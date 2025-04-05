-- Bagshui Character Attribute Tracking
-- Exposes: BsCharacter (and Bagshui.components.Character)
-- Raises:
-- - BAGSHUI_CHARACTER_LEARNED_RECIPE
--   BAGSHUI_CHARACTER_UPDATE
--   BAGSHUI_EQUIPPED_UPDATE
--   BAGSHUI_EQUIPPED_HISTORY_UPDATE
--   BAGSHUI_MONEY_UPDATE
--   BAGSHUI_PROFESSION_ITEM_UPDATE
--
-- Builds lists of skills, spells, and profession crafts and reagents.
-- Profession limitations:
-- - Item lists can only be constructed when the profession window is opened -
--   that's why we register for TRADE_SKILL_SHOW and CRAFT_SHOW.
-- - Enchanting uses the "Craft" API instead of TradeSkill, which means that the
--   items returned from GetCraftItemLink are actually spells. It appears that
--   a list of Enchanting crafts can't be autogenerated and a database would need
--   to be constructed.

Bagshui:AddComponent(function()

-- Events that will trigger `Character:OnEvent()`.
local CHARACTER_EVENTS = {
	BAGSHUI_INITIAL_CHARACTER_UPDATE = true,  -- Delayed processing at startup.
	CHAT_MSG_SKILL = true,  -- New skills learned or leveled up.
	CHAT_MSG_SYSTEM = true,  -- Messages to parse for important events.
	CRAFT_SHOW = true,  -- Enchanting profession window is opened.
	PLAYER_ENTERING_WORLD = true,  -- Trigger initial processing at startup.
	PLAYER_LEVEL_UP = true,  -- Level up.
	SKILL_LINES_CHANGED = true,  -- Need to update skills (needed to catch some weird skills like Fist Weapons).
	SPELLS_CHANGED = true,  -- Need to update spells.
	TRADE_SKILL_SHOW = true,  -- Profession window is opened (other than Enchanting).
	UPDATE_INVENTORY_ALERTS = true,  -- Equipped gear has changed.
	UNIT_INVENTORY_CHANGED = true,  -- Equipped gear has changed.
}

-- Events that should trigger a money update.
-- Making a table for these because there are a bunch.
-- Using key-value so it's easy to test in `Character:OnEvent()`.
local MONEY_EVENTS = {
	PLAYER_MONEY = true,
	PLAYER_TRADE_MONEY = true,
	SEND_MAIL_MONEY_CHANGED = true,
	SEND_MAIL_COD_CHANGED = true,
	TRADE_MONEY_CHANGED = true,  -- Might not need this one but might as well do it just to be safe.
}


-- The comments below refer to `currentCharacterInfo`, which is a pointer to
-- `Bagshui.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO]`.

-- Array of property names for `currentCharacterInfo` whose values are tables.
local CHARACTER_INFO_TABLES = {
	"skills",
	"spellNamesToIds",
	"spells",
	"professionCrafts",
	"professionReagents",
	"equippedHistory",
	"equipped",
}

-- Array of important property names and dummy values for `currentCharacterInfo`.
-- See comment above the initial call to `Character:UpdateInfo()` at the end of
-- this file for more information.
local CHARACTER_INFO_MINIMUM_PROPERTIES = {
	class = "",
	faction = "",
	name = "",
	realm = "",
	level = 1,
	localizedClass = "",
	localizedFaction = "",
	localizedRace = "",
	money = 0,
	race = "",
}


-- The game only gives skill categories as localized strings, so this is a way
-- of making internal references locale-independent.
local LOCALIZED_TO_EN_SKILL_ID = {
	[L["Professions"]] = "professions",
	[L["Secondary Skills"]] = "secondarySkills",
	[L["Weapon Skills"]] = "weaponSkills",
	[L["Armor Proficiencies"]] = "armorProficiencies",
}

-- We have no use for these skills, so don't store them.
local IGNORE_SKILL_CATEGORY = {
	[L["Class Skills"]] = true,
	[L["Languages"]] = true,
}



-- `Bagshui.currentCharacterData` table is guaranteed to be initialized by
-- `Bagshui:AddonLoaded()` so we don't need to check it.
local currentCharacterInfo = Bagshui.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO]

-- Ensure key tables exist in `Bagshui.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO]`.
for _, tableName in ipairs(CHARACTER_INFO_TABLES) do
	if not currentCharacterInfo[tableName] then
		currentCharacterInfo[tableName] = {}
	end
end

-- Ensure skill tables exist.
-- 1.12 doesn't give any sort of IDs for skill types, only localized names, but
-- we're dealing with that via `LOCALIZED_TO_EN_SKILL_ID`.
for _, skillName in pairs(LOCALIZED_TO_EN_SKILL_ID) do
	if not currentCharacterInfo.skills[skillName] then
		currentCharacterInfo.skills[skillName] = {}
	end
end



-- Build Character class.
local Character = {
	-- `Bagshui.currentCharacterData[BS_CONFIG_KEY.CHARACTER_INFO]`.
	info = currentCharacterInfo,
	-- List of all inventory slots, including bags, and their localized names.
	---@type table<number,string>
	inventorySlots = {},
	-- Bag slot IDs so `Character:UpdateGear()` can differentiate.
	---@type table<number,true>
	bagSlots = {},
	-- When character info is nil, we'll retry a few times.
	startupRetries = 0,
	initialized = false,
}
-- Add skills, spells, etc.
for _, tableName in ipairs(CHARACTER_INFO_TABLES) do
	Character[tableName] = currentCharacterInfo[tableName]
end
-- Add professions, secondarySkills, etc.
for _, skillName in pairs(LOCALIZED_TO_EN_SKILL_ID) do
	Character[skillName] = currentCharacterInfo.skills[skillName]
end
-- Add inventory slots.
for slot, localized in pairs(BS_INVENTORY_SLOT_NAMES) do
	Character.inventorySlots[slot] = localized
end
for inventoryType, config in pairs(Bagshui.config.Inventory) do
	for bagNum, slotName in ipairs(config.inventorySlots) do
		Character.inventorySlots[slotName] = inventoryType .. "Container" .. bagNum
		Character.bagSlots[slotName] = true
	end
end
Bagshui.environment.BsCharacter = Character
Bagshui.components.Character = Character



--- Event processing.
---@param event string WoW API event
---@param arg1 any First event argument.
function Character:OnEvent(event, arg1)
	-- Bagshui:PrintDebug("Character event " .. event .. " // " .. tostring(arg1))

	-- Initial processing at startup. The delayed event is necessary to ensure
	-- we can actually get the data we need, which isn't available instantly.
	-- See comment above the initial call to Character:UpdateInfo() at the end of
	-- this file for more information.
	if event == "PLAYER_ENTERING_WORLD" then
		if not self.initialized then
			Bagshui:QueueEvent("BAGSHUI_INITIAL_CHARACTER_UPDATE", 1.5)
		end
		return
	end

	-- Some important events are only conveyed through chat messages that need
	-- string matching to determine whether they're what we want.
	if event == "CHAT_MSG_SYSTEM" then
		-- This seems to be the best way to know when a character learns a new recipe.
		-- Handling it centrally so other classes just have to register for BAGSHUI_CHARACTER_LEARNED_RECIPE.
		if string.find(arg1, L.ChatMsgIdentifier_LearnedRecipe) then
			BsItemInfo:InvalidateUsableCache()
			Bagshui:RaiseEvent("BAGSHUI_CHARACTER_LEARNED_RECIPE")
		end
		return
	end

	-- Refresh spells/skills and remove any items from the profession tables that shouldn't be there anymore.
	-- This is also where the initial update after PLAYER_ENTERING_WORLD occurs.
	if
		(
			self.initialized
			and (
				event == "SPELLS_CHANGED"
				or event == "CHAT_MSG_SKILL"
				or event == "SKILL_LINES_CHANGED"
			)
		)
		or event == "BAGSHUI_INITIAL_CHARACTER_UPDATE"
	then
		self:UpdateSkillsAndSpells()
		self:PruneProfessionItems()
		-- Need to set this true before calling UpdateInfo() so that it will
		-- correctly raise BAGSHUI_CHARACTER_UPDATE.
		self.initialized = true
		if event == "BAGSHUI_INITIAL_CHARACTER_UPDATE" then
			self:UpdateInfo()
			self:UpdateGear()
			self:UpdateMoney()
		end
		-- Whenever something major about the character changes, the usable cache must be updated.
		-- This might be slightly overboard, but it's the easiest way to maximize
		-- accuracy of usability status.
		BsItemInfo:InvalidateUsableCache()
		return
	end

	-- Nothing else can happen until the class is initialized.
	if not self.initialized then
		return
	end

	-- Player level changed.
	if event == "PLAYER_LEVEL_UP" then
		self:UpdateInfo(arg1)
		BsItemInfo:InvalidateUsableCache()
		return
	end

	-- Equipped gear changed ("inventory" in this case is what's equipped, not what's in bags).
	if
		event == "UPDATE_INVENTORY_ALERTS"
		or event == "UNIT_INVENTORY_CHANGED"
	then
		self:UpdateGear()
		return
	end

	-- Money changed.
	if MONEY_EVENTS[event] then
		self:UpdateMoney()
		return
	end

	-- Do a profession update.
	-- This can only happen when the appropriate window is opened!
	if event == "CRAFT_SHOW" or event == "TRADE_SKILL_SHOW" then
		-- Wait a smidgen before attempting the update so that game functions will return values.
		Bagshui:QueueClassCallback(self, self.UpdateProfessionItems, 0.75, false, event)
		BsItemInfo:InvalidateUsableCache()
		return
	end

end


-- Determine whether there are actual changes in `Character:UpdateInfo()`.
local _updateInfo_oldValues = {}


--- Refresh basic character information.
---@param newLevel number? `arg1` from the `PLAYER_LEVEL_UP` event, needed because `UnitLevel()` can be wrong just after gaining a level.
function Character:UpdateInfo(newLevel)
	-- Record old values.
	for key, value in pairs(self.info) do
		_updateInfo_oldValues[key] = value
	end

	self.info.name = _G.UnitName("player")
	self.info.realm = BsUtil.Trim(_G.GetCVar("realmName"))
	self.info.localizedClass, self.info.class = _G.UnitClass("player")
	self.info.faction, self.info.localizedFaction = _G.UnitFactionGroup("player")
	self.info.localizedRace, self.info.race = _G.UnitRace("player")

	-- Level should never be 0. UnitLevel() returns 0 for a short time after login,
	-- and we want to ignore that. The processing of CHARACTER_INFO_MINIMUM_PROPERTIES
	-- at the end of this file will fill it with 1 for a brief time at the very first login.
	-- After that, it'll be cached in SavedVariables.
	newLevel = newLevel or _G.UnitLevel("player")
	if newLevel ~= 0 then
		self.info.level = newLevel
	end

	-- Ensure the standard Class entry is uppercase, just to be safe. That's how the game 
	-- typically returns it, so there are other parts of Bagshui that assume it'll be in all caps.
	self.info.class = string.upper(self.info.class)

	-- Retry at startup (when no `newLevel` parameter is passed) if needed due to empty values.
	if not newLevel and not self.faction and self.infoRetries < 5 then
		self.infoRetries = self.infoRetries + 1
		Bagshui:QueueEvent("BAGSHUI_INITIAL_CHARACTER_UPDATE", 1)
		return
	end

	-- Raise an event if there were changes.
	if self.initialized then
		for key, value in pairs(self.info) do
			if self.info[key] ~= _updateInfo_oldValues[key] then
				Bagshui:RaiseEvent("BAGSHUI_CHARACTER_UPDATE")
				break
			end
		end
	end
end



--- Keep money current.
function Character:UpdateMoney()
	local newMoney = _G.GetMoney()
	if not newMoney then
		return
	end
	if self.info.money ~= newMoney then
		Bagshui:RaiseEvent("BAGSHUI_MONEY_UPDATE")
	end
	self.info.money = newMoney
end



-- Reusable tables for `UpdateSkillsAndSpells()`.

local update_tempSpells = {}
local update_tempSkills = {}


--- Refresh the list of known skills and spells.
function Character:UpdateSkillsAndSpells()

	-- Backup copy to compare against so we know whether changes actually happened.
	BsUtil.TableCopy(self.spells, update_tempSpells)
	BsUtil.TableCopy(self.skills, update_tempSkills)

	-- Rebuild the lists fresh each time.
	BsUtil.TableClear(self.spells)
	BsUtil.TableClear(self.spellNamesToIds)
	for _, skillTypeList in pairs(self.skills) do
		BsUtil.TableClear(skillTypeList)
	end

	-- To get the full list of spells, we have to just keep asking GetSpellName
	-- for spells, starting at 1, until it stops answering.
	local spellNum = 1
	while true do
		local spellName, spellRank = _G.GetSpellName(spellNum, _G.BOOKTYPE_SPELL)
		if not spellName then
			break
		end
		self.spells[spellName] = spellRank
		self.spellNamesToIds[spellName] = spellNum
		spellNum = spellNum + 1
	end

	-- Iterate skills and place them in the appropriate category.
	local skillCategory
	local skip  -- Will be either nil or true depending on whether the skill is in `IGNORE_SKILL_CATEGORY`.
	for skillIndex = 1, _G.GetNumSkillLines() do
		local skillName, isHeader, _, skillRank = _G.GetSkillLineInfo(skillIndex)
		if isHeader then
			skip = IGNORE_SKILL_CATEGORY[skillName]
			if not skip then
				skillCategory = LOCALIZED_TO_EN_SKILL_ID[skillName] or skillName
				if not self.skills[skillCategory] then
					self.skills[skillCategory] = {}
				end
			end
		elseif not skip and skillCategory and skillName then
			self.skills[skillCategory][skillName] = skillRank
		end
	end

	-- Is anything different?
	if
		self.initialized
		and (
			not BsUtil.ObjectsEqual(self.spells, update_tempSpells)
			or not BsUtil.ObjectsEqual(self.skills, update_tempSkills)
		)
	then
		Bagshui:RaiseEvent("BAGSHUI_CHARACTER_UPDATE")
	end

	-- Don't need to keep contents (but do keep the tables).
	BsUtil.TableClear(update_tempSpells)
	BsUtil.TableClear(update_tempSkills)
end



--- Refresh the list of equipped armor and weapons.
function Character:UpdateGear()
	-- Bs:PrintDebug("Character:UpdateGear()")
	local historyChanged = false
	local equippedChanged = false
	local itemString, prevItemString

	for slot, localized in pairs(self.inventorySlots) do

		-- Track whether there's been a change.
		prevItemString = self.equipped[slot] and self.equipped[slot].itemString or ""

		-- Get the current item in this slot.
		itemString = BsItemInfo:ParseItemLink(
			_G.GetInventoryItemLink("player", _G.GetInventorySlotInfo(slot))
		)

		-- Ensure the slot has an item storage table available.
		if not self.equipped[slot] then
			self.equipped[slot] = {}
		end

		if itemString then
			-- Fill slot information.
			if not BsItemInfo:Get(itemString, self.equipped[slot], true, true) then
				Bagshui:PrintDebug("Character:UpdateGear() GetItemInfo failed")
			end
			-- Set `count` property to at least 1 so that the Catalog will know that this item should be added to the totals.
			self.equipped[slot].count = math.max(self.equipped[slot].count, 1)

			-- Add to history (skip bags).
			if not self.equippedHistory[itemString] and not self.bagSlots[slot] then
				self.equippedHistory[itemString] = localized
				historyChanged = true
			end
		else
			-- Wipe the slot.
			BsItemInfo:InitializeItem(self.equipped[slot])
		end

		-- Check for changes.
		if itemString ~= prevItemString then
			equippedChanged = true
		end
	end

	if equippedChanged then
		Bagshui:RaiseEvent("BAGSHUI_EQUIPPED_UPDATE")
	end
	if historyChanged then
		Bagshui:RaiseEvent("BAGSHUI_EQUIPPED_HISTORY_UPDATE")
	end
end




--- Remove the given item from the list of worn gear.
---@param itemLink string Item to remove.
function Character:RemoveFromEquippedGear(itemLink)
	if self.equippedHistory[itemLink] then
		self.equippedHistory[itemLink] = nil
		Bagshui:RaiseEvent("BAGSHUI_EQUIPPED_HISTORY_UPDATE")
	end
end



-- Remove any profession crafts/reagents that are no longer known.
function Character:PruneProfessionItems()
	if
		self:PruneItemList(self.professionCrafts)
		or
		self:PruneItemList(self.professionReagents)
	then
		Bagshui:RaiseEvent("BAGSHUI_PROFESSION_ITEM_UPDATE")
	end
end



-- Clean up the given list of crafts or reagents.
---@param list table Crafts or reagents table to process.
---@return boolean # true if any items were removed from the list.
function Character:PruneItemList(list)
	local changesMade = false
	for item, skills in pairs(list) do
		-- Clear out any skills associated with this item that this character no longer has.
		for skillName, _ in pairs(skills) do
			if not self.professions[skillName] or self.secondarySkills[skillName] then
				list[item][skillName] = nil
				changesMade = true
			end
		end
		-- If there are no skills left, remove the item.
		if BsUtil.TrueTableSize(skills) == 0 then
			list[item] = nil
			changesMade = true
		end
	end
	return changesMade
end



-- Perform a profession update.
function Character:UpdateProfessionItems(event)
	local changesMade = false

	-- Functions for professions other than Enchanting.
	local getSkillLine = _G.GetTradeSkillLine
	local getNumSkills = _G.GetNumTradeSkills
	local getSkillItemLink = _G.GetTradeSkillItemLink
	local getSkillNumReagents = _G.GetTradeSkillNumReagents
	local getSkillReagentItemLink = _G.GetTradeSkillReagentItemLink

	-- Enchanting has its own set of functions, and it's the only profession
	-- referred to as a "Craft" instead of a "TradeSkill".
	if event == "CRAFT_SHOW" then
		getSkillLine = _G.GetCraftDisplaySkillLine
		getNumSkills = _G.GetNumCrafts
		getSkillItemLink = _G.GetCraftItemLink
		getSkillNumReagents = _G.GetCraftNumReagents
		getSkillReagentItemLink = _G.GetCraftReagentItemLink
	end

	local craftName, craftType, craftItemLink, reagentItemLink

	-- Find out which profession window was opened.
	local professionName = getSkillLine()

	-- Hunter pet training window shows up as a craft with a nil professionName.
	if professionName then

		-- Process each available skill.
		local numSkills = getNumSkills()
		if numSkills > 0 then
			for skillNum = 1, numSkills do

				-- Get the name and type of item crafted by this skill (need type to make sure it's not a header).
				craftName, craftType = self:GetSkillInfo(event, skillNum)
				if craftName and craftType ~= "header" then

					-- Get the information about what this skill creates and add to list of crafts.
					craftItemLink = getSkillItemLink(skillNum)
					if self:AddProfessionItemToList(professionName, craftItemLink, self.professionCrafts) then
						changesMade = true
					end

					-- Process each reagent for this skill
					local numReagents = getSkillNumReagents(skillNum)
					if numReagents > 0 then
						for reagentNum = 1, numReagents do
							-- Add to list of reagents
							reagentItemLink = getSkillReagentItemLink(skillNum, reagentNum)
							if self:AddProfessionItemToList(professionName, reagentItemLink, self.professionReagents) then
								changesMade = true
							end
						end
					end
				end
			end
		end

	end

	-- Notify of changes.
	if changesMade then
		Bagshui:RaiseEvent("BAGSHUI_PROFESSION_ITEM_UPDATE")
	end
end



--- Add an item's ID to the given list.
---@param professionName string Name of the associated profession.
---@param itemLink string Link of item produced by the skill.
---@param list table<number, table> List to add the item to.
---@return boolean? # True if changes made to `list`, false if no changes made, or nil if the itemLink wasn't able to be processed.
function Character:AddProfessionItemToList(professionName, itemLink, list)
	if type(itemLink) ~= "string" then
		return
	end
	local _, itemId = BsItemInfo:ParseItemLink(itemLink)
	-- itemLinks from skills aren't always actual items (for example, Enchants
	-- return an "enchant:####" link instead of "item:####:####:####:####").
	-- When ParseItemLink doesn't get a normal item: link, it will return nil.
	if not itemId then
		return
	end
	-- Initialize item table if needed and store relevant profession.
	if not list[itemId] then
		list[itemId] = {}
	end
	if list[itemId][professionName] == true then
		-- Already linked to the profession.
		return false
	end
	list[itemId][professionName] = true
	-- A change was made.
	return true
end



--- GetTradeSkillInfo and GetCraftInfo return slightly different values,
--- so we can't just assign their functions directly to variables like everything
--- else in UpdateProfessionItems(). This wrapper resolves the differences.
---@param event string WoW event that triggered this update.
---@param skillNum number Current skill line number.
---@return string craftName Name of the item.
---@return string craftType "header" or difficulty of crafting.
function Character:GetSkillInfo(event, skillNum)
	local craftName, craftType
	if event == "CRAFT_SHOW" then
		craftName, _, craftType = _G.GetCraftInfo(skillNum)
	else
		craftName, craftType = _G.GetTradeSkillInfo(skillNum)
	end
	return craftName, craftType
end



--- Is the given item ID in the provided profession item list? Designed to be used from a rule function.
--- itemTable must be provided in order to allow testing against arbitrary characters, not just the current one
--- Example: BsCharacter:TestItem(rules.item.id, rules.character.professionCrafts, ruleArguments)
---@param itemId number Item ID to be checked.
---@param professionTable table Profession crafts or reagent table produced by this class.
---@param argumentList string[]? If present, array of one or more profession names that will be used to additionally filter the results. 
---@return boolean # Whether the item was found.
function Character:TestItem(itemId, professionTable, argumentList)
	if type(professionTable) ~= "table" then
		return false
	end

	-- The item needs to be in the given item table.
	if not professionTable[itemId] then
		return false
	end

	-- No arguments -- we already know this item is in the table, so return true.
	if not argumentList or type(argumentList) ~= "table" or (argumentList and table.getn(argumentList) == 0) then
		return true
	end

	-- Arguments are a list of keys (professions) for the tables within professionTable -- does this item belong to one of them?
	local allArgumentsEmptyStrings = true
	for _, argument in ipairs(argumentList) do
		argument = argument and BsUtil.Trim(tostring(argument)) or ""
		if string.len(argument) > 0 then
			allArgumentsEmptyStrings = false
			if professionTable[itemId][argument] or professionTable[itemId][L[argument]] then
				return true
			end
		end
	end

	-- We weren't actually given any keys to check, so this item matches.
	if allArgumentsEmptyStrings then
		return true
	end

	-- Default to false.
	return false
end



--- Given a skill name, return the character's current level for that skill.
---@param skillName string Skill to search for.
---@param character table? Character to check.
---@return number skillLevel Skill level, or -1 if the character doesn't have the skill.
function Character:GetSkillLevel(skillName, character)
	character = character or self.info
	for _, skills in pairs(character.skills) do
		for skill, level in pairs(skills) do
			if skill == skillName then
				return level
			end
		end
	end
	return -1
end



--- Build a `<name colored by class> [<colored faction indicator]` string.
---@param characterId string Unique character identifier.
---@param includeRealm boolean? Append the character's realm to the end.
---@return string?
function Character:FormatCharacterName(characterId, includeRealm)
	if not characterId or not Bagshui.characters[characterId] then
		return
	end
	local characterInfo = Bagshui.characters[characterId].info
	return
		-- Class color.
		(
			type(characterInfo.class) == "string"
			and (
				_G.RAID_CLASS_COLORS[string.upper(characterInfo.class)]
				and _G.RAID_CLASS_COLORS[string.upper(characterInfo.class)].colorStr
				and ("|c" .. _G.RAID_CLASS_COLORS[string.upper(characterInfo.class)].colorStr)
			)
			or NORMAL_FONT_COLOR_CODE
		)
		-- Name.
		.. characterInfo.name
		-- End class color.
		.. FONT_COLOR_CODE_CLOSE
		.. " "
		-- Faction color.
		.. (
			type(characterInfo.faction) == "string"
			and BS_FONT_COLOR["FACTION_" .. string.upper(characterInfo.faction)]
			or BS_FONT_COLOR.FACTION_UNKNOWN
		)
		-- Faction letter.
		.. "[" .. (string.len(characterInfo.faction or "") > 0 and string.sub(characterInfo.faction, 1, 1) or "?") .. "]"
		-- End faction color.
		.. FONT_COLOR_CODE_CLOSE
		-- Realm.
		.. (
			includeRealm
			and GRAY_FONT_COLOR_CODE .. " • " .. characterInfo.realm .. FONT_COLOR_CODE_CLOSE
			or ""
		)
end



-- Class event registration.
-- This is done at the end because RegisterEvent expects the class to have an OnEvent function.
for event, enabled in pairs(CHARACTER_EVENTS) do
	Bagshui:RegisterEvent(event, Character)
end
-- Money money money.
for event, enabled in pairs(MONEY_EVENTS) do
	if enabled then
		Bagshui:RegisterEvent(event, Character)
	end
end



-- Make a first pass at grabbing character information. Only some data is typically
-- available right away, with UnitFactionGroup() returning nil and UnitLevel()
-- returning 0 until shortly after PLAYER_ENTERING_WORLD, so we also make a fill-in
-- pass with dummy values. The second call to UpdateInfo that occurs shortly after
-- PLAYER_ENTERING_WORLD should rectify the missing properties.
-- One important reason to do this is to avoid errors during initial rule validation,
-- which gets upset if BsCharacter.info.localizedClass is nil.
Character:UpdateInfo()
for property, initialValue in pairs(CHARACTER_INFO_MINIMUM_PROPERTIES) do
	if not currentCharacterInfo[property] then
		currentCharacterInfo[property] = initialValue
	end
end


end)