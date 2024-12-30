-- Bagshui UI Class: Edit Boxes

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui


--- Create an EditBox for entering text.
--- Bagshui EditBox support a fake "read-only" mode -- see `Ui:ResetEditBox()` for details.
---@param name string Unique name for the button (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param inherits string? Widget template.
---@param fontObject string|table? Font object or identifier string (defaults to ChatFontNormal).
---@param multiLine boolean? Edit box should be multiline.
---@param noBackgroundOrBorder boolean? Don't apply any styling.
---@param selectAllOnFocus boolean? Highlight text when focus is gained.
---@return table editBox
function Ui:CreateEditBox(name, parent, inherits, fontObject, multiLine, noBackgroundOrBorder, selectAllOnFocus)

	local editBox = _G.CreateFrame(
		"EditBox",
		self:CreateElementName(name),
		parent,
		inherits
	)

	editBox.bagshuiData = {
		-- There doesn't seem to be a built-in way to check whether an edit box
		-- currently has focus, so we'll track it.
		hasFocus = false
	}

	editBox:SetFontObject(fontObject or "ChatFontNormal")
	editBox:SetMultiLine(multiLine)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 5, 5)

	if not noBackgroundOrBorder then
		self:SetFrameBackdropAndBorderForEditWidgets(editBox)
	end

	-- Create reusable functions for EditBox script handlers.
	-- RestReadOnly needs to capture self, so they're all just being done
	-- here instead of as local functions.
	if not self._createEditBox_OnEscape then

		-- Clear focus.
		function self._createEditBox_OnEscape()
			_G.this:ClearFocus()
		end

		-- Focus tracking.
		function self._createEditBox_OnFocusGained()
			_G.this.bagshuiData.hasFocus = true
			if selectAllOnFocus then
				_G.this:HighlightText()
			end
		end

		-- Focus tracking.
		function self._createEditBox_OnFocusLost()
			_G.this.bagshuiData.hasFocus = false
		end

		-- Reset read-only EditBoxes.
		function self._createEditBox_ResetReadOnly()
			self:ResetEditBox(_G.this)
		end

	end

	-- Escape key should of course remove the cursor from the EditBox.
	editBox:SetScript('OnEscapePressed', self._createEditBox_OnEscape)

	-- Track focus.
	editBox:SetScript("OnEditFocusGained", self._createEditBox_OnFocusGained)
	editBox:SetScript("OnEditFocusLost", self._createEditBox_OnFocusLost)

	-- Fake a read-only EditBox by resetting contents when changed.
	-- Setting this for both OnChar and OnTextChanged because OnChar is faster
	-- if someone just types, but OnTextChanged is necessary to catch cutting/pasting.
	editBox:SetScript("OnChar", self._createEditBox_ResetReadOnly)
	editBox:SetScript("OnTextChanged", self._createEditBox_ResetReadOnly)

	return editBox
end



--- Reset a "read-only" EditBox.
--- Make an EditBox read-only by setting the `bagshuiData.readOnlyText` property
--- to the text that should be immutable.
---@param editBox table EditBox from `Ui:CreateEditBox()`.
function Ui:ResetEditBox(editBox)
	if not editBox.bagshuiData or (editBox.bagshuiData and (not editBox.bagshuiData.readOnlyText)) then
		return
	end

	-- Make sure the text is scrolled to the right place.
	if editBox.bagshuiData.scrollFrame then
		editBox.bagshuiData.scrollFrame:UpdateScrollChildRect()
	end

	-- Reset text only if it's been edited.
	if editBox:GetText() ~= editBox.bagshuiData.readOnlyText then
		editBox:ClearFocus()
		editBox:SetText(editBox.bagshuiData.readOnlyText)
	end
end



--- Create a scrollable multiline edit box for entering text.
---@param namePrefix string Unique name prefix for the button (will be suffixed with ScrollFrame/EditBox and passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param borderStyle table|string `borderStyle` parameter for `Ui:CreateScrollFrame()`.
---@param editBoxInherits string? `inherits` parameter for `Ui:CreateEditBox()`.
---@param fontObject string|table? `fontObject` parameter for `Ui:CreateEditBox()`.
---@param selectAllOnFocus boolean `selectAllOnFocus` parameter for `Ui:CreateEditBox()`.
---@return table scrollFrame
---@return table editBox
function Ui:CreateScrollableEditBox(namePrefix, parent, borderStyle, editBoxInherits, fontObject, selectAllOnFocus)
	assert(namePrefix, "CreateScrollableEditBox(): namePrefix is required to create a scrollable EditBox")

	-- Create the elements.
	local scrollFrame = self:CreateScrollFrame(namePrefix .. "ScrollFrame", parent, borderStyle)
	local editBox = self:CreateEditBox(namePrefix .. "EditBox", scrollFrame, editBoxInherits, fontObject, true, true, selectAllOnFocus)

	-- Add references for easy access to related elements.
	scrollFrame.bagshuiData.scrollChild = editBox  -- Allow Ui:SetScrollChildWidth() to work automatically.
	scrollFrame.bagshuiData.editBox = editBox
	editBox.bagshuiData.scrollFrame = scrollFrame

	-- Prep the EditBox with default height and width that will trigger scrolling..
	editBox:SetWidth(1000)
	editBox:SetHeight(1000)

	-- Without SetAllPoints you get some wild behavior where the EditBox either:
	-- - Can't be clicked if the CreateFrame call is made with the ScrollFrame as the parent or
	-- - Has to be created with the dialog frame as the parent to be clickable, but then its
	--   editing area spills out of the ScrollFrame bounds and messes with window dragability.
	editBox:SetAllPoints(scrollFrame)

	-- Requirements to make scrolling work.
	-- Credit to WowLua source for pointing me in the right direction.
	if not self._createScrollableEditBox_OnCursorChanged then
		-- This is silly, but I wanted to prevent EditBoxes from being scrolled to the bottom
		-- when their contents are set programmatically. To do that, OnTextSet sets the
		-- textChangedProgrammatically property to 2, because there are 2 OnCursorChanged
		-- events that fire afterwards. OnCursorChanged subtracts 1 every time it's called,
		-- and will only trigger ScrollingEdit_OnUpdate to adjust scroll once
		-- textChangedProgrammatically <= 0.
		function self._createScrollableEditBox_OnCursorChanged()
			self:ResetEditBox(_G.this)
			if _G.this.bagshuiData.textChangedProgrammatically <= 0 then
				_G.this.cursorOffset = arg2
				_G.this.cursorHeight = arg4
			end
			_G.this.bagshuiData.textChangedProgrammatically = _G.this.bagshuiData.textChangedProgrammatically - 1
		end

		function self._createScrollableEditBox_OnTextSet()
			if not _G.this.bagshuiData.scrollToBottomOnTextSet then
				_G.this.bagshuiData.textChangedProgrammatically = 2
			end
			_G.this.bagshuiData.scrollFrame:UpdateScrollChildRect()
		end

		function self._createScrollableEditBox_OnTextChanged()
			self:ResetEditBox(_G.this)
			_G.this.bagshuiData.scrollFrame:UpdateScrollChildRect()
		end
	end
	editBox.cursorOffset = 0
	editBox.cursorHeight = 0
	editBox.bagshuiData.textChangedProgrammatically = 0
	editBox:SetScript("OnUpdate", _G.ScrollingEdit_OnUpdate)
	editBox:SetScript("OnCursorChanged", self._createScrollableEditBox_OnCursorChanged)
	editBox:SetScript("OnTextSet", self._createScrollableEditBox_OnTextSet)
	editBox:SetScript("OnTextChanged", self._createScrollableEditBox_OnTextChanged)

	-- Assign the EditBox to the ScrollFrame so scrolling actually scrolls..
	scrollFrame:SetScrollChild(editBox)

	-- Allow a click on the empty ScrollFrame area to focus the EditBox when the
	-- EditBox is shorter than the ScrollFrame.
	scrollFrame:EnableMouse(true)
	scrollFrame:SetScript("OnMouseDown", function()
		self:CloseMenusAndClearFocuses()
		editBox:SetFocus()
	end)

	return scrollFrame, editBox
end


end)