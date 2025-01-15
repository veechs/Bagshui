-- Bagshui Item Fixes
-- Exposes: Bagshui.config.ItemFixes
--
-- This file contains corrections to item properties. It's primarily used to fix
-- type/subtype, but can be used for any item property. Most of the time, category
-- lists and rules are fine to identify items correctly, but sometimes the information
-- WoW returns about an item doesn't make any sense, and it's better to fix it before
-- we get to the stage of categorizing things.
-- One example of this is quest items that have to be bound into books,
-- which are classed as Junk instead of Quest.

Bagshui:LoadComponent(function()

-- This table is filled with:
-- ```
-- [<ItemId>] = {
-- 	<propertyName1> = "Value1",
-- 	<propertyName2> = "Value2",
-- }
-- ```
-- Property names are case-sensitive and must match what's in `BS_INVENTORY_TEMPLATE`.
---@type table<number, table<string, any>>
Bagshui.config.ItemFixes = {

	-- Consumables
	[11563] = { type = "Consumable", subtype = "Consumable" }, -- Crystal Force (all the Crystals here can be quest objectives, but they do other stuff too ).
	[11564] = { type = "Consumable", subtype = "Consumable" }, -- Crystal Ward  (so we'll let ActiveQuest() put them in the Quest category when applicable  ).
	[11565] = { type = "Consumable", subtype = "Consumable" }, -- Crystal Yield.
	[11567] = { type = "Consumable", subtype = "Consumable" }, -- Crystal Spire.
	[4388]  = { type = "Consumable", subtype = "Consumable" }, -- Discombobulator Ray (this is normally Trade Goods/Devices, and an argument could really be made either way, but let's follow EngInventory's lead for now).
	[21519] = { type = "Consumable", subtype = "Consumable" }, -- Mistletoe (doesn't belong in Miscellaneous/Junk).
	[5052]  = { type = "Consumable", subtype = "Consumable" }, -- Unconscious Dig Rat (doesn't belong in Miscellaneous/Junk).
	[5332]  = { type = "Consumable", subtype = "Consumable" }, -- Glowing Cat Figurine (doesn't belong in Miscellaneous/Junk).

	-- Explosives
	[11566] = { type = "Trade Goods", subtype = "Explosives" }, -- Crystal Charge (yes, it's received from a quest, but it's not a Quest Item).
	-- [10577] = { type = "Trade Goods", subtype = "Explosives" }, -- Goblin Mortar [FIX DISABLED] (EngInventory had this forced into the Explosives category but that doesn't seem necessary since it actually is a trinket).
	[8956]  = { type = "Trade Goods", subtype = "Explosives" }, -- Oil of Immolation (previously Consumable/Consumable).
	[4403]  = { type = "Trade Goods", subtype = "Explosives" }, -- Portable Bronze Mortar (why is this in Trade Goods/Devices instead of Explosives?).
	[13180] = { type = "Trade Goods", subtype = "Explosives" }, -- Stratholme Holy Water (it is a Quest Item, but the ActiveQuest() rule will catch them when they're actually an objective).

	-- Quest Items
	[15874] = { type = "Quest", subtype = "Quest" }, -- Soft-Shelled Clams aren't keys (this might just be a Turtle WoW issue).
	[61793] = { type = "Quest", subtype = "Quest" }, -- Arena Marks of Honor aren't junk and there's no Vanilla "Currency" type.


	-- Bindable book pages for quests (previously Miscellaneous/Junk).
	-- ActiveQuest() will never catch these because they are not actual objectives, only their "bound" versions are.

	-- Green Hills of Stranglethorn
	[2725] = { type = "Quest", subtype = "Quest" },
	[2728] = { type = "Quest", subtype = "Quest" },
	[2730] = { type = "Quest", subtype = "Quest" },
	[2732] = { type = "Quest", subtype = "Quest" },
	[2734] = { type = "Quest", subtype = "Quest" },
	[2735] = { type = "Quest", subtype = "Quest" },
	[2738] = { type = "Quest", subtype = "Quest" },
	[2740] = { type = "Quest", subtype = "Quest" },
	[2742] = { type = "Quest", subtype = "Quest" },
	[2744] = { type = "Quest", subtype = "Quest" },
	[2745] = { type = "Quest", subtype = "Quest" },
	[2748] = { type = "Quest", subtype = "Quest" },
	[2749] = { type = "Quest", subtype = "Quest" },
	[2750] = { type = "Quest", subtype = "Quest" },
	[2751] = { type = "Quest", subtype = "Quest" },

	-- Shredder Operating Manual
	[16645] = { type = "Quest", subtype = "Quest" },
	[16646] = { type = "Quest", subtype = "Quest" },
	[16647] = { type = "Quest", subtype = "Quest" },
	[16648] = { type = "Quest", subtype = "Quest" },
	[16649] = { type = "Quest", subtype = "Quest" },
	[16650] = { type = "Quest", subtype = "Quest" },
	[16651] = { type = "Quest", subtype = "Quest" },
	[16652] = { type = "Quest", subtype = "Quest" },
	[16653] = { type = "Quest", subtype = "Quest" },
	[16654] = { type = "Quest", subtype = "Quest" },
	[16655] = { type = "Quest", subtype = "Quest" },
	[16656] = { type = "Quest", subtype = "Quest" },

	-- Love is In the Air (previously Consumables).
	[21960] = { type = "Quest", subtype = "Quest" }, -- Handmade Woodcraft.
	[22117] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Stormwind.
	[22119] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Ironforge.
	[22120] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Darnassus.
	[22121] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Undercity.
	[22122] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Thunder Bluff.
	[22123] = { type = "Quest", subtype = "Quest" }, -- Pledge of Loyalty: Orgrimmar.
	[22140] = { type = "Quest", subtype = "Quest" }, -- Sentinel's Card.
	[22141] = { type = "Quest", subtype = "Quest" }, -- Ironforge Guard's Card.
	[22142] = { type = "Quest", subtype = "Quest" }, -- Grunt's Card.
	[22143] = { type = "Quest", subtype = "Quest" }, -- Stormwind Guard's Card.
	[22144] = { type = "Quest", subtype = "Quest" }, -- Bluffwatcher's Card.
	[22145] = { type = "Quest", subtype = "Quest" }, -- Guardian's Moldy Card.
	[22173] = { type = "Quest", subtype = "Quest" }, -- Dwarven Homebrew.
	[22174] = { type = "Quest", subtype = "Quest" }, -- Romantic Poem.
	[22175] = { type = "Quest", subtype = "Quest" }, -- Freshly Baked Pie.
	[22176] = { type = "Quest", subtype = "Quest" }, -- Homemade Bread.
	[22177] = { type = "Quest", subtype = "Quest" }, -- Freshly Picked Flowers.
	[22283] = { type = "Quest", subtype = "Quest" }, -- Sack of Homemade Bread.
	[22284] = { type = "Quest", subtype = "Quest" }, -- Bundle of Cards.
	[22285] = { type = "Quest", subtype = "Quest" }, -- Stormwind Pledge Collection.
	[22286] = { type = "Quest", subtype = "Quest" }, -- Ironforge Pledge Collection.
	[22287] = { type = "Quest", subtype = "Quest" }, -- Parcel of Cards.
	[22288] = { type = "Quest", subtype = "Quest" }, -- Case of Homebrew.
	[22289] = { type = "Quest", subtype = "Quest" }, -- Stack of Cards.
	[22290] = { type = "Quest", subtype = "Quest" }, -- Darnassus Pledge Collection.
	[22291] = { type = "Quest", subtype = "Quest" }, -- Box of Woodcrafts.
	[22292] = { type = "Quest", subtype = "Quest" }, -- Box of Fresh Pies.
	[22293] = { type = "Quest", subtype = "Quest" }, -- Package of Cards.
	[22294] = { type = "Quest", subtype = "Quest" }, -- Orgrimmar Pledge Collection.
	[22295] = { type = "Quest", subtype = "Quest" }, -- Satchel of Cards.
	[22296] = { type = "Quest", subtype = "Quest" }, -- Basket of Flowers.
	[22297] = { type = "Quest", subtype = "Quest" }, -- Thunder Bluff Pledge Collection.
	[22298] = { type = "Quest", subtype = "Quest" }, -- Book of Romantic Poems.
	[22299] = { type = "Quest", subtype = "Quest" }, -- Sheaf of Cards.
	[22300] = { type = "Quest", subtype = "Quest" }, -- Undercity Pledge Collection.
}


end)