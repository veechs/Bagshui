-- Bagshui Core: Windows
-- Window management.

Bagshui:LoadComponent(function()


--- When the escape key is pressed, close all registered frames.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call.
---@param arg1 any
---@param arg2 any
---@param arg3 any
---@return boolean windowsOpen
function Bagshui:CloseAllWindows(wowApiFunctionName, arg1, arg2, arg3)
	-- Need to know whether any other windows were closed since CloseAllWindows() is expected
	-- to return true if windows were closed to prevent the Game Menu from being opened.
	local otherWindowsVisible = self.hooks:OriginalHook(wowApiFunctionName, arg1, arg2, arg3)

	-- Close any of our windows there were open.
	local bagshuiWindowsVisible = false
	local dialogsClosed = false

	-- First loop looks for dialogs and closes them.
	for frame, _ in pairs(self.framesToCloseOnEscape) do
		if frame.isDialog and frame:IsVisible() then
			bagshuiWindowsVisible = true
			dialogsClosed = true
			frame:Hide()
		end
	end

	-- Now we can close anything that isn't a dialog.
	if not dialogsClosed then
		for frame, _ in pairs(self.framesToCloseOnEscape) do
			if frame:IsVisible() then
				bagshuiWindowsVisible = true
			end

			-- Hide the frame if it's clean.
			local dirty = false
			local hasCursorItem = false
			if frame.bagshuiData then
				hasCursorItem = frame.bagshuiData.hasCursorItem
				dirty =
					frame.bagshuiData.dirty
					or frame.bagshuiData.hasModalDialog
					or hasCursorItem
			end
			if not dirty then
				frame:Hide()
			end

			-- Frame is dirty and has an onDirty function.
			if dirty and frame.bagshuiData.onDirty and not frame.bagshuiData.hasModalDialog then
				frame.bagshuiData.onDirty()
			end

			-- Frame has a cursor item.
			if hasCursorItem then
				-- This is a quick hack to get Edit Mode cursor clearing on Escape press
				-- to work. When something is picked up in Edit Mode, Inventory:ShowEditModeCursor()
				-- sets the frame's hasCursorItem property to itself (the class instance).
				-- Then we can detect the class instance and call ClearEditModeCursor().
				if type(hasCursorItem) == "table" and hasCursorItem.ClearEditModeCursor then
					hasCursorItem:ClearEditModeCursor()
				else
					_G.ClearCursor()
				end
			end
		end
	end

	-- Return true if any window was closed so WoW knows not to open the Game Menu.
	return otherWindowsVisible or bagshuiWindowsVisible
end



--- Add new frame to be closed when CloseAllWindows() fires.
---@param frame table
function Bagshui:RegisterFrameForCloseOnEscape(frame)
	self.framesToCloseOnEscape[frame] = true
end



--- When at least one of the frames registered through `Bagshui:RegisterFrameAsChildWindow() is visible, return `true`.
---@return boolean
function Bagshui:ChildWindowsVisible()
	for frame, _ in pairs(self.childWindowFrames) do
		if frame:IsVisible() then
			return true
		end
	end
	return false
end



--- Register frame as a "Child Window" (see `Bagshui:ChildWindowsVisible()`).
---@param frame table
function Bagshui:RegisterFrameAsChildWindow(frame)
	self.childWindowFrames[frame] = true
end




local boundaryFramePositions = { "TOP", "RIGHT", "BOTTOM", "LEFT" }

--- These "boundary frames" are used to detect when one of the Bagshui inventory
--- windows gets moved outside the screen area. See `Inventory:RescueWindow()`.
function Bagshui:ManageBoundaryFrames()
	if not self.boundaryFrames then
		self.boundaryFrames = {}
	end

	for _, position in ipairs(boundaryFramePositions) do
		if not self.boundaryFrames[position] then
			self.boundaryFrames[position] = _G.CreateFrame("Frame", "BagshuiBoundary" .. position, _G.UIParent)
			self.boundaryFrames[position]:SetHeight(1)
			self.boundaryFrames[position]:SetWidth(1)
			self.boundaryFrames[position]:SetPoint(position, _G.UIParent, position)
		end

		self.boundaryFrames[position]:SetScale(BsSettings.windowScale)

	end
end


end)