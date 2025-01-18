-- Bagshui Inventory Prototype: Item Slot Buttons

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory
local InventoryUi = Bagshui.prototypes.InventoryUi


-- Disabled in favor of ContainerFrameItemButton_OnClick().
-- local function ItemButton_SplitStack(button, split)
-- 	-- These functions are NOT captured into the Bagshui environment to ensure that if they're
-- 	-- hooked by another addon, we call the hooked version instead of the original.
-- 	_G.SplitContainerItem(button.bagshuiData.bagNum, button.bagshuiData.slotNum, split)
-- 	-- Instead of redefining the button.SplitStack function every time,
-- 	-- we're using an additional property to track whether this is a
-- 	-- right-click sell split at the merchant or a normal one.
-- 	if button.bagshuiData.splitStackAtMerchant then
-- 		_G.MerchantItemButton_OnClick("LeftButton")
-- 	end
-- end


--- Special OnHide for Inventory item slot buttons to also hide tooltips and
--- the stack split frame.
local function InventoryItemButton_OnHide()
	-- oldOnHide was captured during button creation in CreateInventoryItemSlotButton().
	_G.this.bagshuiData.oldOnHide()

	if BsInfoTooltip:IsOwned(_G.this) then
		BsInfoTooltip:Hide()
	end

	-- If the stack splitting frame is visible and owned by this inventory window, hide it.
	-- (this.hasStackSplit is managed by Blizzard's FrameXML code).
	if _G.this.hasStackSplit == 1 then
		_G.StackSplitFrame:Hide()
	end
end


--- Create a new item slot button.
--- This is a separate function instead of overriding InventoryUi:CreateItemSlotButton()
--- because they need to take completely different parameters.
---@param buttonNum number? When provided, only create the group if it doesn't exist.
function InventoryUi:CreateInventoryItemSlotButton(buttonNum)
	local ui = self
	local inventory = self.inventory

	-- Wrapper functions so we can reference self.
	if not inventory._itemSlotButton_ScriptWrapper_OnClick then
		function inventory._itemSlotButton_ScriptWrapper_OnClick()
			inventory:ItemButton_OnClick(_G.arg1)
		end
		function inventory._itemSlotButton_ScriptWrapper_OnDragStart()
			inventory:ItemButton_OnClick("LeftButton", true)
		end
		function inventory._itemSlotButton_ScriptWrapper_OnReceiveDrag()
			if _G.CursorHasItem() then
				inventory:ItemButton_OnClick("LeftButton", true)
			end
		end
		function inventory._itemSlotButton_ScriptWrapper_OnUpdate()
			inventory:ItemButton_OnUpdate(_G.arg1)
		end
		function inventory._itemSlotButton_ScriptWrapper_OnEnter()
			inventory:ItemButton_OnEnter()
		end
		function inventory._itemSlotButton_ScriptWrapper_OnLeave()
			inventory:ItemButton_OnLeave()
		end
		function inventory._itemSlotButton_ScriptWrapper_OnHide()
			inventory:ItemButton_OnEnter()
		end
	end


	ui:CreateIfNotExists(
		buttonNum,
		ui.buttons.itemSlots,
		function(elementNum)
			-- The button is created normally, then customized for Inventory use.
			local slotButton = ui:CreateItemSlotButton(
				"Item"..elementNum,
				inventory.uiFrame
			)
			ui.buttons.itemSlots[elementNum] = slotButton

			-- Used by OnUpdate to manage real-time stock badge fading.
			slotButton.bagshuiData.lastStockStateRefresh = _G.GetTime()

			-- Consumed by InventoryItemButton_OnHide(). Must be captured before changing OnHide
			-- to the Inventory-specific version.
			slotButton.bagshuiData.oldOnHide = slotButton:GetScript("OnHide")

			-- Inventory button events.
			slotButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			slotButton:RegisterForDrag("LeftButton")

			slotButton:SetScript("OnClick", inventory._itemSlotButton_ScriptWrapper_OnClick)
			slotButton:SetScript("OnDragStart", inventory._itemSlotButton_ScriptWrapper_OnDragStart)
			slotButton:SetScript("OnReceiveDrag", inventory._itemSlotButton_ScriptWrapper_OnReceiveDrag)
			slotButton:SetScript("OnUpdate", inventory._itemSlotButton_ScriptWrapper_OnUpdate)
			slotButton:SetScript("OnEnter", inventory._itemSlotButton_ScriptWrapper_OnEnter)
			slotButton:SetScript("OnLeave", inventory._itemSlotButton_ScriptWrapper_OnLeave)
			slotButton:SetScript("OnHide", InventoryItemButton_OnHide)

			-- SplitStack() as a button property is required to reuse Blizzard's OpenStackSplitFrame().
			-- Disabled in favor of ContainerFrameItemButton_OnClick().
			-- slotButton.SplitStack = ItemButton_SplitStack
		end
	)
end



--- OnEnter mostly handles tooltip stuff.
---@param itemButton table? Item slot button widget.
function Inventory:ItemButton_OnEnter(itemButton)
	itemButton = itemButton or _G.this

	-- Cases when nothing should happen.
	if
		-- OnEnter still fires even if mouse events are disabled so we need to avoid doing anything when we're in that state.
		not itemButton:IsMouseEnabled()
		-- Don't pop up tooltips or do anything else when a menu is open.
		or self.menus:IsMenuOpen()
	then
		return
	end

	local buttonInfo = itemButton.bagshuiData
	local item = itemButton.bagshuiData.item or self.inventory[buttonInfo.bagNum][buttonInfo.slotNum]

	-- Update IDs so ContainerFrameItemButton_OnEnter() will work.
	-- Disabled because we're currently not actually calling ContainerFrameItemButton_OnEnter,
	-- but this could probably be added in the future if it's found to be necessary for compatibility
	-- with other addons.
	self:UpdateItemButtonIDs(itemButton, item)

	-- Record that the mouse has moved over this button (used by OnUpdate to determine
	-- whether the tooltip should be shown when the Edit Mode cursor puts down an item).
	-- This is used instead of MouseIsOver() because that function returns true even
	-- when the frame is behind other frames.
	buttonInfo.mouseIsOver = true

	-- Highlight all items belonging to a category on mouseover in Edit Mode,
	-- but only if an object hasn't been picked up.
	if self.editState.cursorItem == nil then
		if _G.IsAltKeyDown() and item.id > 0 then
			self.editState.highlightItem = item.id
			self.editState.highlightCategory = nil
		else
			self.editState.highlightItem = nil
			self.editState.highlightCategory = item.bagshuiCategoryId
		end
	end

	-- Nothing further to do when there's an Edit Mode item on the cursor,
	-- This can't be combined with the initial "return immediately" checks above
	-- because we want to trigger Edit Mode highlighting.
	if self:EditModeCursorHasItem() then
		return
	end


	-- Turn off the Bagshui tooltip hint once Alt is held.
	if
		not self.settings.hint_bagshuiTooltip
		and _G.IsAltKeyDown()
	then
		self.settings.hint_bagshuiTooltip = true
	end

	-- Record current modifier key state (referenced by OnUpdate() to decide if it has changed).
	-- Translating return values from 1/nil to true/false so the *KeyDown properties don't have 
	-- to be initialized to non-nil.
	buttonInfo.altKeyDown = (_G.IsAltKeyDown() == 1)
	buttonInfo.controlKeyDown = (_G.IsControlKeyDown() == 1)
	buttonInfo.shiftKeyDown = (_G.IsShiftKeyDown() == 1)

	-- In Edit Mode and/or "Bagshui Info" mode with Alt down, special behavior needs to be enabled:
	-- - Tooltips get truncated at the first blank line so there's more room for the Bagshui tooltip (if enabled).
	local truncateTooltip = (
		(BS_INVENTORY_TRUNCATE_TOOLTIPS_EDIT_MODE and self.editMode)
		or (BS_INVENTORY_TRUNCATE_TOOLTIPS_INFO_MODE and _G.IsAltKeyDown())
	)
	-- Empty slots deserve a tooltip too sometimes.
	local displayTooltipForEmptySlots = (_G.IsAltKeyDown() or self.editMode)

	-- When Alt is held in Edit Mode, swap from the Category tooltip to the Item tooltip.
	local editModeShowItemTooltip = self.editMode and _G.IsAltKeyDown()

	-- GameTooltip normally anchors to item frame, but in Edit Mode it attaches to the group frame.
	local gameTooltipAnchorPoint = BsUtil.FlipAnchorPoint(self.settings.windowAnchorXPoint)
	local tooltipAnchorFrame = self.editMode and itemButton:GetParent() or itemButton
	local tooltipOffset = BsSkin.tooltipExtraOffset
	_G.GameTooltip:SetOwner(
		itemButton,
		-- Using ANCHOR_PRESERVE here for Edit Mode instead of ANCHOR_NONE
		-- so pfUI doesn't mess with the position.
		"ANCHOR_" .. (self.editMode and "PRESERVE" or gameTooltipAnchorPoint),
		-tooltipOffset,
		tooltipOffset
	)
	if self.editMode then
		_G.GameTooltip:SetPoint(
			"BOTTOM" .. BsUtil.FlipAnchorPoint(gameTooltipAnchorPoint),
			tooltipAnchorFrame,
			"TOP" .. gameTooltipAnchorPoint,
			-tooltipOffset,
			tooltipOffset
		)
	end

	-- When true, the class instance had a `itemSlotTooltipFunction` defined
	-- and we need to reapply our preferred tooltip position.
	local setTooltipPositionAgain = false


	-- Populate GameTooltip with Item or Edit Mode information, as appropriate.

	if not self.editMode or editModeShowItemTooltip then
		-- Item tooltip outside Edit Mode, or if Alt is held in Edit Mode.

		-- Empty slots have special handling, as usual.
		if item.emptySlot == 1 then
			-- This is an empty slot.

			_G.GameTooltip:ClearLines()

			-- Add name.
			if
				(
					displayTooltipForEmptySlots
					or self.settings.stackEmptySlots
				)
				and item.name ~= nil
			then
				_G.GameTooltip:AddLine(
					BsItemInfo:GetQualityColoredName(item),
					1, 1, 1,
					true
				)
			end

			-- Empty slot stacking/unstacking instructions should only be added when appropriate.
			if
				not self.editMode
				and self.settings.stackEmptySlots
				and not _G.CursorHasItem()
			then
				_G.GameTooltip:AddLine(
					string.format(L.Tooltip_Inventory_ToggleEmptySlotStacking, L.Click, string.lower(self.expandEmptySlotStacks and L.Stack or L.Unstack)),
					nil, nil, nil,
					true
				)
			end


		else
			-- There's an item in this slot.

			-- These will be populated with the return values of ItemInfo:LoadTooltip().
			local hasCooldown, repairCost

			-- Populate the tooltip.
			-- There doesn't seem to be a way to get hasCooldown/repairCost without
			-- loading the tooltip, so we have to call this even if there's an
			-- itemSlotTooltipFunction that's going to load it again.
			hasCooldown, repairCost = BsItemInfo:LoadTooltip(_G.GameTooltip, item, self)

			-- This class instance has a custom tooltip loading function.
			-- Spoiler: It's probably ContainerFrameItemButton_OnEnter().
			-- (itemSlotTooltipFunction is the function name, not the actual function
			-- see declaration in Inventory.lua for reasoning.)
			if
				not self.editMode  -- Not calling in Edit Mode so we cut out some hooks and have a little more control.
				and not truncateTooltip  -- Also, we don't need extra stuff if we're just going to truncate anyway.
				and self.itemSlotTooltipFunction
				and type(_G[self.itemSlotTooltipFunction]) == "function"
			then
				-- Ugh, this is stupid, but the GFW tooltip hooking code doesn't
				-- have `ContainerFrameItemButton_OnEnter()`'s button parameter,
				-- so the Blizzard function ends up pulling the global `this`
				-- instead of the passed parameter. When `Inventory:ItemSlotAndGroupMouseOverCheck()`
				-- calls us, global `this` isn't the item slot button and
				-- `ContainerFrameItemButton_OnEnter()`'s call to `GetRight()`
				-- returns nil, throwing an error. We can work around their bug by
				-- temporarily changing the value of global `this`, then restoring it.
				local oldGlobalThis = _G.this
				_G.this = itemButton
				_G[self.itemSlotTooltipFunction](itemButton)
				_G.this = oldGlobalThis
				-- `ContainerFrameItemButton_OnEnter()` will change the tooltip position
				-- to something that ignores our custom offsets, so we need to fix that.
				setTooltipPositionAgain = true
			end

			-- There are situations where we may want to truncate the tooltip
			-- at the first empty line to leave more room for the Bagshui tooltip.
			-- This code was originally written when information was being added
			-- to GameTooltip instead of a separate tooltip, so it was very
			-- necessary due to the tooltip line limit. Now that the Bagshui Info
			-- tooltip is used instead, it's not as relevant, but it's still nice to
			-- not have GameTooltip so giant when the Bagshui Info tooltip is shown.
			-- The BS_INVENTORY_TRUNCATE_TOOLTIPS_*_MODE constants control whether
			-- tooltip truncation is enabled.
			if truncateTooltip then

				local firstBlankLine, ttTextFrame, ttText, leftText, rightText
				for ttLineNum = 1, _G.GameTooltip:NumLines() do
					leftText = nil
					rightText = nil
					for i, lr in ipairs(BsHiddenTooltip.bagshuiData.textFieldsPerLine) do
						ttTextFrame = _G["GameTooltipText" .. lr .. ttLineNum]
						if ttTextFrame ~= nil and ttTextFrame:IsVisible() then
							ttText = ttTextFrame:GetText()

							if ttText ~= nil and not string.find(ttText, "^" .. BS_NEWLINE) then
								if i == 1 then
									leftText = BsUtil.Trim(ttText)
								else
									rightText = BsUtil.Trim(ttText)
								end
							end
						end
					end

					-- We found a blank line and can truncate here..
					if string.len(leftText or "") == 0 and string.len(rightText or "") == 0 then
						firstBlankLine = ttLineNum
						break
					end
				end

				-- Hide lines.
				if firstBlankLine then
					for line = firstBlankLine, _G.GameTooltip:NumLines() do
						for _, lr in ipairs(BsHiddenTooltip.bagshuiData.textFieldsPerLine) do
							if _G["GameTooltipText" .. lr .. line] then
								_G["GameTooltipText" .. lr .. line]:SetText(nil)
								_G["GameTooltipText" .. lr .. line]:Hide()
							end
						end
					end
					_G.GameTooltipMoneyFrame:Hide()
				end
			end


			-- Don't want to apply this stuff in Edit Mode since normal functionality isn't available.
			if not self.editMode then
				_G.ResetCursor()

				-- Trigger ItemButton_OnUpdate to reload the tooltip after 1 second if there's an active cooldown.
				-- (In other words, the 1 here represents number of seconds, NOT `true`).
				buttonInfo.tooltipCooldownUpdate = hasCooldown and 1 or nil

				-- Special cases.
				if _G.InRepairMode() and (repairCost and repairCost > 0) then
					-- Repair mode.
					_G.GameTooltip:AddLine(_G.TEXT(_G.REPAIR_COST), 1, 1, 1)
					_G.SetTooltipMoney(_G.GameTooltip, repairCost)

				elseif self.ui:IsFrameVisible(_G.MerchantFrame) then
					-- At merchant.
					_G.ShowContainerSellCursor(item.bagNum, item.slotNum)

				elseif (item.readable or (_G.IsControlKeyDown() and not _G.IsAltKeyDown())) and item.emptySlot ~= 1 then
					-- Readable items (books, etc) / Control key dressup.
					_G.ShowInspectCursor()

				end
			end
		end

		-- Show Alt+Click Trade hint when appropriate.
		if (self.settings.rightClickAttach or self.settings.altClickAttach) and self:IsInitiateTradeAllowed(item) then
			_G.GameTooltip:AddLine(string.format(L.Tooltip_Inventory_TradeShortcut, L.AltClick, _G.UnitName("target")))
		end


	elseif self.editMode then
		-- By default in Edit Mode, show category info as the primary tooltip.
		-- This gets overridden when Alt is held.
		_G.GameTooltip:AddLine(
			Bagshui:FormatTooltipLine(
				(BsCategories:GetName(item.bagshuiCategoryId) or L.Error_ItemCategoryUnknown),
				string.format(L.Symbol_Colon, L.Category), self.editMode
			)
		)
	end


	-- Bagshui Info Tooltip
	if
		self.editMode
		or _G.IsAltKeyDown()
		or (
			BsSettings.showInfoTooltipsWithoutAlt
			and not _G.IsShiftKeyDown()
		)
	then

		-- 4th parameter: Always place the info tooltip under GameTooltip in edit mode.
		Bagshui:SetInfoTooltipPosition(itemButton, true, self.editMode)

		if not self.editMode then

			-- There's no real information to show for empty slot stacks.
			if not buttonInfo.isEmptySlotStack then

				-- Populate the tooltip.
				if _G.IsControlKeyDown() then
					-- All item properties.
					BsItemInfo:AddTooltipInfo(item, BsInfoTooltip)

				else
					-- Normal mode.

					-- We only want blank lines between sections after one section has been added.
					local spacerNeeded = false

					-- Inventory counts.
					spacerNeeded = BsCatalog:AddTooltipInfo(item.itemString, BsInfoTooltip)

					-- Only show more in-depth info when Alt is held, even if showInfoTooltipsWithoutAlt is on.
					if _G.IsAltKeyDown() then

						-- Active quest info.
						if Bagshui.activeQuestItems[item.name] then
							if spacerNeeded then
								self:AddBagshuiInfoTooltipLine(" ")
							end
							self:AddBagshuiInfoTooltipLine(tostring(Bagshui.activeQuestItems[item.name].obtained or "?") .. "/" .. tostring(Bagshui.activeQuestItems[item.name].needed or "?"), string.format(L.Symbol_Colon, L.ItemPropFriendly_activeQuest))
							spacerNeeded = true
						end

						-- Stock state.
						if
							(item.bagshuiDate or 0) > 0
							and item.bagshuiStockState ~= nil
							and item.bagshuiStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE
						then
							if spacerNeeded then
								self:AddBagshuiInfoTooltipLine(" ")
							end
							self:AddBagshuiInfoTooltipLine(L["Stock_" .. item.bagshuiStockState], string.format(L.Symbol_Colon, L.StockState))
							self:AddBagshuiInfoTooltipLine(BsUtil.FormatTimeRemainingString(_G.time() - item.bagshuiDate), string.format(L.Symbol_Colon, L.StockLastChange))
							spacerNeeded = true
						end

						-- Assigned category and bag name.
						if spacerNeeded then
							self:AddBagshuiInfoTooltipLine(" ")
						end
						self:AddBagshuiInfoTooltipLine((BsCategories:GetName(item.bagshuiCategoryId) or L.Error_ItemCategoryUnknown), string.format(L.Symbol_Colon, L.Category), false)
						self:AddBagshuiInfoTooltipLine((self.containers[item.bagNum].name or L.Unknown), string.format(L.Symbol_Colon, L.Bag))

						-- Instructions.
						self:AddBagshuiInfoTooltipLine(" ")
						self:AddBagshuiInfoTooltipLine(L.AltRightClick, string.format(L.Symbol_Colon, string.format(L.Suffix_Menu, L.Item)))
						self:AddBagshuiInfoTooltipLine(L.HoldControlAlt, string.format(L.Symbol_Colon, L.MoreInformation))
					end
				end

			end


		else
			-- Edit Mode.

			if editModeShowItemTooltip then
				-- Item instructions.

				if item.id > 0 then
					self:AddBagshuiInfoTooltipLine(L.AltClick, string.format(L.Symbol_Colon, string.format(L.Prefix_Move, L.Item)))
				end
				self:AddBagshuiInfoTooltipLine(L.RightClick, string.format(L.Symbol_Colon, string.format(L.Suffix_Menu, L.CategorySlashItem)))

				self:AddBagshuiInfoTooltipLine(" ")

				-- Category name.
				self:AddBagshuiInfoTooltipLine((BsCategories:GetName(item.bagshuiCategoryId) or L.Error_ItemCategoryUnknown), string.format(L.Symbol_Colon, L.Category), self.editMode)
				-- Target Category: Release Alt.
				self:AddBagshuiInfoTooltipLine(L.ReleaseAlt, string.format(L.Symbol_Colon, string.format(L.Prefix_Target, L.Category)))

			else
				-- Category instructions.

				-- Move Category: Click.
				self:AddBagshuiInfoTooltipLine(L.Click, string.format(L.Symbol_Colon, string.format(L.Prefix_Move, L.Category)))
				-- Category/Item Menu: Right-Click.
				self:AddBagshuiInfoTooltipLine(L.RightClick, string.format(L.Symbol_Colon, string.format(L.Suffix_Menu, L.CategorySlashItem)))
				self:AddBagshuiInfoTooltipLine(" ")

				-- Item name.
				if string.len(item.name or "") > 0 then
					self:AddBagshuiInfoTooltipLine(BsItemInfo:GetQualityColoredName(item), string.format(L.Symbol_Colon, L.Item), true)
				end

				-- Target Item: Hold Alt.
				self:AddBagshuiInfoTooltipLine(L.HoldAlt, string.format(L.Symbol_Colon, string.format(L.Prefix_Target, L.Item)))

			end

		end

	elseif not self.settings.hint_bagshuiTooltip then
		-- Show tip about holding alt to display Bagshui info tooltip.
		Bagshui:SetInfoTooltipPosition(itemButton, true)
		self:AddBagshuiInfoTooltipLine(L.HoldAlt, string.format(L.Symbol_Colon, L.BagshuiTooltipIntro))

	else
		-- Clear the tooltip so we know not to display it.
		BsInfoTooltip:ClearLines()
	end

	-- Normal tooltip.
	if _G.GameTooltip:NumLines() > 0 or _G.GameTooltip:IsVisible() then
		-- Quality color tooltip borders (currently a hidden setting).
		if
			self.settings.qualityColorTooltipBorders
			and type(buttonInfo.qualityColor) == "table"
			and item.quality > -1
			and itemButton.bagshuiData.buttonComponents
			and itemButton.bagshuiData.buttonComponents.border
		then
			_G.GameTooltip:SetBackdropBorderColor(
				buttonInfo.qualityColor.r,
				buttonInfo.qualityColor.g,
				buttonInfo.qualityColor.b
			)
		end

		-- Need to reapply customized tooltip position.
		-- See setTooltipPositionAgain declaration for details.
		if setTooltipPositionAgain then
			_G.GameTooltip:ClearAllPoints()
			_G.GameTooltip:SetPoint(
				"BOTTOM" .. BsUtil.FlipAnchorPoint(gameTooltipAnchorPoint),
				tooltipAnchorFrame,
				"TOP" .. gameTooltipAnchorPoint,
				-tooltipOffset,
				tooltipOffset
			)
		end

		_G.GameTooltip:Show()
	else
		_G.GameTooltip:Hide()
	end

	-- Bagshui info tooltip.
	if BsInfoTooltip:NumLines() > 0 then
		Bagshui:ShowInfoTooltip()
	else
		BsInfoTooltip:Hide()
	end


	-- If the mouse is obscuring the tooltip, move the tooltip to the other side of the item button.
	local offset = 10
	if
		(
			_G.MouseIsOver(_G.GameTooltip, offset, offset, offset, -offset)
			or (
				BsInfoTooltip:IsVisible()
				and _G.MouseIsOver(BsInfoTooltip, offset, offset, offset, -offset)
			)
		)
		and (_G.GameTooltip:GetNumPoints() or 0) > 0
	then
		local point, anchorTo, anchorToPoint, xOffset, yOffset = _G.GameTooltip:GetPoint(1)
		_G.GameTooltip:ClearAllPoints()
		_G.GameTooltip:SetPoint(
			BsUtil.FlipAnchorPointComponent(point, 2),
			anchorTo,
			BsUtil.FlipAnchorPointComponent(anchorToPoint, 2),
			-xOffset,
			yOffset
		)

		if BsInfoTooltip:IsVisible() then
			point, anchorTo, anchorToPoint, xOffset, yOffset = BsInfoTooltip:GetPoint(1)
			BsInfoTooltip:ClearAllPoints()
			BsInfoTooltip:SetPoint(
				BsUtil.FlipAnchorPointComponent(point, 2),
				anchorTo,
				BsUtil.FlipAnchorPointComponent(anchorToPoint, 2),
				-xOffset,
				yOffset
			)
		end
	end

	-- Edit Mode highlighting.
	self:EditModeWindowUpdate(nil, true)

	-- Highlight bag this item is in.
	self.hoveredItem = item
	self:UpdateBagBar()
end



--- OnLeave: Reset everything and hide the tooltip.
function Inventory:ItemButton_OnLeave()
	local itemButton = _G.this

	-- Clear Edit Mode category highlighting.
	if self.editState.cursorItemType ~= BS_INVENTORY_OBJECT_TYPE.CATEGORY or self.editState.cursorItem == nil then
		self.editState.highlightCategory = nil
	end
	if self.editState.cursorItemType ~= BS_INVENTORY_OBJECT_TYPE.ITEM or self.editState.cursorItem == nil then
		self.editState.highlightItem = nil
	end

	-- Reset tracking properties.
	itemButton.bagshuiData.tooltipCooldownUpdate = nil
	itemButton.bagshuiData.altKeyDown = nil
	itemButton.bagshuiData.controlKeyDown = nil
	itemButton.bagshuiData.shiftKeyDown = nil

	-- Record that the mouse has left this button (used by OnUpdate to determine
	-- whether the tooltip should be shown when the Edit Mode cursor puts down an item).
	-- This is used instead of MouseIsOver() because that function returns true
	-- even when the frame is behind other frames.
	itemButton.bagshuiData.mouseIsOver = false

	-- Hide the main tooltip.
	if _G.GameTooltip:IsOwned(itemButton) then
		_G.GameTooltip:Hide()
		-- Go back to the normal cursor unless the Edit Mode cursor is holding something.
		if not BsCursorTooltip:IsVisible() then
			_G.ResetCursor()
		end
	end

	-- Hide our tooltip.
	if BsInfoTooltip:IsOwned(itemButton) then
		BsInfoTooltip:Hide()
	end

	-- Update Edit Mode colors.
	self:EditModeWindowUpdate(nil, true)

	-- Un-highlight bag this item is in.
	self.hoveredItem = nil
	self:UpdateBagBar()
end



-- Store reusable variable outside OnUpdate to keep the garbage collector happy.
local itemButton_OnUpdate_RefreshTooltip

-- The main goal of OnUpdate is to keep the tooltip up to date by calling OnEnter once
-- a second (if needed) so long as the mouse remains over the item slot. It also
-- does a couple of other things.
-- 
-- We need a fresh call to OnEnter when his itemButton owns the tooltip and one
-- of the following is true:
--   - The `bagshuiData.tooltipCooldownUpdate` property exists and it's been more than 1 second since it was set.
--   - The `bagshuiData.<modifier>KeyDown` property doesn't match `Is<Modifier>KeyDown()`.
---@param elapsed number? Time since the last OnUpdate call.
function Inventory:ItemButton_OnUpdate(elapsed)

	-- Refresh stock state every 60 seconds so badges fade in almost real-time.
	if
		_G.this.bagshuiData
		and _G.this.bagshuiData.item
		and _G.this.bagshuiData.item.bagshuiStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE
		and _G.GetTime() - _G.this.bagshuiData.lastStockStateRefresh > 60
		and _G.this.bagshuiData.type == BS_UI_ITEM_BUTTON_TYPE.ITEM
	then
		self.ui:UpdateItemButtonStockState(_G.this)
		self.ui:UpdateItemButtonColorsAndBadges(_G.this)
		_G.this.bagshuiData.lastStockStateRefresh = _G.GetTime()
	end

	-- Edit Mode help - make tooltips disappear as soon as the cursor holds an item.
	if
		self.editMode
		and _G.this.bagshuiData.mouseIsOver
		and self:EditModeCursorHasItem()
		and _G.GameTooltip:IsOwned(_G.this)
	then
		self:ItemButton_OnLeave()
		return
	end

	-- Clear state tracking variables when the mouse isn't present.
	if not _G.this.bagshuiData.mouseIsOver then
		_G.this.bagshuiData.tooltipCooldownUpdate = nil
		_G.this.bagshuiData.altKeyDown = nil
		_G.this.bagshuiData.controlKeyDown = nil
		_G.this.bagshuiData.shiftKeyDown = nil
		return
	end

	-- Does the tooltip need to be updated?
	itemButton_OnUpdate_RefreshTooltip = false

	-- More Edit Mode help - display tooltips as soon as the cursor no longer holds an item.
	if self.editMode and _G.this.bagshuiData.mouseIsOver and not _G.GameTooltip:IsOwned(_G.this) then
		itemButton_OnUpdate_RefreshTooltip = true
	end

	-- Update cooldown info in tooltip.
	if _G.this.bagshuiData.tooltipCooldownUpdate ~= nil then
		-- tooltipCooldownUpdate is initially set to 1 by OnEnter when there's a cooldown.
		-- Here we subtract the elapsed time in seconds, which will eventually go below 0
		-- so long as the property isn't wiped by moving the mouse off this item.
		_G.this.bagshuiData.tooltipCooldownUpdate = _G.this.bagshuiData.tooltipCooldownUpdate - elapsed

		-- Don't proceed until it's been more than 1 second.
		if _G.this.bagshuiData.tooltipCooldownUpdate < 0 then
			itemButton_OnUpdate_RefreshTooltip = true
		end
	end

	-- Show/hide tooltip when modifier key state changes.
	-- The 1/nil to true/false translation was done in our ItemButton_OnEnter
	-- for reasons explained there, so we need to mirror it here.
	if
		(
			_G.this.bagshuiData.altKeyDown ~= nil
			and _G.this.bagshuiData.altKeyDown ~= (_G.IsAltKeyDown() == 1)
		)
		or
		(
			_G.this.bagshuiData.controlKeyDown ~= nil
			and _G.this.bagshuiData.controlKeyDown ~= (_G.IsControlKeyDown() == 1)
		)
		or
		(
			_G.this.bagshuiData.shiftKeyDown ~= nil
			and _G.this.bagshuiData.shiftKeyDown ~= (_G.IsShiftKeyDown() == 1)
		)
	then
		itemButton_OnUpdate_RefreshTooltip = true
	end

	-- Time to update the tooltip.
	if itemButton_OnUpdate_RefreshTooltip then
		self:ItemButton_OnEnter(_G.this)
	end
end



--- Left and right click and all the modifier key combinations.
---@param mouseButton string
---@param isDrag number|nil|boolean
function Inventory:ItemButton_OnClick(mouseButton, isDrag)
	local itemButton = _G.this

	local buttonInfo = itemButton.bagshuiData
	local item = self.inventory[buttonInfo.bagNum][buttonInfo.slotNum]

	-- Update IDs so ContainerFrameItemButton_OnClick() will work.
	self:UpdateItemButtonIDs(itemButton, item)

	-- Nothing normal should happen in Edit Mode.
	if self.editMode then

		if mouseButton == "LeftButton" then
			-- When a menu is open, just close it and don't do anything else.
			-- Without this, you can accidentally pick up a group/category/item when trying to close a menu.
			if self.menus:IsMenuOpen() then
				Bagshui:CloseMenus()
				-- Need to update state so that things know the cursor is present.
				self:ItemButton_OnEnter()
				return
			end

			if self:EditModeCursorHasItem() then
				-- Something has been picked up. We can only take action here if it's a category.
				if self.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.CATEGORY then
					self:AssignCategoryToGroup(self.editState.cursorItem, buttonInfo.groupId)
				end

			else
				-- Nothing on the cursor, so pick up the Item/Category.
				if _G.IsAltKeyDown() then
					self:EditModePickUpItem(item)
				else
					self:EditModePickUpCategory(item.bagshuiCategoryId)
				end
			end


		elseif mouseButton == "RightButton" then
			-- Just open the item menu on right-click.
			self:ClearEditModeCursor()
			self.menus:OpenMenu("Item", item, nil, "cursor")
		end


	else
		-- Normal processing (non-Edit Mode).

		-- Make sure there's an item of some sort to work with (can be an empty slot representation).
		if item then

			-- Clear stock state when interacting with an item.
			if self.settings.itemStockChangeClearOnInteract then
				item.bagshuiDate = -1
			end

			-- Flip the expandEmptySlotStacks flag when clicking empty slots if stacking is enabled.
			if
				self.settings.stackEmptySlots
				and not isDrag
				and mouseButton == "LeftButton"
				and not _G.CursorHasItem()
				and item.emptySlot == 1
			then
				self.expandEmptySlotStacks = buttonInfo.isEmptySlotStack
				self:ItemButton_OnLeave()
				self:ForceUpdateWindow()
				return
			end

			-- Can't do anything else offline.
			if not self.online then
				return
			end

			-- Try to do something with the item. When that fails, go on to default actions.
			local clickHandled = true
			local callPickupContainerItemFromBagshuiPickupItem = false
			if
				-- Drag action.
				-- Don't allow anything else to happen when a drag action has been initiated,
				-- since this should always pick up the item, no matter what modifiers are pressed.
				isDrag
			then
				-- Use the default left button handler but go directly to PickupContainerItem()
				-- instead of proxying through ContainerFrameItemButton_OnClick() since we
				-- absolutely know we want to pick up the item immediately.
				mouseButton = "LeftButton"
				clickHandled = false
				callPickupContainerItemFromBagshuiPickupItem = true


			elseif
				-- Item information menu Alt+right-click blocks everything else.
				mouseButton == "RightButton" and _G.IsAltKeyDown()
			then
				self.menus:OpenMenu("Item", item, nil, "cursor")
				-- Makes sense to return here since there's no need for a window update.
				return


			elseif
				-- Blizzard Mail Attachments - Right-click/Alt+click.
				self:IsItemClickActionAllowed(mouseButton, "InboxFrame", "SendMailFrame")
				-- Doing two checks here for "Mail" addon in case another addon ends up replicating
				-- the way it handles attachments.
				and not _G.IsAddOnLoaded("Mail")
				and _G.SendMailPackageButton:IsEnabled() == 1
			then
				-- Switch to the Send Mail tab and attach the item.
				self:AttachItem(
					item,
					_G.MailFrameTab_OnClick, 2,
					_G.ClickSendMailItemButton
				)


			elseif
				-- "Mail" addon - Alt+click (it only provides right-click).	
				(mouseButton == "LeftButton" and _G.IsAltKeyDown())
				and self.settings.altClickAttach
				and self.ui:IsFrameVisible("MailFrame")
				and _G.IsAddOnLoaded("Mail")
			then
				-- Pretend Alt isn't down so Mail's UseContainerItem will do the work.
				self:ContainerItemAction(item, "Use", false)


			elseif
				-- CT_MailMod, Postal, and Postal Returned [Postal is descended from CT_MailMod] -
				-- Right-click (they only provide Alt+click).
				mouseButton == "RightButton"
				and self.settings.rightClickAttach
				and (
					(_G.IsAddOnLoaded("CT_MailMod") and self.ui:IsFrameVisible("CT_MailFrame"))
					or (
						(
							-- The Postal family.
							_G.IsAddOnLoaded("Postal")
							or _G.IsAddOnLoaded("Postal Returned")
							-- IsAddOnLoaded goes by TOC file name, and Postal Returned
							-- can be loaded from Postal-Returned.toc as well
							-- due to <https://github.com/veechs/Postal-Returned/issues/2>.
							or _G.IsAddOnLoaded("Postal-Returned")
						) and self.ui:IsFrameVisible("PostalFrame")
					)
				)
			then
				-- Pretend Alt is down so their code will do the item attachment work.
				self:ContainerItemAction(item, "Pickup", true)


			elseif
				-- Blizzard Auction House - Right-click/Alt+click.
				self:IsItemClickActionAllowed(mouseButton, "AuctionFrame")
			then
				-- Switch to the Auctions tab and attach the item.
				self:AttachItem(
					item,
					_G.AuctionFrameTab_OnClick, 3,
					_G.ClickAuctionSellItemButton
				)


			elseif
				-- aux - Alt+click (it only provides right-click).
				(mouseButton == "LeftButton" and _G.IsAltKeyDown())
				and self.settings.altClickAttach
				and _G.IsAddOnLoaded("aux-addon")
				and self.ui:IsFrameVisible("aux_frame")
			then
				-- Pretend Alt isn't down so aux's UseContainerItem will do the work.
				self:ContainerItemAction(item, "Use", false)


			elseif
				-- Trade - Right-click/Alt+click.
				self:IsItemClickActionAllowed(mouseButton, "TradeFrame")
			then
				local tradeSlot = _G.TradeFrame_GetAvailableSlot()
				if tradeSlot then
					self:AttachItem(item, nil, nil, _G.ClickTradeButton, tradeSlot)
				end


			elseif
				-- Initiate Trade on Al+click when friendly unit is targeted.
				(self.settings.rightClickAttach or self.settings.altClickAttach)
				and mouseButton == "LeftButton"
				and _G.IsAltKeyDown()
				and self:IsInitiateTradeAllowed(item)
			then
				-- We've already hooked TradeFrame_OnShow so that once the Trade window opens,
				-- Inventory:TradeQueuedItem() can add self.queuedTradeItem.
				self.queuedTradeItem = item
				_G.InitiateTrade("target")


			else
				-- No conditions were met, so go on to default actions.
				clickHandled = false
			end


			-- Keeping this as a separate statement instead of putting it in the else
			-- clause for the other actions above in case there's a situation where an
			-- action might want to fall through to default behavior when it fails.
			if not clickHandled then

				if mouseButton == "LeftButton" then
					-- Normal left-click.
					-- This will eventually become a call to ContainerFrameItemButton_OnClick(), which can handle:
					-- - Control+click dress-up.
					-- - Shift+click chat links.
					-- - Shift+click stack splitting.
					-- - Calling PickupContainerItem() if none of the above are met.
					-- It also allows hooks to both ContainerFrameItemButton_OnClick() and PickupContainerItem() to work.
					-- (See the declaration of Bagshui:PickupItem() for details about why it exists.)
					Bagshui:PickupItem(item, self, itemButton, callPickupContainerItemFromBagshuiPickupItem)

				else
					-- Normal right-click.
					-- ContainerFrameItemButton_OnClick() for right button will handle:
					-- - Shift+right-click stack splitting at merchant.
					-- - Otherwise calling UseContainerItem().
					-- It also allows hooks to both ContainerFrameItemButton_OnClick() and UseContainerItem() to work.
					_G.ContainerFrameItemButton_OnClick(mouseButton)
				end
			end

			-- Hide tooltip on click -- UpdateWindow() will call ItemSlotAndGroupMouseOverCheck(), which will show it again if needed.
			self:ItemButton_OnLeave()
			-- Something was clicked, so make sure the window is up to date.
			self:ForceUpdateWindow()
		end
	end
end



--- Set item slot button and parent frame ID to the given item's bagNum and slotNum, respectively.
--- This provides compatibility with Blizzard's ContainerFrameItemButton_OnClick(), etc.
---@param button table Item slot button.
---@param item table Bagshui item.
function Inventory:UpdateItemButtonIDs(button, item)
	button:SetID(item and item.slotNum or -99)
	button:GetParent():SetID(item and item.bagNum or -99)
end



--- Return the appropriate empty slot texture (generic or profession-specific).
---@param emptySlot table Bagshui item table for the empty slot.
---@return string texturePath
function Inventory:GetEmptySlotTexture(emptySlot)
	local texture = BS_INVENTORY_EMPTY_SLOT_TEXTURE[L.Bag]
	if self.containers[emptySlot.bagNum] then
		texture = BS_INVENTORY_EMPTY_SLOT_TEXTURE[self.containers[emptySlot.bagNum].genericType]
	end
	return texture
end



--- Call `PickupContainerItem()` for the given item, forcing Alt to be up, and
--- optionally calling the specified function(s) before/after.
--- The cursor will be cleared afterwards if an item is present, since the whole
--- point of this function is to get an item attached. To pick up an item, use
--- Bagshui:PickupItem() instead.
---@param item table Bagshui item.
---@param beforePickupFunction function? Function to call before `PickupContainerItem()`.
---@param beforePickupParam any? Parameter to pass to `beforePickupFunction()`.
---@param afterPickupFunction function? Function to call after `PickupContainerItem()`.
---@param afterPickupParam any? Parameter to pass to `afterPickupFunction()`.
function Inventory:AttachItem(item, beforePickupFunction, beforePickupParam, afterPickupFunction, afterPickupParam)
	if type(beforePickupFunction) == "function" then
		beforePickupFunction(beforePickupParam)
	end

	-- Ensure Alt is NOT down so addons like CT_MailMod, Postal, and Postal Returned that hook
	-- PickupContainerItem and alter its behavior when Alt is down won't mess things up.
	self:ContainerItemAction(item, "Pickup", false)

	if type(afterPickupFunction) == "function" then
		afterPickupFunction(afterPickupParam)
	end

	-- Put item back if our action wasn't successful or the item was swapped with another.
	if _G.CursorHasItem() then
		_G.ClearCursor()
	end
end



--- Call `PickupContainerItem()` or `UseContainerItem()` for the given item while forcing
--- the Alt key to be in a specific state by temporarily overriding `IsAltKeyDown()`.
---@param item table Bagshui item.
---@param action string `"Pickup"` or `"Use"` as in `PickupContainerItem` or `UseContainerItem`.
---@param altDown boolean? `true` for Alt down, `false` for Alt up.
function Inventory:ContainerItemAction(item, action, altDown)
	local oldIsAltKeyDown = _G.IsAltKeyDown
	_G.IsAltKeyDown = altDown and BsUtil.ReturnTrue or BsUtil.ReturnFalse
	_G[(string.lower(action or "") == "use" and "UseContainerItem" or "PickupContainerItem")](item.bagNum, item.slotNum)
	_G.IsAltKeyDown = oldIsAltKeyDown
end



--- Determine whether an Alt+click or right-click action is allowed.
--- If there's currently an item on the cursor, the answer will be no, regardless of anything else.
---@param mouseButton string OnClick arg1.
---@param frame1 string? Any of the frameN parameters must be visible for this to return `true`.
---@param frame2 string? 
---@param frame3 string? 
---@param frame4 string? 
---@return boolean
function Inventory:IsItemClickActionAllowed(mouseButton, frame1, frame2, frame3, frame4)
	return
		not _G.CursorHasItem()
		and (
			(self.settings.altClickAttach and mouseButton == "LeftButton" and _G.IsAltKeyDown())
			or (self.settings.rightClickAttach and mouseButton == "RightButton")
		)
		and (
			self.ui:IsFrameVisible(frame1)
			or self.ui:IsFrameVisible(frame2)
			or self.ui:IsFrameVisible(frame3)
			or self.ui:IsFrameVisible(frame4)
		)
end



--- Determine whether trade can be initiated with the targeted unit.
---@param item table Bagshui item.
---@return boolean
function Inventory:IsInitiateTradeAllowed(item)
	return
		not _G.CursorHasItem()
		-- Must be a valid item, not an empty slot.
		and item
		and item.emptySlot ~= 1
		and item.itemString
		and item.itemString ~= ""
		-- Can't trade soulbound items.
		and not string.find(item.tooltip, _G.ITEM_SOULBOUND)
		-- No "action" frames visible.
		and not self.ui:IsFrameVisible("TradeFrame")
		and not self.ui:IsFrameVisible("AuctionFrame")
		and not self.ui:IsFrameVisible("MailFrame")
		-- Can't trade with yourself.
		and not _G.UnitIsUnit("target", "player")
		-- Friendly units only.
		and _G.UnitExists("target")
		and _G.UnitIsFriend("player", "target")
		and _G.UnitIsPlayer("target")
		-- Must be close enough.
		and _G.CheckInteractDistance("target", 2)
end



--- Hook for trade frame so we can add the Alt+clicked item after it opens.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call.
function Inventory:TradeFrame_OnShow(wowApiFunctionName)
	self.hooks:OriginalHook(wowApiFunctionName)
	Bagshui:QueueClassCallback(self, self.TradeQueuedItem, 0.05)
end



--- Helper for TradeFrame_OnShow to try and ensure the item we want to Alt+click trade
--- actually gets traded, even if things are running slow.
---@param attemptCount number How many passes we've made while trying to trade the item.
function Inventory:TradeQueuedItem(attemptCount)
	attemptCount = attemptCount or 1

	-- Reasons to stop:
	if
		-- Too many tries.
		attemptCount > 30
		-- Nothing has been queued to trade.
		or not self.queuedTradeItem
		-- There's an item on the cursor that ISN'T the one we're trying to put in the trade window.
		or (_G.CursorHasItem() and (Bagshui.cursorItem ~= self.queuedTradeItem or Bagshui.cursorItem == nil))
		-- First slot in the trade window has been filled.
		or (_G.TradePlayerItem1ItemButton and _G.TradePlayerItem1ItemButton.hasItem)
		-- Trade frame was closed.
		or not self.ui:IsFrameVisible("TradeFrame")
	then
		self.queuedTradeItem = nil
		return
	end

	-- We might have the item we want already on the cursor based on the checks above.
	if not _G.CursorHasItem() then
		-- Calling PickupContainerItem() directly since we don't need any of the things 
		-- Bagshui:PickupItem() provides (and calling ContainerFrameItemButton_OnClick()
		-- will generate an error now since _G.this isn't the item button.)
		self:ContainerItemAction(self.queuedTradeItem, "Pickup", false)
	end
	_G.ClickTradeButton(1)

	-- Do another pass to make sure it worked.
	Bagshui:QueueClassCallback(self, self.TradeQueuedItem, 0.05, nil, attemptCount + 1)
end


end)