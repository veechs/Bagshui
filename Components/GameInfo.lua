-- Bagshui WoW Game Information Loader
-- Exposes: BsGameInfo (and Bagshui.components.GameInfo)

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

	-- Item subclasses that don't require a skill.
	BS_ITEM_SUBCLASS_NO_SKILL_NEEDED = {
		Idols = true,
		Librams = true,
		Miscellaneous = true,
	}
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

	-- Localized version of BS_ITEM_SUBCLASS_TO_SKILL.
	itemSubclassToSkill = {},

	-- Localized version of BS_ITEM_SUBCLASS_NO_SKILL_NEEDED.
	itemSubclassNoSkillNeeded = {},

	-- Class translation helper tables.
	reverseTranslatedCharacterClasses = {},
	lowercaseReverseTranslatedCharacterClasses = {},
	lowercaseToNormalCaseReverseTranslatedCharacterClasses = {},
	lowercaseLocalizedCharacterClasses = {},
	lowercaseToNormalCaseLocalizedCharacterClasses = {},
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

	-- Used by ItemInfo:IsUsable().
	for subclass, skill in pairs(BS_ITEM_SUBCLASS_TO_SKILL) do
		self.itemSubclassToSkill[L[subclass]] = L[skill]
	end
	for subclass, _ in pairs(BS_ITEM_SUBCLASS_NO_SKILL_NEEDED) do
		self.itemSubclassNoSkillNeeded[L[subclass]] = true
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



--- Event handling.
---@param event string Event identifier.
---@param arg1 any? Argument 1 from the event.
function GameInfo:OnEvent(event, arg1)
	if event == "BAGSHUI_LOCALIZATION_LOADED" then
		self:PopulatePostLocalizationInfo()
	end
end

Bagshui:RegisterEvent("BAGSHUI_LOCALIZATION_LOADED", GameInfo)


end)