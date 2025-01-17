-- Bagshui Core: Tooltips
-- General tooltip stuff along with sneaky tooltip hooking to globally display
-- the Bagshui info tooltip when Alt is held.
-- There's some slight redundancy here and in Inventory.Ui.ItemButton.lua, but it
-- doesn't feel like enough to warrant refactoring right now.
-- 
-- Exposes:
-- - BsTooltips (table of { name = tooltip }).
-- - BsInfoTooltip, BsCursorTooltip, BsIconButtonTooltip, BsHiddenTooltip (pointers to tooltips within BsTooltips).

Bagshui:AddComponent(function()


--- Initialize tooltips that are shared across all of Bagshui.
function Bagshui:InitTooltips()

	-- Info Tooltip -- because sometimes GameTooltip runs out of space.
	self.tooltips.info = self:CreateTooltip("InfoTooltip", nil, true)


	-- Cursor Tooltip for "carrying" items on the cursor in edit mode.
	self.tooltips.cursor = self:CreateTooltip("CursorTooltip")
	local cursorTooltipName = self.tooltips.cursor.bagshuiData.name

	-- Move texture to top left.
	local cursorTooltipTexture1 = _G[cursorTooltipName .. "Texture1"]
	cursorTooltipTexture1:ClearAllPoints()
	cursorTooltipTexture1:SetPoint("TOPLEFT", self.tooltips.cursor, "TOPLEFT", 10, -9)
	cursorTooltipTexture1:SetVertexColor(unpack(BS_COLOR.YELLOW))
	cursorTooltipTexture1:Show()
	-- Shift text left so it doesn't overlap with texture.
	local textLeft1 = _G[cursorTooltipName .. "TextLeft1"]
	local textLeft2 = _G[cursorTooltipName .. "TextLeft2"]
	textLeft1:SetPoint("TOPLEFT", self.tooltips.cursor, "TOPLEFT", 26, -10)
	textLeft2:ClearAllPoints()
	textLeft2:SetPoint("LEFT", cursorTooltipTexture1, "LEFT", 0, 0)
	textLeft2:SetPoint("TOP", textLeft1, "BOTTOM", 0, -2)

	self.tooltips.cursor.bagshuiData.textLeft1 = textLeft1
	self.tooltips.cursor.bagshuiData.textLeft2 = textLeft2
	self.tooltips.cursor.bagshuiData.texture1 = cursorTooltipTexture1


	-- Icon button tooltip for toolbar buttons, etc.	
	self.tooltips.iconButton = self:CreateTooltip("IconButtonTooltip")
	local iconButtonTooltipName = self.tooltips.iconButton.bagshuiData.name

	-- Set all text the same size as the title so that when we scale down the tooltip
	-- the non-title text doesn't become unreadable.
	local _, titleFontSize = _G[iconButtonTooltipName .. "TextLeft1"]:GetFont()
	for i = 2, 10 do
		_G[iconButtonTooltipName .. "TextLeft" .. i]:SetFont(
			_G[iconButtonTooltipName .. "TextLeft" .. i]:GetFont(),
			titleFontSize
		)
	end
	self.tooltips.iconButton:SetScale(0.65)


	-- Hidden tooltip for retrieving item tooltips and forcing items to load into the local game cache.
	self.tooltips.hidden = self:CreateTooltip("HiddenTooltip")
	-- This makes looping through the tooltip easier.
	self.tooltips.hidden.bagshuiData.textFieldsPerLine = { "Left", "Right", }
	-- Must have an owner to function.
	self.tooltips.hidden:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
	-- These font strings are required to allow tooltip the SetBagItem(), etc. methods to dynamically add new lines.
	self.tooltips.hidden:AddFontStrings(
		self.tooltips.hidden:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
		self.tooltips.hidden:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
	)


	-- Expose tooltips.
	Bagshui.environment.BsTooltips = self.tooltips
	for _, tooltip in pairs(self.tooltips) do
		self.environment["Bs" .. tooltip.bagshuiData.shortName] = tooltip
	end

end



--- Create a new tooltip.
---@param name string Unique name for the tooltip (will be passed to `Ui:CreateElementName()`).
---@param inherits string? Widget template.
---@param smallFont boolean? When true, change all text to `GameFontNormalSmall`.
---@return table tooltip
function Bagshui:CreateTooltip(name, inherits, smallFont)
	local tooltipName = Bagshui.prototypes.Ui:CreateElementName(name)
	local tooltip = _G.CreateFrame(
		"GameTooltip",
		tooltipName,
		_G.UIParent,  -- Required for tooltips to respect UI scale.
		inherits or "GameTooltipTemplate"
	)
	tooltip.bagshuiData = {
		name = tooltipName,
		shortName = name,
	}

	-- Apply per-skin tooltip styling.
	if BsSkin.tooltipSkinFunc then
		BsSkin.tooltipSkinFunc(tooltip)
	end

	-- Shrink all the tooltip lines
	if smallFont then
		local i = 1
		while true do
			local fontString = _G[tooltip.bagshuiData.name .. "TextLeft" .. i]
			if not fontString then
				break
			end
			fontString:SetFontObject("GameFontNormalSmall")
			_G[tooltip.bagshuiData.name .. "TextRight" .. i]:SetFontObject("GameFontNormalSmall")

			i = i + 1
		end
	end

	return tooltip
end



--- Wrapper for `Bagshui:FormatTooltipLine()` that automatically adds to the Bagshui info tooltip.
---@param tooltip table WoW UI tooltip.
---@param text string? Primary text value.
---@param label string? Labels to display in front of text, if any.
---@param title boolean? Use highlight color instead of normal color for `text`.
---@param indent boolean? Indent the entire line.
function Bagshui:AddTooltipLine(tooltip, text, label, title, indent)
	tooltip:AddLine(self:FormatTooltipLine(text, label, title, indent))
end



--- Prepare text to be added to a tooltip. Will colorize, label, and indent.
---@param text string? Primary text value.
---@param label string? Labels to display in front of text, if any.
---@param title boolean? Use highlight color instead of normal color for `text`.
---@param indent boolean? Indent the entire line.
---@return string tooltipText
function Bagshui:FormatTooltipLine(text, label, title, indent)
	local tooltipText = (title and HIGHLIGHT_FONT_COLOR_CODE or NORMAL_FONT_COLOR_CODE) .. (text or "") .. FONT_COLOR_CODE_CLOSE
	if label then
		tooltipText = BsUtil.Trim(
			(title and BS_FONT_COLOR.BAGSHUI or HIGHLIGHT_FONT_COLOR_CODE)
			.. label
			.. FONT_COLOR_CODE_CLOSE
			.. " " .. tooltipText
		)
	end
	if indent then
		tooltipText = "  " .. tooltipText
	end
	return tooltipText
end



--- Display the given tooltip after a delay if it's still owned by the same element.
--- To utilize this, use `<tooltip>:AddLine()`, not `SetText()` since the latter instantly makes the tooltip visible:
--- ```
--- <tooltip>:SetOwner(<owner>, "ANCHOR_TOPLEFT")
--- <tooltip>:ClearLines()
--- <tooltip>:AddLine("Text")
--- Bagshui:ShowTooltipAfterDelay(<tooltip>, <owner>)
--- ```
---@param tooltip table Tooltip frame to show.
---@param expectedOwner table Frame that should own the tooltip.
---@param tooltipGroupElement table UI element that conceptually groups multiple items together and will be used to determine when the delay to display tooltips should be shortened.
---@param delayOverride number? Delay after which the tooltip should be shown. `BS_TOOLTIP_DELAY_SECONDS.DEFAULT` will be used if not provided.
---@param noTooltipDelayShorting boolean? When true, do not shorten subsequent tooltip display delays.
---@param postDisplayCallback function? Callback to trigger after the tooltip is shown.
function Bagshui:ShowTooltipAfterDelay(tooltip, expectedOwner, tooltipGroupElement, delayOverride, noTooltipDelayShorting, postDisplayCallback)

	tooltipGroupElement = tooltipGroupElement or expectedOwner:GetParent()
	if not tooltipGroupElement.bagshuiData then
		tooltipGroupElement.bagshuiData = {}
	end

	-- Set the tooltip group tracking property on the tooltip owner.
	if not expectedOwner.bagshuiData then
		expectedOwner.bagshuiData = {}
	end
	expectedOwner.bagshuiData._showTooltipAfterDelay_TooltipGroupElement = tooltipGroupElement

	-- Default delay
	local delaySeconds = delayOverride or BS_TOOLTIP_DELAY_SECONDS.DEFAULT

	-- Shorten delay if a tooltip has been displayed for this group in the last X seconds.
	if
		not noTooltipDelayShorting
		and type(tooltipGroupElement.bagshuiData._showTooltipAfterDelay_LastShown) == "number"
		and _G.GetTime() - tooltipGroupElement.bagshuiData._showTooltipAfterDelay_LastShown < BS_TOOLTIP_DELAY_SECONDS.USE_SHORTENED_AFTER_LAST_SHOW_FOR
	then
		delaySeconds = BS_TOOLTIP_DELAY_SECONDS.SHORTENED
	end

	-- Show the tooltip after the delay.
	if delayOverride == 0 then
		self:ShowTooltipIfStillOwned(tooltip, expectedOwner, postDisplayCallback)
	else
		Bagshui:QueueClassCallback(
			self,
			self.ShowTooltipIfStillOwned,
			delaySeconds,
			false,
			tooltip,
			expectedOwner,
			postDisplayCallback
		)
	end

end



--- Helper function for ShowTooltipAfterDelay that actually makes the tooltip
--- visible if it's still owned by the same element once the delay has expired.
---@param tooltip table Tooltip frame to show.
---@param expectedOwner table Frame that should own the tooltip.
---@param postDisplayCallback function?
function Bagshui:ShowTooltipIfStillOwned(tooltip, expectedOwner, postDisplayCallback)
	if tooltip and tooltip.IsOwned and tooltip:IsOwned(expectedOwner) then
		tooltip:Show()
		self:ShortenTooltipDelay(expectedOwner, true)  -- Update the time of last display for this tooltip group.
		if postDisplayCallback then
			postDisplayCallback()
		end
	end
end



-- Helper function for `Bagshui:ShowTooltipAfterDelay()` to update the
-- `_showTooltipAfterDelay_LastShown` property of the tracking element.
---@param element table Frame triggering the tooltip display.
---@param shorten boolean? `true` to set the LastShown property, which will shorten the next display of tooltips within this tooltip group.
function Bagshui:ShortenTooltipDelay(element, shorten)

	-- Make sure the Bagshui table exists to avoid errors.
	if not element.bagshuiData then
		element.bagshuiData = {}
	end

	-- If this is an element that has a breadcrumb up to a parent element, use that instead.
	-- This will be triggered most of the time, but it gives the option to pass in a parent frame
	-- and reset tooltip delays directly if desired. (Initially this was going to be how things
	-- worked and then it turned out to not be necessary but the functionality is staying I guess?).
	if element.bagshuiData._showTooltipAfterDelay_TooltipGroupElement then
		element = element.bagshuiData._showTooltipAfterDelay_TooltipGroupElement

		-- Again, make sure the Bagshui table exists since we have changed elements.
		if not element.bagshuiData then
			element.bagshuiData = {}
		end
	end

	-- Set or clear the LastShown property.
	element.bagshuiData._showTooltipAfterDelay_LastShown = shorten and _G.GetTime() or nil
end



--- Hide GameTooltip and all Bagshui Info Tooltips if owned by `this` or `force == true`.
---@param this table? Frame to check for ownership instead of the global `this`.
---@param force boolean? Hide tooltips without checking ownership.
function Bagshui:HideTooltips(this, force)
	this = this or _G.this
	if force or _G.GameTooltip:IsOwned(this) then
		_G.GameTooltip:Hide()
	end
	for _, tooltip in pairs(self.tooltips) do
		if force or tooltip:IsOwned(this) then
			tooltip:Hide()
		end
	end
end



--- Prepare an info tooltip to be displayed. Anchors above or below the parent tooltip
--- depending on where there is more vertical space.
---@param owner table Frame that owns the tooltip (parameter for `<tooltip>:SetOwner()`).
---@param managedElsewhere boolean? Don't do any automatic filling of tooltip content in `Bagshui:ManageInfoTooltip()`.
---@param forceBelow boolean? When true, always display info tooltip below `attachToTooltip` regardless of `attachToTooltip`'s vertical position.
---@param attachToTooltip table? "Parent" tooltip to which the info tooltip will attach (default: `GameTooltip`).
---@param infoTooltip table? Info tooltip, if `BsInfoTooltip` shouldn't be used.
function Bagshui:SetInfoTooltipPosition(owner, managedElsewhere, forceBelow, attachToTooltip, infoTooltip)
	-- Always need an owner. Don't throw an error though. Upstream code in
	-- Bagshui:ManageInfoTooltip() tries to guard against this, but let's be sure.
	if not owner then
		return
	end

	attachToTooltip = attachToTooltip or _G.GameTooltip

	-- Sanity check.
	if not attachToTooltip.bagshuiData then
		return
	end

	infoTooltip = infoTooltip or BsInfoTooltip

	infoTooltip:SetOwner(owner, "ANCHOR_PRESERVE")
	infoTooltip:ClearAllPoints()

	-- Anchor info tooltip to left/right/center of tooltip.
	local leftRight = ""
	if (attachToTooltip:GetNumPoints()) or 0 > 0 then
		local point = attachToTooltip:GetPoint(1)
		leftRight = BsUtil.GetAnchorLeftRight(point)
	end

	-- Consumed by `Bagshui:ShowInfoTooltip()`.
	infoTooltip.anchorLeftRight = leftRight

	-- Consumed by `Bagshui:ManageInfoTooltip()`.
	attachToTooltip.bagshuiData.infoTooltipManagedElsewhere = managedElsewhere

	-- Show info tooltip above or below depending on tooltip position.
	if
		not forceBelow
		and (
			(
				attachToTooltip:GetTop()
				and _G.GetScreenHeight() - attachToTooltip:GetTop() > attachToTooltip:GetBottom()
			)
			or (
				attachToTooltip.bagshuiData.displayNextAbove
			)
		)
	then
		-- Above.
		infoTooltip:SetPoint("BOTTOM" .. leftRight, attachToTooltip, "TOP" .. leftRight, 0, -BsSkin.infoTooltipYOffset)
	else
		-- Below.
		infoTooltip:SetPoint("TOP" .. leftRight, attachToTooltip, "BOTTOM" .. leftRight, 0, BsSkin.infoTooltipYOffset)
	end

end



--- Because info tooltips are anchored above/below another tooltip, sometimes
--- things run up against the edge of the screen and the tooltips can overlap.
--- We can (mostly) prevent this by doing some re-anchoring fancy footwork.
---@param infoTooltip any
function Bagshui:ShowInfoTooltip(infoTooltip)
	infoTooltip = infoTooltip or BsInfoTooltip

	-- First, get the tooltip on the screen so its size will be calculated.
	infoTooltip:Show()

	-- Info tooltip can't be used.
	if not infoTooltip:IsVisible() then
		return
	end
	if not ((infoTooltip:GetNumPoints() or 0) > 0) then
		return
	end

	-- Determine where the info tooltip is currently anchored.
	local point, tooltip = infoTooltip:GetPoint(1)

	-- Anchoring tooltip can't be used.
	if not tooltip.bagshuiData then
		return
	end
	if not ((tooltip:GetNumPoints() or 0) > 0) then
		return
	end

	-- Store anchor points for the tooltip to which the info tooltip is anchored
	-- so that `Bagshui:ManageTooltip()` can restore them.
	tooltip.bagshuiData.originalPoint,
		tooltip.bagshuiData.originalAnchorToFrame,
		tooltip.bagshuiData.originalAnchorToPoint,
		tooltip.bagshuiData.originalXOffset,
		tooltip.bagshuiData.originalYOffset = tooltip:GetPoint(1)

	-- Decide whether the info tooltip is above or below the tooltip to which it's anchored.
	local topTooltip, bottomTooltip
	if
		string.find(point, "^BOTTOM")
	then
		-- Above.
		topTooltip = infoTooltip
		bottomTooltip = tooltip
	else
		-- Below.
		topTooltip = tooltip
		bottomTooltip = infoTooltip
	end

	-- Left/right/center-aligned?
	local leftRight = BsUtil.GetAnchorLeftRight(point)

	-- When one of the tooltips is at the extreme edge, re-anchor the other tooltip
	-- to it so one can't slide under the other.
	if topTooltip:GetTop() / _G.UIParent:GetEffectiveScale() >= _G.UIParent:GetTop() then
		-- Top tooltip is at the top of the screen.
		topTooltip:ClearAllPoints()
		bottomTooltip:ClearAllPoints()
		bottomTooltip:SetPoint(
			"TOP" .. leftRight,
			topTooltip,
			"BOTTOM" .. leftRight,
			0,
			BsSkin.infoTooltipYOffset
		)

	elseif bottomTooltip:GetBottom() / _G.UIParent:GetEffectiveScale() <= _G.UIParent:GetBottom() then
		-- Bottom tooltip is at the bottom of the screen.
		topTooltip:ClearAllPoints()
		bottomTooltip:ClearAllPoints()
		topTooltip:SetPoint(
			"BOTTOM" .. leftRight,
			bottomTooltip,
			"TOP" .. leftRight,
			0,
			-BsSkin.infoTooltipYOffset
		)

	end

end



--- Called from each hooked tooltip's OnShow, OnHide, and OnUpdate to decide whether
--- the info tooltip should be shown or hidden.
---@param tooltip any
function Bagshui:ManageInfoTooltip(tooltip)
	if
		-- Don't do anything if global tooltip hooks are disabled.
		not BsSettings.globalInfoTooltips
		-- Exception for Bagshui bag slot buttons. This would be nice to refactor out.
		and not (tooltip.bagshuiData and tooltip.bagshuiData.infoTooltipAlwayShow)
	then
		-- When the setting is toggled, we need to hide the info tooltip unless it has a management exemption.
		if tooltip.bagshuiData and tooltip.bagshuiData.infoTooltip and not tooltip.bagshuiData.infoTooltipManagedElsewhere then
			tooltip.bagshuiData.infoTooltip:Hide()
		end
		return
	end

	-- Reasons not to proceed.
	if
		-- Tooltip to which we want to attach isn't visible.
		not tooltip:IsVisible()
		-- We don't have the information we need.
		or not tooltip.bagshuiData
		or not tooltip.bagshuiData.lastItemString
		or not tooltip.bagshuiData.infoTooltip
		-- Exempt from global management (stored when `Bagshui:SetInfoTooltipPosition()` is called).
		or tooltip.bagshuiData.infoTooltipManagedElsewhere
	then
		-- Reset things if there's no exemption.
		if tooltip.bagshuiData and not tooltip.bagshuiData.infoTooltipManagedElsewhere then
			-- Hide the info tooltip when it's still owned by the previous frame or we don't have ownership data.
			if
				tooltip.bagshuiData.infoTooltip
				and (
					(
						tooltip.bagshuiData.lastOwner
						and tooltip.bagshuiData.infoTooltip:IsOwned(tooltip.bagshuiData.lastOwner)
					)
					or not tooltip.bagshuiData.lastOwner
				)
			then
				tooltip.bagshuiData.infoTooltip:Hide()
			end
			tooltip.bagshuiData.lastOwner = nil
			tooltip.bagshuiData.lastAltKeyState = nil
			tooltip.bagshuiData.lastControlKeyState = nil
			tooltip.bagshuiData.lastShiftKeyState = nil
		end
		return
	end

	-- Triggers to potentially show or hide tooltip.
	if
		tooltip.bagshuiData.lastAltKeyState ~= _G.IsAltKeyDown()
		or tooltip.bagshuiData.lastControlKeyState ~= _G.IsControlKeyDown()
		or tooltip.bagshuiData.lastShiftKeyState ~= _G.IsShiftKeyDown()
	then

		-- Move the parent tooltip back to its original spot if it was adjusted by `Bagshui:ShowInfoTooltip()`.
		if tooltip.bagshuiData.originalPoint then
			tooltip:ClearAllPoints()
			tooltip:SetPoint(
				tooltip.bagshuiData.originalPoint,
				tooltip.bagshuiData.originalAnchorToFrame,
				tooltip.bagshuiData.originalAnchorToPoint,
				tooltip.bagshuiData.originalXOffset,
				tooltip.bagshuiData.originalYOffset
			)
		end

		-- Should we actually show or hide?
		if
			tooltip.bagshuiData.lastOwner
			and (
				_G.IsAltKeyDown()
				or tooltip.bagshuiData.showInfoTooltipWithoutAlt
				or BsSettings.showInfoTooltipsWithoutAlt
	 		)
			and not _G.IsShiftKeyDown()
		then
			-- Need to show.

			-- Reset and position.
			tooltip.bagshuiData.infoTooltip:ClearLines()
			self:SetInfoTooltipPosition(tooltip.bagshuiData.lastOwner, false, false, tooltip, tooltip.bagshuiData.infoTooltip)

			-- Determine which version of the tooltip to show.
			if _G.IsControlKeyDown() then
				-- Item property list.
				BsItemInfo:Get(tooltip.bagshuiData.lastItemString, tooltip.bagshuiData.lastItemInfo, true)
				BsItemInfo:AddTooltipInfo(tooltip.bagshuiData.lastItemInfo, tooltip.bagshuiData.infoTooltip)
			else
				-- Basic -- just account-wide counts.
				BsCatalog:AddTooltipInfo(tooltip.bagshuiData.lastItemString, tooltip.bagshuiData.infoTooltip)
			end

			-- Any content to display?
			if tooltip.bagshuiData.infoTooltip:NumLines() > 0 then
				self:ShowInfoTooltip(tooltip.bagshuiData.infoTooltip)
			end

		elseif
			not tooltip.bagshuiData.lastOwner
			or tooltip.bagshuiData.infoTooltip:IsOwned(tooltip.bagshuiData.lastOwner)
		then
			-- Need to hide.
			tooltip.bagshuiData.infoTooltip:Hide()

		end

		-- Store states for next check.

		tooltip.bagshuiData.lastAltKeyState = _G.IsAltKeyDown()
		tooltip.bagshuiData.lastControlKeyState = _G.IsControlKeyDown()
		tooltip.bagshuiData.lastShiftKeyState = _G.IsShiftKeyDown()
	end
end



--- Hook the tooltips where we want to intercept `SetHyperlink()`, `SetBagItem()`, etc.
--- so that our info tooltip can be displayed when Alt is held.
function Bagshui:AddInfoTooltipHooks()
	self:HookTooltip(_G.GameTooltip)
	self:HookTooltip(_G.ItemRefTooltip, true, true)
end



--- Shared function for profession-related tooltips.
---@param self table Tooltip.
---@param type "Craft"|"TradeSkill" Profession type - used to decide what downstream functions to call.
---@param skill string Profession name (passed through from the `:Set*()` function).
---@param slot number? Item slot (passed through from the `:Set*()` function).
---@param subtype string? If the hooked function ends in something other than "Item", specify that here.
---@return unknown
local function hookTooltip_SetProfessionItem(self, type, skill, slot, subtype)
	if slot then
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G["Get" .. type .. "ReagentItemLink"](skill, slot))
	else
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G["Get" .. type .. "ItemLink"](skill))
	end
	return self.bagshuiData.hooked["Set" .. type .. (subtype or "Item")](self, skill, slot)
end


-- Functions we're hooking on each tooltip.
local hookTooltipFunctions = {

	-- These are needed to capture items being displayed in the tooltip.
	-- Some guidance taken from aux's [tooltip.lua](https://github.com/shirsig/aux-addon-vanilla/blob/master/core/tooltip.lua).
	-- and pfUI's [libtooltip.lua](https://github.com/shagu/pfUI/blob/master/libs/libtooltip.lua)

	SetBagItem = function(self, bagNum, slotNum)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetContainerItemLink(bagNum, slotNum))
		return self.bagshuiData.hooked.SetBagItem(self, bagNum, slotNum)
	end,

	SetAuctionItem = function(self, type, index)
		self.bagshuiData.displayNextAbove = true  -- Don't obscure auction listing row.
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetAuctionItemLink(type, index))
		return self.bagshuiData.hooked.SetAuctionItem(self, type, index)
	end,

	SetAuctionSellItem = function(self)
		local name, texture = _G.GetAuctionSellItemInfo()
		self.bagshuiData.lastItemString  = BsCatalog:FindItemByNameAndTexture(name, texture, "itemString")
		return self.bagshuiData.hooked.SetAuctionSellItem(self)
	end,

	SetCraftItem = function(self, skill, slot)
		return hookTooltip_SetProfessionItem(self, "Craft", skill, slot)
	end,

	SetCraftSpell = function(self, slot)
		return hookTooltip_SetProfessionItem(self, "Craft", slot, nil, "Spell")
	end,

	SetHyperlink = function(self, link)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(link)
		-- https://github.com/veechs/Bagshui/issues/52
		-- Need to trap errors here because pfQuest adds "quest:" links to the game.
		-- This in and of itself isn't a problem, but if the person clicking the
		-- chat link isn't running pfQuest but IS using Bagshui, there will be an
		-- error thrown that looks like it's a Bagshui issue. In reality, it's
		-- simply that Vanilla WoW doesn't know what to do with quest links unless
		-- an addon steps in and adds hooks to intercept them.
		local ret, error = pcall(self.bagshuiData.hooked.SetHyperlink, self, link)
		if error then
			-- Display the error without the [Bagshui] prefix so it looks like a
			-- standard game message (which it technically is).
			Bagshui:ShowErrorMessage(error, nil, nil, nil, nil, nil, nil, nil, true)
		end
		return ret
	end,

	SetInboxItem = function(self, id, attachIndex)
		local name, texture = _G.GetInboxItem(id)
		self.bagshuiData.lastItemString  = BsCatalog:FindItemByNameAndTexture(name, texture, "itemString")
		return self.bagshuiData.hooked.SetInboxItem(self, id, attachIndex)
	end,

	SetInventoryItem = function(self, unit, slotNum, nameOnly)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetInventoryItemLink(unit, slotNum))
		return self.bagshuiData.hooked.SetInventoryItem(self, unit, slotNum, nameOnly)
	end,

	SetLootItem = function(self, lootSlot)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetLootSlotLink(lootSlot))
		return self.bagshuiData.hooked.SetLootItem(self, lootSlot)
	end,

	SetLootRollItem = function(self, id)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetLootRollItemLink(id))
		return self.bagshuiData.hooked.SetLootRollItem(self, id)
	end,

	SetMerchantItem = function(self, id)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetMerchantItemLink(id))
		return self.bagshuiData.hooked.SetMerchantItem(self, id)
	end,

	SetQuestItem = function(self, type, slot)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetQuestItemLink(type, slot))
		return self.bagshuiData.hooked.SetQuestItem(self, type, slot)
	end,

	SetQuestLogItem = function(self, type, slot)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetQuestLogItemLink(type, slot))
		return self.bagshuiData.hooked.SetQuestLogItem(self, type, slot)
	end,

	SetSendMailItem = function(self)
		-- Vanilla doesn't have GetSendMailItemLink() so we need to figure it out.
		local name, texture = _G.GetSendMailItem()
		self.bagshuiData.lastItemString  = BsCatalog:FindItemByNameAndTexture(name, texture, "itemString")
		return self.bagshuiData.hooked.SetSendMailItem(self)
	end,

	SetTradePlayerItem = function(self, index)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetTradePlayerItemLink(index))
		return self.bagshuiData.hooked.SetTradePlayerItem(self, index)
	end,

	SetTradeSkillItem = function(self, skill, slot)
		return hookTooltip_SetProfessionItem(self, "TradeSkill", skill, slot)
	end,

	SetTradeTargetItem = function(self, index)
		self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink(_G.GetTradeTargetItemLink(index))
		return self.bagshuiData.hooked.SetTradeTargetItem(self, index)
	end,


	-- Reset all tracking when the tooltip owner changes.
	SetOwner = function(self, owner, anchor, xOffset, yOffset)
		self.bagshuiData.lastOwner = owner
		self.bagshuiData.lastItemString = nil
		self.bagshuiData.lastAltKeyState = -1
		self.bagshuiData.lastControlKeyState = -1
		self.bagshuiData.lastShiftKeyState = -1
		self.bagshuiData.showInfoTooltipWithoutAlt = nil
		self.bagshuiData.displayNextAbove = nil
		self.bagshuiData.originalPoint = nil
		self.bagshuiData.originalAnchorToFrame = nil
		self.bagshuiData.originalAnchorToPoint = nil
		self.bagshuiData.originalXOffset = nil
		self.bagshuiData.originalYOffset = nil

		-- aux is almost impenetrable and does absolutely wild things with tooltips
		-- where it caches the text instead of calling SetHyperlink(), but we *can*
		-- luckily discover the item during the SetOwner() call. Refer to `methods.OnIconEnter`
		-- in aux's gui\auction_listing.lua file to see why this works.
		if _G.IsAddOnLoaded("aux-addon") then
			local parent = owner:GetParent()
			self.bagshuiData.lastItemString = BsItemInfo:ParseItemLink((
				parent
				and parent.row
				and parent.row.record
				and parent.row.record.link
			))
			self.bagshuiData.displayNextAbove = (self.bagshuiData.lastItemString ~= nil)  -- Don't obscure auction listing row.
		end
		
		-- Clearing this only when the tooltip isn't visible keeps us from
		-- incorrectly overriding the value set by our ItemButton code.
		if not self:IsVisible() then
			self.bagshuiData.infoTooltipManagedElsewhere = false
		end
		return self.bagshuiData.hooked.SetOwner(self, owner, anchor, xOffset, yOffset)
	end,
}


-- Frame scripts that need to be hooked for each tooltip in order to show or hide the info tooltip.
local hookTooltipScripts = {

	OnUpdate = function()
		Bagshui:ManageInfoTooltip(_G.this.bagshuiData.tooltip)
	end,

	OnShow = function()
		-- Next-frame delay is necessary to prevent flickering tooltips with pfQuest's `/db scan`.
		Bagshui:QueueClassCallback(Bagshui, Bagshui.ManageInfoTooltip, nil, nil, _G.this.bagshuiData.tooltip)
	end,

	OnHide = function()
		-- Do a check on the next frame to see if the info tooltip should be hidden.
		-- Delay is necessary due to Blizzard's bag slot buttons constantly hiding and
		-- re-showing GameTooltip OnUpdate.
		Bagshui:QueueClassCallback(Bagshui, Bagshui.ManageInfoTooltip, nil, nil, _G.this.bagshuiData.tooltip)
	end,
}


--- Do the necessary work to insert all tooltip hooks.
--- Not using the Hooks class for this because it doesn't currently support hooking
--- functions outside the global namespace.
---@param tooltip table Tooltip to hook.
---@param createInfoTooltip boolean? Create a new info tooltip to work with this tooltip.
---@param showAbove boolean? Place the info tooltip above the hooked tooltip by default.
function Bagshui:HookTooltip(tooltip, createInfoTooltip, showAbove)
	if not tooltip then
		return
	end

	if not tooltip.bagshuiData then
		tooltip.bagshuiData = {}
	end

	local tooltipName = (tooltip:GetName() or tostring(tooltip))

	local infoTooltip = BsInfoTooltip

	if createInfoTooltip then
		infoTooltip = self:CreateTooltip(tooltipName .. "Info", nil, true)
	end

	tooltip.bagshuiData.infoTooltip = infoTooltip
	-- Reusable table for `ItemInfo:Get()` results that are displayed when Control+Alt are held.
	tooltip.bagshuiData.lastItemInfo = {}
	tooltip.bagshuiData.showInfoTooltipAbove = showAbove
	tooltip.bagshuiData.hooked = {}

	-- Hook functions.
	for functionName, hookFunction in pairs(hookTooltipFunctions) do
		tooltip.bagshuiData.hooked[functionName] = tooltip[functionName]
		tooltip[functionName] = hookFunction
	end

	-- Hook scripts.
	-- Handled by creating a child frame instead of hooking the existing frame's scripts
	-- because it seems to behave MUCH better this way.
	tooltip.bagshuiData.hookFrame = _G.CreateFrame("Frame", tooltipName .. "BagshuiHookFrame", tooltip)
	tooltip.bagshuiData.hookFrame.bagshuiData = {
		tooltip = tooltip
	}
	for scriptName, hookScript in pairs(hookTooltipScripts) do
		tooltip.bagshuiData.hookFrame:SetScript(scriptName, hookScript)
	end

end


-- Initialization.
-- Doing this here instead of Bagshui:Init() or Bagshui:AddonLoaded()
-- because we depend on Ui:CreateElementName().
Bagshui:InitTooltips()
Bagshui:AddInfoTooltipHooks()


end)