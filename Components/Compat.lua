-- Bagshui Compatibility
-- Warnings for for compatibility with other addons.

Bagshui:AddComponent(function()


--- Execute compatibility checks that will help avoid issues or unexpected behaviors.
function Bagshui:CheckCompat()

	-- The pfUI Bags module also hooks the Blizzard Bank events, so both
	-- Bagshui and pfUI display simultaneously. When in this state, show an
	-- actionable dialog so it's easy to avoid the problem.
	if pfUI and pfUI.env and pfUI.env.C and pfUI.env.C.disabled then

		-- Don't do anything until pfUI firstrun is done.
		if pfUI.firstrun and pfUI.firstrun.steps then
			for _, step in pairs(pfUI.firstrun.steps) do
				if not _G.pfUI_init[step.name] then
					self:QueueClassCallback(self, self.CheckCompat, 0.5)
					return
				end
			end
		end

		self:CheckOtherAddonSetting(
			"pfUIBags",
			true,
			pfUI.env.C.disabled,
			"bags",
			"1",
			"replaceBank"
		)
	end

	-- tDF All-In-One-Bag is an embedded version of SUCC-Bag and it will override
	-- our Backpack hook. Show a recommendation to disable it so key bindings
	-- work as expected.
	self:CheckOtherAddonSetting(
		"tDFAllInOneBags",
		(
			_G.IsAddOnLoaded("tDF")
			and _G.ShaguTweaks
			and _G.ShaguTweaks.T
			and _G.ShaguTweaks_config
		),
		_G.ShaguTweaks_config,
		(_G.ShaguTweaks and _G.ShaguTweaks.T and _G.ShaguTweaks.T["All-In-One-Bag"]),
		0,
		"hookBag0"
	)

end



-- Callback data for compatibility dialog.
local addonPromptData = {

	--- Perform the disable action and prompt for UI reload.
	--- @param data any
	disableFunc = function(data)
		-- Change the addon setting.
		data.addonSettingTable[data.addonSettingKey] = data.settingDisabledValue

		local dialogName = "BAGSHUI_COMPAT_RELOAD_UI"

		if not _G.StaticPopupDialogs[dialogName] then
			_G.StaticPopupDialogs[dialogName] = {
				text = "",
				button1 = L.Reload,
				button2 = L.NotNow,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 0,
				OnAccept = function()
					_G.ReloadUI()
				end,
			}
		end

		_G.StaticPopupDialogs[dialogName].text = data.infoMessage .. BS_NEWLINE .. BS_NEWLINE .. L.Compat_ReloadUIPrompt
		_G.StaticPopup_Show(dialogName)
	end,

	--- Show dialog with instructions for managing the offending setting.
	---@param data any
	ignoreFunc = function(data)
		-- Record the choice to ignore.
		BsSettings[data.ignoreSetting] = true
		
		local dialogName = "BAGSHUI_COMPAT_INFO"

		if not _G.StaticPopupDialogs[dialogName] then
			_G.StaticPopupDialogs[dialogName] = {
				text = "",
				button1 = _G.OKAY,
				timeout = 10,
				whileDead = 1,
				hideOnEscape = 0,
			}
		end

		_G.StaticPopupDialogs[dialogName].text = data.infoMessage
		_G.StaticPopup_Show(dialogName)

	end,

}



--- Inspect the value of a specific setting belonging to another addon that can
--- conflict with Bagshui and prompt to disable it.
--- Some things need to be defined in Bagshui configs for this to work.
--- See the exiting pfUIBags ones as an example.
--- Settings:
--- - `compat_<bagshuiCompatSettingId>LastSetting`
--- - `compat_<bagshuiCompatSettingId>Ignored`
--- Localization:
--- - `Compat_<bagshuiCompatSettingId>`
--- - `Compat_<bagshuiCompatSettingId>Info`
---@param bagshuiCompatSettingId string Used for the compat settings and localization (see function description).
---@param addonInstalledCondition boolean Must be `true` for the check to proceed.
---@param addonSettingTable table Storage for the other addon's setting.
---@param addonSettingKey any Key within `addonSettingTable` where the offending setting is found.
---@param settingDisabledValue any Value for `addonSettingKey` that indicates the setting is in a **good** state.
---@param bagshuiSettingToCheck string Bagshui setting that must be enabled for the check to proceed. **Must be a character or account-scoped setting!**
function Bagshui:CheckOtherAddonSetting(
	bagshuiCompatSettingId,
	addonInstalledCondition,
	addonSettingTable,
	addonSettingKey,
	settingDisabledValue,
	bagshuiSettingToCheck
)

	-- Can't proceed if addon isn't installed or Bagshui setting is disabled.
	if
		not addonInstalledCondition
		or (bagshuiSettingToCheck and not BsSettings[bagshuiSettingToCheck])
	then
		return
	end

	local lastSetting = "compat_" .. bagshuiCompatSettingId .. "LastSetting"
	local ignored = "compat_" .. bagshuiCompatSettingId .. "Ignored"

	-- Reset compatibility warning when addon setting is changed.
	if BsSettings[lastSetting] ~= addonSettingTable[addonSettingKey] then
		BsSettings[ignored] = false
	end

	-- Check actual setting.
	if
		addonSettingTable[addonSettingKey] ~= settingDisabledValue
		and not BsSettings[ignored]
	then

		local dialogName = "BAGSHUI_COMPAT_DISABLE"

		if not _G.StaticPopupDialogs[dialogName] then
			_G.StaticPopupDialogs[dialogName] = {
				text = "",
				button1 = L.Disable,
				button2 = L.Ignore,
				timeout = 0,
				whileDead = 1,
				hideOnEscape = 0,
				cancels = dialogName,

				--- Disable was clicked, so do it.
				---@param data table Reference to `self.renameGroup_Data`, passed through via the dialog's `data` property.
				OnAccept = function(data)
					data.disableFunc(data)
				end,

				--- Ignore was clicked.
				---@param data table Reference to `self.renameGroup_Data`, passed through via the dialog's `data` property.
				OnCancel = function(data, reason)
					if reason == "override" then
						return
					end
					data.ignoreFunc(data)
				end,

			}

		end

		_G.StaticPopupDialogs[dialogName].text = BS_FONT_COLOR.BAGSHUI .. "Bagshui" .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. L["Compat_" .. bagshuiCompatSettingId]

		self:CloseMenus()

		local dialog = _G.StaticPopup_Show(dialogName)

		if dialog then
			addonPromptData.addonSettingTable = addonSettingTable
			addonPromptData.addonSettingKey = addonSettingKey
			addonPromptData.settingDisabledValue = settingDisabledValue
			addonPromptData.ignoreSetting = ignored
			addonPromptData.infoMessage = L["Compat_" .. bagshuiCompatSettingId .. "Info"]
			dialog.data = addonPromptData
		end

		Bs:PrintDebug("setting is enabled and needs to be disabled")

	end

	-- Record last setting value so we know when to reset our warning.
	BsSettings[lastSetting] = addonSettingTable[addonSettingKey]

end


end)