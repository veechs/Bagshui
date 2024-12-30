-- Bagshui Scrollable Text Window
-- Exposes: Bagshui.prototypes.ScrollableTextWindow
--
-- Display an edit box that takes up an entire frame.

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui

local ScrollableTextWindow = {}
Ui.ScrollableTextWindow = ScrollableTextWindow
Bagshui.prototypes.ScrollableTextWindow = ScrollableTextWindow


--- Create a new ScrollableTextWindow instance.
---@param instanceProperties table List of properties for the new class instance. See `window` declaration below.
---@return table
function ScrollableTextWindow:New(instanceProperties)
	assert(instanceProperties.name, "ScrollableTextWindow:New() - instanceProperties.name is required")

	local window = {
		_super = ScrollableTextWindow,

		---@type string REQUIRED Unique name for the new class.
		name = "ScrollableTextWindow",

		---@type boolean The EditBox will be read-only.
		readOnly = false,

		---@type boolean The EditBox will highlight all text when focus is gained.
		selectAllOnFocus = true,

		---@type boolean Always scroll to the bottom of the EditBox when the window is opened.
		scrollToBottomOnShow = false,


		-- Internal properties.
		-- These could be underscore-prefixed or whatever, but it's not really
		-- worth it for this class.

		ui = nil,
		uiFrame = nil,
		scrollFrame = nil,
		editBox = nil,
	}

	-- Copy instance properties to final object.
	for key, value in pairs(instanceProperties) do
		window[key] = value
	end

	-- Set up the class object.
	setmetatable(window, self)
	self.__index = self
	return window

end



--- Set EditBox contents.
---@param text string
function ScrollableTextWindow:SetText(text)
	if not self.uiFrame then
		return
	end

	-- Add text to EditBox.
	if self.readOnly then
		-- Set readOnlyText property for fake read-only-ness.
		self.editBox.bagshuiData.readOnlyText = tostring(text)
	end
	self.editBox:ClearFocus()
	self.editBox:SetText(tostring(text))
	self.editBox:SetFocus()
end



--- Retrieve EditBox contents.
---@return string
function ScrollableTextWindow:GetText(text)
	if not self.uiFrame then
		return ""
	end
	return self.editBox:GetText()
end



--- Initialize the UI.
function ScrollableTextWindow:InitUi()
	-- Things can get messed up if we do this more than once.
	if self.uiFrame then
		return
	end

	-- Create UI class instance.
	self.ui = Bagshui.prototypes.Ui:New(self.name)

	-- Create window with EditBox.
	self.uiFrame, self.scrollFrame, self.editBox = self.ui:CreateScrollableEditBoxWindow(
		"uiFrame",  -- name
		nil,  -- parent
		self.width,
		self.height,
		self.title,  -- title
		nil,  -- noCloseOnEscape
		self.fontObject,
		self.selectAllOnFocus
	)

	self.uiHeader = self.uiFrame.bagshuiData.header
	self.uiTitle = self.uiFrame.bagshuiData.title
end




--- Display the window.
---@param text string Text to place in the EditBox.
---@return boolean? willOpen false if the window won't open due to missing parameters.
function ScrollableTextWindow:Open(text)
	-- Nothing to do.
	if not text then
		return false
	end

	self:InitUi()

	-- Ensure it's closed (this will bring it to the front if already open).
	self:Close()

	-- Add text to EditBox.
	self:SetText(text)

	-- Reset scrolling.
	self.scrollFrame:UpdateScrollChildRect()

	-- Scroll to top.
	if not self.editBox.bagshuiData.scrollToBottomOnTextSet then
		self.scrollFrame:SetVerticalScroll(0)
	end

	-- Move to center of screen and open.
	if self.uiFrame:IsVisible() then
		self.uiFrame:Raise()
	else
		self.uiFrame:SetMovable(true)
		self.uiFrame:ClearAllPoints()
		self.uiFrame:SetPoint("CENTER", 0, 0)
		self.uiFrame:Show()
	end

	return true
end



-- Close the window.
function ScrollableTextWindow:Close()
	if self.uiFrame then
		self.uiFrame:Hide()
	end
end


end)