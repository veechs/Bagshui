-- Bagshui Profile Management UI

Bagshui:AddComponent(function()

local Profiles = BsProfiles


-- Reusable table for hiding the selected object ID from the replace menu.
local replaceMenuHideIds = {}


--- Subclass override for InitUI() to handle class-specific details.
function Profiles:InitUi()
	-- ObjectList:InitUi() has the same check, but let's avoid doing any unnecessary work
	-- since the superclass function isn't called immediately.
	if self.objectManager then
		return
	end

	--- Prompt for confirmation and perform deletion.
	local function replaceAfterConfirmation(profileType, source, target)
		local dialogName = "BAGSHUI_REPLACE_PROFILE"

		if not _G.StaticPopupDialogs[dialogName] then
			_G.StaticPopupDialogs[dialogName] = {
				text = "",
				button1 = L.Replace,
				button2 = L.Cancel,
				showAlert = 1,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 0,
				--- Perform replacement (no need for OnCancel as that simply needs to do nothing).
				---@param data table Reference to `self.replaceAfterConfirmation_Data`, passed through via the dialog's `data` property.
				OnAccept = function(data)
					self:Copy(data.source, data.target, data.profileTypeStorageKey)
				end,
			}

			self.replaceAfterConfirmation_Data = {}
		end

		-- Make sure there's something to do
		if not self.objectManager.ui.listFrame.bagshuiData.selectedEntry then
			return
		end

		-- Don't preempt any other dialogs or they'll end up calling OnCancel
		if _G.StaticPopup_Visible(dialogName) then
			return
		end


		-- Update prompt. Not using arg1/arg2 of StaticPopup_Show() because we need three parameters.
		_G.StaticPopupDialogs[dialogName].text = string.format(
			L.ProfileManager_ReplacePrompt,
			L["Profile_" .. profileType],
			self:GetName(target),
			self:GetName(source)
		)
		--_G.StaticPopupDialogs[dialogName].text = string.format(L.EditMode_Prompt_RenameGroup, (string.len(currentName or "") > 0 and currentName or L.UnnamedGroup))

		-- Display the dialog and provide the object type and object name to the prompt text
		local dialog = _G.StaticPopup_Show(dialogName)

		-- Pass stuff to dialog functions via the magic data property.
		self.replaceAfterConfirmation_Data.source = source
		self.replaceAfterConfirmation_Data.target = target
		self.replaceAfterConfirmation_Data.profileTypeStorageKey = self:GetProfileStorageKey(profileType)
		if dialog then
			dialog.data = self.replaceAfterConfirmation_Data
		end
	end


	-- Custom menus.
	self.menus = Bagshui.prototypes.Menus:New()

	-- Menu for Replace button.
	local replaceMenu = {}
	for _, profileType in pairs(BS_PROFILE_TYPE) do
		local profileTypeUpvalue = profileType
		local profileTypeLocalized = L["Profile_" .. profileType]
		table.insert(
			replaceMenu,
			{
				text = L["Profile_" .. profileType],
				value = {
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.PROFILES,
					autoSplitNoBaseExtraItems = true,
					idsToOmit = replaceMenuHideIds,
					omitFunc = function(id, itemList)
						-- Can't use profiles that don't have the necessary profile component.
						return (not itemList[id] or not itemList[id][BsProfiles:GetProfileStorageKey(profileTypeUpvalue)])
					end,
					tooltipTitleFunc = function()
						return string.format(L.ProfileManager_ReplaceTooltipTitle, profileTypeLocalized)
					end,
					tooltipTextFunc = function(source)
						return string.format(
							L.ProfileManager_ReplaceTooltipText,
							profileTypeLocalized,
							self:GetName(source),
							self:GetName(self.objectManager.ui.listFrame.bagshuiData.selectedEntry)
						)
					end,
					func = function(target, source)
						replaceAfterConfirmation(profileTypeUpvalue, source, target)
					end,
				},
				notCheckable = true,
				hasArrow = true,
			}
		)
	end
	self.menus:AddMenu(
		"ReplaceProfileData",
		-- Level 1.
		replaceMenu,
		-- Level 2/3.
		nil, nil,
		--- OpenMenu callback.
		---@param menu table Menu table.
		---@param selectedObjectId string|number Currently selected object.
		function(menu, selectedObjectId)
			BsUtil.TableClear(replaceMenuHideIds)
			table.insert(replaceMenuHideIds, selectedObjectId)

			for _, menuItem in ipairs(menu.levels[1]) do
				menuItem.value.objectId = selectedObjectId
			end
		end
	)


	-- Calls ObjectList:InitUi().
	self._super.InitUi(self,
		nil,  -- No custom Object Manager needed.
		nil,  -- No custom Object Editor needed.
		{
			-- Object Manager settings.

			managerWidth  = 500,
			managerHeight = 400,

			managerColumns = {
				{
					field = "name",
					title = L.ObjectManager_Column_Name,
					widthPercent = "75",
					currentSortOrder = "ASC",
					lastSortOrder = "ASC",
				},
				{
					field = "builtin",
					title = L.ObjectManager_Column_Source,
					widthPercent = "16",
					lastSortOrder = "ASC",
				},
				{
					field = "inUse",
					title = L.ObjectManager_Column_InUse,
					widthPercent = "9",
					lastSortOrder = "ASC",
				},
			},

			managerToolbarModification = function(toolbarButtons)
				-- Insert the Replace button.
				for i = 1, table.getn(toolbarButtons) do
					if toolbarButtons[i].scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.EDIT then
						table.insert(
							toolbarButtons,
							i + 1,
							{
								scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.REPLACE,
								scrollableList_AutomaticAnchor = true,
								scrollableList_DisableIfReadOnly = true,
								scrollableList_DisableIfMultipleSelected = true,
								xOffset = BsSkin.toolbarSpacing,
								onClick = function()
									self.menus:OpenMenu(
										"ReplaceProfileData",
										self.objectManager.ui.listFrame.bagshuiData.selectedEntry,  -- OpenMenu callback arg1
										nil,  -- OpenMenu callback arg2
										-- Anchoring.
										_G.this, 0, 0, "TOPLEFT", "BOTTOMLEFT"
									)
								end,
							}
						)
						break
					end
				end
			end,


			-- Object Editor settings.

			editorWidth  = 450,
			editorHeight = 100,

			editorFields = {
				"name",
			},

			editorFieldProperties = {
				name = {
					required = true
				},
			},

		}
	)


	---comment Override NewEditor so we can modify the interface.
	---@return table objectEditorInstance
	function self.objectManager:NewEditor()
		local editor = self._super.NewEditor(self)

		local footerText = editor.uiFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
		footerText:SetText(GRAY_FONT_COLOR_CODE .. L.ProfileEditor_FooterText .. FONT_COLOR_CODE_CLOSE)
		footerText:SetJustifyH("LEFT")
		footerText:SetPoint("BOTTOMLEFT", editor.uiFrame, "BOTTOMLEFT", BsSkin.windowPadding, BsSkin.windowPadding)
		footerText:SetPoint("BOTTOMRIGHT", editor.uiFrame, "BOTTOMRIGHT", -BsSkin.windowPadding, BsSkin.windowPadding)

		return editor
	end

end


end)