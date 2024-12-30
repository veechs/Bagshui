-- Bagshui Dialog Box
-- Exposes: BsDialog (and Bagshui.prototypes.Dialog)
--
-- Special dialog boxes for Bagshui functionality.

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui

-- Dialog properties and instances should be stored on the prototype so they're global.
Ui.dialogProperties = {}
Ui.dialogInstances = {}



--- Set up a new dialog. This is similar to Blizzard's `StaticPopupDialogs[]`.
--- It's built on Bagshui's ScrollableTextWindow class, so the dialog objects
--- are ScrollableTextWindow instances.
---
--- Properties can be anything accepted by `ScrollableTextWindow:New()`, plus:
--- ```
--- {
--- 	---@type string? Text to at the top of the dialog. Will be overridden by `ShowDialog()` parameter if provided.
--- 	prompt,
--- 	---@type string? Text to display on button1 (the left button). Will be overridden by `ShowDialog()` parameter if provided. An empty string will hide the button.
--- 	button1,
--- 	---@type string? Text to display on button2 (the right button). Will be overridden by `ShowDialog()` parameter if provided. An empty string will hide the button.
--- 	button2,
--- 	---@type boolean? Disable button1 unless there is text in the EditBox..
--- 	button1DisableOnEmptyText,
--- 	---@type boolean? Disable button2 unless there is text in the EditBox..
--- 	button2DisableOnEmptyText,
--- 	---@type string? Text to display on button2 (the right button). Will be overridden by `ShowDialog()` parameter if provided. An empty string will hide the button.
--- 	button2,
--- 	---@type function? Called when button1 is clicked (see notes below).
--- 	OnAccept = function(dialog) -> nil,
--- 	---@type function? Called when button2 is clicked (see notes below).
--- 	OnCancel = function(dialog) -> nil,
--- 	---@type function? Perform any dialog customization at the end of the dialog's `InitUi()`.
--- 	dialogCustomizationFunc = function(dialog) -> nil,
--- }
--- ```
--- 
--- ### OnAccept/OnCancel
--- These functions will be passed the dialog instance as their only parameter.
--- From there, all `ScrollableTextWindow` properties are available.
--- The most important things are getting the EditBox contents and passing data
--- through from the calling function.
--- 
--- If OnAccept is defined as:
--- ```
--- OnAccept = function(dialog)
--- 	Bagshui:PrintDebug(dialog:GetText())
--- 	Bagshui:PrintDebug(dialog.data.someProperty)
--- end
--- ```
--- 
--- Then the calling function can do something like:
--- ```
--- local dialog = ui:ShowDialog("DIALOG_ID", "Enter some text:")
--- dialog.data.someProperty = "This will pass through to the callback."
--- ```
---@param id any Unique identifier.
---@param dialogProperties table List of properties.
function Ui:AddMultilineDialog(id, dialogProperties)
	dialogProperties.width = dialogProperties.width or 400
	dialogProperties.height = dialogProperties.height or 400
	self.dialogProperties[id] = dialogProperties
end



--- Obtain a dialog instance as configured in `AddDialog()`.
---@param id any Unique identifier as set up in `AddDialog()`.
---@return table dialog Dialog-modified ScrollableTextWindow instance. 
function Ui:GetDialog(id)
	assert(self.dialogProperties[id], tostring(id) .. " is not a known dialog! Initialize with `AddDialog()` first.")

	if not self.dialogInstances[id] then
		self.dialogInstances[id] = {}
	end

	local dialogProperties = self.dialogProperties[id]
	local dialog

	-- Find an existing dialog to reuse.
	for _, existingDialog in ipairs(self.dialogInstances[id]) do
		if
			existingDialog.recycle == true
			or not existingDialog.uiFrame
			or not existingDialog.uiFrame.IsVisible
			or not existingDialog.uiFrame:IsVisible()
		then
			dialog = existingDialog
			break
		end
	end

	-- Nothing found; create a new one.
	if not dialog then
		dialogProperties.name = tostring(id) .. table.getn(self.dialogInstances[id])
		dialog = self.ScrollableTextWindow:New(dialogProperties)
		dialog.isDialog = true
		dialog.ui = self
		dialog.id = id
		dialog.data = {}
		dialog.prompt = nil
		dialog.button1 = _G.OKAY
		dialog.button2 = _G.CANCEL
		dialog.dialogProperties = dialogProperties


		--- Initialize the UI.
		function dialog:InitUi()
			assert(self.prompt, "Dialog prompt text is required, either via ShowDialog() parameter or in AddDialog() property list.")

			self._super.InitUi(self)

			-- Needed for `Bagshui:CloseAllWindows()`.
			self.uiFrame.isDialog = true

			-- Keep it on top of everything else.
			self.uiFrame:SetFrameStrata("DIALOG")

			-- This is called every time ShowDialog() is called, so we need to avoid
			-- customizing more than once.
			if not self.uiFrame.bagshuiData.prompt then

				-- Special stuff for dialog behaviors on top of the base ScrollableTextWindow scripts.

				local oldOnShow = self.uiFrame:GetScript("OnShow")
				self.uiFrame:SetScript("OnShow", function()
					if self.suppressShowHideEvents then
						return
					end
					if oldOnShow then
						oldOnShow()
					end
					self:SetParentHasModalDialog(true)
					self.recycle = false
				end)


				local oldOnHide = self.uiFrame:GetScript("OnHide")
				self.uiFrame:SetScript("OnHide", function()
					if self.suppressShowHideEvents then
						return
					end
					if oldOnHide then
						oldOnHide()
					end

					if self.modalParent then
						self.ui:SetWindowShade(self.modalParent, false)
						Bagshui:QueueClassCallback(self, self.SetParentHasModalDialog, 0.1, nil, false)
					end

					self.editBox:SetText("")
					self.recycle = true
				end)

				-- EditBox changes.
				local oldOnChanged = self.editBox:GetScript("OnTextChanged")
				self.editBox:SetScript("OnTextChanged", function()
					oldOnChanged()
					if self.dialogProperties.button1DisableOnEmptyText or self.dialogProperties.button1DisableOnEmptyText then
						local state = string.len(BsUtil.Trim(_G.this:GetText() or "")) > 0 and "Enable" or "Disable"
						if self.dialogProperties.button1DisableOnEmptyText then
							self.uiFrame.bagshuiData.button1[state](self.uiFrame.bagshuiData.button1)
						end
						if self.dialogProperties.button2DisableOnEmptyText then
							self.uiFrame.bagshuiData.button2[state](self.uiFrame.bagshuiData.button2)
						end
					end
				end)

				-- Prompt text.
				self.uiFrame.bagshuiData.prompt = self.uiFrame:CreateFontString(nil, nil, "GameFontHighlight")
				self.uiFrame.bagshuiData.prompt:SetText(self.prompt)
				self.uiFrame.bagshuiData.prompt:SetJustifyH("LEFT")
				self.uiFrame.bagshuiData.prompt:SetPoint("TOPLEFT", self.uiFrame, "TOPLEFT", BsSkin.windowPadding, -BsSkin.windowPadding)
				self.uiFrame.bagshuiData.prompt:SetWidth(self.dialogProperties.width - (BsSkin.windowPadding * 2))

				-- Buttons.
				local buttonWidth = math.min(self.dialogProperties.width / 2 - 10, 150)

				-- Directly passing the default text parameter here to ensure button heights are set correctly.
				self.uiFrame.bagshuiData.button1 = self.ui:CreateButton("Button1", self.uiFrame, _G.TEXT(_G.OKAY), function()
					if self.dialogProperties.OnAccept then
						self.dialogProperties.OnAccept(dialog)
					end
					self.uiFrame:Hide()
				end)
				self.uiFrame.bagshuiData.button1:SetPoint("BOTTOMLEFT", self.uiFrame, "BOTTOMLEFT", BsSkin.windowPadding, BsSkin.windowPadding)
				self.uiFrame.bagshuiData.button1:SetWidth(buttonWidth)

				self.uiFrame.bagshuiData.button2 = self.ui:CreateButton("Button1", self.uiFrame, _G.TEXT(_G.CANCEL), function()
					if self.dialogProperties.OnCancel then
						self.dialogProperties.OnCancel(dialog)
					end
					self.uiFrame:Hide()
				end)
				self.uiFrame.bagshuiData.button2:SetPoint("BOTTOMRIGHT", self.uiFrame, "BOTTOMRIGHT", -BsSkin.windowPadding, BsSkin.windowPadding)
				self.uiFrame.bagshuiData.button2:SetWidth(buttonWidth)

				-- Re-anchor ScrollFrame to prompt text and buttons.
				self.ui:SetPoint(self.uiFrame.bagshuiData.scrollFrame, "TOPLEFT", self.uiFrame.bagshuiData.prompt, "BOTTOMLEFT", 0, -4)
				self.ui:SetPoint(self.uiFrame.bagshuiData.scrollFrame, "BOTTOMRIGHT", self.uiFrame.bagshuiData.button2, "TOPRIGHT", 0, 4)


				if type(self.dialogProperties.dialogCustomizationFunc) == "function" then
					self.dialogProperties.dialogCustomizationFunc(self)
				end

			end  -- ScrollableTextWindow customization complete.

			-- Update everything to reflect current parameters.

			self.uiFrame.bagshuiData.prompt:SetText(self.prompt)

			if string.len(tostring(self.button1)) == 0 then
				self.uiFrame.bagshuiData.button1:Hide()
			else
				self.uiFrame.bagshuiData.button1:SetText(self.button1)
				self.uiFrame.bagshuiData.button1:Show()
			end

			if string.len(tostring(self.button2)) == 0 then
				self.uiFrame.bagshuiData.button2:Hide()
			else
				self.uiFrame.bagshuiData.button2:SetText(self.button2)
				self.uiFrame.bagshuiData.button2:Show()
			end

			self.uiFrame:SetHeight(self.dialogProperties.height + self.uiFrame.bagshuiData.prompt:GetHeight())

		end



		--- Focusing the EditBox too quickly causes the cursor to visually "stick",
		--- where it doesn't flash and doesn't disappear when escape is pressed.
		--- A short delay on the SetFocus() call works around it. *shrug*
		function dialog:FocusEditBox()
			self.editBox:SetFocus()
		end


		--- Clearing the `hasModalDialog` property too quickly causes the check in
		--- `Bagshui:CloseAllWindows()` to see it as false before it should be and
		--- the parent window ends up closing when it shouldn't.
		function dialog:SetParentHasModalDialog(hasModalDialog)
			if
				type(self.modalParent) == "table"
				and self.modalParent.GetName
				and self.modalParent.bagshuiData
			then
				self.modalParent.bagshuiData.hasModalDialog = hasModalDialog
			end
		end


		--- Display the window.
		---@param text string Text to place in the EditBox.
		---@return boolean? willOpen false if the window won't open due to missing parameters.
		function dialog:Open(text)
			if not self._super.Open(self, text) then
				return false
			end

			if self.modalParent then
				-- Modal dialog behavior -- anchor and center it on the parent and
				-- place a shade over the parent frame.
				self.uiFrame:SetMovable(false)
				----------
				-- Can't use SetParent() because it messes up the ScrollFrame overflow. :(
				-- Instead, we're putting the frame on the DIALOG strata during its' InitUi().
				-- self.suppressShowHideEvents = true  -- Changing parentage will trigger OnHide/OnShow and we don't want them to fire again.
				-- self.uiFrame:SetParent(self.modalParent)
				-- self.suppressShowHideEvents = false
				----------
				self.uiFrame:ClearAllPoints()
				self.uiFrame:SetPoint("CENTER", self.modalParent, "CENTER", 0, 0)
				self.ui:SetWindowShade(self.modalParent, true, self.uiFrame)
				self.modalParent.bagshuiData.hasModalDialog = true
			end

			-- Focus the EditBox after a short delay (see dialog:FocusEditBox() comments for reasoning).
			Bagshui:QueueClassCallback(self, self.FocusEditBox, 0.1)

			return true
		end


		table.insert(self.dialogInstances[id], dialog)
	end

	return dialog
end



--- Display a multiline input dialog.
--- To get the input, use the OnAccept/OnCancel callbacks (see notes for `AddDialog()`).
---@param idOrDialog any|table Unique identifier set up in `AddDialog()` *or* return value from `GetDialog()`.
---@param prompt string? Text to display above the EditBox. If not provided, mut have been given to `AddDialog()`.
---@param button1Text string? Text to display on the left-hand button. If not provided, will fall back to dialog properties and then default to localized "Okay". An empty string will hide the button.
---@param button2Text string? Text to display on the right-hand button. If not provided, will fall back to dialog properties and then default to localized "Cancel". An empty string will hide the button.
---@param defaultText string? Initial text placed in the EditBox.
---@param modalParent table? Frame to attach this dialog to.
---@return table dialog The dialog box object that will be passed through to callbacks.
function Ui:ShowDialog(idOrDialog, prompt, button1Text, button2Text, defaultText, modalParent)
	local dialog = idOrDialog
	if type(idOrDialog) == "string" then
		dialog = self:GetDialog(idOrDialog)
	end
	assert(dialog and dialog.isDialog, "Ui:ShowDialog() - " .. tostring(idOrDialog) .. " is not a valid dialog.")

	-- Update properties that will be consumed by InitUi().

	dialog.properties = self.dialogProperties[dialog.id]  -- Refresh pointer to properties in case they've been updated.
	dialog.prompt = prompt or self.dialogProperties[dialog.id].prompt or nil
	dialog.button1 = button1Text or self.dialogProperties[dialog.id].button1 or _G.OKAY
	dialog.button2 = button2Text or self.dialogProperties[dialog.id].button2 or _G.CANCEL
	dialog.modalParent = modalParent

	-- Create/update UI.
	dialog:InitUi()

	-- Display the dialog and wait for callback.
	-- ScrollableTextWindow:Open() expects a non-nil string so pass an empty one if no default text was given.
	dialog:Open(type(defaultText) == "string" and defaultText or "")

	return dialog
end



--- Display a copyable URL.
---@param url string
function Ui:ShowUrl(url)
	local dialogName = "BAGSHUI_COPY_URL"

	if not _G.StaticPopupDialogs[dialogName] then
		_G.StaticPopupDialogs[dialogName] = {
			text = L.HowToUrl,
			button1 = _G.OKAY,
			hasEditBox = 1,
			hasWideEditBox = 1,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,

			-- Extra property to be used in OnShow to fill the edit box.
			-- Blizzard doesn't provide an easy way to do this in Vanilla as the
			-- data property isn't accessible in OnShow, and all the FrameXML code uses
			-- global variables and functions.
			_bagshuiUrl = "",

			-- Set the default value for the edit box
			OnShow = function()
				-- For whatever reason, Blizzard has hardcoded which dialogs are wide instead of
				-- resizing based on hasWideEditBox, so the only way to get the dialog wide enough
				-- is to set it manually.
				_G.this:SetWidth(420)
				_G[_G.this:GetName().."WideEditBox"]:SetText(_G.StaticPopupDialogs[dialogName]._bagshuiUrl)
				_G[_G.this:GetName().."WideEditBox"]:SetFocus()
				_G[_G.this:GetName().."WideEditBox"]:HighlightText()
				-- We also need to reposition Button1 because apparently you're not supposed to
				-- have a dialog with an EditBox and one button.
				_G[_G.this:GetName().."Button1"]:ClearAllPoints()
				_G[_G.this:GetName().."Button1"]:SetPoint("TOP", _G[_G.this:GetName().."EditBox"], "BOTTOM", 0, -8);
			end,

			-- Clear text on hide so it doesn't bleed over to other dialogs.
			OnHide = BsUtil.StaticPopupDialogs_ClearTextOnHide
		}
	end

	_G.StaticPopupDialogs[dialogName]._bagshuiUrl = url
	_G.StaticPopup_Show(dialogName)

end


end)