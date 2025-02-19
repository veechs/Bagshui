-- Bagshui WoW Game Information Loader
-- Exposes: BsGameInfo (and Bagshui.components.GameInfo)
-- Raises: BAGSHUI_GAME_UPDATE

Bagshui:AddComponent(function()

-- Information constructed here is used for localization and generation of default categories.

Bagshui:AddConstants({
	BS_INVENTORY_SLOT_NAMES = {
		HeadSlot = _G.INVTYPE_HEAD,
		NeckSlot = _G.INVTYPE_NECK,
		ShoulderSlot = _G.INVTYPE_SHOULDER,
		BackSlot = _G.INVTYPE_CLOAK,
		ChestSlot = _G.INVTYPE_CHEST,
		ShirtSlot = _G.INVTYPE_SHIELD,
		TabardSlot = _G.INVTYPE_TABARD,
		WristSlot = _G.INVTYPE_WRIST,
		HandsSlot = _G.INVTYPE_HAND,
		WaistSlot = _G.INVTYPE_WAIST,
		LegsSlot = _G.INVTYPE_LEGS,
		FeetSlot = _G.INVTYPE_FEET,
		Finger0Slot = _G.INVTYPE_FINGER,
		Finger1Slot = _G.INVTYPE_FINGER,
		Trinket0Slot = _G.INVTYPE_TRINKET,
		Trinket1Slot = _G.INVTYPE_TRINKET,
		MainHandSlot = _G.INVTYPE_WEAPONMAINHAND,
		SecondaryHandSlot = _G.INVTYPE_WEAPONOFFHAND,
		RangedSlot = _G.INVTYPE_RANGED,
	},

	-- Map item subclasses to the skills they require.
	-- Only needed when the subclass doesn't match the skill name.
	BS_ITEM_SUBCLASS_TO_SKILL = {
		["Fishing Pole"] = "Fishing",
		["One-Handed Axes"] = "Axes",
		["One-Handed Maces"] = "Maces",
		["One-Handed Swords"] = "Swords",
		["Plate"] = "Plate Mail",
		["Shields"] = "Shield",
	},
})


-- Prepare storage of game information.
local GameInfo = {

	-- Character classes.
	-- Keys: English UPPERCASE names
	-- Values: English Proper Noun Case names
	characterClasses = {
		["DRUID"]   = "Druid",
		["HUNTER"]  = "Hunter",
		["MAGE"]    = "Mage",
		["PALADIN"] = "Paladin",
		["PRIEST"]  = "Priest",
		["ROGUE"]   = "Rogue",
		["SHAMAN"]  = "Shaman",
		["WARLOCK"] = "Warlock",
		["WARRIOR"] = "Warrior",
	},

	-- Item classes added here are not covered by GetAuctionItemClasses and
	-- need to be localized manually in the locale file.
	-- Key case must match the case of the item class as returned by the game.
	itemClasses = {
		["Key"] = "Key",
		["Miscellaneous"] = "Miscellaneous",
		["Quest"] = "Quest",
		["Trade Goods"] = "Trade Goods",
	},

	-- Item subclasses added here are not covered by GetAuctionItemSubClasses.
	itemSubclasses = {},

	-- Need these mappings to call GetAuctionItemSubClasses.
	itemSubClassIds = {
		Weapon = 1,
		Armor = 2,
		Container = 3,
		Projectile = 6,
		Quiver = 7,
		Recipe = 8
	},

	-- List of inventory slot locations, used to generate rule function templates.
	inventorySlots = {},

	-- Class translation helper tables.
	reverseTranslatedCharacterClasses = {},
	lowercaseReverseTranslatedCharacterClasses = {},
	lowercaseToNormalCaseReverseTranslatedCharacterClasses = {},
	lowercaseLocalizedCharacterClasses = {},
	lowercaseToNormalCaseLocalizedCharacterClasses = {},

	-- Game state tracking.
	currentZone = "",
	currentRealZone = "",
	currentSubZone = "",
	currentMinimapZone = "",
	playerGroupType = BS_GAME_PLAYER_GROUP_TYPE.SOLO,
	isInInstance = nil,  -- Game returns 1/nil so we're just going with it here.
	instanceType = "none",
	lootMethod = "freeforall",
	masterLooterPartyId = nil,
}
Bagshui.environment.BsGameInfo = GameInfo
Bagshui.components.GameInfo = GameInfo



-- Populate item classes and subclasses.

GameInfo.itemClasses["Weapon"],
GameInfo.itemClasses["Armor"],
GameInfo.itemClasses["Container"],
GameInfo.itemClasses["Consumable"],
GameInfo.itemClasses["Trade Goods"],
GameInfo.itemClasses["Projectile"],
GameInfo.itemClasses["Quiver"],
GameInfo.itemClasses["Recipe"],
GameInfo.itemClasses["Reagent"],
GameInfo.itemClasses["Miscellaneous"] = _G.GetAuctionItemClasses()

for itemClass, localizedItemClass in pairs(GameInfo.itemClasses) do
	GameInfo.itemSubclasses[itemClass] = {}
end

GameInfo.itemSubclasses["Weapon"]["One-Handed Axes"],
GameInfo.itemSubclasses["Weapon"]["Two-Handed Axes"],
GameInfo.itemSubclasses["Weapon"]["Bows"],
GameInfo.itemSubclasses["Weapon"]["Guns"],
GameInfo.itemSubclasses["Weapon"]["One-Handed Maces"],
GameInfo.itemSubclasses["Weapon"]["Two-Handed Maces"],
GameInfo.itemSubclasses["Weapon"]["Polearms"],
GameInfo.itemSubclasses["Weapon"]["One-Handed Swords"],
GameInfo.itemSubclasses["Weapon"]["Two-Handed Swords"],
GameInfo.itemSubclasses["Weapon"]["Staves"],
GameInfo.itemSubclasses["Weapon"]["Fist Weapons"],
GameInfo.itemSubclasses["Weapon"]["Miscellaneous"],
GameInfo.itemSubclasses["Weapon"]["Daggers"],
GameInfo.itemSubclasses["Weapon"]["Thrown"],
GameInfo.itemSubclasses["Weapon"]["Crossbows"],
GameInfo.itemSubclasses["Weapon"]["Wands"],
GameInfo.itemSubclasses["Weapon"]["Fishing Pole"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Weapon)

GameInfo.itemSubclasses["Armor"]["Miscellaneous"],
GameInfo.itemSubclasses["Armor"]["Cloth"],
GameInfo.itemSubclasses["Armor"]["Leather"],
GameInfo.itemSubclasses["Armor"]["Mail"],
GameInfo.itemSubclasses["Armor"]["Plate"],
GameInfo.itemSubclasses["Armor"]["Shields"],
GameInfo.itemSubclasses["Armor"]["Librams"],
GameInfo.itemSubclasses["Armor"]["Idols"],
GameInfo.itemSubclasses["Armor"]["Totems"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Armor)

GameInfo.itemSubclasses["Container"]["Bag"],
GameInfo.itemSubclasses["Container"]["Soul Bag"],
GameInfo.itemSubclasses["Container"]["Herb Bag"],
GameInfo.itemSubclasses["Container"]["Enchanting Bag"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Container)

GameInfo.itemSubclasses["Projectile"]["Arrow"],
GameInfo.itemSubclasses["Projectile"]["Bullet"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Projectile)

GameInfo.itemSubclasses["Quiver"]["Quiver"],
GameInfo.itemSubclasses["Quiver"]["Ammo Pouch"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Quiver)

GameInfo.itemSubclasses["Recipe"]["Book"],
GameInfo.itemSubclasses["Recipe"]["Leatherworking"],
GameInfo.itemSubclasses["Recipe"]["Tailoring"],
GameInfo.itemSubclasses["Recipe"]["Engineering"],
GameInfo.itemSubclasses["Recipe"]["Blacksmithing"],
GameInfo.itemSubclasses["Recipe"]["Cooking"],
GameInfo.itemSubclasses["Recipe"]["Alchemy"],
GameInfo.itemSubclasses["Recipe"]["First Aid"],
GameInfo.itemSubclasses["Recipe"]["Enchanting"],
GameInfo.itemSubclasses["Recipe"]["Fishing"] = _G.GetAuctionItemSubClasses(GameInfo.itemSubClassIds.Recipe)


-- Item subclasses not provided by GetAuctionItemClasses which need to be localized manually in the locale file.
GameInfo.itemSubclasses["Key"]["Key"] = "Key"
GameInfo.itemSubclasses["Miscellaneous"]["Junk"] = "Junk"
GameInfo.itemSubclasses["Quest"]["Quest"] = "Quest"
GameInfo.itemSubclasses["Trade Goods"]["Devices"] = "Devices"
GameInfo.itemSubclasses["Trade Goods"]["Explosives"] = "Explosives"
GameInfo.itemSubclasses["Trade Goods"]["Parts"] = "Parts"
GameInfo.itemSubclasses["Trade Goods"]["Trade Goods"] = "Trade Goods"



-- Populate Inventory Slots.
-- Automatically build the English -> localized translations of inventory slot names.
-- (INVTYPE_X -> localized doesn't need to be stored because it's always available in global variables).
for globalVariable, englishName in pairs({
	-- Armor.
	INVTYPE_BODY = "Shirt",
	INVTYPE_CHEST = "Chest",
	INVTYPE_CLOAK = "Back",
	INVTYPE_FEET = "Feet",
	INVTYPE_FINGER = "Finger",
	INVTYPE_HAND = "Hands",
	INVTYPE_HEAD = "Head",
	INVTYPE_LEGS = "Legs",
	INVTYPE_NECK = "Neck",
	INVTYPE_ROBE = "Chest",
	INVTYPE_SHOULDER = "Shoulder",
	INVTYPE_WAIST = "Waist",
	INVTYPE_WRIST = "Wrist",

	-- Weapons.
	INVTYPE_RANGED = "Ranged",
	INVTYPE_WEAPON = "One-Hand",
	INVTYPE_2HWEAPON = "Two-Hand",
	INVTYPE_WEAPONMAINHAND = "Main Hand",
	INVTYPE_WEAPONOFFHAND = "Off Hand",
	INVTYPE_SHIELD = "Off Hand",
	INVTYPE_HOLDABLE = "IHeld In Off-hand",
	INVTYPE_RELIC = "Relic",

	-- Other.
	INVTYPE_BAG = "Bag",
	INVTYPE_TABARD = "Tabard",
	INVTYPE_TRINKET = "Trinket",
}) do
	GameInfo.inventorySlots[englishName] = _G[globalVariable]
end



--- Some game information can't be built until the Bagshui localization has been loaded.
function GameInfo:PopulatePostLocalizationInfo()

	-- Professions to profession bags.
	self.professionsToBags = {
		[L.Enchanting] = L["Enchanting Bag"],
		[L.Herbalism] = L["Herb Bag"],
	}

	-- Alphabetically sorted list of player classes.
	self.sortedCharacterClasses = {}
	for uppercaseClass, nounCaseClass in pairs(self.characterClasses) do
		self.reverseTranslatedCharacterClasses[L[nounCaseClass]] = nounCaseClass
		table.insert(self.sortedCharacterClasses, uppercaseClass)
	end
	table.sort(self.sortedCharacterClasses, function(a, b)
		return L[self.characterClasses[a]] < L[self.characterClasses[b]]
	end)

	-- Provide a menu template for player classes.
	-- Used by Category Editor and Inventory Edit Mode Direct Assignment menu.
	self.characterClassMenu = {}
	for _, class in ipairs(BsGameInfo.sortedCharacterClasses) do
		table.insert(
			self.characterClassMenu,
			{
				text = L[BsGameInfo.characterClasses[class]],
				value = class,
			}
		)
	end

	-- Used by RequiresClass.
	for _, nounCaseClass in pairs(self.characterClasses) do
		self.lowercaseReverseTranslatedCharacterClasses[string.lower(L[nounCaseClass])] = string.lower(nounCaseClass)
		self.lowercaseToNormalCaseReverseTranslatedCharacterClasses[string.lower(L[nounCaseClass])] = nounCaseClass
	end
	for _, nounCaseClass in pairs(self.characterClasses) do
		self.lowercaseLocalizedCharacterClasses[string.lower(nounCaseClass)] = string.lower(L[nounCaseClass])
		self.lowercaseToNormalCaseLocalizedCharacterClasses[string.lower(nounCaseClass)] = L[nounCaseClass]
	end
end



--- Storage helper for `GameInfo:UpdateLocation()`.
--- Returns nil if the string is empty.
---@param str any
---@return any
local function nilForEmptyString(str)
	return string.len(str or "") > 0 and str or nil
end



-- Tracking variables used to determine whether UpdateLocation() should raise BAGSHUI_GAME_UPDATE.

local oldZone, oldRealZone, oldSubZone, oldMinimapZone, oldInInstance, oldInstanceType

--- Store current location data.
function GameInfo:UpdateLocation()
	oldZone = self.currentZone
	oldRealZone = self.currentRealZone
	oldSubZone = self.currentSubZone
	oldMinimapZone = self.currentMinimapZone
	oldInInstance = self.isInInstance
	oldInstanceType = self.instanceType

	self.currentZone = nilForEmptyString(_G.GetZoneText())
	self.currentRealZone = nilForEmptyString(_G.GetRealZoneText())
	self.currentSubZone = nilForEmptyString(_G.GetSubZoneText())
	self.currentMinimapZone = nilForEmptyString(_G.GetMinimapZoneText())
	self.isInInstance, self.instanceType = _G.IsInInstance()

	if
		oldZone ~= self.currentZone
		or oldRealZone ~= self.currentRealZone
		or oldSubZone ~= self.currentSubZone
		or oldMinimapZone ~= self.currentMinimapZone
		or oldInInstance ~= self.isInInstance
		or oldInstanceType ~= self.instanceType
	then
		Bagshui:RaiseEvent("BAGSHUI_GAME_UPDATE")
	end
end



-- Tracking variables used to determine whether UpdateLocation() should raise BAGSHUI_GAME_UPDATE.

local oldPlayerGroupType, oldLootMethod, oldMasterLooter

-- Reusable variable for `GetLootMethod()` return value.
local masterLooterPartyId

--- Store current group (as in party/raid) data.
function GameInfo:UpdateGroup()
	oldPlayerGroupType = self.playerGroupType
	oldLootMethod = self.lootMethod
	oldMasterLooter = self.isMasterLooter

	-- There's no GetGroupType() but we can infer it.=
	self.playerGroupType = (
		(_G.GetNumRaidMembers() or 0) > 0 and BS_GAME_PLAYER_GROUP_TYPE.RAID
		or (_G.GetNumPartyMembers() or 0) > 0 and BS_GAME_PLAYER_GROUP_TYPE.PARTY
		or BS_GAME_PLAYER_GROUP_TYPE.SOLO
	)

	-- Don't need the third return value from GetLootMethod() because 
	-- the second is 0 if the current player is the master looter.
	self.lootMethod, masterLooterPartyId = _G.GetLootMethod()
	self.isMasterLooter = (self.lootMethod == "master" and masterLooterPartyId == 0)

	if
		oldPlayerGroupType ~= self.playerGroupType
		or oldLootMethod ~= self.lootMethod
		or oldMasterLooter ~= self.isMasterLooter
	then
		Bagshui:RaiseEvent("BAGSHUI_GAME_UPDATE")
	end
end



--- Zone output helper for the GameInfo slash handler.
--- Only prints both zones if they're different and non-nil.
---@param z1 string? First zone.
---@param z2 string? Second zone.
local function printNonNilZones(z1, z2)
	local mainZone = z1 or z2
	if not mainZone then
		return
	end
	Bs:PrintBare(BS_INDENT .. mainZone)
	if mainZone == z2 or not z2 then
		return
	end
	Bs:PrintBare(BS_INDENT .. z2)
end



--- Event handling.
---@param event string Event identifier.
---@param arg1 any? Argument 1 from the event.
function GameInfo:OnEvent(event, arg1)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UpdateLocation()
		self:UpdateGroup()
		return
	end

	if
		string.find(event, "ZONE")
	then
		self:UpdateLocation()
		return
	end

	if
		string.find(event, "PARTY")
		or string.find(event, "RAID")
	then
		self:UpdateGroup()
		return
	end

	if event == "BAGSHUI_LOCALIZATION_LOADED" then
		self:PopulatePostLocalizationInfo()

		BsSlash:AddHandler("Game", function(tokens)
			if not tokens[2] then
				BsSlash:PrintHandlers({L.Location, L.Group}, "Game")

			elseif
				BsUtil.MatchLocalizedOrNon(tokens[2], "location")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "instance")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "zone")
			then
				Bs:Print(string.format(L.Symbol_Colon, L.Location))

				Bs:PrintBare(string.format(L.Symbol_Colon, L.Zone))
				printNonNilZones(self.currentZone, self.currentSubZone)
				Bs:PrintBare(string.format(L.Symbol_Colon, L.Subzone))
				printNonNilZones(self.currentSubZone, self.currentMinimapZone)

				Bs:PrintBare(string.format(L.Symbol_Colon, L.Instance))
				if not self.isInInstance or self.instanceType == "none" then
					Bs:PrintBare(BS_INDENT .. L.NoneParenthesis)
				else
					Bs:PrintBare(BS_INDENT .. self.instanceType)
				end

			elseif
				BsUtil.MatchLocalizedOrNon(tokens[2], "group")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "party")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "loot")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "raid")
			then
				Bs:Print(string.format(L.Symbol_Colon, _G.GROUP))
				Bs:PrintBare(BS_INDENT .. self.playerGroupType)

				Bs:PrintBare(string.format(L.Symbol_Colon, _G.LOOT))
				Bs:PrintBare(BS_INDENT .. string.format(L.Symbol_Colon, _G.LOOT_METHOD) .. " " .. self.lootMethod)
				Bs:PrintBare(BS_INDENT .. "IsLootMaster? " .. tostring(self.isMasterLooter))
			end
		end)

		return
	end
end

Bagshui:RegisterEvent("BAGSHUI_LOCALIZATION_LOADED", GameInfo)
-- Location events.
Bagshui:RegisterEvent("PLAYER_ENTERING_WORLD", GameInfo)
Bagshui:RegisterEvent("MINIMAP_ZONE_CHANGED", GameInfo)
Bagshui:RegisterEvent("ZONE_CHANGED", GameInfo)
Bagshui:RegisterEvent("ZONE_CHANGED_NEW_AREA", GameInfo)
Bagshui:RegisterEvent("ZONE_CHANGED_INDOORS", GameInfo)
-- Group events.
Bagshui:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", GameInfo)
Bagshui:RegisterEvent("PARTY_MEMBERS_CHANGED", GameInfo)
Bagshui:RegisterEvent("RAID_ROSTER_UPDATE", GameInfo)


end)