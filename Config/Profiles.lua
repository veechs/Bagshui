-- Bagshui Default Profiles
-- Exposes: Bagshui.config.Profiles

Bagshui:AddComponent(function()

-- Array of tables that defines non-editable built-in profile templates.
-- Each one *must* have a unique `id` property that will become its object ID.
-- See Components\Profiles.lua for details, especially the `profileSkeleton` declaration.
---@type table<string, any>[]
Bagshui.config.Profiles = {
	version = 2,

	defaults = {
		-- This is the default profile, which specifies the default layout.
		{
			id = "Bagshui",
			name = "Bagshui",
			structure = {
				primary = {
					layout = {
						-- Row 1
						{
							{
								name = L.Explosives,
								categories = {
									"Explosives",
								},
							},
							{
								name = L.Bags,
								categories = {
									"Bags",
								},
							},
							{
								name = string.format("%s/%s", L.Mounts, L.Companions),
								categories = {
									"Mounts",
									"Companions",
								},
							},
							{
								name = L.Junk,
								categories = {
									"QualGray",
								},
							},
							{
								name = L.Uncategorized,
								categories = {
									"Uncategorized",
								},
							},
							{
								name = L.Empty,
								categories = {
									"EmptySlot",
								},
							},
						},

						-- Row 2
						{
							{
								name = L.Food,
								categories = {
									"Food",
								},
								sortOrder = "MinLevel"
							},
							{
								name = L.Drink,
								categories = {
									"Drink",
								},
								sortOrder = "MinLevel"
							},
							{
								name = L.Consumables,
								categories = {
									"Consumables",
								},
							},
							{
								name = L.Health,
								categories = {
									"PotionsHealth",
									"Bandages",
								},
								sortOrder = "MinLevelNameRev"
							},
							{
								name = L.Mana,
								categories = {
									"PotionsMana",
								},
								sortOrder = "MinLevelNameRev"
							},
							{
								name = L.PotionsSlashRunes,
								categories = {
									"Potions",
									"Runes",
								},
								sortOrder = "MinLevelNameRev"
							},
							{
								name = L.Buffs,
								categories = {
									"Elixirs",
									"FoodBuffs",
									"Juju",
									"Scrolls",
									"WeaponBuffs",
								},
								sortOrder = "MinLevelNameRev"
							},
						},

						-- Row 3
						{
							{
								name = L.Recipes,
								categories = {
									"Recipes",
								},
							},
							{
								name = L.ProfessionCrafts,
								categories = {
									"ProfessionCrafts",
								},
							},
							{
								name = L.ProfessionReagents,
								categories = {
									"ProfessionBags",
									"ProfessionReagents",
								},
							},
							{
								name = L["Trade Goods"],
								categories = {
									"AllProfessionBags",
									"TradeGoods",
								},
							},
						},

						-- Row 4
						{
							{
								name = L.MyGear,
								categories = {
									"SoulboundGear",
									"EquippedGear",
								},
							},
							{
								name = L.BindOnEquip,
								categories = {
									"BOE",
								},
							},
							{
								name = L.Gear,
								categories = {
									"Armor",
									"Weapons",
								},
							},
						},

						-- Row 5
						{
							{
								name = string.format(L.Suffix_Items, L.Quest),
								categories = {
									"Quest",
									"ActiveQuest",
								},
							},
							{
								name = L.Tokens,
								categories = {
									"Tokens",
								},
							},
							{
								name = L.Keys,
								categories = {
									"KeyAndKeyLike",
								},
							},
							{
								name = string.format(L.Suffix_Reagents, _G.CLASS),
								categories = {
									"ClassReagents"
								}
							},
							{
								name = string.format(L.Suffix_Items, _G.CLASS),
								categories = {
									"ClassItems",
									"ClassBooks",
								}
							},
							{
								name = L.Misc,
								categories = {
									"Teleports",
									"TradeTools",
								},
							},
						},
					},
				},
				docked = {
					Keyring = {
						layout = {
							-- Row 1
							{
								{
									name = L.Empty,
									categories = {
										"EmptySlot",
									},
								},
								{
									name = L.Uncategorized,
									categories = {
										"Uncategorized",
									},
								},
								{
									name = L.Glyphs,
									categories = {
										"TWGlyphs",
									},
								},
								{
									name = L.Keys,
									categories = {
										"KeyAndKeyLike",
									},
								},
							},
						},
					},
				},
			},

			-- This empty table must be present for the profile to be available as an
			-- option for default Design profile.
			-- Defaults for the Design profile come from inventory-scoped settings that have 
			-- `profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN` (Config\Settings.lua).
			design = {},
		},

		-- OneBagshui is a "OneBag" style layout where everything is in a single group
		-- and the only organization is via sorting.
		{
			id = "OneBagshui",
			name = "OneBagshui",
			structure = {
				defaultSortOrder = "Manual",
				stackEmptySlots = false,
				-- Since there's only one group, the labels aren't necessary.
				hideGroupLabelsOverride = true,
				primary = {
					layout = {
						-- Row 1
						{
							{
								name = L.Hidden,
								categories = {},
								hide = true,
							},
						},

						-- Row 2
						{
							{
								name = L.Inventory,
								categories = {
									"ActiveQuest",
									"Armor",
									"Bags",
									"Bandages",
									"ClassBooks",
									"ClassItems",
									"ClassReagents",
									"Companions",
									"Consumables",
									"Disguises",
									"Drink",
									"Elixirs",
									"EmptySlot",
									"EquippedGear",
									"Explosives",
									"Food",
									"FoodBuffs",
									"Juju",
									"KeyAndKeyLike",
									"Mounts",
									"Potions",
									"PotionsHealth",
									"PotionsMana",
									"ProfessionCrafts",
									"ProfessionReagents",
									"QualGray",
									"Quest",
									"Recipes",
									"Runes",
									"Scrolls",
									"SoulboundGear",
									"Teleports",
									"Tokens",
									"TradeGoods",
									"TradeTools",
									"Uncategorized",
									"WeaponBuffs",
									"Weapons",
								},
								-- Invisible background and border.
								background = { 0, 0, 0, 0 },
								border = { 0, 0, 0, 0 },
							},
						},
					},
				},
				docked = {
					Keyring = {
						layout = {
							-- Row 1
							{
								{
									name = L.Hidden,
									categories = {},
									hide = true,
								},
							},

							-- Row 2
							{
								{
									name = L.Inventory,
									categories = {
										"EmptySlot",
										"KeyAndKeyLike",
										"TWGlyphs",
										"Uncategorized",
									},
									background = { 0, 0, 0, 0 },
									border = { 0, 0, 0, 0 },
								},
							},
						},
						defaultSortOrder = "Manual",
						stackEmptySlots = false,
						hideGroupLabelsOverride = true,
					},
				},
			},

			design = {
				windowMaxColumns = 10
			},
		},

	}, -- End defaults.


	-- Changes that need to occur during updates.
	migrate = function(profiles, oldVersion)

		-- In v2, the Tokens Category was added to both the Bagshui and OneBagshui Structures.
		if oldVersion < 2 then
			for id, profile in pairs(profiles.list) do
				-- Only add Tokens if there hasn't been significant editing.
				if
					-- Based on default Bagshui Structure.
					profile.structure
					and profile.structure.primary
					and profile.structure.primary.layout
					and type(profile.structure.primary.layout[5]) == "table"
					-- Quest Items
					and (
						type(profile.structure.primary.layout[5][1]) == "table"
						and profile.structure.primary.layout[5][1].name == string.format(L.Suffix_Items, L.Quest)
						and type(profile.structure.primary.layout[5][1].categories) == "table"
						and table.getn(profile.structure.primary.layout[5][1].categories) == 2
						and BsUtil.TableContainsValue(profile.structure.primary.layout[5][1].categories, "Quest")
						and BsUtil.TableContainsValue(profile.structure.primary.layout[5][1].categories, "ActiveQuest")
					)
					-- Keys
					and (
						type(profile.structure.primary.layout[5][2]) == "table"
						and profile.structure.primary.layout[5][2].name == L.Keys
						and type(profile.structure.primary.layout[5][2].categories) == "table"
						and table.getn(profile.structure.primary.layout[5][2].categories) == 1
						and profile.structure.primary.layout[5][2].categories[1] == "KeyAndKeyLike"
					)
					-- Safeguard to make sure profile default exists.
					and Bagshui.config.Profiles
					and Bagshui.config.Profiles.defaults
					and Bagshui.config.Profiles.defaults[1]
					and Bagshui.config.Profiles.defaults[1].structure
					and Bagshui.config.Profiles.defaults[1].structure.primary
					and Bagshui.config.Profiles.defaults[1].structure.primary.layout
					and Bagshui.config.Profiles.defaults[1].structure.primary.layout[5]
					and Bagshui.config.Profiles.defaults[1].structure.primary.layout[5][2]
				then
					-- Tokens is a separate Group in Bagshui.
					table.insert(
						profile.structure.primary.layout[5],
						2,
						BsUtil.TableCopy(Bagshui.config.Profiles.defaults[1].structure.primary.layout[5][2])
					)

				elseif
					-- Based on OneBagshui Structure.
					profile.structure
					and profile.structure.primary
					and profile.structure.primary.layout
					and type(profile.structure.primary.layout[2]) == "table"
					and type(profile.structure.primary.layout[2][1]) == "table"
					and profile.structure.primary.layout[2][1].name == L.Inventory
					and type(profile.structure.primary.layout[2][1].categories) == "table"
					and table.getn(profile.structure.primary.layout[2][1].categories) == 37
					-- Yes this is silly but it only will ever run once.
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ActiveQuest")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Armor")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Bags")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Bandages")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ClassBooks")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ClassItems")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ClassReagents")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Companions")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Consumables")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Disguises")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Drink")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Elixirs")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "EmptySlot")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "EquippedGear")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Explosives")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Food")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "FoodBuffs")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Juju")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "KeyAndKeyLike")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Mounts")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Potions")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "PotionsHealth")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "PotionsMana")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ProfessionCrafts")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "ProfessionReagents")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "QualGray")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Quest")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Recipes")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Runes")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Scrolls")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "SoulboundGear")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Teleports")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "TradeGoods")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "TradeTools")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Uncategorized")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "WeaponBuffs")
					and BsUtil.TableContainsValue(profile.structure.primary.layout[2][1].categories, "Weapons")
				then
					-- Tokens is used for sorting in OneBagshui (if changed away from Manual sort, obvs).
					table.insert(
						profile.structure.primary.layout[2][1].categories,
						"Tokens"
					)
					table.sort(profile.structure.primary.layout[2][1].categories)
				end
			end
		end

	end
}



end)