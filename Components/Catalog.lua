-- Bagshui Catalog
-- Exposes: BsCatalog (and Bagshui.components.Catalog)
--
-- Account-wide index of all characters' inventories.
-- Everything is calculated at runtime from what's in SavedVariables.
--
-- Init() takes care of calculations for character other than the current one,
-- while Update() handles the current character and grand totals.


Bagshui:AddComponent(function()


Bagshui:AddConstants({
	BS_CATALOG_LOCATIONS = {
		EQUIPPED = "Equipped",  -- This needs to match the Abbrev_[value] localization.
		MONEY = "$$$",
	},
})

-- Table key for totals and prefix for subtotals.
local TOTAL_KEY = "==Total"

-- Money storage.
local MONEY_ITEM = {
	itemString = BS_CATALOG_LOCATIONS.MONEY,
	count = 0,
}

-- Key suffixes for subtotals.
local SUBTOTAL_TYPE = {
	Current = "Current",
	Other = "Other",
}

-- How much to indent each tooltip line.
local TOOLTIP_INDENT = "  "




local Catalog = {
	-- Array of the item info tables of all items on the account, sorted by name.
	items = {},

	-- Calculation results as produced by `BuildIndex()` and `Update()`.
	-- Structure:
	-- ```
	-- {
	--  	-- Overall account-wide totals.
	--  	["==Total"] = { <itemString> => <count> },
	--  	-- Current character totals (will be the same as the realm-level total, obviously).
	--  	["==TotalCurrent"] = { <itemString> => <count> },
	--  	-- Other character totals.
	--  	["==TotalOther"] = { <itemString> => <count> },
	--  	-- Each realm will have an entry.
	--  	["realm1"] = {
	--  		-- Overall realm-wide totals.
	--  		["==Total"] = { <itemString> => <count> },
	--  		-- Current character realm-level totals.
	--  		["==TotalCurrent"] = { <itemString> => <count> },
	--  		-- Other character realm-level totals.
	--  		["==TotalOther"] = { <itemString> => <count> },
	--  		-- Class-colored character name with faction appended.
	--  		["_formattedCharacterNames"] = { <characterName> => <formattedCharacterName> },
	--  		-- Characters on this realm, sorted alphabetically.
	--  		["_sortedCharacterList"] = { "characterName1", "characterName2", ... },
	--  		-- Each character will have an entry.
	--  		["characterName1"] = { <itemString> => <count> },
	--  	},
	-- }
	-- ```
	totals = {},

	-- Arrays of item tables that can later be iterated during calculations of totals.
	-- There isn't an `all` entry here because that's `self.items`.
	itemListTables = {
		currentCharacter = {},
		otherCharacter = {},
	},

	-- Array of locations where items are stored (BS_INVENTORY_TYPE_UI_ORDER followed by EQUIPPED).
	-- Iterated to build per-character tooltips.
	itemLocations = {},

	-- List of realms, sorted alphabetically.
	sortedRealmList = {},

	-- Reusable table for calculating per-location totals for each character.
	-- ```
	-- {
	--  	<itemLocation> = { <itemString> => <count> }
	-- }
	-- ```
	tempItemCounts = {},

	-- Tooltips for items from other characters need to be reloaded during `Update()`.
	tooltipUpdateNeeded = true,

	-- Has `Init()` finished?
	initialized = false,

}
Bagshui.environment.BsCatalog = Catalog
Bagshui.components.Catalog = Catalog



--- Event processing.
---@param event string WoW API event
---@param arg1 any First event argument.
function Catalog:OnEvent(event, arg1)
	-- Bagshui:PrintDebug("Catalog event " .. event)

	-- Initial processing at startup. Delayed since it's not needed immediately.
	-- Other update events are allowed to delay initial processing even further.
	if event == "PLAYER_ENTERING_WORLD" or not self.initialized then
		-- This check is duplicated in Catalog:Init() but let's be extra safe.
		if not self.initialized then
			Bagshui:QueueClassCallback(self, self.Init, 3)
		end
		return
	end

	if event == "BAGSHUI_CHARACTER_UPDATE" then
		-- Refresh the current character's name as we may now have more data.
		self:StoreFormattedCharacterName(Bagshui.currentCharacterId, Bagshui.currentCharacterData.info)
		return
	end

	if event == "BAGSHUI_CHARACTER_LEARNED_RECIPE" then
		-- Learning a new recipe requires updating tooltips for items from other characters.
		self.tooltipUpdateNeeded = true
	end

	if event == "BAGSHUI_CATALOG_SHOULD_UPDATE" then
		-- We've received the delayed event to trigger the update.
		self:Update()
		return
	end

	-- Any other event requires an update after a delay.
	Bagshui:QueueEvent("BAGSHUI_CATALOG_SHOULD_UPDATE", 0.75)
end



--- Initialize the Catalog class.
--- Also calculates item totals for all characters other than the current one.
function Catalog:Init()
	-- Bagshui:PrintDebug("Catalog Init()")

	-- Safeguard just in case. Without this, if Init() is called multiple times
	-- then the list of characters will be duplicated and tooltips will look weird.
	if self.initialized then
		return
	end

	-- Initialize storage tables.

	for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
		table.insert(self.itemLocations, inventoryType)
	end
	for _, itemLocation in pairs(BS_CATALOG_LOCATIONS) do
		table.insert(self.itemLocations, itemLocation)
	end

	for _, inventoryType in ipairs(self.itemLocations) do
		self.tempItemCounts[inventoryType] = {}
	end

	self:CreateTotalKeys(self.totals)


	-- Process all characters in SavedVariables.
	for characterId, data in pairs(Bagshui.characters) do

		-- Make sure it's a fully formed character.
		if data.info and data.info.name then

			local realm = data.info.realm

			-- Initialize realm storage table.
			if not self.totals[realm] then
				table.insert(self.sortedRealmList, realm)
				self.totals[realm] = {
					_sortedCharacterList = {},
					_formattedCharacterNames = {},
				}
				self:CreateTotalKeys(self.totals[realm])
			end

			-- Store data about this character that will be needed later.
			table.insert(self.totals[realm]._sortedCharacterList, data.info.name)
			self:StoreFormattedCharacterName(characterId, data.info)

			-- Update() will take calculations for the current character, so Init() only needs to handle others.
			if characterId ~= Bagshui.currentCharacterId then
				self:CalculatePerCharacterTotal(
					characterId,
					data,
					self.itemListTables.otherCharacter
				)
			end

			-- Ensure all items are known so tooltips will load immediately.
			for _, item in ipairs(self.itemListTables.otherCharacter) do
				BsItemInfo:LoadItemIntoLocalGameCache(item.itemString)
			end

		end
	end

	-- Produce subtotals for all characters other than the current one.
	self:CalculateSubtotals(self.itemListTables.otherCharacter, SUBTOTAL_TYPE.Other)

	-- Character and realm lists only need to be sorted once because they can't change without logging out.
	table.sort(self.sortedRealmList)
	for _, realm in ipairs(self.sortedRealmList) do
		table.sort(self.totals[realm]._sortedCharacterList)
	end

	-- Get current character data and calculate totals.
	self:Update()

	-- Register slash command.
	BsSlash:AddOpenCloseHandler("Catalog", self)

	-- Allow events to be processed normally.
	self.initialized = true
end



--- Sort an array of item tables alphabetically by name.
---@param a table
---@param b table
---@return boolean
local function sortItemList(a, b)
	return (a.name or "") < (b.name or "")
end



--- Refresh item counts and totals for the current character, then refresh overall totals.
function Catalog:Update()
	-- Bagshui:PrintDebug("Catalog:Update() - tooltips? " .. tostring(self.tooltipUpdateNeeded))

	-- Reset existing grand totals and current character subtotals.
	BsUtil.TableClear(self.totals[TOTAL_KEY])
	for _, realm in ipairs(self.sortedRealmList) do
		BsUtil.TableClear(self.totals[realm][TOTAL_KEY])
	end
	BsUtil.TableClear(self.totals[self:TotalKey(SUBTOTAL_TYPE.Current)])
	for _, realm in ipairs(self.sortedRealmList) do
		BsUtil.TableClear(self.totals[realm][self:TotalKey(SUBTOTAL_TYPE.Current)])
	end

	-- Wipe the item tracking table so `AddToItemTable()` will work.
	BsUtil.TableClear(self.itemListTables.currentCharacter)

	-- Get the item counts for the current character.
	self:CalculatePerCharacterTotal(
		Bagshui.currentCharacterId,
		Bagshui.currentCharacterData,
		self.itemListTables.currentCharacter
	)

	-- Calculate subtotals for current character.
	self:CalculateSubtotals(self.itemListTables.currentCharacter, SUBTOTAL_TYPE.Current)

	-- Build unique, sorted list of all items on the account.
	BsUtil.TableClear(self.items)
	for _, itemTable in pairs(self.itemListTables) do
		for _, item in ipairs(itemTable) do
			if type(item.id) == "number" and item.id > 0 then
				-- Refresh the tooltip for items belonging to other characters so
				-- the Catalog will accurately indicate whether the current
				-- character can use the item.
				if
					self.tooltipUpdateNeeded
					and itemTable ~= self.itemListTables.currentCharacter
				then
					-- 3nd parameter: Force tooltip loading to use itemString
					-- instead of bagNum/slotNum, since those are for other
					-- characters in this context and will lead to pulling
					-- the wrong tooltip.
					BsItemInfo:GetTooltip(item, nil, true)
				end
				self:AddToItemTable(item, self.items)
			end
		end
	end
	table.sort(self.items, sortItemList)

	-- Combine totals from current character and other characters.
	self:CalculateGrandTotals()

	-- Refresh the account-wide search if it's visible.
	if self.objectManager and self.objectManager.uiFrame:IsVisible() then
		self.objectManager:UpdateList()
	end

	-- Reset flag.
	self.tooltipUpdateNeeded = false
end



--- Iterate a character's item storage locations and collect sums of each item.
--- Totals are calculated at the item, character, and realm level.
---@param characterId string Unique ID of the character being analyzed. This is generated by Bagshui on startup and housed in the `Bagshui.currentCharacterId` property. It is also the key for each character in the SavedVariables `characters` table.
---@param characterData table Character's table from the SavedVariables `characters` table.
---@param itemTable table Array that will be filled with the unique list of all items belonging to this character.
function Catalog:CalculatePerCharacterTotal(characterId, characterData, itemTable)
	assert(type(characterData) == "table", "Catalog:CalculatePerCharacterTotal() - characterData must be a table")
	assert(type(characterData.realm) == "string", "Catalog:CalculatePerCharacterTotal() - characterData.realm is required")

	local storage = self.totals[characterData.info.realm]
	local storageSuffix = (characterId == Bagshui.currentCharacterId and SUBTOTAL_TYPE.Current or SUBTOTAL_TYPE.Other)

	BsUtil.TableClear(storage[self:TotalKey(characterData.info.name)])  -- Reset the storage for this character.
	for _, inventoryType in ipairs(self.itemLocations) do
		BsUtil.TableClear(self.tempItemCounts[inventoryType])  -- Used by AddToItemTotal().
	end

	-- Normal inventory locations (Bags, Bank, etc.).
	for _, inventoryType in pairs(BS_INVENTORY_TYPE) do
		local inventoryTypeStorageKey = BsUtil.LowercaseFirstLetter(inventoryType)
		if characterData[inventoryTypeStorageKey] and characterData[inventoryTypeStorageKey].inventory then
			for bagNum, contents in pairs(characterData[inventoryTypeStorageKey].inventory) do
				for slotNum, item in ipairs(contents) do
					if item.emptySlot ~= 1 then
						self:AddItemToSubtotals(
							item,
							storage,
							storageSuffix,
							characterId,
							characterData,
							itemTable,
							inventoryType
						)
					end
				end
			end
		end
	end

	-- Equipped items.
	if type(characterData.info.equipped) == "table" then
		for slot, item in pairs(characterData.info.equipped) do
			self:AddItemToSubtotals(
				item,
				storage,
				storageSuffix,
				characterId,
				characterData,
				itemTable,
				BS_CATALOG_LOCATIONS.EQUIPPED
			)
		end
	end

	-- Money.
	if type(characterData.info.money) == "number" then
		MONEY_ITEM.count = characterData.info.money
		self:AddItemToSubtotals(
			MONEY_ITEM,
			storage,
			storageSuffix,
			characterId,
			characterData,
			itemTable,
			BS_CATALOG_LOCATIONS.MONEY
		)
	end

	-- Instead of building out tooltip strings when the tooltip is requested,
	-- we're just going to pre-build them.
	-- The goal is to come out with something like "Bags: 3" or "Bags: 2 + Bank 5 = 7".

	local tooltipString, multipleLocations, lastCount

	for itemString, totalCount in pairs(storage[self:TotalKey(characterData.info.name)]) do
		tooltipString = ""
		multipleLocations = false

		-- self.itemLocations provides the correct order for the inventory locations.
		for _, inventoryType in ipairs(self.itemLocations) do

			-- tempItemCounts was populated by `AddItemToSubtotals()` during the loops above.
			if self.tempItemCounts[inventoryType][itemString] then

				-- Add a separator if this item is found in more than one location.
				if string.len(tooltipString) > 0 then
					tooltipString = tooltipString .. GRAY_FONT_COLOR_CODE .. " + " .. FONT_COLOR_CODE_CLOSE
					multipleLocations = true
				end

				-- When there are not multiple locations for an item, this information will be used to recolor the number
				-- so that "Bags: 3" has a white 3 just like "Bags: 2 + Bank 5 = 7" will have a white 7.
				lastCount = self.tempItemCounts[inventoryType][itemString]

				if
					inventoryType == BS_CATALOG_LOCATIONS.MONEY
					and itemString == BS_CATALOG_LOCATIONS.MONEY
				then
					-- Money is a little weird in that it's shoehorned into the catalog in a special location that
					-- only contains the money itemString, so when we see it, we know that this is not a tooltip
					-- that needs to be built up from multiple locations; it's just a money string.
					tooltipString = BsUtil.FormatMoneyString(lastCount)
					break

				else
					tooltipString =
						tooltipString
						.. string.format(L.Symbol_Colon, (L_nil["Abbrev_" .. inventoryType] or L[inventoryType])) .. " "
						.. lastCount
				end
			end
		end

		-- Final touches -- either add the sum at the end or recolor the number.
		if multipleLocations then
			tooltipString =
				tooltipString
				.. GRAY_FONT_COLOR_CODE .. " = " .. FONT_COLOR_CODE_CLOSE
				.. HIGHLIGHT_FONT_COLOR_CODE .. totalCount .. FONT_COLOR_CODE_CLOSE
		else
			tooltipString = string.gsub(tooltipString, lastCount .. "$", HIGHLIGHT_FONT_COLOR_CODE .. lastCount .. FONT_COLOR_CODE_CLOSE)
		end

		-- Overwrite the existing total count with the tooltip string since we have no other use for the per-character total.
		storage[self:TotalKey(characterData.info.name)][itemString] = tooltipString
	end

end



--- Add up per-realm subtotals of a given type into an account-wide subtotal.
---@param uniqueItemList table Deduplicated list of items.
---@param subtotalType string `SUBTOTAL_TYPE` value.
function Catalog:CalculateSubtotals(uniqueItemList, subtotalType)
	assert(subtotalType, "Catalog:CalculateSubtotals() - subtotalType is required")
	for _, item in ipairs(uniqueItemList) do
		for _, realm in ipairs(self.sortedRealmList) do
			self:AddToTotal(
				self.totals,
				subtotalType,
				item.itemString,
				self:GetTotal(self.totals[realm], subtotalType, item.itemString)
			)
		end
	end
end



--- Combine "current" and "other" character totals into final tallies.
function Catalog:CalculateGrandTotals()
	for _, subtotalType in pairs(SUBTOTAL_TYPE) do
		for _, realm in ipairs(self.sortedRealmList) do
			for itemString, count in pairs(self.totals[realm][self:TotalKey(subtotalType)]) do
				-- Per-realm grand total.
				self:AddToTotal(
					self.totals[realm],
					nil,
					itemString,
					count
				)
				-- Account-wide grand total.
				self:AddToTotal(
					self.totals,
					nil,
					itemString,
					count
				)
			end
		end
	end
end



--- Primary function called for each item in a character's inventory that is responsible
--- for adding it to all the various subtotal tables. This is a helper for `CalculatePerCharacterTotal()`
--- and isn't meant to be called independently because it relies on that function doing
--- the necessary prep work of clearing tables.
---@param item table Bagshui ItemInfo table.
---@param storage table Place to store the calculation results.
---@param storageSuffix string One of the SUBTOTAL_TYPE values. Controls whether the subtotals are stored in the "Current" or "Other" character bucket.
---@param characterId string Unique ID of the character.
---@param characterData table Character's table from the SavedVariables `characters` table.
---@param uniqueItemList table Array where the deduplicated list of items will be stored (see `AddToItemTable()`).
---@param inventoryType string Which location in the `self.tempItemCounts` table this item belongs to.
function Catalog:AddItemToSubtotals(item, storage, storageSuffix, characterId, characterData, uniqueItemList, inventoryType)
	if
		type(item) == "table"
		or (
			(item.id or 0) > 0
			or item.itemString == MONEY_ITEM.itemString
		)
		and (item.count or 0) > 0
	then
		-- Add to list of known items if not already present.
		-- 3rd parameter: Make a copy of the item table if this item comes from another character's
		-- cached inventory so we can manipulate it (mainly updating tooltips to get usable status)
		-- without messing up their data.
		self:AddToItemTable(item, uniqueItemList, characterId ~= Bagshui.currentCharacterId)
		-- Character total.
		self:AddToTotal(storage, characterData.info.name, item.itemString, item.count)
		-- Inventory-type total.
		self:AddToItemTotal(self.tempItemCounts[inventoryType], item.itemString, item.count)
		-- Overall subtotal.
		self:AddToTotal(storage, storageSuffix, item.itemString, item.count)
	end
end



--- Add the given item's itemString to the provided item list table, but only
--- if it hasn't already been inserted.
---@param item table Bagshui ItemInfo table.
---@param uniqueItemList any
function Catalog:AddToItemTable(item, uniqueItemList, copy)
	-- Don't duplicate.
	for _, existingItem in ipairs(uniqueItemList) do
		if existingItem.itemString == item.itemString then
			return
		end
	end

	local itemToInsert = copy and BsUtil.TableCopy(item) or item

	table.insert(uniqueItemList, itemToInsert)
end



--- Prepare the storage location, then add up the item total.
---@param storage table Place to store the calculation results.
---@param subtotalType string? `SUBTOTAL_TYPE` value, or `nil` if this is a grand total.
---@param itemString string Unique item identifier.
---@param count number Amount by which to increase this item's total.
function Catalog:AddToTotal(storage, subtotalType, itemString, count)
	if type(itemString) ~= "string" or type(count) ~= "number" then
		return
	end

	-- Ensure the storage location exists.
	local keyString = self:TotalKey(subtotalType)
	if not storage[keyString] then
		storage[keyString] = {}
	end

	self:AddToItemTotal(storage[keyString], itemString, count)
end



--- Add the given count to the given item's total.
---@param storage table Place to store the calculation results. Must be an `{ <itemString> => <count> }` table.
---@param itemString string Unique item identifier.
---@param count number Amount by which to increase this item's total.
function Catalog:AddToItemTotal(storage, itemString, count)
	if type(itemString) ~= "string" or type(count) ~= "number" then
		return
	end
	storage[itemString] = (
		storage[itemString]
		and storage[itemString] + count
		or count
	)
end



-- Reusable variable for `GetTotal()`'s key checking.
local getTotal_key

--- Pull the calculated total for the given `itemString` from the specified storage location.
---@param storage table Calculation results to query.
---@param subtotalType string? `SUBTOTAL_TYPE` value, or `nil` to get the grand total.
---@param itemString string Unique item identifier.
---@return integer count
function Catalog:GetTotal(storage, subtotalType, itemString)
	getTotal_key = self:TotalKey(subtotalType)
	return storage[getTotal_key] and storage[getTotal_key][itemString] or 0
end



--- Prepare the given storage table with keys that are known to be required.
---@param storage table Place to create keys.
function Catalog:CreateTotalKeys(storage)
	if not storage[TOTAL_KEY] then
		storage[TOTAL_KEY] = {}
	end
	for _, suffix in pairs(SUBTOTAL_TYPE) do
		local keyString = self:TotalKey(suffix)
		if not storage[keyString] then
			storage[keyString] = {}
		end
	end
end



--- Get the key for the calculation results table of the specified type. 
---@param subtotalType string? `SUBTOTAL_TYPE` value, or `nil` if this is a grand total.
---@return string key
function Catalog:TotalKey(subtotalType)
	return TOTAL_KEY .. (subtotalType or "")
end



--- Build a `<name colored by class> [<colored faction indicator]` string.
---@param characterId string Unique character identifier.
---@param characterInfo table `info` table from the character's SavedVariables data.
function Catalog:StoreFormattedCharacterName(characterId, characterInfo)
	-- Store the name per-realm since it might be possible to have the same names on different realms.
	self.totals[characterInfo.realm]._formattedCharacterNames[characterInfo.name] = BsCharacter:FormatCharacterName(characterId)
end



-- Reusable tables for storing tooltip data.
local addTooltipInfo_LeftStrings = {}
local addTooltipInfo_RightStrings = {}


--- Add counts for the given itemString to the provided tooltip.
---@param itemString string Item to gather counts for.
---@param tooltip table WoW GameTooltip object.
---@return boolean linesAdded true if one or more lines were added to the tooltip.
function Catalog:AddTooltipInfo(itemString, tooltip)
	assert(type(tooltip) == "table" and tooltip.AddDoubleLine, "Catalog:AddTooltipInfo() - tooltip must be a WoW GameTooltip object")

	-- Can't add any data until the class is up and running.
	if not self.initialized then
		return false
	end

	BsUtil.TableClear(addTooltipInfo_LeftStrings)
	BsUtil.TableClear(addTooltipInfo_RightStrings)

	-- When characters from more than one realm have the item, we'll want to add a grand total line.
	local realmsWithItems = 0

	-- Current realm always goes at the top.
	if self:GetPerRealmTooltipInfo(itemString, Bagshui.currentRealm) > 0 then
		realmsWithItems = realmsWithItems + 1
	end

	-- Now add all the other realms.
	for _, realm in ipairs(self.sortedRealmList) do
		if realm ~= Bagshui.currentRealm then
			if self:GetPerRealmTooltipInfo(itemString, realm) > 0 then
				realmsWithItems = realmsWithItems + 1
			end
		end
	end

	-- Populate the tooltip.
	if table.getn(addTooltipInfo_LeftStrings) > 0 then

		-- Grand total for multi-realm.
		if realmsWithItems > 1 then
			tooltip:AddDoubleLine(
				HIGHLIGHT_FONT_COLOR_CODE .. L.Total .. FONT_COLOR_CODE_CLOSE,
				HIGHLIGHT_FONT_COLOR_CODE .. self:GetTotal(self.totals, nil, itemString) .. FONT_COLOR_CODE_CLOSE
			)
		end

		-- Add tooltip lines, indenting the left side in multi-realm mode.
		for lineNum, left in ipairs(addTooltipInfo_LeftStrings) do
			tooltip:AddDoubleLine(
				(realmsWithItems > 1 and TOOLTIP_INDENT or HIGHLIGHT_FONT_COLOR_CODE) .. left .. FONT_COLOR_CODE_CLOSE,
				addTooltipInfo_RightStrings[lineNum]
			)
		end

		return true
	else
		tooltip:AddDoubleLine(
			GRAY_FONT_COLOR_CODE .. L.Total .. FONT_COLOR_CODE_CLOSE,
			GRAY_FONT_COLOR_CODE .. 0 .. FONT_COLOR_CODE_CLOSE
		)
	end

	return false
end



--- When at least 1 of the given item is held by one or more characters on the specified realm,
--- add all the tooltip data for that realm to the reusable strings tables.
---@param itemString string Item to gather counts for.
---@param realm string Realm to get counts for.
---@return integer realmCount Total count of the given item found on the specified realm.
function Catalog:GetPerRealmTooltipInfo(itemString, realm)
	-- This realm has no data.
	if not self.totals[realm] then
		return 0
	end

	local overallTotal = self:GetTotal(self.totals[realm], nil, itemString)

	if (overallTotal or 0) > 0 or itemString == BS_CATALOG_LOCATIONS.MONEY then
		-- Realm-wide total goes first.
		self:AddTooltipInfoLine(
			realm,
			HIGHLIGHT_FONT_COLOR_CODE
			.. (itemString == BS_CATALOG_LOCATIONS.MONEY and BsUtil.FormatMoneyString(overallTotal) or overallTotal)
			.. FONT_COLOR_CODE_CLOSE
		)

		-- Add the total held by each character (if more than 0)
		local characterTotals
		for _, characterName in ipairs(self.totals[realm]._sortedCharacterList) do
			characterTotals = self.totals[realm][self:TotalKey(characterName)][itemString]
			if characterTotals then
				self:AddTooltipInfoLine(TOOLTIP_INDENT .. self.totals[realm]._formattedCharacterNames[characterName], characterTotals)
			end
		end
	end

	return overallTotal
end



--- Add the given strings to the reusable tooltip storage tables, to be consumed
--- by `AddTooltipInfo()`.
---@param left string?
---@param right string?
function Catalog:AddTooltipInfoLine(left, right)
	table.insert(addTooltipInfo_LeftStrings, left or "")
	table.insert(addTooltipInfo_RightStrings, right or "")
end



--- Get an item from the catalog by matching name and (optionally) texture.
--- Useful when item ID isn't known (like for some hooked tooltip functions).
--- This doesn't guarantee a 100% match since there are a few items that have
--- the same name and texture but different IDs (Recruit's Boots/Pants/Shirt).
---@param name string Item name.
---@param texture string? Item texture (recommended for a guaranteed accurate match).
---@param property string? Extract a single item property instead of returning the entire item table.
---@return table|string? # Item table or item property.
function Catalog:FindItemByNameAndTexture(name, texture, property)
	for _, item in ipairs(self.items) do
		if item.name == name and (not texture or item.texture == texture) then
			if property then
				return item[property]
			else
				return item
			end
			break
		end
	end
end



--- Build the account-wide search interface.
function Catalog:InitUi()
	-- Don't initialize multiple times.
	if self.objectManager then
		return
	end

	-- Upvalue for use inside ObjectManager class functions.
	local catalog = self

	self.objectManager = Bagshui.prototypes.ObjectManager:New({
		objectType = "Catalog",
		listType = BS_UI_SCROLLABLE_LIST_TYPE.ITEM,
		managerMultiSelect = false,
		disableObjectCreation = true,
		disableObjectDeletion = true,
		disableObjectEditing = true,
		disableObjectSharing = true,
		managerHeight = 700,
		managerWidth = 400,
		searchPlaceholderText = L.CatalogManager_SearchBoxPlaceholder,
		wikiPage = BS_WIKI_PAGES.Search,
	})


	function self.objectManager:InitUi()
		self._super.InitUi(self)
		self.ui.searchBox:SetWidth(self.dimensions.width * 0.6)

		-- Add CharacterData manager button to toolbar.
		local characterButton = self.ui:CreateIconButton({
			name = "Character",
			texture = "CharacterRobed",
			parentFrame = self.toolbar,
			anchorPoint = "RIGHT",
			anchorToPoint = "RIGHT",
			xOffset = -2,
			noTooltipDelay = true,
			noTooltipTextDelay = true,
			tooltipAnchor = "ANCHOR_PRESERVE",
			tooltipAnchorPoint = "TOPRIGHT",
			tooltipAnchorToPoint = "BOTTOMRIGHT",
			tooltipXOffset = 4,
			tooltipYOffset = -4,
			tooltipFunction = function(button, tooltip)
				tooltip:AddLine(HIGHLIGHT_FONT_COLOR_CODE .. string.format(L.Prefix_Manage, L.CharacterData) .. FONT_COLOR_CODE_CLOSE)
				tooltip:AddLine(BS_NEWLINE .. L.CatalogManager_KnownCharacters)
				tooltip:AddLine("- " .. table.concat(BsCharacterData.characterNameList, BS_NEWLINE .. "- "))
			end,
			onClick = function()
				BsCharacterData:Open()
			end,
		})
	end


	function self.objectManager:GetObjectList()
		return catalog.items
	end

end



--- Open the account-wide search interface, optionally with a pre-populated search string.
---@param searchString string? Search string to pre-populate.
function Catalog:Open(searchString)
	self:Init()
	self:InitUi()
	self.objectManager.Open(self.objectManager)
	if type(searchString) == "string" then
		self.objectManager.ui.listFrame.bagshuiData.searchBox:SetText(searchString)
	end
end



--- Hide the catalog window.
function Catalog:Close()
	self.objectManager:Close()
end



--- Open the Catalog if it's closed and vice-versa.
function Catalog:Toggle()
	if self:Visible() then
		self.objectManager:Close()
	else
		self:Open()
	end
end



--- Determine whether the Catalog window is open.
function Catalog:Visible()
	return self.objectManager and self.objectManager.uiFrame and self.objectManager.uiFrame:IsVisible()
end



--- Open and search the Catalog, setting focus on the search box.
---@param searchString string? Search string to pre-populate.
function Catalog:Search(searchString)
	self:Open(searchString)
	self.objectManager.ui.listFrame.bagshuiData.searchBox:SetFocus()
end



-- Class event registration.
-- This is done at the end because RegisterEvent expects the class to have an OnEvent function.
Bagshui:RegisterEvent("PLAYER_ENTERING_WORLD", Catalog)
Bagshui:RegisterEvent("BAGSHUI_CHARACTER_UPDATE", Catalog)
Bagshui:RegisterEvent("BAGSHUI_CHARACTER_LEARNED_RECIPE", Catalog)
Bagshui:RegisterEvent("BAGSHUI_EQUIPPED_UPDATE", Catalog)
Bagshui:RegisterEvent("BAGSHUI_INVENTORY_CACHE_UPDATE", Catalog)
Bagshui:RegisterEvent("BAGSHUI_MONEY_UPDATE", Catalog)
Bagshui:RegisterEvent("BAGSHUI_CATALOG_SHOULD_UPDATE", Catalog)


end)