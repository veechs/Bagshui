-- Bagshui Inventory Class Prototype
-- Exposes: Bagshui.prototypes.Inventory
-- Raises:
-- - BAGSHUI_INVENTORY_CACHE_UPDATE
-- - BAGSHUI_INVENTORY_EDIT_MODE_UPDATE
-- All inventory types (Bags, Bank, etc.) are instances of this class.

Bagshui:AddComponent(function()


Bagshui:AddConstants({

	-- Control the order in which bag types are displayed in the free space tooltip
	-- that appears when mousing over the free space display next to the bag bar.
	BS_INVENTORY_CONTAINER_TYPE_ORDER = {
		L["Bag"],
		L["Ammo Pouch"],
		L["Enchanting Bag"],
		L["Herb Bag"],
		L["Quiver"],
		L["Soul Bag"],
	},

	-- Different bag types get different empty slot textures.
	BS_INVENTORY_EMPTY_SLOT_TEXTURE = {
		[L["Bag"]] = "ItemSlot\\EmptySlot",
		[L["Ammo Pouch"]] = "ItemSlot\\EmptySlot-AmmoPouch",
		[L["Enchanting Bag"]] = "ItemSlot\\EmptySlot-EnchantingBag",
		[L["Herb Bag"]] = "ItemSlot\\EmptySlot-HerbBag",
		[L["Quiver"]] = "ItemSlot\\EmptySlot-Quiver",
		[L["Soul Bag"]] = "ItemSlot\\EmptySlot-SoulBag",
	},

	-- Properties listed here are appended when building the new class object instead of
	-- overriding what's in the prototype. Obviously only works for tables.
	-- - Keys must match case with class property names.
	BS_INVENTORY_SUBCLASS_APPEND_PROPERTY = {
		events = true,
		apiFunctionsToHook = true,
	},

	-- Quality badges are set via these parameters for `SetTexCoord()` to crop UI-RaidTargetingIcons for finer
	-- control than `SetRaidTargetIconTexture()` allows (mostly to make the purple diamond more square).
	-- - `[Quality Number] = { left, right, top, bottom }`
	BS_INVENTORY_QUALITY_BADGE_COORD = {
		[2] = { 0.00, 0.25, 0.25, 0.5 }, -- White Crescent Moon
		-- Green alternates
		-- [2] = { 0.72, 1.00, 0.00, 0.26 }, -- Green Triangle
		-- [2] = { 0.00, 0.25, 0.00, 0.25 }, -- Yellow Cross
		[3] = { 0.235, 0.515, 0.235, 0.515 }, -- Blue Square
		[4] = { 0.53, 0.74, 0.00, 0.26 }, -- Purple Diamond
		[5] = { 0.24, 0.49, 0.00, 0.24 }, -- Orange Circle
		[6] = { 0.00, 0.25, 0.00, 0.25 }, -- Yellow Cross
	},

	-- Set `[Quality Number] = true` if a badge requires recoloring.
	-- This will cause it to be recolored to the standard item quality color via `SetVertexColor()`.
	BS_INVENTORY_QUALITY_BADGE_RECOLOR = {
		[2] = true,  -- The moon is white, so turn it green.
	},

	-- Textures and cropping for item usable badges.
	-- ```
	-- USABLE_STATE = {
	--     texture = "path",
	--     texCoord = { left, right, top, bottom },
	-- }
	-- ```
	-- Note: `texCoord` is **required**; use `{ 0, 1, 0, 1 }` for uncropped.
	BS_INVENTORY_USABLE_BADGE = {
		UNUSABLE = {
			texture = "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
			texCoord = { 0.49, 0.761, 0.241, 0.511 },  -- Red X
		},
		KNOWN = {
			-- There's no check mark in UI-RaidTargetingIcons, so we have to provide our own.
			texture = "ItemSlot\\Check",
			texCoord = { 0, 1, 0, 1 },
		}
	},

	-- Lowest stock badge opacity allowed (percentage as decimal between 0 and 1).
	BS_INVENTORY_STOCK_BADGE_MAX_FADE = 0.4,

	-- Truncate long tooltips at the first empty line when the Bagshui Info tooltip
	-- is displayed or in Edit Mode.
	BS_INVENTORY_TRUNCATE_TOOLTIPS_INFO_MODE = true,
	BS_INVENTORY_TRUNCATE_TOOLTIPS_EDIT_MODE = true,

	-- Use these strings to build the full string that is stored in each item's tooltip property.
	-- MUST be an array-type table where:
	-- ```
	-- [1] = <Left>
	-- [2] = <Right>
	-- ```
	BS_INVENTORY_TOOLTIP_JOIN_CHARACTERS = {
		Left = BS_NEWLINE,
		Right = "   ",
	},

	-- Enum used by `Visible()` (passed from `OpenCloseToggle()`) to call the correct UI visibility function.
	-- Values must correspond to class function names.
	---@enum BS_INVENTORY_UI_VISIBILITY_ACTION
	BS_INVENTORY_UI_VISIBILITY_ACTION = {
		OPEN = "Open",
		CLOSE = "Close",
		TOGGLE = "Toggle"
	},

	-- Inventory-specific object identifiers.
	---@enum BS_INVENTORY_OBJECT_TYPE
	BS_INVENTORY_OBJECT_TYPE = {
		GROUP = "Group",
		GROUP_MOVE_TARGET = "GroupMoveTarget",
		CATEGORY = "Category",
		ITEM = "Item",
	},

	-- Used in Edit Mode to determine whether a layout change is being made in
	-- a horizontal or vertical direction.
	---@enum BS_INVENTORY_LAYOUT_DIRECTION
	BS_INVENTORY_LAYOUT_DIRECTION = {
		ROW = "Row",
		COLUMN = "Column",
	},

	-- Used to find the Hearthstone for the Hearthstone button.
	BS_INVENTORY_HEARTHSTONE_ITEM_ID = 6948,

})



local Inventory = {}
Bagshui.prototypes.Inventory = Inventory

-- Instance of UI class with Inventory-specific modifications. Additions are made
-- in the various Inventory.Ui.*.lua files. Each instance of the Inventory class
-- then creates its own instance of InventoryUi in Inventory:InitUi().
Bagshui.prototypes.InventoryUi = Bagshui.prototypes.Ui:New()



--- Create new Inventory class instance.
---@param newPropsOrInventoryType BS_INVENTORY_TYPE|table Inventory type configured in Config\Inventory.lua or a table of Inventory class properties.
---@return table inventoryClassInstance
function Inventory:New(newPropsOrInventoryType)
	local newProps = newPropsOrInventoryType  --[[@as table]]
	if type(newPropsOrInventoryType) == "string" then
		newProps = Bagshui.config.Inventory[newPropsOrInventoryType]
		assert(newProps, "Inventory:New() - " .. newPropsOrInventoryType .. " not found in Inventory config")
		-- Transfer inventory type identifier to the instance properties.
		newProps.inventoryType = newPropsOrInventoryType
	end
	assert(newProps.inventoryType, "Inventory:New() - property table must contain inventoryType")

	-- Default class properties.
	local classObj = {
		_super = Inventory,


		--#region MUST be filled in by subclasses. --------------------------------

		---@type string A Bagshui BS_INVENTORY_TYPE.
		inventoryType = nil,

		---@type number How many item slot buttons to create during initialization.
		-- More will automatically be created if needed; this is just the starting point.
		initialItemSlotButtons = 160,

		---@type number[] {start, end} inclusive range that controls which bag numbers
		-- are included in this subclass' containerIds array.
		containerIdRange = {},

		---@type table<string,any> Handling instructions for the primary immutable container
		-- belonging to this class (the Backpack, initial Bank bag, Keyring).
		-- Items are optional unless noted.
		-- ```
		-- {
		--		---@type number id of the bag (required).
		-- 		id = <ContainerId>,
		--		---@type string Name of the bag (required).
		-- 		name = "Name",
		--    	---@type string Texture to display (required).
		-- 		texture = "Path\\To\\Texture",
		--    	---@type string Parameter for GetBindingKey() that will return the key binding for this container.
		--		bindingKey = "BINDINGKEY"
		--    	---@type function Call this in lieu of GetContainerNumSlots() (will be passed a bagNum parameter).
		-- 		numSlotsFunction = <function>,
		-- }
		-- ```
		primaryContainer = {},

		
		---@type function? Called as the second parameter to <tooltip>:SetInventoryItem() 
		--- and passed the item's slotNum. This is necessary because some containers'
		--- contents can't be loaded into tooltips using SetBagItem().
		getInventorySlotFunction = nil,

		---@type string? Name of game function to call so other addons' tooltip hooks work.
		--- Will be passed the current item slot button.
		--- This is a string instead of the actual function so we can always be sure to
		--- call the last link in the hook chain. If the function pointer was captured
		--- at startup in Config\Inventory.lua then there's the risk of missing hooks.
		itemSlotTooltipFunction = nil,

		-- Bag button handling (none of these are applied to primaryContainer).
		---@type string Name of XML template for bag buttons.
		bagButtonTemplate = "BagshuiBagsContainerTemplate",
		---@type number Add this to ContainerId when creating bag slots to avoid issues.
		-- with conflicting frame IDs (relevant for Bags, not Bank).
		bagButtonIdOffset = 0,
		---@type string When creating bag buttons, use this as the name prefix instead.
		-- of the usual CreateElementName. This is needed because the Blizzard code
		-- we rely on for bag slot buttons parses information from the element's
		-- name via `strsub(<name>, 10)`. See the bagSlotName reference in
		-- `InventoryUi:CreateBagSlotButtons()` along with Config\Inventory.lua
		-- for more details.
		bagSlotNameFormat = "Bagshui__%d",
		---@type number When creating bag buttons, add this to ContainerId to populate bagSlotNameFormat.
		bagSlotNameNumberOffset = 0,

		--#endregion MUST be filled in by subclasses.


		--#region Additional subclass override properties. --------------------------------

		---@type BS_INVENTORY_TYPE to attach frame to.
		dockTo = nil,

		---@type boolean Should the Hearthstone button be available?
		hearthButton = false,

		---@type string Default sound to play when window is opened.
		openSound = "igMainMenuOpen",
		---@type string Default sound to play when window is closed.
		closeSound = "igMainMenuClose",

		---@type table<string,boolean|number|string> Table of events to register.
		-- Subclasses can add or remove events by providing their own Events table.
		-- Keys are event names.
		-- Values can be any of the below (note that some of the advanced functionality may not currently be used):
		-- * true = Just handle the event normally.
		-- * number = Queue the event to bae raised again with this delay and a BAGSHUI_ prefix.
		-- * string = Call the function with this name, if it exists.
		-- * false = Disable this event.
		events = {
			PLAYER_LOGIN = true,
			PLAYER_ENTERING_WORLD = true,
			BAG_UPDATE = true,
			BAG_UPDATE_COOLDOWN = true,
			ITEM_LOCKED = true,  -- Doesn't seem to actually ever fire but let's register for it anyway.
			ITEM_LOCK_CHANGED = true,  -- Required for multiple reasons, including preventing items from staying gray if you attempt to place them in an incompatible container (ex. non-ammo in ammo bags).
			BAGSHUI_INVENTORY_INIT_RETRY = true,
			BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE = true,
			BAGSHUI_INITIAL_INVENTORY_UPDATE = true,
			BAGSHUI_CATEGORY_UPDATE = true,
			BAGSHUI_CHARACTER_LEARNED_RECIPE = true,
			BAGSHUI_CHARACTER_UPDATE = true,
			BAGSHUI_CHARACTERDATA_UPDATE = true,
			BAGSHUI_PROFESSION_ITEM_UPDATE = true,
			BAGSHUI_PROFILE_UPDATE = true,
			BAGSHUI_SETTING_UPDATE = true,
			BAGSHUI_SORTORDER_UPDATE = true,
			BAGSHUI_EQUIPPED_HISTORY_UPDATE = true,
			BAGSHUI_WINDOW_OPENED = true,
			BAGSHUI_WINDOW_CLOSED = true,
		},

		---@type table<string,string> WoW API functions to hook and the corresponding class function to call.
		-- The WoW API function name will be passed as the first parameter with any additional parameters after that.
		apiFunctionsToHook = {
			BagSlotButton_OnClick = "BagSlotButton_OnHook",
			BagSlotButton_OnDrag = "BagSlotButton_OnHook",
			TradeFrame_OnShow = "TradeFrame_OnShow",
		},

		---@type table<string,string> See Inventory:GetHookSettingName() for details.
		-- Keys are pattern strings to match against the API function name and
		-- values are the setting name to return.
		hookSettingTranslations = {},

		---@type boolean When true, add entries to the Hooks setting menu for this class' bag numbers.
		opensViaHooks = false,

		---@type string The string that goes in front of key binding indexes to look them up.
		keyBindingPrefix = nil,

		---@type boolean Debugging options.
		debug = false and BS_DEBUG,
		clearItemCacheAtStartup = false and BS_DEBUG,
		wipeSettingsOnLoad = false and BS_DEBUG,

		--#endregion Additional subclass override properties.


		--#region Runtime properties. --------------------------------

		---@type boolean Should inventory changes be allowed?
		online = true,

		-- Container-related lookup tables.

		---@type number[] Full list of bag numbers owned by this subclass.
		-- * The primary container ID will always be at index 1.
		-- * This is filled by code at the bottom of Config\Inventory.lua because other
		--   configuration files depend on it.
		-- * No reason to create a table here because it will be pulled from the config.
		containerIds = nil,
		---@type table<number, number> `{ <ContainerId> = <index in self.containerIds> }` for every ContainerId in self.containerIds -- used to quickly check whether a given container ID belongs to this class.
		myContainerIds = {},
		---@type table<number, number> `{ <InventoryId> = <ContainerId> }`
		inventoryIdsToContainerIds = {},
		---@type table<string, table> `{ <Container Type> = { available = <used slots>, total = <total slots> } }` -- Managed by UpdateBagBar().
		containerSpace = {},

		-- Partial stack tracking -- Managed by UpdateCache().
		---@type table<number, number> `{ itemId = count of partial stacks }`
		partialStacks = {},

		-- "Shadow" cache of item stock states.
		-- See comment above the declaration of shadowId in Inventory.Cache.lua.
		shadowStockState = {},
		shadowBagshuiDate = {},

		-- Restack queue -- see Restack() for details.
		restackQueue = {
			sources = {},
			targets = {},
		},

		-- Tracking tables used in UpdateCache().
		preUpdateItemCounts = {},
		postUpdateItemCounts = {},
		lastUpdateLockedContainers = {},

		-- Category/group-related lookup tables -- See CategorizeAndSort() for descriptions of most of these.
		categoryIdsGroupedBySequence = {},
		activeGroups = {},
		sortedCategorySequenceNumbers = {},
		categoriesToGroups = {},

		-- Tracking tables and state variables for UpdateWindow() and friends.
		-- Detailed descriptions typically can be found where each is first referenced.
		groups = {},
		groupItems = {},
		groupItemCounts = {},
		groupWidthsInItems = {},
		groupsIdsToFrames = {},
		actualGroupWidths = {},
		emptySlotStacks = {},  -- Fake item entries used to create empty slot stacks in the UI
		expandEmptySlotStacks = false,
		lastExpandEmptySlotStacks = false,
		highlightItemsInContainerId = nil,
		highlightItemsInContainerLocked = false,
		showHidden = false,  -- Toggle display of hidden groups and items (like Hearthstone).
		hasHiddenGroups = false,  -- Whether any objects are hidden and the toolbar icon should appear.
		multiplePartialStacks = false,  -- Whether there are multiple partial stacks of the same item, meaning the restack toolbar icon should be enabled.
		hideItems = {},
		hasHiddenItems = false,
		hasChanges = false,
		positioningTables = {},
		enableResortIcon = false,  -- Managed by `Inventory:CategorizeAndSort()` and consumed by `Inventory:UpdateToolbar()`.

		-- Used to track changes that occur when bags are moved between slots (see `Bagshui:PickupInventoryItem()` for details).
		pendingContainerChanges = {},

		-- Update tracking.
		-- Start by requiring an update of everything.
		inventoryUpdateAllowed = false, -- This will be flipped to true once the BAGSHUI_INITIAL_INVENTORY_UPDATE event is raised.
		initialInventoryUpdateNeeded = true, -- This starts out true so that on the very first cache update, everything will be rebuilt.
		cacheUpdateNeeded = true,
		resortNeeded = true,
		windowUpdateNeeded = true,
		updating = false,
		forceCacheUpdate = false,
		forceResort = false,

		---@type string|nil Item search will occur when this is a string instead of nil.
		searchText = nil,
		---@type boolean Highlight mode - dim items whose stock state has not changed
		highlightChanges = false,

		---@type boolean Alter frame close behavior -- see UiFrame_OnShow().
		dockingFrameVisibleOnLastOpen = false,

		---@type table|nil Hearthstone cache entry tracking.
		hearthstoneItemRef = nil,

		-- Edit Mode state tracking -- see Components\Inventory.EditMode.lua.
		---@type boolean
		editMode = false,
		---@type table<string, any>
		editState = {
			cursorItem = nil,
			cursorItemType = nil,
			cursorTooltip = nil,
			highlightCategory = nil,
			highlightItem = nil,
		},

		-- UI element storage.
		ui = nil, -- Ui class instance that we also hang UI elements on.
		uiFrame = nil,

		---@type boolean When true, this indicates that on the initial cache update, items should NOT be
		-- treated as new. This avoids the situation where everything receives the new item badge on a
		-- clean install. It gets set to true if needed during `Inventory:Init()`.
		freshCache = false,


		---@type string When this is NOT an empty string, the error icon will appear in the top left of the window.
		errorText = "",

		-- Table pointers.
		-- These are set during `Inventory:Init()` but are documented here for reference.
		settings = nil,  -- Settings class instance
		inventory = nil,  -- `Bagshui.characters[<characterId>][self.inventoryTypeSavedVars].inventory`
		layout = nil,  -- Active layout.
		-- `containers` stores the following information about equipped/available bags (subclasses may add more):
		-- ```
		-- <ContainerId> = {
		-- 	name = <Name of bag>
		-- 	numSlots = <Number of slots>
		--  genericType = <Bag Subclass or "Bag"> -- (A bag's "genericType" is the the item class returned by GetItemInfo for profession bags or the localized version of "Bag" for any other bag and the primary container)
		--  isProfessionBag = <true/false>
		-- 	slotsFilled = <Number of slots filled>
		-- 	texture = <Bag texture>
		-- 	type = <Container type>
		-- }
		-- ```
		containers = nil,   -- `Bagshui.characters[<characterId>][self.inventoryTypeSavedVars].containers`
		profiles = {},  -- Pointers to active profiles, mostly so that the Settings class can access them easily.

		-- Used by `Inventory:Init()` to avoid initializing multiple times.
		initialized = false,

		--#endregion Runtime properties.
	}

	-- Append/overwrite additional properties for class instance.
	if newProps ~= nil then
		for key, value in pairs(newProps) do
			-- Some properties need to be appended instead of overwriting.
			if BS_INVENTORY_SUBCLASS_APPEND_PROPERTY[key] then
				for subKey, subVal in pairs(value) do
					classObj[key][subKey] = subVal
				end
			else
				classObj[key] = value
			end
		end
	end

	-- We'll need the lowercase version of the inventory type for SavedVariables and the localized version for the UI.
	classObj.inventoryTypeSavedVars = BsUtil.LowercaseFirstLetter(classObj.inventoryType)
	classObj.inventoryTypeLocalized = L[classObj.inventoryType]

	-- Build the list of containerIds belonging to this class along with the reverse inventory ID (slot) mapping.
	for index, containerId in ipairs(classObj.containerIds) do
		classObj.myContainerIds[containerId] = index
		classObj.inventoryIdsToContainerIds[_G.ContainerIDToInventoryID(containerId)] = containerId
	end

	-- Store docked inventory relationship.
	if classObj.dockTo and Bagshui.components[classObj.dockTo] then
		Bagshui.dockedInventories[classObj.dockTo] = classObj.inventoryType
		classObj.dockedToInventory = Bagshui.components[classObj.dockTo]
		Bagshui.components[classObj.dockTo].dockedInventory = classObj
	end

	-- Make the class work.
	setmetatable(classObj, self)
	self.__index = self

	-- Register events.
	for event, eventAction in pairs(classObj.events) do
		if eventAction ~= false then
			Bagshui:RegisterEvent(event, classObj)
			-- Events with number actions get queued for a re-raise as BAGSHUI_<event>,
			-- so we need to register for that version of the event too.
			if type(eventAction) == "number" then
				Bagshui:RegisterEvent("BAGSHUI_" .. event, classObj)
			end
		end
	end

	-- Register slash command handler with additional verbs.
	BsSlash:AddOpenCloseHandler(classObj.inventoryType, classObj, {L.Settings, L.ResetPosition}, function(tokens)
		if BsUtil.MatchLocalizedOrNon(tokens[2], "settings") then
			classObj:Open()
			classObj.menus:OpenMenu("Settings")
			return true
		end

		if BsUtil.MatchLocalizedOrNon(tokens[2], "resetposition") then
			classObj:Open()
			classObj:RescueWindow(true)
			return true
		end
	end)

	-- Expose as `Bagshui.<inventoryType>`.
	Bagshui.components[classObj.inventoryType] = classObj

	return classObj
end



--- Perform initialization tasks.
function Inventory:Init()
	if self.initialized then
		return
	end

	-- Ensure config is initialized for current player.
	if Bagshui.currentCharacterData[self.inventoryTypeSavedVars] == nil then
		Bagshui.currentCharacterData[self.inventoryTypeSavedVars] = {
			neverOnline = true,
		}
		self.freshCache = true
	end

	-- Prepare settings (docked classes use settings of the class they're docked to).
	self.settings = (
		self.dockTo and Bagshui.components[self.dockTo].settings
		or Bagshui.prototypes.Settings:New(
			self,
			self.debugSettingsOnLoad  -- Wipe settings on load if configured.
		)
	)

	-- Default to current character at startup.
	self:SetCharacter(Bagshui.currentCharacterId)

	-- Convenience properties for current character that can be referenced 
	-- regardless of what the active character is.
	self.currentCharacterInventory = Bagshui.characters[Bagshui.currentCharacterId][self.inventoryTypeSavedVars].inventory

	-- Activate profiles.
	for _, profileType in pairs(BS_PROFILE_TYPE) do
		self:SetProfile(self.settings["profile" .. profileType], profileType, true)
	end

	-- Initialize settings.
	self.settings:SetDefaults(false, BS_SETTING_SCOPE.INVENTORY)
	self.settings:InitCache()

	-- Clean the inventory cache at startup (not usually needed but can be enabled).
	if self.clearItemCacheAtStartup then
		for index, bagNum in ipairs(self.containerIds) do
			self.inventory[bagNum] = {}
		end
		self.freshCache = true
	end

	-- Set up WoW API function hooks.
	self.hooks = Bagshui.prototypes.Hooks:New(self.apiFunctionsToHook, self)

	-- Build the GUI.
	self:InitUi()
	self:InitMenus()

	-- Ensure lookup tables are correct from the start.
	self:UpdateLayoutLookupTables()

	-- Initialize the frame docked to this one, if present.
	if self.dockedInventory then
		self.dockedInventory:Init()
	end

	-- We're done.
	self.initialized = true
end



--- Calling this function means that an update is needed, but if other update-triggering
--- events arrive within the delay period, go ahead and allow them to reset the delay.
--- This allows us to minimize our updates while still staying responsive.
function Inventory:QueueUpdate(delay)
	-- Don't push the default delay too low on this or we'll end up performing updates too quickly
	-- during things like moving bags between slots, and stock states will be lost.
	Bagshui:QueueClassCallback(self, self.Update, delay or 0.07, false)
end



--- Event handling.
---@param event string Event identifier.
---@param arg1 any? Argument 1 from the event.
---@param arg2 any? Argument 2 from the event.
function Inventory:OnEvent(event, arg1, arg2)
	-- self:PrintDebug("OnEvent(): " ..  event .. " // " .. tostring(arg1) .. " // " .. tostring(arg2))

	-- Store the name of this event so it can be checked when updating the inventory
	-- cache to see if the cache update should be delayed (see self.lastEvent check
	-- near the top of Inventory:UpdateCache()).
	self.lastEvent = event

	-- Initialization.
	-- Triggering off both PLAYER_LOGIN and PLAYER_ENTERING_WORLD because there seem
	-- to be occasional issues with PLAYER_LOGIN not firing in 1.12.
	if
		event == "PLAYER_LOGIN"
		or event == "PLAYER_ENTERING_WORLD"
	then
		-- Don't initialize if we're docked to another frame -- that frame will initialize us.
		if not self.dockTo then
			-- It's safe to call `Inventory:Init()` multiple times since it will
			-- just return immediately if it has already executed successfully.
			self:Init()
		end

		-- Queue initial inventory cache update so long as it hasn't been done yet.
		-- PLAYER_ENTERING_WORLD also fires when zoning, so we avoid repeating it.
		if self.initialInventoryUpdateNeeded and event == "PLAYER_ENTERING_WORLD" then
			-- The delay is added because if we try to update immediately, GetItemInfo() may return nil.
			Bagshui:QueueEvent("BAGSHUI_INITIAL_INVENTORY_UPDATE", 2)
		end

		return
	end

	if not self.initialized then
		return
	end

	-- BAG_UPDATE: Don't do anything if arg1 is for a bag not handled by this class.
	if event == "BAG_UPDATE" and not self.myContainerIds[arg1] then
		return
	end


	-- When a character learns a new recipe, we have to re-cache all item tooltips
	-- so learned indicators will be correct.
	if event == "BAGSHUI_CHARACTER_LEARNED_RECIPE" then
		self.forceFullCacheUpdate = true
		self.windowUpdateNeeded = true
		self:QueueUpdate()
		return
	end


	-- Active quest / character changes / equipped gear / profession items.
	-- Putting this early since it will be very common.
	if
		event == "BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE"
		or event == "BAGSHUI_CHARACTER_UPDATE"
		or event == "BAGSHUI_EQUIPPED_HISTORY_UPDATE"
		or event == "BAGSHUI_PROFESSION_ITEM_UPDATE"
	then
		self.cacheUpdateNeeded = true
		self.windowUpdateNeeded = true
		-- DO NOT force a resort here or things will move around when the inventory
		-- window is open and one of the change events is raised.
		self:QueueUpdate()
		return
	end


	-- Toolbar updates.
	if
		-- Window changes should update the toolbar since icon highlights need to
		-- be locked for inventories and catalog.
		event == "BAGSHUI_WINDOW_OPENED"
		or event == "BAGSHUI_WINDOW_CLOSED"
		-- Refresh toolbar state when alts are deleted.
		or event == "BAGSHUI_CHARACTERDATA_UPDATE"
	then
		self:UpdateToolbar()
		return
	end


	-- Special action handling - see description of the Events table in Inventory:New() for details.
	local eventAction = self.events[event]

	-- Re-queue the event with a delay if configured.
	if type(eventAction) == "number" then
		Bagshui:QueueEvent("BAGSHUI_"..event, eventAction, false, arg1, arg2)
		return
	end

	-- Call the event function if it exists.
	-- If the function returns false, don't continue processing.
	local eventFunction = self[eventAction]
	if type(eventFunction) == "function" then
		if eventFunction(self) == false then
			return
		end
	end

	-- Actually perform initial inventory cache update.
	if event == "BAGSHUI_INITIAL_INVENTORY_UPDATE" then
		self.inventoryUpdateAllowed = true
		self.cacheUpdateNeeded = true
		self.forceCacheUpdate = true
		self.forceResort = true
		self:QueueUpdate()
		return
	end


	-- Settings changes should trigger a window update with optional cache update.
	-- arg1 = Setting name.
	-- arg2 = Setting info table as defined in Config\Settings.lua.
	if event == "BAGSHUI_SETTING_UPDATE" then
		-- If any of the "inventory*OnChange" options are set, an update is needed.
		if
			arg2
			and (
				arg2.inventoryCacheUpdateOnChange
				or arg2.inventoryResortOnChange
				or arg2.inventoryWindowUpdateOnChange
			)
		then
			-- Reset header/footer show/hide double-click state when the corresponding setting is changed.
			if
				(
					arg1 == "showHeader"
					or arg1 == "showFooter"
				)
				and not self.ignoreNextSettingChange
			then
				self.headerWasHiddenOnDoubleClick = false
				self.footerWasHiddenOnDoubleClick = false
			end

			self.cacheUpdateNeeded = arg2.inventoryCacheUpdateOnChange or self.cacheUpdateNeeded or false
			self.forceResort = arg2.inventoryResortOnChange or false
			self.windowUpdateNeeded = true
			self:QueueUpdate(0.005)
		end

		-- Even if no update was needed, we don't need anything else to happen.
		return
	end


	-- Fall back to another profile if the active one is deleted.
	if event == "BAGSHUI_PROFILE_UPDATE" then
		for _, profileType in pairs(BS_PROFILE_TYPE) do
			-- Trigger a profile update when one of the active profiles has changed.
			if self.settings["profile" .. profileType] == arg1 then
				self:SetProfile(arg1, profileType)
				if profileType == BS_PROFILE_TYPE.STRUCTURE then
					self.forceResort = true  -- Required to avoid issues during UpdateWindow() since all groups may need to be reassessed.
				end
				self.windowUpdateNeeded = true
				self:QueueUpdate(0.05)
			end
		end
		return
	end


	-- Re-sort and re-categorize when fundamental objects change.
	if
		event == "BAGSHUI_CATEGORY_UPDATE"
		or event == "BAGSHUI_SORTORDER_UPDATE"
	then
		self.forceResort = true
		self:QueueUpdate()
		return
	end


	-- Lock/unlock events need a cache update, but not when a container has
	-- been picked up.
	if
		event == "ITEM_LOCK_CHANGED"
		and not Bagshui.pickedUpBagSlotNum
		and not Bagshui.putDownBagSlotNum
	then
		self.forceCacheUpdate = true
	end


	-- Assume any other event that gets this far may require a cache update.
	self.cacheUpdateNeeded = true

	-- If we get this far, it's a normal event that should just trigger inventory and window updates.
	self:QueueUpdate()
end



--- Conditions that determine whether the inventory is online.
function Inventory:UpdateOnlineStatus()
	self.online = true

	-- Can only be online if the active character is the one currently logged in.
	if self.activeCharacterId ~= Bagshui.currentCharacterId then
		self.online = false
	end
end



local setCharacterConvenienceProps = {
	"containers",
	"inventory"
}

--- Change the active character for this inventory class.
--- Alters the properties listed in `setCharacterConvenienceProps`
--- to point to the given character's data storage.
--- Also updates the class `activeCharacterId` property.
---@param characterId any
function Inventory:SetCharacter(characterId)
	if not Bagshui.characters[characterId] then
		Bagshui:PrintWarning(characterId .. " is not a known character")
		return
	end

	-- No change.
	if characterId == self.activeCharacterId then
		return
	end

	-- Used for online checks.
	self.activeCharacterId = characterId

	if not self._characterMenuActiveCharacter then
		-- self._characterMenuActiveCharacter is assigned to the Character menu's idsToCheck
		-- property, so this will place a check mark next to the active character.
		self._characterMenuActiveCharacter = {}
	end
	BsUtil.TableClear(self._characterMenuActiveCharacter)
	table.insert(self._characterMenuActiveCharacter, self.activeCharacterId)

	-- Point convenience properties to character's SavedVariables.
	for _, propName in ipairs(setCharacterConvenienceProps) do
		if Bagshui.characters[characterId][self.inventoryTypeSavedVars] == nil then
			Bagshui.characters[characterId][self.inventoryTypeSavedVars] = {}
		end
		if Bagshui.characters[characterId][self.inventoryTypeSavedVars][propName] == nil then
			Bagshui.characters[characterId][self.inventoryTypeSavedVars][propName] = {}
		end
		self[propName] = Bagshui.characters[characterId][self.inventoryTypeSavedVars][propName]
	end

	-- Initialize container info tables if needed.
	for _, bagNum in ipairs(self.containerIds) do
		if self.containers[bagNum] == nil or (self.containers[bagNum] and not self.containers[bagNum].numSlots) then
			self.containers[bagNum] = {
				numSlots = 0,
			}
		end
		-- Need to call this here to make sure there aren't errors when Bank is
		-- brought up offline before visiting a banker.
		self:InitializeEmptySlotStackTracking(self.containers[bagNum])
	end

	-- Remove any bag slot highlighting since bags are going to change.
	self.highlightItemsInContainerId = nil
	self.highlightItemsInContainerLocked = nil

	self.forceResort = true
	self:QueueUpdate()

	-- Update character of docked inventory class to match.
	if self.initialized and self.dockedInventory then
		self.dockedInventory:SetCharacter(characterId)
	end
end



--- Given a profile ID and type, activate it for use if possible. Uses fallback
--- logic in the Profile class' `GetUsableProfile()` function if the desired profile
--- isn't available.
---@param desiredProfileId string|number ID of profile to activate.
---@param profileType BS_PROFILE_TYPE Type for which this profile should be used.
---@param startup boolean? Changing the value of the profile* settings triggers a call to this function, so this needs to be true during startup to prevent repeated calls.
---@return string|nil # ID of selected profile, if any.
function Inventory:SetProfile(desiredProfileId, profileType, startup)
	-- Prevent double-call during initialization from settings change.
	if not self.initialized and not startup then
		return
	end

	-- Ensure the desired profile is actually valid.
	-- GetUsableProfile() takes care of figuring out what profile to use if there's an issue.
	-- It also handles first login logic when desiredProfileId will be nil.
	local profile, profileId = BsProfiles:GetUsableProfile(desiredProfileId, profileType)

	-- Store a reference to the profile so the Settings class can update it.
	self.profiles[profileType] = profile[BsUtil.LowercaseFirstLetter(profileType)]

	-- Assign the Structure profile's layout to the correct convenience property.
	if profileType == BS_PROFILE_TYPE.STRUCTURE then
		if self.dockTo then
			-- Docked inventory is stored in its own table.
			self.layout = profile.structure.docked[self.inventoryType].layout
		else
			self.layout = profile.structure.primary.layout
		end
	end

	-- Store the selected profile in settings.
	if not self.dockTo then
		self.settings["profile" .. profileType] = profileId
		-- Ensure the profile has all default values filled in and reset the settings cache.
		-- Only do this if already initialized. Otherwise it'll happen multiple times at startup.
		-- `Init()` takes care of these steps at startup.
		if self.initialized then
			self.settings:SetDefaults(false, BS_SETTING_SCOPE.INVENTORY)
			self.settings:InitCache()
		end
	end

	-- Update docked inventory to use the same profile.
	if not self.dockTo and self.dockedInventory then
		self.dockedInventory:SetProfile(profileId, profileType)
	end

	return profileId
end



--- Enable self:PrintDebug() for Inventory classes that prefixes the output with the
--- inventory type and enables control of debug output at the class instance level.
function Inventory:PrintDebug(msg, r, g, b)
	if self.debug then
		Bagshui:PrintDebug(msg, self.inventoryType, r, g, b)
	end
end



--- Call the same function for every Inventory class instance.
---@param functionName string
function Bagshui:CallInventoryClassFunctionForAll(functionName, arg1, arg2, arg3)
	if self.prototypes.Inventory[functionName] then
		for _, inventoryType in pairs(BS_INVENTORY_TYPE) do
			self.components[inventoryType][functionName](self.components[inventoryType], arg1, arg2, arg3)
		end
	end
end



--- Trigger `Resort()` for every every Inventory class instance.
--- Used by key bindings.
function Bagshui:ResortAll()
	self:CallInventoryClassFunctionForAll("Resort")
end



--- Trigger `Restack()` for every every Inventory class instance.
--- Used by key bindings.
function Bagshui:RestackAll()
	self:CallInventoryClassFunctionForAll("Restack")
end


end)