-- Bagshui UI Class: Item Slot Buttons

Bagshui:LoadComponent(function()

local Ui = Bagshui.prototypes.Ui


--- Default OnEnter event script for standalone item slot buttons.
---@param targetItemButton table? Alternate button to use instead of global `this`.
---@param fromEntryFrame boolean? This is being called as a result of the mouse entering the associated scrollable list entry frame (explained in the comment above `if this.bagshuiData.entryFrame then...`).
---@param refreshTooltipOnly boolean? Don't do anything other than reload the tooltip.
local function ItemButton_OnEnter(targetItemButton, fromEntryFrame, refreshTooltipOnly)
	local this = targetItemButton or _G.this
	this.bagshuiData.mouseIsOver = true

	-- The `itemString` or an `item` table populated by `ItemInfo:Get()` MUST be
	-- set on the `bagshuiData` table of the button for the tooltip to appear.
	local itemString = this.bagshuiData.itemString or this.bagshuiData.item and this.bagshuiData.item.itemString
	if type(itemString) == "string" and string.find(itemString, "^item:") then

		-- Tooltip location can be changed by altering the `tooltip*` properties referenced below.
		if this.bagshuiData.tooltipAnchorDefault then
			_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, this)
		else
			_G.GameTooltip:SetOwner(this, this.bagshuiData.tooltipAnchor or "ANCHOR_TOPLEFT")
		end
		-- Pass along to `Bagshui:HookTooltip()`.
		_G.GameTooltip.bagshuiData.showInfoTooltipWithoutAlt = this.bagshuiData and this.bagshuiData.showBagshuiInfoWithoutAlt

		-- There's a custom tooltip position.
		if
			not this.bagshuiData.tooltipAnchorDefault
			and (
				this.bagshuiData.tooltipAnchor == "ANCHOR_NONE"
				or this.bagshuiData.tooltipAnchor == "ANCHOR_PRESERVE"
			)
			and this.bagshuiData.tooltipAnchorPoint
			and this.bagshuiData.tooltipAnchorToPoint
		then
			_G.GameTooltip:ClearAllPoints()
			_G.GameTooltip:SetPoint(
				this.bagshuiData.tooltipAnchorPoint,
				this.bagshuiData.tooltipAnchorToFrame or this,
				this.bagshuiData.tooltipAnchorToPoint,
				this.bagshuiData.tooltipXOffset or 0,
				this.bagshuiData.tooltipYOffset or 0
			)
		end

		_G.GameTooltip:SetHyperlink(itemString)
		_G.GameTooltip:Show()
	end

	-- Coordinate OnEnter with the scrollable list entry frame when applicable so that
	-- mousing over the item slot button triggers the hover state for the list entry.
	-- See `ItemListEntryFrame_OnEnter()` for the other side.
	if this.bagshuiData.entryFrame and not refreshTooltipOnly then
		if fromEntryFrame then
			this:LockHighlight()
		else
			this.bagshuiData.entryFrame:GetScript("OnEnter")(this.bagshuiData.entryFrame, true)
		end
	end
end



--- When the Bagshui Info tooltip is anchored to the GameTooltip, it may end up
--- underneath it near the bottom of the screen. When that happens, reposition things.
---@param button table Item button.
---@param xAnchor string "LEFT" or "RIGHT".
function ItemButton_OnEnter_FixTooltipPosition(button, xAnchor)
	if (BsInfoTooltip:GetBottom() or 0) <= (_G.UIParent:GetBottom() or 0) then
		BsInfoTooltip:ClearAllPoints()
		BsInfoTooltip:SetPoint(
			button.bagshuiData.tooltipAnchorPoint,
			button.bagshuiData.tooltipAnchorToFrame or button,
			BsUtil.FlipAnchorPointComponent(button.bagshuiData.tooltipAnchorToPoint, 1),
			button.bagshuiData.tooltipXOffset or 0,
			(button.bagshuiData.tooltipYOffset or 0) - BsSkin.tooltipExtraOffset
		)
		_G.GameTooltip:ClearAllPoints()
		_G.GameTooltip:SetPoint(
			"BOTTOM" .. xAnchor,
			BsInfoTooltip,
			"TOP" .. xAnchor,
			0,
			-BsSkin.infoTooltipYOffset
		)
	end
end



--- Default OnLeave event script for standalone item slot buttons.
---@param targetItemButton table? Alternate button to use instead of global `this`.
---@param fromEntryFrame boolean? This is being called as a result of the mouse leaving the associated scrollable list entry frame (explained in the comment above `if this.bagshuiData.entryFrame then...`).
local function ItemButton_OnLeave(targetItemButton, fromEntryFrame)
	local this = targetItemButton or _G.this
	this.bagshuiData.mouseIsOver = false
	Bagshui:HideTooltips(this)

	-- Coordinate OnLeave with the scrollable list entry frame when applicable so that
	-- the mouse leaving the item slot button removes the hover state for the list entry.
	-- See `ItemListEntryFrame_OnLeave()` for the other side.
	if this.bagshuiData.entryFrame then
		if fromEntryFrame then
			this:UnlockHighlight()
		else
			this.bagshuiData.entryFrame:GetScript("OnLeave")(this.bagshuiData.entryFrame, true)
		end
	end
end


--- Default OnClick handler for standalone item buttons.
--- Since they're not tied to an actual bag slot, we can't leverage `ContainerFrameItemButton_OnClick()`.
---@param targetItemButton table? Alternate button to use instead of global `this`.
local function ItemButton_OnClick(targetItemButton)
	local this = targetItemButton or _G.this
	if _G.IsShiftKeyDown() and this.bagshuiData.item and this.bagshuiData.item.itemLink then
		-- I guess we'll be nice and provide WIM support here since it's pretty simple.
		if _G.IsAddOnLoaded("WIM") and _G.WIM_EditBoxInFocus then
			_G.WIM_EditBoxInFocus:Insert(this.bagshuiData.item.itemLink)

		elseif _G.ChatFrameEditBox:IsVisible() then
			_G.ChatFrameEditBox:Insert(this.bagshuiData.item.itemLink)
		end
	end
end


--- Default OnHide handler for standalone item buttons.
local function ItemButton_OnHide()
	Bagshui:HideTooltips()
end



-- Default OnUpdate for standalone item buttons to refresh tooltips when modifier keys are pressed/released.
local function ItemButton_OnUpdate()
	if not _G.this.bagshuiData.mouseIsOver then
		return
	end
	if
		_G.this.bagshuiData.altKeyState ~= _G.IsAltKeyDown()
		or _G.this.bagshuiData.controlKeyState ~= _G.IsControlKeyDown()
		or _G.this.bagshuiData.shiftKeyState ~= _G.IsShiftKeyDown()
	then
		ItemButton_OnEnter(_G.this, nil, true)
		_G.this.bagshuiData.altKeyState = _G.IsAltKeyDown()
		_G.this.bagshuiData.controlKeyState = _G.IsControlKeyDown()
		_G.this.bagshuiData.shiftKeyState = _G.IsShiftKeyDown()
	end
end



--- Create a new item slot button.
---@param name string Unique name for the button (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@return table itemSlotButton
function Ui:CreateItemSlotButton(name, parent)
	assert(name, "CreateItemSlotButton(): name is required")

	local button = _G.CreateFrame(
		"Button",
		self:CreateElementName(name),
		parent,
		"ItemButtonTemplate"
	)

	button.bagshuiData = {
		type = BS_UI_ITEM_BUTTON_TYPE.ITEM,
		ui = self,
		-- Store a reference to the assigned inventory class (if present) for later use.
		inventory = self.inventory,
	}

	-- Default script handlers.
	button:SetScript("OnEnter", ItemButton_OnEnter)
	button:SetScript("OnClick", ItemButton_OnClick)
	button:SetScript("OnLeave", ItemButton_OnLeave)
	button:SetScript("OnUpdate", ItemButton_OnUpdate)
	button:SetScript("OnHide", ItemButton_OnHide)

	-- Apply visual customizations.
	self:SkinItemButton(button)

	return button
end



--- Apply all our visual customizations to an item slot (or bag slot) button.
---@param button table Button to skin.
function Ui:SkinItemButton(button, buttonType)
	if not button.bagshuiData then
		button.bagshuiData = {}
	end
	local buttonInfo = button.bagshuiData

	-- Used by Ui:SetItemButtonSize() and Inventory:AssignItemsToSlots().
	buttonInfo.originalSize = math.floor(button:GetWidth() + 0.5)
	buttonInfo.originalSizeAdjusted = button.bagshuiData.originalSize + (BsSkin.itemSlotSizeFudge or 0)

	-- Treat as an item slot button unless the button has been configured as something else.
	buttonType = buttonInfo.type or BS_UI_ITEM_BUTTON_TYPE.ITEM

	local buttonName = button:GetName()

	-- Build a list of all the button parts so they're easily accessible in the future.
	buttonInfo.buttonComponents = {
		highlightTexture = button:GetHighlightTexture(),
		iconTexture = _G[buttonName .. "IconTexture"],
		normalTexture = button:GetNormalTexture(),
		pushedTexture = button:GetPushedTexture(),
		checkedTexture = _G[buttonName .. "HighlightFrameTexture"],
		count = _G[buttonName .. "Count"],
		stock = _G[buttonName .. "Stock"],
	}
	local buttonComponents = buttonInfo.buttonComponents

	-- Adjust texture coordinates.
	if BsSkin.itemSlotIconTexCoord then
		buttonComponents.iconTexture:SetTexCoord(BsSkin.itemSlotIconTexCoord[1], BsSkin.itemSlotIconTexCoord[2], BsSkin.itemSlotIconTexCoord[3], BsSkin.itemSlotIconTexCoord[4])
	end

	-- Adjust icon texture anchoring.
	if BsSkin.itemSlotIconAnchor then
		buttonComponents.iconTexture:ClearAllPoints()
		buttonComponents.iconTexture:SetPoint("TOPLEFT", BsSkin.itemSlotIconAnchor, -BsSkin.itemSlotIconAnchor)
		buttonComponents.iconTexture:SetPoint("BOTTOMRIGHT", -BsSkin.itemSlotIconAnchor, BsSkin.itemSlotIconAnchor)
	end


	-- Apply text improvements.

	-- The original alignments are weird.
	buttonComponents.count:SetPoint("BOTTOMRIGHT", button, -BsSkin.itemSlotDecorationAnchor, BsSkin.itemSlotDecorationAnchor)
	buttonComponents.stock:SetPoint("TOPLEFT", button, BsSkin.itemSlotDecorationAnchor, -BsSkin.itemSlotDecorationAnchor)

	-- Add outline and shadow to all text to improve readability.
	local font, fontSize = buttonComponents.count:GetFont()
	font = BsSkin.itemSlotFont or font
	fontSize = math.max(BsSkin.itemSlotFontSize or 0, fontSize)  -- Don't let the font go smaller than the default.
	local fontStyle = BsSkin.itemSlotFontStyle or "OUTLINE"
	buttonComponents.count:SetFont(font, fontSize, fontStyle)
	buttonComponents.stock:SetFont(font, fontSize, fontStyle)
	buttonComponents.count:SetShadowColor(0, 0, 0, 0.75)
	buttonComponents.count:SetShadowOffset(1, -1)
	buttonComponents.stock:SetShadowColor(0, 0, 0, 0.75)
	buttonComponents.stock:SetShadowOffset(1, -1)

	if buttonType == BS_UI_ITEM_BUTTON_TYPE.BAG then
		-- Change stock text to white.
		buttonComponents.stock:SetFontObject("NumberFontNormal")
	end


	-- Add Background.

	-- ItemButtonTemplate doesn't come with a built-in background, so let's make it look like a bag slot.
	-- The background will be updated to reflect bag type during window updates.
	buttonComponents.background = button:CreateTexture(nil, "BACKGROUND")
	buttonComponents.background:SetTexture(
		BS_UI_ITEM_BUTTON_TYPE.BAG and "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag"
		or BS_INVENTORY_EMPTY_SLOT_TEXTURE[L.Bag]
	)
	local backgroundOutset = -1
	buttonComponents.background:SetPoint("TOPLEFT", button, "TOPLEFT", backgroundOutset, -backgroundOutset)
	buttonComponents.background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -backgroundOutset, backgroundOutset)
	-- Skin-specific background texture coordinate adjustments.
	if BsSkin.itemSlotBackgroundTexCoord then
		buttonComponents.background:SetTexCoord(
			BsSkin.itemSlotBackgroundTexCoord[1],
			BsSkin.itemSlotBackgroundTexCoord[2],
			BsSkin.itemSlotBackgroundTexCoord[3],
			BsSkin.itemSlotBackgroundTexCoord[4]
		)
	end


	-- Add Border.
	-- Credit: [ShaguTweaks AddBorder()](https://github.com/shagu/ShaguTweaks/blob/master/helpers.lua).
	buttonComponents.border = _G.CreateFrame("Frame", nil, button)
	buttonComponents.border:SetFrameLevel(buttonComponents.border:GetFrameLevel() + 3) -- Borders will end up under normalTexture without this.
	buttonComponents.border:SetPoint("TOPLEFT", button, "TOPLEFT", -BsSkin.itemSlotBorderAnchor, BsSkin.itemSlotBorderAnchor)
	buttonComponents.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", BsSkin.itemSlotBorderAnchor, -BsSkin.itemSlotBorderAnchor)
	buttonInfo.borderBackdropTable = {
		tile = false, tileSize = 0,
		edgeFile = BsSkin.itemSlotBorderTexture,
		edgeSize = BsSkin.itemSlotEdgeSize,
		insets = { left = BsSkin.itemSlotInset, right = BsSkin.itemSlotInset, top = BsSkin.itemSlotInset, bottom = BsSkin.itemSlotInset }
	}
	buttonComponents.border:SetBackdrop(buttonInfo.borderBackdropTable)
	buttonInfo.forceBorderDisplay = BsSkin.itemSlotBorderAlwaysShow
	buttonInfo.qualityColor = BsSkin.itemSlotBorderDefaultColor


	-- More skin-specific adjustments.

	if BsSkin.itemSlotHighlightTexture then
		buttonComponents.highlightTexture:SetTexture(BsUtil.GetFullTexturePath(BsSkin.itemSlotHighlightTexture))
	end

	if BsSkin.itemSlotHighlightAnchor then
		buttonComponents.highlightTexture:ClearAllPoints()
		buttonComponents.highlightTexture:SetPoint("TOPLEFT", -BsSkin.itemSlotHighlightAnchor, BsSkin.itemSlotHighlightAnchor)
		buttonComponents.highlightTexture:SetPoint("BOTTOMRIGHT", BsSkin.itemSlotHighlightAnchor, -BsSkin.itemSlotHighlightAnchor)
	end

	if BsSkin.itemSlotPushedTexture then
		buttonComponents.pushedTexture:SetTexture(BsUtil.GetFullTexturePath(BsSkin.itemSlotPushedTexture))
	end

	if BsSkin.itemSlotPushedAnchor then
		buttonComponents.pushedTexture:ClearAllPoints()
		buttonComponents.pushedTexture:SetPoint("TOPLEFT", -BsSkin.itemSlotPushedAnchor, BsSkin.itemSlotPushedAnchor)
		buttonComponents.pushedTexture:SetPoint("BOTTOMRIGHT", BsSkin.itemSlotPushedAnchor, -BsSkin.itemSlotPushedAnchor)
	end

	if buttonComponents.checkedTexture and BsSkin.itemSlotCheckedTexture then
		buttonComponents.checkedTexture:SetTexture(BsUtil.GetFullTexturePath("ItemSlot\\Flat-Checked"))
	end

	-- Change NormalTexture if the skin wants it.
	if BsSkin.itemSlotNormalTexture then
		buttonComponents.normalTexture:SetTexture(BsSkin.itemSlotNormalTexture)
	end

	-- Inner glow (used for quality colors).
	-- Credit: [ShaguTweaks-mods AddTexture()](https://github.com/GryllsAddons/ShaguTweaks-mods/blob/main/mods/item-colors-glow.lua).
	buttonComponents.innerGlow = button:CreateTexture(nil, "OVERLAY")
	buttonComponents.innerGlow:SetTexture(BsUtil.GetFullTexturePath(BsSkin.itemSlotInnerGlowTexture))
	buttonComponents.innerGlow:SetBlendMode("ADD")
	buttonComponents.innerGlow:SetPoint("TOPLEFT", button, "TOPLEFT", -BsSkin.itemSlotInnerGlowAnchor, BsSkin.itemSlotInnerGlowAnchor)
	buttonComponents.innerGlow:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", BsSkin.itemSlotInnerGlowAnchor, -BsSkin.itemSlotInnerGlowAnchor)
	buttonComponents.innerGlow:SetVertexColor(1, 1, 1, 0)


	-- Item slot button needs a bunch of additional stuff.
	if buttonType == BS_UI_ITEM_BUTTON_TYPE.ITEM then

		-- Cooldown.
		buttonComponents.cooldown = _G.CreateFrame("Model", nil, button, "CooldownFrameTemplate")
		buttonComponents.cooldown:SetFrameLevel(buttonComponents.cooldown:GetFrameLevel() + 1)  -- Move above NormalTexture.
		-- Enable pfUI cooldown display. The pfUI check is needed because
		-- Turtle Dragonflight will double the text when pfCooldownType is present.
		-- (`pfUI` is added to the Bagshui environment in Bagshui.lua).
		if pfUI then
			buttonComponents.cooldown.pfCooldownType = "ALL"
		end

		-- All badges need to be 2 levels above the border so the cooldown can be below them.
		local badgeFrameLevel = buttonComponents.border:GetFrameLevel() + 2

		-- Quality badge.
		buttonComponents.qualityBadge = self:CreateShadowedTexture(button, "Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		buttonComponents.qualityBadge:SetFrameLevel(badgeFrameLevel)
		buttonComponents.qualityBadge:SetWidth(12)
		buttonComponents.qualityBadge:SetHeight(12)
		buttonComponents.qualityBadge:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", BsSkin.itemSlotDecorationAnchor, BsSkin.itemSlotDecorationAnchor)
		buttonComponents.qualityBadge:Hide()
		buttonInfo.qualityBadgeAlpha = 0

		-- Item usable badge.
		buttonComponents.topLeftBadge = self:CreateShadowedTexture(button, "Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		buttonComponents.topLeftBadge:SetFrameLevel(badgeFrameLevel)
		buttonComponents.topLeftBadge:SetWidth(12)
		buttonComponents.topLeftBadge:SetHeight(12)
		buttonComponents.topLeftBadge:SetPoint("TOPLEFT", button, "TOPLEFT", BsSkin.itemSlotDecorationAnchor, -BsSkin.itemSlotDecorationAnchor)
		buttonComponents.topLeftBadge:Hide()
		buttonInfo.topLeftBadgeAlpha = 0

		-- Stock change badge.
		buttonComponents.stockBadge = self:CreateShadowedTexture(button, nil)
		buttonComponents.stockBadge:SetFrameLevel(badgeFrameLevel)
		buttonComponents.stockBadge:SetWidth(12)
		buttonComponents.stockBadge:SetHeight(12)
		buttonComponents.stockBadge:SetPoint("TOPRIGHT", button, "TOPRIGHT", -BsSkin.itemSlotDecorationAnchor, -BsSkin.itemSlotDecorationAnchor)
		buttonComponents.stockBadge:Hide()
		buttonInfo.stockBadgeAlpha = 0

	end

	-- Set default colors.
	self:UpdateItemButtonColorsAndBadges(button, true)
end



--- Assign an item to an item slot button.
---@param button table Button to which the item should be assigned.
---@param item table Bagshui item table filled by `ItemInfo:Get()`.
---@param groupId string? Inventory layout group ID, if applicable. Used to obtain per-group settings that affect item slots.
function Ui:AssignItemToItemButton(button, item, groupId)
	local buttonInfo = button.bagshuiData
	local inventory = buttonInfo.inventory
	local buttonComponents = button.bagshuiData.buttonComponents
	local opacityOverride

	-- Use Bags settings as the settings fallback if the button doesn't have an Inventory class instance.
	local settings = inventory and inventory.settings or Bagshui.components.Bags.settings

	-- Store item reference so it's available for later use, primarily by `UpdateItemButtonColorsAndBadges()`.
	buttonInfo.item = item
	buttonInfo.itemId = item.id

	-- Store group ID so `UpdateItemButtonStockState()` can pull per-group settings.
	buttonInfo.groupId = groupId

	-- Set main item texture.
	_G.SetItemButtonTexture(button, item.texture)

	-- Start with full normal color and opacity.

	buttonInfo.iconTextureColorR = BS_COLOR.ITEM_SLOT_STATE_NORMAL[1]
	buttonInfo.iconTextureColorG = BS_COLOR.ITEM_SLOT_STATE_NORMAL[2]
	buttonInfo.iconTextureColorB = BS_COLOR.ITEM_SLOT_STATE_NORMAL[3]
	buttonInfo.iconTextureAlpha = BS_COLOR.ITEM_SLOT_STATE_NORMAL[4]

	-- Figure out border color.
	-- It's typically the quality color, but can be forced to something else.
	if inventory or buttonInfo.colorBorders then
		local qualityColor = _G.ITEM_QUALITY_COLORS[item.quality or 1]
		if buttonInfo.forceBorderDisplay then
			if (item.quality or 1) == 1 then
				qualityColor = BsSkin.itemSlotBorderDefaultColor
			end
		end
		buttonInfo.qualityColor = qualityColor
	end


	-- Hide badges by default.

	buttonInfo.qualityBadgeAlpha = 0
	buttonInfo.stockBadgeAlpha = 0
	buttonInfo.topLeftBadgeAlpha = 0


	-- Quality color badges can be enabled globally via Colorblind Mode.
	local qualityBadgeTexCoords = BS_INVENTORY_QUALITY_BADGE_COORD[item.quality]
	if
		buttonComponents.qualityBadge
		and (settings.itemQualityBadges or settings.colorblindMode)
		and qualityBadgeTexCoords
	then
		self:SetShadowedTextureTexCoord(
			buttonComponents.qualityBadge,
			qualityBadgeTexCoords[1],
			qualityBadgeTexCoords[2],
			qualityBadgeTexCoords[3],
			qualityBadgeTexCoords[4]
		)
		if BS_INVENTORY_QUALITY_BADGE_RECOLOR[item.quality] then
			self:SetShadowedTextureVertexColor(
				buttonComponents.qualityBadge,
				buttonInfo.qualityColor.r,
				buttonInfo.qualityColor.g,
				buttonInfo.qualityColor.b
			)
		else
			self:SetShadowedTextureVertexColor(buttonComponents.qualityBadge, 1, 1, 1)
		end
		-- This may be turned back off below for edit mode or if the item is locked.
		buttonInfo.qualityBadgeAlpha = 1
	end


	-- Active quest badge (uses the top left badge slot).
	if
		settings.itemActiveQuestBadges
		and Bagshui.activeQuestItems[item.name]
	then
		self:SetShadowedTexture(buttonComponents.topLeftBadge, "ItemSlot\\Quest")
		self:SetShadowedTextureTexCoord(buttonComponents.topLeftBadge, 0, 1, 0, 1)
		buttonInfo.topLeftBadgeAlpha = 1
	end


	-- Usable/learned colors and badge (secondary priority for top left badge slot).
	local usable, alreadyKnown
	if
		settings.itemUsableColors
		or settings.itemUsableBadges
		or settings.colorblindMode
	then
		usable, alreadyKnown = BsItemInfo:IsUsable(item)

		-- Color.
		if settings.itemUsableColors then
			if not usable then
				buttonInfo.iconTextureColorR = BS_COLOR.FULL_RED[1]
				buttonInfo.iconTextureColorG = BS_COLOR.FULL_RED[2]
				buttonInfo.iconTextureColorB = BS_COLOR.FULL_RED[3]
			elseif alreadyKnown then
				buttonInfo.iconTextureColorR = BS_COLOR.LIGHT_GREEN[1]
				buttonInfo.iconTextureColorG = BS_COLOR.LIGHT_GREEN[2]
				buttonInfo.iconTextureColorB = BS_COLOR.LIGHT_GREEN[3]
			end
		end

		-- Badge (don't override active quest indicator).
		if buttonInfo.topLeftBadgeAlpha == 0 then
			local usableTextureKey = ((not usable) and "UNUSABLE") or (alreadyKnown and "KNOWN")

			if
				(
					settings.itemUsableBadges
					or settings.colorblindMode
				)
				and usableTextureKey
			then
				self:SetShadowedTexture(
					buttonComponents.topLeftBadge,
					BS_INVENTORY_USABLE_BADGE[usableTextureKey].texture
				)
				self:SetShadowedTextureTexCoord(
					buttonComponents.topLeftBadge,
					BS_INVENTORY_USABLE_BADGE[usableTextureKey].texCoord[1],
					BS_INVENTORY_USABLE_BADGE[usableTextureKey].texCoord[2],
					BS_INVENTORY_USABLE_BADGE[usableTextureKey].texCoord[3],
					BS_INVENTORY_USABLE_BADGE[usableTextureKey].texCoord[4]
				)
				buttonInfo.topLeftBadgeAlpha = 1
			end
		end
	end


	-- Without an Inventory class instance, we're done.
	if inventory then

		-- Show charges.

		-- Items can only have charges if they aren't stacked.
		-- It might be nice to show x1 for items with 1 charge remaining, but the
		-- number of charges disappears from the tooltip once it's down to 1,
		-- so charges are going to behave like count and disappear at 1.
		local hasCharges = (item.count == 1 and item.maxStackCount == 1 and (item.charges or 0) > 1)
		_G.SetItemButtonCount(button, (hasCharges and item.charges or item.count))
		-- Make charges look different from count.
		if hasCharges then
			buttonComponents.count:SetText("×" .. (item.charges < 999 and item.charges or "+") .. "")
			buttonComponents.count:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
			buttonComponents.count:Show()
			-- Prevent split stack code from thinking there is more than one item,
			-- since the count property is set by SetItemButtonCount().
			button.count = 0
		else
			buttonComponents.count:SetTextColor(1, 1, 1)
		end


		-- Refresh stock state (new/increased/decreased).
		self:UpdateItemButtonStockState(button)


		-- Dim locked items and their badges.

		_G.SetItemButtonDesaturated(button, item.locked, 0.5, 0.5, 0.5)
		if item.locked then
			buttonInfo.iconTextureColorR = BS_COLOR.ITEM_SLOT_STATE_LOCKED[1]
			buttonInfo.iconTextureColorG = BS_COLOR.ITEM_SLOT_STATE_LOCKED[2]
			buttonInfo.iconTextureColorB = BS_COLOR.ITEM_SLOT_STATE_LOCKED[3]
			buttonInfo.iconTextureAlpha = BS_COLOR.ITEM_SLOT_STATE_LOCKED[4]

			buttonInfo.stockBadgeAlpha = buttonInfo.stockBadgeAlpha == 1 and 0.2 or 0
			buttonInfo.topLeftBadgeAlpha = buttonInfo.topLeftBadgeAlpha == 1 and 0.2 or 0
			buttonInfo.qualityBadgeAlpha = buttonInfo.qualityBadgeAlpha == 1 and 0.2 or 0
		end

	end


	if item.emptySlot == 1 then
		-- Empty slot: Show appropriate texture on the background layer.
		local emptySlotTexture = BS_INVENTORY_EMPTY_SLOT_TEXTURE[L.Bag]
		if inventory then
			emptySlotTexture = inventory:GetEmptySlotTexture(item)
		end
		buttonComponents.background:SetTexture(BsUtil.GetFullTexturePath(emptySlotTexture))

	else
		-- Filled slot: Remove background.
		buttonComponents.background:SetTexture("")
	end


	-- Force colors to be set.
	self:UpdateItemButtonColorsAndBadges(button, true)


	-- Cooldown.
	if inventory then
		local cooldownStart = 0
		local cooldownDuration = 0
		local isOnCooldown = nil
		if item.itemString ~= nil then
			cooldownStart, cooldownDuration, isOnCooldown = _G.GetContainerItemCooldown(item.bagNum, item.slotNum)
		end

		_G.CooldownFrame_SetTimer(buttonComponents.cooldown, cooldownStart, cooldownDuration, isOnCooldown)

		-- Apparently there can be situations where the cooldownDuration is greater than 0,
		-- but isOnCooldown is false. When that happens, dim the item.
		-- Not sure if this is needed, but EngInventory had it, so leaving it in.
		if cooldownDuration > 0 and isOnCooldown == 0 then
			_G.SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4, opacityOverride or 1)
		end
	end

end



--- Determine and apply correct colorization to all components of an item slot button.
---@param button table Button to which the item should be assigned.
---@param force boolean? Set colors even if there is not an associated item.
function Ui:UpdateItemButtonColorsAndBadges(button, force)

	-- Don't set colors when an item isn't assigned unless being forced to do so.
	if not button.bagshuiData.item and not force then
		return
	end

	local buttonInfo = button.bagshuiData
	local item = buttonInfo.item
	local inventory = buttonInfo.inventory
	local opacityOverride
	local buttonComponents = button.bagshuiData.buttonComponents


	-- These have usually been set by AssignItemToItemButton() but may need to be changed.

	local iconTextureColorR = buttonInfo.iconTextureColorR or BS_COLOR.ITEM_SLOT_STATE_NORMAL[1]
	local iconTextureColorG = buttonInfo.iconTextureColorG or BS_COLOR.ITEM_SLOT_STATE_NORMAL[2]
	local iconTextureColorB = buttonInfo.iconTextureColorB or BS_COLOR.ITEM_SLOT_STATE_NORMAL[3]
	local iconTextureAlpha = buttonInfo.iconTextureAlpha or BS_COLOR.ITEM_SLOT_STATE_NORMAL[4]


	-- Determine whether this slot needs to be highlighted because its container is highlighted.
	local containerHighlight = (
		inventory
		and item
		and (
			-- Condition 1: Item must be in the desired container and must NOT be an an empty slot stack.
			(
				inventory.highlightItemsInContainerId
				and item.bagNum == inventory.highlightItemsInContainerId
				and not button.bagshuiData.isEmptySlotStack
			)
			-- Condition 2: Item IS an empty slot stack and represents the desired container.
			or (
				button.bagshuiData.isEmptySlotStack
				and inventory.emptySlotStacks[inventory.containers[item.bagNum].genericType]._bagsRepresented[inventory.highlightItemsInContainerId]
			)
		)
	)



	if inventory and inventory.editMode then
		-- Edit Mode.

		-- Highlight/dim based on hovering.
		if
			item
			and (
				inventory.editState.highlightCategory == item.bagshuiCategoryId
				or inventory.editState.highlightItem == item.id
			)
		then
			-- We should be highlighting a category or item.
			buttonComponents.iconTexture:SetVertexColor(1, 1, 1, 1)
			buttonComponents.count:SetAlpha(1)

			buttonComponents.border:SetBackdropBorderColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotBorderOpacity
			)
			if buttonComponents.innerGlow then
				buttonComponents.innerGlow:SetVertexColor(
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
					BsSkin.itemSlotInnerGlowOpacity
				)
			end
			buttonComponents.highlightTexture:SetVertexColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotInnerGlowOpacity
			)
		else
			-- Dim this item.
			buttonComponents.iconTexture:SetVertexColor(1, 1, 1, BsSkin.itemSlotTextureEditModeOpacity)
			buttonComponents.count:SetAlpha(0.5)
			buttonComponents.border:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
			if buttonComponents.innerGlow then
				buttonComponents.innerGlow:SetVertexColor(1, 1, 1, 0)
			end
			buttonComponents.highlightTexture:SetVertexColor(1, 1, 1, 0)
		end

		-- Hide badges in Edit Mode
		buttonComponents.stockBadge:Hide()
		buttonComponents.qualityBadge:Hide()
		buttonComponents.topLeftBadge:Hide()


	else
		-- Normal processing (non-Inventory item slot buttons or Inventory and not Edit Mode).

		-- Dim non-matching items on container highlight.
		if
			inventory
			and inventory.highlightItemsInContainerId
			and item
			and item.bagNum ~= inventory.highlightItemsInContainerId
		then
			iconTextureAlpha = 0.3
			opacityOverride = 0.2
		end

		-- Default opacity when offline
		if inventory and not inventory.online then
			iconTextureAlpha = BsSkin.itemSlotTextureOfflineOpacity
		end

		-- Search dimming
		if inventory then
			-- Docked inventory types should use the parent's search text.
			local searchText = inventory.dockTo and Bagshui.components[inventory.dockTo].searchText or inventory.searchText
			if searchText then
				if not BsRules:Match(searchText, item, nil, nil, true) then
					iconTextureAlpha = BsSkin.itemSlotTextureDimmedOpacity
					opacityOverride = BsSkin.itemSlotTextureDimmedOpacity
				end
			end
		end

		-- Stock badge / "highlight changes" mode.
		if buttonComponents.stockBadge then
			if buttonInfo.stockBadgeAlpha > 0 then
				buttonComponents.stockBadge:Show()
				buttonComponents.stockBadge:SetAlpha(opacityOverride or buttonInfo.stockBadgeAlpha)
			else
				buttonComponents.stockBadge:Hide()

				-- If we're in "highlight changes" mode, dim this item because it hasn't changed.
				if not opacityOverride and inventory and inventory.highlightChanges then
					opacityOverride = BsSkin.itemSlotTextureDimmedOpacity
				end
			end
		end

		-- Set color and opacity of main texture and count.
		buttonComponents.iconTexture:SetVertexColor(
			iconTextureColorR,
			iconTextureColorG,
			iconTextureColorB,
			opacityOverride or iconTextureAlpha
		)

		-- Item borders get colors for every quality level.
		-- Some skins may always need the border displayed if the baked-in ItemTexture
		-- borders are hidden (itemSlotBorderAlwaysShow, which is mapped into
		-- the forceBorderDisplay property).
		buttonComponents.border:SetBackdropBorderColor(
			buttonInfo.qualityColor.r,
			buttonInfo.qualityColor.g,
			buttonInfo.qualityColor.b,
			(
				((inventory or buttonInfo.colorBorders) and item and item.quality > -1 and not item.locked) and (opacityOverride or BsSkin.itemSlotBorderOpacity)
				or (buttonInfo.forceBorderDisplay and opacityOverride or buttonInfo.qualityColor.a)
				or 0
			)
		)

		-- Only color inner glow for Uncommon and up.
		if buttonComponents.innerGlow then
			buttonComponents.innerGlow:SetVertexColor(
				buttonInfo.qualityColor.r,
				buttonInfo.qualityColor.g,
				buttonInfo.qualityColor.b,
				(
					((inventory or buttonInfo.colorBorders) and item and item.quality > 1 and not item.locked)
					and (opacityOverride or BsSkin.itemSlotInnerGlowOpacity)
					or 0
				)
			)
		end

		-- This is safe to call even if count is 0 because it will be hidden by
		-- SetItemButtonCount(), which means SetAlpha() won't do anything.
		buttonComponents.count:SetAlpha(opacityOverride or 1)

		-- Additional badges.
		if buttonComponents.qualityBadge then
			if buttonInfo.qualityBadgeAlpha > 0 then
				buttonComponents.qualityBadge:Show()
				self:SetShadowedTextureAlpha(buttonComponents.qualityBadge, (opacityOverride or buttonInfo.qualityBadgeAlpha))
			else
				buttonComponents.qualityBadge:Hide()
			end
		end
		if buttonComponents.topLeftBadge then
			if buttonInfo.topLeftBadgeAlpha > 0 then
				buttonComponents.topLeftBadge:Show()
				self:SetShadowedTextureAlpha(buttonComponents.topLeftBadge, (opacityOverride or buttonInfo.topLeftBadgeAlpha))
			else
				buttonComponents.topLeftBadge:Hide()
			end
		end

		-- Container item slot highlighting.
		-- Needs to happen after everything else is in place so that item slots will
		-- update properly when items are placed in a container by mousing over
		-- and clicking the container.
		if containerHighlight then
			buttonComponents.border:SetBackdropBorderColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotBorderContainerHighlightOpacity
			)
			if buttonComponents.innerGlow then
				buttonComponents.innerGlow:SetVertexColor(
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
					BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
					BsSkin.itemSlotInnerGlowContainerHighlightOpacity
				)
			end
			buttonComponents.highlightTexture:SetVertexColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotInnerGlowContainerHighlightOpacity
			)
		end

	end

	-- Make the mouseover highlight glow the same as the quality color when it's Uncommon or greater.
	if item and (item.quality or 0) > 1 then
		buttonComponents.highlightTexture:SetVertexColor(
			buttonInfo.qualityColor.r,
			buttonInfo.qualityColor.g,
			buttonInfo.qualityColor.b
		)
	else
		buttonComponents.highlightTexture:SetVertexColor(1, 1, 1)
	end


	if item and (item.emptySlot or 0) == 1 then
		-- Empty slot: Hide NormalTexture for a clean look.
		buttonComponents.normalTexture:SetVertexColor(0, 0, 0, 0)

	else
		-- Filled slot.
		buttonComponents.normalTexture:SetVertexColor(
			1, 1, 1,
			opacityOverride or 1
		)
	end

	-- Background opacity for search miss (only really matters for empty slots).
	buttonComponents.background:SetAlpha((not containerHighlight) and opacityOverride or 1)

end



--- Refresh the stock state (new/increased/decreased) of an item slot button:
--- * Sets the `bagshuiData.stockBadgeAlpha` property.
--- * Changes the slot badge texture to the appropriate icon.
--- * Clears the item's `bagshuiStockState` property if the stock change period has expired.
---
--- When there's no item associated with the button (`bagshuiData.item`), the stock
--- badge will always be hidden.
--- 
--- Note that this does *not* actually display or hide the stock badge -- that's
--- handled by `Ui:UpdateItemButtonColorsAndBadges()`. All this function does
--- is update the 
--- 
--- This is split into its own function so it can be called OnUpdate.
--- as well as `Ui:AssignItemToItemButton()`.
---@param button table Item slot button.
function Ui:UpdateItemButtonStockState(button)

	-- Assume the badge should be hidden.
	button.bagshuiData.stockBadgeAlpha = 0

	local inventory = button.bagshuiData.inventory

	if button.bagshuiData.item and inventory and not inventory.editMode then
		-- Item must be in an Inventory to have stock changes.

		local item = button.bagshuiData.item
		local groupId = button.bagshuiData.groupId

		if
			item.itemString ~= nil
			and (item.bagshuiDate or 0) > 0
			and item.bagshuiStockState ~= nil
			and item.bagshuiStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE
			and _G.time() - item.bagshuiDate < (inventory.settings.itemStockChangeExpiration * 60)
		then
			-- There are stock changes.

			-- Decide whether to the badge should be visible.
			if
				(
					inventory.settings.itemStockBadges
					or inventory.highlightChanges
				)
				-- Don't show stock badge if it's disabled for this group.
				and (
					not (inventory.groups and inventory.groups[groupId])
					or inventory.groups[groupId].hideStockBadge ~= true
				)
			then
				-- Badge should be displayed.

				-- Calculate opacity based on time elapsed.
				local stockBadgeAlpha = 1
				local timeElapsed = (_G.time() - item.bagshuiDate) / 60  -- Settings are in minutes, so convert from seconds here.
				-- Ready to start fading.
				if timeElapsed > (inventory.settings.itemStockChangeExpiration - inventory.settings.itemStockBadgeFadeDuration) then
					-- Translate time elapsed into an opacity percentage by scaling:
					-- Fade Start Time -> 100%
					-- Fade End Time   -> Lowest allowed opacity %
					-- This is done by initially scaling between 0 and 1 - [max fade], then subtracting that result from 1.
					stockBadgeAlpha = 1 - BsUtil.ScaleNumber(
						timeElapsed,
						inventory.settings.itemStockChangeExpiration - inventory.settings.itemStockBadgeFadeDuration,
						inventory.settings.itemStockChangeExpiration,
						0,
						1 - BS_INVENTORY_STOCK_BADGE_MAX_FADE
					)
				end

				self:SetShadowedTexture(
					button.bagshuiData.buttonComponents.stockBadge,
					"Interface\\Addons\\Bagshui\\Images\\ItemSlot\\Stock-" .. item.bagshuiStockState
				)

				-- Stock badge colors are baked into the textures instead of being configurable.
				-- If this is re-enabled, the corresponding items in Config/Settings.lua need to be enabled as well.
				-- local stockBadgeColor = inventory.settings["itemStockBadge" .. item.bagshuiStockState .. "Color"]
				-- self:SetShadowedTextureVertexColor(
				--	buttonComponents.stockBadge,
				-- 	stockBadgeColor[1],
				-- 	stockBadgeColor[2],
				-- 	stockBadgeColor[3]
				-- )

				button.bagshuiData.stockBadgeAlpha = (not item.locked) and stockBadgeAlpha or 0

			end

		else
			-- Item hasn't changed.

			-- Clear the stock change state. This is necessary for other parts of
			-- Bagshui (tooltips, "highlight changes" mode) to know whether the
			-- stock badge fade time has elapsed, after which the item is no longer "changed".
			item.bagshuiStockState = BS_ITEM_STOCK_STATE.NO_CHANGE

		end
	end

end



--- There are elements of the Blizzard `ItemButtonTemplate` that have hardcoded sizes
--- and instead of fixing them, this should be used in lieu of SetHeight/SetWidth.
---@param button table Button to scale.
---@param newSize number Height/width.
---@return number scale
function Ui:SetItemButtonSize(button, newSize)
	button.bagshuiData.scale = self:GetItemButtonScale(button, newSize)
	button:SetScale(button.bagshuiData.scale)

	self:InvertItemButtonBorderScale(button)

	return button.bagshuiData.scale
end



--- Determine the scale factor required to set an item button to the desired size
--- without actually applying the scaling.
---@param button table
---@param newSize number Height/width.
---@return number scale
function Ui:GetItemButtonScale(button, newSize)
	return newSize / button.bagshuiData.originalSizeAdjusted
end



--- Determine the scaled size of an item button without actually applying the scaling.
---@param button table
---@param newSize number Height/width.
---@return number buttonSize
function Ui:GetItemButtonScaledSize(button, newSize)
	return button.bagshuiData.originalSize * self:GetItemButtonScale(button, newSize)
end



--- Scale the item button border inversely to the scale of the item button if the
--- skin has requested it. This is necessary for 1px borders to stay 1px when scaling
--- is applied to the parent frame (the item button).
---@param button any
function Ui:InvertItemButtonBorderScale(button)
	if not button.bagshuiData.scale then
		return
	end

	if BsSkin.itemSlotBorderInverseScale and not button.bagshuiData.noBorderScale then
		button.bagshuiData.borderBackdropTable.edgeSize = BsSkin.itemSlotEdgeSize * (1/button.bagshuiData.scale)
		button.bagshuiData.buttonComponents.border:SetBackdrop(button.bagshuiData.borderBackdropTable)
		self:UpdateItemButtonColorsAndBadges(button, true)
	end
end


end)