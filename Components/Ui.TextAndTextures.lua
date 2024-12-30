-- Bagshui UI Class: Textures and Fonts

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui



--- Show full label in tooltip when the text is wider than the frame.
function Ui._Label_OnEnter()
	local text =_G.this.bagshuiData.text
	local tooltip = _G.this.bagshuiData.tooltip
	if text:GetWidth() > _G.this:GetWidth() then
		tooltip:ClearLines()
		tooltip:SetOwner(_G.this, "ANCHOR_PRESERVE")
		local tooltipOffset = -text:GetHeight() * tooltip:GetScale()
		tooltip:SetPoint("BOTTOMLEFT", _G.this, "BOTTOMLEFT", tooltipOffset, tooltipOffset)
		tooltip:AddLine(text:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
		Bagshui:ShowTooltipAfterDelay(tooltip, _G.this, _G.this.bagshuiData.tooltipGroupFrame)
	end
end


--- Hide label tooltip.
function Ui._Label_OnLeave()
	local tooltip = _G.this.bagshuiData.tooltip
	if tooltip:IsOwned(_G.this) then
		Bagshui:ShortenTooltipDelay(_G.this, true)
		tooltip:Hide()
	end
end



--- Create a label that will display the full text in a tooltip when the label frame
--- isn't as wide as the text.
---@param parentFrame table Group frame.
---@param tooltipGroupFrame table Frame to use when tracking tooltip delay shortening.
---@param fontStyle string? Font to use.
---@param noColors boolean? Don't apply Inventory-class label coloring.
---@return table labelFrame Frame holding the label.
---@return table text FontString - the actual text.
function Ui:CreateLabel(parentFrame, tooltipGroupFrame, fontStyle, noColors)
	local ui = self

	-- Create frame and text.
	local labelFrame = _G.CreateFrame("Frame", nil, parentFrame)
	local text = labelFrame:CreateFontString(nil, nil, fontStyle or "GameFontNormalSmall")
	-- Add the properties that will be referenced by OnEnter.
	labelFrame.bagshuiData = {
		text = text,
		tooltip = (ui.tooltips and ui.tooltips.mini) or BsIconButtonTooltip,
		tooltipGroupFrame = tooltipGroupFrame or parentFrame,
		ui = ui,
	}

	labelFrame:Hide()
	labelFrame:EnableMouse(true)
	labelFrame:SetScript("OnEnter", self._Label_OnEnter)
	labelFrame:SetScript("OnLeave", self._Label_OnLeave)

	-- Hack up drag methods to pass to primary window so there aren't dead zones where the window can't be dragged.
	labelFrame:RegisterForDrag("LeftButton")
	ui:PassMouseEventsThrough(labelFrame, self:FindWindowFrame(parentFrame), true)

	-- Position and style text.
	text:SetPoint("LEFT", labelFrame, "LEFT", 1, 0)
	text:SetPoint("RIGHT", labelFrame, "RIGHT", -1, 0)
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	if not noColors then
		text:SetTextColor(BS_COLOR.WHITE[1], BS_COLOR.WHITE[2], BS_COLOR.WHITE[3], 0.8)
		text:SetShadowColor(0, 0, 0, 0.25)
		text:SetShadowOffset(0.25, -0.25)
	end
	text:SetText(" ")  -- Set to a space so we can measure the height during UpdateWindow().

	return labelFrame, text
end




--- Create a frame that holds both the texture and a desaturated version of the texture,
--- stacked appropriately to create a shadow effect. Manipulation of these textures
--- in the future can be done via SetShadowedTexture() and friends.
---@param parentFrame table
---@param texturePath string
---@param shadowOpacity number?
---@return table textureFrame
function Ui:CreateShadowedTexture(parentFrame, texturePath, shadowOpacity)
	texturePath = BsUtil.GetFullTexturePath(texturePath)
	shadowOpacity = shadowOpacity or 0.6

	local textureFrame = _G.CreateFrame("Frame", nil, parentFrame)
	textureFrame.bagshuiData = {
		shadowOpacity = shadowOpacity
	}

	-- Create normal texture.
	textureFrame.bagshuiData.texture = textureFrame:CreateTexture(nil, "OVERLAY")
	textureFrame.bagshuiData.texture:SetPoint("TOPLEFT", textureFrame, "TOPLEFT", 0, 0)
	textureFrame.bagshuiData.texture:SetPoint("BOTTOMRIGHT", textureFrame, "BOTTOMRIGHT", -1, 1)
	if texturePath then
		textureFrame.bagshuiData.texture:SetTexture(texturePath)
	end

	-- Create shadow texture.
	textureFrame.bagshuiData.shadow = textureFrame:CreateTexture(nil, "ARTWORK")
	textureFrame.bagshuiData.shadow:SetPoint("TOPLEFT", textureFrame, "TOPLEFT", 1, -1)
	textureFrame.bagshuiData.shadow:SetPoint("BOTTOMRIGHT", textureFrame, "BOTTOMRIGHT", 0, 0)
	if texturePath then
		textureFrame.bagshuiData.shadow:SetTexture(texturePath)
	end
	textureFrame.bagshuiData.shadow:SetBlendMode("MOD")
	textureFrame.bagshuiData.shadow:SetDesaturated(1)
	textureFrame.bagshuiData.shadow:SetVertexColor(0.5, 0.5, 0.5, shadowOpacity)

	return textureFrame
end



--- Change the texture of a shadowed texture created by `CreateShadowedTexture()`.
---@param textureFrame table
---@param texturePath string
function Ui:SetShadowedTexture(textureFrame, texturePath)
	if not texturePath then
		return
	end
	texturePath = BsUtil.GetFullTexturePath(texturePath)
	textureFrame.bagshuiData.texture:SetTexture(texturePath)
	textureFrame.bagshuiData.shadow:SetTexture(texturePath)
end



--- Change the texture coordinates of a shadowed texture created by `CreateShadowedTexture()`.
---@param textureFrame table
---@param left number
---@param right number
---@param top number
---@param bottom number
function Ui:SetShadowedTextureTexCoord(textureFrame, left, right, top, bottom)
	if not left or not right or not top or not bottom then
		return
	end
	textureFrame.bagshuiData.texture:SetTexCoord(left, right, top, bottom)
	textureFrame.bagshuiData.shadow:SetTexCoord(left, right, top, bottom)
end



--- Change the vertex color of a shadowed texture created by `CreateShadowedTexture()`.
--- Note that only the color of the texture itself is changed; the shadow just gets its opacity updated to match.
---@param textureFrame table
---@param red number
---@param green number
---@param blue number
---@param alpha number
function Ui:SetShadowedTextureVertexColor(textureFrame, red, green, blue, alpha)
	if not red or not green or not blue then
		return
	end
	textureFrame.bagshuiData.texture:SetVertexColor(red, green, blue, alpha)
	self:SetShadowedTextureShadowAlpha(textureFrame, alpha)
end



--- Change the opacity of a shadowed texture created by `CreateShadowedTexture()`.
---@param textureFrame table
---@param alpha number
function Ui:SetShadowedTextureAlpha(textureFrame, alpha)
	if not alpha then
		return
	end
	textureFrame.bagshuiData.texture:SetAlpha(alpha)
	self:SetShadowedTextureShadowAlpha(textureFrame, alpha)
end



--- Change the opacity of the shadow for of a shadowed texture created by `CreateShadowedTexture()`.
--- This is needed to handle the complexities of keeping things visually correct:
--- * When opacity is less than 1%, the shadow needs to be hidden so that the texture itself doesn't look weird.
--- * The shadow texture's opacity should never be allowed to go higher than what it was set to at creation.
---@param textureFrame table
---@param alpha number
function Ui:SetShadowedTextureShadowAlpha(textureFrame, alpha)
	alpha = alpha or 1
	if alpha < 0.1 then
		textureFrame.bagshuiData.shadow:Hide()
	else
		textureFrame.bagshuiData.shadow:SetAlpha(alpha < textureFrame.bagshuiData.shadowOpacity and alpha or textureFrame.bagshuiData.shadowOpacity)
		textureFrame.bagshuiData.shadow:Show()
	end
end



--- Create a lightly shadowed font string. Use the `:SetText()` method on the returned object to display text.
---@param parent table Parent frame.
---@param name string Name of the font string object.
---@param fontObject string|table? Font object or identifier string (defaults to GameFontHighlight).
---@return table fontString
function Ui:CreateShadowedFontString(parent, name, fontObject)
	local text = parent:CreateFontString(name, nil, fontObject or "GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetJustifyV("MIDDLE")
	text:SetShadowColor(0, 0, 0, 0.25)
	text:SetShadowOffset(0.25, -0.25)
	return text
end


end)