-- Bagshui Log Window
-- Exposes: BsLogWindow (and Bagshui.components.LogWindow)
--
-- Display Bagshui errors in a scrollable window.

Bagshui:AddComponent(function()


-- Initialize component.
local LogWindow = Bagshui.prototypes.ScrollableTextWindow:New({
	name = "Log",
	readOnly = true,
	title = L.LogWindowTitle,
	width = 600,
	height = 400,
	selectAllOnFocus = false,

	-- Used in OnEvent when receiving BAGSHUI_LOG_UPDATE events.
	allowUpdates = true,
})
Bagshui.components.LogWindow = LogWindow
Bagshui.environment.BsLogWindow = LogWindow



--- Open the Bagshui log window.
function LogWindow:Open()
	self._super.Open(self, Bagshui:GetLogText())
end



--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function LogWindow:OnEvent(event, arg1)
	-- During update, set allowUpdates to false to prevent stack overflow if messages are logged during the process.
	if event == "BAGSHUI_LOG_UPDATE" and self.allowUpdates then
		self.allowUpdates = false
		self:SetText(Bagshui:GetLogText())
		self.allowUpdates = true
		return
	end
end



--- Prepare log window.
function LogWindow:InitUi()
	-- Calls ScrollableTextWindow:InitUi().
	if self._super.InitUi(self) == false then
		return
	end

	-- Add toolbar icons.
	self.clearButton = self.ui:CreateIconButton({
		name = "ClearLog",
		texture = "Delete",
		tooltipTitle = L.ClearLog,
		parentFrame = self.uiFrame.bagshuiData.header,
		anchorPoint = "RIGHT",
		anchorToFrame = self.uiFrame.bagshuiData.closeButton,
		anchorToPoint = "LEFT",
		width = 16,
		height = 16,
		xOffset = -BsSkin.toolbarCloseButtonOffset,
		onClick = function()
			Bagshui:ClearLog()
			self:SetText("")
		end,
	})

	-- Re-anchor title to leftmost toolbar button so it doesn't run underneath.
	self.uiFrame.bagshuiData.title:SetPoint("RIGHT", self.clearButton, "LEFT", -BsSkin.toolbarCloseButtonOffset, 0)


	-- EditBox SHOULD scroll to the bottom when the log is updated.
	self.editBox.bagshuiData.scrollToBottomOnTextSet = true

end



-- Register for log change event.
Bagshui:RegisterEvent("BAGSHUI_LOG_UPDATE", LogWindow)


end)