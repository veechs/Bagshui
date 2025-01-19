-- Bagshui Item Information
--
-- Obtain information about a given item.
-- Provide PeriodicTable interface.
-- Display a window with an edit box to provide copyable item information.

Bagshui:AddComponent(function()


Bagshui:AddConstants({

	---@enum BS_ITEM_INFO_DISPLAY_TYPE
	-- Some item properties need to display differently depending on where they're
	-- being shown. For example, periodicTable only provides a count of sets in
	-- menus and tooltips, but gives the entire list of sets for text display.
	-- This is a parameter for ItemInfo:ItemPropertyValuesForDisplay() and is passed
	-- to the dynamic item property functions.
	-- ```
	-- { UPPERCASE = "UPPERCASE" }
	-- ```
	---@type table<string, string>
	BS_ITEM_INFO_DISPLAY_TYPE = {
		MENU = "MENU",
		TEXT = "TEXT",
		TOOLTIP = "TOOLTIP",
	},

	-- ItemInfo:InitializeItem() will never reset these properties.
	---@type table<string, boolean>
	BS_ITEM_INFO_PROTECTED_PROPERTIES = {
		bagNum = true,
		bagType = true,
		slotNum = true,
	},

})



local ItemInfo = {
	periodicTableSetCache = {},
	periodicTableSetCacheItemLink = "_",  -- Not using "" so that empty slots don't match.

	-- This is the ItemInfo window.
	window = Bagshui.prototypes.ScrollableTextWindow:New({
		name = "ItemInfo",
		title = "Item Info",  -- Will be updated to the name of the item in Open().
		readOnly = true,
		width = 400,
		height = 650,
		selectAllOnFocus = false,
	})
}
Bagshui.components.ItemInfo = ItemInfo
Bagshui.environment.BsItemInfo = ItemInfo

-- local infoWindowName = "ItemInfo"
-- local ui, uiFrame, uiTitle, scrollFrame, infoBox, itemSlotButton



--- Given an item link or string, obtain as much information as possible.
---@param itemIdentifier string|number|nil Item ID, link, or string. Allowed to be nil for empty slots.
---@param itemInfoTable table Table that will be filled with item information.
---@param initialize boolean? When true, always wipe the provided `itemInfoTable` before doing anything else.
---@param reinitialize boolean? `itemInfoTable` will be wiped after a successful call to `GetItemInfo()` when this is true.
---@param forceIntoLocalGameCache boolean? When true, call `LoadItemIntoLocalGameCache()` before doing anything else.
---@param inventory table? Inventory class instance associated with this item.
---@return boolean infoRetrievalSuccess # False if `GetItemInfo()` returned nil.
function ItemInfo:Get(itemIdentifier, itemInfoTable, reinitialize, initialize, forceIntoLocalGameCache, inventory)
	assert(type(itemInfoTable) == "table", "ItemInfo:Get(): itemInfoTable must be a table")
	-- Bagshui:PrintDebug(itemIdentifier)

	local itemName, itemTexture, itemString, itemStringFromGetItemInfo,
	      itemQuality, itemMinLevel, itemType, itemSubtype, itemMaxStackCount,
		  itemEquipLocation, itemId, itemLinkWithoutRandomSuffix,
		  itemBaseName, itemSuffixName

	local item = itemInfoTable

	local itemAlreadyInitialized = false

	-- Load the item into the local game cache if required
	if forceIntoLocalGameCache then
		self:LoadItemIntoLocalGameCache(itemIdentifier)
	end

	-- When the itemInfoTable is empty, it always makes sense to initialize.
	if initialize or (item.id == nil and item.name == nil and item.itemLink == nil) then
		self:InitializeItem(item)
		itemAlreadyInitialized = true
	end

	-- Attempt initial item information retrieval.
	-- This is all done before anything else to avoid wiping the cache entry if we
	-- get nil values from GetItemInfo().
	-- We can only call GetItemInfo if there's an item in the slot.
	if itemIdentifier ~= nil then
		-- Get the various permutations of information we need from the item identifier, if it's a link or item:#:#:#:# string.
		if type(itemIdentifier) == "string" then
			-- itemStringGeneric currently isn't utilized in Bagshui
			itemString, itemId, _, itemLinkWithoutRandomSuffix = self:ParseItemLink(itemIdentifier)
		end

		-- Call and store GetItemInfo results
		-- itemString can be nil if itemIdentifier was numeric or ParseItemLink couldn't get results,
		-- so try with the original identifier in that case.
		itemName,
			itemStringFromGetItemInfo,
			itemQuality,
			itemMinLevel,
			itemType,
			itemSubtype,
			itemMaxStackCount,
			itemEquipLocation,
			itemTexture = _G.GetItemInfo(itemString or itemIdentifier)

		-- Post-server query item identifier processing.
		if not itemString and itemStringFromGetItemInfo then
			-- The given itemIdentifier was just an ID, but now we have the itemString.
			itemString, itemId, _, itemLinkWithoutRandomSuffix = self:ParseItemLink(itemStringFromGetItemInfo)
		end

		-- When GetItemInfo returns nil there's (almost) nothing more we can do.
		if itemName == nil then
			Bagshui:PrintDebug("GetItemInfo() returned nil - bailing")
			return false
		end
	end


	-- If we make it this far, it's safe to proceed.

	-- Start fresh if allowed to do so.
	-- This is separate from the previous initialization because for Inventory cache
	-- entries, we don't want to wipe them until a successful call to GetItemInfo()
	-- has been made. Without this protection, cache entries can be wiped at startup
	-- before the client is getting answers from the server and opening the Inventory
	-- at that point will be like a first-run experience instead of instantly being
	-- able to see what was cached from the previous session. It's not a HUGE deal,
	-- but preserving the cache does make things feel better.
	if reinitialize and not itemAlreadyInitialized then
		-- Bagshui:PrintDebug("re-initialized " .. tostring(item.bagNum) .. ":" .. tostring(item.slotNum))
		self:InitializeItem(item)
	end

	-- Add item information that will be applicable regardless of whether this is
	-- an empty slot (or nil'd if it's an empty slot).

	item.itemString = itemString
	item.id = itemId
	item.texture = itemTexture
	item.bagshuiInventoryType = (inventory and inventory.inventoryType or nil)  -- Item location (Bags, Bank, etc).

	-- itemStringGeneric is disabled -- see BS_ITEM_SKELETON in Bagshui.lua for details.
	-- To restore this, bring back:
	-- - local itemStringGeneric at top of function.
	-- - Replace _ with itemStringGeneric in both calls to BsItemInfo:ParseItemLink above.
	--item.itemStringGeneric = (itemStringGeneric ~= itemString) and itemStringGeneric or nil

	-- There's an item, so we can proceed with populating all the item info.
	if item.itemString ~= nil then

		-- GetItemInfo() results.

		item.name = itemName
		item.quality = itemQuality
		item.minLevel = itemMinLevel
		item.type = itemType
		item.subtype = itemSubtype
		item.maxStackCount = itemMaxStackCount
		item.equipLocation = itemEquipLocation

		-- Apply any property overrides from Config\ItemFixes.lua.
		if Bagshui.config.ItemFixes[item.id] then
			for property, value in pairs(Bagshui.config.ItemFixes[item.id]) do
				if BS_ITEM_SKELETON[property] then
					item[property] = value
				end
			end
		end

		-- Store localized versions of information.
		if item.equipLocation and string.len(item.equipLocation) > 0 then
			item.equipLocationLocalized = _G[item.equipLocation]
		end
		item.qualityLocalized = _G[string.format("ITEM_QUALITY%d_DESC", item.quality)]

		-- If this is an item with a random suffix, figure out what it is.
		-- This will be used for reversed name sorting so that "Amazing Helmet of the Bear"
		-- can be sorted as "Helmet Amazing Bear the of" instead of "Bear the of Helmet Amazing".
		if itemLinkWithoutRandomSuffix ~= nil then
			itemBaseName = _G.GetItemInfo(itemLinkWithoutRandomSuffix)
			itemSuffixName = BsUtil.Trim(string.gsub(itemName, itemBaseName, ""))
		end
		item.baseName = itemBaseName
		item.suffixName = itemSuffixName

		-- Load tooltip.
		self:GetTooltip(item, inventory)

	end -- itemString exists

	-- Construct an item link if the itemIdentifier wasn't one.
	if itemString ~= nil and not string.find(tostring(itemIdentifier), "^|") then
		local itemQualityColor = _G.ITEM_QUALITY_COLORS[item.quality or 1].hex
		item.itemLink = itemQualityColor .. "|H" .. itemString .. "|H[" .. (itemName or L.Unknown) .. "]|H|r"
	else
		item.itemLink = itemIdentifier
	end

	-- Make sure important values aren't nil to avoid errors elsewhere.
	item.name = item.name or BS_ITEM_SKELETON.name
	item.subtype = item.subtype or BS_ITEM_SKELETON.subtype
	-- EngInventory/EngBags had an "unknown" quality value of -1 but that doesn't
	-- seem likely to occur (or particularly relevant to convey?), so let's just
	-- use the default quality color if we somehow didn't get one.
	item.quality = item.quality or BS_ITEM_SKELETON.quality

	return true
end



--- Set all values of an inventory cache item to default.
--- It's up to calling functions to manage any of the properties in
--- BS_ITEM_INFO_PROTECTED_PROPERTIES when they already have values.
---@param itemInfoTable table Table that will be filled with item information.
---@param initializeProtected boolean? Reset properties protected by `BS_ITEM_INFO_PROTECTED_PROPERTIES`.
function ItemInfo:InitializeItem(itemInfoTable, initializeProtected)
	for itemKey, defaultValue in pairs(BS_ITEM_SKELETON) do
		-- Never reset a protected property; only fill it if it's empty.
		-- All other properties are fair game.
		if
			not (
				BS_ITEM_INFO_PROTECTED_PROPERTIES[itemKey]
				and not initializeProtected
			)
			or not itemInfoTable[itemKey]
		then
			if type(defaultValue) == "table" then
				itemInfoTable[itemKey] = BsUtil.TableCopy(defaultValue)
			else
				itemInfoTable[itemKey] = defaultValue
			end
		end
	end
end




--- `GetItemInfo()` in Vanilla doesn't accept the full item links returned by `GetContainerItemLink()`,
--- so we need to parse out just the `item:itemId:enchantId:suffixId:uniqueId` part.
--- 
--- While we're doing that, we might as well pull out the item ID and the generic item link,
--- which is the same as the item link with enchantId and uniqueId set to 0, (even though we're not using it).
--- 
--- If applicable, also figure out the version of the item string associated with the base item that
--- doesn't have a the random suffix (i.e. "of the Bear") for use during reverse name sorting
--- (see comment about `itemLinkWithoutRandomSuffix` in `ItemInfo:Get()`).
--- 
--- Reference: https://warcraft.wiki.gg/index.php?title=ItemLink&oldid=4718845
---@param itemLink string Item link or item string.
---@return string? itemString
---@return number? itemId
---@return string? itemStringGeneric
---@return string? itemStringWithoutRandomSuffix
function ItemInfo:ParseItemLink(itemLink)
	if not itemLink then
		return
	end
	local itemString, itemStringGeneric, itemStringWithoutRandomSuffix
	local found, _, itemId, enchantId, suffixId, uniqueId = string.find(tostring(itemLink), "item:(%d+):(%d+):(%d+):(%d+)")
	if found then
		local itemFormatString = "item:%s:%s:%s:%s"
		itemString = string.format(itemFormatString, itemId, enchantId, suffixId, uniqueId)
		itemStringGeneric = string.format(itemFormatString, itemId, "0", suffixId, "0")
		if suffixId ~= "0" then
			itemStringWithoutRandomSuffix = string.format(itemFormatString, itemId, "0", "0", "0")
		end
	end
	return itemString, tonumber(itemId), itemStringGeneric, itemStringWithoutRandomSuffix
end



--- Store item's tooltip on the item.tooltip property as a single string.
--- Also parse charges from the tooltip if possible.
---@param item table Item information table in the format of BS_ITEM_SKELETON.
---@param inventory table? Inventory class, if applicable.
---@param forceItemString boolean? Ignore bagNum/slotNum properties on `item` and use `itemString`.
function ItemInfo:GetTooltip(item, inventory, forceItemString)
	-- Reset charges first since this is where they're picked up (when SuperWoW isn't loaded).
	if not BS_SUPER_WOW_LOADED then
		item.charges = 0
	end

	item.tooltip = ""

	-- Pull the tooltip text into our hidden tooltip.
	BsHiddenTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")  -- Need to clear lines first.
	self:LoadTooltip(BsHiddenTooltip, item, inventory, forceItemString)

	-- Loop through all lines of tooltip and concatenate.
	-- This is also where we can figure out if an item has charges.
	local ttTextFrame, ttText
	local ttBagshuiData = BsHiddenTooltip.bagshuiData
	local chargesFound, chargeCount
	-- Lines
	for ttLineNum = 2, BsHiddenTooltip:NumLines() do
		-- Left/Right
		-- Don't use _ as a placeholder here since it's used inside the loop.
		for __, lr in ipairs(ttBagshuiData.textFieldsPerLine) do

			ttTextFrame = _G[ttBagshuiData.name .. "Text" .. lr .. ttLineNum]
			if ttTextFrame ~= nil and ttTextFrame:IsVisible() then

				ttText = ttTextFrame:GetText()
				if ttText ~= nil then

					-- Append to tooltip.
					ttText = string.gsub(ttText, "^%s+$", "")
					item.tooltip = item.tooltip .. BS_INVENTORY_TOOLTIP_JOIN_CHARACTERS[lr] .. ttText

					-- Parse charges and store, but don't overwrite if we already know them.
					if not BS_SUPER_WOW_LOADED and item.charges == 0 then
						chargesFound, _, chargeCount = string.find(ttText, L.TooltipParse_Charges)
						if chargesFound then
							item.charges = tonumber(chargeCount)
						end
					end

				end -- ttText exists
			end -- ttTextFrame exists
		end -- Left/Right
	end -- Lines

	item.tooltip = BsUtil.Trim(item.tooltip)
end



--- Load the tooltip for the given item into the provided `tooltipFrame`.
--- Normally we can use `SetBagItem()`, but some containers need to use `SetInventoryItem()` instead.
---@param tooltipFrame table WoW UI tooltip frame created with `CreateFrame("GameTooltip" ... )`.
---@param item table<string,string|number>|string Item information table populated by ItemInfo:Get() or an itemString ("item:#:#:#:#").
---@param inventory table? Inventory class instance, if applicable.
---@param forceItemString boolean? Ignore bagNum/slotNum properties on `item` and use `itemString`.
---@return number|nil|boolean hasCooldown Is the item on cooldown?
---@return number|nil repairCost If the item is damaged, value in copper to repair.
function ItemInfo:LoadTooltip(tooltipFrame, item, inventory, forceItemString)
	local hasCooldown, repairCost

	-- Determine whether the tooltip needs to be loaded using the itemString (via SetHyperlink()).
	-- There are multiple reasons this can occur:
	-- 
	-- 1. A string or number was passed instead of a table.
	local itemString =
		type(item) == "string" and item
		or type(item) == "number" and ("item:" .. item .. ":0:0:0:0:0:0:0:0")
		or nil  --[[@as string|number|nil]]
	-- 
	-- 2a. An an item table was passed but bagNum and slotNum are both the default, meaning we
	--     can't use SetInventoryItem()/SetBagItem().
	-- 2b. Offline mode, where the Set*Item() functions aren't available.
	-- 2C. forceItemString is set.
	if
		type(item) == "table"
		and (
			(item.bagNum == BS_ITEM_SKELETON.bagNum and item.slotNum == BS_ITEM_SKELETON.slotNum)
			or (inventory and not inventory.online)
			or forceItemString
		)
	then
		itemString = item.itemString
	end

	-- When itemString was given a value for one of the reasons above, that means
	-- we should use SetHyperlink().
	if itemString then
		tooltipFrame:SetHyperlink(itemString)

	elseif type(item) == "table" then

		-- Inventory configurations can provide a function that translates the item's slotNum
		-- from the sequential 0-N bag slot to the global inventory slot number when
		-- they need to use SetInventoryItem() instead of SetBagItem().
		if
			inventory
			and inventory.primaryContainer.id == item.bagNum
			and inventory.getInventorySlotFunction
		then

			-- SetInventoryItem() returns hasItem, hasCooldown, repairCost.
			_, hasCooldown, repairCost = tooltipFrame:SetInventoryItem(
				"player",
				inventory.getInventorySlotFunction(item.slotNum)
			)
		else
			hasCooldown, repairCost = tooltipFrame:SetBagItem(item.bagNum, item.slotNum)
		end
	end

	return hasCooldown, repairCost
end



--- Fill the given tooltip with a list of all item properties.
---@param item table Filled by `ItemInfo:Get()`.
---@param tooltip table WoW UI tooltip.
function ItemInfo:AddTooltipInfo(item, tooltip)
	Bagshui:AddTooltipLine(tooltip, nil, L.ItemProperties, true)
	-- Iterate all item properties.
	for _, itemPropertyFriendly, itemPropertyValue, itemPropertyDisplay in self:ItemPropertyValuesForDisplay(item, BS_ITEM_INFO_DISPLAY_TYPE.TOOLTIP) do
		if itemPropertyValue ~= nil then
			Bagshui:AddTooltipLine(tooltip, itemPropertyDisplay, string.format(L.Symbol_Colon, itemPropertyFriendly))
		end
	end
end



--- Ensure GetItemInfo will work for an item by forcing it into the local game cache via hidden tooltip load.
---@param itemIdentifier string|number|nil itemString ("item:#:#:#:#") or item number.
function ItemInfo:LoadItemIntoLocalGameCache(itemIdentifier)
	if not itemIdentifier or itemIdentifier == 0 then
		return
	end
	local itemString
	if type(itemIdentifier) == "number" or (type(itemIdentifier) == "string" and tonumber(itemIdentifier)) then
		-- Extra 0s seem to sometimes be necessary to make SetHyperlink work, and they never have hurt during testing.
		itemString = "item:" .. itemIdentifier .. ":0:0:0:0:0:0:0:0"
	else
		itemString = self:ParseItemLink(itemIdentifier)
	end
	if itemString then
		BsHiddenTooltip:SetHyperlink(itemString)
	end
end



--- Check whether the given Bagshui item is usable by the specified Bagshui character.
---@param item table<string,string|number> Bagshui Inventory cache entry.
---@param character table Bagshui character information table.
---@return boolean usable
---@return boolean? alreadyKnown
function ItemInfo:IsUsable(item, character)
	character = character or Bagshui.currentCharacterInfo

	-- When there's no information about the item or character, assume it IS usable.
	if not item.id or item.id == 0 or (character.level or 0) == 0 then
		return true
	end

	-- Item required level > character's current level.
	if item.minLevel > character.level then
		-- Bagshui:PrintDebug(item.name ..  " minLevel " .. tostring(item.minLevel) .. " > " .. tostring(character.level))
		return false
	end

	-- Class requirements.
	-- _G.ITEM_CLASSES_ALLOWED is "Classes: %s"
	if item.tooltip and string.find(item.tooltip, string.format(_G.ITEM_CLASSES_ALLOWED, "")) then
		-- Wrapping the class name in a frontier pattern for word boundary matching.
		-- This allows for safely matching things like "Classes: Hunter, Rogue, Mage".
		if not string.find(item.tooltip, string.format(_G.ITEM_CLASSES_ALLOWED, ".*%f[%a]" .. character.localizedClass .. "%f[%A].*")) then
			-- Bagshui:PrintDebug(item.name ..  " requires class")
			return false
		end
	end

	-- Required skill from tooltip.
	local requiredSkill, requiredLevel = self:GetRequiredSkillAndLevel(item.tooltip)

	if requiredSkill then
		-- GetSkillLevel returns -1 if the character doesn't have the skill.
		local skillLevel = BsCharacter:GetSkillLevel(requiredSkill, character)
		if skillLevel < 1 or (requiredLevel and skillLevel < requiredLevel) then
			-- Bagshui:PrintDebug(item.name ..  " requires skill " .. tostring(requiredSkill) .. " lvl " .. tostring(requiredLevel) .. " not " .. tostring(skillLevel))
			return false
		end
	end

	if
		(item.type == L.Armor or item.type == L.Weapon)
		and not BsGameInfo.itemSubclassNoSkillNeeded[item.subtype]
	then
		-- Armor/Weapons (including Fishing Poles).

		-- Start by assuming the skill the character must possess is based on the item subtype.
		-- A lot of skills have the same name (subtype "Swords" is the skill "Swords"), but
		-- some don't match ("One-Handed Swords" -> "Swords"), which is why we check the
		-- GameInfo itemSubclassToSkill table first.
		local skillName = BsGameInfo.itemSubclassToSkill[item.subtype] or item.subtype

		-- GetSkillLevel will return -1 if the character doesn't have the skill.
		if BsCharacter:GetSkillLevel(skillName, character) < 1 then
			-- Bagshui:PrintDebug(item.name ..  " requires skill " .. tostring(skillName))
			return false
		end

		if
			item.equipLocation == "INVTYPE_WEAPONOFFHAND"
			and BsCharacter:GetSkillLevel(L["Dual Wield"], character) < 1
		then
			-- Off-hand weapons require Dual Wield skill.
			-- Bagshui:PrintDebug(item.name ..  " requires Dual Wield")
			return false
		end

	elseif item.type == L.Projectile or item.type == L.Quiver then
		-- Projectiles/Ammo Bags.

		if
			(item.subtype == L.Arrow or item.subtype == L.Quiver)
			and BsCharacter:GetSkillLevel(L.Bows, character) < -1
		then
			-- Arrow/Quiver require Bows skill.
			-- Bagshui:PrintDebug(item.name ..  " requires Bows")
			return false

		elseif
			(item.subtype == L.Bullet or item.subtype == L["Ammo Pouch"])
			and BsCharacter:GetSkillLevel(L.Guns, character) < -1
		then
			-- Bullets/Ammo Pouches require Guns skill.
			-- Bagshui:PrintDebug(item.name ..  " requires Guns")
			return false
		end


	elseif item.type == L.Recipe then
		-- Recipes.

		-- Already known check.
		if item.tooltip and string.find(item.tooltip, L.TooltipParse_AlreadyKnown) then
			-- Bagshui:PrintDebug(item.name ..  " already known")
			return true, true
		end

	end

	return true

end



--- Parse an item's tooltip to determine whether a specific skill is required to use it.
--- Relies on the correct localized search pattern being defined in TooltipParse_RequiresLevel.
---@param itemTooltip string Item tooltip as a single string.
---@return string? skillName
---@return number? skillLevel
function ItemInfo:GetRequiredSkillAndLevel(itemTooltip)
	if not itemTooltip then
		return
	end
	local _, _, skillName, skillLevel = string.find(
		-- Remove anything after a double line break since text after this point doesn't
		-- refer to the item itself, but to an item set or the item a recipe crafts.
		string.gsub(itemTooltip, "\n\n.+$", ""),
		L.TooltipParse_RequiresLevel
	)
	if skillName then
		return skillName, tonumber(skillLevel)
	end
end



--- Wrap an item's name in the appropriate color escape sequence for its quality level.
---@param item table<string,string|number> Item information table populated by ItemInfo:Get().
---@return string
function ItemInfo:GetQualityColoredName(item)
	if type(item) ~= "table" then
		return L.Unknown
	end
	return
		_G.ITEM_QUALITY_COLORS[item.quality or 1].hex
		.. ((string.len(item.name or "") > 0) and item.name or L.Unknown)
		.. FONT_COLOR_CODE_CLOSE
end



--- Obtain a sorted array of either the full list of PeriodicTable sets or
--- those pertaining to the given item.
---@param itemOrItemLink table<string,string|number>|string|number? Item information table populated by ItemInfo:Get() or item link.
---@return table
function ItemInfo:GetPeriodicTableSets(itemOrItemLink)
	-- When an item info table is provided, grab the item link.
	if type(itemOrItemLink) == "table" then
		itemOrItemLink = itemOrItemLink.itemLink
	end

	-- We've just seen this item and already know its sets.
	if
		(itemOrItemLink and itemOrItemLink == self.periodicTableSetCacheItemLink)
		or (not itemOrItemLink and self.periodicTableSetCacheItemLink == "~")
	then
		return self.periodicTableSetCache
	end

	-- Reset the cache and update the cached item identifier.
	BsUtil.TableClear(self.periodicTableSetCache)
	self.periodicTableSetCacheItemLink = (itemOrItemLink or "~")

	-- We need to directly access PeriodicTable's k set storage structure because
	-- it doesn't seem to provide any way to request the listing of built-in sets.
	for setName, _ in pairs(Bagshui.libs.PT.k.customsets) do
		if not itemOrItemLink or (itemOrItemLink and Bagshui.libs.PT:ItemInSet(itemOrItemLink, setName)) then
			table.insert(self.periodicTableSetCache, setName)
		end
	end

	table.sort(self.periodicTableSetCache)

	return self.periodicTableSetCache
end



--- Create a string consisting of itemString, count, and item location that allows
--- an item to be (almost) uniquely identified. Used by the "shadow ID" system in
--- the inventory cache -- see comment above the definition of shadowId in
--- Inventory.Cache.lua for detail.
---@param item table<string,string|number> Item information table populated by ItemInfo:Get().
---@param bagNumOverride number? Get the unique ID as if the item is in a different container.
---@param slotNumOverride number? Get the unique ID as if the item is in a different bag slot.
---@return string
function ItemInfo:GetUniqueItemId(item, bagNumOverride, slotNumOverride)
	return
		(bagNumOverride or item.bagNum or "?") .. ":" ..
		(slotNumOverride or item.slotNum or "?") .. ":" ..
		(item.itemString or "?") .. ":" ..
		(item.count or 0) .. ":" ..
		(item.bagshuiInventoryType or "?")
end



--- Display the Item Information Window for the given item
---@param item table<string,string|number> Item information table populated by ItemInfo:Get().
function ItemInfo:Open(item)
	self.window:Open(item)
end



--- Construct the code examples for the info window.
---@param ruleFunctionExamples string[] Rule functions. If `%s` is found, the item property value will be substituted.
---@param itemPropertyValue string|number? Value to fill if %s is present in the rule function.
---@param itemPropertyFriendly string User-facing localized name for the item property, used if `itemPropertyValue` is nil.
---@return string
function ItemInfo:BuildRuleFunctionExampleText(ruleFunctionExamples, itemPropertyValue, itemPropertyFriendly)
	local ret = ""
	for _, ruleFunctionExample in ipairs(ruleFunctionExamples) do
		-- The substitution text for rule function parameters is either the actual value with
		-- double quotes escaped or `<Friendly Property Name>` if the property doesn't have a value.
		local ruleFunctionParameter = itemPropertyValue ~= nil and string.gsub(tostring(itemPropertyValue), '"', '\\"') or ("<" .. tostring(itemPropertyFriendly) .. ">")
		-- Replace %s or %d in the example with the parameter value.
		if string.find(ruleFunctionExample, "%%s") then
			ruleFunctionExample = string.format(ruleFunctionExample, tostring(ruleFunctionParameter))
		end
		-- Add to info text.
		ret = ret .. BS_FONT_COLOR.CODE_EXAMPLE .. ruleFunctionExample .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE
	end
	return ret
end



--- Get an iterator function that will return item properties in the order of `BS_ITEM_PROPERTIES_SORTED`.
---@param item table<string,string|number> Item information table populated by ItemInfo:Get().
---@param displayType BS_ITEM_INFO_DISPLAY_TYPE?
---@return function iterableFunction function with the following return values, in order:
--- ```
--- ---@return string propertyName # Actual property name.
--- ---@return string propertyDisplayName # Friendly localized property name for display.
--- ---@return any propertyValue # Actual property value.
--- ---@return any propertyDisplayValue # Same as `propertyValue`, but will be the localized "(No Value)" string if `propertyValue` is empty.
--- ```
function ItemInfo:ItemPropertyValuesForDisplay(item, displayType)
	self:BuildSortedItemTemplatePropertyList()

	-- These upvalues are needed for the iterator function.
	local i = 0
	local realtimeItemProperties = BS_REALTIME_ITEM_INFO_PROPERTIES
	local L = L

	return function()
		i = i + 1

		local itemProperty = BS_ITEM_PROPERTIES_SORTED[i]

		local itemPropertyFriendly = itemProperty and L["ItemPropFriendly_" .. itemProperty]

		local itemPropertyValue = (
				(
					not (
						displayType == BS_ITEM_INFO_DISPLAY_TYPE.TOOLTIP
						and item.bagshuiInventoryType == nil
						and BS_ITEM_PROPERTIES_SUPPRESSED_IN_TOOLTIP_OUTSIDE_INVENTORY[itemProperty]
					)
					and itemProperty
				)
				and	(
					realtimeItemProperties[itemProperty] and realtimeItemProperties[itemProperty](item, displayType)
					or (item[itemProperty] ~= nil and item[itemProperty] ~= "") and tostring(item[itemProperty])
					or nil
				)
				or nil
			)

		-- Display value is the actual value if it exists or "(No Value)" if not.
		-- Will be truncated unless it's for text display.
		local itemPropertyDisplay =
			itemPropertyValue
			and (
				type(itemPropertyValue) ~= "table"
				and (
					NORMAL_FONT_COLOR_CODE
					.. (
						displayType ~= Bagshui.environment.BS_ITEM_INFO_DISPLAY_TYPE.TEXT
						and BsUtil.TruncateString(tostring(itemPropertyValue), 35)
						or tostring(itemPropertyValue)
					)
					.. FONT_COLOR_CODE_CLOSE)
				or ""
			)
			or GRAY_FONT_COLOR_CODE .. L.NoValue .. FONT_COLOR_CODE_CLOSE

		if itemPropertyValue == "" then
			itemPropertyValue = nil
		end

		return itemProperty, itemPropertyFriendly, itemPropertyValue, itemPropertyDisplay
	end
end



--- Fill BS_ITEM_PROPERTIES_SORTED with a list of item properties that have a corresponding
--- rule function, sorted in friendly (localized) name order.
function ItemInfo:BuildSortedItemTemplatePropertyList()
	-- Only do this once.
	if not Bagshui.environment.BS_ITEM_PROPERTIES_SORTED then
		local itemPropertiesSorted = {}
		-- Only add properties that have a corresponding rule function.
		for prop, _ in pairs(BS_ITEM_PROPERTIES_TO_FUNCTIONS) do
			table.insert(itemPropertiesSorted, prop)
		end
		-- Sort the list.
		table.sort(itemPropertiesSorted, function(itmA, itmB)
			return L["ItemPropFriendly_" .. itmA] < L["ItemPropFriendly_" .. itmB]
		end)
		-- Save to Bagshui environment.
		Bagshui.environment.BS_ITEM_PROPERTIES_SORTED = itemPropertiesSorted
	end
end



--- ScrollableTextWindow override for item info display.
---@param item table<string,string|number> Item information table populated by ItemInfo:Get().
function ItemInfo.window:Open(item)
	-- Nothing to do.
	if not item then
		return
	end

	-- Build item information text.

	local infoText = ""

	for itemProperty, itemPropertyFriendly, itemPropertyValue, itemPropertyDisplay in ItemInfo:ItemPropertyValuesForDisplay(item, BS_ITEM_INFO_DISPLAY_TYPE.TEXT) do

		-- Start this property with `<Friendly Property Name>: <Property Value>`.
		infoText = infoText .. string.format(L.Symbol_Colon, itemPropertyFriendly) .. " " .. itemPropertyDisplay .. BS_NEWLINE

		-- Add rule function examples.
		local ruleFunctionExamples = BS_ITEM_PROPERTIES_TO_FUNCTIONS[itemProperty]
		if type(ruleFunctionExamples) == "table" then
			if type(itemPropertyValue) == "table" then
				for _, val in ipairs(itemPropertyValue) do
					infoText = infoText .. ItemInfo:BuildRuleFunctionExampleText(ruleFunctionExamples, val, itemPropertyFriendly)
				end
			else
				infoText = infoText .. ItemInfo:BuildRuleFunctionExampleText(ruleFunctionExamples, itemPropertyValue, itemPropertyFriendly)
			end
		else
			infoText = infoText .. GRAY_FONT_COLOR_CODE .. L.NoRuleFunction .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE
		end

		-- End with a final newline so that there are two newlines to separate from
		-- the next property (extra newlines at the very end don't matter).
		infoText = infoText .. BS_NEWLINE

	end

	-- Prepare to open the window.
	if self._super.Open(self, infoText, true) == false then
		return
	end

	-- Set title to item name.
	self.uiTitle:SetText(
		string.format(L.Symbol_Colon, L.BagshuiItemInformation) .. " "
		.. HIGHLIGHT_FONT_COLOR_CODE .. tostring(item.name) .. FONT_COLOR_CODE_CLOSE
	)

	-- Set item slot button in top left to item.
	self.ui:AssignItemToItemButton(self.itemSlotButton, item)
	self.itemSlotButton.bagshuiData.itemString = item.itemString  -- This will be picked up for the tooltip.

	-- Actually open the window.
	-- self:Open()
end



--- ScrollableTextWindow override for initializing UI.
function ItemInfo.window:InitUi()
	-- Calls ScrollableTextWindow:InitUi().
	if self._super.InitUi(self) == false then
		return
	end

	-- Add item slot button to top left of window.
	self.itemSlotButton = self.ui:CreateItemSlotButton("ItemSlotButton", self.uiHeader)
	self.itemSlotButton.bagshuiData.tooltipAnchorDefault = true
	self.itemSlotButton.bagshuiData.noBorderScale = true
	self.ui:SetItemButtonSize(self.itemSlotButton, self.uiTitle:GetHeight() + 2)
	self.itemSlotButton:SetPoint("LEFT", self.uiFrame.bagshuiData.header)
	-- Remove clickability and pass drag events to the window.
	self.itemSlotButton:RegisterForClicks(nil)
	self.itemSlotButton:RegisterForDrag("LeftButton")
	self.itemSlotButton:SetScript("OnDragStart", function()
		if _G.GameTooltip:IsOwned(_G.this) then
			_G.GameTooltip:Hide()
		end
		self.uiFrame:StartMoving()
	end)
	self.itemSlotButton:SetScript("OnDragStop", function()
		self.uiFrame:StopMovingOrSizing()
	end)

	-- Anchor title to item slot button.
	self.uiTitle:ClearAllPoints()
	self.uiTitle:SetPoint("LEFT", self.itemSlotButton, "RIGHT", 4, 0)
end


end)