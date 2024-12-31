-- Bagshui UI Class: Buttons

Bagshui:AddComponent(function()

-- Scaling for the custom IconButton cooldown shine.
local ICON_BUTTON_SHINE_SCALE = 3

local Ui = Bagshui.prototypes.Ui


--- Create a standard button.
---@param name string Unique name for the button (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param buttonText string Text to display.
---@param onClick function Click handler.
---@return table button
function Ui:CreateButton(name, parent, buttonText, onClick)

	local elementName = self:CreateElementName(name)

	local element = _G.CreateFrame(
		"Button",
		elementName,
		parent,
		"UIPanelButtonTemplate"
	)

	element:SetText(buttonText or "")

	local buttonTextObject = _G[elementName .. "Text"]
	element:SetWidth(buttonTextObject:GetWidth() + 20)
	element:SetHeight(buttonTextObject:GetHeight() + 10)

	if onClick then
		element:SetScript("OnClick", onClick)
	end

	if type(BsSkin.buttonSkinFunc) == "function" then
		BsSkin.buttonSkinFunc(element)
	end

	return element

end



--- Create a checkbox (or "CheckButton" as Blizzard likes to call them).
---@param name string Unique name for the button (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param template string? XML template to use.
---@param buttonText string Text to display.
---@param onClick function Click handler.
---@param width number? Initial width.
---@param height number? Initial height.
---@return table button
function Ui:CreateCheckbox(name, parent, template, buttonText, onClick, width, height)

	local elementName = self:CreateElementName(name)
	template = template or "UIOptionsCheckButtonTemplate"

	local element = _G.CreateFrame(
		"CheckButton",
		elementName,
		parent,
		template
	)

	element.bagshuiData = {
		text = _G[elementName .. "Text"],
		padding = 0,
	}

	if element.bagshuiData.text then
		-- Why is the text so close to the checkbox in the Blizzard templates?
		if string.find(template, "UI.-CheckButtonTemplate") then
			element.bagshuiData.text:SetPoint("LEFT", element, "RIGHT", 0, 0)
		end

		if buttonText then
			element.bagshuiData.text:SetText(buttonText)
		else
			element.bagshuiData.text:Hide()
		end
	end

	if onClick then
		element:SetScript("OnClick", onClick)
	end

	if type(BsSkin.checkboxSkinFunc) == "function" then
		BsSkin.checkboxSkinFunc(element)
	end

	element:SetHeight(height or 20)
	element:SetWidth(width or 20)

	return element

end



--- Create a button with an attached drop-down menu.
---@param name string Unique name for the button (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param width number
---@param menusInstance table Bagshui `Menus` class instance.
---@param menuType string Identifier of the menu to display in the drop-down.
---@param openFuncArg2 any 2nd parameter for the OpenMenu callback of `menuType`.
---@return table dropDownMenuButton
function Ui:CreateDropDownMenuButton(name, parent, width, menusInstance, menuType, openFuncArg2)

	local dropDownName = self:CreateElementName(name)

	local dropDown = _G.CreateFrame(
		"Frame",
		dropDownName,
		parent,
		"UIDropDownMenuTemplate"
	)
	dropDown.bagshuiData = {}

	-- Hide textures that we don't want to display.
	_G[dropDownName .. "Left"]:Hide()
	_G[dropDownName .. "Middle"]:Hide()
	_G[dropDownName .. "Right"]:Hide()

	-- Style to match other Bagshui widgets.
	self:SetFrameBackdropAndBorderForEditWidgets(dropDown, "SOLID")

	-- Text will be updated when an item is selected, but we need a non-empty string
	-- to be able to size the widget.
	local dropDownText = _G[dropDownName .. "Text"]
	dropDownText:SetText("")
	dropDown:SetWidth(width)
	dropDown:SetHeight(dropDownText:GetHeight() + 10)

	-- Fix drop-down button and text positions so they look right.
	local button = _G[dropDownName .. "Button"]
	button:ClearAllPoints()
	button:SetPoint("RIGHT", dropDown, "RIGHT", 5, 0)
	dropDownText:ClearAllPoints()
	dropDownText:SetPoint("LEFT", dropDown, "LEFT", 5, 0)
	dropDownText:SetJustifyH("LEFT")

	-- Skin it.
	if type(BsSkin.dropdownSkinFunc) == "function" then
		BsSkin.dropdownSkinFunc(dropDown)
	end

	-- Add OnClick handler to show the drop-down.
	local buttonOldOnClick = button:GetScript("OnClick")
	button:SetScript("OnClick", function()
		local dropDown = _G.this:GetParent()
		-- We'll need this after calling the original OnClick.
		local originalParentHeight = dropDown:GetHeight()

		-- Manually perform the OpenMenu callback that the Menus class would normally do.
		if menusInstance.menuList[menuType] and menusInstance.menuList[menuType].openFunc then
			menusInstance.menuList[menuType].openFunc(menusInstance.menuList[menuType], dropDown, openFuncArg2)
		end

		-- ToggleDropDownMenu().
		buttonOldOnClick()

		-- Reset to reset height because ToggleDropDownMenu's call to UIDropDownMenu_Initialize changes it.
		dropDown:SetHeight(originalParentHeight)

		-- Fix menu positioning -- it's normally off by the amount by which the height had to be adjusted.
		local menuFrame = _G.DropDownList1
		if menuFrame:IsVisible() then
			menuFrame:ClearAllPoints()
			menuFrame:SetPoint("TOPLEFT", dropDown, "BOTTOMLEFT", -3, 3)
		end
	end)


	--- Special considerations to make the menu display correctly.
	---@param dropDownWidget any
	local function dropDownMenuPrep(dropDownWidget)
		local this = dropDownWidget or _G.this
		local originalHeight = this:GetHeight()

		-- This would normally be handled by `Menus:OpenMenu()` but we need to set it up directly.
		_G.UIDropDownMenu_Initialize(
			this,
			function(level)
				menusInstance:LoadMenu(menuType, level)
			end
		)

		-- Clear the selection. Blizzard code won't behave properly unless we do this.
		_G.UIDropDownMenu_SetSelectedID(this, nil, 1)

		-- Keep the menu width the same as the button.
		_G.UIDropDownMenu_SetWidth(width, this)

		-- UIDropDownMenu_Initialize messes with the height so let's reset it.
		this:SetHeight(originalHeight)
	end

	dropDown:SetScript("OnShow", dropDownMenuPrep)

	-- Call prep once to make sure everything is in order.
	dropDownMenuPrep(dropDown)

	return dropDown
end



--- Create an icon button with the specified texture.
--- There are a bunch of optional parameters so it's easier to pass a table.
--- See the `assert()`s  for which keys are mandatory.
--- ```
--- {
--- 	name = "InternalButtonName",
--- 	namePrefix = "ToolbarButton",
--- 	parentFrame = <frame object or name string>,
--- 	anchorToFrame = <frame object or name string>,
--- 	xOffset = -10,
--- 	yOffset = 0,
--- 	width = 14,
--- 	height = 14,
--- 	disable = true,
--- 	onClick = function()
--- 		-- OnClick action
--- 	end,
--- 	texture = "TextureName", -- If only a name is provided it will be prefixed with the addon <textureFolder>\ folder path
--- 	textureDir = "Toolbar",
--- 	texCoord = { 0, 0, 0, 0 },
--- 	tooltipTitle = "Text for first line of tooltip",
--- 	tooltipText = "Text with additional tooltip information",
--- 	tooltipAnchor = "valid anchor parameter for SetOwner()",
--- 	tooltipAnchorPoint = "valid anchor point", -- Only used if tooltipAnchor is ANCHOR_NONE or ANCHOR_PRESERVE
--- 	tooltipAnchorToPoint = "valid anchor point", -- Only used if tooltipAnchor is ANCHOR_NONE or ANCHOR_PRESERVE
--- }
--- ```
---comment
---@param buttonOpts table
---@return table button
function Ui:CreateIconButton(buttonOpts)
	assert(type(buttonOpts) == "table", "CreateIconButton() parameter must be a table")
	assert(buttonOpts.name, "name property is missing")
	assert(buttonOpts.texture, "texture property is missing")

	-- Create button.
	local button = _G.CreateFrame(
		"Button",
		self:CreateElementName((buttonOpts.namePrefix or "button") .. buttonOpts.name),
		buttonOpts.parentFrame
	)

	-- Change frame level.
	if buttonOpts.frameLevelChange then
		button:SetFrameLevel(button:GetFrameLevel() + buttonOpts.frameLevelChange)
	end

	-- Make the button target bigger.
	button:SetHitRectInsets(-4, -4, -4, -4)

	-- Set Texture.
	self:SetIconButtonTexture(
		button,
		(
			(string.find(buttonOpts.texture, "\\"))
			and buttonOpts.texture
			or (buttonOpts.textureDir or "Icons") .. "\\" .. buttonOpts.texture
		),
		buttonOpts.vertexColor,
		buttonOpts.hoverVertexColor
	)

	-- Initialize Bagshui info table.
	button.bagshuiData = {
		xOffset = buttonOpts.xOffset or -6,
		yOffset = buttonOpts.yOffset or 0,
		tooltipTitle = buttonOpts.tooltipTitle,
		tooltipText = buttonOpts.tooltipText,
		tooltipAnchor = buttonOpts.tooltipAnchor or "ANCHOR_TOPLEFT",
		tooltipAnchorPoint = buttonOpts.tooltipAnchorPoint,
		tooltipAnchorToPoint = buttonOpts.tooltipAnchorToPoint,
		tooltipXOffset = buttonOpts.tooltipXOffset or 0,
		tooltipYOffset = buttonOpts.tooltipYOffset or 0,
		tooltipFunction = buttonOpts.tooltipFunction,
		tooltipGroupElement = buttonOpts.tooltipGroupElement,
		tooltipDelay = buttonOpts.tooltipDelay,
		noTooltipDelay = buttonOpts.noTooltipDelay,
		noTooltipDelayShorting = buttonOpts.noTooltipDelayShorting,
		tooltipTextDelay = buttonOpts.tooltipTextDelay or BS_TOOLTIP_DELAY_SECONDS.DEFAULT,
		noTooltipTextDelay = buttonOpts.noTooltipTextDelay,
		highlightTexture = button:GetHighlightTexture(),
	}

	-- Pushed texture should shift down slightly.
	local pushedTexture = button:GetPushedTexture()
	if pushedTexture then
		pushedTexture:ClearAllPoints()
		pushedTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -0.5)
		pushedTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, -0.5)
	end

	-- Dimensions.
	local buttonWidth = buttonOpts.width or 14
	button:SetWidth(buttonWidth)
	button:SetHeight(buttonOpts.height or buttonWidth)

	-- Position.
	button:SetPoint(
		buttonOpts.anchorPoint or "RIGHT",
		buttonOpts.anchorToFrame or buttonOpts.parentFrame,
		buttonOpts.anchorToPoint or "LEFT",
		button.bagshuiData.xOffset,
		button.bagshuiData.yOffset
	)

	-- Tooltip management.
	if buttonOpts.tooltipTitle or buttonOpts.tooltipFunction then
		-- Allow tooltip delays to be handled per-button.
		if buttonOpts.independentTooltipDelay then
			buttonOpts.tooltipGroupElement = button
		end

		button:SetScript("OnEnter", function()
			_G.this.bagshuiData.mouseIsOver = true
			self:ShowIconButtonTooltip(_G.this)
		end)

		button:SetScript("OnLeave", function()
			_G.this.bagshuiData.mouseIsOver = false
			if BsIconButtonTooltip:IsOwned(_G.this) then
				Bagshui:ShortenTooltipDelay(_G.this, true)
				BsIconButtonTooltip:Hide()
			end
			_G.this.bagshuiData.keepTooltipVisible = nil
		end)
	end

	-- Set click action.
	if buttonOpts.onClick then
		-- Capture onClick function so table reuse doesn't bite us.
		local onClick = buttonOpts.onClick
		local onClickBeforeCloseMenusAndClearFocuses = buttonOpts.onClickBeforeCloseMenusAndClearFocuses
		button:SetScript("OnClick", function()
			if onClickBeforeCloseMenusAndClearFocuses then
				onClickBeforeCloseMenusAndClearFocuses()
			end
			self:CloseMenusAndClearFocuses(true, true, false)
			onClick()
		end)
		-- Shift/unshift HighlightTexture to match pushed/normal texture on mousedown/mouseup.
		button:SetScript("OnMouseDown", function()
			if not _G.this.bagshuiData.highlightTexture then
				_G.this.bagshuiData.highlightTexture = _G.this:GetHighlightTexture()
			end
			_G.this.bagshuiData.highlightTexture:ClearAllPoints()
			_G.this.bagshuiData.highlightTexture:SetPoint("TOPLEFT", _G.this, "TOPLEFT", 0, -0.5)
			_G.this.bagshuiData.highlightTexture:SetPoint("BOTTOMRIGHT", _G.this, "BOTTOMRIGHT", 0, -0.5)
		end)
		button:SetScript("OnMouseUp", function()
			_G.this.bagshuiData.highlightTexture:ClearAllPoints()
			_G.this.bagshuiData.highlightTexture:SetAllPoints(_G.this)
		end)
	end
	if buttonOpts.mouseButtons then
		button:RegisterForClicks(unpack(BsUtil.Split(buttonOpts.mouseButtons, ",")))
	else
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	end

	-- Set up other scripts.
	if buttonOpts.onEnter then
		button:SetScript("OnEnter", buttonOpts.onEnter)
	end
	if buttonOpts.onLeave then
		button:SetScript("OnLeave", buttonOpts.onLeave)
	end

	if buttonOpts.onShow then
		button:SetScript("OnShow", buttonOpts.onShow)
	end
	if buttonOpts.onHide then
		button:SetScript("OnHide", buttonOpts.onHide)
	end

	button:SetScript("OnUpdate", function()
		if _G.this.bagshuiData and _G.this.bagshuiData.isOnCooldown then
			self:UpdateIconButtonCooldown(_G.this)
		end
		if buttonOpts.onUpdate then
			buttonOpts.onUpdate()
		end
	end)

	-- Disable if requested.
	if buttonOpts.disable then
		button:Disable()
	end

	return button
end



--- Set icon button (toolbar buttons, etc) texture.
---@param button table Return value from `Ui:CreateIconButton()`.
---@param texturePath string?
---@param vertexColor number?[] { r, g, b, [a] }
---@param hoverVertexColor number?[] { r, g, b, [a] }
function Ui:SetIconButtonTexture(button, texturePath, vertexColor, hoverVertexColor)
	texturePath = texturePath and BsUtil.GetFullTexturePath(texturePath) or nil

	-- Set all the button textures to the same thing.
	for _, textureName in ipairs(BS_UI_BUTTON_TEXTURES) do
		button["Set" .. textureName .. "Texture"](button, texturePath)
	end

	self:SetIconButtonColors(button, vertexColor, hoverVertexColor)
end



--- Set icon button (toolbar buttons, etc) texture.
---@param button table Return value from `Ui:CreateIconButton()`.
---@param vertexColor number?[] { r, g, b, [a] }
---@param hoverVertexColor number?[] { r, g, b, [a] }
function Ui:SetIconButtonColors(button, vertexColor, hoverVertexColor)
	assert(type(button) == "table" and button.GetNormalTexture, "Ui:SetIconButtonColor() - button does not appear to be a WoW UI button")
	vertexColor =
		vertexColor
		or (self.inventory and self.inventory.settings and self.inventory.settings.toolbarButtonColor)
		or BS_COLOR.YELLOW
	hoverVertexColor = hoverVertexColor or BS_COLOR.ICON_BUTTON_HOVER

	-- Ensure color changes are allowed and texture was set successfully before attempting any manipulation.
	if
		(button.bagshuiData and button.bagshuiData.noRecolor)
		or not button:GetNormalTexture()
		or not button:GetDisabledTexture()
	then
		return
	end

	-- Need RGB to auto-calculate pushed color.

	local r = vertexColor[1]
	local g = vertexColor[2]
	local b = vertexColor[3]

	button:GetNormalTexture():SetVertexColor(
		r, g, b,
		(
			-- NormalTexture should be faded while the cooldown is active since
			-- the cooldown takes on its opacity.
			(button.bagshuiData and button.bagshuiData.isOnCooldown)
			and 0.4
			or vertexColor[4]
			or 1
		)
	)

	-- Keep cooldown colored the same as NormalTexture and inherit its expected opacity.
	if button.bagshuiData and button.bagshuiData.cooldownTexture then
		button.bagshuiData.cooldownTexture:SetVertexColor(
			r, g, b,
			(button.bagshuiData.isOnCooldown and (vertexColor[4] or 1) or 0)
		)
	end

	button:GetHighlightTexture():SetVertexColor(
		hoverVertexColor[1],
		hoverVertexColor[2],
		hoverVertexColor[3],
		hoverVertexColor[4] or BS_COLOR.ICON_BUTTON_HOVER[4]
	)

	button:GetPushedTexture():SetVertexColor(r - 0.1, g - 0.1, b - 0.1)
	button:GetPushedTexture():SetBlendMode("BLEND")

	button:GetDisabledTexture():SetVertexColor(r, g, b, 0.4)
end



--- Start the custom cooldown animation that fills the icon from bottom to top.
---@param button table Return value from `Ui:CreateIconButton()`.
function Ui:SetIconButtonCooldown(button, cooldownStart, cooldownDuration, isOnCooldown)
	if not button.bagshuiData then
		return
	end

	-- Create cooldown texture if not yet added.
	if not button.bagshuiData.cooldownTexture then
		local normalTexture = button:GetNormalTexture()
		button.bagshuiData.cooldownTexture = button:CreateTexture(nil, "OVERLAY")
		button.bagshuiData.cooldownTexture:SetTexture(normalTexture:GetTexture())
		-- Cooldown will be scaled upwards from the bottom.
		button.bagshuiData.cooldownTexture:SetPoint("TOP", button, button:GetHeight())
		button.bagshuiData.cooldownTexture:SetPoint("RIGHT", button, "RIGHT")
		button.bagshuiData.cooldownTexture:SetPoint("BOTTOM", button, "BOTTOM")
		button.bagshuiData.cooldownTexture:SetPoint("LEFT", button, "LEFT")
		local r, g, b, a = normalTexture:GetVertexColor()
		button.bagshuiData.cooldownTexture:SetVertexColor(r, g, b, a)
		button.bagshuiData.cooldownTexture:Hide()
	end

	-- Set appropriate properties to trigger cooldown animation in `UpdateIconButtonCooldown()`.
	-- Will make the call; no need to do it here.

	button.bagshuiData.cooldownStart = nil
	button.bagshuiData.cooldownDuration = nil
	button.bagshuiData.isOnCooldown = false
	if ( cooldownStart > 0 and cooldownDuration > 0 and isOnCooldown > 0) then
		button.bagshuiData.cooldownStart = cooldownStart
		button.bagshuiData.cooldownDuration = cooldownDuration
		button.bagshuiData.isOnCooldown = true
	end

end



--- Custom cooldown animation. Scales a cropped version of NormalTexture from
--- bottom to top while the actual NormalTexture is faded. This gives the appearance
--- of the icon filling up.
--- Called from the IconButton's `OnUpdate` script.
---@param button table Return value from `Ui:CreateIconButton()`.
function Ui:UpdateIconButtonCooldown(button)
	-- This isn't a Bagshui button.
	if not button.bagshuiData then
		return
	end

	-- Hide cooldown when button is disabled or it's not on cooldown.
	if
		button.bagshuiData
		and button.bagshuiData.cooldownTexture
		and button.bagshuiData.cooldownTexture:IsVisible()
		and not (
			button:IsEnabled()
			or button.bagshuiData.isOnCooldown
		)
	then
		button.bagshuiData.cooldownTexture:Hide()
		return
	end

	-- There's no need to update on every frame.
	if _G.GetTime() - (button.bagshuiData.lastCooldownUpdate or 0) < 0.5 then
		return
	end

	-- Cooldown time remaining.
	button.bagshuiData.cooldownRemaining =
		button.bagshuiData.cooldownDuration - (_G.GetTime() - button.bagshuiData.cooldownStart)

	if button.bagshuiData.cooldownRemaining <= 0 then
		-- Cooldown is done.
		button.bagshuiData.isOnCooldown = false
		button.bagshuiData.cooldownRemaining = nil
		button.bagshuiData.cooldownPercentRemaining = nil
		button.bagshuiData.cooldownTexture:Hide()

		if not _G.this.bagshuiData.shineFrame or not _G.this.bagshuiData.shineFrame:IsVisible() then
			self:ShineIconButton(button)
		end
	else
		button.bagshuiData.isOnCooldown = true
		-- Scale the cooldown texture vertically to match the remaining percentage.
		button.bagshuiData.cooldownPercentRemaining = button.bagshuiData.cooldownRemaining / button.bagshuiData.cooldownDuration
		button.bagshuiData.cooldownTexture:SetTexCoord(0, 1, button.bagshuiData.cooldownPercentRemaining, 1)
		button.bagshuiData.cooldownTexture:SetPoint("TOP", button, "BOTTOM", 0, (button:GetHeight() * (1 - button.bagshuiData.cooldownPercentRemaining)))
		button.bagshuiData.cooldownTexture:Show()
	end

	-- Set appropriate opacities for NormalTexture and cooldown.
	self:SetIconButtonColors(button)

	button.bagshuiData.lastCooldownUpdate = _G.GetTime()
end



-- Variable for use in OnUpdate to avoid GC.
local iconButton_ShineFrame_OnUpdate_alpha

--- Shrink and fade the "cooldown finished" shine, eventually hiding it once the animation is done.
--- Credit: https://github.com/anzz1/OmniCC/blob/master/OmniCC.lua
local function IconButton_ShineFrame_OnUpdate()
	-- Control animation speed.
	if _G.GetTime() - (_G.this.bagshuiData.lastShineUpdate or 0) < 0.1 then
		return
	end

	iconButton_ShineFrame_OnUpdate_alpha = _G.this.bagshuiData.shine:GetAlpha()
	_G.this.bagshuiData.shine:SetAlpha(iconButton_ShineFrame_OnUpdate_alpha * 0.95)

	if iconButton_ShineFrame_OnUpdate_alpha < 0.1 then
		-- Animation is done, so hide the shine.
		_G.this:Hide()
	else
		-- Shrink the shine as the alpha value decreases.
		_G.this.bagshuiData.shine:SetHeight(iconButton_ShineFrame_OnUpdate_alpha * _G.this:GetHeight() * ICON_BUTTON_SHINE_SCALE)
		_G.this.bagshuiData.shine:SetWidth(iconButton_ShineFrame_OnUpdate_alpha * _G.this:GetWidth() * ICON_BUTTON_SHINE_SCALE)
		_G.this.bagshuiData.lastShineUpdate = _G.GetTime()
	end
end



---	Show a shine animation over an IconButton.
--- Credit: https://github.com/anzz1/OmniCC/blob/master/OmniCC.lua
---@param button table Return value from `Ui:CreateIconButton()`.
function Ui:ShineIconButton(button)
	if not button.bagshuiData then
		return
	end

	-- Create shine texture.
	if not button.bagshuiData.shineFrame then
		button.bagshuiData.shineFrame = _G.CreateFrame("Frame", nil, button)
		button.bagshuiData.shineFrame:SetAllPoints(button)
		button.bagshuiData.shineFrame:Hide()
		button.bagshuiData.shineFrame.bagshuiData = {}

		local shine = button.bagshuiData.shineFrame:CreateTexture(nil, "OVERLAY")
		shine:SetTexture("Interface\\Cooldown\\star4")
		shine:SetPoint("CENTER", button.bagshuiData.shineFrame, "CENTER")
		shine:SetBlendMode("ADD")
		button.bagshuiData.shineFrame.bagshuiData.shine = shine

		button.bagshuiData.shineFrame:SetScript("OnUpdate", IconButton_ShineFrame_OnUpdate)

	end

	-- Initial shine size and opacity.
	button.bagshuiData.shineFrame.bagshuiData.shine:SetAlpha(math.min(button:GetAlpha(), 0.75))
	button.bagshuiData.shineFrame.bagshuiData.shine:SetHeight(button.bagshuiData.shineFrame:GetHeight() * ICON_BUTTON_SHINE_SCALE)
	button.bagshuiData.shineFrame.bagshuiData.shine:SetWidth(button.bagshuiData.shineFrame:GetWidth() * ICON_BUTTON_SHINE_SCALE)

	-- OnUpdate will fade and shrink the shine.
	button.bagshuiData.shineFrame:Show()
end



--- Display the tooltip for an icon button, taking into consideration the configured
--- anchoring, delay, callback, etc.
---@param button table Bagshui icon button from `Ui:CreateIconButton()`.
---@param tooltipDelayOverride number? Delay tooltip display by this many seconds. If the button has `tooltipDelay` set to 0s or if `noTooltipDelay` is true, the delay will be forced to 0, regardless of this parameter's value.
---@param secondPass boolean? 
function Ui:ShowIconButtonTooltip(button, tooltipDelayOverride, secondPass)

	-- Avoid incorrectly showing the tooltip if the mouse has moved off the button
	-- before the delay period expires.
	if secondPass and not button.bagshuiData.mouseIsOver then
		return
	end

	local bagshuiInfo = button.bagshuiData
	local tooltip = BsIconButtonTooltip

	tooltip:SetOwner(button, bagshuiInfo.tooltipAnchor)

	-- Nonstandard anchor location.
	if
		(bagshuiInfo.tooltipAnchor == "ANCHOR_NONE" or bagshuiInfo.tooltipAnchor == "ANCHOR_PRESERVE")
		and bagshuiInfo.tooltipAnchorPoint
		and bagshuiInfo.tooltipAnchorToPoint
	then
		tooltip:ClearAllPoints()
		tooltip:SetPoint(
			bagshuiInfo.tooltipAnchorPoint,
			button,
			bagshuiInfo.tooltipAnchorToPoint,
			bagshuiInfo.tooltipXOffset,
			bagshuiInfo.tooltipYOffset
		)
	end

	tooltip:ClearLines()

	if bagshuiInfo.tooltipFunction then
		-- When a tooltipFunction is configured, it should handle adding all tooltip content.
		-- This isn't currently used.
		bagshuiInfo.tooltipFunction(button, tooltip)
	else
		-- Normal behavior.

		tooltip:AddLine(bagshuiInfo.tooltipTitle, 1.0, 1.0, 1.0)

		if
			bagshuiInfo.tooltipText
			and (
				-- Add tooltip text if there's no delay.
				bagshuiInfo.noTooltipTextDelay
				-- Add tooltip text if there was a delay and the delay period has expired.
				or (
					bagshuiInfo.tooltipTextDelay
					and secondPass
				)
			)
		then
			tooltip:AddLine(bagshuiInfo.tooltipText, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
		end

		-- Ensure line wrapping keeps the tooltip as narrow as is allowed.
		tooltip:SetWidth(10)
	end

	-- Don't allow the override delay to make tooltips take longer to display if that's not desired.
	if bagshuiInfo.tooltipDelay == 0 or bagshuiInfo.noTooltipDelay then
		tooltipDelayOverride = 0
	end

	-- Actually show the tooltip.
	Bagshui:ShowTooltipAfterDelay(
		tooltip,
		button,
		bagshuiInfo.tooltipGroupElement,
		(tooltipDelayOverride or button.tooltipDelay or BS_TOOLTIP_DELAY_SECONDS.TOOLBAR_DEFAULT),
		button.noTooltipDelayShorting,
		function()
			-- This will add tooltip text after the additional tooltipTextDelay
			-- by calling `ShowIconButtonTooltip()` a second time.
			if bagshuiInfo.tooltipTextDelay and not secondPass then
				Bagshui:QueueClassCallback(
					self,
					self.ShowIconButtonTooltip,
					bagshuiInfo.tooltipTextDelay,
					false,
					button,
					0,  -- tooltipDelayOverride
					true  -- secondPass
				)
			end
		end
	)
end


end)