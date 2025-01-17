-- Bagshui Default Categories
-- Exposes: Bagshui.config.Categories
--
-- The goal is to provide a reasonably complete set of built-in categories that
-- cover a large number of use cases without getting too much into the weeds.
-- 
-- Some intentional omissions that should be filled with custom categories if desired:
-- - Categories for every Type()/Subtype().
-- - Tokens - PeriodicTable().

Bagshui:AddComponent(function()

-- Array of tables that defines non-editable built-in categories.
-- Table properties can be anything in `BS_CATEGORY_SKELETON` (see Components\Categories.lua),
-- but each one *must* have a unique `id` property that will become its object ID.
---@type table<string, any>[]
Bagshui.config.Categories = {
	version = 1,

	defaults = {
		-- Other/Unknown (default fallback category when nothing else matches).
		{
			id = "Uncategorized",
			name = L.Uncategorized,
			sequence = 102,  -- Put this outside the user-accessible sequence range AFTER empty slots so it's processed last.
			rule = "*",  -- Super-secret rule expression that instantly matches anything.
			hidden = true,  -- Shouldn't be visible.
		},


		-- Gray Items.
		{
			id = "QualGray",
			name = string.format(L.Suffix_Items, L.Gray),  -- "Gray Items"
			nameSort = "_" .. string.format(L.Suffix_Items, L.Gray),
			sequence = 99,
			rule = 'Quality(0)',
		},


		-- Empty Slots.
		{
			id = "EmptySlot",
			name = L.EmptySlots,
			sequence = 100,
			rule = 'EmptySlot()',
		},



		-- Food and Drink are just type: Consumable, subtype: Consumable in Vanilla, so tooltip parsing is required.

		{
			id = "FoodBuffs",
			name = L.FoodBuffs,
			nameSort = L.Consumables .. " - " .. L.Buffs .. " - " .. L.FoodBuffs,
			sequence = 67,  -- Run before the normal Food rule.
			rule = string.format('Tooltip("%s") and Tooltip("%s", "%s")', L.TooltipIdentifier_Food, L.TooltipIdentifier_Buff_WellFed, L.TooltipIdentifier_Buff_AlsoIncreases),
		},

		{
			id = "Food",
			name = L.Food,
			nameSort = L.Consumables .. " - " .. L.Food .. "/" .. L.Drink .. " - " .. L.Food,
			-- Run before Drink to ensure deterministic behavior.
			sequence = 68,
			rule = string.format('Tooltip("%s")', L.TooltipIdentifier_Food),
		},

		{
			id = "Drink",
			name = L.Drink,
			nameSort = L.Consumables .. " - " .. L.Food .. "/" .. L.Drink .. " - " .. L.Drink,
			-- Run after Food so any items with conflicting tooltips are handled deterministically
			-- and before default so that there's no undefined behavior with consumables.
			sequence = 69,
			rule = string.format('Tooltip("%s")', L.TooltipIdentifier_Drink),
		},


		{
			id = "Consumables",
			name = L.Consumables,
			sequence = 90,
			rule = string.format('Type("%s")', L.Consumable),
		},



		-- Potions, Elixirs, and Scrolls are also type: Consumable, subtype: Consumable in Vanilla, so we have to look at tooltips/names.

		{
			id = "Elixirs",
			name = L.Elixirs,
			nameSort = L.Consumables .. " - " .. L.Buffs .. " - " .. L.Elixirs,
			sequence = 68,  -- This has to run before the Health Potions rule
			rule = string.format('Name("%s")', L.NameIdentifier_Elixir),
			list = {   -- There are items that have Elixir-like effects but don't have Elixir in the name
				20079,  -- Spirit of Zanza
				20080,  -- Sheen of Zanza
				20081,  -- Swiftness of Zanza
				8410,  -- R.O.I.D.S.
				8411,  -- Lung Juice Cocktail
				8412,  -- Ground Scorpok Assay
				8423,  -- Cerebral Cortex Compound
				8424,  -- Gizzard Gum

				13510,  -- Flask of the Titans
				13511,  -- Flask of Distilled Wisdom
				13512,  -- Flask of Supreme Power
				13513,  -- Flask of Chromatic Resistance
				13506,  -- Flask of Petrification
				9088,  -- Gift of Arthas
				3388,  -- Strong Troll's Blood Potion
				3826,  -- Mighty Troll's Blood Potion
				20004,  -- Major Troll's Blood Potion
				20007,  -- Mageblood Potion
			}
		},

		{
			id = "PotionsHealth",
			name = string.format(L.Suffix_Potions, L.Health),
			nameSort = L.Consumables .. " - " .. L.Potions .. " - " .. L.Health,
			sequence = 69,  -- Make sure to catch these before the normal name-based Potions rule.
			rule = string.format('Tooltip("%s")', L.TooltipIdentifier_PotionHealth),
		},

		{
			id = "PotionsMana",
			name = string.format(L.Suffix_Potions, L.Mana),
			nameSort = L.Consumables .. " - " .. L.Potions .. " - " .. L.Mana,
			sequence = 69,  -- Make sure to catch these before the normal name-based Potions rule.
			rule = string.format('Tooltip("%s")', L.TooltipIdentifier_PotionMana),
		},

		{
			id = "Potions",
			name = L.Potions,
			nameSort = L.Consumables .. " - " .. L.Potions,
			rule = string.format('Name("%s")', L.NameIdentifier_Potion),
		},

		{
			id = "Scrolls",
			name = L.Scrolls,
			nameSort = L.Consumables .. " - " .. L.Buffs .. " - " .. L.Juju,
			sequence = 69,  -- This has to run before the Consumable rule
			rule = string.format('Name("%s")', L.NameIdentifier_Scroll),
		},



		-- Runes.
		{
			id = "Runes",
			name = L.Runes,
			nameSort = L.Consumables .. " - " .. L.Potions .. " - " .. L.Runes,
			sequence = 68,  -- This has to run before the Health Potions rule due to similar tooltips.
			list = {
				-- Mage Mana Gems
				5514,  -- Mana Agate
				5513,  -- Mana Jade
				8007,  -- Mana Citrine
				8008,  -- Mana Ruby

				-- Warlock Healthstones
				5512,  -- Minor Healthstone 0/2
				19004,  -- Minor Healthstone 1/2
				19005,  -- Minor Healthstone 2/2
				5511,  -- Lesser Healthstone 0/2
				19006,  -- Lesser Healthstone 1/2
				19007,  -- Lesser Healthstone 2/2
				5509,  -- Healthstone 0/2
				19008,  -- Healthstone 1/2
				19009,  -- Healthstone 2/2
				5510,  -- Greater Healthstone 0/2
				19010,  -- Greater Healthstone 1/2
				19011,  -- Greater Healthstone 2/2
				9421,  -- Major Healthstone 0/2
				19012,  -- Major Healthstone 1/2
				19013,  -- Major Healthstone 2/2

				-- Other
				11562,  -- Crystal Restore
				20520,  -- Dark Rune
				12662,  -- Demonic Rune
				22682,  -- Frozen Rune
				15723,  -- Tea with Sugar
				11951,  -- Whipper Root Tuber
				11952,  -- Night Dragon's Breath
			},
		},



		-- Juju.
		-- Normally type: Quest (need to check type because there is armor with "Juju" in the name).
		{
			id = "Juju",
			name = L.Juju,
			nameSort = L.Consumables .. " - " .. L.Buffs .. " - " .. L.Juju,
			sequence = 68,  -- Must run before Quest Items
			rule = string.format('Type("%s") and Name("%s")', L.Quest, L.NameIdentifier_Juju),
			list = {
				12820 -- Winterfall Firewater (not technically a JuJu, but shares a buff slot with Juju Might)
			},
		},



		-- Weapon Buff.
		-- Normally type: Consumable, subtype: Consumable
		{
			id = "WeaponBuffs",
			name = L.WeaponBuffs,
			nameSort = L.Consumables .. " - " .. L.Buffs .. " - " .. L.WeaponBuffs,
			-- Using a name rule here to avoid listing out every item.
			rule = string.format(
				'Name("%s", "%s", "%s", "%s", "%s", "%s")',
				L.NameIdentifier_FrostOil,
				L.NameIdentifier_ManaOil,
				L.NameIdentifier_ShadowOil,
				L.NameIdentifier_SharpeningStone,
				L.NameIdentifier_Weightstone,
				L.NameIdentifier_WizardOil
			),
		},



		-- Soulbound Gear.
		{
			id = "SoulboundGear",
			name = L.SoulboundGear,
			nameSort = L.Gear .. " - " .. L.MyGear .. " - " .. L.SoulboundGear,
			sequence = 88,  -- Must run before BOE, Armor, and Weapons
			rule = string.format('Soulbound() and Type("%s", "%s")', L.Armor, L.Weapon),
		},

		-- Worn Gear (has been equipped at least once).
		{
			id = "EquippedGear",
			name = L.EquippedGear,
			nameSort = L.Gear .. " - " .. L.MyGear .. " - " .. L.EquippedGear,
			sequence = 87,  -- Must run before all other equipment categories.
			rule = 'Equipped()',
		},

		-- Binds on Equip (BOE).
		{
			id = "BOE",
			name = L.BindOnEquip,
			nameSort = L.Gear .. " - " .. L.BindOnEquip,
			sequence = 89,  -- Must run before Armor and Weapons.
			rule = 'BindsOnEquip()',
		},

		-- Armor.
		{
			id = "Armor",
			name = L.Armor,
			nameSort = L.Gear .. " - " .. L.Other .. " - " .. L.Armor,
			sequence = 90,
			rule = string.format('Type("%s")', L.Armor),
		},

		-- Weapons.
		{
			id = "Weapons",
			name = L.Weapons,
			nameSort = L.Gear .. " - " .. L.Other .. " - " .. L.Weapons,
			sequence = 90,
			rule = string.format('Type("%s")', L.Weapon),
		},



		-- Recipes.
		{
			id = "Recipes",
			name = L.Recipes,
			-- Run before Food/Drink to avoid tooltip confusion. Two examples:
			-- 1. The Food and Drink categories use tooltips for identification. When a recipe
			--    has the crafting result in its tooltip, the Food/Drink rule can incorrectly match the recipe.
			-- 2. Weapon Buffs are identified by their names, which also match the recipe names.
			-- 3. The "Top/Bottom Half of Advanced..." pieces need to be captured.
			sequence = 66,
			rule = string.format(
				'Type("%s")\nor\n(\n  Name("/^%s/", "/^%s/")\n  and Subtype("%s", "%s")\n)',
				L.Recipe,
				L.NameIdentifier_Recipe_TopHalf,
				L.NameIdentifier_Recipe_BottomHalf,
				L.Junk,
				L.Quest
			),
		},



		-- Profession Reagents for learned professions.
		-- This includes profession bags so empty slots are grouped with the reagents.
		{
			id = "ProfessionReagents",
			name = L.Category_ProfessionReagents,
			nameSort = L.ProfessionReagents,
			sequence = 68,  -- Run after Profession Crafts.
			rule = 'ProfessionReagent()',
		},

		-- Profession Bags for learned professions.
		{
			id = "ProfessionBags",
			name = L.Category_ProfessionBags,
			sequence = 68,  -- Run after Profession Crafts.
			rule = 'BagType(ProfessionBag)',
		},

		-- Profession Crafts for learned professions.
		{
			id = "ProfessionCrafts",
			name = L.Category_ProfessionCrafts,
			nameSort = L.ProfessionCrafts,
			sequence = 66,  -- Run before most other builtins to give it priority.
			rule = 'ProfessionCraft()',
		},

		-- Profession Bags, including those for professions the current character doesn't have.
		{
			id = "AllProfessionBags",
			name = L.Category_ProfessionBagsAll,
			sequence = 90,  -- Low priority.
			rule = 'BagType(AllProfessionBags)',
		},



		{
			id = "TradeTools",
			name = L.TradeTools,
			sequence = 67,  -- Must run before Profession Crafts.
			list = {
				7005,  -- Skinning Knife
				5956,  -- Blacksmith Hammer
				6219,  -- Arclight Spanner
				2901,  -- Mining Pick
				6218,  -- Runed Copper Rod
				6339,  -- Runed Silver Rod
				11130,  -- Runed Golden Rod
				11145,  -- Runed Truesilver Rod
				16207,  -- Runed Arcanite Rod
				9149,  -- Philosopher's Stone
				4471,  -- Flint and Tinder
			},
		},



		-- Quest Items.
		-- There is not a combo category for `Type('Quest') or Tooltip('%s') or ActiveQuest()`
		-- because the Active Quest Items rule needs  to have a low sequence number in order
		-- for it to step in and grab things that aren't normally quest items, but the normal
		-- Quest Items rule shouldn't steal away from other categories.
		{
			id = "Quest",
			sequence = 75,
			name = string.format(L.Suffix_Items, L.Quest),  -- "Quest Items"
			rule = string.format('Type("%s") or Tooltip("%s")', L.Quest, L.TooltipIdentifier_QuestItem),
		},

		{
			id = "ActiveQuest",
			sequence = 61,
			name = string.format(L.Suffix_Items, L.ActiveQuest),
			-- Giving this the same sorting name as the normal Quest Items rule so everything sorts normally within the group.
			nameSort = string.format(L.Suffix_Items, L.Quest),
			rule = 'ActiveQuest()',
		},



		-- There aren't too many teleport-type items in Vanilla but let's make a category for them anyway.
		{
			id = "Teleports",
			name = L.Teleports,
			sequence = 87,  -- Must run before Soulbound because some of these are soulbound.
			list = {
				6948,  -- Hearthstone
				18986,  -- Ultrasafe Transporter: Gadgetzan
				18984,  -- Dimensional Ripper - Overlook
				51313,  -- Portable Wormhole Generator: Orgrimmar (Turtle WoW)
				61000,  -- Time-Worn Rune (Turtle WoW)
			},
		},


		-- Disguises.
		-- Mostly originally Consumable/Consumable, but some are Miscellaneous/Junk.
		{
			id = "Disguises",
			sequence = 64,
			name = L.Disguises,
			list = {
				20557,  -- Hallow's End Pumpkin Treat
				21212,  -- Fresh Holly
				18258,  -- Gordok Ogre Suit
				8529,  -- Noggenfogger Elixir
				21213,  -- Preserved Holly
				6657,  -- Savory Deviate Delight
				17712,  -- Winter Veil Disguise Kit
				50744,  -- Winterax Disguise (Turtle WoW)
			},
			rule = string.format('Name("%s")', L.NameIdentifier_HallowedWand),  -- There are multiple Hallowed wands so we'll just use the name here.
		},


		-- First Aid (Bandages, Anti-Venom).
		-- Normally type: Consumable, subtype: Consumable
		{
			id = "Bandages",  -- Don't change this to FirstAid -- it would break existing Structures.
			name = L.FirstAid,
			rule = string.format('(Subtype("%s") and Name("%s", "%s")) or PeriodicTable("Consumable.Bandage", "Misc.Antivenom")', L.Consumables, L.NameIdentifier_Bandage, L.NameIdentifier_AntiVenom),
		},


		-- Trade Goods.
		{
			id = "TradeGoods",
			name = L["Trade Goods"],
			sequence = 90,
			rule = string.format('Type("%s") or BagType(AllProfessionBags)', L["Trade Goods"]),
		},


		-- Explosives.
		{
			id = "Explosives",
			name = L.Explosives,
			sequence = 89,  -- Must run before Trade Goods,
			rule = string.format('Subtype("%s")', L.Explosives),
		},


		-- Bags.
		{
			id = "Bags",
			name = L.Bags,
			sequence = 88,  -- Must run before BOE.
			rule = string.format('Type("%s", "%s")', L.Container, L.Quiver),
		},


		-- Keys (and key-like items).
		{
			id = "KeyAndKeyLike",
			name = L.Keys,
			rule = string.format('Type("%s")', L.Key),
			list = {
				18266,  -- Gordok Courtyard Key (one time use)
				18268,  -- Gordok Inner Door Key (one time use)
				12344,  -- Seal of Ascension
				9240,  -- Mallet of Zul'Farrak
				17191,  -- Scepter of Celebras
				16309,  -- Drakefire Amulet
				17333,  -- Aqual Quintessence
				22754,  -- Eternal Quintessence
				15138,  -- Onyxia Scale Cloak
				21986,  -- Banner of Provocation
				22014,  -- Hallowed Brazier
			}
		},


		-- Tokens.
		{
			id = "Tokens",
			name = L.Tokens,
			sequence = 74,  -- Must run before Quest.
			rule = 'PeriodicTable("Tokens")',  -- Tokens are identified in Config\PeriodicTable.lua, not here, because there are a LOT.
		},



		-- Mounts.
		-- Normally type: Miscellaneous and subtype: Junk, so a tooltip check is required.
		{
			id = "Mounts",
			name = L.Mounts,
			rule = string.format(
				'Tooltip("%s", "%s")',
				L.TooltipIdentifier_Mount,
				L.TooltipIdentifier_MountAQ40
			),
		},


		-- Companions.
		-- Normally type: Miscellaneous and subtype: Junk, so a tooltip check is required.
		{
			id = "Companions",
			name = L.Companions,
			rule = string.format('Tooltip("%s")', L.TooltipIdentifier_Companion),
		},



		-- Class Reagents.
		{
			id = "ClassReagents",
			name = string.format(L.Prefix_Class, L.Reagents),
			sequence = 68,  -- Run before the default of 70 and before Profession Reagents at 69.
			classes = {
				-- Class names must be UPPERCASE here because that's how the game API returns them.
				DRUID = {
					list = {
						17036,  -- Ashwood Seed
						17037,  -- Hornbeam Seed
						17038,  -- Ironwood Seed
						17034,  -- Maple Seed
						17035,  -- Stranglethorn Seed
						17021,  -- Wild Berries
						17026,  -- Wild Thornroot
						61199,  -- Bright Dream Shard (Turtle WoW)
					},
				},
				HUNTER = {
					list = {
						21223,
						16204,
					},
				},
				MAGE = {
					list = {
						17020,  -- Arcane Powder
						17032,  -- Rune of Portals
						17031,  -- Rune of Teleportation
						17056,  -- Light Feather
						5517,  -- Tiny Bronze Key
						8147,  -- Tiny Copper Key
						5518,  -- Tiny Iron Key
						8148,  -- Tiny Silver Key
					},
				},
				PALADIN = {
					list = {
						17033,  -- Symbol of Divinity
						21177,  -- Symbol of Kings
					},
				},
				PRIEST = {
					list = {
						17029,  -- Sacred Candle
						17028,  -- Holy Candle
						17056,  -- Light Feather
					},
				},
				ROGUE = {
					list = {
						5530,  -- Blinding Powder
						5140,  -- Flash Powder
						7676,  -- Thistle Tea (technically not a reagent)
					},
				},
				SHAMAN = {
					list = {
						17030,  -- Ankh
						17058,  -- Fish Oil
						17057,  -- Shiny Fish Scales
					},
				},
				WARLOCK = {
					list = {
						16583,  -- Demonic Figurine
						5565,  -- Infernal Stone
					},
				},
			}
		},


		-- Class Items.
		{
			id = "ClassItems",
			name = string.format(L.Prefix_Class, L.Items),
			sequence = 69,  -- Run before the default of 70.
			classes = {
				-- Class names must be UPPERCASE here because that's how the game API returns them.
				HUNTER = {
					-- Putting projectiles and ammo bag slots together as class items for Hunters
					rule = string.format('Type("%s") or BagType("%s", "%s")', L.Projectile, L["Ammo Pouch"], L["Quiver"])
				},
				ROGUE = {
					list = {
						5060,  -- Thieves' Tools
					},
					-- Poisons: Tooltip has "Classes: Rogue", Name has "Poison", and Type: Consumable
					rule = string.format(
						'RequiresClass("%s") and Name("%s") and Type("%s")',
						L.Rogue,
						L.NameIdentifier_Poison,
						L.Consumables
					),
				},
				SHAMAN = {
					list = {
						5178,  -- Air Totem
						5175,  -- Earth Totem
						5176,  -- Fire Totem
						5177,  -- Water Totem
					},
				},
				WARLOCK = {
					list = {
						6265,  -- Soul Shard
					},
					rule = string.format(
						'ContainerType("%s")\nor (\n  Name("%s")\n  and Type("%s")\n)\nor (\n  Name("%s", "%s")\n  and EquipLocation("INVTYPE_HOLDABLE")\n)',
						L["Soul Bag"],
						L.NameIdentifier_Soulstone,
						L.Consumables,
						L.NameIdentifier_Firestone,
						L.NameIdentifier_Spellstone
					),
				},
			}
		},


		-- Class Books.
		-- This relies on the Character table that's provided in the rule environment.
		{
			id = "ClassBooks",
			name = string.format(L.Prefix_Class, L.Books),
			sequence = 65,  -- Run before recipes
			rule = string.format('Type("%s") and Subtype("%s") and RequiresClass(character.localizedClass)', L.Recipe, L.Book),
		},



		-- Turtle WoW Glyphs.
		-- TW classifies their glyphs as keys.
		{
			id = "TWGlyphs",
			name = L.TurtleWoWGlyphs,
			sequence = 69,  -- Run before the normal Keys rule, just to be safe
			rule = string.format('Type("%s") and Name("%s")', L.Key, L.NameIdentifier_TurtleWoWGlyph),
		},
	},


	-- Currently no need for migration.
	migrate = nil,
}


end)