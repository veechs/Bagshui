-- Bagshui About Dialog
-- Exposes: BsAboutDialog (and Bagshui.components.AboutDialog)

Bagshui:AddComponent(function()

local About = {}
Bagshui.components.AboutDialog = About
Bagshui.environment.BsAboutDialog = About


--- Initialize the About dialog.
function About:InitUi()
	if self.uiFrame then
		return
	end

	self.uiFrame = Bagshui.prototypes.Ui:CreateWindowFrame("About", nil, 295, 140, "")

	local nextAnchor = self.uiFrame
	local nextAnchorToPoint = "TOPLEFT"
	local nextXOffset = 25
	local nextYOffset = -25

	local logoParts = {}

	-- The Bagshui logo is split into 4 parts to optimize the file sizes.
	for i, logoPart in pairs({"Ba", "gs", "hu", "i"}) do
		logoParts[i] = self.uiFrame:CreateTexture(nil, "ARTWORK")
		logoParts[i]:SetTexture(BsUtil.GetFullTexturePath("UI\\Logo_" .. logoPart))
		logoParts[i]:SetWidth(75)
		logoParts[i]:SetHeight(75)
		logoParts[i]:SetVertexColor(BS_COLOR.BAGSHUI_LOGO[1], BS_COLOR.BAGSHUI_LOGO[2], BS_COLOR.BAGSHUI_LOGO[3])
		logoParts[i]:SetPoint("TOPLEFT", nextAnchor, nextAnchorToPoint, nextXOffset, nextYOffset)
		nextAnchor = logoParts[i]
		nextAnchorToPoint = "TOPRIGHT"
		nextXOffset = 0
		nextYOffset = 0
	end

	local version = self.uiFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
	version:SetText(BS_FONT_COLOR.BAGSHUI .. BS_VERSION .. FONT_COLOR_CODE_CLOSE)
	version:SetJustifyH("RIGHT")
	version:SetPoint("TOPRIGHT", logoParts[4], "BOTTOMLEFT", 13, 17)

	local url = Bagshui.prototypes.Ui:CreateEditBox("AboutUrl", self.uiFrame, nil, nil, nil, true, true)
	url:SetText(BS_URL)
	url.bagshuiData.readOnlyText = BS_URL
	url:SetWidth(150)
	url:SetHeight(16)
	url:SetTextInsets(0, 0, 0, 0)
	url:SetAlpha(0.5)
	url:SetJustifyH("LEFT")
	url:SetPoint("TOPLEFT", logoParts[1], "BOTTOMLEFT", 0, -5)
	url:SetPoint("RIGHT", self.uiFrame, "RIGHT", -25, 0)
	local oldOnFocusGained = url:GetScript("OnEditFocusGained")
	url:SetScript("OnEditFocusGained", function()
		oldOnFocusGained()
		_G.this:SetAlpha(1)
	end)
	local oldOnFocusLost = url:GetScript("OnEditFocusLost")
	url:SetScript("OnEditFocusLost", function()
		oldOnFocusLost()
		_G.this:SetAlpha(0.5)
	end)

	-- Unfocus the URL when clicking outside it.
	self.uiFrame:SetScript("OnMouseUp", function()
		url:HighlightText(0, 0)
		url:ClearFocus()
	end)

end



--- Open the window.
function About:Open()
	self:InitUi()

	-- Move to center of screen and open.
	self:Close()
	if not self.uiFrame:IsVisible() then
		self.uiFrame:SetPoint("CENTER", 0, 0)
		self.uiFrame:Show()
	else
		self.uiFrame:Raise()
	end
end



--- Close the window.
function About:Close()
	if self.uiFrame then
		self.uiFrame:Hide()
	end
end


end)