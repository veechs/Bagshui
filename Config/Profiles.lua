-- Bagshui Default Profiles
-- Exposes: Bagshui.config.Profiles

Bagshui:AddComponent(function()

-- Array of tables that defines non-editable built-in profile templates.
-- Each one *must* have a unique `id` property that will become its object ID.
-- See Components\Profiles.lua for details, especially the `profileSkeleton` declaration.
---@type table<string, any>[]
Bagshui.config.Profiles = {

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

					-- Row 4
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

					-- Row 6
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

					-- Row 7
					{
						{
							name = string.format(L.Suffix_Items, L.Quest),
							categories = {
								"Quest",
								"ActiveQuest",
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

}


end)