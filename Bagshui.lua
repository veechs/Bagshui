-- Bagshui Core
-- Customizable auto-categorizing and sorting all-in-one inventory replacement for Vanilla WoW 1.12.
-- https://github.com/veechs/Bagshui
--
-- Most code is split into file in Components; what's here is close to the minimum to get things bootstrapped.
--
-- Raises:
-- - BAGSHUI_ADDON_LOADED
-- - BAGSHUI_LOG_UPDATE

-- Provide access to the global environment without using `getglobal()`.
-- Must be declared before `bagshuiEnvironment` because things in there use it.
local _G = _G or getfenv()


-- This environment will be loaded for all Bagshui code via `setfenv()`.  
-- Top-level constants should be declared here as `BS_CONSTANT_NAME`.  
-- Other constants can be added later via `Bagshui:AddConstants()`.  
local bagshuiEnvironment = {
	-- Pull basic information into the environment.

	BS_VERSION = "",  -- Intentionally empty; will be filled from Bagshui.toc by `Bagshui:AddonLoaded()`.

	-- Increment to wipe SavedVariables.
	BS_DATA_VERSION = 1,

	-- Imports of this version or lower can be processed.
	-- Stored in the `bagshuiExportFormat` key of the export object table.
	-- This may never change, but it seems like a good thing to track just in case.
	BS_EXPORT_VERSION = 1,

	-- Bagshui homepage.
	BS_URL = "github.com/veechs/Bagshui",
	-- Bagshui wiki root. MUST end in a slash.
	BS_WIKI_URL = "github.com/veechs/Bagshui/wiki/",
	-- Bagshui wiki pages. Need to be concatenated onto `BS_WIKI_URL`.
	BS_WIKI_PAGES = {
		EditMode = "Edit-Mode",
		Categories = "Categories",
		CharacterData = "Searching#managing-character-data",
		Profiles = "Profiles",
		Rules = "Rules",
		Search = "Searching",
		Share = "Import-Export",
		SortOrders = "Sort-Orders",
	},


	-- Fallback locale, used if no matching locale for the current WoW client is found.
	BS_DEFAULT_LOCALE = "enUS",


	-- Defaults for categorizing and sorting.
	BS_DEFAULT_CATEGORY_ID = "Uncategorized",
	BS_DEFAULT_CATEGORY_SEQUENCE = 30,
	BS_DEFAULT_BUILTIN_CATEGORY_SEQUENCE = 90,
	-- This has to be here, not in SortOrders.lua, so it's available to Setting configuration.
	BS_DEFAULT_SORT_ORDER_ID = "Default",

	-- Default profiles used at first login and for fallback if the configured default profile is unavailable.
	-- ```
	-- { [BS_PROFILE_TYPE value] = "ProfileId" }
	-- ```
	---@type table<BS_PROFILE_TYPE, string>
	BS_DEFAULT_PROFILE = {
		Structure = "Bagshui",
		Design = "Bagshui",
	},


	---@enum BS_INVENTORY_TYPE
	-- Allowed inventory class types.
	-- Note that values get lowercased automatically for SavedVariables storage.
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_INVENTORY_TYPE = {
		BAGS = "Bags",
		BANK = "Bank",
		KEYRING = "Keyring",
	},

	-- Control the order in which toolbar icons and menu items for inventory types appear.
	-- ```
	-- { [BS_INVENTORY_TYPE value1], ... [BS_INVENTORY_TYPE valueN] }
	-- ```
	---@type string[]
	BS_INVENTORY_TYPE_UI_ORDER = {
		"Bags",
		"Bank",
		"Keyring",
	},


	---@enum BS_PROFILE_TYPE
	-- Allowed profile types.
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_PROFILE_TYPE = {
		STRUCTURE = "Structure",
		DESIGN = "Design",
	},

	-- Control the order in which the Settings menus for default profiles appear.
	-- ```
	-- { [BS_PROFILE_TYPE key1], ... [BS_PROFILE_TYPE key2] }
	-- ```
	---@type string[]
	BS_PROFILE_ORDER = {
		"STRUCTURE",
		"DESIGN",
	},


	-- Names of keys in the config file for various types of data.
	-- ```
	-- { UPPERCASE = "camelCase" }
	-- ```
	---@type table<string, string>
	BS_CONFIG_KEY = {
		CHARACTERS = "characters",
		CHARACTER_INFO = "info",
		COLORS = "colors",
		DATA_VERSION = "dataVersion",
		OBJECT_VERSIONS = "objectVersions",
		LOG = "log",
	},


	---@enum BS_SETTING_APPLICABILITY
	-- Used in Config\Settings.lua and elsewhere to specify what object a group of settings apply to.
	-- ```
	-- { UPPERCASE = "UPPERCASE" }
	-- ```
	---@type table<string, string>
	BS_SETTING_APPLICABILITY = {
		INVENTORY = "INVENTORY",
		GROUP = "GROUP",
	},

	---@enum BS_SETTING_SCOPE
	-- Used in Config\Settings.lua to specify the `scope` of a setting (i.e. what level it's stored at).
	-- See `Settings:InitSettingsInfo()` for more information.
	-- ```
	-- { UPPERCASE = "UPPERCASE" }
	-- ```
	---@type table<string, string>
	BS_SETTING_SCOPE = {
		ACCOUNT = "ACCOUNT",
		CHARACTER = "CHARACTER",
		INVENTORY = "INVENTORY",
	},


	---@enum BS_SETTING_PROFILE_SCOPE
	-- Used in Config\Settings.lua to specify the `profileScope` of a setting. Only works when
	-- `scope` is "INVENTORY". See `Settings:InitSettingsInfo()` for more information.
	-- ```
	-- { UPPERCASE = "UPPERCASE" }
	-- ```
	---@type table<string, string>
	BS_SETTING_PROFILE_SCOPE = {
		STRUCTURE = "STRUCTURE",
		DESIGN = "DESIGN",
		BEHAVIOR = "BEHAVIOR",
	},

	-- Data types for settings, used in a setting's `type` property in Config\Settings.lua.
	-- The Settings class expects the values of these entries to correspond to `Settings:Validate<value>()`.
	-- For example, `NUMBER = "Number"` would map to `Settings:ValidateNumber()`.
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_SETTING_TYPE = {
		BOOL = "Bool",
		CHOICES = "Choices",
		COLOR = "ColorRgba",
		NUMBER = "Number",
		TRIGGER = "Trigger",
		PLACEHOLDER = "Placeholder",
	},


	---@enum BS_AUTO_SPLIT_MENU_TYPE
	-- Globally recognized auto-split menu types.
	-- Needs to be defined here so it can be used in Config\Settings.lua.
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_AUTO_SPLIT_MENU_TYPE = {
		CATEGORIES = "Categories",
		CHARACTERS = "Characters",
		PROFILES = "Profiles",
		SORT_ORDERS = "SortOrders",
		SORT_FIELDS = "SortFields",
	},
	----@alias BS_AUTO_SPLIT_MENU_TYPE table<string, string>


	-- Custom colors.
	-- ```
	-- { UPPERCASE = { r, g, b, [a] } }
	-- ```
	---@type table<string, number[]>
	BS_COLOR = {
		-- This is slightly different from BS_FONT_COLOR.BAGSHUI
		-- because colors don't look quite the same when applied to
		-- large areas.
		BAGSHUI_LOGO = { 0.692, 0.139, 0.416, },

		-- General colors.
		RED         = { 0.8,   0,   0 },
		FULL_RED    = {   1,   0,   0 },
		DARK_RED    = {   1, 0.1, 0.1 },
		GRAY        = { 0.5, 0.5, 0.5 },
		GREEN       = {   0, 0.8,   0 },
		LIGHT_GREEN = { 0.2, 0.9, 0.2 },
		DARK_GREEN  = {   1, 0.8, 0.1 },
		WHITE       = {   1,   1,   1 },
		YELLOW      = { 0.9, 0.72, 0.15 },  -- Default toolbar button color.

		-- Factions.
		FACTION_ALLIANCE = { 0.15, 0.25, 0.95 },
		FACTION_HORDE = { 0.85, 0.15, 0.10 },
		FACTION_UNKNOWN = { 0.60, 0.50, 0.30 },

		-- Item slot button texture colors.
		ITEM_SLOT_STATE_NORMAL = { 1, 1, 1, 1 },
		ITEM_SLOT_STATE_LOCKED = { 0.5, 0.5, 0.5, 1 },
		ITEM_SLOT_HIGHLIGHT = { 1, 1, 0.35 },

		-- Icon button colors.
		UI_GREEN = { 0.6, 0.82, 0.3 },
		UI_ORANGE = { 1, 0.45, 0.1 },
		ICON_BUTTON_HOVER = { 0.95, 0.9, 0.9, 0.25 },

		CODE_EXAMPLE = { 0.83, 0.47, 0.65 },

		-- Print() and friends colors.
		PRINT_BAGSHUI = { 0.86, 0.259, 0.573, },
		PRINT_ERROR = { 0.95, 0, 0 },
		PRINT_WARNING = { 0.95, 0.45, 0 },
	},

	-- Custom font colors, defined as "|cff<hex color>".
	-- Everything from `BS_COLOR` will automatically be converted to escape strings
	-- populated automatically by `Bagshui:PostUtilInit()`.
	---@type table<string, string>
	BS_FONT_COLOR = {
		BAGSHUI = "|cffdb4e97",
	},


	-- Predefined border types, consumed by `Ui:SetFrameBackdrop()`.
	-- ```
	-- { UPPERCASE = { `<frame>:SetBackdrop()` table } }
	-- ```
	---@type table<string, table>
	BS_BORDER = {
		NONE = {},
		CURVED = {
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			edgeSize = 16,
			insets = 4,
		},
		SOLID = {
			edgeFile = "Interface\\Buttons\\WHITE8X8",
			edgeSize = 1,
			insets = 1,
		},
	},


	-- Tooltip hover delays, used by `Bagshui:ShowTooltipAfterDelay()` and associated functions.
	-- ```
	-- { UPPERCASE = <number> }
	-- ```
	---@type table<string, number>
	BS_TOOLTIP_DELAY_SECONDS = {
		DEFAULT = 1,
		TOOLBAR_DEFAULT = 2,
		TOOLBAR_EXPAND_DEFAULT = 4,
		-- After a tooltip is shown, how long should the SHORTENED value be used?
		USE_SHORTENED_AFTER_LAST_SHOW_FOR = 2,
		SHORTENED = 0.3,
	},


	-- It looks nicer to indent some menu values under headers (like the Edit Mode menu for groups).
	---@type string
	BS_MENU_SUBTITLE_INDENT = "    ",

	-- When checking whether a window with a saved position might be offscreen,
	-- how close to the edge does it need to be?
	BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD = 15,

	-- Empty item used to initialize inventory cache entries.
	-- Values here can't be nil or Lua drops them.
	-- ```
	-- { camelCase = <value> }
	-- ```
	---@type table<string, string|number|table>
	BS_ITEM_SKELETON = {
		baseName = "",  -- Name without random suffix, if applicable.
		bagNum = -99,  -- Using an invalid container ID since 0 is Backpack.
		bagType = "",
		charges = 0,
		count = 0,
		equipLocationLocalized = "",
		equipLocation = "",
		emptySlot = 0,  -- Using 0/1 instead of true/false for easy sorting
		id = 0,
		itemLink = "",  -- Item link (|cffffffff|Hitem:12345:0:0:0|h[Name]|h|r)
		itemString = "",  -- Item string (item:12345:0:0:0)
		locked = 0,
		maxStackCount = 0,
		minLevel = "",
		name = "",
		quality = 1,
		qualityLocalized = "",
		readable = 0,
		slotNum = 0,
		subtype = "",
		suffixName = "",  -- Random suffix, if applicable.
		tooltip = "",
		texture = "Interface\\Icons\\INV_Misc_QuestionMark",
		type = "",
		uncategorized = 0,  -- Using 0/1 instead of true/false for easy sorting

		bagshuiGroupId = "",
		bagshuiCategoryId = "",
		bagshuiDate = -1,
		bagshuiInventoryType = "",
		bagshuiStockState = "",

		-- Disabled properties and reasons for disabling.

		-- itemStringGeneric is itemString without enchantId and uniqueId. This
		-- was never used anywhere in EngInventory, so there doesn't seem to be
		-- any real use for it. It's commented out throughout Bagshui in case
		-- there's ever a reason to bring it back.
		-- itemStringGeneric = "",
	},

	-- Which properties can be used in sort orders?
	-- ```
	-- { [BS_ITEM_SKELETON key1], ... [BS_ITEM_SKELETON keyN] }
	-- ```
	---@type string[]
	BS_ITEM_PROPERTIES_ALLOWED_IN_SORT_ORDERS = {
		"bagNum",
		"bagType",
		"charges",
		"count",
		"equipLocationLocalized",
		"equipLocation",
		"emptySlot",
		"id",
		"itemLink",
		"itemString",
		"minLevel",
		"name",
		"quality",
		"slotNum",
		"subtype",
		"tooltip",
		"type",
		"uncategorized",
	},

	-- Rule functions that correspond to item properties.
	-- This controls what appears in the Item Information menu, tooltip, and window.
	-- ```
	-- { [BS_ITEM_SKELETON key] = { "Function1()", "FunctionN(%s)" }|true }
	-- ```
	-- * `%s` will be replaced with the item property value.
	-- * Set `true` if there is no rule function but the property should still appear.
	---@type table<string, string[]|boolean>
	BS_ITEM_PROPERTIES_TO_FUNCTIONS = {
		activeQuest            = { 'ActiveQuest()' },
		bagNum                 = { 'Bag(%s)' },
		bagType                = { 'BagType("%s")' },
		bindsOnEquip           = { 'BindsOnEquip()' },
		count                  = { 'Count(%s)', 'Count(Min, Max)' },
		emptySlot              = { 'EmptySlot()' },
		equipLocation          = { 'EquipLocation("%s")' },
		equipLocationLocalized = { 'EquipLocation("%s")' },
		id                     = { 'Id(%s)' },
		itemString             = { 'ItemString("%s")' },
		minLevel               = { 'MinLevel(%s)', 'CharacterLevelRange(±levels)', 'CharacterLevelRange(LevelsBelow, LevelsAbove)' },
		name                   = { 'Name("%s")', 'NameExact("%s")' },
		periodicTable          = { 'PeriodicTable("%s")'},
		quality                = { 'Quality(%s)' },
		qualityLocalized       = { 'Quality("%s")' },
		soulbound              = { 'Soulbound()' },
		stacks                 = { 'Stacks()' },
		subtype                = { 'Subtype("%s")' },
		tooltip                = { 'Tooltip("Search String")' },
		type                   = { 'Type("%s")' },
		uncategorized          = true,
	},

	-- These will supplement and/or override the item's properties in the
	-- Item Information menu/tooltip/window.
	--
	-- All references must be explicit here since the Bagshui environment isn't built up yet.
	-- In other words, use `Bagshui.environment.L` instead of `L`, `Bagshui.components.Rules` instead of `BsRules`, etc.
	--
	-- ```
	-- { [BS_ITEM_SKELETON key] = function(item, BS_ITEM_INFO_DISPLAY_TYPE) -> string|string[] }
	-- ```
	---@type table<string, function>
	BS_REALTIME_ITEM_INFO_PROPERTIES = {

		activeQuest = function(item)
			return tostring(Bagshui.components.Rules:Match("ActiveQuest()", item))
		end,

		bindsOnEquip = function(item)
			return tostring(Bagshui.components.Rules:Match("BindsOnEquip()", item))
		end,

		emptySlot = function(item)
			return tostring(item.emptySlot == 1)
		end,

		periodicTable = function(item, displayType)
			Bagshui.components.ItemInfo:GetPeriodicTableSets(item)
			-- Only show the count of sets in the right-click menu or tooltip.
			if displayType ~= Bagshui.environment.BS_ITEM_INFO_DISPLAY_TYPE.TEXT then
				return string.format(Bagshui.environment.L.Suffix_Sets, table.getn(Bagshui.components.ItemInfo.periodicTableSetCache))
			end
			-- Text mode (Item Information window) should show the entire list of sets.
			return Bagshui.components.ItemInfo.periodicTableSetCache
		end,

		soulbound = function(item)
			return tostring(Bagshui.components.Rules:Match("soulbound()", item))
		end,

		stacks = function(item)
			return tostring(Bagshui.components.Rules:Match("stacks()", item))
		end,

		tooltip = function(item, displayType)
			if item.tooltip == "" then
				return nil
			end
			-- Text mode (Item Information window) should show the entire tooltip.
			if displayType == Bagshui.environment.BS_ITEM_INFO_DISPLAY_TYPE.TEXT then
				return "\n" .. item.tooltip
			end
			-- Only show the first line of the tooltip in the right-click menu or tooltip.
			-- (%C is non-control characters, which excludes newline.)
			local _, _, tooltip = string.find(item.tooltip, "^(%C+)")
			if tooltip ~= item.tooltip then
				tooltip = string.format(Bagshui.environment.L.Symbol_Ellipsis, tooltip)
			end
			return tooltip
		end,

		uncategorized = function(item)
			return tostring(item.uncategorized == 1)
		end,
	},

	-- Item properties that will be hidden from the Bagshui info tooltip when the item isn't in a bag.
	---@type table<string, true>
	BS_ITEM_PROPERTIES_SUPPRESSED_IN_TOOLTIP_OUTSIDE_INVENTORY = {
		bagNum = true,
		count = true,  -- Count is always 0 and looks silly.
		emptySlot = true,
		periodicTable = true,  -- Could allow this in the future if a way to open the info window for items not in inventory is devised.
		tooltip = true,  -- Same as periodicTable.
		slotNum = true,
		uncategorized = true,
	},

	-- List of item properties sorted by friendly (localized) name.
	-- Automatically built out by `ItemInfo:BuildSortedItemTemplatePropertyList()` the first time it's needed.
	---@type string[]
	BS_ITEM_PROPERTIES_SORTED = nil,


	-- In addition to the bagshuiStockState item property, stock state table values are used
	-- to determine the following stock badge attributes, so they must be PascalCase:
	-- - Textures: `ItemSlot\Stock-<value>.tga`
	-- - Colors: `settings.itemStockBadge<value>Color`
	-- - Tooltip strings: `L["Stock_" .. <value>]`
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_ITEM_STOCK_STATE = {
		NEW = "New",
		UP = "Up",
		DOWN = "Down",
		NO_CHANGE = "",
	},


	---@enum BS_RULE_ENVIRONMENT_VARIABLES
	-- Variables that are pre-populated into the Rule evaluation environment.
	-- Rule functions can add their own as well.
	---@type table<string, string>
	BS_RULE_ENVIRONMENT_VARIABLES = {
		Active = "~Active~",
		Eligible = "~Eligible~",
		Inactive = "~Inactive~",
		Ineligible = "~Ineligible~",
	},


	---@enum BS_RULE_ARGUMENT_TYPE
	-- Define what argument types are accepted by the `validArgumentTypes` parameter of `Rules:TestItemAttribute()`.
	-- - Keys are one or more Lua types **in UPPERCASE** separated by commas with **no spaces**.
	-- - Every possible order of key types must be included, so if `STRING,NUMBER` is a key, `NUMBER,STRING` must also be a key.
	--   (This could be automated but it's not really worth it.)
	-- - Values are tables with keys as Lua types and values of true.
	-- ```
	-- { ["TYPE1,TYPE2"] = { type1 = true, typeN = true} }
	-- ```
	---@type table<string, table<string, boolean>>
	BS_RULE_ARGUMENT_TYPE = {
		["STRING"] = {
			string = true,
		},
		["NUMBER"] = {
			number = true,
		},
		["STRING,NUMBER"] = {
			string = true,
			number = true
		},
		["NUMBER,STRING"] = {
			string = true,
			number = true
		},
	},

	---@enum BS_RULE_MATCH_TYPE
	-- What types of matches will `Rules:TestItemAttribute()` accept?
	-- ```
	-- { UPPERCASE = "UPPERCASE" }
	-- ```
	---@type table<string, string>
	BS_RULE_MATCH_TYPE = {
		EQUALS = "EQUALS",
		CONTAINS = "CONTAINS",
		BETWEEN = "BETWEEN",
	},


	---@enum BS_HOOK_ACTION
	-- Hook class action parameter values.
	-- ```
	-- { UPPERCASE = "PascalCase" }
	-- ```
	---@type table<string, string>
	BS_HOOK_ACTION = {
		REGISTER = "Register",
		UNREGISTER = "Unregister",
		CHECK = "Check",
	},


	---@enum BS_LOG_MESSAGE_TYPE
	-- Log message severities.
	-- ```
	-- { UPPERCASE = number }
	-- ```
	---@type table<string, number>
	BS_LOG_MESSAGE_TYPE = {
		INFORMATION = 1,
		WARNING = 2,
		ERROR = 3,
	},

	-- How to localize log message severities.
	-- - Array index is severity number from `BS_LOG_MESSAGE_TYPE`,
	-- - Value is the string to look up in `L`.
	---@type string[]
	BS_LOG_TYPE_LOCALIZATION_KEY = {
		"Log_Info",
		"Log_Warn",
		"Log_Error",
	},

	-- How to color log messages based on severity.
	-- - Array index is severity number from `BS_LOG_MESSAGE_TYPE`,
	-- - Value is the font formatting string.
	---@type string[]
	BS_LOG_MESSAGE_COLOR = {
		_G.HIGHLIGHT_FONT_COLOR_CODE,
		"|cFFFF5F00",
		_G.RED_FONT_COLOR_CODE,
	},

	-- Keep this many log entries.
	---@type number
	BS_LOG_LIMIT = 75,

	-- Date formatting for log entries.
	---@type string
	BS_LOG_DATE_STRING = "%Y-%m-%d %H:%M:%S",

	-- Ensure debug is never turned on in production by requiring another addon to set BAGSHUI_DEBUG to true prior to Bagshui loading.
	-- (I'm doing this via a one-line addon named !BagshuiDebug whose only code is BAGSHUI_DEBUG = true).
	---@type boolean
	BS_DEBUG = _G.BAGSHUI_DEBUG or false,

	-- Is SuperWoW loaded? Since it's a DLL injection, not an addon, IsAddOnLoaded() won't help here.
	---@type boolean
	BS_SUPER_WOW_LOADED = type(_G.SetAutoloot) == "function",


	-- Localization helpers.

	BS_NEWLINE = "\n",


	-- These are accessible via metatable, but explicit access is going to be slightly faster.
	-- Not capturing font colors in case they're changed.

	_G = _G,
	error = _G.error,
	ipairs = _G.ipairs,
	pairs = _G.pairs,
	loadstring = _G.loadstring,
	math = _G.math,
	mod = _G.mod,
	tonumber = _G.tonumber,
	tostring = _G.tostring,
	string = _G.string,
	table = _G.table,
	type = _G.type,

	-- Other addons.
	pfUI = _G.IsAddOnLoaded("pfUI") and _G.pfUI or nil,


	-- Contain the _ dummy variable within the Bagshui environment.
	_ = 0,
}

-- Configure environment so global variables are still accessible.
setmetatable(bagshuiEnvironment, { __index = _G })

-- Replace current execution environment with Bagshui environment.
---@diagnostic disable-next-line: param-type-mismatch
setfenv(1, bagshuiEnvironment)



-- Namespace for everything Bagshui
local Bagshui = {

	-- Class instances go here.
	-- ```
	-- { PascalCase = class }
	-- ```
	---@type table<string, table>
	components = {},

	-- Class prototypes go here.
	-- ```
	-- { PascalCase = prototype }
	-- ```
	---@type table<string, table>
	prototypes = {},

	-- Configuration files in the Config folder should add data here.
	---@type table<string, any>
	config = {},

	-- Embedded libraries.
	---@type table<string, table>
	libs = {
		-- PeriodicTableEmbed is added when Libs\PeriodicTable.xml is processed, prior to Bagshui.lua.
		PT = _G.PeriodicTableEmbed:GetInstance("1")
	},

	-- Name and realm identifier of the current character.
	-- Populated in `Bagshui:AddonLoaded()`.
	---@type string
	currentCharacterId = nil,

	-- Pointer to SavedVariables data for the current character.
	---@type table
	currentCharacterData = {},


	-- Relationship between docked inventory class instances.
	-- For example, if Keyring is docked to Bags, `{ "Bags" = "Keyring" }`.
	-- This only allows for one docking per class, but that's fine for now.
	---@type table<BS_INVENTORY_TYPE, BS_INVENTORY_TYPE>
	dockedInventories = {},

	-- List of active quest items by name.
	-- See Components\ActiveQuestItems.lua for details.
	---@type table<string, { questName: string, needed: number, obtained: number }>
	activeQuestItems = nil,


	-- WoW API functions that need to be hooked at the Bagshui level.
	-- ```
	-- { ApiFunctionName = "BagshuiClassFunctionName" }
	-- ```
	---@type table<string, string>
	apiFunctionsToHook = {
		ClearCursor = "ClearCursor",
		CloseAllWindows = "CloseAllWindows",
		DeleteCursorItem = "ClearCursor",
		MoneyFrame_UpdateMoney = "MoneyFrame_UpdateMoney",
		OpenStackSplitFrame = "OpenStackSplitFrame",
		PickupBagFromSlot = "PickupInventoryItem",
		PickupInventoryItem = "PickupInventoryItem",
		PutItemInBag = "PickupInventoryItem",
		ToggleDropDownMenu = "ToggleDropDownMenu",
		UIDropDownMenu_AddButton = "UIDropDownMenu_AddButton",
	},


	-- Bagshui's hidden frame for event handling, declared in `Bagshui:Init()`.
	---@type table
	eventFrame = nil,

	-- List of components and events for which to call the OnEvent function.  
	-- After calling `Bagshui:RegisterEvent()`, the table will start looking something like this:
	-- ```
	-- {
	-- 	[classObject Pointer] = {
	-- 		_eventFunctionName = function,
	-- 		event1 = true,
	-- 		event2 = true
	-- 	}
	-- }
	-- ```
	---@type table<string, table>
	eventConsumers = {},

	-- Reusable tables for the Bagshui event queue.
	-- Keys for each sub-table will be the unique event identifier.
	-- See `Bagshui:QueueEvent()`, `Bagshui:ProcessEventQueue()`, and `Bagshui:RaiseEvent()`.
	---@type table<string, table>
	queuedEvents = {
		-- Events that are waiting to be raised and the time at which to raise them.
		---@type table<string, number>
		events = {},
		-- First parameter for the callback function.
		---@type table<string, any>
		arg1 = {},
		-- Second parameter for the callback function.
		---@type table<string, any>
		arg2 = {},
		-- Third parameter for the callback function.
		---@type table<string, any>
		arg3 = {},
		-- Fourth parameter for the callback function.
		---@type table<string, any>
		arg4 = {},

		-- Class function callback tables, populated by Bagshui:QueueClassCallback()
		-- and consumed by Bagshui:RaiseEvent().

		-- Class references.
		---@type table<string, table>
		class = {},
		-- Class function references.
		---@type table<string, function>
		classFunction = {}
	},


	-- Window Management.

	-- Frames that should be closed when `CloseAllWindows()` fires.
	---@type table<table, boolean>
	framesToCloseOnEscape = {},

	-- "Child Frames" prevent Esc from closing Inventory frames when visible.
	---@type table<table, boolean>
	childWindowFrames = {},


	-- Tooltips can be shared across all Bagshui code.
	---@type table<string, table>
	tooltips = {},

	-- Ui class instance, basically just used for access to the Bagshui Info tooltip (instantiated during `Init()`).
	ui = nil,

	-- List of log messages.
	---@type string[]
	log = nil,  -- Initialized in `Bagshui:AddonLoaded()`.

	-- Expose the Bagshui environment table so things can be added to it.
	environment = bagshuiEnvironment,

	-- Debugging.
	debug = BS_DEBUG,
	debugWipeConfigOnLoad = false and BS_DEBUG,
}


-- Expose Bagshui globally.
_G.Bagshui = Bagshui

-- Add Bagshui to environment for quick access by other components.
Bagshui.environment.Bagshui = Bagshui
Bagshui.environment.Bs      = Bagshui



--- Basic initialization. Called when BAGSHUI_CORE_EVENT_FUNCTIONS_LOADED is raised.
function Bagshui:Init()
	-- self:PrintDebug("Bagshui:Init()")

	-- Hidden frame for event handling (see `Bagshui:OnEvent()`).
	self.eventFrame = _G.CreateFrame("Frame")
	self.eventFrame.bagshuiData = {
		registeredEvents = {}
	}
	self.eventFrame:SetScript("OnEvent", function()
		-- Vanilla WoW "passes" event parameters via global variables.
		self:OnEvent(_G.event, _G.arg1, _G.arg2, _G.arg3, _G.arg4)
	end)
	self.eventFrame:SetScript("OnUpdate", function()
		-- Check the event queue on every frame.
		self:ProcessEventQueue()
	end)


	-- Bagshui itself needs these events. Other classes register their own events.
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("BAGSHUI_UTIL_LOADED")
	self:RegisterEvent("BAGSHUI_LOCALIZATION_LOADED")
	self:RegisterEvent("PLAYER_LOGOUT")


	-- Shared menu hosting frame.
	self.menuFrame = _G.CreateFrame(
		"Frame",
		"BagshuiMenuHostFrame",
		nil,
		"UIDropDownMenuTemplate"
	)
	self.menuFrame.bagshuiData = {
		name = self.menuFrame:GetName(),
		-- Populated by `Menus:ShowMenu()` and consumed by `Bagshui:IsMenuOpen()`.
		lastMenuTypeLoaded = nil,
		-- Can be set to true before calling `Menus:ShowMenu()` to avoid changing
		-- level 1 anchors unnecessarily in `Bagshui:ToggleDropDownMenu()`.
		noFirstLevelRepositionNeeded = nil,
	}


	-- Key binding header; doesn't need localization.
	-- Localized versions of inventory key binding names are populated during Inventory class creation.
	_G.BINDING_HEADER_Bagshui = "Bagshui"


	-- Create hex font strings for all RGB colors.
	if not self.environment.BS_FONT_COLOR then
		self.environment.BS_FONT_COLOR = {}
	end
	for name, rgb in pairs(BS_COLOR) do
		if not self.environment.BS_FONT_COLOR[name] then
			local hex = BsUtil.RGBPercentToHex(rgb.r or rgb[1], rgb.g or rgb[2], rgb.b or rgb[3])
			-- The ff prefix would be alpha value, but WoW ignores it and it just always needs to be ff.
			self.environment.BS_FONT_COLOR[name] = "|cff" .. hex
		end
	end

	-- Need to adjust this by the scale so it behaves as expected.
	BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD = BS_WINDOW_OFFSCREEN_RESCUE_THRESHOLD / _G.UIParent:GetScale()

end



--- Called from `Bagshui:OnEvent()` when ADDON_LOADED is raised. This indicates SavedVariables are safe to use.  
--- Bagshui components are loaded immediately after this.
function Bagshui:AddonLoaded()
	-- self:PrintDebug("Bagshui:AddonLoaded()")

	-- Grab version number from TOC file.
	self.environment.BS_VERSION = tostring(_G.GetAddOnMetadata("Bagshui", "Version"))

	-- Prepare game function hooks.
	self.hooks = Bagshui.prototypes.Hooks:New(self.apiFunctionsToHook, self)

	local dataVersionKey = BS_CONFIG_KEY.DATA_VERSION
	local charactersKey = BS_CONFIG_KEY.CHARACTERS

	-- "[Name] - [Realm]"
	self.currentCharacterId = _G.UnitName("player") .. " - " .. BsUtil.Trim(_G.GetCVar("realmName"))
	self.currentRealm = BsUtil.Trim(_G.GetCVar("realmName"))

	-- Base config (if it doesn't exist, version doesn't match, or debug wipe is on).
	if
		_G.BagshuiData == nil
		or (_G.BagshuiData[dataVersionKey] == nil)
		or (_G.BagshuiData[dataVersionKey] ~= BS_DATA_VERSION)
		or self.debugWipeConfigOnLoad
	then
		-- Display chat message on version mismatch only.
		if _G.BagshuiData ~= nil and _G.BagshuiData[dataVersionKey] ~= nil and _G.BagshuiData[dataVersionKey] ~= BS_DATA_VERSION then
			self:Print(
				string.format(
					L.BagshuiDataReset,
					tostring(_G.BagshuiData[dataVersionKey]),
					BS_DATA_VERSION
				)
			)
		end

		_G.BagshuiData = {
			[dataVersionKey] = BS_DATA_VERSION,
			[charactersKey] = {},
		}
	end

	-- Creating the object versions key here because it was added after 1.0.
	if not _G.BagshuiData[BS_CONFIG_KEY.OBJECT_VERSIONS] then
		_G.BagshuiData[BS_CONFIG_KEY.OBJECT_VERSIONS] = {}
	end
	self.objectVersions = _G.BagshuiData[BS_CONFIG_KEY.OBJECT_VERSIONS]

	-- Color history (account-wide).
	if _G.BagshuiData[BS_CONFIG_KEY.COLORS] == nil then
		_G.BagshuiData[BS_CONFIG_KEY.COLORS] = {}
	end
	self.colorHistory = _G.BagshuiData[BS_CONFIG_KEY.COLORS]

	-- Character data storage.
	if _G.BagshuiData[charactersKey] == nil then
		_G.BagshuiData[charactersKey] = {}
	end
	if _G.BagshuiData[charactersKey][self.currentCharacterId] == nil then
		_G.BagshuiData[charactersKey][self.currentCharacterId] = {}
	end

	self.characters = _G.BagshuiData[charactersKey]
	self.currentCharacterData = _G.BagshuiData[charactersKey][self.currentCharacterId]

	-- Character info (data will be populated by Character class).
	if self.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO] == nil then
		self.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO] = {}
	end
	self.currentCharacterInfo = self.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO]

	-- Log storage.
	if _G.BagshuiData[BS_CONFIG_KEY.LOG] == nil then
		_G.BagshuiData[BS_CONFIG_KEY.LOG] = {}
	end
	self.log = _G.BagshuiData[BS_CONFIG_KEY.LOG]

end



--- Initialization that can't occur until after Components\Localization.lua has loaded.
--- Called from `Bagshui:OnEvent()` when BAGSHUI_LOCALIZATION_LOADED is raised.
function Bagshui:PostLocalizationInit()

	-- Add "About" slash command.
	BsSlash:AddHandler("About", function(tokens)
		if not tokens[2] or BsUtil.MatchLocalizedOrNon(tokens[2], "dialog") then
			BsAboutDialog:Open()
		elseif BsUtil.MatchLocalizedOrNon(tokens[2], "text") then
			Bagshui:PrintBare("Bagshui " .. BS_VERSION)
		elseif BsUtil.MatchLocalizedOrNon(tokens[2], "help") then
			BsSlash:PrintHandlers({L.Dialog, L.Text}, "About")
		end
	end)

	-- Add "Settings" slash command.
	BsSlash:AddHandler("Settings", function(tokens)

		for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
			if BsUtil.MatchLocalizedOrNon(tokens[2], inventoryType) then
				self.components[inventoryType]:Open()
				self.components[inventoryType].menus:OpenMenu("Settings")
				return
			end
		end

		if not self._settingsHandler_LocalizedInventoryTypes then
			self._settingsHandler_LocalizedInventoryTypes = {}
			for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
				table.insert(self._settingsHandler_LocalizedInventoryTypes, L[inventoryType])
			end
		end
		BsSlash:PrintHandlers(self._settingsHandler_LocalizedInventoryTypes, "Settings")
	end)

end



--- Primary event handler called by Bagshui.eventFrame's OnEvent script.
---@param event string Event name.
---@param arg1 any? First event argument, if any.
---@param arg2 any? Second argument, if any.
---@param arg3 any? Third argument, if any.
---@param arg4 any? Fourth argument, if any.
function Bagshui:OnEvent(event, arg1, arg2, arg3, arg4)
	local downstreamEvent = event  --[[@as string|nil]]

	if event == "ADDON_LOADED" then
		-- Need to check arg1 to avoid responding to this event for other addons.
		if arg1 == "Bagshui" then
			self:AddonLoaded()
			self:LoadComponents()
		else
			return
		end
	end

	if event == "PLAYER_LOGIN" then
		-- Do compatibility check after everything else is definitely loaded.
		if not self.startupCompatChecked then
			self:QueueClassCallback(self, self.CheckCompat, 1)
			self.startupCompatChecked = true
		end
	end

	if event == "BAGSHUI_CORE_EVENT_FUNCTIONS_LOADED" then
		-- Part of Init() is registering events so we can't run that until event functions are available.
		self:Init()
	end

	if event == "BAGSHUI_LOCALIZATION_LOADED" then
		-- Some startup stuff requires localization to be available.
		self:PostLocalizationInit()
	end

	if event == "PLAYER_LOGOUT" then
		-- Used by `Inventory:UpdateCache()` to move `item.bagshuiDate` forward
		-- so that only in-game time counts for stock states.
		self.currentCharacterData.lastLogout = _G.time()
	end


	-- Pass events on to consumers.
	if downstreamEvent then
		for consumer, events in pairs(self.eventConsumers) do
			if events[event] then
				consumer[self.eventConsumers[consumer]._eventFunctionName](consumer, downstreamEvent, arg1, arg2, arg3, arg4)
			end
		end
	end

	-- Provide an event that happens just after ADDON_LOADED but before anything else
	-- so that components split across multiple files can complete initialization.
	if downstreamEvent == "ADDON_LOADED" then
		self:RaiseEvent("BAGSHUI_ADDON_LOADED")
	end
end





-- Component storage.  
-- Doesn't need to be exposed; it's up to individual components to expose themselves on
-- `Bagshui.components`, `Bagshui.prototypes`, and/or `Bagshui.environment` as appropriate.
---@type function[]
local components = {}


--- Load a component by executing its function within the Bagshui environment.
--- This must be here because it's needed by every other file.
---@param creationFunction function
---@param loadEvent string? Event to raise after `creationFunction` has run.
function Bagshui:LoadComponent(creationFunction, loadEvent)
	setfenv(creationFunction, self.environment)
	creationFunction()
	if loadEvent and self.RaiseEvent then
		self:RaiseEvent(loadEvent)
	end
end



--- Queue the creation of a Bagshui component.
--- Components will be loaded FIFO, so load order is controlled by the TOC/XML.
---@param creationFunction function Component code to execute within the Bagshui environment.
function Bagshui:AddComponent(creationFunction)
	table.insert(components, creationFunction)
end



--- Execute the component creation functions queued by AddComponent.
function Bagshui:LoadComponents()
	for _, creationFunction in ipairs(components) do
		self:LoadComponent(creationFunction)
	end
end



--- Add additional constants to the Bagshui environment. Keys in the `constantTable`
--- should start with `BS_` and will be prefixed with it if they don't.
---@param constantTable table<string, any> List of `{ name = value }`.
function Bagshui:AddConstants(constantTable)
	for name, value in pairs(constantTable) do
		local constantName = string.find(name, "^BS_") and name or "BS_" .. name
		if self.environment[constantName] then
			self:PrintError("Constant " .. constantName .. " is already defined as " .. tostring(value))
		else
			self.environment[constantName] = value
		end
	end
end




-- lua-language-server hack to remove "undefined-field" errors when accessing WoW API via _G.
---@class _G
---@field [string] any