-- Bagshui Settings Configuration and Defaults
-- Exposes: Bagshui.config.Settings

Bagshui:AddComponent(function()

-- There are some things that need to be defined before we can get to the actual configuration.
-- If you're just looking for that, skip down to Bagshui.config.Settings.


-- Choices for window anchoring and content alignment.
local POSITION_CHOICES = {
	LEFT_RIGHT = {
		{
			value = "LEFT",
			text = L.Left,
		},
		{
			value = "RIGHT",
			text = L.Right,
		},
	},

	TOP_BOTTOM = {
		{
			value = "TOP",
			text = L.Top,
		},
		{
			value = "BOTTOM",
			text = L.Bottom,
		}
	},

}



--- Assigned to the `hideFunc` property of the `*UseSkinColors` settings to hide
--- their menu entries when the default skin is active.
---@return boolean
local function useSkinColorsHide()
	return Bagshui.config.Skins.activeSkin == "Bagshui"
end


--- Assigned to the `nameFunc` property of the `*UseSkinColors` settings to insert
--- the skin name into the localization string.
---@param nameString string
---@return string updatedNameString
local function useSkinColorsName(nameString)
	return string.format(nameString, Bagshui.config.Skins.activeSkin)
end



--- Assigned to the `textDisplayFunc` property of settings affected by Colorblind Mode
--- to append * to the name when they are force-enabled.
local function colorblindModeOverrideTextFunc(text, settingName, settings)
	return text .. (settings.colorblindMode and (LIGHTYELLOW_FONT_COLOR_CODE .. " √" .. FONT_COLOR_CODE_CLOSE) or "")
end

--- Assigned to the `tooltipTextDisplayFunc` property of settings affected by Colorblind Mode
--- to add text to the tooltip when they are force-enabled.
local function colorblindModeOverrideTooltipFunc(tooltipText, settingName, settings)
	return string.gsub(
		tooltipText,
		"~1~",
		(
			settings.colorblindMode
			and (LIGHTYELLOW_FONT_COLOR_CODE .. L.Setting_EnabledBy_ColorblindMode .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE)
			or ""
		)
	)
end


--- Assigned to the `disableFunc` property of the `*Background[Default]` settings
--- to disable them when the corresponding `*UseSkinColors` setting is true.
---@param settingName string
---@param settings table
---@return boolean
local function disableWhenUsingSkinColors(settingName, settings)
	return
		Bagshui.config.Skins.activeSkin ~= "Bagshui"
		and settings[(string.find(settingName, "^group") and "group" or "window") .. "UseSkinColors"]
end



--- Assigned to the `onChange` property of the `windowAnchor<X/Y>Point` settings to adjust
--- the saved position to reference the new anchor so the window stays in the same place.
---@param settingName string
---@param settings table
---@param newValue string
local function windowAnchorChange(settings, settingName, newValue)
	settings[string.gsub(settingName, "Point$", "Offset")] = settings._inventoryClassInstance:GetWindowOffset(newValue)
end



-- It's simplest to build the Inventory class hook settings here and insert them at the correct
-- place below instead of trying to do it the other way around.
-- Non-generated hook settings are hardcoded in first. It would be nice to have things ordered
-- alphabetically (Bags, Bank, Keyring) instead of Bank, Bags, Keyring... maybe in the future.

local hookSettings = {
	{
		menuTitle = L.Menu_Settings_InfoTooltip,
	},
	{
		name = "globalInfoTooltips",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
	},
	{
		name = "showInfoTooltipsWithoutAlt",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = false,
	},
	{
		menuTitle = L.Menu_Settings_ToggleBagsWith,
	},
	{
		name = "toggleBagsWithAuctionHouse",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
	},
	{
		name = "toggleBagsWithBankFrame",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
	},
	{
		name = "toggleBagsWithMailFrame",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
	},
	{
		name = "toggleBagsWithTradeFrame",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
	},
	{
		menuTitle = L.Bank,
	},
	{
		name = "replaceBank",
		scope = BS_SETTING_SCOPE.ACCOUNT,
		type = BS_SETTING_TYPE.BOOL,
		defaultValue = true,
		onChange = function(settings, settingName, newValue)
			Bagshui.components.Bank:ReplaceBlizzardBank(newValue)
			-- Redo pfUI Bags compatibility check when replaceBank enabled.
			if newValue then
				settings.compat_pfUIBagsIgnored = false
				Bagshui:QueueClassCallback(Bagshui, Bagshui.CheckCompat, 0.05)
			end
		end
	},
}

-- Iterate the containers of each inventory type that opens via function hooking
-- and add settings to disable hooks for those containers.
for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
	local inventoryConfig = Bagshui.config.Inventory[inventoryType]

	if inventoryConfig.opensViaHooks then

		table.insert(
			hookSettings,
			{
				menuTitle = string.format(L.Menu_Settings_Hooks_Suffix, L[inventoryType]),
			}
		)

		for _, containerId in ipairs(Bagshui.config.Inventory[inventoryType].containerIds) do
			local bagName =
				(containerId == inventoryConfig.primaryContainer.id)
				and inventoryConfig.primaryContainer.name
				or string.format(L.Prefix_Bag, containerId)

			table.insert(
				hookSettings,
				{
					name = "hookBag" .. containerId,
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.BOOL,
					title = bagName,
					tooltipTitle = string.format(L.Setting_HookBagTooltipTitle, bagName),
					tooltipText = string.format(L.Setting_HookBagTooltipText, bagName),
					defaultValue = true,
					onChange = function(settings, settingName, newValue)
						-- Redo tDF All-In-One-Bag compatibility check when Backpack hook is enabled.
						if settingName == "hookBag0" and newValue then
							settings.compat_tDFAllInOneBagsIgnored = false
							Bagshui:QueueClassCallback(Bagshui, Bagshui.CheckCompat, 0.05)
						end
					end
				}
			)
		end
	end
end



-- Each profile type settings entries in two places:
-- 1. The Default Profiles submenu, where there should be a submenu to select
--    the default profile of that type and a "Copy" menu entry to trigger profile
--    duplication when a new character logs in.
-- 2. An auto-split submenu for selecting the active profile.
--
-- The tables that feed the auto-split menus in these settings will be attached
-- by Profiles:Init().

local defaultProfileSettings = {}
local profileSettings = {}

-- Iterate each profile type to build out the settings.
for _, profileTypeKey in pairs(BS_PROFILE_ORDER) do

	local profileType = BS_PROFILE_TYPE[profileTypeKey]

	-- Default Profile selection with auto-split menu of available profiles.
	table.insert(
		defaultProfileSettings,
		{
			name = "defaultProfile" .. profileType,
			fakeTitle = true,
			hideArrow = true,
			scope = BS_SETTING_SCOPE.ACCOUNT,
			type = BS_SETTING_TYPE.CHOICES,
			defaultValue = BS_DEFAULT_PROFILE[profileType],
			choicesAutoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.PROFILES,
			choicesAutoSplitMenuOmitFunc = function(id, itemList)
				-- Can't use profiles that don't have the necessary profile component.
				return (not itemList[id] or not itemList[id][BsProfiles:GetProfileStorageKey(profileType)])
			end,
			onChange = function(settings, settingName, newValue)
				-- Update the `createNewProfile<profileType>` to `true` if this is a built-in profile.

				local profile = BsProfiles:Get(newValue)
				if profile and profile.builtin then
					settings["createNewProfile" .. string.gsub(settingName, "^defaultProfile", "")] = true
				end
			end,
		}
	)
	-- "Copy" setting to trigger duplication of the default profile when
	-- a new profile needs to be created.
	table.insert(
		defaultProfileSettings,
		{
			name = "createNewProfile" .. profileType,
			scope = BS_SETTING_SCOPE.ACCOUNT,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = true,
			disableFunc = function(settingName, settings)
				-- Disable menu item for built-in profiles.
				-- Translate `createNewProfile<profileType>` to `defaultProfile<profileType>`
				-- and obtain the profile object so we can determine whether it's built-in.
				-- Intentionally calling Get() instead of GetUsableProfile() here so that
				-- an invalid profile will return false instead of falling back to a built-in
				-- profile.

				local profile = BsProfiles:Get(settings["defaultProfile" .. string.gsub(settingName, "^createNewProfile", "")])
				return (profile and profile.builtin)
			end,
		}
	)

	-- Active profile with auto-split menu of available profiles.
	profileSettings[profileTypeKey] = {
		name = "profile" .. profileType,
		scope = BS_SETTING_SCOPE.INVENTORY,
		type = BS_SETTING_TYPE.CHOICES,
		defaultValue = nil,
		choicesAutoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.PROFILES,
		choicesAutoSplitMenuTooltipTextFunc = function(_, _, inventory)
			return
				string.format(L.Setting_Profile_Use, L[inventory.inventoryType], L["Profile_" .. profileType])
				.. BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. L.Setting_Profile_SetAllHint .. FONT_COLOR_CODE_CLOSE
		end,
		choicesAutoSplitMenuOmitFunc = function(id, itemList)
			-- Can't use builtin (template) profiles, only live ones.
			return (not itemList[id] or itemList[id].builtin)
		end,
		onChange = function(settings, settingName, newValue)
			settings._inventoryClassInstance:SetProfile(newValue, profileType)
		end,
		choicesAutoSplitMenuFunc = function(settings, settingName, newValue)
			-- When the menu item is shift-clicked, set all OTHER profile types to the same value.
			-- Setting the profile type this menu item represents is still handled by onChange.
			if _G.IsShiftKeyDown() then
				for _, profileTypeToSet in pairs(BS_PROFILE_TYPE) do
					if profileTypeToSet ~= profileType then
						settings["profile" .. profileTypeToSet] = newValue
					end
				end
			end
		end,
		inventoryResortOnChange = true,
	}
	-- Display the active profile name.
	profileSettings[profileTypeKey .. "_Display"] = {
		name = "profile" .. profileType .. "_Display",
		notClickable = true,
		notCheckable = true,
		faded = true,
		type = BS_SETTING_TYPE.PLACEHOLDER,
		title = "",  -- Blank string to prevent localization warnings.
		textDisplayFunc = function(originalText, settingName, settings)
			return (BsProfiles:GetName(settings["profile" .. profileType]) or tostring(settings["profile" .. profileType]))
		end,
	}

end



-- This is where settings and their defaults are configured.
-- Tables in the arrays corresponding to each BS_SETTING_APPLICABILITY key
-- must conform to the `settingsTable` parameter definition of `Settings:InitSettingsInfo()`.
---@type table<BS_SETTING_APPLICABILITY, table[]>
Bagshui.config.Settings = {

	-- Inventory settings (also defines the Settings menu structure).
	-- Defaults can be overridden per-class instance in `Bagshui.config.InventorySettingOverrides`, below.
	[BS_SETTING_APPLICABILITY.INVENTORY] = {

		-- Autogenerated "Bagshui <inventoryType>" title with close button graphic.
		{
			mainTitle = true
		},

		{
			name = "windowLocked",
			scope = BS_SETTING_SCOPE.INVENTORY,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = false,
		},

		{
			submenuName = L.Menu_Settings_Advanced,
			settings = {
				{
					menuTitle = L.Menu_Settings_Commands,
				},
				{
					name = "resetStockState",
					type = BS_SETTING_TYPE.TRIGGER,
					onChange = function(settings, settingName, newValue)
						if settings._inventoryClassInstance then
							settings._inventoryClassInstance:ResetStockState()
						end
					end,
				},

				{
					menuTitle = L.Menu_Settings_Behaviors,
				},
				{
					name = "disableAutomaticResort",
					scope = BS_SETTING_SCOPE.CHARACTER,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = false,
				},


				{
					menuTitle = L.Menu_Settings_Window,
				},

				{
					menuTitle = BS_MENU_SUBTITLE_INDENT .. L.Menu_Settings_Anchoring,
				},

				{
					name = "windowAnchorXPoint",
					scope = BS_SETTING_SCOPE.INVENTORY,
					type = BS_SETTING_TYPE.CHOICES,
					defaultValue = "RIGHT",
					choices = POSITION_CHOICES.LEFT_RIGHT,
					onChange = windowAnchorChange,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "windowAnchorYPoint",
					scope = BS_SETTING_SCOPE.INVENTORY,
					type = BS_SETTING_TYPE.CHOICES,
					defaultValue = "BOTTOM",
					choices = POSITION_CHOICES.TOP_BOTTOM,
					onChange = windowAnchorChange,
					inventoryWindowUpdateOnChange = true,
				},


				{
					menuTitle = BS_MENU_SUBTITLE_INDENT .. L.Menu_Settings_Size,
				},

				-- Scale of the entire window.
				-- It might be nice to provide the ability to enter arbitrary
				-- values, but that's going to take more work.
				{
					name = "windowScale",
					scope = BS_SETTING_SCOPE.CHARACTER,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 1.0,
					min = 0.5,
					max = 2.05,
					step = 0.05,
					valueDisplayFunc = function(num)
						return (num * 100) .. "%"
					end,
					inventoryWindowUpdateOnChange = true,
				},


				{
					menuTitle = BS_MENU_SUBTITLE_INDENT .. L.Menu_Settings_Toggles,
				},
				{
					name = "windowDoubleClickActions",
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = false,
				},

			},
		},



		{
			menuTitle = L.Profile_Structure,
		},
		-- Display active Structure profile name and submenu for changing it.
		profileSettings.STRUCTURE_Display,
		profileSettings.STRUCTURE,

		-- Options submenu for Structure profile.
		{
			submenuName = L.Menu_Settings_Options,
			settings = {

				{
					menuTitle = L.Menu_Settings_ItemSlots,
				},
				{
					name = "stackEmptySlots",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.STRUCTURE,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryResortOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Defaults,
				},
				-- Default Sort Order.
				-- Valid choices are kept up to date by the SortOrders class.
				{
					name = "defaultSortOrder",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.STRUCTURE,
					type = BS_SETTING_TYPE.CHOICES,
					defaultValue = BS_DEFAULT_SORT_ORDER_ID,
					inventoryResortOnChange = true,
					-- Use the Auto-Split menu functionality to generate the Sort Order menu.
					-- The choices table that lists valid choices will be linked by Components\SortOrders.lua.
					choicesAutoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.SORT_ORDERS,
					inventoryWindowUpdateOnChange = true,
				},
				{
					menuTitle = L.Menu_Settings_Overrides,
				},
				{
					name = "hideGroupLabelsOverride",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.STRUCTURE,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = false,
					inventoryWindowUpdateOnChange = true,
				},
			},
		},



		{
			menuTitle = L.Profile_Design,
		},
		-- Display active Design profile name and submenu for changing it.
		profileSettings.DESIGN_Display,
		profileSettings.DESIGN,

		{
			submenuName = L.Menu_Settings_Colors,
			settings = {

				{
					menuTitle = L.Menu_Settings_Window,
				},
				{
					name = "windowUseSkinColors",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					hideFunc = useSkinColorsHide,
					nameFunc = useSkinColorsName,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "windowBackground",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = true,
					defaultValue = { 0.090, 0.085, 0.090, 0.95 },
					disableFunc = disableWhenUsingSkinColors,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "windowBorder",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = true,
					defaultValue = { 0.900, 0.850, 0.900, 0.98 },
					disableFunc = disableWhenUsingSkinColors,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_GroupDefaults,
				},
				{
					name = "groupUseSkinColors",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					hideFunc = useSkinColorsHide,
					nameFunc = useSkinColorsName,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "groupBackgroundDefault",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = true,
					defaultValue = { 0.090, 0.085, 0.090, 0.95 },
					disableFunc = disableWhenUsingSkinColors,
					inventoryWindowUpdateOnChange = true,
				},

				{
					name = "groupBorderDefault",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = true,
					defaultValue = { 0.900, 0.850, 0.900, 0.5 },
					disableFunc = disableWhenUsingSkinColors,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "groupLabelDefault",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = true,
					defaultValue = { 1, 1, 1, 0.8 },
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Toolbar,
				},
				{
					name = "toolbarButtonColor",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.COLOR,
					hasOpacity = false,
					defaultValue = BS_COLOR.YELLOW,
					inventoryWindowUpdateOnChange = true,
				},
			},


			-- Stock badge colors are baked into the images instead of being configurable.
			-- If this is re-enabled, the code in Ui:AssignItemToItemButton() needs to be uncommented as well,
			-- and this localization restored:
			-- ------------------------------
			-- ["itemStockBadgeNewColor"] = "New",
			-- ["itemStockBadgeNewColor_TooltipText"] = "Color of the 'New' stock change badge",
			-- ["itemStockBadgeDownColor"] = "Decreased",
			-- ["itemStockBadgeDownColor_TooltipText"] = "Color of the 'Decreased' stock change badge",
			-- ["itemStockBadgeUpColor"] = "Increased",
			-- ["itemStockBadgeUpColor_TooltipText"] = "Color of the 'Increased' stock change badge",
			-- ------------------------------
			-- {
			-- 	menuTitle = L.Menu_Settings_StockBadgeColors,
			-- },
			-- {
			-- 	name = "itemStockBadgeNewColor",
			-- 	type = BS_SETTING_TYPE.COLOR,
			-- 	defaultValue = { 1, 0.9, 0 },
			-- },
			-- {
			-- 	name = "itemStockBadgeUpColor",
			-- 	type = BS_SETTING_TYPE.COLOR,
			-- 	defaultValue = { 0, 0.9, 0.1 },
			-- },
			-- {
			-- 	name = "itemStockBadgeDownColor",
			-- 	type = BS_SETTING_TYPE.COLOR,
			-- 	defaultValue = { 1, 0.15, 0.15 },
			-- },
		},

		{
			submenuName = L.Menu_Settings_Size,
			settings = {

				{
					menuTitle = L.Menu_Settings_Window,
				},
				{
					name = "windowMaxColumns",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 13,
					min = 10,
					max = 30,
					inventoryWindowUpdateOnChange = true,
				},


				{
					menuTitle = L.Menu_Settings_ItemSlots,
				},
				{
					name = "itemSize",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 35,
					min = 20,
					max = 60,
					step = 5,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemMargin",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 2,
					min = 0,
					max = 15,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Groups,
				},
				{
					name = "groupPadding",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 0,
					min = 0,
					max = 15,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "groupMargin",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 8,
					min = 0,
					max = 15,
					inventoryWindowUpdateOnChange = true,
				},

			}
		},

		{
			submenuName = L.Menu_Settings_View,
			settings = {

				{
					menuTitle = L.Menu_Settings_Interface
				},

				{
					name = "showHeader",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					name = "showFooter",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					name = "showBagBar",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					name = "showHearthstone",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryCacheUpdateOnChange = true,
				},

				{
					name = "showMoney",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Groups,
				},

				{
					name = "showGroupLabels",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					textDisplayFunc = function(name, settingName, settings)
						return name .. (settings.hideGroupLabelsOverride and (LIGHTYELLOW_FONT_COLOR_CODE .. " ×" .. FONT_COLOR_CODE_CLOSE) or "")
					end,
					tooltipTextDisplayFunc = function(tooltipText, settingName, settings)
						return string.gsub(
							tooltipText,
							"~1~",
							(
								settings.hideGroupLabelsOverride
								and (LIGHTYELLOW_FONT_COLOR_CODE .. L.Setting_DisabledBy_HideGroupLabels .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE)
								or ""
							)
						)
					end,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Tinting,
				},
				{
					name = "itemUsableColors",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_Badges,
				},
				{
					name = "itemQualityBadges",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					textDisplayFunc = colorblindModeOverrideTextFunc,
					tooltipTextDisplayFunc = colorblindModeOverrideTooltipFunc,
					defaultValue = false,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemUsableBadges",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					textDisplayFunc = colorblindModeOverrideTextFunc,
					tooltipTextDisplayFunc = colorblindModeOverrideTooltipFunc,
					defaultValue = false,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemActiveQuestBadges",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemStockBadges",
					scope = BS_SETTING_SCOPE.INVENTORY,
					profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = true,
					inventoryWindowUpdateOnChange = true,
				},

			},
		},



		{
			menuTitle = L.Menu_Settings_General,
		},

		{
			submenuName = L.Menu_Settings_DefaultProfiles,
			settings = defaultProfileSettings,
		},



		{
			submenuName = L.Menu_Settings_More,
			tooltipTitle = L.Menu_Settings_More_TooltipTitle,
			settings = {
				{
					menuTitle = "Bagshui " .. BS_VERSION,
				},
				{
					name = "openAbout",
					title = string.format(L.Symbol_Ellipsis, L.About),
					tooltipTitle = L.About,
					type = BS_SETTING_TYPE.TRIGGER,
					onChange = function(settings, settingName, newValue)
						Bagshui:CloseMenus()
						BsAboutDialog:Open()
					end,
				},
				{
					name = "showWikiUrl",
					title = string.format(L.Symbol_Ellipsis, L.Help),
					tooltipTitle = L.Help,
					type = BS_SETTING_TYPE.TRIGGER,
					onChange = function(settings, settingName, newValue)
						Bagshui:CloseMenus()
						Bagshui.prototypes.Ui:ShowUrl(BS_WIKI_URL)
					end,
				},

				{
					menuTitle = L.Menu_Settings_Accessibility,
				},
				{
					name = "colorblindMode",
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = false,
					inventoryWindowUpdateOnChange = true,
				},

				{
					menuTitle = L.Menu_Settings_ChangeTiming,
				},
				{
					name = "itemStockBadgeFadeDuration",
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 15,
					min = 0,
					max = 1440,  -- 1 day
					-- Hardcoding choices seems simplest here.
					choices = {
						{
							value = 0,
							text = L.NoneParenthesis
						},
						{
							value = 15,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 15)
						},
						{
							value = 30,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 30)
						},
						{
							value = 45,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 45)
						},
						{
							value = 60,
							text = string.format(_G.INT_SPELL_DURATION_HOURS, 1)
						},
						{
							value = 120,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 2)
						},
						{
							value = 180,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 3)
						},
						{
							value = 240,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 4)
						},
						{
							value = 300,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 5)
						},
						{
							value = 360,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 6)
						},
						{
							value = 720,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 12)
						},
						{
							value = 1440,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 24)
						},
					},
					onChange = function(settings, settingName, newValue)
						-- If fade duration is set higher than the change expiration,
						-- find the highest fade duration that's lower than the
						-- change expiration and select that value instead.
						if settings.itemStockBadgeFadeDuration > settings.itemStockChangeExpiration then
							local settingInfo = settings:GetSettingInfo("itemStockBadgeFadeDuration")
							local newValue = settingInfo.defaultValue
							for i = table.getn(settingInfo.choices), 1, -1 do
								if settingInfo.choices[i].value <= settings.itemStockChangeExpiration then
									newValue = settingInfo.choices[i].value
									break
								end
							end
							settings.itemStockBadgeFadeDuration = newValue
						end
					end,
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemStockChangeExpiration",
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.NUMBER,
					defaultValue = 45,
					min = 1,
					max = 10080,  -- 1 week
					choices = {
						{
							value = 15,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 15)
						},
						{
							value = 30,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 30)
						},
						{
							value = 45,
							text = string.format(_G.INT_SPELL_DURATION_MIN, 45)
						},
						{
							value = 60,
							text = string.format(_G.INT_SPELL_DURATION_HOURS, 1)
						},
						{
							value = 120,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 2)
						},
						{
							value = 360,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 6)
						},
						{
							value = 720,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 12)
						},
						{
							value = 1440,
							text = string.format(_G.INT_SPELL_DURATION_HOURS_P1, 24)
						},
						{
							value = 2880,
							text = string.format(_G.INT_SPELL_DURATION_DAYS, 2)
						},
						{
							value = 4320,
							text = string.format(_G.INT_SPELL_DURATION_DAYS, 3)
						},
						{
							value = 10080,
							text = string.format(_G.INT_SPELL_DURATION_DAYS, 7)
						}
					},
					inventoryWindowUpdateOnChange = true,
				},
				{
					name = "itemStockChangeClearOnInteract",
					scope = BS_SETTING_SCOPE.ACCOUNT,
					type = BS_SETTING_TYPE.BOOL,
					defaultValue = false,
				},


				{
					menuTitle = L.Menu_Settings_Behaviors,
				},
				{
					submenuName = L.Menu_Settings_Integration,
					-- Insert the hook settings submenu.
					settings = hookSettings,
				},


				{
					menuTitle = L.Menu_Settings_Open,
				},

				{
					name = "openLogWindow",
					title = string.format(L.Symbol_Ellipsis, L.LogWindow),
					tooltipTitle = L.LogWindow,
					type = BS_SETTING_TYPE.TRIGGER,
					onChange = function(settings, settingName, newValue)
						Bagshui:CloseMenus()
						BsLogWindow:Open()
					end,
				},
				{
					name = "openShare",
					title = string.format(L.Symbol_Ellipsis, L.ImportSlashExport),
					tooltipTitle = L.ImportSlashExport,
					type = BS_SETTING_TYPE.TRIGGER,
					onChange = function(settings, settingName, newValue)
						Bagshui:CloseMenus()
						BsShare:Open()
					end,
				},
			},
		},



		-- Hidden settings.

		-- Window will grow horizontally from this point on the windowAnchorXPoint side of the screen
		-- (expressed in the WoW coordinate system where the bottom right is 0,0).
		-- Updated automatically when the inventory frame is moved.
		{
			name = "windowAnchorXOffset",
			scope = BS_SETTING_SCOPE.INVENTORY,
			hidden = true,
			type = BS_SETTING_TYPE.NUMBER,
			defaultValue = -30,
		},

		-- Window will grow vertically from this point on the windowAnchorYPoint side of the screen
		-- (expressed in the WoW coordinate system where the bottom right is 0,0).
		-- Updated automatically when the inventory frame is moved.
		{
			name = "windowAnchorYOffset",
			scope = BS_SETTING_SCOPE.INVENTORY,
			hidden = true,
			type = BS_SETTING_TYPE.NUMBER,
			defaultValue = 90,
		},

		-- Tint item tooltip borders to match the item's quality level.
		{
			name = "qualityColorTooltipBorders",
			scope = BS_SETTING_SCOPE.CHARACTER,
			type = BS_SETTING_TYPE.BOOL,
			hidden = true,
			defaultValue = false,
		},

		-- Content Alignment.
		-- Groups and item slots will anchor to this side of the window.
		-- Code to actually make this work probably isn't fully functional.
		{
			name = "windowContentAlignment",
			scope = BS_SETTING_SCOPE.INVENTORY,
			hidden = true,
			defaultValue = POSITION_CHOICES.LEFT_RIGHT[2].value,  -- "RIGHT"
			type = BS_SETTING_TYPE.CHOICES,
			choices = POSITION_CHOICES.LEFT_RIGHT,
		},

		-- The right-click/Alt+click attach preferences are hidden because we rely
		-- on other addons for some of the functionality, so turning them off doesn't
		-- fully disable them. Examples:
		-- - aux and the "Mail" addon provides right-click.
		-- - CT_MailMod, Postal, and Postal Returned provide alt+click.
		-- It's possible to do some additional work that will override the state
		-- of things when these preferences are false, but is there anyone who
		-- actually needs to turn this stuff off?
		{
			name = "rightClickAttach",
			scope = BS_SETTING_SCOPE.ACCOUNT,
			hidden = true,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = true,
		},
		{
			name = "altClickAttach",
			scope = BS_SETTING_SCOPE.ACCOUNT,
			hidden = true,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = true,
		},


		-- Set to true once the hint about displaying the Bagshui tooltip is acknowledged.
		{
			name = "hint_bagshuiTooltip",
			scope = BS_SETTING_SCOPE.ACCOUNT,
			hidden = true,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = false,
		},



		-- When the Ignore button is clicked on the any compatibility
		-- warning, these will be set to true so the alert won't reappear unless
		-- an associated Bagshui setting is changed.
		{
			name = "compat_pfUIBagsIgnored",
			scope = BS_SETTING_SCOPE.CHARACTER,
			hidden = true,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = false,
		},
		{
			name = "compat_pfUIBagsLastSetting",
			scope = BS_SETTING_SCOPE.CHARACTER,
			hidden = true,
			type = BS_SETTING_TYPE.CHOICES,
			choices = {
				{
					value = "-1",
					text = "Unknown",
				},
				{
					value = "0",
					text = "Enabled",
				},
				{
					value = "1",
					text = "Disabled",
				},
			},
			defaultValue = "0",
		},
		{
			name = "compat_tDFAllInOneBagsIgnored",
			scope = BS_SETTING_SCOPE.CHARACTER,
			hidden = true,
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = false,
		},
		{
			name = "compat_tDFAllInOneBagsLastSetting",
			scope = BS_SETTING_SCOPE.CHARACTER,
			hidden = true,
			type = BS_SETTING_TYPE.NUMBER,
			defaultValue = -1,
		},


	},




	-- Per-Group Settings.
	-- The structure here is intentionally different from the Inventory settings:
	-- - This is `<settingName> = { <SettingInfo> }`
	-- - No menu structure here; it's in Inventory.Menus.lua.
	-- - Localization is also handled in Inventory.Menus.lua.
	[BS_SETTING_APPLICABILITY.GROUP] = {
		background = {
			type = BS_SETTING_TYPE.COLOR,
			hasOpacity = true,
			defaultValue = { 0.090, 0.085, 0.090, 0.5 },
			inventoryWindowUpdateOnChange = true,
		},
		border = {
			type = BS_SETTING_TYPE.COLOR,
			hasOpacity = true,
			defaultValue = { 0.900, 0.850, 0.900, 0.5 },
			inventoryWindowUpdateOnChange = true,
		},
		label = {
			type = BS_SETTING_TYPE.COLOR,
			hasOpacity = true,
			defaultValue = { 1, 1, 1, 0.8 },
			inventoryWindowUpdateOnChange = true,
		},
		hideStockBadge = {
			type = BS_SETTING_TYPE.BOOL,
			defaultValue = false,
			inventoryWindowUpdateOnChange = true,
		},
	}

}




-- Change defaults for specific inventory types here.
-- Only `<settingName> = <value>` is needed, not the entire settings table.
---@type table<BS_INVENTORY_TYPE, table<string, any>>
Bagshui.config.InventorySettingOverrides = {

	[BS_INVENTORY_TYPE.BANK] = {
		-- Bank should start at the bottom-left
		windowAnchorXPoint = "LEFT",
		windowAnchorXOffset = 20,
	},

}


end)