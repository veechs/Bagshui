-- Bagshui Settings Class Prototype
-- Exposes:
-- * Bagshui.prototypes.Settings
-- * BsSettings - see notes at the end of this file.
--   
-- Raises: BAGSHUI_SETTING_UPDATE
--
-- The goal of the Settings class is to have a table that proxies all accesses
-- (get/set) in order to transparently handle setting scoping. This allows simple
-- things like settingsInstance.mySetting = 1, and if mySetting is supposed to be
-- stored at the account level (as defined in Config\Settings.lua), then that will
-- just happen.
--
-- For settingsInstance.mySetting to work, the metatable that runs the show assumes
-- that all keys in the Settings class that don't exist are settings. This means
-- that if there's ever a need to add new class-level keys after instantiation,
-- rawset() must be used.
--
-- In addition, it's recommended that ALL class properties for Settings be prefixed
-- with an underscore to avoid collision with actual settings. Recommended naming
-- convention that will ensure uniqueness:
-- * settingName
-- * _classProperty
-- * ClassFunction

Bagshui:AddComponent(function()

local SETTING_VERSION_KEY = "_settingVersions_"

-- Settings class. See notes at the top of Settings.lua regarding underscore naming.
local Settings = {
	-- Private table for storing setting information.
	_settingInfo = {},

	-- Private table to store references to setting tables (ACCOUNT, CHARACTER, Bags, Bank, etc).
	_settingValues = {},
}
Bagshui.prototypes.Settings = Settings



-- Initial setup.
function Settings:Init()

	-- The only settings that need to be initialized are those related to Inventory.
	self:InitSettingsInfo(Bagshui.config.Settings[BS_SETTING_APPLICABILITY.INVENTORY])

	-- Account-wide settings.
	if _G.BagshuiData.settings == nil then
		_G.BagshuiData.settings = {}
	end
	self._settingValues[BS_SETTING_SCOPE.ACCOUNT] = _G.BagshuiData.settings

	-- Character-wide settings (shared across Inventory classes).
	if Bagshui.currentCharacterData.settings == nil then
		Bagshui.currentCharacterData.settings = {}
	end
	self._settingValues[BS_SETTING_SCOPE.CHARACTER] = Bagshui.currentCharacterData.settings

	-- Set defaults for account/character settings (3rd parameter EXCLUDES Inventory-level settings)
	-- as those will be set during `Settings:New()`.
	self:SetDefaults(false, nil, BS_SETTING_SCOPE.INVENTORY)

end



-- Create a new Settings class instance that will magically access and store settings in the appropriate scope-level tables.
---@param inventoryClassInstance table? Instance of the Bagshui Inventory class prototype.
---@param wipeOnLoad boolean? Reset all settings during initialization.
---@return table settings Class instance.
function Settings:New(inventoryClassInstance, wipeOnLoad)
	local inventoryType = inventoryClassInstance and inventoryClassInstance.inventoryType

	if inventoryType then
		-- SavedVariables data for inventory classes is stored under the lowercase
		-- version of their inventoryType property.
		local inventoryTypeSavedVars = string.lower(inventoryType)

		-- Ensure storage is initialized
		if Bagshui.currentCharacterData[inventoryTypeSavedVars] == nil then
			Bagshui.currentCharacterData[inventoryTypeSavedVars] = {}
		end
		if Bagshui.currentCharacterData[inventoryTypeSavedVars].settings == nil or wipeOnLoad then
			Bagshui.currentCharacterData[inventoryTypeSavedVars].settings = {}
		end
		-- Store inventory-level tables on the Settings class prototype (self), NOT the instance since docked classes use the settings of the class they're docked to.
		-- This is intentionally using the Noun Case version of the inventoryType property for storage on the class object.
		self._settingValues[inventoryType] = Bagshui.currentCharacterData[inventoryTypeSavedVars].settings
	end

	-- Prepare new class object.
	-- Using underscore-prefixed keys for reasons outlined in the class introduction.
	local classObj = {
		-- BS_INVENTORY_TYPE of the Inventory class instance that owns this Settings class instance, if any.
		_inventoryType = inventoryType,
		-- Inventory class instance that owns this Settings class instance, if any.
		_inventoryClassInstance = inventoryClassInstance,

		-- BS_INVENTORY_TYPE of the Inventory class instance that where Settings are being stored, based on docked state.
		_inventoryTypeForSettingsStorage = inventoryType,
		-- Inventory class instance on which settings should be stored, based on docked state..
		_inventoryClassSettingsSource = inventoryClassInstance,

		-- Cache is used to avoid full lookups when just requesting a setting value.
		_settingCache = {},

		-- Don't send change events until initialization is complete.
		_initialized = false,
	}

	-- Alter the settings source for docked instances to be the class they're docked to.
	if inventoryClassInstance and inventoryClassInstance.dockTo then
		classObj._inventoryTypeForSettingsStorage = inventoryClassInstance.dockTo
		classObj._inventoryClassSettingsSource = Bagshui.components[inventoryClassInstance.dockTo]
	end

	-- Metatable that will intercept all accesses to classObj for unknown keys.
	-- This is what makes `settingInstance.settingName` work for get/set.
	local mt = {

		--- Get
		---@param _ table The table being accessed.
		---@param key any Requested key.
		---@return any # Setting value or class property value.
		__index = function(_, key)
			if not self._settingInfo[key] then
				-- If it's not a setting, return the class level function or property.
				return self[key]
			else
				-- Retrieve setting value.
				return classObj:Get(key)
			end
		end,

		--- Set
		---@param _ table The table being accessed.
		---@param settingName string Setting to update.
		---@param value any New value.
		__newindex = function(_, settingName, value)
			--Bagshui:PrintDebug("*update of element " .. tostring(settingName) .. " to " .. tostring(value))
			classObj:Set(settingName, value)
		end
	}

	setmetatable(classObj, mt)

	-- Set the defaults for this inventory type.
	-- This won't do anything if there isn't an Inventory class instance.
	classObj:SetDefaults(false, BS_SETTING_SCOPE.INVENTORY)

	-- Initialize the settings cache.
	classObj:InitCache()

	-- Change events can now be raised.
	classObj._initialized = true

	-- Receive change events from other Settings class instances.
	Bagshui:RegisterEvent("BAGSHUI_SETTING_UPDATE", classObj)

	-- Return the new class object.
	return classObj
end



--- Recursively process the settings configuration into a flat list.
--- 
--- The `settingsTable` is an array containing tables that conform to the following formats:
---
--- ## Titles
--- A title table can contain either a `menuTitle` or a `mainTitle` key.
--- ### Standard Title
--- ```
--- {
--- 	---@type string Menu text for the title.
--- 	menuTitle,
--- },
--- ```
--- ### Main Title
--- ```
--- {
--- 	---@type boolean Build the top-level Inventory class menu title -- see mainTitle code in Components\Inventory.Menus.Settings.lua.
--- 	mainTitle = true,
--- },
--- ```
--- 
--- ## Submenus
--- A submenu is created by adding a table with `submenuName` and `settings` keys.
--- ```
--- {
--- 	---@type string Name to display for the submenu.
--- 	submenuName,
--- 	---@type string? Text to use as the tooltip title (will use the `submenuName` if not provided).
--- 	 tooltipTitle,
--- 	---@type string? Text to use as the tooltip body.
--- 	 tooltipText,
--- 	---@type Setting[] Array of setting tables.
--- 	settings = {}
--- }
--- ```
--- 
--- ## Setting
---
--- ### Important note about localization:
--- The preferred way to localize `title`/`tooltipTitle`/`tooltipText` is via localization.
--- * `<settingName>` -> `title`
--- * `<settingName>_TooltipTitle` -> `tooltipTitle`
--- * `<settingName>_TooltipText` -> `tooltipText`
--- The `title`/`tooltipTitle`/`tooltipText` properties should only be used where
--- localization won't cut it. Container hook settings are one example of this.
--- 
---
--- ### Each setting is defined using a table with the following keys:
--- ```
--- {
--- 	---@type string REQUIRED Internal name of the setting. Will also be used for localization as `Setting_<name>`.
--- 	name,
--- 	---@type BS_SETTING_TYPE REQUIRED Setting data type.
--- 	type,
--- 	---@type any Initial setting value.
--- 	defaultValue,
--- 	---@type BS_SETTING_SCOPE? At what level should the setting be stored? Defaults to INVENTORY.
--- 	scope,
--- 	---@type BS_SETTING_PROFILE_SCOPE? When scope is INVENTORY, settings can be further scoped into profiles.
--- 	profileScope,
--- 	---@type boolean Don't expose this setting in the UI.
--- 	hidden,
--- 	---
--- 	--- * Display Customization *
--- 	---@type string? Display name of the setting when the setting does not have a localization.
--- 	-- This should really be called `text` instead of `title`. Maybe it'll get fixed one day.
--- 	title,
--- 	---@type string? Text to use as the tooltip title when the setting does not have a localization.
--- 	tooltipTitle,
--- 	---@type string? Text to use as the tooltip body when the setting does not have a localization.
--- 	tooltipText,
--- 	---@type boolean? Make the menu entry *look* like a title, but still be clickable.
--- 	fakeTitle,
--- 	---@type boolean? Suppress display of the submenu arrow.
--- 	hideArrow,
--- 	---@type function? Alter the value displayed in the UI without changing anything else.
--- 	valueDisplayFunc,
--- 	---
--- 	--- * Behaviors *
--- 	---@type function(settingName, settingsClassInstance)? -> boolean Return `true` to disable the setting.
--- 	disableFunc,
--- 	---@type function? -> boolean Return `true` to hide the setting.
--- 	hideFunc,
--- 	---@type function(nameString)? -> string Alter the displayed name of the setting during initialization.
---     -- Should be renamed to `textFunc` if this ever gets a consistency pass.
--- 	nameFunc,
--- 	---@type function(text, settingName, settings)? -> string Modify the menu text at display-time.
--- 	textDisplayFunc,
--- 	---@type function(tooltipText, settingName, settings)? -> string Modify the tooltip text at display-time. The `tooltipText` string will contain `~1~` as a placeholder for insertion at the end, but before the reset text.
--- 	tooltipTextDisplayFunc,
--- 	---@type function(settings, settingName, newValue)? -> nil Custom callback to execute after setting change..
--- 	onChange,
--- 	---@type boolean? Trigger the associated inventory class to refresh its item cache.
--- 	inventoryCacheUpdateOnChange,
--- 	---@type boolean? Trigger the associated inventory class to re-sort and re-categorize.
--- 	inventoryResortOnChange,
--- 	---@type boolean? Trigger the associated inventory class to redraw its window.
--- 	inventoryWindowUpdateOnChange,
--- 	---
--- 	--- > BS_SETTING_TYPE.CHOICES only <
--- 	---@type { value: any, text: string }[] Array of choices to display.
--- 	choices,
--- 	---@type BS_AUTO_SPLIT_MENU_TYPE Auto-split menu to display instead of a static list of choices.
--- 	choicesAutoSplitMenuType,
--- 	---@type function See `omitFunc` definition in Components\Menus.lua.
--- 	choicesAutoSplitMenuOmitFunc,
--- 	---@type function See `tooltipTextFunc` definition in Components\Menus.lua.
--- 	choicesAutoSplitMenuTooltipTextFunc,
--- 	---
--- 	--- > BS_SETTING_TYPE.COLOR only <
--- 	---@type boolean Display the opacity slider in the color picker.
--- 	hasOpacity,
--- 	---
--- 	--- > BS_SETTING_TYPE.NUMBER only <
--- 	---@type number Lowest value for the number selection submenu and lowest allowable value.
--- 	min,
--- 	---@type number Highest value for the number selection submenu and highest allowable value.
--- 	max,
--- 	---@type number Increment to use when building the number selection submenu.
--- 	step,
--- 	---@type { value: any, text: string }[] Array of choices to display. Will be used instead of automatically generating a list based on min/max.
--- 	choices,
--- }
--- ```
---@param settingsTable table<string,any> Settings configuration as defined just above.
function Settings:InitSettingsInfo(settingsTable)
	for _, settingInfo in pairs(settingsTable) do
		if type(settingInfo.settings) == "table" then
			-- This setting has a `settings` table on it, so we need to recurse.
			Settings:InitSettingsInfo(settingInfo.settings)

		elseif settingInfo.name then
			-- This is a normal setting.
			if settingInfo.type then
				-- Add to _settingInfo table.
				settingInfo.scope = BS_SETTING_SCOPE[settingInfo.scope] or BS_SETTING_SCOPE.INVENTORY  -- Default scope
				settingInfo.settingVersion = type(settingInfo.settingVersion) == "number" and settingInfo.settingVersion or 1
				self._settingInfo[settingInfo.name] = settingInfo

				-- When a setting is added after startup, make sure it has a default value.
				if self._initialized then
					self:SetDefaults(false, nil, nil, settingInfo.name)
				end
			else
				Bagshui:PrintWarning("Setting " .. settingInfo.name .. " is missing the 'type' property and cannot be used.")
			end
		end
	end
end



--- Prepare the cache for this settings instance.
--- Cache is referenced by `Settings:Get()`.
function Settings:InitCache()
	BsUtil.TableClear(self._settingCache)
	for settingName, _ in pairs(self._settingInfo) do
		local value = self:Get(settingName, false, true, true)  -- final trues are noCache/noDefault so the actual value is obtained.
		self._settingCache[settingName] = value
	end
end



--- Event handling.
---@param event string Event identifier.
---@param arg1 any? Argument 1 from the event.
---@param arg2 any? Argument 2 from the event.
---@param arg3 any? Argument 3 from the event.
function Settings:OnEvent(event, arg1, arg2, arg3, arg4)

	-- Update cache for non-Inventory level setting changes that come from other
	-- Settings class instances. Without this, settings will get out of sync as
	-- they're changed and won't be synced back up until a reload. (For example,
	-- an account-level setting is changed from the Bags settings menu, but the
	-- Bank's Settings class instance would still have the old value in its cache.)
	-- arg1 is settingName.
	-- arg2 is settingInfo.
	-- arg3 is newValue.
	-- arg4 is the Settings class instance.
	if
		self._settingCache
		and event == "BAGSHUI_SETTING_UPDATE"
		and arg4 ~= self
		and arg2.scope ~= BS_SETTING_SCOPE.INVENTORY
	then
		self._settingCache[arg1] = arg3
	end
end



--- Retrieve the info table for a setting.
---@param settingName any
---@return table settingInfo
function Settings:GetSettingInfo(settingName)
	assert(settingName ~= nil, "settingName is required")
	local settingInfo = self._settingInfo[settingName]
	assert(settingInfo, "Invalid setting " .. settingName)
	return settingInfo
end



--- Retrieve the storage table for a given setting.
---@param setting string|table Setting name or settingInfo table.
---@return table|nil
function Settings:GetTableForSetting(setting)

	local settingInfo = type(setting) == "table" and setting or self:GetSettingInfo(setting)

	-- Non-Inventory-scoped settings.
	-- We have to use the class prototype here because _settingValues isn't stored at the instance level.
	local settingTable = Settings._settingValues[settingInfo.scope]

	-- Inventory-scoped settings need special handling.
	if settingInfo.scope == BS_SETTING_SCOPE.INVENTORY then
		-- Safety check - can't return an inventory-scoped setting if we don't have an inventory instance.
		if self._inventoryClassInstance then
			-- profileScope should be populated in Settings config using the BS_SETTING_PROFILE_SCOPE enum.
			if settingInfo.profileScope then
				-- Get the profile-level setting table. Using _inventoryClassSettingsSource,
				-- which is the Inventory class instance on which settings should be stored,
				-- regardless of docked state.
				settingTable =
					self._inventoryClassSettingsSource
					and self._inventoryClassSettingsSource.profiles
					and self._inventoryClassSettingsSource.profiles[BS_PROFILE_TYPE[settingInfo.profileScope]]
					or nil

			else
				-- Non-profile settings.
				settingTable = Settings._settingValues[self._inventoryTypeForSettingsStorage]
			end
		else
			-- Safety check failed.
			settingTable = nil
		end
	end
	return settingTable
end



-- Retrieve the value of a setting.
---@param settingName string
---@param includeVersion boolean? The second return value will be the setting version. Only works when `noCache` is true.
---@param noCache boolean? Do not pull from the cache.
---@param noDefault boolean? When the setting value is nil, just return nil instead of the default value.
---@return any value
---@return integer? settingVersion
function Settings:Get(settingName, includeVersion, noCache, noDefault)
	local value

	-- Cached value.
	if not (includeVersion or noCache) then
		value = self._settingCache[settingName]
		if value ~= nil then
			return value
		end
	end

	-- Non-cached value.
	local settingTable = self:GetTableForSetting(settingName)
	if settingTable then
		value = settingTable[settingName]
	end

	-- Grab default value if we haven't found a saved value.
	if value == nil and not noDefault then
		-- Using self._settingInfo instead of self:GetSettingInfo() because we 
		-- already know it's a valid setting name from calling GetTableForSetting().
		value = self._settingInfo[settingName].defaultValue
	end

	if includeVersion then
		return value, ((settingTable and settingTable[SETTING_VERSION_KEY] and settingTable[SETTING_VERSION_KEY][settingName]) or 0)
	end

	return value
end



--- Update the value for a setting.
---@param settingName string
---@param value any New value.
---@param skipValidation boolean? Use `value` as given without potentially changing it via validation.
---@param force boolean? Save the setting even if the value hasn't changed.
function Settings:Set(settingName, value, skipValidation, force)

	local settingInfo = self:GetSettingInfo(settingName)
	local settingTable = self:GetTableForSetting(settingInfo)
	local previousValue = settingTable and settingTable[settingName]
	local finalValue = value

	-- Validate.
	if not skipValidation then
		finalValue = self:Validate(settingInfo, value)
	end

	-- Make sure there's a change.
	if finalValue == previousValue and not force then
		return
	end

	if
		-- Only save if a save location is available.
		settingTable
		-- Trigger settings don't get changes saved since their only purpose is to raise the change event.
		and settingInfo.type ~= BS_SETTING_TYPE.TRIGGER
	then
		if not settingTable[SETTING_VERSION_KEY] then
			settingTable[SETTING_VERSION_KEY] = {}
		end

		-- Save setting and version
		settingTable[settingName] = finalValue
		settingTable[SETTING_VERSION_KEY][settingName] = settingInfo.settingVersion

		-- Update cache.
		if self._settingCache then
			self._settingCache[settingName] = finalValue
		end
	end

	-- Trigger change callback if provided.
	if settingInfo.onChange and self._initialized then
		settingInfo.onChange(self, settingName, finalValue)
	end

	-- Send change notification.
	if self._initialized then
		Bagshui:RaiseEvent(
			"BAGSHUI_SETTING_UPDATE",
			nil,
			settingName,
			settingInfo,
			finalValue,
			self
		)
	end
end



--- Ensure all settings are initialized and reset to default if requested.
---@param forceReset boolean? By default, settings are only reset if they are nil or have invalid values. When `forceReset` is true, all settings matching the scope filters are reset.
---@param scope BS_SETTING_SCOPE? Only reset settings matching this scope.
---@param omitScope BS_SETTING_SCOPE? Only reset settings NOT matching this scope.
---@param limitToSetting string? Reset only the specified setting (scope-based filtering still applies).
---@param silent boolean? Don't print a message when settings are changed.
function Settings:SetDefaults(forceReset, scope, omitScope, limitToSetting, silent)
	--Bagshui:PrintDebug(string.format("SetDefaults() forceReset=%s scope=%s omitScope=%s", tostring(forceReset), tostring(scope), tostring(omitScope)))

	local qualifiedSettingName, currentVersion, newVersion, currentValue, newValue, changeReason

	-- Loop through all settings since we don't store indexes of setting scopes.
	for settingName, settingInfo in pairs(self._settingInfo) do

		-- Only process requested scopes.
		if
			(
				-- Safety check - Can't do inventory-level scopes if we don't have
				-- an inventory type and setting table for the given setting.
				settingInfo.scope ~= BS_SETTING_SCOPE.INVENTORY
				or (
					self._inventoryClassInstance ~= nil
					and self:GetTableForSetting(settingInfo)
				)
			)
			and (not scope or (scope ~= nil and settingInfo.scope == scope))
			and (not omitScope or (omitScope ~= nil and settingInfo.scope ~= omitScope))
			-- Skip settings that don't have values.
			and settingInfo.type ~= BS_SETTING_TYPE.TRIGGER
			and settingInfo.type ~= BS_SETTING_TYPE.PLACEHOLDER
		then

			if not limitToSetting or limitToSetting == settingName then

				-- Initialize variables
				changeReason = nil
				currentValue, currentVersion = self:Get(settingName, true, true, true)
				newValue = nil
				newVersion = settingInfo.settingVersion

				-- No need to validate current value if resetting.
				if not forceReset then
					if currentValue ~= nil then
						newValue = self:Validate(settingInfo, currentValue)
						if type(currentValue) == "table" then
							for key, _ in pairs(currentValue) do
								if currentValue[key] ~= newValue[key] then
									changeReason = L.SettingReset_InvalidValue
								end
							end
						end
					end
				end

				-- Reasons to reset.
				if currentValue == nil then
					-- Not yet initialized.

					-- Won't be printed to chat due to currentValue ~= nil check,
					-- but changeReason needs to have a value to trigger initialization.
					changeReason = "init"


				elseif currentVersion < newVersion then
					-- Outdated version.
					changeReason = L.SettingReset_Outdated
					--Bagshui:PrintDebug("old version: "..tostring(currentVersion)..", settingVersion: "..tostring(newVersion))

				end

				-- Need to reset.
				if changeReason or forceReset then
					-- Grab default value if it wasn't corrected by validation above.
					if newValue == nil then
						newValue = (
							-- Setting override per-inventoryType
							(
								self._inventoryType
								and Bagshui.config.InventorySettingOverrides[self._inventoryType]
								and Bagshui.config.InventorySettingOverrides[self._inventoryType][settingName]
							)
							or settingInfo.defaultValue
						)
					end

					-- Set value, skipping validation since we know it's good.
					if currentValue ~= newValue then
						self:Set(settingName, newValue, true, true)

						-- Logging.
						if not silent and currentValue ~= nil then
							qualifiedSettingName = tostring((settingInfo.scope ~= BS_SETTING_SCOPE.INVENTORY) and settingInfo.scope or self._inventoryType) .. "." .. settingName
							-- "<Setting> reset [<reason>] '<old value>' => '<new value>'"
							Bagshui:PrintInfo(string.format(
								"%s%s '%s' => '%s'",
								string.format(L.SettingReset_LogStart, qualifiedSettingName),
								changeReason and string.format(" [%s]", changeReason) or "",
								tostring(currentValue),
								tostring(newValue)
							))
						end
					end

				end

			--else
				--Bagshui:PrintDebug("skipping " .. settingName .. " because scope is " .. settingInfo.scope .. " and scope = " .. tostring(scope) .. " or omitScope = " .. tostring(omitScope))

			end

		end


	end

end



--- Ensure the given setting value is valid and provide the value it should be.
---@param settingInfo any Configuration for the setting being validated.
---@param value any Value to validate.
---@return any validatedValue Current or default value, depending on whether it needed to be corrected.
function Settings:Validate(settingInfo, value)
	local validatedValue = value

	-- Call validation function if available for the setting's data type.
	if settingInfo.type then
		local validationFunctionName = "Validate" .. settingInfo.type
		if self[validationFunctionName] then
			validatedValue = self[validationFunctionName](self, value, settingInfo)
		end
	end

	return validatedValue
end



--- Ensure `value` is within the allowed `min` - `max` range.
---@param value any Number to validate.
---@param min number Lowest allowed value.
---@param max number Highest allowed value.
---@param default number Fallback if `value` is invalid.
---@return number validatedValue
function Settings:ValidateNumericRange(value, min, max, default)
	if value == nil then
		return default
	end

	local validatedValue = value

	if type(validatedValue) ~= "number" then
		validatedValue = tonumber(validatedValue)
	end

	if min then
		validatedValue = math.max(validatedValue, min)
	end

	if max then
		validatedValue = math.min(validatedValue, max)
	end

	return validatedValue
end



--- Validation: BS_SETTING_TYPE.NUMBER  
--- Ensure `value` is within the allowed `min` - `max` range.
---@param value any Setting value to validate.
---@param settingInfo any Configuration for the setting being validated.
---@return number validatedValue
function Settings:ValidateNumber(value, settingInfo)
	return self:ValidateNumericRange(value, settingInfo.min, settingInfo.max, settingInfo.defaultValue)
end



--- Validation: BS_SETTING_TYPE.BOOL  
--- Understands 1 -> true, "true" -> true.
---@param value any Setting value to validate.
---@param settingInfo any Configuration for the setting being validated.
---@return boolean validatedValue
function Settings:ValidateBool(value, settingInfo)
	local validatedValue = value

	if type(validatedValue) == "number" then
		validatedValue = (validatedValue == 1)
	end

	if type(validatedValue) == "string" then
		validatedValue = (validatedValue == string.lower("true"))
	end

	if type(validatedValue) ~= "boolean" then
		validatedValue = settingInfo.defaultValue
	end

	return value
end



--- Validation: BS_SETTING_TYPE.COLOR  
--- ` { r, g, b, [a] }` where all values are between 0 and 1.
---@param value any Setting value to validate.
---@param settingInfo any Configuration for the setting being validated.
---@return number[] validatedValue
function Settings:ValidateColorRgba(value, settingInfo)
	local validatedValue = value
	if type(validatedValue) ~= "table" or (type(validatedValue) == "table" and table.getn(validatedValue) < table.getn(settingInfo.defaultValue)) then
		return BsUtil.TableCopy(settingInfo.defaultValue)
	end

	for i = 1, table.getn(settingInfo.defaultValue) do
		validatedValue[i] = self:ValidateNumericRange(validatedValue[i], 0, 1, settingInfo.defaultValue[i])
	end

	return validatedValue
end



--- Validation: BS_SETTING_TYPE.CHOICES  
---@param value any Setting value to validate.
---@param settingInfo any Configuration for the setting being validated.
---@return any validatedValue
function Settings:ValidateChoices(value, settingInfo)

	if not settingInfo.choices then
		return nil
	end

	local validatedValue = nil

	if value ~= nil then
		local menuTableFound = false

		-- There are two possible formats for valid choices.

		-- One is the menu format of `{ { value = "Val2", text = "Text1" }, { value = "Val2", text = "Text2" } }`.
		for _, choice in ipairs(settingInfo.choices) do
			if choice.value then
				menuTableFound = true
			end
			if
				(not settingInfo.caseSensitive and string.lower(value) == string.lower(choice.value or ""))
				or (settingInfo.caseSensitive and value == choice.value)
			then
				validatedValue = choice.value
			end
		end

		-- The other way to specify valid choices is a list where the keys are valid values.
		-- (Sort Orders uses this)
		if not menuTableFound then
			for choice, _ in pairs(settingInfo.choices) do
				if
					(not settingInfo.caseSensitive and string.lower(value) == string.lower(choice))
					or (settingInfo.caseSensitive and value == choice)
				then
					validatedValue = choice
				end
			end
		end
	end

	-- Couldn't find a valid value, so fall back to default.
	if validatedValue == nil then
		validatedValue = settingInfo.defaultValue
	end

	return validatedValue
end



--- Validation: BS_SETTING_TYPE.TRIGGER  
---@param value any Setting value to validate.
---@param settingInfo any Configuration for the setting being validated.
---@return true|nil validatedValue
function Settings:ValidateTrigger(value, settingInfo)
	-- The only valid values for a Trigger setting are nil and true.
	return (value == true) or nil
end



-- Initialize class.
Settings:Init()


-- This is a Settings class instance available in the Bagshui
-- environment that can only access ACCOUNT and CHARACTER-scoped settings.
-- Inventory class instances must use their self.settings Settings class
-- instances; BsSettings is only for use outside the Inventory classes.
-- See the Profiles class for an example of it in action.
Bagshui.environment.BsSettings = Settings:New()


end)