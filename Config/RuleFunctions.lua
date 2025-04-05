-- Bagshui Rule Functions
-- Exposes: Bagshui.config.RuleFunctions
--
-- Defines the built-in rule functions available for use in Category rule expressions.

Bagshui:AddComponent(function()


-- Internal constant for BagType() rule function.
local ALL_PROFESSION_BAGS = "~AllProfessionBags~"
-- Internal constant for BagType() rule function.
local PROFESSION_BAGS = "~ProfessionBags~"


-- Property names/values of tables in this array should match `Rules:AddFunction()`
-- parameters, however the `templates` property should *not* be used in this file.
-- Instead, there are two options for adding built-in rule templates:
-- 1. Localization (see `Rules:AddRuleExamplesFromLocalization() for details).
-- 2. Generated in Config\RuleFunctionTemplates.lua or elsewhere and added to `Bagshui.config.RuleFunctionTemplates`.
---@type table<string, any>[]
Bagshui.config.RuleFunctions = {

	-- Item belongs to the list of active quest items.
	-- Only works by name due to client limitations.
	{
		functionNames = {
			"ActiveQuest",
			"aq",
			"ActiveQuestItem",
		},
		ruleFunction = function(rules, ruleArguments)
			return Bagshui.activeQuestItems[rules.item.name] ~= nil
		end,
		-- Templates come from localization.
	},


	-- Item is in the given bag number.
	{
		functionNames = {
			"Bag",
			"BagNum",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestItemAttribute("bagNum", ruleArguments, "number")
		end,
		-- Templates are autogenerated in Components\Rules.lua (can't be done in
		-- RuleFunctionTemplates.lua because it's too early to read each inventory type).
	},


	-- Item is in a bag of the given type.
	{
		functionNames = {
			"BagType",
			"bt",
			"ContainerType",
		},
		ruleFunction = function(rules, ruleArguments)
			for _, arg in ipairs(ruleArguments) do
				-- Profession bags, triggered by "*ProfessionBags*" or "*AllProfessionBags*"
				if arg == PROFESSION_BAGS or arg == ALL_PROFESSION_BAGS then
					for profession, bagType in pairs(BsGameInfo.professionsToBags) do
						if
							(arg == PROFESSION_BAGS and rules.character.skills.professions[profession])
							or arg == ALL_PROFESSION_BAGS
						then
							table.insert(ruleArguments, bagType)
						end
					end
				end
			end
			return rules:TestItemAttribute("bagType", ruleArguments)
		end,
		environmentVariables = {
			AllProfessionBags = ALL_PROFESSION_BAGS,
			AllTradeskillBags = ALL_PROFESSION_BAGS,
			ProfessionBag = PROFESSION_BAGS,
			ProfessionBags = PROFESSION_BAGS,
			TradeskillBag = PROFESSION_BAGS,
			TradeskillBags = PROFESSION_BAGS,
		},
		-- Templates are autogenerated in RuleFunctionTemplates.lua
	},


	-- Item binds on equip.
	{
		functionNames = {
			"BindsOnEquip",
			"BindsWhenEquipped",
			"boe",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Reusable table parameter to avoid activating garbage collection.
			if not rules._bindsOnEquip_Tooltip then
				rules._bindsOnEquip_Tooltip = { _G.ITEM_BIND_ON_EQUIP }
			end
			return rules:Rule_Tooltip(rules._bindsOnEquip_Tooltip)
		end,
		-- Templates come from localization.
	},


	-- CharacterLevelRange() -- Exactly the current character's level.
	-- CharacterLevelRange(<levels below>, <levels above>) -- Within the range provided.
	{
		functionNames = {
			"CharacterLevelRange",
			"clr",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Avoid an error about missing arguments vy setting 0 as the only argument
			-- When adjusted by `betweenAdjustmentAmount` it will become the
			-- character's current level.
			if table.getn(ruleArguments) == 0 then
				table.insert(ruleArguments, 0)
			end
			-- Passing the currently targeted character's level for `betweenAdjustmentAmount`
			-- so that upper and lower bound are relative to the current character's level
			return rules:TestItemAttribute("minLevel", ruleArguments, nil, "between", rules.character.level)
		end,
		-- Templates come from localization.
	},


	-- Count(#): There are at least this many of the item.
	-- Count(min, max): There are between <min> and <max> of the item.
	{
		functionNames = {
			"Count",
			"Num",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Passing true for the last parameter so that Count(5) will match >= 5
			-- (infinite upper bound if table.getn(ruleArguments) == 1).
			return rules:TestItemAttribute("count", ruleArguments, nil, "between", nil, true)
		end,
		-- Templates come from localization.
	},


	-- Empty slots.
	{
		functionNames = {
			"EmptySlot",
			"empty",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules.item.emptySlot == 1
		end,
		-- Templates come from localization.
	},


	-- Item can be equipped at the specified location.
	{
		functionNames = {
			"EquipLocation",
			"eq",
			"Equip",
			"EquipLoc",
		},
		ruleFunction = function(rules, ruleArguments)
			if table.getn(ruleArguments) == 0 then
				return string.len(rules.item.equipLocation) > 0
			else
				return
					rules:TestItemAttribute("equipLocation", ruleArguments)
					or rules:TestItemAttribute("equipLocationLocalized", ruleArguments)
			end
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Item has been equipped at least once.
	{
		functionNames = {
			"Equipped",
			"Worn",
		},
		ruleFunction = function(rules, ruleArguments)
			return BsCharacter:TestItem(rules.item.itemString, rules.character.equippedHistory, ruleArguments)
		end,
		-- Templates come from localization.
	},


	-- Item's ID is in the given list.
	{
		functionNames = {
			"Id",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestItemAttribute("id", ruleArguments, "string,number")
		end,
		-- Templates come from localization.
	},


	-- Vanilla doesn't have ilvls.
	{
		functionNames = {
			"ItemLevelStat",
			"ilvl",
			"itemlevel",
			"statlevel",
		},
		ruleFunction = function(rules, ruleArguments)
			rules.errorMessage = L.Error_Rule_ItemLevelStat
			return false
		end,
		hideFromUi = true,
	},


	-- Item string matches the given list.
	{
		functionNames = {
			"ItemString",
			"is",
		},
		ruleFunction = function(rules, ruleArguments)
			rules:RequireArguments(ruleArguments)

			-- Ensure all item strings are properly formatted to increase the likelihood of matching.
			-- The goal is to come out with something like:
			-- - "^item:itemId:enchantId:suffixId:uniqueId"
			-- - "^item:itemId:"
			for i = 1, table.getn(ruleArguments) do
				local arg = ruleArguments[i]

				if string.find(tostring(arg), "^/.-/$") then
					-- Already a pattern; nothing to do.

				elseif type(arg) == "number" or string.find(tostring(arg), "^%d+$") then
					-- It's just a number: 12345 and "12345" -> "^item:12345:".
					arg = "^item:" .. tostring(arg) .. ":"


				elseif type(arg) == "string" then
					-- Other strings require more work.

					-- Clean up any stray colons from both ends before starting
					arg = BsUtil.Trim(arg, ":")

					-- Everything other than a string like "item:1000" needs to be tweaked
					if not string.find(arg, "^%^?%a+:%d+") then
						arg = "item:" .. arg
					end

					-- Expand any empty colons (Wowhead-style) to zeros (this needs to run twice to catch them all).
					arg = string.gsub(string.gsub(arg, "::", ":0:"), "::", ":0:")

					-- More stuff for standard item strings
					if string.find(arg, "^item") then
						local _, colonCount = string.gsub(arg, ":", "")

						-- Item strings in Vanilla only have 4 parts, so remove any extraneous things from the end
						-- (again, getting a string from Wowhead is the issue here).
						if colonCount > 4 then
							arg = BsItemInfo:ParseItemLink(arg)

						-- Standard item strings have 4 colons, so if there are fewer than 4 and
						-- the argument doesn't already end in a colon, add one to ensure correct
						-- partial matches (item:123 shouldn't match item:1234:0:0:0).
						elseif colonCount < 4 and not string.find(arg, ":$") then
							arg = arg .. ":"
						end
					end

					-- Anchor the pattern to the start of the string if it's not already anchored.
					if not string.find(arg, "^%^") then
						arg = "^" .. arg
					end

				end
				-- Activate pattern matching.
				ruleArguments[i] = "/" .. arg .. "/"
			end

			return rules:TestItemAttribute("itemString", ruleArguments, "string,number", "contains")
		end,
		-- Templates come from localization.
	},


	-- We're not parsing tooltips to get item stats.
	{
		functionNames = {
			"ItemStat",
			"ItemStatActive"
		},
		ruleFunction = function(rules, ruleArguments)
			rules.errorMessage = L.Error_Rule_ItemStat
			return false
		end,
		hideFromUi = true,
	},


	-- Player is the master looter.
	{
		functionNames = {
			"LootMaster",
		},
		ruleFunction = function(rules, ruleArguments)
			return BsGameInfo.isMasterLooter
		end,
		-- This is hidden and rolled into the templates for LootMethod().
		hideFromUi = true,
	},


	-- Loot method matches the given string.
	{
		functionNames = {
			"LootMethod",
			"LootMode",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestValue(BsGameInfo.lootMethod, ruleArguments)
		end,
		-- Templates come from localization.
	},


	-- Item matches another category.
	-- This is one of the most complex rule functions because it's critical to avoid
	-- a loop where category 1 wants to match 2 which wants to match 1. To make this
	-- work requires cooperation from the Categories and Rules classes to help manage
	-- the call stack tracking (`Rules._matchCategory_callStack`) and other aspects.
	{
		functionNames = {
			"MatchCategory",
			"Match",
		},
		ruleFunction = function(rules, ruleArguments)
			rules:RequireArguments(ruleArguments)

			-- Set up special table for loop prevention.
			-- Managed here and in:
			-- - Categories:MatchCategory()
			-- - Rules:Match()
			if not rules._matchCategory_callStack then
				rules._matchCategory_callStack = {}
			end

			-- This controls which property on the `rules` object error messages
			-- get stored in. By default we assume we're inside a stack of
			-- `MatchCategory()` rule function calls and so we assume we'll need
			-- to use the special property that will be picked up at the end
			-- of this function.
			local errorProperty = "_matchCategory_errorMessage"
			-- When the call stack is empty, this is the originating category,
			-- and any errors belong to it.
			if table.getn(rules._matchCategory_callStack) == 0 then
				errorProperty = "errorMessage"
				rules._matchCategory_errorMessage = nil
				-- Store the ID of the category that started this.
				-- Used by the Categories class to track which categories have MatchCategory() rules.
				if rules.currentCategoryId then
					rules._matchCategory_originalCaller = rules.currentCategoryId
				end
			end

			-- Try to match categories.
			for _, categoryId in ipairs(ruleArguments) do
				-- Custom category IDs are numeric and built-ins are strings, so anything
				-- that converts to a number should be treated as such.
				categoryId = tonumber(categoryId) or categoryId

				-- Check potential error conditions before allowing the Categories:MatchCategory() call to proceed.
				if BsUtil.TableContainsValue(rules._matchCategory_callStack, categoryId) then
					-- We've seen this category ID before, so stop before we overflow the call stack.
					-- Build out the error message so it shows the dependency list: ID1 → ID2 → ID1.
					rules[errorProperty] =
						BsUtil.Trim(L.Error_Rule_MatchCategory_Loop)
						.. " " .. table.concat(rules._matchCategory_callStack, " → ")
						.. " → " .. categoryId
					return false

				elseif BsCategories.errors[categoryId] then
					-- The category referenced by this one has an error, so evaluation can't continue.
					rules[errorProperty] = string.format(L.Error_Rule_MatchCategory_DownstreamError, categoryId)
					return false
				end

				-- Make the real MatchCategory() call.
				if BsCategories:MatchCategory(categoryId, rules.item, rules.character, rules.currentSession, true) then
					return true
				end

			end

			-- We want to lift the error message from the depths of the call stack and
			-- only return it for the category at the top.
			if errorProperty == "errorMessage" then
				rules[errorProperty] = rules._matchCategory_errorMessage
			end

			return false
		end,
		-- Templates come from localization.
	},


	-- Item is usable by the current character based on the item's minimum level requirement.
	{
		functionNames = {
			"MinLevel",
			"ireq",
			"ItemLevelUse",
			"lvl",
			"ReqLevel",
			"UseLevel",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Passing true for the last parameter so that MinLevel(5) will match >= 5 (infinite upper bound if table.getn(ruleArguments) == 1)
			return rules:TestItemAttribute("minLevel", ruleArguments, nil, "between", nil, true)
		end,
		-- Templates come from localization.
	},


	-- Item is in the specified inventory location.
	{
		functionNames = {
			"Location",
			"InventoryType",
			"loc",
		},
		ruleFunction = function(rules, ruleArguments)
			rules:RequireArguments(ruleArguments)
			for i, arg in ipairs(ruleArguments) do
				arg = string.lower(arg)
				if arg == string.lower(L[BS_INVENTORY_TYPE.BAGS]) or arg == "bags" or arg == "bag" then
					ruleArguments[i] = BS_INVENTORY_TYPE.BAGS
				elseif arg == string.lower(L[BS_INVENTORY_TYPE.BANK]) or arg == "bank" then
					ruleArguments[i] = BS_INVENTORY_TYPE.BANK
				elseif arg == string.lower(L[BS_INVENTORY_TYPE.KEYRING]) or arg == "keyring" or arg == "keychain" or arg == "keys" then
					ruleArguments[i] = BS_INVENTORY_TYPE.KEYRING
				end
			end
			return rules:TestItemAttribute("bagshuiInventoryType", ruleArguments)
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Item name match (partial allowed).
	{
		functionNames = {
			"Name",
			"n",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestItemAttribute("name", ruleArguments, nil, "contains")
		end,
		-- Templates come from localization.
	},


	-- Item name exact match.
	{
		functionNames = {
			"NameExact",
			"ne",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestItemAttribute("name", ruleArguments)
		end,
		-- Templates come from localization.
	},


	-- Item can be opened.
	{
		functionNames = {
			"Openable",
			"Locked",
			"Opens",
			"Pickable",
		},
		ruleFunction = function(rules, ruleArguments)
			if table.getn(ruleArguments) > 0 then
				if ruleArguments[1] then
					return rules.item.lockPickable == 1
				else
					return rules.item.openable == 1
				end
			else
				return rules.item.openable == 1 or rules.item.lockPickable == 1
			end
		end,
		environmentVariables = {
			Locked = true,
			NotLocked = false,
			Unlocked = false,
		},
		-- Templates come from localization.
	},


	-- Outfit() stub -- needs to be replaced by another function.
	-- Stubs current
	{
		functionNames = {
			"Outfit",
		},
		ruleFunction = function(rules, ruleArguments)
			rules.errorMessage = string.format(L.Error_AddonDependency_Generic_FunctionName, "Outfit()")
			return false
		end,
		replaceable = true,
		ruleTemplates = {
			{
				code = GRAY_FONT_COLOR_CODE .. "Outfit()" .. FONT_COLOR_CODE_CLOSE,
				description = RED_FONT_COLOR_CODE .. L.Error_AddonDependency_Generic .. FONT_COLOR_CODE_CLOSE
			}
		},
		-- Templates are defined in localization.
		-- Replacement function should supply `ruleFunctionTemplateFormatStrings`;
		-- (see ItemRack just below for an example).
	},


	-- ItemRack set.
	{
		functionNames = {
			"Outfit",
			"ItemRack",
			"Outfit_ItemRack",
		},
		conditional = function()
			return _G.IsAddOnLoaded("ItemRack")
		end,
		ruleFunction = function(rules, ruleArguments)
			if not _G.IsAddOnLoaded("ItemRack") then
				rules.errorMessage = string.format(L.Error_AddonDependency, "ItemRack")
				return false
			end

			if not rules.item.itemLink then
				return false
			end

			-- Here's a sample of the relevant parts of the data structure we're expecting to process:
			-- ```
			-- Rack_User = {
			-- 	["<Name> of <Realm>"] = {
			-- 		["Sets"] = {
			-- 			["Test"] = {
			-- 				[0] = {
			-- 					["id"] = "2516:0:0",
			-- 					["name"] = "Light Shot",
			-- 				},
			-- 				[1] = {
			-- 					["id"] = "14566:0:0",
			-- 					["name"] = "Prospector's Pads",
			-- 				},
			-- 				["icon"] = "Interface\\Icons\\Spell_Nature_NullWard",
			-- 			},
			-- 			["Rack-CombatQueue"] = {
			-- 				[1] = {
			-- 				},
			-- 				[0] = {
			-- 				},
			-- 			},
			-- 		},
			-- 	},
			-- }
			-- ```

			local itemRackUser = _G.Rack_User[rules.character.name .. " of " .. rules.character.realm]
			if type(itemRackUser) ~= "table" then
				return false
			end

			local itemRackOutfits = itemRackUser.Sets
			if type(itemRackOutfits) ~= "table" then
				return false
			end

			-- Parsing into distinct codes instead of using ItemRack's "code:enchantCode:subCode"
			-- ID format so we can ignore enchant codes.
			local found , _, code, enchantCode, subCode = string.find(rules.item.itemLink or "", "item:(%d+):(%d+):(%d+)")
			if not found then
				return false
			end
			-- Pattern to ignore enchant codes.
			local itemRackIdMatch = code .. ":%d+:" .. subCode

			local matchAny = (table.getn(ruleArguments) == 0)

			for outfitName, outfitItems in pairs(itemRackOutfits) do
				local outfitName = string.lower(BsUtil.Trim(outfitName))
				for _, item in pairs(outfitItems) do
					-- Type check is needed here because ItemRack stores the outfit icon as a string at the same level.
					if type(item) == "table" and type(item.id) == "string" and (string.find(item.id, itemRackIdMatch)) then
						if matchAny then
							return true
						else
							for _, outfitToMatch in ipairs(ruleArguments) do
								if string.lower(BsUtil.Trim(outfitToMatch)) == outfitName then
									return true
								end
							end
						end
					end
				end
			end

			return false

		end,
		-- Templates come from localization and need a substitution string.
		ruleFunctionTemplateFormatStrings = {
			"ItemRack"
		}
	},


	-- Outfitter set.
	{
		functionNames = {
			"Outfit",
			"Outfitter",
			"Outfit_Outfitter",
		},
		conditional = function()
			return _G.IsAddOnLoaded("Outfitter")
		end,
		ruleFunction = function(rules, ruleArguments)
			if not _G.IsAddOnLoaded("Outfitter") then
				rules.errorMessage = string.format(L.Error_AddonDependency, "Outfitter")
				return false
			end

			-- Extra check to make sure Outfitter is ready to go.
			if not _G.Outfitter_IsInitialized and _G.Outfitter_IsInitialized() then
				return false
			end

			if not rules.item.itemLink then
				return false
			end

			-- Here's a sample of the relevant parts of the data structure we're expecting to process:
			-- gOutfitter_Settings = {
			-- 	["Outfits"] = {
			-- 		["Partial"] = {
			-- 		},
			-- 		["Accessory"] = {
			-- 		},
			-- 		["Special"] = {
			-- 			[1] = {
			-- 				["Items"] = {},  -- Snipped
			-- 				["StatID"] = "ArgentDawn",
			-- 				["Name"] = "Argent Dawn",
			-- 				["CategoryID"] = "Special",
			-- 				["SpecialID"] = "ArgentDawn",
			-- 			},
			-- 		},
			-- 		["Complete"] = {
			-- 			[1] = {
			-- 				["Items"] = {},
			-- 				["CategoryID"] = "Complete",
			-- 				["Name"] = "Birthday Suit",
			-- 			},
			-- 			[2] = {
			-- 				["Items"] = {},
			-- 				["CategoryID"] = "Complete",
			-- 				["Name"] = "Normal",
			-- 			},
			-- 			[3] = {
			-- 				["Items"] = {
			-- 					["ShoulderSlot"] = {
			-- 						["Name"] = "Prospector's Pads",
			-- 						["Code"] = 14566,
			-- 						["SubCode"] = 0,
			-- 						["EnchantCode"] = 0,
			-- 					},
			-- 					["AmmoSlot"] = {
			-- 						["Name"] = "Light Shot",
			-- 						["Code"] = 2516,
			-- 						["SubCode"] = 0,
			-- 						["EnchantCode"] = 0,
			-- 					},
			-- 				},
			-- 				["CategoryID"] = "Complete",
			-- 				["Name"] = "Test",
			-- 			},
			-- 		},
			-- 	},
			-- 	["HideHelm"] = {
			-- 	},
			-- 	["HideCloak"] = {
			-- 	},
			-- }

			-- gOutfitter_Settings is NOT a typo!
			local outfitterOutfits = _G.gOutfitter_Settings.Outfits
			if type(outfitterOutfits) ~= "table" then
				return false
			end

			-- Not using `Outfitter_GetItemInfoFromLink` because it generates throwaway
			-- tables and will make the garbage collector upset.
			local found , _, code, enchantCode, subCode = string.find(rules.item.itemLink or "", "item:(%d+):(%d+):(%d+)")
			if not found then
				return false
			end

			local matchAny = (table.getn(ruleArguments) == 0)

			for outfitType, outfits in pairs(outfitterOutfits) do
				for outfitId, outfit in pairs(outfits) do
					local outfitName = string.lower(BsUtil.Trim(outfit.Name))
					for slot, item in pairs(outfit.Items) do
						if
							item.Code == tonumber(code)
							and item.SubCode == tonumber(subCode)
							-- False positives seem preferable to false negatives?
							-- Replicating exactly what Outfitter does in terms of
							-- when it decides to do fuzzy matching and ignore
							-- enchants would require more work than I'm currently
							-- willing to put in. Always ignoring enchants will at
							-- least ensure that items are matched more permissively.
							-- 
							-- and item.EnchantCode == tonumber(enchantCode)
						then
							if matchAny then
								return true
							else
								for _, outfitToMatch in ipairs(ruleArguments) do
									if string.lower(BsUtil.Trim(outfitToMatch)) == outfitName then
										return true
									end
								end
							end
						end
					end
				end
			end

			return false

		end,
		-- Templates come from localization and need a substitution string.
		ruleFunctionTemplateFormatStrings = {
			"Outfitter"
		}
	},


	-- Item belongs to the PeriodicTable set(s).
	{
		functionNames = {
			"PeriodicTable",
			"pt",
			"Taxonomy",
			"tx",
		},
		ruleFunction = function(rules, ruleArguments)
			if not rules.item.itemLink then
				return false
			end

			rules:RequireArguments(ruleArguments)

			for _, ptSet in ipairs(ruleArguments) do
				if Bagshui.libs.PT:ItemInSet(rules.item.itemLink, BsUtil.Trim(ptSet)) then
					return true
				end
			end
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Player is in a group.
	-- The PlayerGroup() name was chosen so there's no possibility of thinking
	-- this is somehow checking whether an item is in a layout Structure Group.
	{
		functionNames = {
			"PlayerInGroup",
			"PlayerGroup",
		},
		ruleFunction = function(rules, ruleArguments)
			if table.getn(ruleArguments) == 0 then
				return BsGameInfo.playerGroupType ~= BS_GAME_PLAYER_GROUP_TYPE.SOLO
			else
				return rules:TestValue(BsGameInfo.playerGroupType, ruleArguments)
			end
		end,
		environmentVariables = {
			Party = BS_GAME_PLAYER_GROUP_TYPE.PARTY,
			Raid = BS_GAME_PLAYER_GROUP_TYPE.RAID,
		},
		-- Templates come from localization.
	},


	-- Item is crafted by a learned profession recipe.
	{
		functionNames = {
			"ProfessionCraft",
			"pc",
			"TradeskillCraft",
			"tsc",
		},
		ruleFunction = function(rules, ruleArguments)
			return BsCharacter:TestItem(rules.item.id, rules.character.professionCrafts, ruleArguments)
		end,
		-- Templates come from localization.
	},


	-- Item is a reagent for a learned profession recipe.
	{
		functionNames = {
			"ProfessionReagent",
			"pr",
			"TradeskillReagent",
			"tsr",
		},
		ruleFunction = function(rules, ruleArguments)
			return BsCharacter:TestItem(rules.item.id, rules.character.professionReagents, ruleArguments)
		end,
		-- Templates come from localization.
	},


	-- Item is of the specified quality.
	{
		functionNames = {
			"Quality",
			"q",
			"Rarity",
		},
		ruleFunction = function(rules, ruleArguments)
			return
				rules:TestItemAttribute("quality", ruleArguments, "string,number")
				or rules:TestItemAttribute("qualityLocalized", ruleArguments, "string,number")
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Item stock state has changed.
	{
		functionNames = {
			"RecentlyChanged",
			"Changed",
			"rc",
		},
		ruleFunction = function(rules, ruleArguments)
			if table.getn(ruleArguments) == 0 then
				return rules.item.bagshuiStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE
			else
				return rules:TestItemAttribute("bagshuiStockState", ruleArguments)
			end
		end,
		environmentVariables = {
			New = BS_ITEM_STOCK_STATE.NEW,
			Up = BS_ITEM_STOCK_STATE.UP,
			Down = BS_ITEM_STOCK_STATE.DOWN,
		},
		-- Template come from localization.
	},


	-- Does the tooltip contain "Class: <Class Name>"?
	{
		functionNames = {
			"RequiresClass",
			"Class",
			"AllowedClass",
			"rq",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Reusable table parameter to avoid activating garbage collection.
			if not rules._requiresClass_Tooltip then
				-- Normal and localized class names.
				rules._requiresClass_Tooltip = { "", "" }
				-- Need slashes to active pattern matching.
				rules._requiresClass_BasePattern = "/" .. _G.ITEM_CLASSES_ALLOWED .. "/"
			end

			rules:RequireArguments(ruleArguments)

			for _, arg in ipairs(ruleArguments) do
				-- Wrapping the class name in a frontier pattern for word boundary matching.
				-- This allows for safely matching things like "Classes: Hunter, Rogue, Mage".
				rules._requiresClass_Tooltip[1] = string.format(rules._requiresClass_BasePattern, ".*%f[%a]" .. arg .. "%f[%A].*")
				rules._requiresClass_Tooltip[2] = string.format(rules._requiresClass_BasePattern, ".*%f[%a]" .. (BsGameInfo.lowercaseToNormalCaseLocalizedCharacterClasses[string.lower(arg)] or arg) .. "%f[%A].*")
				if rules:Rule_Tooltip(rules._requiresClass_Tooltip) then
					return true
				end
			end
			return false
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Item is soulbound.
	{
		functionNames = {
			"Soulbound",
			"sb",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Reusable table parameter to avoid activating garbage collection.
			if not rules._soulbound_Tooltip then
				rules._soulbound_Tooltip = { _G.ITEM_SOULBOUND }
			end
			return rules:Rule_Tooltip(rules._soulbound_Tooltip)
		end,
		-- Templates come from localization.
	},


	-- Item is allowed to stack.
	{
		functionNames = {
			"Stacks",
			"st",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Reusable table parameter to avoid activating garbage collection.
			if not rules._stacks_Minimum then
				rules._stacks_Minimum = { 2 }
			end
			-- Passing true for the last parameter so that Stacks() will match >= 2
			-- (infinite upper bound if table.getn(ruleArguments) == 1).
			return rules:TestItemAttribute("maxStackCount", rules._stacks_Minimum, nil, "between", nil, true)
		end,
		-- Templates come from localization.
	},


	-- Item subtype match.
	{
		functionNames = {
			"Subtype",
			"sty",
			"stype",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Final parameter is true to allow matches via localization of arguments.
			return rules:TestItemAttribute("subtype", ruleArguments, nil, nil, nil, nil, true)
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Current subzone.
	{
		functionNames = {
			"Subzone",
			"sz",
		},
		ruleFunction = function(rules, ruleArguments)
			return (
				rules:TestValue(BsGameInfo.currentSubZone, ruleArguments, nil, BS_RULE_MATCH_TYPE.CONTAINS, nil, nil, true)
				or rules:TestValue(BsGameInfo.currentMinimapZone, ruleArguments, nil, BS_RULE_MATCH_TYPE.CONTAINS, nil, nil, true)
			)
		end,
		-- Template come from localization.
	},


	-- Tooltip contains the given string.
	{
		functionNames = {
			"Tooltip",
			"tt",
		},
		ruleFunction = function(rules, ruleArguments)
			return rules:TestItemAttribute("tooltip", ruleArguments, "string", "contains")
		end,
		-- Templates come from localization.
	},


	-- Transmog() stub.
	{
		functionNames = {
			"Transmog",
		},
		ruleFunction = function(rules, ruleArguments)
			rules.errorMessage = string.format(L.Error_AddonDependency_Generic_FunctionName, "Transmog()")
			return false
		end,
		ruleTemplates = {
			{
				code = GRAY_FONT_COLOR_CODE .. "Transmog()" .. FONT_COLOR_CODE_CLOSE,
				description = RED_FONT_COLOR_CODE .. L.Error_AddonDependency_Generic .. FONT_COLOR_CODE_CLOSE
			}
		},
		replaceable = true,
	},

	-- Item type match.
	{
		functionNames = {
			"Type",
			"ty",
		},
		ruleFunction = function(rules, ruleArguments)
			-- Final parameter is true to allow matches via localization of arguments
			return rules:TestItemAttribute("type", ruleArguments, nil, nil, nil, nil, true)
		end,
		-- Template are autogenerated in RuleFunctionTemplates.lua.
	},


	-- Item is usable by the current character.
	{
		functionNames = {
			"Usable",
			"u",
			"Useable",
		},
		ruleFunction = function(rules, ruleArguments)
			return BsItemInfo:IsUsable(rules.item)
		end,
		-- Templates come from localization.
	},


	-- Gray items.
	-- It would be possible to extend this with more intelligent junk identification
	-- in the future by tapping into data from other addons.
	-- To turn this into a stub, alias support for stubs would need to be added.
	{
		functionNames = {
			"Trash",
			"Junk",
		},
		hideFromUi = true,
		ruleFunction = function(rules, ruleArguments)
			if not rules._trashQuality then
				rules._trashQuality = {0}
			end
			return rules:Rule_Quality(rules._trashQuality)
		end,
		-- Templates come from localization.
	},


	-- Wishlist() stub.
	{
		functionNames = {
			"Wishlist",
		},
		ruleFunction = function(rules, ruleArguments)
			rules.errorMessage = string.format(L.Error_AddonDependency_Generic_FunctionName, "Wishlist()")
			return false
		end,
		ruleTemplates = {
			{
				code = GRAY_FONT_COLOR_CODE .. "Wishlist()" .. FONT_COLOR_CODE_CLOSE,
				description = RED_FONT_COLOR_CODE .. L.Error_AddonDependency_Generic .. FONT_COLOR_CODE_CLOSE
			}
		},
		replaceable = true,
		-- Templates are defined in localization.
		-- Replacement function should supply `ruleFunctionTemplateFormatStrings`;
		-- (see ItemRack just below for an example).
	},


	-- AtlasLoot wishlist -- replaces Wishlist() when AtlasLoot is available.
	{
		functionNames = {
			"Wishlist",
			"AtlasLootWish",
			"Wishlist_AtlasLoot",
			"Wish",
		},
		conditional = function()
			return _G.IsAddOnLoaded("AtlasLoot")
		end,
		ruleFunction = function(rules, ruleArguments)
			if not _G.IsAddOnLoaded("AtlasLoot") then
				rules.errorMessage = string.format(L.Error_AddonDependency, "AtlasLoot")
				return false
			end

			if not rules.item.itemLink then
				return false
			end

			-- Here's a sample of the relevant parts of the data structure we're expecting to process:
			-- ```
			-- _G.AtlasLootCharDB.WishList = {
			-- 	[1] = {
			-- 		[1] = 19346,
			-- 		[2] = "INV_Weapon_Shortblade_29",
			-- 		[3] = "=q4=Dragonfang Blade",
			-- 		[4] = "=ds=#h1#, #w4#",
			-- 		[5] = "BWLVaelastrasz|AtlasLootItems",
			-- 	},
			-- 	[2] = {
			-- 		[1] = 19395,
			-- 		[2] = "INV_Misc_Gem_Topaz_02",
			-- 		[3] = "=q4=Rejuvenating Gem",
			-- 		[4] = "=ds=#s14#",
			-- 		[5] = "BWLEbonroc|AtlasLootItems",
			-- 	},
			-- },
			-- ```

			if type(_G.AtlasLootCharDB) ~= "table" then
				return false
			end
			if type(_G.AtlasLootCharDB.WishList) ~= "table" then
				return false
			end

			for _, itemInfo in ipairs(_G.AtlasLootCharDB.WishList) do
				if type(itemInfo) == "table" and itemInfo[1] == rules.item.id then
					return true
				end
			end

			return false

		end,
		-- Templates come from localization and need a substitution string.
		ruleFunctionTemplateFormatStrings = {
			"AtlasLoot"
		}
	},


	-- Current zone.
	{
		functionNames = {
			"Zone",
			"z",
		},
		ruleFunction = function(rules, ruleArguments)
			return (
				rules:TestValue(BsGameInfo.currentZone, ruleArguments, nil, BS_RULE_MATCH_TYPE.CONTAINS, nil, nil, true)
				or rules:TestValue(BsGameInfo.currentRealZone, ruleArguments, nil, BS_RULE_MATCH_TYPE.CONTAINS, nil, nil, true)
			)
		end,
		-- Template come from localization.
	},

}


end)