-- Bagshui Inventory Prototype: Bag Slot Buttons

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory
local InventoryUi = Bagshui.prototypes.InventoryUi


--- Create one bag slot button per container ID in the class instance.
function InventoryUi:CreateBagSlotButtons()
	local ui = self
	local inventory = self.inventory

	local buttonParent = ui.frames.bagBar
	local buttonTemplate, primaryBag, buttonName, previousBagSlot
	-- Gets assigned to the bagshuiData.bagSlotNum property so that the Bank can
	-- determine whether the slot has been purchased.
	-- Needs to start at 1 for the first non-primary container, so it's initialized
	-- to 0 and incremented in the loop.
	local sequentialBagSlotNum = 0


	for index, containerId in ipairs(inventory.containerIds) do
		local bagSlotButton, inventoryId

		buttonTemplate = inventory.bagButtonTemplate
		primaryBag = false

		if index == 1 and containerId == inventory.primaryContainer.id then
			-- Special handling for the primary bag.
			primaryBag = true
			buttonName = ui:CreateElementName("PrimaryBag")
			-- We use a normal ItemButtonTemplate that gets faked into being a faux bag button.
			buttonTemplate = "ItemButtonTemplate"

		else
			-- All other bags.
			-- Name needs to be in a specific format because we're depending on Blizzard
			-- code for bag slots and there are several places where it parses the element
			-- name using `strsub(this:GetName(), 10)`. It also expects a certain string
			-- to be produced -- for PaperDollItemSlotButton, it's "Bag#Slot" but for
			-- Bank bag buttons it's just "Bag#". The correct name formatting strings
			-- need to be set in each Inventory class' configuration.
			buttonName = string.format(inventory.bagSlotNameFormat, containerId + inventory.bagSlotNameNumberOffset)

			sequentialBagSlotNum = sequentialBagSlotNum + 1

		end

		-- Create the button.
		bagSlotButton = _G.CreateFrame("Button", buttonName, buttonParent, buttonTemplate)

		-- Post-creation button changes.
		if primaryBag then
			-- Primary bag needs extra tweaks.
			-- Blizzard code sets the `hasItem` property to 1 when a slot is occupied, so we're doing the same.
			bagSlotButton.hasItem = 1
			-- Blizzard also uses `tooltipText` to provide bag slot information adn we're reusing that too. 
			bagSlotButton.tooltipText = inventory.primaryContainer.name

			-- Set the special texture for this faux bag button.
			_G.SetItemButtonTexture(bagSlotButton, inventory.primaryContainer.texture)

		else
			inventoryId = containerId + inventory.bagButtonIdOffset
			-- All other containers need this for compatibility with Blizzard code.
			-- Also used in Inventory:ShowBagSlotTooltip().
			bagSlotButton:SetID(inventoryId)

		end


		-- Add Bagshui properties.
		bagSlotButton.bagshuiData = {
			type = BS_UI_ITEM_BUTTON_TYPE.BAG,
			bagNum = containerId,
			containerId = containerId,
			bagSlotNum = sequentialBagSlotNum,
			inventoryId = inventoryId,
			inventorySlotId = inventoryId and (
				inventory.getInventorySlotFunction
				-- We absolutely have to use 1 instead of true here to get Blizzard's code to work.
				and inventory.getInventorySlotFunction(containerId, 1)
				or inventoryId
			),
			primary = primaryBag,
			highlightLocked = false,
		}


		-- Apply all our appearance adjustments.
		ui:SkinItemButton(bagSlotButton)

		-- Size should be the same as an item slot button.
		bagSlotButton:SetWidth(ui.buttons.itemSlots[1]:GetWidth())
		bagSlotButton:SetHeight(ui.buttons.itemSlots[1]:GetHeight())

		-- First button is anchored to bottom left, subsequent are anchored to the previous one.
		if table.getn(ui.buttons.bagSlots) == 0 then
			bagSlotButton:SetPoint(
				"BOTTOMLEFT",
				3, 0
			)
		else
			bagSlotButton:SetPoint(
				"TOPLEFT",
				previousBagSlot,
				"TOPRIGHT",
				BsSkin.bagBarSpacing, 0
			)
		end

		-- Expand HitRectInsets to avoid item highlight flickering when moving mouse between buttons.
		local hitRectInset = BsSkin.bagBarSpacing / 2
		bagSlotButton:SetHitRectInsets(-hitRectInset, -hitRectInset, -hitRectInset, -hitRectInset)

		-- Event handling.
		-- We're not reusing Blizzard code for OnEnter/OnLeave/OnUpdate because
		-- it gets really messy trying to add new lines to tooltips when they're
		-- being reset on every frame by the OnUpdate functions.
		-- A lot of this could probably be refactored and merged with ItemButton
		-- code, but that's not a priority.

		-- Note that Bagshui info tooltips are handled in Bagshui.Tooltips.lua, at least for now.
		bagSlotButton:SetScript("OnEnter", function(bagButton)
			if inventory.editMode then
				return
			end

			local this = bagButton or _G.this
			this.bagshuiData.mouseIsOver = true

			-- Display tooltip.
			inventory:ShowBagSlotTooltip(this)

			-- Highlight this bag's contents.
			if
				inventory:BagSlotButtonHasBag(this)
				and not inventory.highlightItemsInContainerLocked
			then
				inventory.highlightItemsInContainerId = this.bagshuiData.bagNum
				inventory:UpdateItemSlotColors()
			end

			-- Show slot available/used counts.
			inventory.ui.frames.bagBar:GetScript("OnEnter")()
		end)


		bagSlotButton:SetScript("OnLeave", function()
			_G.this.bagshuiData.mouseIsOver = false

			-- Hide tooltip.
			if _G.GameTooltip:IsOwned(_G.this) then
				_G.GameTooltip:Hide()
			end

			-- Get rid of any cursor changes.
			_G.ResetCursor()

			-- Stop any further tooltip refreshes.
			_G.this.bagshuiData.tooltipCooldownUpdate = nil

			-- Remove bag highlight unless it's locked on.
			if
				inventory.highlightItemsInContainerId == _G.this.bagshuiData.bagNum
				and not inventory.highlightItemsInContainerLocked
			then
				inventory.highlightItemsInContainerId = nil
				inventory:UpdateItemSlotColors()
			end

			-- Decide whether to keep displaying slot available/used counts.
			inventory.ui.frames.bagBar:GetScript("OnLeave")()
		end)


		local onUpdate_refreshTooltip -- Storing at a higher scope to reduce garbage collector load.
		bagSlotButton:SetScript("OnUpdate", function(elapsed)
			onUpdate_refreshTooltip = false

			-- Safeguard to prevent tooltips from popping up when the mouse has already left.
			if not _G.this.bagshuiData.mouseIsOver then
				_G.this.bagshuiData.tooltipCooldownUpdate = nil
				return
			end

			-- Honestly not even sure if bag cooldowns are something that need to be
			-- accounted for, but I guess we'll handle it just in case.
			if _G.this.bagshuiData.tooltipCooldownUpdate ~= nil then
				-- tooltipCooldownUpdate is initially set to 1 by OnEnter when there's a cooldown.
				-- Here we subtract the elapsed time in seconds, which will eventually go below 0
				-- so long as the property isn't wiped by moving the mouse off this item.
				_G.this.bagshuiData.tooltipCooldownUpdate = _G.this.bagshuiData.tooltipCooldownUpdate - elapsed

				-- Don't proceed until it's been more than 1 second.
				if _G.this.bagshuiData.tooltipCooldownUpdate < 0 then
					onUpdate_refreshTooltip = true
				end
			end

			if onUpdate_refreshTooltip then
				inventory:ShowBagSlotTooltip(_G.this)
			end
		end)


		-- Most of the default OnClick behaviors for bag buttons are fine, but we need to overlay a few things.
		-- - Alt-click highlight lock/unlock.
		-- - Block default functions if offline.
		-- - Handle placing items in primary containers.
		local oldOnClick = bagSlotButton:GetScript("OnClick")
		bagSlotButton:SetScript("OnClick", function()
			local this = _G.this
			local bagNum = this.bagshuiData.bagNum

			-- Alt-click highlight lock.
			if
				inventory:BagSlotButtonHasBag(this)
				and (
					_G.IsAltKeyDown()
					-- Normal clicking needs to remove the highlight lock since the bag might be getting picked up.
					or (
						inventory.highlightItemsInContainerLocked == bagNum
						and inventory.online
					)
				)
				and not inventory.editMode
			then

				-- Toggle highlight lock for this button
				-- this.bagshuiData.highlightLocked = not this.bagshuiData.highlightLocked
				inventory.highlightItemsInContainerLocked =
					inventory.highlightItemsInContainerLocked ~= bagNum
					and bagNum
					or nil

				inventory.highlightItemsInContainerId = bagNum
				inventory:UpdateBagBar()
				inventory:UpdateItemSlotColors()

				-- Don't pick up bag or do anything else if alt key was down.
				if _G.IsAltKeyDown() then
					return
				end
			end

			-- Can't do anything with bags other than highlight items if we're offline or in Edit Mode
			if not inventory.online or inventory.editMode then
				return
			end

			-- Putting items in the primary container needs special handling because there doesn't seem to be
			-- a bag ID that works with PutItemInBag for the primary Bank or Keyring containers. So instead
			-- we're iterating the container and looking for empty slots, then calling PickupContainerItem.
			-- This doesn't need to use Bagshui:PickupItem() since cursor tracking data gets cleared via the
			-- ClearCursor() hook and we don't need to call ContainerFrameItemButton_OnClick() either.
			if this.bagshuiData.primary and _G.CursorHasItem() then
				local noEmptySlots = true
				for slotNum, slotContents in ipairs(inventory.inventory[this.bagshuiData.bagNum]) do
					if slotContents.emptySlot == 1 then
						_G.PickupContainerItem(this.bagshuiData.bagNum, slotNum)
						noEmptySlots = false
					end
				end
				if noEmptySlots then
					Bagshui:ShowErrorMessage(_G.BAG_FULL, self.inventoryType)
				end
			end

			if oldOnClick then
				oldOnClick()
			end

		end)

		-- OnDragStart -- just use the original OnDragStart, but block it when offline or in Edit Mode.
		local oldOnDragStart = bagSlotButton:GetScript("OnDragStart")
		bagSlotButton:SetScript("OnDragStart", function()

			if not inventory.online or inventory.editMode then
				return
			end

			if oldOnDragStart then
				oldOnDragStart()
			end
		end)

		-- Perform final initialization.
		-- This is done in a separate function so subclasses can override it.
		if not primaryBag then
			inventory:BagSlotButton_Init(bagSlotButton)
		end

		-- Add to bagSlots table.
		table.insert(ui.buttons.bagSlots, bagSlotButton)

		-- Update previousBagSlot for button placement.
		previousBagSlot = bagSlotButton

	end
end



--- Further initialization of bag slot buttons, called midway through CreateBagSlotButtons().
--- Broken out as a separate function so subclasses can deal with nuances of different Blizzard
--- code in Bags and Bank. Just a placeholder for subclasses to override.
--- This feels like it could be refactored somehow to be cleaner, but it also doesn't feel worth it.
---@param bagSlotButton table Button widget.
function Inventory:BagSlotButton_Init(bagSlotButton)
end



-- For the WoW API functions BagSlotButton_OnClick() and BagSlotButton_OnDrag)(),
-- we need to first call the original function, then make sure our window is up to date.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call.
function Inventory:BagSlotButton_OnHook(wowApiFunctionName)
	-- Don't interfere if this isn't a Bagshui button
	if not string.find(_G.this:GetName(), self.bagSlotNameFormat) then
		self.hooks:OriginalHook(wowApiFunctionName)
		return
	end

	-- Can't do anything offline.
	if not self.online then
		return
	end
	self.hooks:OriginalHook(wowApiFunctionName)
	self:Update()
end



--- Does the given bagSlotButton contain a bag?
--- (We can't just use the button's `hasItem` property because it doesn't get
--- updated when viewing other characters.)
---@param bagSlotButton any
---@return boolean
function Inventory:BagSlotButtonHasBag(bagSlotButton)
	return (
		self.containers[bagSlotButton.bagshuiData.bagNum]
		and (self.containers[bagSlotButton.bagshuiData.bagNum].numSlots or 0) > 0
	)
end



--- Apply bag slot button tooltip modifications.
--- A lot of this could probably be refactored and merged with ItemButton
--- code, but that's not a priority.
---@param bagSlotButton table Button widget.
function Inventory:ShowBagSlotTooltip(bagSlotButton)
	local this = bagSlotButton or _G.this

	-- Cases when nothing should happen.
	if
		-- OnEnter still fires even if mouse events are disabled so we need to avoid doing anything when we're in that state.
		not this:IsMouseEnabled()
		-- Don't pop up tooltips or do anything else when a menu is open.
		or self.menus:IsMenuOpen()
	then
		return
	end

	-- Get the tooltip ready.
	_G.GameTooltip:SetOwner(
		this,
		"ANCHOR_" .. BsUtil.FlipAnchorPoint(self.settings.windowAnchorXPoint),
		-BsSkin.tooltipExtraOffset,
		BsSkin.tooltipExtraOffset
	)

	-- Is the bag currently on cooldown?
	local hasCooldown = false

	if
		not this.bagshuiData.primary
		and self.online
		and this.bagshuiData.inventorySlotId
	then
		-- Not using return value 1 (hasItem) because it's automatically captured into
		-- the button's hasItem property by Blizzard code when an event that changes
		-- bags fires.
		_, hasCooldown = _G.GameTooltip:SetInventoryItem("player", this.bagshuiData.inventorySlotId)
	end

	-- Trigger the OnUpdate function to reload the tooltip after 1 second if there's an active cooldown.
	-- (In other words, the 1 here represents number of seconds, NOT `true`).
	this.bagshuiData.tooltipCooldownUpdate = hasCooldown and 1 or nil

	-- Set bag name or slot status text in tooltip.
	if
		-- Primary bag always needs special handling.
		this.bagshuiData.primary
		-- Try to take care of other bags offline when the name is known.
		or (
			not self.online
			and (
				self.containers[this.bagshuiData.bagNum].name
				or this.tooltipText
				or (self.activeCharacterId ~= Bagshui.currentCharacterId)
			)
		)
		-- When there's no inventoryId we can't use the tooltip's SetInventoryItem(). 
		or not this.bagshuiData.inventorySlotId
		-- No bag in slot.
		or not this.hasItem
	then
		_G.GameTooltip:SetText(
			(
				self.containers[this.bagshuiData.bagNum].name
				or this.tooltipText
				or (self.activeCharacterId ~= Bagshui.currentCharacterId and L.EmptyBagSlot)
				or _G.EQUIP_CONTAINER
			),
			1.0, 1.0, 1.0
		)
	end

	-- Add key bindings to tooltip.
	if
		this.hasItem
		and self.opensViaHooks
		and self.activeCharacterId == Bagshui.currentCharacterId
	then
		local keyBinding = _G.GetBindingKey((
			this.bagshuiData.primary
			and self.primaryContainer.bindingKey
			or (
				self.keyBindingPrefix
				and table.getn(self.containerIdRange) > 0
				-- Refer to Blizzard's BagSlotButton_OnEnter.
				and self.keyBindingPrefix .. (self.containerIdRange[2] - (this.bagshuiData.containerId - self.containerIdRange[1]))
			)
		))
		if (keyBinding) then
			_G.GameTooltip:AppendText(" " .. NORMAL_FONT_COLOR_CODE .. "(".. keyBinding .. ")" .. FONT_COLOR_CODE_CLOSE)
		end
	end

	-- Figure out how many slots are available and add it to the tooltip.
	local totalSlots = self.containers[this.bagshuiData.bagNum].numSlots
	if totalSlots > 0 then
		local usedSlots = self.containers[this.bagshuiData.bagNum].slotsFilled
		local availableSlots = totalSlots - usedSlots
		local full = (availableSlots <= 0) and (" (" .. L.Full .. ")") or ""
		_G.GameTooltip:AddDoubleLine(
			string.format(L.Symbol_Colon, L.Available) .. " " .. tostring(availableSlots) .. full,
			string.format(L.Symbol_Colon, L.Used) .. " " .. tostring(usedSlots) .. "/" .. tostring(totalSlots),
			1, 1, 0.5,
			1, 1, 0.5
		)
	end

	-- Add hint about locking highlight if there's something in the slot and there are items in the inventory cache.
	if
		not self.editMode
		and (
			((self.activeCharacterId == Bagshui.currentCharacterId) and this.hasItem or false)
			or (self.containers[this.bagshuiData.bagNum].numSlots or 0) > 0
		)
		and self.inventory[this.bagshuiData.bagNum]
	then
		_G.GameTooltip:AddLine(
			string.format(
				L.Tooltip_Inventory_ToggleBagSlotHighlightLockHint,
				L.AltClick,
				string.lower((self.highlightItemsInContainerLocked and self.highlightItemsInContainerId == this.bagshuiData.bagNum) and L.Unlock or L.Lock)
			),
			GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b
		)
	end

	-- Use code in Bagshui.Tooltips.lua to show info tooltip.
	_G.GameTooltip.bagshuiData.infoTooltipAlwayShow = true
	_G.GameTooltip:Show()
end


end)