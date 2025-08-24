-- Bagshui Inventory Prototype: UI
--
-- Creation of the main window frame and general Inventory-specific UI stuff

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory


--- Set up everything related to the UI that needs to be done at startup.
--- This could probably be broken into multiple functions because it's a bit of a monstrosity at this point.
function Inventory:InitUi()

	-- Instance of the `InventoryUi` class specific to this Inventory class instance.
	-- `InventoryUi` is built up in the Inventory.Ui.*.lua files.
	self.ui = Bagshui.prototypes.InventoryUi:New(self)
	local ui = self.ui

	-- Fill `self.toolbarAndMainMenuItems` so it can be iterated to build the toolbar and menus.
	self:PopulateToolbarAndMainMenuItems()

	-- Tables to store UI object references.
	for _, name in ipairs({"buttons", "frames", "tooltips", "text", "ordering"}) do
		ui[name] = {}
	end
	local buttons = ui.buttons
	buttons.bagSlots = {}
	buttons.itemSlots = {}
	buttons.toolbar = {}
	local frames = ui.frames
	frames.groups = {}
	frames.groupMoveTargets = {}
	local tooltips = ui.tooltips



	-- Prepare the window.

	self.uiFrame = ui:CreateWindowFrame("Frame")
	local uiFrame = self.uiFrame

	-- Start with the window in the correct position and hidden.
	self:FixWindowPosition()
	uiFrame:Hide()

	-- Add scripts.

	uiFrame.bagshuiData.lastDirtyCheck = _G.GetTime()
	uiFrame:SetScript("OnUpdate", function()
		-- Mark this window as dirty if any "child" windows are open.
		if _G.GetTime() - _G.this.bagshuiData.lastDirtyCheck > 0.075 then
			_G.this.bagshuiData.dirty = Bagshui:ChildWindowsVisible()
			_G.this.bagshuiData.lastDirtyCheck = _G.GetTime()
		end
	end)

	local oldOnShow = uiFrame:GetScript("OnShow")
	uiFrame:SetScript("OnShow", function()
		self:UiFrame_OnShow()
		if oldOnShow then
			oldOnShow()
		end
	end)
	local oldOnHide = uiFrame:GetScript("OnHide")
	uiFrame:SetScript("OnHide", function()
		self:UiFrame_OnHide()
		if oldOnHide then
			oldOnHide()
		end
	end)

	local function resetClick()
		self.clickedOnce = nil
	end

	uiFrame:SetScript("OnMouseDown", function()
		-- Clear a pending item sale.
		if self.itemPendingSale then
			self:ClearItemPendingSale()
		end

		if _G.arg1 == "LeftButton" then
			-- Close non-Settings menus on left mouse down (Settings is closed OnMouseUp).
			if not self.menus:IsMenuOpen("Settings") then
				Bagshui:CloseMenus()
			end

			-- When the Hearthstone was picked up by dragging it from the
			-- Hearthstone button, take it off the cursor.
			if self.pickedUpHearthstoneFromButton and Bagshui:GetCursorItem() == self.hearthstoneItemRef then
				_G.ClearCursor()
			end
			self.pickedUpHearthstoneFromButton = nil

			-- Double-click actions.
			if
				self.settings.windowDoubleClickActions
				and self.lastMouseDown
				and _G.GetTime() - self.lastMouseDown < 0.5
				and self.clickedOnce
			then
				if _G.IsAltKeyDown() then
					-- Toggle window position lock.
					self.settings.windowLocked = not self.settings.windowLocked
				else
					-- Toggle toolbars.
					self.ignoreNextSettingChange = true
					if
						self.settings.showHeader == self.settings.showFooter
						and self.headerWasHiddenOnDoubleClick == self.footerWasHiddenOnDoubleClick
					then
						self.headerWasHiddenOnDoubleClick = false
						self.footerWasHiddenOnDoubleClick = false
						self.settings.showHeader = not self.settings.showHeader
						self.settings.showFooter = not self.settings.showFooter
					else
						if self.settings.showHeader == false then
							self.headerWasHiddenOnDoubleClick = true
							self.settings.showHeader = true

						elseif self.headerWasHiddenOnDoubleClick then
							self.headerWasHiddenOnDoubleClick = false
							self.settings.showHeader = false

						elseif self.settings.showFooter == false then
							self.footerWasHiddenOnDoubleClick = true
							self.settings.showFooter = true

						elseif self.footerWasHiddenOnDoubleClick then
							self.footerWasHiddenOnDoubleClick = false
							self.settings.showFooter = false

						end
					end
					self.ignoreNextSettingChange = true
					-- self.settings.showHeader = not self.settings.showHeader
					-- self.settings.showFooter = self.settings.showHeader
					self:Update()
				end
			end
			self.lastMouseDown = _G.GetTime()
			self.clickedOnce = true
			Bagshui:QueueEvent(resetClick, 0.25)

		elseif _G.arg1 == "RightButton" then
			-- Show right-click menu.
			Bagshui:HideTooltips()
			self.ui.tooltips.mini:Hide()
			self.menus:OpenMenu("Main", nil, nil, "cursor")
		end
	end)

	uiFrame:SetScript("OnMouseUp", function()
		-- Only close Settings menu on mouse up so window can be dragged without closing it.
		-- (All other menus are closed OnMouseDown).
		if self.menus:IsMenuOpen("Settings") then
			Bagshui:CloseMenus()
		end
		ui.frames.searchBox:ClearFocus()
		self:ClearEditModeCursor()
		self:EditModeWindowUpdate()
	end)

	-- Util.CreateWindowFrame() sets default handlers for these to make window dragging
	-- worked, but Inventory windows need their own handlers due to docking.
    uiFrame:SetScript("OnDragStart", function()
		self:UiFrame_OnDragStart()
	end)
	uiFrame:SetScript("OnDragStop", function()
		self:UiFrame_OnDragStop()
	end)


	uiFrame:SetScript("OnEnter", function()
		-- If the cursor was holding an item in Edit Mode and left the window,
		-- OnLeave would have hidden it, so bring it back.
		self:ShowEditModeCursor()
		-- Ensure the Bag Bar state is correct.
		self:UpdateBagBar()
		-- Prevent menus from closing.
		_G.UIDropDownMenu_StopCounting(_G.DropDownList1)
	end)

	uiFrame:SetScript("OnLeave", function()
		-- Edit Mode actions are Inventory class instance-specific, so it makes sense to
		-- turn the cursor back to normal when it leaves the window.
		if not _G.MouseIsOver(_G.this) then
			self:HideEditModeCursor()
		end
	end)



	-- Header and footer frames.

	ui.frames.header = ui:CreateHeaderFooter(
		"FrameHeader",
		uiFrame,
		"TOP",
		BsSkin.inventoryHeaderFooterHeight,
		BsSkin.inventoryWindowPadding,
		-BsSkin.inventoryWindowPadding - BsSkin.inventoryHeaderFooterYAdjustment
	)
	local header = ui.frames.header

	ui.frames.footer = ui:CreateHeaderFooter(
		"FrameFooter",
		uiFrame,
		"BOTTOM",
		BsSkin.inventoryHeaderFooterHeight,
		BsSkin.inventoryWindowPadding,
		BsSkin.inventoryWindowPadding + BsSkin.inventoryHeaderFooterYAdjustment
	)
	local footer = ui.frames.footer

	footer:SetScript("OnLeave", function()
		self:PrintDebug("footer OnLeave")
	end)


	-- Main content frame for groups and items.
	ui.frames.main = _G.CreateFrame("Frame", ui:CreateElementName("FrameMain"), uiFrame)
	local mainFrame = ui.frames.main
	mainFrame:SetPoint("TOP", header, "BOTTOM", 0, 0)
	mainFrame:SetPoint("BOTTOM", footer, "TOP", 0, 0)
	mainFrame:SetPoint("LEFT", uiFrame, BsSkin.inventoryWindowPadding, 0)
	mainFrame:SetPoint("RIGHT", uiFrame, -BsSkin.inventoryWindowPadding, 0)
	mainFrame:EnableMouse()
	mainFrame:RegisterForDrag("LeftButton")
	-- Need to hack up the mouse methods so they're passed to the parent frame.
	ui:PassMouseEventsThrough(mainFrame, uiFrame)

	-- "No inventory data" message for when the cache has never been populated
	-- (like when we haven't yet gotten Bank data).
	ui.text.noData = mainFrame:CreateFontString(nil, nil, "GameFontHighlightSmall")
	ui.text.noData:SetText(L.Inventory_NoData)
	ui.text.noData:SetAllPoints(mainFrame)
	ui.text.noData:SetAlpha(0.4)
	ui.text.noData:Hide()


	-- Toolbar.

	-- Shared functions for spell cast buttons.

	--- Return `true` if the current button does *not* have an associated spell
	--- in its `bagshuiData.spellName` property.
	---@return boolean
	local function inventory_SpellButton_NoSpell()
		return (
			not _G.this.bagshuiData
			or not _G.this.bagshuiData.spellName
			or not BsCharacter.spellNamesToIds[_G.this.bagshuiData.spellName]
		)
	end

	--- Cast the configured spell on a button.
	local function inventory_SpellButton_OnClick()
		if inventory_SpellButton_NoSpell() then
			return
		end
		_G.CastSpell(BsCharacter.spellNamesToIds[_G.this.bagshuiData.spellName], _G.BOOKTYPE_SPELL)
	end

	--- Show the spell tooltip associated with a button.
	local function inventory_SpellButton_OnEnter()
		if inventory_SpellButton_NoSpell() then
			return
		end
		_G.GameTooltip:SetOwner(_G.this, "ANCHOR_" .. BsUtil.FlipAnchorPoint(self.settings.windowAnchorXPoint))
		_G.GameTooltip:SetSpell(BsCharacter.spellNamesToIds[_G.this.bagshuiData.spellName], _G.BOOKTYPE_SPELL)
		_G.GameTooltip:Show()
		return false
	end

	--- Hide the tooltip.
	local function inventory_SpellButton_OnLeave()
		if _G.GameTooltip:IsOwned(_G.this) then
			_G.GameTooltip:Hide()
		end
		return false
	end

	-- Permanent variables for OnUpdate to keep the garbage collector happy.
	local spellButton_OnUpdate_cooldownStart, spellButton_OnUpdate_cooldownDuration, spellButton_OnUpdate_cooldownEnable

	--- Manage the spell cooldown.
	local function inventory_SpellButton_OnUpdate()
		if inventory_SpellButton_NoSpell() then
			return
		end
		spellButton_OnUpdate_cooldownStart,
			spellButton_OnUpdate_cooldownDuration,
			spellButton_OnUpdate_cooldownEnable
			= _G.GetSpellCooldown(BsCharacter.spellNamesToIds[_G.this.bagshuiData.spellName], _G.BOOKTYPE_SPELL)
		if spellButton_OnUpdate_cooldownEnable and (spellButton_OnUpdate_cooldownDuration or 0) > 0 then
			self.ui:SetIconButtonCooldown(
				_G.this,
				spellButton_OnUpdate_cooldownStart,
				spellButton_OnUpdate_cooldownDuration,
				spellButton_OnUpdate_cooldownEnable
			)
		end
	end


	-- Top left icon.
	buttons.toolbar.menu = ui:CreateIconButton({
		name = "Menu",
		parentFrame = header,
		anchorPoint = "LEFT",
		anchorToFrame = header,
		anchorToPoint = "LEFT",
		width = 16,
		height = 16,
		xOffset = 5,
		onClick = function()
			Bagshui:HideTooltips()
			self.ui.tooltips.mini:Hide()
			self.menus:OpenMenu("Main", nil, nil, _G.this, -5, -5)
		end,
		onEnter = function()
			_G.this.bagshuiData.overrideTooltip = (
				(
					not self.settings.showFooter
					and not self.alwaysShowUsageSummary
				) or (
					self.settings.bagUsageDisplay ~= BS_INVENTORY_BAG_USAGE_DISPLAY.ALWAYS
					and not self.settings.showBagBar
				)
			)

			if _G.this.bagshuiData.overrideTooltip then
				self:ShowUsageSummary(_G.this, false)
				return false
			end
		end,
		onLeave = function()
			if _G.this.bagshuiData.overrideTooltip then
				self:HideUsageSummary(_G.this, false)
				return false
			end
		end,
		texture = self.inventoryType,
		tooltipTitle = L.Toolbar_Menu_TooltipTitle,
		tooltipAnchorPoint = "",
	})

	-- Offline indicator.
	buttons.toolbar.offline = ui:CreateIconButton({
		name = "State",
		parentFrame = header,
		anchorPoint = "LEFT",
		anchorToFrame = buttons.toolbar.menu,
		anchorToPoint = "RIGHT",
		xOffset = BsSkin.toolbarSpacing,
		onClick = function()
			-- Return to current character if viewing an alt.
			if self.activeCharacterId ~= Bagshui.currentCharacterId then
				self:SetCharacter(Bagshui.currentCharacterId)
				return
			end
		end,
		texture = "Offline",
		tooltipTitle = string.format(_G.FRIENDS_LIST_OFFLINE_TEMPLATE, self.inventoryTypeLocalized),
		noTooltipDelay = true,
		noTooltipTextDelay = true,
		vertexColor = BS_COLOR.RED,
	})
	buttons.toolbar.offline.bagshuiData.noRecolor = true
	buttons.toolbar.offline:Hide()

	-- Error indicator.
	buttons.toolbar.error = ui:CreateIconButton({
		name = "Error",
		parentFrame = header,
		anchorPoint = "LEFT",
		anchorToFrame = buttons.toolbar.menu,  -- Will be updated by UpdateToolbar().
		anchorToPoint = "RIGHT",
		xOffset = BsSkin.toolbarSpacing,
		onClick = function()
			BsLogWindow:Open()
		end,
		texture = "Exclamation",
		tooltipTitle = L.Error,
		tooltipDelay = 0,
		vertexColor = BS_COLOR.UI_ORANGE,
	})
	buttons.toolbar.error.bagshuiData.noRecolor = true
	buttons.toolbar.error:Hide()

	-- Edit Mode indicator.
	buttons.toolbar.editMode = ui:CreateIconButton({
		name = "EditMode",
		parentFrame = header,
		anchorPoint = "LEFT",
		anchorToFrame = buttons.toolbar.menu,  -- Will be updated by UpdateToolbar().
		anchorToPoint = "RIGHT",
		xOffset = BsSkin.toolbarSpacing,
		onClick = function()
			-- Exit Edit Mode.
			if self.editMode then
				_G.PlaySound("igMainMenuOptionCheckBoxOff")
				self:ToggleEditMode()
				return
			end
		end,
		texture = "Edit",
		tooltipTitle = L.Toolbar_ExitEditMode,
	})
	buttons.toolbar.editMode:Hide()


	-- Close button.
	buttons.toolbar.close = ui:CreateCloseButton(
		"ButtonClose",
		header,
		"RIGHT",
		-6 + (BsSkin.closeButtonInventoryWindowXOffsetAdjustment or 0),
		0 + (BsSkin.closeButtonInventoryWindowYOffsetAdjustment or 0),
		function()
			self:Close()
		end
	)
	buttons.toolbar.close.bagshuiData.noRecolor = true

	local nextAnchor = buttons.toolbar.close
	local nextOffset = -BsSkin.toolbarCloseButtonOffset

	-- Catalog is a special case.
	buttons.toolbar.catalog = ui:CreateIconButton({
		name = "Catalog",
		parentFrame = header,
		anchorToFrame = nextAnchor,
		onClick = function()
			BsCatalog:Toggle()
		end,
		texture = "Catalog",
		tooltipTitle = L.Toolbar_Catalog_TooltipTitle,
		tooltipText = L.Toolbar_Catalog_TooltipText
	})
	nextAnchor = buttons.toolbar.catalog
	nextOffset = -BsSkin.toolbarSpacing


	-- Right toolbar order, consumed by `Inventory:UpdateToolbarAnchoring()`
	-- to manage anchoring based on what is visible.
	self.ui.ordering.topRightToolbar = {
		buttons.toolbar.close,
		-BsSkin.toolbarCloseButtonOffset,
		buttons.toolbar.catalog,
	}

	-- Inventory type buttons -- iterating backwards (true parameter) because buttons are added right to left.
	for inventoryType, inventoryTypeLocalized in self:OtherInventoryTypesInToolbarIconOrder(true) do
		local inventoryClass = Bagshui.components[inventoryType]
		buttons.toolbar[inventoryType] = ui:CreateIconButton({
			name = inventoryType,
			parentFrame = header,
			anchorToFrame = nextAnchor,
			onClick = function()
				inventoryClass:Toggle()
			end,
			texture = inventoryType,
			tooltipTitle = inventoryTypeLocalized,
		})
		nextAnchor = buttons.toolbar[inventoryType]
		nextOffset = -BsSkin.toolbarSpacing

		table.insert(self.ui.ordering.topRightToolbar, buttons.toolbar[inventoryType])
	end
	table.insert(self.ui.ordering.topRightToolbar, -BsSkin.toolbarGroupSpacing)

	-- Add remainder of toolbar buttons right to left.
	nextOffset = -BsSkin.toolbarGroupSpacing
	for i = table.getn(self.toolbarAndMainMenuItems), 1, -1 do
		local item = self.toolbarAndMainMenuItems[i]
		item.parentFrame = header
		item.anchorToFrame = nextAnchor
		item.tooltipSecondDelay = BS_TOOLTIP_DELAY_SECONDS.TOOLBAR_DEFAULT
		item.xOffset = item.xOffset or nextOffset

		local button = ui:CreateIconButton(item)

		-- The toolbar button is stored in buttons.toolbar with the first letter
		-- of its name lowercased (button.toolbar.showHide instead of buttons.toolbar.ShowHide).
		-- (item.id is set in InventoryUi:PopulateToolbarAndMainMenuItems()).
		buttons.toolbar[item.id] = button

		nextAnchor = button

		-- Store special spacing directives so they can be read by Inventory:UpdateToolbarAnchoring().
		if item.xOffset and item.xOffset ~= nextOffset then
			table.insert(self.ui.ordering.topRightToolbar, item.xOffset)
		end
		table.insert(self.ui.ordering.topRightToolbar, button)
	end


	-- Search box (hidden until Search button is clicked).
	frames.searchBox = ui:CreateSearchBox(
		"SearchBox",
		header,
		85, -- Width
		18, -- Height

		-- OnTextChanged - trigger search.
		function()
			self.searchText = _G.this.bagshuiData.searchText  -- Set by autogenerated function in CreateSearchBox().
			self:UpdateItemSlotColors()
			if self.dockedInventory then
				self.dockedInventory:UpdateItemSlotColors()
			end
			if not self.searchTextSetFromEvent then
				Bagshui:RaiseEvent("BAGSHUI_INVENTORY_SEARCH", nil, self.inventoryType, self.searchText)
			end
			self.searchTextSetFromEvent = false
		end,

		-- OnEnterPressed -- open Catalog if a modifier is down.
		function()
			if self.searchText and (_G.IsAltKeyDown() or _G.IsShiftKeyDown() or _G.IsControlKeyDown()) then
				self:SearchCatalog()
			end
		end,

		-- OnIconClick -- open Catalog on right-click.
		function()
			if
				self.searchText
				and (
					_G.arg1 == "RightButton"
					or (_G.arg1 == "LeftButton" and _G.IsAltKeyDown())
				)
			then
				self:SearchCatalog()
			end
		end
	)
	frames.searchBox:SetPoint("TOPRIGHT", buttons.toolbar.resort, -BsSkin.toolbarGroupSpacing - 12, 2)
	frames.searchBox:Hide()

	table.insert(self.ui.ordering.topRightToolbar, frames.searchBox)

	-- Hide search box when empty.
	local oldOnEditFocusLost = frames.searchBox:GetScript("OnEditFocusLost")
	frames.searchBox:SetScript("OnEditFocusLost", function()
		oldOnEditFocusLost()
		if not self.searchText then
			_G.PlaySound("igMainMenuOptionCheckBoxOff")
			frames.searchBox:Hide()
			buttons.toolbar.search:Show()
			if self.temporarilyShowWindowHeader then
				self.temporarilyShowWindowHeader = false
				self:ForceUpdateWindow()
			else
				self:UpdateToolbar()
				self:SetWindowSize()
			end
		end
	end)

	-- Add tooltip text for search icon inside search box.
	frames.searchBox.bagshuiData.searchIcon.bagshuiData.tooltipText = string.format(L.Toolbar_Search_TooltipText, self.inventoryTypeLocalized)


	-- Status text (can't be done sooner because it anchors to the search button).

	ui.frames.status, ui.text.status = self.ui:CreateLabel(header)
	ui.text.status:SetText(" ")
	ui.frames.status:SetHeight(ui.text.status:GetHeight() + 2)
	ui.frames.status:SetPoint("LEFT", buttons.toolbar.main, "RIGHT", BsSkin.toolbarSpacing, 0)
	ui.frames.status:SetPoint("RIGHT", buttons.toolbar.search, "LEFT", -BsSkin.toolbarSpacing, 0)
	ui.frames.status:Show()

	-- The last thing anchored to the leftmost right toolbar icon is the status text. 
	table.insert(self.ui.ordering.topRightToolbar, ui.frames.status)


	-- Left toolbar order, consumed by `Inventory:UpdateToolbarAnchoring()`
	-- to manage anchoring based on what is visible.
	self.ui.ordering.topLeftToolbar = {
		buttons.toolbar.menu,
		buttons.toolbar.offline,
		buttons.toolbar.error,
		buttons.toolbar.editMode,
		ui.frames.status,
	}




	-- Pre-create item slot buttons. More will be created on the fly as needed.
	-- This needs to happen before bag slot buttons because the size of item slot buttons dictates things about bag slot buttons
	for buttonNum = 1, self.initialItemSlotButtons do
		ui:CreateInventoryItemSlotButton(buttonNum)
	end


	-- Create groups we know need to exist. Like tem slot buttons, more will be created if required.
	for _, row in pairs(self.layout) do
		for _, group in pairs(row) do
			ui:CreateGroup()
		end
	end

	-- Ensure at least one group exists so its label text can be measured for sizing the mini
	-- tooltip and for use during UpdateWindow().
	if table.getn(frames.groups) == 0 then
		ui:CreateGroup()
	end



	-- Bag bar.

	frames.bagBar = _G.CreateFrame(
		"Frame",
		ui:CreateElementName("BagBar"),
		footer
	)
	frames.bagBar:SetPoint("LEFT", footer)
	frames.bagBar:SetPoint("TOP", footer)
	frames.bagBar:SetPoint("BOTTOM", footer)
	frames.bagBar.bagshuiData = {
		baseWidth = (buttons.itemSlots[1].bagshuiData.originalSizeAdjusted + BsSkin.bagBarSpacing) * table.getn(self.containerIds)
	}
	frames.bagBar:SetWidth(frames.bagBar.bagshuiData.baseWidth)
	frames.bagBar:EnableMouse(true)
	frames.bagBar:RegisterForDrag("LeftButton")
	ui:PassMouseEventsThrough(frames.bagBar, uiFrame)

	-- Toggle available space display on mouseover.
	frames.bagBar:SetScript("OnEnter", function()
		frames.bagBar.bagshuiData.mouseIsOver = true
		self:UpdateBagBar()
	end)
	frames.bagBar:SetScript("OnLeave", function()
		frames.bagBar.bagshuiData.mouseIsOver = false
		self:UpdateBagBar()
	end)

	-- Actual bag slot setup.
	ui:CreateBagSlotButtons()


	-- Shared functions for utilization displays.

	local function usageSummary_OnEnter()
		self:ShowUsageSummary(_G.this, true)
	end
	local function usageSummary_OnLeave()
		self:HideUsageSummary(_G.this, true)
	end


	--- Create a space utilization display.
	--- Frame and FontStrings will *not* have positions set.
	---@param parent table? Parent frame.
	---@param justifyH string? FontString justification.
	---@return table spaceSummary
	local function CreateSpaceSummary(parent, justifyH)
		local spaceSummary = _G.CreateFrame("Frame", ui:CreateElementName("SpaceSummary"), parent)
		spaceSummary:SetHitRectInsets(-(BsSkin.bagBarSpacing / 2), -(BsSkin.bagBarSpacing / 2), -(BsSkin.bagBarSpacing / 2), -(BsSkin.bagBarSpacing / 2))
		spaceSummary.bagshuiData = {
			text = spaceSummary:CreateFontString(nil, nil, "NumberFontNormalSmall"),
			subtext = spaceSummary:CreateFontString(nil, nil, "NumberFontNormalSmall"),
		}
		spaceSummary.bagshuiData.text:SetTextColor(1, 1, 1, 0.75)
		spaceSummary.bagshuiData.text:SetShadowColor(0, 0, 0, 0.75)
		spaceSummary.bagshuiData.text:SetShadowOffset(1, -1)
		spaceSummary.bagshuiData.text:SetJustifyH(justifyH or "CENTER")
		spaceSummary.bagshuiData.text:SetJustifyV("MIDDLE")
		spaceSummary.bagshuiData.subtext:SetTextColor(1, 1, 1, 0.65)
		spaceSummary.bagshuiData.subtext:SetShadowColor(0, 0, 0, 0.75)
		spaceSummary.bagshuiData.subtext:SetShadowOffset(1, -1)
		spaceSummary.bagshuiData.subtext:SetJustifyH(justifyH or "CENTER")
		spaceSummary.bagshuiData.subtext:SetJustifyV("MIDDLE")
		spaceSummary.bagshuiData.subtext:SetFont(spaceSummary.bagshuiData.subtext:GetFont(), 9)

		-- Show individual bag type information on mouseover.
		spaceSummary:EnableMouse(true)
		spaceSummary:RegisterForDrag("LeftButton")
		ui:PassMouseEventsThrough(spaceSummary, uiFrame, true)
		spaceSummary:SetScript("OnEnter", usageSummary_OnEnter)
		spaceSummary:SetScript("OnLeave", usageSummary_OnLeave)

		return spaceSummary
	end

	-- This is the main utilization display that goes to the right of the bag bar.
	frames.spaceSummary = CreateSpaceSummary(frames.bagBar, "CENTER")
	frames.spaceSummary:SetPoint("LEFT", buttons.bagSlots[table.getn(buttons.bagSlots)], "RIGHT", BsSkin.bagBarSpacing - 2, 0)
	frames.spaceSummary:SetPoint("TOP", frames.bagBar)
	frames.spaceSummary:SetPoint("BOTTOM", frames.bagBar)
	frames.spaceSummary:SetWidth(50)
	frames.spaceSummary.bagshuiData.text:SetPoint("BOTTOM", frames.spaceSummary, "CENTER", 0, -2)
	frames.spaceSummary.bagshuiData.subtext:SetPoint("TOP", frames.spaceSummary, "CENTER", 0, -3)

	-- Create two "mini" utilization displays to use when the bag bar is hidden.
	-- One is for the bottom left and the other for the top left when the bottom toolbar is hidden.
	-- Reusing just one would be nice but this is more expedient.
	for _, position in ipairs({"Bottom", "Top"}) do
		local name = "miniSpaceSummary" .. position
		frames[name] = CreateSpaceSummary(footer, "LEFT")
		frames[name]:SetPoint("LEFT", footer, "LEFT", BsSkin.toolbarSpacing, 0)
		frames[name]:SetWidth(100)
		frames[name]:SetHeight(18)
		frames[name].bagshuiData.text:SetPoint("LEFT", frames[name], "LEFT", 0, 0)
		frames[name].bagshuiData.subtext:SetPoint("LEFT", frames[name].bagshuiData.text, "RIGHT", 1, 0.5)
	end
	-- Make the top one conditionally part of the top left toolbar.
	frames.miniSpaceSummaryTop:SetParent(header)
	frames.miniSpaceSummaryTop:ClearAllPoints()
	frames.miniSpaceSummaryTop.bagshuiData.text:SetPoint("LEFT", frames.miniSpaceSummaryTop, "LEFT", 0, -1)
	table.insert(self.ui.ordering.topLeftToolbar, 2, frames.miniSpaceSummaryTop)


	-- Bottom right toolbar anchor.
	frames.bottomRightToolbarAnchor = _G.CreateFrame("Frame", ui:CreateElementName("BottomRightToolbarAnchor"), footer)
	frames.bottomRightToolbarAnchor:SetHeight(25)
	frames.bottomRightToolbarAnchor:SetWidth(1)
	frames.bottomRightToolbarAnchor:SetPoint("RIGHT", footer, "RIGHT", 5, 0)

	-- Money frame.

	local moneyFrameName = ui:CreateElementName("Money")
	frames.money = _G.CreateFrame(
		"Frame",
		ui:CreateElementName("Money"),
		footer,
		"SmallMoneyFrameTemplate"
	)
	frames.money.bagshuiData = {
		name = moneyFrameName,
		texts = {
			gold = _G[moneyFrameName .. "GoldButtonText"],
			silver = _G[moneyFrameName .. "SilverButtonText"],
			copper = _G[moneyFrameName .. "CopperButtonText"],
		},
		autoLayoutXOffset = 12
	}
	frames.money:SetWidth(22)
	frames.money:SetHeight(25)
	frames.money:SetPoint("RIGHT", 8, 0)

	-- Need custom OnEnter/OnLeave to show tooltip with all characters' money.

	frames.money:EnableMouse(true)

	frames.money:SetScript("OnEnter", function()
		if self.editMode then
			return
		end
		_G.GameTooltip:SetOwner(frames.money, "ANCHOR_TOPRIGHT", -8, 0)
		BsCatalog:AddTooltipInfo(BS_CATALOG_LOCATIONS.MONEY, _G.GameTooltip)
		_G.GameTooltip:Show()
	end)

	frames.money:SetScript("OnLeave", function()
		if _G.GameTooltip:IsOwned(frames.money) then
			_G.GameTooltip:Hide()
		end
	end)

	local function moneyFrameOnEnter()
		frames.money:GetScript("OnEnter")()
	end
	local function moneyFrameOnLeave()
		frames.money:GetScript("OnLeave")()
	end

	for _, child in ipairs({frames.money:GetChildren()}) do
		if child.HasScript and child:HasScript("OnEnter") then
			child:SetScript("OnEnter", moneyFrameOnEnter)
			child:SetScript("OnLeave", moneyFrameOnLeave)
		end
	end



	-- Hearthstone button.

	buttons.toolbar.hearthstone = ui:CreateIconButton({
		name = "Hearthstone",
		parentFrame = footer,
		anchorPoint = "RIGHT",
		anchorToFrame = frames.money,
		anchorToPoint = "LEFT",
		disable = false,
		onClick = function()
			if Bagshui:GetCursorItem() == self.hearthstoneItemRef then
				_G.ClearCursor()
				return
			end
			if self.hearthstoneItemRef then
				_G.UseContainerItem(self.hearthstoneItemRef.bagNum, self.hearthstoneItemRef.slotNum, true)
			else
				Bagshui:ShowAndLogErrorMessage(L.Error_HearthstoneNotFound)
			end
		end,
		texture = "Hearthstone",
		onEnter = function()
			if self.hearthstoneItemRef then
				_G.this.bagshuiData.bagNum = self.hearthstoneItemRef.bagNum
				_G.this.bagshuiData.slotNum = self.hearthstoneItemRef.slotNum
				self:ItemButton_OnEnter()
			end
		end,
		onLeave = function()
			self:ItemButton_OnLeave()
		end,
		onUpdate = function()
			self:ItemButton_OnUpdate(_G.arg1)
		end,
	})
	-- Make the Hearthstone toolbar button compatible with our `ContainerFrameItemButton_` hackery.
	ui:AddItemSlotButtonGetIdProxy(buttons.toolbar.hearthstone)

	-- Allow picking up the Hearthstone from the button.
	buttons.toolbar.hearthstone:RegisterForDrag("LeftButton")
	buttons.toolbar.hearthstone:SetScript("OnDragStart", function()
		local hearthstone = self.hearthstoneItemRef
		if hearthstone then
			Bagshui:PickupItem(hearthstone, self, nil, true)
		end
		self.pickedUpHearthstoneFromButton = true
	end)

	-- Even though we always create the hearthstone button, it may not be enabled
	-- for this class instance.
	if not self.hearthButton then
		buttons.toolbar.hearthstone:Hide()
	end


	-- Clam (open container) button.
	buttons.toolbar.clam = ui:CreateIconButton({
		name = "Clam",
		parentFrame = footer,
		anchorPoint = "RIGHT",
		anchorToFrame = buttons.toolbar.hearthstone,
		anchorToPoint = "LEFT",
		disable = false,
		texture = "Clam",
		tooltipTitle = L.OpenContainer,
		onClick = function()
			if
				self.nextOpenableItemBagNum
				and self.nextOpenableItemSlotNum
			then
				_G.UseContainerItem(self.nextOpenableItemBagNum, self.nextOpenableItemSlotNum)
			end
		end,
		onEnter = function()
			-- Actual work will be handled in OnUpdate.
			_G.this.bagshuiData.mouseIsOver = true
		end,
		onLeave = function()
			_G.this.bagshuiData.mouseIsOver = false
			self.highlightItemsInContainerId = nil
			self.highlightItemsContainerSlot = nil
			self:UpdateItemSlotColors()
			if self.nextOpenableItemSlotButton then
				self:ItemButton_OnLeave(self.nextOpenableItemSlotButton)
			elseif self.lastHighlightedOpenableButton then
				self:ItemButton_OnLeave(self.lastHighlightedOpenableButton)
			end
			self.lastHighlightedOpenableButton = nil
		end,
		onUpdate = function()
			if not _G.this.bagshuiData.mouseIsOver then
				-- We need to essentially fake an OnLeave event when the
				-- last container is opened because the normal OnLeave
				-- won't fire, which leads to the light highlighted item
				-- slot button thinking it's still moused over.
				if _G.this.bagshuiData.wasUpdated then
					_G.this.bagshuiData.wasUpdated = false
				end
				return
			end
			self:HighlightNextOpenable()
			_G.this.bagshuiData.wasUpdated = true
		end,
	})


	-- Disenchant button.
	buttons.toolbar.disenchant = ui:CreateIconButton({
		name = "Disenchant",
		parentFrame = footer,
		anchorPoint = "RIGHT",
		anchorToFrame = buttons.toolbar.clam,
		anchorToPoint = "LEFT",
		disable = false,
		texture = "Disenchant",
		onClick = inventory_SpellButton_OnClick,
		onEnter = inventory_SpellButton_OnEnter,
		onLeave = inventory_SpellButton_OnLeave,
		onUpdate = inventory_SpellButton_OnUpdate,
	})
	buttons.toolbar.disenchant.bagshuiData.spellName = L.Spell_Disenchant


	-- Pick Lock button.
	buttons.toolbar.pickLock = ui:CreateIconButton({
		name = "PickLock",
		parentFrame = footer,
		anchorPoint = "RIGHT",
		anchorToFrame = buttons.toolbar.disenchant,
		anchorToPoint = "LEFT",
		disable = false,
		texture = "PickLock",
		onClick = inventory_SpellButton_OnClick,
		onEnter = inventory_SpellButton_OnEnter,
		onLeave = inventory_SpellButton_OnLeave,
		onUpdate = inventory_SpellButton_OnUpdate,
	})
	buttons.toolbar.pickLock.bagshuiData.spellName = L.Spell_PickLock



	-- Bottom right toolbar order, consumed by `Inventory:UpdateToolbarAnchoring()`
	-- to manage anchoring based on what is visible.
	self.ui.ordering.bottomRightToolbar = {
		frames.bottomRightToolbarAnchor,
		frames.money,
		-BsSkin.toolbarGroupSpacing,
		buttons.toolbar.hearthstone,
		-BsSkin.toolbarGroupSpacing,
		buttons.toolbar.clam,
		buttons.toolbar.pickLock,
		buttons.toolbar.disenchant,
	}


	-- Tooltips.

	-- Mini is used to display full group label names on mouseover and for toolbar tooltips.
	-- It's scaled based on the first group's label text, so that needs to be created first.
	-- There is a mini tooltip per Inventory class instance because it is sized based on the
	-- group label text.
	tooltips.mini = Bagshui:CreateTooltip("MiniTooltip")
	local miniTooltipName = tooltips.mini.bagshuiData.name  -- We'll need to know the name in a bit to grab the TextLeft1 font string.

	-- Scale the Mini tooltip down to match the size of the group label text (as close as possible).
	-- This is being done in a loop because it's the only way I could figure to get an accurate result.
	local miniTooltipTargetFontSize = ui.frames.groups[1].bagshuiData.text:GetHeight()
	local miniTooltipScaleStep = 0.03
	local miniTooltipScale = 1 + miniTooltipScaleStep -- Start higher than 1 because the next step is to subtract
	local miniTooltipActualFontSize
	-- Tooltip needs to have and owner and content to measure.
	tooltips.mini:SetOwner(uiFrame, "ANCHOR_PRESERVE")
	tooltips.mini:SetText(" ")
	repeat
		-- Set the scale, measure the result, see if it's small enough yet.
		miniTooltipScale = miniTooltipScale - miniTooltipScaleStep
		tooltips.mini:SetScale(miniTooltipScale)
		tooltips.mini:Show()
		miniTooltipActualFontSize = _G[miniTooltipName .. "TextLeft1"]:GetHeight() * miniTooltipScale
	until miniTooltipActualFontSize <= miniTooltipTargetFontSize or miniTooltipScale <= 0.5
	tooltips.mini:SetScale(miniTooltipScale - miniTooltipScaleStep)
	-- Prepare for later use.
	tooltips.mini:Hide()

end



--- Creates the list of items stored in `self.toolbarAndMainMenuItems`, which is
--- used to build both the main window toolbar and the main menu Actions list.
function Inventory:PopulateToolbarAndMainMenuItems()

	-- Notes:
	-- - Textures are assumed to be in the Icons folder.
	-- - Items are in top-to-bottom menu order and left-to-right toolbar order.
	-- - onClick is the toolbar button click function.
	-- - Unless func is specified, the menu item will click the toolbar button.

	self.toolbarAndMainMenuItems = {

		{
			-- Changing this name property will break several things, including
			-- the `onClick` function below and `Inventory:Search()`.
			name = "Search",
			texture = "Search",
			tooltipTitle = L.Toolbar_Search_TooltipTitle,
			tooltipText = string.format(L.Toolbar_Search_TooltipText, self.inventoryTypeLocalized),
			xOffset = -BsSkin.toolbarGroupSpacing,
			onClick = function()
				_G.PlaySound("igMainMenuOptionCheckBoxOn")
				self.ui.buttons.toolbar.search:Hide()  -- This relies on the `name` property of this button being "Search".
				if not self.settings.showHeader then
					self.temporarilyShowWindowHeader = true
					self:ForceUpdateWindow()
				end
				self.ui.frames.searchBox:Show()
				self:UpdateToolbar()
				self:SetWindowSize()
				self.ui.frames.searchBox:SetFocus()
			end,
		},

		{
			name = "Resort",
			texture = "Resort",
			tooltipTitle = L.Toolbar_Resort_TooltipTitle,
			tooltipText = L.Toolbar_Resort_TooltipText,
			disable = true,
			onClick = function()
				_G.PlaySound("igQuestLogOpen")
				self:Resort()
			end,
		},

		{
			name = "Restack",
			texture = "Restack",
			tooltipTitle = L.Toolbar_Restack_TooltipTitle,
			tooltipText = L.Toolbar_Restack_TooltipText,
			xOffset = -BsSkin.toolbarGroupSpacing,
			disable = true,
			onClick = function()
				_G.PlaySound("UChatScrollButton")
				self:Restack()
			end,
		},

		{
			name = "ShowHide",
			texture = "Show",
			tooltipTitle = L.Toolbar_Show_TooltipTitle,
			tooltipText = L.Toolbar_Show_TooltipText,
			onClick = function()
				self:ToggleProperty("showHidden")
			end,
			_bagshuiCheckedFunc = function()
				return self.showHidden
			end,
		},

		{
			name = "HighlightChanges",
			texture = "HighlightChanges",
			tooltipTitle = L.Toolbar_HighlightChanges_TooltipTitle,
			tooltipText = L.Toolbar_HighlightChanges_TooltipText,
			xOffset = -BsSkin.toolbarGroupSpacing,
			onClick = function()
				if _G.IsAltKeyDown() then
					self:ResetStockState()
				else
					self:ToggleProperty("highlightChanges")
				end
			end,
			_bagshuiCheckedFunc = function()
				return self.highlightChanges
			end,
		},

		{
			name = "Character",
			texture = "CharacterRobed",
			tooltipTitle = L.Toolbar_Character_TooltipTitle,
			tooltipText = string.format(L.Toolbar_Character_TooltipText, self.inventoryTypeLocalized),
			xOffset = -BsSkin.toolbarGroupSpacing,
			menuHasArrow = true,
			menuHideArrow = true,
			menuIgnoreOnClick = true,
			-- There's a chicken-and-egg issue between building the toolbar item
			-- list and constructing the menus because the menu won't exist yet.
			-- when this code is executed. Placing the property retrieval
			-- in a function is the workaround.
			getMenuValueProp = function()
				return self.menus.menuList.Character.levels[1]
			end,
			onClickBeforeCloseMenusAndClearFocuses = function()
				-- Whether the character menu was open before the default button OnClick closed it.
				_G.this.bagshuiData.characterMenuWasOpen = self.menus:IsMenuOpen("Character")
			end,
			onClick = function()
				if _G.this.bagshuiData.characterMenuWasOpen then
					Bagshui:CloseMenus()
				else
					-- Open the menu with a sensible alignment based on window anchoring.
					self.menus:OpenMenu(
						"Character",  -- menuType
						_G.this,  -- arg1
						nil,  -- arg2
						_G.this,  -- anchorFrame
						(5 * (self.settings.windowAnchorXPoint == "LEFT" and -1 or 1)),  -- xOffset
						-5,  -- yOffset
						"TOP" .. self.settings.windowAnchorXPoint,  -- anchorPoint
						"BOTTOM" .. self.settings.windowAnchorXPoint  -- anchorToPoint
					)
				end
			end,
		},
	}


	-- Pre-set full texture paths and firstLetterLowercased name.
	for _, item in ipairs(self.toolbarAndMainMenuItems) do
		item.id = BsUtil.LowercaseFirstLetter(item.name)
		if item.texture then
			item.texture = BsUtil.GetFullTexturePath("Icons\\" .. item.texture)
		end
	end

end



--- Iterator function to provide the list of inventory types that AREN'T the current class, in the 
--- order defined by INVENTORY_TYPE_UI_ORDER (reversed if requested).
---@param reverse boolean?
---@param includeSelf boolean? The current instance's inventory type will be omitted unless this is true.
---@return function # Iterator function that returns the inventory type along with the localized value.
function Inventory:OtherInventoryTypesInToolbarIconOrder(reverse, includeSelf)
	local inventoryTypes = BS_INVENTORY_TYPE_UI_ORDER
	local startIndex = reverse and table.getn(inventoryTypes) + 1 or 0
	local endIndex = reverse and 0 or table.getn(inventoryTypes) + 1
	local step = reverse and -1 or 1
	local i = startIndex
	---@return string inventoryType
	---@return string inventoryTypeLocalized
	return function()
		repeat
			i = i + step
		until inventoryTypes[i] ~= self.inventoryType or includeSelf or i == endIndex
		-- Need to use L_nil here so that nil is returned at the end of the loop
		return inventoryTypes[i], L_nil[inventoryTypes[i]]
	end
end





--- Reset everything in preparation for displaying the window, including the items below,
--- then trigger categorization and sorting.
--- - Edit Mode off.
--- - Empty slot stacks collapsed.
--- - Top toolbar hidden if it was temporarily visible.
--- - Pending trade-with-another player item cleared.
function Inventory:UiFrame_OnShow()
	-- Make sure everything is up to date.
	Bagshui:ProcessCombatDeferredEvents()

	if self.dockTo then
		-- Used by SetDockedToFrameVisibility() to decide whether the  frame to which this
		-- one is docked should also be closed when this frame is closed.
		self.dockingFrameVisibleOnLastOpen = Bagshui.components[self.dockTo]:Visible()
	end

	_G.PlaySound(self.openSound)

	self.online = true
	self.editMode = false
	self.expandEmptySlotStacks = false
	self.temporarilyShowWindowHeader = false
	self.highlightChanges = false
	self.queuedTradeItem = nil  -- Used by Inventory:TradeFrame_OnShow().
	self.itemPendingSale = nil  -- Used by Inventory:ItemButton_OnClick() to confirm sale of protected items.

	-- Reset any item highlighting.
	self.highlightItemsInContainerId = nil
	self.highlightItemsContainerSlot = nil

	-- Because Update() is called from the UI frame's OnShow function, self:Visible() becomes true
	-- before CategorizeAndSort() executes. Normally, CategorizeAndSort() bails if self:Visible() is true,
	-- so forceResort is set to true to ensure inventory is properly sorted whenever the window is opened.
	-- Of course, we don't want this to happen when automatic resorting is off.
	if not self.settings.disableAutomaticResort then
		self.forceResort = true
	end
	self.resortNeeded = true
	self.inventoryUpdateAllowed = true
	self.cacheUpdateNeeded = true
	self:NotifySkinOfPositionChange()
	-- Do NOT use QueueUpdate() here.
	self:Update()
end



--- Perform tasks that need to occur when the window is closed, including:
--- - Take the frame out of move mode.
--- - Close all menus.
--- - Reset the search box.
--- - Clear the Edit Mode cursor.
--- - Reset the 
--- - If there's a frame docked to this one, close it.
function Inventory:UiFrame_OnHide()
	self.uiFrame:StopMovingOrSizing()
	self:ClearSearch()
	self:CloseMenusAndClearFocuses()
	self:ClearEditModeCursor()
	self:SetCharacter(Bagshui.currentCharacterId)

	_G.PlaySound(self.closeSound)

	-- If there's a frame docked to this frame, close it too.
	if self.dockedInventory then
		self.dockedInventory:Close()
	end

end



--- Handle dragging (start).
function Inventory:UiFrame_OnDragStart()
	if self.dockTo then
		Bagshui.components[self.dockTo]:UiFrame_OnDragStart()
	elseif not self.settings.windowLocked then
		-- Has to be self instead of "this" because it can be called from docked windows.
		self.dragInProgress = true
		self.uiFrame:StartMoving()
	end
end



--- Handle dragging (stop).
function Inventory:UiFrame_OnDragStop()
	if self.dockTo then
		Bagshui.components[self.dockTo]:UiFrame_OnDragStop()
	elseif not self.settings.windowLocked then
		-- Has to be self instead of "this" because it can be called from docked windows.
		self.dragInProgress = false
		self.uiFrame:StopMovingOrSizing()
		self:FixSettingsMenuPosition()
		self:SaveWindowPosition()
		self:NotifySkinOfPositionChange()
	end
end



--- Display the inventory utilization summary tooltip.
---@param owner table Frame to which the tooltip should bet attached.
---@param attachedToBagBar boolean? When `true`, call the bag bar's OnEnter.
---@param extraText string? Text to append to the tooltip.
---@param delay boolean|number? Time to wait before showing the tooltip.
---@param tooltip table? Tooltip to use instead of GameTooltip.
function Inventory:ShowUsageSummary(owner, attachedToBagBar, tooltip, extraText, delay)
	if self.editMode then
		return
	end

	owner = owner or _G.this
	tooltip = tooltip or _G.GameTooltip

	_G.this.bagshuiData.mouseIsOver = true

	-- Trigger bag bar OnEnter to avoid flickering.
	if attachedToBagBar then
		if self.ui.frames.bagBar:IsVisible() then
			self.ui.frames.bagBar:GetScript("OnEnter")()
		end
	end

	-- Add overall info.
	tooltip:SetOwner(
		owner,
		"ANCHOR_" .. BsUtil.FlipAnchorPoint(self.settings.windowAnchorXPoint),
		-BsSkin.tooltipExtraOffset,
		BsSkin.tooltipExtraOffset
	)
	tooltip:AddDoubleLine(
		-- Available: 10     Used: 8/18
		string.format(L.Symbol_Colon, L.Available) .. " " .. tostring(self.availableSlots),
		string.format(L.Symbol_Colon, L.Used) .. " " .. string.format("%s/%s", tostring(self.usedSlots), tostring(self.totalSlots))
	)

	-- Only show per-bag-type info if there are profession bags.
	local hasProfessionBags = false
	for containerType, spaceInfo in pairs(self.containerSpace) do
		if (spaceInfo.total or 0) > 0 and containerType ~= L.Bag then
			hasProfessionBags = true
		end
	end

	-- Add per-bag-type info, excluding any bag types where total is 0 (necessary
	-- because we don't bother cleaning up the containerSpace table when all bags
	-- of a given type are unequipped).
	if hasProfessionBags then
		for _, containerType in ipairs(BS_INVENTORY_CONTAINER_TYPE_ORDER) do
			local spaceInfo = self.containerSpace[containerType]
			if spaceInfo and (spaceInfo.total or 0) > 0 then
				-- Bag: 2             6/8
				tooltip:AddDoubleLine(
					string.format(L.Symbol_Colon, containerType) .. " " .. tostring(spaceInfo.available),
					string.format("%s/%s", tostring(spaceInfo.used), tostring(spaceInfo.total)),
					HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b,
					HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b
				)
			end
		end
	end


	if delay then
		Bagshui:ShowTooltipAfterDelay(
			tooltip,
			owner,
			nil,
			type(delay) == "number" and delay or BS_TOOLTIP_DELAY_SECONDS.DEFAULT,
			nil,
			function()
				if extraText then
					Bagshui:QueueEvent(function()
						if tooltip:IsOwned(owner) and tooltip:IsVisible() then
							tooltip:AddLine(extraText)
							tooltip:Show()
						end
					end, BS_TOOLTIP_DELAY_SECONDS.TOOLBAR_DEFAULT)
				end
			end
		)
	else
		if extraText then
			tooltip:AddLine(extraText)
			tooltip:Show()
		end
		tooltip:Show()
	end
end



--- Companion to `ShowUsageSummary()`.
---@param owner table Tooltip will only be hidden if still owned by this frame.
---@param attachedToBagBar boolean? When `true`, call the bag bar's OnLeave.
---@param tooltip table? Tooltip to use instead of GameTooltip.
function Inventory:HideUsageSummary(owner, attachedToBagBar, tooltip)
	owner = owner or _G.this
	tooltip = tooltip or _G.GameTooltip

	owner.bagshuiData.mouseIsOver = false

	-- Hide tooltip.
	if tooltip:IsOwned(owner) then
		tooltip:Hide()
	end

	-- Decide whether to keep displaying slot available/used counts.
	if attachedToBagBar and self.ui.frames.bagBar:IsVisible() then
		self.ui.frames.bagBar:GetScript("OnLeave")()
	end
end



--- Spotlights the item that will be targeted by clicking the Open Container button.
function Inventory:HighlightNextOpenable()
	-- Avoid firing OnEnter constantly.
	if self.lastHighlightedOpenableButton ~= self.nextOpenableItemSlotButton then
		self.highlightItemsInContainerId = self.nextOpenableItemBagNum
		self.highlightItemsContainerSlot = self.nextOpenableItemSlotNum
		if self.nextOpenableItemSlotButton then
			self:ItemButton_OnEnter(self.nextOpenableItemSlotButton)
		end
		self:UpdateItemSlotColors()
		self.lastHighlightedOpenableButton = self.nextOpenableItemSlotButton
	end
end



--- Visible serves two functions:
--- 1. Get the current visibility of `self.uiFrame`.
--- 2. Optionally perform a UI visibility action prior to checking visibility.
---@param visibilityAction BS_INVENTORY_UI_VISIBILITY_ACTION? Action to perform, if any.
---@return number|boolean|nil isVisible Result of `self.uiFrame:IsVisible()`.
function Inventory:Visible(visibilityAction)
	if not self.uiFrame then
		return false
	end
	if visibilityAction and type(self[visibilityAction]) == "function" then
		self[visibilityAction](self)
	end
	return self.uiFrame:IsVisible()
end



--- Display the window.
function Inventory:Open()
	if not self.uiFrame:IsVisible() then
		-- Set to `EVENT_PREFIX_` when the event ends in `_OPENED`.
		-- This will allow for matching against the corresponding
		-- `EVENT_PREFIX_CLOSED`.
		self.lastOpenEventTrigger =
			_G.event
			and (
				(string.find(_G.event, "_OPENED$")) and (string.gsub(_G.event, "OPENED$", ""))
				or (string.find(_G.event, "_SHOW$")) and (string.gsub(_G.event, "SHOW$", ""))
			)
			or nil
	end
	self.uiFrame:Show()
	self.uiFrame:Raise()
	self:SetDockedToFrameVisibility(BS_INVENTORY_UI_VISIBILITY_ACTION.OPEN)
end



--- Hide the window.
function Inventory:Close()
	if self.uiFrame:IsVisible() then
		-- Don't close if the close request came from an event trigger but
		-- the window not opened by the corresponding event.
		if
			type(_G.event) == "string"
			and (string.find(_G.event, "_CLOSED$"))
			and (
				self.lastOpenEventTrigger == nil
				or (not string.find(_G.event, "^" .. self.lastOpenEventTrigger))
			)
		then
			return
		end
		self.uiFrame:Hide()
	end
end



--- Open if closed, close if opened.
function Inventory:Toggle(keepDockedToFrameOpen)
	if self.uiFrame:IsVisible() then
		self:Close()
		if not keepDockedToFrameOpen then
			self:SetDockedToFrameVisibility(BS_INVENTORY_UI_VISIBILITY_ACTION.CLOSE)
		end
	else
		self:Open()
	end
end



--- OpenCloseToggle is called from hooked functions and checks whether the hook is
--- enabled before performing the action. It calls `self:Visible()` when the hook
--- is enabled and the original hooked function when the hook is disabled.
---@param uiVisibilityAction BS_INVENTORY_UI_VISIBILITY_ACTION
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
---@param bagNumParam number? `arg1` from the hooked API function, if applicable.
---@param forceCallOriginalHook boolean? When true, always call the hooked API function.
function Inventory:OpenCloseToggle(uiVisibilityAction, wowApiFunctionName, bagNumParam, forceCallOriginalHook)

	local callOriginalHook = true
	if self:GetHookEnabled(wowApiFunctionName, bagNumParam) then
		callOriginalHook = false
		-- Only perform the action if it's unconditional or if it's for a container belonging to this instance.
		if not bagNumParam or self.myContainerIds[bagNumParam] then
			self:Visible(uiVisibilityAction)
		end
	end

	if callOriginalHook or forceCallOriginalHook then
		self.hooks:OriginalHook(wowApiFunctionName, bagNumParam)
	end
end



--- Make sure the visibility state of the frame this one is docked to doesn't get out of sync.
---@param visibilityAction BS_INVENTORY_UI_VISIBILITY_ACTION
function Inventory:SetDockedToFrameVisibility(visibilityAction)
	if not self.dockTo then
		return
	end
	-- Only close the docking frame if it wasn't visible when this frame was opened.
	if
		visibilityAction ~= BS_INVENTORY_UI_VISIBILITY_ACTION.CLOSE
		or (
			visibilityAction == BS_INVENTORY_UI_VISIBILITY_ACTION.CLOSE
			and not self.dockingFrameVisibleOnLastOpen
		)
	then
		Bagshui.components[self.dockTo]:Visible(visibilityAction)
	end
end



--- Keep the window in the right place.
---@param noRescueAttempts boolean? Don't call `Inventory:RescueWindow()`.
function Inventory:FixWindowPosition(noRescueAttempts)
	if self.dragInProgress then
		return
	end

	-- As soon as a frame is dragged, its anchor changes to TOPLEFT, which leads to undesirable behavior
	-- when the frame is resized. We have to reset the anchor and position to keep things happy.
	self.uiFrame:ClearAllPoints()
	self.uiFrame:SetPoint(
		self.settings.windowAnchorYPoint .. self.settings.windowAnchorXPoint,
		_G.UIParent,
		self.settings.windowAnchorYPoint .. self.settings.windowAnchorXPoint,
		self.settings.windowAnchorXOffset / self.uiFrame:GetScale(),
		self.settings.windowAnchorYOffset / self.uiFrame:GetScale()
	)

	-- Ensure the Settings menu is in the right spot.
	self:FixSettingsMenuPosition()

	-- Make sure the window is onscreen.
	if not noRescueAttempts then
		self:RescueWindow()
	end
end



--- Get the window back on the screen if it goes wandering.
---@param requested boolean? User-requested reset. Don't check, just do it.
function Inventory:RescueWindow(requested)
	-- Can't check if the frame isn't positioned.
	if not self.uiFrame:GetTop() then
		return
	end

	local rescued = false

	-- Make sure boundary frames are scaled correctly.
	Bagshui:ManageBoundaryFrames()

	-- These two could be collapsed to one shared function but it doesn't seem worth it.
	-- Originally this was implemented with checks against UIParent but that seemed to
	-- fall apart at really large resolutions. So instead we're using four invisible
	-- boundary frames that share the same scale as the Bagshui inventory windows.
	-- HOPEFULLY this will be accurate. (There's probably a better way to do this?)

	if
		requested
		or self.uiFrame:GetTop() <= Bagshui.boundaryFrames.BOTTOM:GetBottom() + BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD
		or self.uiFrame:GetBottom() >= Bagshui.boundaryFrames.TOP:GetTop() - BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD
	then
		self.settings:SetDefaults(true, nil, nil, "windowAnchorYOffset", true)
		if
			(self.settings.windowAnchorYPoint == "TOP" and self.settings.windowAnchorYOffset > 0)
			or (self.settings.windowAnchorYPoint == "BOTTOM" and self.settings.windowAnchorYOffset < 0)
		then
			self.settings.windowAnchorYOffset = -self.settings.windowAnchorYOffset
		end
		rescued = true
	end

	if
		requested
		or self.uiFrame:GetRight() <= Bagshui.boundaryFrames.LEFT:GetLeft() + BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD
		or self.uiFrame:GetLeft() >= Bagshui.boundaryFrames.RIGHT:GetRight() - BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD
	then
		self.settings:SetDefaults(true, nil, nil, "windowAnchorXOffset", true)
		if
			(self.settings.windowAnchorXPoint == "RIGHT" and self.settings.windowAnchorXOffset > 0)
			or (self.settings.windowAnchorXPoint == "LEFT" and self.settings.windowAnchorXOffset < 0)
		then
			self.settings.windowAnchorXOffset = -self.settings.windowAnchorXOffset
		end
		rescued = true
	end

	-- Apply the new position.
	if rescued then
		Bagshui:Print(requested and L.SettingReset_WindowPositionManual or L.SettingReset_WindowPositionAuto, self.inventoryTypeLocalized)
		self:FixWindowPosition(true)
	end
end



--- Record window offsets so they can be used by `Inventory:FixWindowPosition()`.
--- `GetLeft/Right/Top/Bottom()` always return values based on the bottom left of the screen,
--- so we need to do some work to figure out how these relate to the desired frame anchor.
--- Here's how it works, based on the frame's anchor:
--- - *Left/Bottom:* Easy - Use the returned value, adjusted by the frame scale
--- - *Right/Top:*
---   1. Save the returned value, adjusted by frame scale.
---   2. Get the appropriate UIParent dimension (Width/Height) and un-scale it.
---   3. Subtract #1 from #2, then turn it negative.
function Inventory:SaveWindowPosition()

	-- Prevent UpdateWindow() from being fired by settings changes so X and Y can both be saved
	-- Without this, X will be saved but Y will be overwritten because FixWindowPosition() will
	-- be called by UpdateWindow() before the Y setting is updated.
	self.windowUpdateBlocked = true

	-- Save new values.
	self.settings.windowAnchorXOffset = self:GetWindowOffset(self.settings.windowAnchorXPoint)
	self.settings.windowAnchorYOffset = self:GetWindowOffset(self.settings.windowAnchorYPoint)

	-- Allow window updates again.
	self.windowUpdateBlocked = false
end



--- Calculate the current window offset from the given point.
---@param point string LEFT/RIGHT/TOP/BOTTOM
---@return number
function Inventory:GetWindowOffset(point)
	-- Calling, for example, self.uiFrame:GetLeft()
	local offset =
		self.uiFrame["Get" .. BsUtil.Capitalize(point)](self.uiFrame)
		* self.uiFrame:GetScale()

	if string.upper(point) == "RIGHT" or string.upper(point) == "TOP" then
		local dimension = (string.upper(point) == "RIGHT") and "Width" or "Height"
		offset = -((_G.UIParent["Get" .. dimension](_G.UIParent) / _G.UIParent:GetScale()) - offset)
	end

	return offset
end



-- Let the skin know that the window position has changed.
function Inventory:NotifySkinOfPositionChange()
	if type(BsSkin.inventoryPositionFunc) == "function" then
		BsSkin.inventoryPositionFunc(self)
	end
end



--- Do "cleanup" activities when we need to get rid of menus, de-focus the search box, etc.
--- **DO NOT RENAME** without updating `Ui:CloseMenusAndClearFocuses()`.
function Inventory:CloseMenusAndClearFocuses()
	Bagshui:CloseMenus()
	self.ui.frames.searchBox:ClearFocus()
end





--- Wrapper for `Bagshui:AddTooltipLine()` that automatically adds to the Bagshui info tooltip.
---@param text string Primary text value.
---@param label string Labels to display in front of text, if any.
---@param title boolean Use highlight color instead of normal color for `text`.
---@param indent boolean Indent the entire line.
function Inventory:AddBagshuiInfoTooltipLine(text, label, title, indent)
	Bagshui:AddTooltipLine(BsInfoTooltip, text, label, title, indent)
end



--- Open the inventory window and set focus on the search box.
---@param searchString string? Search string to pre-populate.
function Inventory:Search(searchString)
	self:Open()
	self.ui.buttons.toolbar.search:Click()
	if type(searchString) == "string" then
		self.ui.frames.searchBox:SetText(searchString)
	end
end



--- Clear the current search text and store it in history.
function Inventory:ClearSearch()
	if self.searchText then
		self.ui.frames.searchBox:AddHistoryLine(self.searchText)
		self.ui.frames.searchBox:SetText("")
		self.ui.frames.searchBox:GetScript("OnTextChanged")(self.ui.frames.searchBox)
	end
end



--- Transfer the current search to the Catalog.
function Inventory:SearchCatalog()
	if self.searchText then
		local searchText = self.searchText
		self:ClearSearch()
		self:CloseMenusAndClearFocuses()
		BsCatalog:Search(searchText)
	end
end


--- Determine whether a given API function hook is enabled.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
---@param bagNumParam number|boolean? `arg1` from the hooked API function, if applicable.
---@return boolean hookEnabled
function Inventory:GetHookEnabled(wowApiFunctionName, bagNumParam)
	local hookPreference = self:GetHookSettingName(wowApiFunctionName, bagNumParam)
	local hookPreferenceValue = true
	if self.settings[hookPreference] ~= nil then
		hookPreferenceValue = self.settings[hookPreference]
	end
	return hookPreferenceValue
end



--- Some hooked functions can be enabled/disabled through settings, but the setting
--- name isn't always the API function name. For example, Bags stores the
--- OpenBackpack/CloseBackpack/ToggleBackpack preference in hookBag0,
--- to match the autogenerated hookBagX settings. By configuring the 
--- hookSettingTranslations class property, this substitution can be made.
---@param hookFunctionName string WoW API function being hooked.
---@param bagNumParam number|boolean? When given and there's no hookSettingTranslations match, return hookBagX, where X is bagNumParam.
---@return string settingName
function Inventory:GetHookSettingName(hookFunctionName, bagNumParam)
	local retVal = nil

	-- Find any special case matches
	for pattern, preferenceName in pairs(self.hookSettingTranslations) do
		if string.find(hookFunctionName, pattern) then
			retVal = preferenceName
		end
	end

	-- Make sure the bag number is within the declared range for this class.
	-- Checking to ensure it's a number because some hooked bag functions
	-- could be called with booleans (like OpenAllBags()).
	if retVal == nil and type(bagNumParam) == "number" and self.myContainerIds[bagNumParam] then
		retVal = "hookBag" .. bagNumParam
	end

	-- For anything else, the preference name is the hook function name.
	if retVal == nil and self.hooks[hookFunctionName] then
		retVal = hookFunctionName
	end

	---@diagnostic disable-next-line: return-type-mismatch
	return retVal
end


end)