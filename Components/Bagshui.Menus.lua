-- Bagshui Core: Menus
-- Menu-related functionality that makes sense at the Bagshui level instead of on the Menus class.

Bagshui:LoadComponent(function()


-- If there's an open menu that we own, close it.
---@param startLevel number? Close all menus at this level and higher. Will close all menus if not specified.
---@param force boolean? Close menus even if `Bagshui:IsMenuOpen()` returns false.
---@param keepLowerLevelsOpen boolean? When true, call `Bagshui:BlockAutoMenuClose()` for all levels lower than `startLevel`.
function Bagshui:CloseMenus(startLevel, force, keepLowerLevelsOpen)
	if not self:IsMenuOpen() and not force then
		return
	end
	_G.CloseDropDownMenus(startLevel)
	if keepLowerLevelsOpen and type(startLevel) == "number" and startLevel > 1 then
		self:BlockAutoMenuClose(1, startLevel - 1)
	end
end



-- Return true if one of our menus is open (can be restricted to a specific menu type if needed).
-- This is done by checking the `UIDROPDOWNMENU_OPEN_MENU` global variable to see if it contains our
-- menu frame's name. We also need to be sure that dropdown level 1 is visible, because
-- `UIDROPDOWNMENU_OPEN_MENU` doesn't get cleared when menus are closed.
---@param menuType string? Only return true if this specific menu type is open.
---@return boolean
function Bagshui:IsMenuOpen(menuType)
	return
		-- Bagshui menu was the last one opened.
		(self.menuFrame and _G.UIDROPDOWNMENU_OPEN_MENU == self.menuFrame.bagshuiData.name)
		-- Menu is actually open.
		and _G.DropDownList1:IsVisible()
		-- menuType filter.
		and ((menuType and self.menuFrame.bagshuiData.lastMenuTypeLoaded == menuType) or not menuType)
		-- Nothing was open.
		or false
end



--- Prevent the automatic 2-second menu close countdown from kicking in.
--- Primarily used to keep the Settings menu open when the mouse cursor isn't over it.
---@param startLevel number? Lowest level to keep open, inclusive (1-3).
---@param endLevel number? Highest level to keep open, inclusive (1-3).
---@param menuType string? If provided, only stop the countdown when this menu is open.
function Bagshui:BlockAutoMenuClose(startLevel, endLevel, menuType)
	if menuType and not self:IsMenuOpen(menuType) then
		return
	end

	for level = startLevel or 1, endLevel or 3, 1 do
		_G.UIDropDownMenu_StopCounting(_G["DropDownList" .. level])
	end

	-- Need a second pass to ensure nothing has started the countdown again.
	if menuType then
		self:QueueClassCallback(self, self.BlockAutoMenuClose, 1.5, nil, startLevel, endLevel, menuType)
	end
end



local TOGGLE_DROPDOWN_MENU_FIRST_PASS = "BAGSHUI_TOGGLE_DROPDOWN_MENU_FIRST_PASS"
local TOGGLE_DROPDOWN_MENU_LEVEL_1_RECHECK = "BAGSHUI_TOGGLE_DROPDOWN_MENU_LEVEL_1_RECHECK"
local TOGGLE_DROPDOWN_MENU_SECOND_PASS = "BAGSHUI_TOGGLE_DROPDOWN_MENU_THIRD_PASS"


--- Fun hack time!
--- 1.12's ToggleDropDownMenu doesn't accurately correct for menus going off the edge of the 
--- screen due to some apparent weirdness with frame GetRight/Bottom() vs GetScreenWidth/Height(),
--- so I guess we'll do it. The basic technique comes from EngInventory -- thanks to whoever figured this out!
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
---@param level number Menu level parameter for the original `ToggleDropDownMenu()`.
---@param value any Menu value parameter for the original `ToggleDropDownMenu()`.
---@param dropDownFrame table Parameter for the original `ToggleDropDownMenu()`.
---@param anchorName string? Parameter for the original `ToggleDropDownMenu()`.
---@param xOffset number? Parameter for the original `ToggleDropDownMenu()`.
---@param yOffset number? Parameter for the original `ToggleDropDownMenu()`.
---@param bagshuiAdditionalPassReason string? When another pass needs to be made to re-check the menu's position, this extra parameter is added.
function Bagshui:ToggleDropDownMenu(wowApiFunctionName, level, value, dropDownFrame, anchorName, xOffset, yOffset, _, _, _, bagshuiAdditionalPassReason)
	-- Record whether we're in one of the additional passes.
	local phase = 0
	if bagshuiAdditionalPassReason == TOGGLE_DROPDOWN_MENU_FIRST_PASS then
		phase = 1
	elseif bagshuiAdditionalPassReason == TOGGLE_DROPDOWN_MENU_LEVEL_1_RECHECK then
		phase = 1.5
	elseif bagshuiAdditionalPassReason == TOGGLE_DROPDOWN_MENU_SECOND_PASS then
		phase = 2
	end

	-- Let Blizzard code open the menu on first pass.
	-- Additional passes must avoid calling this or the menu will be closed.
	-- Calling on an additional pass can also trigger errors because the meaning of `this` will have
	-- changed, and ToggleDropDownMenu() won't be able to populate its tempFrame variable.
	if phase == 0 then
		self.hooks:OriginalHook(wowApiFunctionName, level, value, dropDownFrame, anchorName, xOffset, yOffset)
		-- At one point there were crashes happening when right-clicking inventory windows to open the menu.
		-- It SEEMS like they were fixed by avoiding touching cursor-anchored menus during the level 1 checks.
		-- If there are still crashing issues reported, this may need to be enabled in lieu of the
		-- immediate call above. (It's not ideal, since there will be a flash of the menu in the wrong position.)
		-- Bagshui:QueueEvent(function()
		-- 	self:ToggleDropDownMenu(wowApiFunctionName, level, value, dropDownFrame, anchorName, xOffset, yOffset, nil, nil, nil, TOGGLE_DROPDOWN_MENU_FIRST_PASS)
		-- end)
		-- return
	end

	-- Don't mess with anyone else's menus.
	if not self:IsMenuOpen() then
		return
	end

	-- Track whether we need to make a second pass.
	local secondPassNeeded = false

	-- Find the open menu frame.
	local frame = _G["DropDownList" .. level]
	local parentFrame = _G["DropDownList" .. (level - 1)]
	if not frame or (level > 1 and not parentFrame) then
		return
	end

	-- Special stuff for top-level menus -- but not Settings, because
	-- Inventory:FixSettingsMenuPosition() takes care of that.
	if level == 1 then
		-- Blizzard's ToggleDropDownMenu() code always forces a TOPLEFT anchor when the menu doesn't go off the screen.
		-- We really don't want that, so we're going to re-anchor to the desired point if it was messed with.
		if
			anchorName ~= "cursor"  -- Game can crash if we mess with cursor-anchored menus.
			and phase < 1.5
			and not self.menuFrame.bagshuiData.noFirstLevelRepositionNeeded  -- The code opening the menu will take care of any positioning issues.
			and (frame:GetNumPoints() or 0) > 0
		then
			local point = frame:GetPoint(1)
			local correctedAnchorPoint, correctedAnchorToPoint

			if self.menuFrame.bagshuiData.anchorPoint ~= nil and point ~= nil and point ~= self.menuFrame.bagshuiData.anchorPoint then

				if point == "TOPLEFT" then
					-- Blizz's ToggleDropDownMenu() moved the menu to a TOPLEFT anchor and we didn't want that. Move it back.
					correctedAnchorPoint = self.menuFrame.bagshuiData.anchorPoint
					correctedAnchorToPoint = self.menuFrame.bagshuiData.anchorToPoint

				elseif
					string.find(self.menuFrame.bagshuiData.anchorPoint, "RIGHT$")
					and string.find(point, "LEFT$")
				then
					-- Blizz's ToggleDropDownMenu() moved the menu to a LEFT anchor due to it going offscreen,
					-- but we wanted a RIGHT anchor, so we'll move from bottom to top or vice-versa but keep the RIGHT anchoring.
					correctedAnchorPoint = BsUtil.FlipAnchorPointComponent(self.menuFrame.bagshuiData.anchorPoint, 1)
					correctedAnchorToPoint = BsUtil.FlipAnchorPointComponent(self.menuFrame.bagshuiData.anchorToPoint, 1)
				end
			end

			-- Need to apply the positioning fix.
			if correctedAnchorPoint and correctedAnchorToPoint then
				-- self:PrintDebug("!!! need to reposition from " .. point .. " to " .. correctedAnchorPoint)
				frame:ClearAllPoints()
				frame:SetPoint(correctedAnchorPoint, (self.menuFrame.bagshuiData.anchorToFrame or anchorName), correctedAnchorToPoint, xOffset, yOffset)
				-- We still need to do all the normal checks since this may move the frame off the screen.
				Bagshui:QueueEvent(function()
					self:ToggleDropDownMenu(wowApiFunctionName, level, value, dropDownFrame, anchorName, xOffset, yOffset, nil, nil, nil, TOGGLE_DROPDOWN_MENU_LEVEL_1_RECHECK)
				end)
				return
			end
		end

		-- Check level 1 to see if its right edge is past the horizontal halfway point, and if so, expand menus to the left.
		self._toggleDropDownMenu_ExpandMenusLeft = (frame:GetLeft() and ((frame:GetRight() * frame:GetScale()) > (_G.UIParent:GetRight() * _G.UIParent:GetScale()) / 2))
	end

	-- Figure out what adjustments are required.
	local adjustX = BsUtil.GetFrameOffscreenAmount(frame, "x")
	local adjustY = BsUtil.GetFrameOffscreenAmount(frame, "y")
	local fullMoveLeft = 0  -- Assume a flip to left-expansion is not necessary.

	-- Shift a submenu to the left of the parent if it's being X-adjusted by a negative amount or we're in left-expansion mode.
	if
		phase < 2
		and level > 1 -- Submenu
		and (
			adjustX < 0
			or self._toggleDropDownMenu_ExpandMenusLeft
		)
	then
		-- This check is needed to ensure we don't double-move a menu that Blizzard code has already moved to the left of the parent.
		if frame:GetLeft() * frame:GetScale() > parentFrame:GetLeft() * parentFrame:GetScale() then
			-- Move to the left of the parent menu.
			fullMoveLeft = -((parentFrame:GetWidth() * parentFrame:GetScale()) + (frame:GetWidth() * frame:GetScale())) + BsSkin.menuShiftLeft
			secondPassNeeded = true
		elseif adjustX == 0 then
			-- Submenu is already to the left, but let's fix Blizzard's weird mismatched extra space for left-expanding menus.
			adjustX = BsSkin.menuShiftLeftFix
		end
	end

	-- Tweak submenu position if the skin requires it.
	if
		level > 1
		and adjustX == 0
		and BsSkin.menuShiftRight ~= 0
	then
		adjustX = BsSkin.menuShiftRight
	end

	-- Special checks for level 1.
	if level == 1 then
		local mouseX, mouseY = _G.GetCursorPosition()

		-- Move menus to the other side of the cursor instead of just shifting them slightly.
		if anchorName == "cursor" and adjustX < 0 and mouseX < (frame:GetRight() * frame:GetScale()) then
			adjustX = -(frame:GetWidth() * frame:GetScale())
		end

		-- Open menus upwards when they're too close to the bottom right of the screen and could be covered by GameTooltip.
		if
			phase < 2
			and (frame:GetBottom() * frame:GetScale()) - (100 * _G.UIParent:GetScale()) < (_G.UIParent:GetBottom() * _G.UIParent:GetScale())
			and (frame:GetRight() * frame:GetScale()) > (_G.UIParent:GetRight() * _G.UIParent:GetScale()) - (300 * _G.UIParent:GetScale())
			and mouseY > (frame:GetBottom() * frame:GetScale())
		then
			-- It feels like this should be something like (frame:GetHeight() * frame:GetScale()) or even
			-- ((frame:GetHeight() * frame:GetScale()) / _G.UIParent:GetScale()), but that gives
			-- inconsistent results at different scales and this simpler solution seems to work so WHO CARES.
			adjustY = frame:GetHeight()
			-- When anchoring to another frame, move the menu above that frame.
			if anchorName ~= "cursor" and type(anchorName) == "table" and anchorName.GetParent then
				adjustY = adjustY + ((anchorName:GetHeight() or 0) * anchorName:GetScale()) + ((yOffset or 0) * -1)
			end
			-- Since we're flipping the menu upwards, a second pass is needed in case it goes off the top.
			secondPassNeeded = true
		end
	end


	-- Make adjustments by shifting the menu exactly the right amount.
	if adjustY ~= 0 or adjustX ~= 0 or fullMoveLeft ~= 0 then

		-- It's preferable to move menu level 2+ frames relative to their parent so they stay anchored
		-- correctly if the UI shifts around. However, WoW will crash on a blind call to GetPoint(1)
		-- if GetNumPoints() is 0, so we need just adjust against UIParent in that case.
		-- (Trying to do this with level 1 seems to be unreliable, so we'll force the use of UIParent for that.)
		if level > 1 and (frame:GetNumPoints() or 0) > 0 then

			-- Grab the menu's current anchor point
			local point, anchorToFrame, anchorToPoint, xOffset, yOffset = frame:GetPoint(1)

			-- Move to the left of the parent anchor frame
			if fullMoveLeft ~= 0 then
			   adjustX = -BsSkin.menuShiftLeft
			   point = BsUtil.FlipAnchorPointComponent(point, 2)  -- <TOP/BOTTOM>LEFT -> <TOP/BOTTOM>RIGHT
			   anchorToPoint = BsUtil.FlipAnchorPointComponent(anchorToPoint, 2)  -- <TOP/BOTTOM>LEFT -> <TOP/BOTTOM>RIGHT
			end

			-- Set new, adjusted point.
			frame:ClearAllPoints()
			frame:SetPoint(point, anchorToFrame, anchorToPoint, (xOffset or 0) + adjustX, (yOffset or 0) + adjustY)

		else
			-- No current parent frame (or level 1) -- just anchor to UIParent and adjust.
			adjustX = frame:GetLeft() + (fullMoveLeft ~= 0 and fullMoveLeft or adjustX)
			adjustY = frame:GetTop() + adjustY
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", _G.UIParent, "BOTTOMLEFT", adjustX, adjustY)
		end
	end

	-- Make a second check in case we accidentally shifted the menu offscreen when flipping it to the left.
	if phase < 2 and secondPassNeeded then
		Bagshui:QueueEvent(function()
			self:ToggleDropDownMenu(wowApiFunctionName, level, value, dropDownFrame, anchorName, xOffset, yOffset, nil, nil, nil, TOGGLE_DROPDOWN_MENU_SECOND_PASS)
		end)
	end

	-- Reset parameter.
	self.menuFrame.bagshuiData.noFirstLevelRepositionNeeded = nil
end



-- Another hack, albeit much more about vanity and not actually fixing anything.
-- Here, we're filling some missing functionality in `UIDropDownMenu_AddButton()`,
-- namely icon colors, position, and size. This function will set or reset values as appropriate.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
---@param menuItem table Menu entry.
---@param level number? Menu level.
function Bagshui:UIDropDownMenu_AddButton(wowApiFunctionName, menuItem, level)

	self.hooks:OriginalHook(wowApiFunctionName, menuItem, level)


	-- Grab info about current menu item.
	-- This is the same as what's done in UIDropDownMenu_AddButton(),
	-- but without incrementing numButtons to the next value.

	local listFrame = _G["DropDownList" .. (level or 1)]
	if not listFrame then
		return
	end
	local listFrameName = listFrame:GetName()
	if not listFrameName then
		return
	end
	local index = listFrame.numButtons
	if not index then
		return
	end
	local button = _G[listFrameName .. "Button" .. index]
	if not button then
		return
	end

	local xOffset

	-- Set/reset opacity.
	button:SetAlpha(menuItem._bagshuiAlpha or 1)

	-- Arrow adjustments.

	local expandArrow = _G[listFrameName.."Button"..index.."ExpandArrow"]
	if expandArrow then
		if not self._originalExpandArrowXOffset then
			_, _, _, self._originalExpandArrowXOffset = expandArrow:GetPoint(1)
		end

		-- Fix arrow position on notCheckable items so the arrow aligns with that of checkable items.

		xOffset = (menuItem._bagshui and menuItem.hasArrow and menuItem.notCheckable) and -10 or self._originalExpandArrowXOffset
		expandArrow:SetPoint("RIGHT", xOffset, 0)

		-- Hide if requested.
		if menuItem._bagshuiHideArrow then
			expandArrow:Hide()
		end
	end


	-- Icon adjustments.

	local icon = _G[button:GetName() .. "Icon"]
	if menuItem.icon and icon then

		-- Store original values if we don't yet know them.
		if not self._originalMenuIconSize then
			self._originalMenuIconSize = icon:GetWidth()
		end
		if not self._originalMenuIconXOffset then
			_, _, _, self._originalMenuIconXOffset = icon:GetPoint(1)
		end

		-- Icon colors.
		local r = menuItem._bagshuiTextureR or (menuItem._bagshui and BS_COLOR.YELLOW[1]) or 1
		local g = menuItem._bagshuiTextureG or (menuItem._bagshui and BS_COLOR.YELLOW[2]) or 1
		local b = menuItem._bagshuiTextureB or (menuItem._bagshui and BS_COLOR.YELLOW[3]) or 1
		local a = (menuItem._bagshui and menuItem.disabled and not menuItem.isTitle) and 0.5 or menuItem._bagshuiTextureA or 1
		icon:SetVertexColor(r, g, b, a)

		-- Icon size.
		local iconSize = menuItem._bagshuiTextureSize or (menuItem._bagshui and 12) or self._originalMenuIconSize
		icon:SetWidth(iconSize)
		icon:SetHeight(iconSize)

		-- Icon position.
		xOffset =
			menuItem._bagshuiTextureXOffset
			or (
				menuItem._bagshui
				and (
					(menuItem.hasArrow and not menuItem._bagshuiHideArrow) and (
						menuItem.notCheckable and -28 or -24
					)
					or menuItem._bagshuiFakeTitle and -14
					or menuItem.notCheckable and -16
				)
				or -12
			)
			or self._originalMenuIconXOffset
		icon:SetPoint("RIGHT", xOffset, 0)
	end


	-- Color Swatch + Arrow hack - hide the arrow.

	if menuItem.hasColorSwatch and menuItem.hasArrow and _G[button:GetName() .. "ExpandArrow"] then
		_G[button:GetName() .. "ExpandArrow"]:Hide()
	end


	-- Other Color Swatch stuff.

	local colorSwatch = _G[button:GetName() .. "ColorSwatch"]
	if menuItem.hasColorSwatch and colorSwatch then
		-- Inexplicably, Blizzard doesn't disable the swatch when the menu item is disabled.
		if menuItem.disabled then
			colorSwatch:Disable()
		else
			colorSwatch:Enable()
		end

		-- Color Swatch custom function hack.
		if menuItem._bagshuiColorSwatchFunc then
			-- Store the Blizzard OnClick function only once so we don't overwrite it with one of ours.
			if not colorSwatch._bagshuiOldOnClick then
				colorSwatch._bagshuiOldOnClick = colorSwatch:GetScript("OnClick")
			end
			colorSwatch:SetScript("OnClick", menuItem._bagshuiColorSwatchFunc)
		elseif colorSwatch._bagshuiOldOnClick then
			-- Restore the Blizzard OnClick.
			colorSwatch:SetScript("OnClick", colorSwatch._bagshuiOldOnClick)
			colorSwatch._bagshuiOldOnClick = nil
		end

		-- Color Swatch position hack.
		if menuItem._bagshuiColorSwatchRightAnchor then
			if not colorSwatch._bagshuiOldRightAnchor and colorSwatch:GetNumPoints() > 0 then
				_, _, _, colorSwatch._bagshuiOldRightAnchor, _ = colorSwatch:GetPoint(1)
			end
			colorSwatch:SetPoint("RIGHT", menuItem._bagshuiColorSwatchRightAnchor, 0)
		elseif colorSwatch._bagshuiOldRightAnchor then
			colorSwatch:SetPoint("RIGHT", colorSwatch._bagshuiOldRightAnchor, 0)
			menuItem._bagshuiOldRightAnchor = nil
		end
	end

end


end)