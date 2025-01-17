-- Bagshui PeriodicTable Configuration

Bagshui:AddComponent(function()


-- Custom PeriodicTable item lists, structured as:
-- ```
-- {
-- 	["Group Name"] = {
-- 		["PeriodicTable.Categorization"] = {
-- 			itemNum1,
-- 			itemNumN,
-- 		},
-- 	},
-- }
-- ```
---@type table<string, table<string, table<string, number>>>
local ptCustomItems = {

	["Tokens"] = {

		["Tokens.AnQuiraj"] = {
			20402, -- Agent of Nozdormu
			21230, -- Ancient Qiraji Artifact
			21762, -- Greater Scarab Coffer Key
			20403, -- Proxy of Nozdormu
			21229, -- Qiraji Lord's Insignia
			21156, -- Scarab Bag
			21761, -- Scarab Coffer Key
			20384, -- Silithid Carapace Fragment

			20858, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20859, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20860, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20861, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20862, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20863, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20864, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)
			20865, -- AQ20/40 Scarab (Cenarion Circle / Brood of Nozdormu)

			20876, -- Idol of Death
			20879, -- Idol of Life
			20875, -- Idol of Night
			20878, -- Idol of Rebirth
			20877, -- Idol of the Sage
			20881, -- Idol of Strife
			20874, -- Idol of the Sun
			20882, -- Idol of War
		},

		["Tokens.ArgentDawn"] = {
			12846, -- Argent Dawn Commission (Seal of the Dawn, Rune of the Dawn, Mark of the Champion not listed)
			12844, -- Argent Dawn Valor Token

			22523, -- Insignia of the Dawn
			22524, -- Insignia of the Crusade

			12840, -- Minion's Scourgestone
			12841, -- Invader's Scourgestone
			12843, -- Corruptor's Scourgestone

			22527, -- Core of Elements
			22528, -- Dark Iron Scraps
			22529, -- Savage Frond

			22373, -- Wartorn Leather Scrap
			22374, -- Wartorn Chain Scrap
			22375, -- Wartorn Plate Scrap
			22376, -- Wartorn Cloth Scrap

			23055, -- Word of Thawing
		},

		["Tokens.Battleground"] = {
			20560, -- Alterac Valley Mark of Honor
			20559, -- Arathi Basin Mark of Honor
			19322, -- Warsong Mark of Honor
			20558, -- Warsong Gulch Mark of Honor
			61793, -- Arena Mark of Honor (Turtle WoW)
		},

		["Tokens.BlastedLands"] = {
			8394, -- Basilisk Brain
			8392, -- Blasted Boar Lung
			8393, -- Scorpok Pincer
			8391, -- Snickerfang Jowl
			8396, -- Vulture Gizzard
		},

		["Tokens.CenarionCircle"] = {
			20802, -- Cenarion Combat Badge
			20800, -- Cenarion Logistics Badge
			20801, -- Cenarion Tactical Badge
			20404, -- Encrypted Twilight Text
			21508, -- Mark of Cenarius
			20447, -- Scepter of Beckoning: Fire
			20448, -- Scepter of Beckoning: Thunder
			20449, -- Scepter of Beckoning: Stone
			20450, -- Scepter of Beckoning: Water
			20408, -- Twilight Cultist Cowl
			20406, -- Twilight Cultist Mantle
			20422, -- Twilight Cultist Medallion of Station
			20451, -- Twilight Cultist Ring of Lordship	
			20407, -- Twilight Cultist Robe
		},

		["Tokens.Felwood"] = {
			11511, -- Cenarion Beacon
			11516, -- Cenarion Plant Salve
			11515, -- Corrupted Soul Shard	
			11514, -- Fel Creep
			11512, -- Patch of Tainted Skin
			11513, -- Tainted Vitriol
		},

		["Tokens.ThoriumBrotherhood"] = {
			18945, -- Dark Iron Residue
		},

		["Tokens.UnGoroCrater"] = {
			11184, -- Blue Power Crystal
			11185, -- Green Power Crystal
			11188, -- Red Power Crystal
			11186, -- Yellow Power Crystal
		},

		["Tokens.Winterspring"] = {
			12384, -- Cache of Mau'ari
			12434, -- Chillwind E'ko
			12435, -- Ice Maul E'ko
			12436, -- Frostmaul E'ko
			12430, -- Frostsaber E'ko
			12432, -- Shardtooth E'ko
			12433, -- Wildkin E'ko
		},

		["Tokens.ZandalarTribe"] = {
			19708, -- Blue Hakkari Bijou
			19713, -- Bronze Hakkari Bijou
			19711, -- Green Hakkari Bijou
			19715, -- Gold Hakkari Bijou
			19710, -- Orange Hakkari Bijou
			19712, -- Purple Hakkari Bijou
			19707, -- Red Hakkari Bijou
			19714, -- Silver Hakkari Bijou
			19709, -- Yellow Hakkari Bijou

			19858, -- Zandalar Honor Token
			19698, -- Zul'Gurub Coin
			19699, -- Zul'Gurub Coin
			19700, -- Zul'Gurub Coin
			19701, -- Zul'Gurub Coin
			19702, -- Zul'Gurub Coin
			19703, -- Zul'Gurub Coin
			19704, -- Zul'Gurub Coin
			19705, -- Zul'Gurub Coin
			19706, -- Zul'Gurub Coin
			19706, -- Zul'Gurub Coin
		},
	}

}



-- Pull AtlasLoot data into custom PeriodicTable categories.
if _G.IsAddOnLoaded("AtlasLoot") and type(_G.AtlasLoot_Data) == "table" and type(_G.GetSpellInfoVanillaDB) == "table" then

	--- GetSpellInfoVanillaDB stores things differently for spells and enchants.
	---@param itemId number
	---@return string? dbKey
	---@return string? itemType
	local function spellInfoLookupKeys(itemId)
		if string.sub(itemId, 1, 1) == "e" then
			return "enchants", "item"
		elseif string.sub(itemId, 1, 1) == "s" then
			return "craftspells", "craftItem"
		end
	end

	-- AtlasLootDataSourceName.AtlasLootDataId
	local ptCategory

	-- AtlasLoot data is structured like the excerpt below, with top-level dataSources
	-- that each contain data tables of items, spells, or enchants. We're going to transform
	-- that into <dataSourceName>.<dataId> for PeriodicTable use.
	-- {
	--  -- dataSourceName:
	-- 	AtlasLootWorldEvents = {
	--      -- dataId:
	-- 		AbyssalTemplars = {
	--			-- itemInfo:
	-- 			{ 20657, "INV_Weapon_ShortBlade_27", "=q3=Crystal Tipped Stiletto", "=ds=#h1#, #w4#", "2.31%" },
	-- 			{ 20655, "INV_Gauntlets_32", "=q2=Abyssal Cloth Handwraps", "=ds=#s9#, #a1#, =q2=#e31#", "13.03%" },
	-- 		}
	-- 	},
	-- 	AtlasLootCrafting = {
	-- 		CraftedWeapons1 = {
	-- 			{ 19166, "INV_Weapon_ShortBlade_12", "=q4=Black Amnesty", "=ds=#h1#, #w4#" },
	-- 			{ 19170, "INV_Hammer_19", "=q4=Ebon Hand", "=ds=#h1#, #w6#" },
	-- 		},
	-- 		EnchantingArtisan1 = {
	-- 			{ "e13917", "Spell_Holy_GreaterHeal", "=ds=Enchant Chest - Superior Mana", "=ds=#sr# =so1=230 =so2=250 =so3=270 =so4=290" },
	-- 			{ "e13905", "Spell_Holy_GreaterHeal", "=ds=Enchant Shield - Greater Spirit", "=ds=#sr# =so1=230 =so2=250 =so3=270 =so4=290" },
	-- 		},
	-- 		Weaponsmith1 = {
	-- 			{ "s10003", "inv_hammer_18", "=q3=The Shatterer", "=ds=#sr# =so1=235 =so2=260 =so3=272 =so4=285" },
	-- 			{ "s10007", "inv_sword_40", "=q3=Phantom Blade", "=ds=#sr# =so1=245 =so2=270 =so3=282 =so4=295" },
	-- 		},
	-- 	},
	-- }
	--
	-- GetSpellInfoVanillaDB looks a bit like this:
	-- {
	-- 	enchants = {
	-- 		[15596] = {
	-- 			["name"] = "Smoking Heart of the Mountain",
	-- 			["icon"] = "Interface\\Icons\\INV_Misc_Gem_Bloodstone_01",
	-- 			["item"] = 11811,
	-- 		},
	-- 	},
	-- 	craftspells = {
	-- 		[6510] = {
	-- 			["name"] = "Poisons: Blinding Powder",
	-- 			["requires"] = "",
	-- 			["tools"] = "",
	-- 			["castTime"] = 3,
	-- 			["text"] = "Create the reagent for the Blind ability.",
	-- 			["craftItem"] = 5530,
	-- 			["craftQuantityMin"] = 3,
	-- 			["craftQuantityMax"] = "",
	-- 			["reagents"] = {
	-- 				[1] = {3818},
	-- 			},
	-- 		},
	-- 	},
	-- }
	for dataSourceName, dataTable in pairs(_G.AtlasLoot_Data) do

		-- AtlasLootFallback is an empty table.
		if dataSourceName ~= "AtlasLootFallback" then

			-- Parent PeriodicTable category.
			ptCustomItems[dataSourceName] = {}

			for dataId, data in pairs(dataTable) do

				-- PeriodicTable category that will hold the items.
				ptCategory = dataSourceName .. "." .. dataId
				ptCustomItems[dataSourceName][ptCategory] = {}

				for _, itemInfo in ipairs(data) do

					if type(itemInfo[1]) == "number" and itemInfo[1] > 0 then
						-- Normal items.
						table.insert(ptCustomItems[dataSourceName][ptCategory], itemInfo[1])

					elseif type(itemInfo[1]) == "string" then
						-- Spells/Enchants.
						local spellId = BsUtil.ExtractNumber(itemInfo[1])
						local dbKey, itemType = spellInfoLookupKeys(itemInfo[1])

						-- Look up the spell/enchant to find the item it creates.
						if spellId and dbKey and itemType then
							local itemId =
								_G.GetSpellInfoVanillaDB[dbKey]
								and _G.GetSpellInfoVanillaDB[dbKey][spellId]
								and _G.GetSpellInfoVanillaDB[dbKey][spellId][itemType]
							if itemId then
								table.insert(ptCustomItems[dataSourceName][ptCategory], itemId)
							end
						end
					end
				end
			end
		end
	end
end



-- Mapping of PeriodicTable category names to more readable ones:
-- ```
-- {
-- 	["Our.Category"] = { "list", "of", "pt", "categories", },
-- }
-- ```
---@type table<string, string[]>
local ptCustomCategoryNames = {

	-- Special cases
	["Tokens.Reputation"] = { "reputationtokens", },

	-- Consumables
	["Consumable.Bandage"] = { "bandages", },
	["Consumable.Bandage.Basic"] = { "bandagesgeneral", },
	["Consumable.Bandage.Alterac"] = { "bandagesalterac", },
	["Consumable.Bandage.Arathi"] = { "bandagesarathi", },
	["Consumable.Bandage.Warsong"] = { "bandageswarsong", },

	["Consumable.Buff.UngoroCrystal"] = { "ungorocrystalsbuff", },

	["Consumable.Food.Special"] = { "foodspecial", },
	["Consumable.Food.Combo.Health"] = { "foodcombohealth", },
	["Consumable.Food.Combo.Mana"] = { "foodcombomana", },
	["Consumable.Food.Combo.Perc"] = { "foodcomboperc", },
	["Consumable.Food.Perc"] = { "foodperc", },
	["Consumable.Food.Perc.Bonus"] = { "foodpercbonus", },

	["Consumable.Food"] = { "foodall", },
	["Consumable.Food.Edible"] = { "foodalledible", },

	["Consumable.Food.Inedible"] = { "foodraw", },
	["Consumable.Food.Inedible.Fish"] = { "foodfishraw", },
	["Consumable.Food.Inedible.Meat"] = { "foodmeatraw", },

	["Consumable.Food.Edible.Basic"] = { "food", },
	["Consumable.Food.Edible.Bread"] = { "foodbread", },
	["Consumable.Food.Edible.Conjured"] = { "foodbreadconjured", },
	["Consumable.Food.Edible.Cheese"] = { "foodcheese", },
	["Consumable.Food.Edible.Fish"] = { "foodfish", },
	["Consumable.Food.Edible.Fruit"] = { "foodfruit", },
	["Consumable.Food.Edible.Fungus"] = { "foodfungus", },
	["Consumable.Food.Edible.Meat"] = { "foodmeat", },
	["Consumable.Food.Edible.Misc"] = { "foodmisc", },
	["Consumable.Food.Edible.Arathi"] = { "foodarathi", },

	["Consumable.Food.Edible.Bonus"] = { "foodbonus", },
	["Consumable.Food.Edible.Bread.Bonus"] = { "foodbreadbonus", },
	["Consumable.Food.Edible.Fish.Bonus"] = { "foodfishbonus", },
	["Consumable.Food.Edible.Meat.Bonus"] = { "foodmeatbonus", },
	["Consumable.Food.Edible.Cheese.Bonus"] = { "foodcheesebonus", },
	["Consumable.Food.Edible.Misc.Bonus"] = { "foodmiscbonus", },

	["Consumable.Food.Edible.Stats"] = { "foodstat", },
	["Consumable.Food.Edible.Fish.Stats"] = { "foodfishstats", },
	["Consumable.Food.Edible.Fruit.Stats"] = { "foodfruitstats", },
	["Consumable.Food.Edible.Meat.Stats"] = { "foodmeatstats", },
	["Consumable.Food.Edible.Misc.Stats"] = { "foodmiscstats", },

	["Consumable.Food.Type"] = { "foodclass", },
	["Consumable.Food.Type.Bread"] = { "foodclassbread", },
	["Consumable.Food.Type.Fish"] = { "foodclassfish", },
	["Consumable.Food.Type.Meat"] = { "foodclassmeat", },
	["Consumable.Food.Type.Cheese"] = { "foodclasscheese", },
	["Consumable.Food.Type.Fruit"] = { "foodclassfruit", },
	["Consumable.Food.Type.Fungus"] = { "foodclassfungus", },
	["Consumable.Food.Type.Misc"] = { "foodclassmisc", },

	["Consumable.Potion"] = { "potionall", },

	["Consumable.Potion.Buff"] = { "potionbuff", },
	["Consumable.Potion.Buff.Health"] = { "potionbuffhealth", },
	["Consumable.Potion.Buff.Mana"] = { "potionbuffmana", },
	["Consumable.Potion.Buff.Armor"] = { "potionbuffarmor", },
	["Consumable.Potion.Buff.Strength"] = { "potionbuffstr", },
	["Consumable.Potion.Buff.Stamina"] = { "potionbuffsta", },
	["Consumable.Potion.Buff.Agility"] = { "potionbuffagi", },
	["Consumable.Potion.Buff.Intellect"] = { "potionbuffint", },
	["Consumable.Potion.Buff.Spirit"] = { "potionbuffspr", },
	["Consumable.Potion.Buff.Regen"] = { "potionbuffregen", },
	["Consumable.Potion.Buff.Attack"] = { "potionbuffattack", },
	["Consumable.Potion.Buff.Spell"] = { "potionbuffspell", },
	["Consumable.Potion.Buff.Resistence"] = { "potionbuffresist", },
	["Consumable.Potion.Buff.Elemtal"] = { "potionbuffelemtal", },
	["Consumable.Potion.Buff.Other"] = { "potionbuffother", },

	["Consumable.Potion.Recovery"] = { "potionhealall", "potionmanaall", },
	["Consumable.Potion.Recovery.Health"] = { "potionhealall", },
	["Consumable.Potion.Recovery.Health.Basic"] = { "potionheal", },
	["Consumable.Potion.Recovery.Health.Alterac"] = { "potionhealalterac", },
	["Consumable.Potion.Rejuvenation"] = { "potionrejuv", },
	["Consumable.Potion.Mana"] = { "potionmanaall", },
	["Consumable.Potion.Mana.Basic"] = { "potionmana", },
	["Consumable.Potion.Mana.Alterac"] = { "potionmanaalterac", },
	["Consumable.Potion.Other.Rage"] = { "potionrage", },
	["Consumable.Potion.Other.Cure"] = { "potioncure", },

	["Consumable.Potion.Flasks"] = { "potionflasks", },

	["Consumable.Scroll"] = { "scrolls", },
	["Consumable.Scroll.Agility"] = { "scrollagi", },
	["Consumable.Scroll.Intellect"] = { "scrollint", },
	["Consumable.Scroll.Protection"] = { "scrollprot", },
	["Consumable.Scroll.Spirit"] = { "scrollspi", },
	["Consumable.Scroll.Stamina"] = { "scrollsta", },
	["Consumable.Scroll.Strength"] = { "scrollstr", },

	["Consumable.Mage.ManaStone"] = { "manastone", },

	["Consumable.Warlock.Healthstone"] = { "healthstone", },

	["Consumable.Water"] = { "waterall", },
	["Consumable.Water.Basic"] = { "water", },
	["Consumable.Water.Perc"] = { "waterperc", },
	["Consumable.Water.Conjured"] = { "waterconjured", },
	["Consumable.Water.Arathi"] = { "waterarathi", },
	["Consumable.Water.Spirit"] = { "waterspirit", },

	["Consumable.WeaponBuff"] = { "weapontempenchants", },

	["Consumable.WeaponBuff.SharpeningStone"] = { "sharpeningstones", },
	["Consumable.WeaponBuff.WeightStone"] = { "weightstones", },

	["Consumable.WeaponBuff.Oil.Mana"] = { "oilmana", },
	["Consumable.WeaponBuff.Oil.Wizard"] = { "oilwizard", },

	["Consumable.WeaponBuff.Poison"] = { "poisons", },
	["Consumable.WeaponBuff.Poison.Crippling"] = { "poisoncrippling", },
	["Consumable.WeaponBuff.Poison.Deadly"] = { "poisondeadly", },
	["Consumable.WeaponBuff.Poison.Instant"] = { "poisoninstant", },
	["Consumable.WeaponBuff.Poison.Mindnumbing"] = { "poisonmindnumbing", },
	["Consumable.WeaponBuff.Poison.Wound"] = { "poisonwound", },



	-- Gear (Equip) Sets

	["GearSet.BlackrockSpire.DalrendsArms"] = { "dalrendsarms", },
	["GearSet.BlackrockSpire.SpidersKiss"] = { "spiderskiss", },
	["GearSet.BlackrockSpire.IronWeaveBattleSuit"] = { "ironweavebattlesuit", },

	["GearSet.Stratholme.ThePostmaster"] = { "thepostmaster", },

	["GearSet.Scholomance.DeathBoneGuardian"] = { "deathboneguardian", },
	["GearSet.Scholomance.CadaverousGarb"] = { "cadaverousgarb", },
	["GearSet.Scholomance.NecropileRaiment"] = { "necropileraiment", },
	["GearSet.Scholomance.BloodmailRegalia"] = { "bloodmailregalia", },

	["GearSet.BlackrockDepths.TheGladiator"] = { "thegladiator", },

	["GearSet.ScarletMonastery.ChainOfTheScarletCrusade"] = { "chainofthescarletcrusade", },

	["GearSet.WailingCaverns.EmbraceOfTheViper"] = { "embraceoftheviper", },

	["GearSet.TheDeadmines.DefiasLeather"] = { "defiasleather", },

	["GearSet.Dungeon1"] = { "dungeon1", },
	["GearSet.Dungeon1.BattlegearOfValor"] = { "battlegearofvalor", },
	["GearSet.Dungeon1.BeaststalkerArmor"] = { "beaststalkerarmor", },
	["GearSet.Dungeon1.DreadmistRaiment"] = { "dreadmistraiment", },
	["GearSet.Dungeon1.LightforgeArmor"] = { "lightforgearmor", },
	["GearSet.Dungeon1.MagistersRegalia"] = { "magistersregalia", },
	["GearSet.Dungeon1.ShadowcraftArmor"] = { "shadowcraftarmor", },
	["GearSet.Dungeon1.TheElements"] = { "theelements", },
	["GearSet.Dungeon1.VestmentsOfTheDevout"] = { "vestmentsofthedevout", },
	["GearSet.Dungeon1.WildheartRaiment"] = { "wildheartraiment", },

	["GearSet.Dungeon2"] = { "dungeon2", },
	["GearSet.Dungeon2.BattlegearOfHeroism"] = { "battlegearofheroism", },
	["GearSet.Dungeon2.BeastmasterArmor"] = { "beastmasterarmor", },
	["GearSet.Dungeon2.DarkmantleArmor"] = { "darkmantlearmor", },
	["GearSet.Dungeon2.DeathmistRaiment"] = { "deathmistraiment", },
	["GearSet.Dungeon2.FeralheartRaiment"] = { "feralheartraiment", },
	["GearSet.Dungeon2.SorcerersRegalia"] = { "sorcerersregalia", },
	["GearSet.Dungeon2.SoulforgeArmor"] = { "soulforgearmor", },
	["GearSet.Dungeon2.TheFiveThunders"] = { "thefivethunders", },
	["GearSet.Dungeon2.VestmentsOfTheVirtuous"] = { "vestmentsofthevirtuous", },

	["GearSet.ZulGurub"] = { "zandalartribesets", },
	["GearSet.ZulGurub.AugursRegalia"] = { "augursregalia", },
	["GearSet.ZulGurub.ConfessorsRaiment"] = { "confessorsraiment", },
	["GearSet.ZulGurub.DemoniacsThreads"] = { "demoniacsthreads", },
	["GearSet.ZulGurub.FreethinkersArmor"] = { "freethinkersarmor", },
	["GearSet.ZulGurub.HaruspexsGarb"] = { "haruspexsgarb", },
	["GearSet.ZulGurub.IllusionistsAttire"] = { "illusionistsattire", },
	["GearSet.ZulGurub.MadcapsOutfit"] = { "madcapsoutfit", },
	["GearSet.ZulGurub.MajorMojoInfusion"] = { "majormojoinfusion", },
	["GearSet.ZulGurub.OverlordsResolution"] = { "overlordsresolution", },
	["GearSet.ZulGurub.PrayerOfThePrimal"] = { "prayeroftheprimal", },
	["GearSet.ZulGurub.PredatorsArmor"] = { "predatorsarmor", },
	["GearSet.ZulGurub.PrimalBlessing"] = { "primalblessing", },
	["GearSet.ZulGurub.TheTwinBladesOfTheHakkari"] = { "thetwinbladesofhakkari", },
	["GearSet.ZulGurub.VindicatorsBattlegear"] = { "vindicatorsbattlegear", },
	["GearSet.ZulGurub.ZanzilsConcentration"] = { "zanzilsconcentration", },


	["GearSet.MoltenCore"] = { "tier1raid", },
	["GearSet.MoltenCore.ArcanistRegalia"] = { "arcanistregalia", },
	["GearSet.MoltenCore.BattlegearOfMight"] = { "battlegearofmight", },
	["GearSet.MoltenCore.CenarionRaiment"] = { "cenarionraiment", },
	["GearSet.MoltenCore.FelheartRaiment"] = { "felheartraiment", },
	["GearSet.MoltenCore.GiantstalkerArmor"] = { "giantstalkerarmor", },
	["GearSet.MoltenCore.LawbringerArmor"] = { "lawbringerarmor", },
	["GearSet.MoltenCore.NightslayerArmor"] = { "nightslayerarmor", },
	["GearSet.MoltenCore.TheEarthury"] = { "theearthfury", },
	["GearSet.MoltenCore.VestmentsOfProphecy"] = { "vestmentsofprophecy", },

	["GearSet.BlackwingLair"] = { "tier2raid", },
	["GearSet.BlackwingLair.BattlregearOfWrath"] = { "battlregearofwrath", },
	["GearSet.BlackwingLair.BloodfangArmor"] = { "bloodfangarmor", },
	["GearSet.BlackwingLair.DragonstalkerArmor"] = { "dragonstalkerarmor", },
	["GearSet.BlackwingLair.JudgementArmor"] = { "judgementarmor", },
	["GearSet.BlackwingLair.NemesisRaiment"] = { "nemesisraiment", },
	["GearSet.BlackwingLair.NetherwindRegalia"] = { "netherwindregalia", },
	["GearSet.BlackwingLair.StormrageRaiment"] = { "stormrageraiment", },
	["GearSet.BlackwingLair.TheTenStorms"] = { "thetenstorms", },
	["GearSet.BlackwingLair.VestmentsOfTrancendance"] = { "vestmentsoftrancendance", },

	["GearSet.Naxxramas"] = { "tier3raid", },
	["GearSet.Naxxramas.BonescytheArmor"] = { "bonescythearmor", },
	["GearSet.Naxxramas.CryptstalkerArmor"] = { "cryptstalkerarmor", },
	["GearSet.Naxxramas.DreadnaughtsBattlegear"] = { "dreadnaughtsbattlegear", },
	["GearSet.Naxxramas.DreamwalkerRaiment"] = { "dreamwalkerraiment", },
	["GearSet.Naxxramas.FrostfireRegalia"] = { "frostfireregalia", },
	["GearSet.Naxxramas.PlagueheartRaiment"] = { "plagueheartraiment", },
	["GearSet.Naxxramas.RedemptionArmor"] = { "redemptionarmor", },
	["GearSet.Naxxramas.Theearthshatterer"] = { "theearthshatterer", },
	["GearSet.Naxxramas.VestmentsOfFaith"] = { "vestmentsoffaith", },

	["GearSet.Crafted.BlackDragonMail"] = { "blackDragonMail", },
	["GearSet.Crafted.BloodsoulEmbrace"] = { "bloodsoulembrace", },
	["GearSet.Crafted.BloodTigerHarness"] = { "bloodtigerharness", },
	["GearSet.Crafted.BloodvineGarb"] = { "bloodvinegarb", },
	["GearSet.Crafted.BlueDragonMail"] = { "blueDragonMail", },
	["GearSet.Crafted.DevilsaurArmor"] = { "devilsaurarmor", },
	["GearSet.Crafted.GreenDragonMail"] = { "greenDragonMail", },
	["GearSet.Crafted.ImperialPlate"] = { "imperialplate", },
	["GearSet.Crafted.IronfeatherArmor"] = { "ironfeatherarmor", },
	["GearSet.Crafted.PrimalBatskin"] = { "primalbatskin", },
	["GearSet.Crafted.StormshroudArmor"] = { "stormshroudarmor", },
	["GearSet.Crafted.TheDarkSoul"] = { "thedarksoul", },
	["GearSet.Crafted.VolcanicArmor"] = { "volcanicarmor", },

	["GearSet.Misc.ShardOfTheGods"] = { "shardofthegods", },
	["GearSet.Misc.SpiritOfEskhandar"] = { "spiritofeskhandar", },
	["GearSet.Misc.Twilighttrappings"] = { "twilighttrappings", },



	-- Instance

	["InstanceLoot.ElementalBosses"] = { "elementalbosses", },
	["InstanceLoot.InstanceBosses"] = { "instancebosses", },
	["InstanceLoot.InstanceZones"] = { "instancezones", },
	["InstanceLoot.RaidZones"] = { "raidzones", },
	["InstanceLoot.RaidBosses"] = { "raidbosses", },
	["InstanceLoot.WorldBosses"] = { "elementalbosses", "worldbosses" },

	["InstanceLoot.BossDrops"] = { "bossdrops", },
	["InstanceLoot.WorldDrops"] = { "worlddrops", },
	["InstanceLoot.WorldDrops.NOT"] = { "NOTworlddrops", },


	["InstanceLoot.AhnQiraj.Bosses"] = { "ahnqiraj", },

	["InstanceLoot.AhnQiraj.BattleguardSartura"] = { "battleguardsartura", },
	["InstanceLoot.AhnQiraj.Cthun"] = { "cthun", },
	["InstanceLoot.AhnQiraj.EmperorVeklor"] = { "emperorveklor", },
	["InstanceLoot.AhnQiraj.EmperorVeknilash"] = { "emperorveknilash", },
	["InstanceLoot.AhnQiraj.FankrissTheUnyielding"] = { "fankrisstheunyielding", },
	["InstanceLoot.AhnQiraj.LordKri"] = { "lordkri", },
	["InstanceLoot.AhnQiraj.Ouro"] = { "ouro", },
	["InstanceLoot.AhnQiraj.PrincessHuhuran"] = { "princesshuhuran", },
	["InstanceLoot.AhnQiraj.PrincessYauj"] = { "princessyauj", },
	["InstanceLoot.AhnQiraj.TheProphetSkeram"] = { "theprophetskeram", },
	["InstanceLoot.AhnQiraj.Vem"] = { "vem", },
	["InstanceLoot.AhnQiraj.Viscidus"] = { "viscidus", },


	["InstanceLoot.BlackrockDepths"] = { "blackrockdepths", },
	["InstanceLoot.BlackrockDepths.Bosses"] = { "blackrockdepthsbosses", },
	["InstanceLoot.BlackrockDepths.Ambassadorflamelash"] = { "ambassadorflamelash", },
	["InstanceLoot.BlackrockDepths.Angerrel"] = { "angerrel", },
	["InstanceLoot.BlackrockDepths.Baelgar"] = { "baelgar", },
	["InstanceLoot.BlackrockDepths.Doomrel"] = { "doomrel", },
	["InstanceLoot.BlackrockDepths.Doperel"] = { "doperel", },
	["InstanceLoot.BlackrockDepths.EmperorDagranThaurissian"] = { "emperordagranthaurissian", },
	["InstanceLoot.BlackrockDepths.FineousDarkvire"] = { "fineousdarkvire", },
	["InstanceLoot.BlackrockDepths.GeneralAngerforge"] = { "generalangerforge", },
	["InstanceLoot.BlackrockDepths.Gloomrel"] = { "gloomrel", },
	["InstanceLoot.BlackrockDepths.GolemLordArgelmach"] = { "golemlordargelmach", },
	["InstanceLoot.BlackrockDepths.Haterel"] = { "haterel", },
	["InstanceLoot.BlackrockDepths.HighInterrogatorGerstahn"] = { "highinterrogatorgerstahn", },
	["InstanceLoot.BlackrockDepths.HurleyBlackbreath"] = { "hurleyblackbreath", },
	["InstanceLoot.BlackrockDepths.LordIncendius"] = { "lordincendius", },
	["InstanceLoot.BlackrockDepths.Magmus"] = { "magmus", },
	["InstanceLoot.BlackrockDepths.Phalanx"] = { "phalanx", },
	["InstanceLoot.BlackrockDepths.PluggersSazzring"] = { "pluggerspazzring", },
	["InstanceLoot.BlackrockDepths.PrincessMoiraBronzebeard"] = { "princessmoirabronzebeard", },
	["InstanceLoot.BlackrockDepths.RibblyScrewspigot"] = { "ribblyscrewspigot", },
	["InstanceLoot.BlackrockDepths.Seethrel"] = { "seethrel", },
	["InstanceLoot.BlackrockDepths.Vilerel"] = { "vilerel", },


	-- "blackrockspire" is missing from PTEmbedElemInstance.lua
	["InstanceLoot.BlackrockSpire"] = { "blackrockspiretrash", "upperblackrockspire", "lowerblackrockspire" },

	["InstanceLoot.BlackrockSpire.Trash"] = { "blackrockspiretrash", },

	["InstanceLoot.BlackrockSpire.Upper"] = { "upperblackrockspire", },
	["InstanceLoot.BlackrockSpire.GeneralDrakkisath"] = { "generaldrakkisath", },
	["InstanceLoot.BlackrockSpire.RendBlackhand"] = { "rendblackhand", },
	["InstanceLoot.BlackrockSpire.Gyth"] = { "gyth", },
	["InstanceLoot.BlackrockSpire.GoralukAnvilcrack"] = { "goralukanvilcrack", },
	["InstanceLoot.BlackrockSpire.PyroguardEmberseer"] = { "pyroguardemberseer", },
	["InstanceLoot.BlackrockSpire.JedRunewatcher"] = { "jedrunewatcher", },
	["InstanceLoot.BlackrockSpire.SolakarFlamewreath"] = { "solakarflamewreath", },

	["InstanceLoot.BlackrockSpire.Lower"] = { "lowerblackrockspire", },
	["InstanceLoot.BlackrockSpire.Halycon"] = { "halycon", },
	["InstanceLoot.BlackrockSpire.Crystalfang"] = { "crystalfang", },
	["InstanceLoot.BlackrockSpire.TheBeast"] = { "thebeast", },
	["InstanceLoot.BlackrockSpire.MotherSmolderweb"] = { "mothersmolderweb", },
	["InstanceLoot.BlackrockSpire.OverlordWyrmthalak"] = { "overlordwyrmthalak", },
	["InstanceLoot.BlackrockSpire.HighlordOmokk"] = { "highlordomokk", },
	["InstanceLoot.BlackrockSpire.WarmasterVoone"] = { "warmastervoone", },
	["InstanceLoot.BlackrockSpire.ShadowHunterVoshgajin"] = { "shadowhuntervoshgajin", },
	["InstanceLoot.BlackrockSpire.GizrulTheSlavener"] = { "gizrultheslavener", },
	["InstanceLoot.BlackrockSpire.QuartermasterZigris"] = { "quartermasterzigris", },
	["InstanceLoot.BlackrockSpire.BurningFelguard"] = { "burningfelguard", },


	["InstanceLoot.BlackwingLair"] = { "blackwinglair", "blackwinglairbosses", },
	["InstanceLoot.BlackwingLair.Trash"] = { "blackwinglair", },
	["InstanceLoot.BlackwingLair.Bosses"] = { "blackwinglairbosses", },

	["InstanceLoot.BlackwingLair.BroodlordLashlayer"] = { "broodlordlashlayer", },
	["InstanceLoot.BlackwingLair.Chromaggus"] = { "chromaggus", },
	["InstanceLoot.BlackwingLair.Ebonroc"] = { "ebonroc", },
	["InstanceLoot.BlackwingLair.Firemaw"] = { "firemaw", },
	["InstanceLoot.BlackwingLair.Flamegor"] = { "flamegor", },
	["InstanceLoot.BlackwingLair.Nefarian"] = { "nefarian", },
	["InstanceLoot.BlackwingLair.RazorgoreTheUntamed"] = { "razorgoretheuntamed", },
	["InstanceLoot.BlackwingLair.VaelastraszTheCorrupt"] = { "vaelastraszthecorrupt", },


	["InstanceLoot.DireMaul"] = { "diremaul", },

	["InstanceLoot.DireMaul.North"] = { "diremaulnorth", },
	["InstanceLoot.DireMaul.KnotThimblejacksCache"] = { "knotthimblejackscache", },
	["InstanceLoot.DireMaul.KingGordok"] = { "kinggordok", },
	["InstanceLoot.DireMaul.ChorushTheObserver"] = { "chorushtheobserver", },
	["InstanceLoot.DireMaul.CaptainKromcrush"] = { "captainkromcrush", },
	["InstanceLoot.DireMaul.GuardFengus"] = { "guardfengus", },
	["InstanceLoot.DireMaul.GuardMoldar"] = { "guardmoldar", },
	["InstanceLoot.DireMaul.GuardSlipkik"] = { "guardslipkik", },
	["InstanceLoot.DireMaul.StomperKreeg"] = { "stomperkreeg", },

	["InstanceLoot.DireMaul.West"] = { "diremaulwest", },
	["InstanceLoot.DireMaul.West.Trash"] = { "diremaulwesttrash", },
	["InstanceLoot.DireMaul.LordHelnurath"] = { "lordhelnurath", },
	["InstanceLoot.DireMaul.IllyannaRavenoak"] = { "illyannaravenoak", },
	["InstanceLoot.DireMaul.Immolthar"] = { "immolthar", },
	["InstanceLoot.DireMaul.MagisterKalendris"] = { "magisterkalendris", },
	["InstanceLoot.DireMaul.TendrisWarpwood"] = { "tendriswarpwood", },
	["InstanceLoot.DireMaul.PrincetOrtheldrin"] = { "princetortheldrin", },
	["InstanceLoot.DireMaul.Tsuzee"] = { "tsuzee", },

	["InstanceLoot.DireMaul.East"] = { "diremauleast", },
	["InstanceLoot.DireMaul.East.Trash"] = { "diremauleasttrash", },
	["InstanceLoot.DireMaul.Pimgib"] = { "pimgib", },
	["InstanceLoot.DireMaul.AlzzinTheWildshaper"] = { "alzzinthewildshaper", },
	["InstanceLoot.DireMaul.ZevrimThornhoof"] = { "zevrimthornhoof", },
	["InstanceLoot.DireMaul.Hydrospawn"] = { "hydrospawn", },
	["InstanceLoot.DireMaul.Lethtendris"] = { "lethtendris", },
	["InstanceLoot.DireMaul.Pusillin"] = { "pusillin", },


	["InstanceLoot.Maraudon"] = { "maraudon", },
	["InstanceLoot.Maraudon.Bosses"] = { "maraudonbosses", },
	["InstanceLoot.Maraudon.Celebrasthecursed"] = { "celebrasthecursed", },
	["InstanceLoot.Maraudon.Landslide"] = { "landslide", },
	["InstanceLoot.Maraudon.LordVyletongue"] = { "lordvyletongue", },
	["InstanceLoot.Maraudon.MeshlokTheHarvester"] = { "meshloktheharvester", },
	["InstanceLoot.Maraudon.Noxxion"] = { "noxxion", },
	["InstanceLoot.Maraudon.PrincessTheradras"] = { "princesstheradras", },
	["InstanceLoot.Maraudon.Razorlash"] = { "razorlash", },
	["InstanceLoot.Maraudon.Rotgrip"] = { "rotgrip", },
	["InstanceLoot.Maraudon.TinkererGizlock"] = { "tinkerergizlock", },


	["InstanceLoot.MoltenCore"] = { "moltencore", "moltencorebosses", },
	["InstanceLoot.MoltenCore.Trash"] = { "moltencore", },
	["InstanceLoot.MoltenCore.Bosses"] = { "moltencorebosses", },

	["InstanceLoot.MoltenCore.Barongeddon"] = { "barongeddon", },
	["InstanceLoot.MoltenCore.Garr"] = { "garr", },
	["InstanceLoot.MoltenCore.Gehennas"] = { "gehennas", },
	["InstanceLoot.MoltenCore.GolemaggTheIncinerator"] = { "golemaggtheincinerator", },
	["InstanceLoot.MoltenCore.Lucifron"] = { "lucifron", },
	["InstanceLoot.MoltenCore.Magmadar"] = { "magmadar", },
	["InstanceLoot.MoltenCore.MajordomoExecutus"] = { "majordomoexecutus", },
	["InstanceLoot.MoltenCore.Ragnaros"] = { "ragnaros", },
	["InstanceLoot.MoltenCore.Shazzrah"] = { "shazzrah", },
	["InstanceLoot.MoltenCore.SulfuronHarbinger"] = { "sulfuronharbinger", },


	["InstanceLoot.Naxxramas.Bosses"] = { "naxxall", },

	["InstanceLoot.Naxxramas.Abomination"] = { "naxxramasabomination", },
	["InstanceLoot.Naxxramas.DeathKnight"] = { "naxxramasdeathknight", },
	["InstanceLoot.Naxxramas.Spider"] = { "naxxramasspider", },
	["InstanceLoot.Naxxramas.FrostWyrm"] = { "naxxramasfrostwyrm", },
	["InstanceLoot.Naxxramas.Plague"] = { "naxxramasplague", },

	["InstanceLoot.Naxxramas.AnubRekhan"] = { "anubrekhan", },
	["InstanceLoot.Naxxramas.Gluth"] = { "gluth", },
	["InstanceLoot.Naxxramas.GothikTheHarvester"] = { "gothiktheharvester", },
	["InstanceLoot.Naxxramas.GrandWidowFaerlina"] = { "grandwidowfaerlina", },
	["InstanceLoot.Naxxramas.Grobbulus"] = { "grobbulus", },
	["InstanceLoot.Naxxramas.HeiganTheUnclean"] = { "heigantheunclean", },
	["InstanceLoot.Naxxramas.InstructorRazuvious"] = { "instructorrazuvious", },
	["InstanceLoot.Naxxramas.KelThuzad"] = { "kelthuzad", },
	["InstanceLoot.Naxxramas.Loatheb"] = { "loatheb", },
	["InstanceLoot.Naxxramas.Maexxna"] = { "maexxna", },
	["InstanceLoot.Naxxramas.NothThePlaguebringer"] = { "noththeplaguebringer", },
	["InstanceLoot.Naxxramas.Patchwerk"] = { "patchwerk", },
	["InstanceLoot.Naxxramas.Sapphiron"] = { "sapphiron", },
	["InstanceLoot.Naxxramas.Thaddius"] = { "thaddius", },


	["InstanceLoot.OnyxiasLair"] = { "onyxiaslair", "onyxia", },
	["InstanceLoot.OnyxiasLair.Trash"] = { "onyxiaslair", },
	["InstanceLoot.OnyxiasLair.Onyxia"] = { "onyxia", },


	["InstanceLoot.RuinsOfAhnQiraj.Bosses"] = { "ruinsofahnqiraj", },

	["InstanceLoot.RuinsOfAhnQiraj.AyamissTheHunter"] = { "ayamissthehunter", },
	["InstanceLoot.RuinsOfAhnQiraj.BuruTheGorger"] = { "buruthegorger", },
	["InstanceLoot.RuinsOfAhnQiraj.GeneralRajaxx"] = { "generalrajaxx", },
	["InstanceLoot.RuinsOfAhnQiraj.Kurinnaxx"] = { "kurinnaxx", },
	["InstanceLoot.RuinsOfAhnQiraj.Moam"] = { "moam", },
	["InstanceLoot.RuinsOfAhnQiraj.OssirianTheUnscarred"] = { "ossiriantheunscarred", },


	["InstanceLoot.Scholomance"] = { "scholomance", },
	["InstanceLoot.Scholomance.Bosses"] = { "scholomancebosses", },
	["InstanceLoot.Scholomance.Darkmastergandling"] = { "darkmastergandling", },
	["InstanceLoot.Scholomance.Doctortheolenkrastinov"] = { "doctortheolenkrastinov", },
	["InstanceLoot.Scholomance.InstructorMalicia"] = { "instructormalicia", },
	["InstanceLoot.Scholomance.JandiceBarov"] = { "jandicebarov", },
	["InstanceLoot.Scholomance.KirtonosTheHerald"] = { "kirtonostheherald", },
	["InstanceLoot.Scholomance.LadyIlluciaBarov"] = { "ladyilluciabarov", },
	["InstanceLoot.Scholomance.LordAlexeiBarov"] = { "lordalexeibarov", },
	["InstanceLoot.Scholomance.LorekeeperPolkelt"] = { "lorekeeperpolkelt", },
	["InstanceLoot.Scholomance.MardukBlackpool"] = { "mardukblackpool", },
	["InstanceLoot.Scholomance.RasFrostwhisper"] = { "rasfrostwhisper", },
	["InstanceLoot.Scholomance.Rattlegore"] = { "rattlegore", },
	["InstanceLoot.Scholomance.TheRavenian"] = { "theravenian", },
	["InstanceLoot.Scholomance.Vectus"] = { "vectus", },


	["InstanceLoot.ShadowfangKeep"] = { "shadowfangkeep", },
	["InstanceLoot.ShadowfangKeep.Trash"] = { "shadowfangkeeptrash", },
	["InstanceLoot.ShadowfangKeep.ArchmageaRugal"] = { "archmagearugal", },
	["InstanceLoot.ShadowfangKeep.RazorclawTheButcher"] = { "razorclawthebutcher", },
	["InstanceLoot.ShadowfangKeep.CommanderSpringvale"] = { "commanderspringvale", },
	["InstanceLoot.ShadowfangKeep.WolfmasterNandos"] = { "wolfmasternandos", },
	["InstanceLoot.ShadowfangKeep.OdoTheBlindwatcher"] = { "odotheblindwatcher", },
	["InstanceLoot.ShadowfangKeep.DeathswornCaptain"] = { "deathsworncaptain", },
	["InstanceLoot.ShadowfangKeep.BaronSilverlaine"] = { "baronsilverlaine", },
	["InstanceLoot.ShadowfangKeep.FenrusTheDevourer"] = { "fenrusthedevourer", },
	["InstanceLoot.ShadowfangKeep.ArugalsVoidwalker"] = { "arugalsvoidwalker", },


	["InstanceLoot.Silithis.Bosses"] = { "silithislords", },

	["InstanceLoot.Silithis.BaronKazum"] = { "baronkazum", },
	["InstanceLoot.Silithis.HighmarshalWhirlaxis"] = { "highmarshalwhirlaxis", },
	["InstanceLoot.Silithis.LordSkwol"] = { "lordskwol", },
	["InstanceLoot.Silithis.PrincesKaldrenox"] = { "princeskaldrenox", },


	["InstanceLoot.Stratholme"] = { "stratholme", },
	["InstanceLoot.Stratholme.Bosses"] = { "stratholmebosses", },
	["InstanceLoot.Stratholme.Archivistgalford"] = { "archivistgalford", },
	["InstanceLoot.Stratholme.Balnazzar"] = { "balnazzar", },
	["InstanceLoot.Stratholme.Baronessanastari"] = { "baronessanastari", },
	["InstanceLoot.Stratholme.Baronrivendare"] = { "baronrivendare", },
	["InstanceLoot.Stratholme.CannonMasterWilley"] = { "cannonmasterwilley", },
	["InstanceLoot.Stratholme.HearthsingerForresten"] = { "hearthsingerforresten", },
	["InstanceLoot.Stratholme.MagistrateBarthilas"] = { "magistratebarthilas", },
	["InstanceLoot.Stratholme.MalekiThePallid"] = { "malekithepallid", },
	["InstanceLoot.Stratholme.Nerubenkan"] = { "nerubenkan", },
	["InstanceLoot.Stratholme.PostmasterMalown"] = { "postmastermalown", },
	["InstanceLoot.Stratholme.RamsteinTheGorger"] = { "ramsteinthegorger", },
	["InstanceLoot.Stratholme.TimmyTheCruel"] = { "timmythecruel", },


	["InstanceLoot.TempleOfAtalhHkkar"] = { "templeofatalhakkar", },
	["InstanceLoot.TempleOfAtalHakkar.Bosses"] = { "templeofatalhakkarbosses", },
	["InstanceLoot.TempleOfAtalHakkar.Atalalarion"] = { "atalalarion", },
	["InstanceLoot.TempleOfAtalHakkar.Avatarofhakkar"] = { "avatarofhakkar", },
	["InstanceLoot.TempleOfAtalHakkar.Dreamscythe"] = { "dreamscythe", },
	["InstanceLoot.TempleOfAtalHakkar.Gasher"] = { "gasher", },
	["InstanceLoot.TempleOfAtalHakkar.Hazzas"] = { "hazzas", },
	["InstanceLoot.TempleOfAtalHakkar.Hukku"] = { "hukku", },
	["InstanceLoot.TempleOfAtalHakkar.JammalanTheProphet"] = { "jammalantheprophet", },
	["InstanceLoot.TempleOfAtalHakkar.Loro"] = { "loro", },
	["InstanceLoot.TempleOfAtalHakkar.Mijan"] = { "mijan", },
	["InstanceLoot.TempleOfAtalHakkar.Morphaz"] = { "morphaz", },
	["InstanceLoot.TempleOfAtalHakkar.OgomTheWretched"] = { "ogomthewretched", },
	["InstanceLoot.TempleOfAtalHakkar.ShadeOfEranikus"] = { "shadeoferanikus", },
	["InstanceLoot.TempleOfAtalHakkar.Weaver"] = { "weaver", },
	["InstanceLoot.TempleOfAtalHakkar.Zolo"] = { "zolo", },
	["InstanceLoot.TempleOfAtalHakkar.ZulLor"] = { "zullor", },


	["InstanceLoot.WorldBosses.Outdoor"] = { "outdoorbosses", },
	["InstanceLoot.WorldBosses.TheFourDragons"] = { "thefourdragons", },

	["InstanceLoot.WorldBosses.Azuregos"] = { "azuregos", },
	["InstanceLoot.WorldBosses.DoomLordKazzak"] = { "lordkazzak", },
	["InstanceLoot.WorldBosses.Emeriss"] = { "emeriss", },
	["InstanceLoot.WorldBosses.Lethon"] = { "lethon", },
	["InstanceLoot.WorldBosses.Taerar"] = { "taerar", },
	["InstanceLoot.WorldBosses.Ysondre"] = { "ysondre", },
	["InstanceLoot.WorldBosses.Avalanchion"] = { "avalanchion", },
	["InstanceLoot.WorldBosses.TheWindreaver"] = { "thewindreaver", },
	["InstanceLoot.WorldBosses.BaronCharr"] = { "baroncharr", },
	["InstanceLoot.WorldBosses.PrincessTempestria"] = { "princesstempestria", },


	["InstanceLoot.ZulGurub"] = { "zulgurub", "zulgurubbosses", },
	["InstanceLoot.ZulGurub.Trash"] = { "zulgurub", },
	["InstanceLoot.ZulGurub.Bosses"] = { "zulgurubbosses", },

	["InstanceLoot.ZulGurub.BloodlordMandokir"] = { "bloodlordmandokir", },
	["InstanceLoot.ZulGurub.Gahzranka"] = { "gahzranka", },
	["InstanceLoot.ZulGurub.Grilek"] = { "grilek", },
	["InstanceLoot.ZulGurub.Hakkar"] = { "hakkar", },
	["InstanceLoot.ZulGurub.Hazzarah"] = { "hazzarah", },
	["InstanceLoot.ZulGurub.HighPriestessArlokk"] = { "highpriestessarlokk", },
	["InstanceLoot.ZulGurub.HighPriestessJeklik"] = { "highpriestessjeklik", },
	["InstanceLoot.ZulGurub.HighPriestessMarli"] = { "highpriestessmarli", },
	["InstanceLoot.ZulGurub.HighPriestThekal"] = { "highpriestthekal", },
	["InstanceLoot.ZulGurub.HighPriestVenoxis"] = { "highpriestvenoxis", },
	["InstanceLoot.ZulGurub.JindoTheHexxer"] = { "jindothehexxer", },
	["InstanceLoot.ZulGurub.Renataki"] = { "renataki", },
	["InstanceLoot.ZulGurub.Wushoolay"] = { "wushoolay", },




	-- Misc

	["Misc.Ammo"] = { "ammo", },
	["Misc.Ammo.Arrows"] = { "ammoarrows", },
	["Misc.Ammo.Bullets"] = { "ammobullets", },
	["Misc.Ammo.Thrown"] = { "ammothrown", },

	["Misc.Antivenom"] = { "antivenom", },

	["Misc.Booze"] = { "booze", },

	["Misc.Bag"] = { "bags", },
	["Misc.Bag.Basic"] = { "bagsnormal", },
	["Misc.Bag.Special"] = { "bagsspecial", },
	["Misc.Bag.Ammo"] = { "bagsammo", },
	["Misc.Bag.Quiver"] = { "bagsquiver", },
	["Misc.Bag.Soul"] = { "bagssoul", },
	["Misc.Bag.Herb"] = { "bagsherb", },
	["Misc.Bag.Enchanting"] = { "bagsench", },
	["Misc.Bag.Engineering"] = { "bagsengin", },

	["Misc.Engineering.Fireworks"] = { "fireworks", },

	["Misc.Explosives"] = { "explosives", },

	["Misc.HallowedWands"] = { "hallowedwands", },

	["Misc.Lockbox"] = { "lockboxes", },

	["Misc.Unlock.SkeletonKey"] = { "keyskeleton", },
	["Misc.Unlock.SeaforiumCharge"] = { "seaforium", },

	["Misc.Minipet"] = { "minipetall", },
	["Misc.Minipet.Other"] = { "minipet", },
	["Misc.Minipet.Holiday"] = { "minipetholiday", },
	["Misc.Mount.All"] = { "mountsall", },
	["Misc.Mount.Normal"] = { "mounts", },
	["Misc.Mount.AhnQiraj"] = { "mountsaq", },

	["Misc.Device"] = { "devices", },

	["Misc.Transporter.Item"] = { "transporteritems", },
	["Misc.Transporter.Equip"] = { "transporterequips", },


	-- Quest Items

	["Quest.AhnQiraj"] = { "ahnqirajquests", },
	["Quest.AhnQiraj.Scarab"] = { "ahnqirajscarab", },
	["Quest.AhnQiraj.Idol.20"] = { "ahnqirajidol20", },
	["Quest.AhnQiraj.Idol.40"] = { "ahnqirajidol40", },
	["Quest.AhnQiraj.Equipment.20"] = { "ahnqirajequipment20", },
	["Quest.AhnQiraj.Equipment.40"] = { "ahnqirajequipment40", },

	["Quest.AhnQiraj.Classes.CenarionCircle"] = { "ahnqirajclassescc", },
	["Quest.AhnQiraj.Classes.BroodOfNozdormu"] = { "ahnqirajclassesbon", },

	["Quest.AhnQiraj.Druid.CenarionCircle"] = { "ahnqirajdruidcc", },
	["Quest.AhnQiraj.Druid.Ring"] = { "ahnqirajdruidring", },
	["Quest.AhnQiraj.Druid.Back"] = { "ahnqirajdruidback", },
	["Quest.AhnQiraj.Druid.Weapon"] = { "ahnqirajdruidweapon", },

	["Quest.AhnQiraj.Druid.BroodOfNozdormu"] = { "ahnqirajdruidbon", },
	["Quest.AhnQiraj.Druid.Shoulder"] = { "ahnqirajdruidshoulder", },
	["Quest.AhnQiraj.Druid.Feet"] = { "ahnqirajdruidfeet", },
	["Quest.AhnQiraj.Druid.Head"] = { "ahnqirajdruidhead", },
	["Quest.AhnQiraj.Druid.Legs"] = { "ahnqirajdruidlegs", },
	["Quest.AhnQiraj.Druid.Chest"] = { "ahnqirajdruidchest", },

	["Quest.AhnQiraj.Hunter.CenarionCircle"] = { "ahnqirajhuntercc", },
	["Quest.AhnQiraj.Hunter.Ring"] = { "ahnqirajhunterring", },
	["Quest.AhnQiraj.Hunter.Back"] = { "ahnqirajhunterback", },
	["Quest.AhnQiraj.Hunter.Weapon"] = { "ahnqirajhunterweapon", },

	["Quest.AhnQiraj.Hunter.BroodOfNozdormu"] = { "ahnqirajhunterbon", },
	["Quest.AhnQiraj.Hunter.Shoulder"] = { "ahnqirajhuntershoulder", },
	["Quest.AhnQiraj.Hunter.Feet"] = { "ahnqirajhunterfeet", },
	["Quest.AhnQiraj.Hunter.Head"] = { "ahnqirajhunterhead", },
	["Quest.AhnQiraj.Hunter.Legs"] = { "ahnqirajhunterlegs", },
	["Quest.AhnQiraj.Hunter.Chest"] = { "ahnqirajhunterchest", },

	["Quest.AhnQiraj.Mage.CenarionCircle"] = { "ahnqirajmagecc", },
	["Quest.AhnQiraj.Mage.Ring"] = { "ahnqirajmagering", },
	["Quest.AhnQiraj.Mage.Back"] = { "ahnqirajmageback", },
	["Quest.AhnQiraj.Mage.Weapon"] = { "ahnqirajmageweapon", },

	["Quest.AhnQiraj.Mage.BroodOfNozdormu"] = { "ahnqirajmagebon", },
	["Quest.AhnQiraj.Mage.Shoulder"] = { "ahnqirajmageshoulder", },
	["Quest.AhnQiraj.Mage.Feet"] = { "ahnqirajmagefeet", },
	["Quest.AhnQiraj.Mage.Head"] = { "ahnqirajmagehead", },
	["Quest.AhnQiraj.Mage.Legs"] = { "ahnqirajmagelegs", },
	["Quest.AhnQiraj.Mage.Chest"] = { "ahnqirajmagechest", },

	["Quest.AhnQiraj.Paladin.CenarionCircle"] = { "ahnqirajpaladincc", },
	["Quest.AhnQiraj.Paladin.Ring"] = { "ahnqirajpaladinring", },
	["Quest.AhnQiraj.Paladin.Back"] = { "ahnqirajpaladinback", },
	["Quest.AhnQiraj.Paladin.Weapon"] = { "ahnqirajpaladinweapon", },

	["Quest.AhnQiraj.Paladin.BroodOfNozdormu"] = { "ahnqirajpaladinbon", },
	["Quest.AhnQiraj.Paladin.Shoulder"] = { "ahnqirajpaladinshoulder", },
	["Quest.AhnQiraj.Paladin.Feet"] = { "ahnqirajpaladinfeet", },
	["Quest.AhnQiraj.Paladin.Head"] = { "ahnqirajpaladinhead", },
	["Quest.AhnQiraj.Paladin.Legs"] = { "ahnqirajpaladinlegs", },
	["Quest.AhnQiraj.Paladin.Chest"] = { "ahnqirajpaladinchest", },

	["Quest.AhnQiraj.Priest.CenarionCircle"] = { "ahnqirajpriestcc", },
	["Quest.AhnQiraj.Priest.Ring"] = { "ahnqirajpriestring", },
	["Quest.AhnQiraj.Priest.Back"] = { "ahnqirajpriestback", },
	["Quest.AhnQiraj.Priest.Weapon"] = { "ahnqirajpriestweapon", },

	["Quest.AhnQiraj.Priest.BroodOfNozdormu"] = { "ahnqirajpriestbon", },
	["Quest.AhnQiraj.Priest.Shoulder"] = { "ahnqirajpriestshoulder", },
	["Quest.AhnQiraj.Priest.Feet"] = { "ahnqirajpriestfeet", },
	["Quest.AhnQiraj.Priest.Head"] = { "ahnqirajpriesthead", },
	["Quest.AhnQiraj.Priest.Legs"] = { "ahnqirajpriestlegs", },
	["Quest.AhnQiraj.Priest.Chest"] = { "ahnqirajpriestchest", },

	["Quest.AhnQiraj.Rogue.CenarionCircle"] = { "ahnqirajroguecc", },
	["Quest.AhnQiraj.Rogue.Ring"] = { "ahnqirajroguering", },
	["Quest.AhnQiraj.Rogue.Back"] = { "ahnqirajrogueback", },
	["Quest.AhnQiraj.Rogue.Weapon"] = { "ahnqirajrogueweapon", },

	["Quest.AhnQiraj.Rogue.BroodOfNozdormu"] = { "ahnqirajroguebon", },
	["Quest.AhnQiraj.Rogue.Shoulder"] = { "ahnqirajrogueshoulder", },
	["Quest.AhnQiraj.Rogue.Feet"] = { "ahnqirajroguefeet", },
	["Quest.AhnQiraj.Rogue.Head"] = { "ahnqirajroguehead", },
	["Quest.AhnQiraj.Rogue.Legs"] = { "ahnqirajroguelegs", },
	["Quest.AhnQiraj.Rogue.Chest"] = { "ahnqirajroguechest", },

	["Quest.AhnQiraj.Shaman.CenarionCircle"] = { "ahnqirajshamancc", },
	["Quest.AhnQiraj.Shaman.Ring"] = { "ahnqirajshamanring", },
	["Quest.AhnQiraj.Shaman.Back"] = { "ahnqirajshamanback", },
	["Quest.AhnQiraj.Shaman.Weapon"] = { "ahnqirajshamanweapon", },

	["Quest.AhnQiraj.Shaman.BroodOfNozdormu"] = { "ahnqirajshamanbon", },
	["Quest.AhnQiraj.Shaman.Shoulder"] = { "ahnqirajshamanshoulder", },
	["Quest.AhnQiraj.Shaman.Feet"] = { "ahnqirajshamanfeet", },
	["Quest.AhnQiraj.Shaman.Head"] = { "ahnqirajshamanhead", },
	["Quest.AhnQiraj.Shaman.Legs"] = { "ahnqirajshamanlegs", },
	["Quest.AhnQiraj.Shaman.Chest"] = { "ahnqirajshamanchest", },

	["Quest.AhnQiraj.Warlock.CenarionCircle"] = { "ahnqirajwarlockcc", },
	["Quest.AhnQiraj.Warlock.Ring"] = { "ahnqirajwarlockring", },
	["Quest.AhnQiraj.Warlock.Back"] = { "ahnqirajwarlockback", },
	["Quest.AhnQiraj.Warlock.Weapon"] = { "ahnqirajwarlockweapon", },

	["Quest.AhnQiraj.Warlock.BroodOfNozdormu"] = { "ahnqirajwarlockbon", },
	["Quest.AhnQiraj.Warlock.Shoulder"] = { "ahnqirajwarlockshoulder", },
	["Quest.AhnQiraj.Warlock.Feet"] = { "ahnqirajwarlockfeet", },
	["Quest.AhnQiraj.Warlock.Head"] = { "ahnqirajwarlockhead", },
	["Quest.AhnQiraj.Warlock.Legs"] = { "ahnqirajwarlocklegs", },
	["Quest.AhnQiraj.Warlock.Chest"] = { "ahnqirajwarlockchest", },

	["Quest.AhnQiraj.Warrior.CenarionCircle"] = { "ahnqirajwarriorcc", },
	["Quest.AhnQiraj.Warrior.Ring"] = { "ahnqirajwarriorring", },
	["Quest.AhnQiraj.Warrior.Back"] = { "ahnqirajwarriorback", },
	["Quest.AhnQiraj.Warrior.Weapon"] = { "ahnqirajwarriorweapon", },

	["Quest.AhnQiraj.Warrior.BroodOfNozdormu"] = { "ahnqirajwarriorbon", },
	["Quest.AhnQiraj.Warrior.Shoulder"] = { "ahnqirajwarriorshoulder", },
	["Quest.AhnQiraj.Warrior.Feet"] = { "ahnqirajwarriorfeet", },
	["Quest.AhnQiraj.Warrior.Head"] = { "ahnqirajwarriorhead", },
	["Quest.AhnQiraj.Warrior.Legs"] = { "ahnqirajwarriorlegs", },
	["Quest.AhnQiraj.Warrior.Chest"] = { "ahnqirajwarriorchest", },


	["Quest.Arcanum.Focus"] = { "arcanumoffocus", },
	["Quest.Arcanum.Protection"] = { "arcanumofprotection", },
	["Quest.Arcanum.Rapidity"] = { "arcanumofrapidity", },
	["Quest.Arcanum.Constitution"] = { "lesserarcanumofconstitution", },
	["Quest.Arcanum.Resilience"] = { "lesserarcanumofresilience", },
	["Quest.Arcanum.Rumination"] = { "lesserarcanumofrumination", },
	["Quest.Arcanum.Tenacity"] = { "lesserarcanumoftenacity", },
	["Quest.Arcanum.Voracity"] = { "lesserarcanumofvoracity", },

	["Quest.ArgentDawnCommission"] = { "argentdawncommission", },

	["Quest.DarkmoonFaire.Deck"] = { "deckcards", },
	["Quest.DarkmoonFaire.Deck.All"] = { "decks", },
	["Quest.DarkmoonFaire.Deck.Cards"] = { "cards", },
	["Quest.DarkmoonFaire.Deck.Beasts"] = { "deckbeasts", },
	["Quest.DarkmoonFaire.Deck.Warlords"] = { "deckwarlords", },
	["Quest.DarkmoonFaire.Deck.Portals"] = { "deckportals", },
	["Quest.DarkmoonFaire.Deck.Elementals"] = { "deckelementals", },

	["Quest.DarkmoonFaire.Turnin"] = { "faire", },
	["Quest.DarkmoonFaire.Turnin.Engineering"] = { "faireengin", },
	["Quest.DarkmoonFaire.Turnin.Greys"] = { "fairegreys", },
	["Quest.DarkmoonFaire.Turnin.Leather"] = { "faireleather", },
	["Quest.DarkmoonFaire.Turnin.Blacksmithing"] = { "fairesmithy", },

	["Quest.Libram.BurningSteppes"] = { "librambs", },
	["Quest.Libram.DireMaul"] = { "libramdm", },

	["Quest.UngoroCrystal"] = { "ungorocrystalspower", },


	["Quest.ZulGurub"] = { "zulgurubquests", },
	["Quest.ZulGurub.Coin"] = { "zulgurubcoin", },
	["Quest.ZulGurub.Bijou"] = { "zulgurubbijou", },
	["Quest.ZulGurub.Primal"] = { "zulgurubprimal", },

	["Quest.ZulGurub.Coin.Rep1"] = { "zulgurubcoinrep1", },
	["Quest.ZulGurub.Coin.Rep2"] = { "zulgurubcoinrep2", },
	["Quest.ZulGurub.Coin.Rep3"] = { "zulgurubcoinrep3", },

	["Quest.ZulGurub.Classes"] = { "zulgurubclasses", },
	["Quest.ZulGurub.Druid"] = { "zulgurubdruid", },
	["Quest.ZulGurub.Hunter"] = { "zulgurubhunter", },
	["Quest.ZulGurub.Mage"] = { "zulgurubmage", },
	["Quest.ZulGurub.Paladin"] = { "zulgurubpaladin", },
	["Quest.ZulGurub.Priest"] = { "zulgurubpriest", },
	["Quest.ZulGurub.Rogue"] = { "zulgurubrogue", },
	["Quest.ZulGurub.Shaman"] = { "zulgurubshaman", },
	["Quest.ZulGurub.Warlock"] = { "zulgurubwarlock", },
	["Quest.ZulGurub.Warrior"] = { "zulgurubwarrior", },


	["Reagent"] = { "reagent", },
	["Reagent.Paladin"] = { "reagentpaladin", },
	["Reagent.Druid"] = { "reagentdruid", },
	["Reagent.Mage"] = { "reagentmage", },
	["Reagent.Priest"] = { "reagentpriest", },
	["Reagent.Rogue"] = { "reagentrogue", },
	["Reagent.Shaman"] = { "reagentshaman", },
	["Reagent.Warlock"] = { "reagentwarlock", },

	["Reputation.Junk"] = { "reputationjunk", },
	["Reputation.Tokens"] = { "reputationtokens", },


	-- Tradeskills

	["Tradeskill.Crafted"] = { "craftedby", },
	["Tradeskill.Crafted.Specialty"] = { "craftedbyspecialty", },
	["Tradeskill.Crafted.Alchemy"] = { "craftedbyalchemy", },
	["Tradeskill.Crafted.Blacksmithing"] = { "craftedbyblacksmith", },
	["Tradeskill.Crafted.Blacksmithing.Basic"] = { "craftedbyblacksmithgeneral", },
	["Tradeskill.Crafted.Blacksmithing.Armorsmith"] = { "craftedbyarmorsmith", },
	["Tradeskill.Crafted.Blacksmithing.Axesmith"] = { "craftedbyaxesmith", },
	["Tradeskill.Crafted.Blacksmithing.Hammersmith"] = { "craftedbyhammersmith", },
	["Tradeskill.Crafted.Blacksmithing.Swordsmith"] = { "craftedbyswordsmith", },
	["Tradeskill.Crafted.Blacksmithing.Weaponsmith"] = { "craftedbyweaponsmith", },
	["Tradeskill.Crafted.Cooking"] = { "craftedbycooking", },
	["Tradeskill.Crafted.Engineering"] = { "craftedbyengineering", },
	["Tradeskill.Crafted.Engineering.Basic"] = { "craftedbyengineeringgeneral", },
	["Tradeskill.Crafted.Engineering.Gnomish"] = { "craftedbyengineeringgnome", },
	["Tradeskill.Crafted.Engineering.Goblin"] = { "craftedbyengineeringgoblin", },
	["Tradeskill.Crafted.FirstAid"] = { "craftedbyfirstaid", },
	["Tradeskill.Crafted.Leatherworking"] = { "craftedbyleatherworking", },
	["Tradeskill.Crafted.Leatherworking.Basic"] = { "craftedbyleatherworkinggeneral", },
	["Tradeskill.Crafted.Leatherworking.Dragonscale"] = { "craftedbyleatherworkingdragonscale", },
	["Tradeskill.Crafted.Leatherworking.Elemental"] = { "craftedbyleatherworkingelemental", },
	["Tradeskill.Crafted.Leatherworking.Tribal"] = { "craftedbyleatherworkingtribal", },
	["Tradeskill.Crafted.Tailoring"] = { "craftedbytayloring", },

	["Tradeskill.Gather"] = { "gatherskill", },
	["Tradeskill.Gather.Fishing"] = { "gatherskillfishing", },
	["Tradeskill.Gather.Disenchant"] = { "gatherskilldisenchant", },
	["Tradeskill.Gather.Herbalism"] = { "gatherskillherbalism", },
	["Tradeskill.Gather.Mining"] = { "gatherskillmining", },
	["Tradeskill.Gather.Skinning"] = { "gatherskillskinning", },

	["Tradeskill.Gather.Mining.GemInNode"] = { "minedgem", },
	["Tradeskill.Gather.Mining.GemInNode.Copper"] = { "minedgemcopper", },
	["Tradeskill.Gather.Mining.GemInNode.Tin"] = { "minedgemtin", },
	["Tradeskill.Gather.Mining.GemInNode.Silver"] = { "minedgemsilver", },
	["Tradeskill.Gather.Mining.GemInNode.Iron"] = { "minedgemiron", },
	["Tradeskill.Gather.Mining.GemInNode.Gold"] = { "minedgemgold", },
	["Tradeskill.Gather.Mining.GemInNode.Mithril"] = { "minedgemmithril", },
	["Tradeskill.Gather.Mining.GemInNode.Truesilver"] = { "minedgemtruesilver", },
	["Tradeskill.Gather.Mining.GemInNode.Thorium"] = { "minedgemthorium", },
	["Tradeskill.Gather.Mining.GemInNode.Zgthorium"] = { "minedgemzgthorium", },
	["Tradeskill.Gather.Mining.GemInNode.Richthorium"] = { "minedgemrichthorium", },
	["Tradeskill.Gather.Mining.GemInNode.Darkiron"] = { "minedgemdarkiron", },

	["Tradeskill.Mat.ByType.Bar"] = { "ingredbar", },
	["Tradeskill.Mat.ByType.Bolt"] = { "ingredbolt", },
	["Tradeskill.Mat.ByType.Cloth"] = { "ingredcloth", },
	["Tradeskill.Mat.ByType.Dust"] = { "ingreddust", },
	["Tradeskill.Mat.ByType.Dye"] = { "ingreddye", },
	["Tradeskill.Mat.ByType.Element"] = { "ingredelement", },
	["Tradeskill.Mat.ByType.Essence"] = { "ingredessence", },
	["Tradeskill.Mat.ByType.Flux"] = { "ingredflux", },
	["Tradeskill.Mat.ByType.Gem"] = { "ingredgem", },
	["Tradeskill.Mat.ByType.Grinding"] = { "ingredgrinding", },
	["Tradeskill.Mat.ByType.Hide"] = { "ingredhide", },
	["Tradeskill.Mat.ByType.Leather"] = { "ingredleather", },
	["Tradeskill.Mat.ByType.Nexus"] = { "ingrednexus", },
	["Tradeskill.Mat.ByType.Oil"] = { "ingredoil", },
	["Tradeskill.Mat.ByType.Ore"] = { "ingredore", },
	["Tradeskill.Mat.ByType.Part"] = { "ingredpart", },
	["Tradeskill.Mat.ByType.Pearl"] = { "ingredpearl", },
	["Tradeskill.Mat.ByType.Poison"] = { "ingredpoison", },
	["Tradeskill.Mat.ByType.Powder"] = { "ingredpowder", },
	["Tradeskill.Mat.ByType.Rod"] = { "ingredrod", },
	["Tradeskill.Mat.ByType.Salt"] = { "ingredsalt", },
	["Tradeskill.Mat.ByType.Scale"] = { "ingredscale", },
	["Tradeskill.Mat.ByType.Shard"] = { "ingredshard", },
	["Tradeskill.Mat.ByType.Spice"] = { "ingredspice", },
	["Tradeskill.Mat.ByType.Stone"] = { "ingredstone", },
	["Tradeskill.Mat.ByType.Thread"] = { "ingredthread", },
	["Tradeskill.Mat.ByType.Vial"] = { "ingredvial", },

	["Tradeskill.Mat.BySource.Drop"] = { "ingredmonsterdrops", },
	["Tradeskill.Mat.BySource.Vendor"] = { "ingredvendorbought", },

	["Tradeskill.Recipe"] = { "recipe", },
	["Tradeskill.Recipe.Alchemy"] = { "recipealchemy", },
	["Tradeskill.Recipe.Blacksmithing"] = { "recipeblacksmith", },
	["Tradeskill.Recipe.Cooking"] = { "recipecooking", },
	["Tradeskill.Recipe.Enchanting"] = { "recipeenchanting", },
	["Tradeskill.Recipe.Engineering"] = { "recipeengineering", },
	["Tradeskill.Recipe.Fishing"] = { "recipefishing", },
	["Tradeskill.Recipe.FirstAid"] = { "recipefirstaid", },
	["Tradeskill.Recipe.Leatherworking"] = { "recipeleatherworking", },
	["Tradeskill.Recipe.Tailoring"] = { "recipetailoring", },

	["Tradeskill.Recipe.Vendor"] = { "recipevendor", },
	["Tradeskill.Recipe.Vendor.Alchemy"] = { "recipevendoralchemy", },
	["Tradeskill.Recipe.Vendor.Blacksmithing"] = { "recipevendorblacksmith", },
	["Tradeskill.Recipe.Vendor.Cooking"] = { "recipevendorcooking", },
	["Tradeskill.Recipe.Vendor.Enchanting"] = { "recipevendorenchanting", },
	["Tradeskill.Recipe.Vendor.Engineering"] = { "recipevendorengineering", },
	["Tradeskill.Recipe.Vendor.Fishing"] = { "recipevendorfishing", },
	["Tradeskill.Recipe.Vendor.Firstaid"] = { "recipevendorfirstaid", },
	["Tradeskill.Recipe.Vendor.Leatherworking"] = { "recipevendorleatherworking", },
	["Tradeskill.Recipe.Vendor.Tailoring"] = { "recipevendortailoring", },

	["Tradeskill.Recipe.Drop"] = { "recipedrop", },
	["Tradeskill.Recipe.Drop.Alchemy"] = { "recipedropalchemy", },
	["Tradeskill.Recipe.Drop.Blacksmithing"] = { "recipedropblacksmith", },
	["Tradeskill.Recipe.Drop.Firstaid"] = { "recipedropfirstaid", },
	["Tradeskill.Recipe.Drop.Cooking"] = { "recipedropcooking", },
	["Tradeskill.Recipe.Drop.Enchanting"] = { "recipedropenchanting", },
	["Tradeskill.Recipe.Drop.Engineering"] = { "recipedropengineering", },
	["Tradeskill.Recipe.Drop.Leatherworking"] = { "recipedropleatherworking", },
	["Tradeskill.Recipe.Drop.Tailoring"] = { "recipedroptailoring", },

	["Tradeskill.Recipe.Quest"] = { "recipequest", },
	["Tradeskill.Recipe.Quest.Alchemy"] = { "recipequestalchemy", },
	["Tradeskill.Recipe.Quest.Blacksmithing"] = { "recipequestblacksmith", },
	["Tradeskill.Recipe.Quest.Cooking"] = { "recipequestcooking", },
	["Tradeskill.Recipe.Quest.Engineering"] = { "recipequestengineering", },
	["Tradeskill.Recipe.Quest.Leatherworking"] = { "recipequestleatherworking", },
	["Tradeskill.Recipe.Quest.Tailoring"] = { "recipequesttailoring", },

	["Tradeskill.Recipe.Crafted"] = { "recipecrafted", },
	["Tradeskill.Recipe.Crafted.Alchemy"] = { "recipecraftedalchemy", },
	["Tradeskill.Recipe.Crafted.Blacksmithing"] = { "recipecraftedblacksmith", },

	["Tradeskill.Recipe.Seasonal"] = { "recipeseasonal", },

	["Tradeskill.Recipe.Faction"] = { "recipefaction", },
	["Tradeskill.Recipe.Faction.Alliance"] = { "recipefactionalliance", },
	["Tradeskill.Recipe.Faction.Horde"] = { "recipefactionhorde", },
	["Tradeskill.Recipe.Faction.Neutral"] = { "recipefactionneutral", },
	["Tradeskill.Recipe.Faction.ArgentDawn"] = { "recipefactionargentdawn", },
	["Tradeskill.Recipe.Faction.CenarionCircle"] = { "recipefactioncenarioncircle", },
	["Tradeskill.Recipe.Faction.ThoriumBrotherhood"] = { "recipefactionthoriumbrotherhood", },
	["Tradeskill.Recipe.Faction.Timbermaw"] = { "recipefactiontimbermaw", },
	["Tradeskill.Recipe.Faction.Zandalar"] = { "recipefactionzandalar", },
	["Tradeskill.Recipe.Faction.Ravenholdt"] = { "recipefactionravenholdt", },

	["Tradeskill.Mat.ByProfession"] = { "tradeskill", },
	["Tradeskill.Mat.ByProfession.Alchemy"] = { "tradeskillalchemy", },
	["Tradeskill.Mat.ByProfession.Blacksmithing"] = { "tradeskillblacksmithing", },
	["Tradeskill.Mat.ByProfession.Cooking"] = { "tradeskillcooking", },
	["Tradeskill.Mat.ByProfession.Enchanting"] = { "tradeskillenchanting", },
	["Tradeskill.Mat.ByProfession.Engineering"] = { "tradeskillengineering", },
	["Tradeskill.Mat.ByProfession.Firstaid"] = { "tradeskillfirstaid", },
	["Tradeskill.Mat.ByProfession.Leatherworking"] = { "tradeskillleatherworking", },
	["Tradeskill.Mat.ByProfession.Tailoring"] = { "tradeskilltailoring", },
	["Tradeskill.Mat.ByProfession.Poison"] = { "tradeskillpoison", },
	["Tradeskill.Mat.ByProfession.Smelting"] = { "tradeskillsmelting", },

	["Tradeskill.Tool"] = { "tradeskilltools", },
	["Tradeskill.Tool.Enchanting"] = { "toolsenchanting", },
	["Tradeskill.Tool.Engineering"] = { "toolsengineering", },
	["Tradeskill.Tool.Blacksmithing"] = { "toolsblacksmithing", },
	["Tradeskill.Tool.Skinning"] = { "toolsskinning", },
	["Tradeskill.Tool.Mining"] = { "toolsmining", },
	["Tradeskill.Tool.Fishing"] = { "toolsfishing", },
	["Tradeskill.Tool.Fishing.Gear"] = { "fishinggear", },
	["Tradeskill.Tool.Fishing.Bait"] = { "fishinglures", },
	["Tradeskill.Tool.Fishing.Tool"] = { "fishingpoles", },

}


-- Process into PeriodicTable format.


for setName, set in pairs(ptCustomCategoryNames) do
	Bagshui.libs.PT:RegisterCustomSet(set, setName)
end


for parentSetName, sets in pairs(ptCustomItems) do
	local parentSet = {}
	for setName, itemList in pairs(sets) do
		table.insert(parentSet, setName)
		if type(itemList) == "table" then
			Bagshui.libs.PT:RegisterCustomSet(table.concat(itemList, " "), setName)
		end
	end
	Bagshui.libs.PT:RegisterCustomSet(parentSet, parentSetName)
end


end)