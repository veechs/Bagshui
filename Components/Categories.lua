-- Bagshui Categories
-- Exposes: BsCategories (and Bagshui.components.Categories)
-- Raises: BAGSHUI_CATEGORY_UPDATE
-- 
-- The high-level flow of categorization and rule evaluation is as follows:
-- 1. During inventory layout updates, Categories:Categorize() is called for each item.
-- 2. Categories:Categorize() loops through all active categories [any category assigned to a group], in category sequence order.
-- 3. For each category, Categories:MatchCategory() is called.
-- 4. Categories:MatchCategory() calls Rules:Match() with the finalized rule.
-- 5. Rules:Match() executes the rule it within the protected rule environment and returns true if it matches.
-- 6. Once a match is found, Categories:Categorize() updates the bagshuiGroupId, bagshuiCategoryId, and uncategorized properties.

Bagshui:AddComponent(function()


Bagshui:AddConstants({

	-- Allowed properties.
	BS_CATEGORY_SKELETON = {
		-- Category name.
		name = "",
		-- Alternate name to be used in sorting.
		nameSort = "",

		-- Global evaluation ordering.
		sequence = 0,

		-- Array of item IDs (the 0 in the array is so that TableCopy will know what type of value is allowed).
		list = { 0 },
		-- Rule expression.
		rule = "",

		classes = {
			-- Class categories can have any valid player class (DRUID, HUNTER, etc.) as the key.
			-- That is expressed here by putting the GameInfo.characterClasses table as the key within
			-- the template, which Util.TableClear() knows to interpret as a list of valid keys.
			-- IMPORTANT: There is code in Categories.Ui.lua that depends on this table.
			[BsGameInfo.characterClasses] = {
				list = { 0 },  -- List of item IDs.
				rule = "",  -- Rule expression.
			},
		},
	},

	-- Template for creating a new standard category.
	BS_NEW_CATEGORY_TEMPLATE = {
		name     = "",
		nameSort = "",
		sequence = BS_DEFAULT_CATEGORY_SEQUENCE,
		list     = {},
		rule     = "",
	},

	-- Template for creating a new class category.
	BS_NEW_CLASS_CATEGORY_TEMPLATE = {
		name         = "",
		nameSort     = "",
		sequence     = BS_DEFAULT_CATEGORY_SEQUENCE,
		classes      = {},
	},

	-- Which template properties can be used in sort orders?
	BS_CATEGORY_PROPERTIES_ALLOWED_IN_SORT_ORDERS = {
		"name",
	},

})


-- Key in _G.BagshuiData where categories will be stored.
local CATEGORIES_DATA_STORAGE_KEY = "categories"


-- Categories class is built on the ObjectList prototype.
local Categories = Bagshui.prototypes.ObjectList:New({

	dataStorageKey = CATEGORIES_DATA_STORAGE_KEY,
	objectVersion = Bagshui.config.Categories.version,
	objectMigrationFunction = Bagshui.config.Categories.migrate,
	objectName = "Category",
	objectNamePlural = "Categories",
	objectSkeleton = BS_CATEGORY_SKELETON,
	objectTemplate = BS_NEW_CATEGORY_TEMPLATE,
	defaults = Bagshui.config.Categories.defaults,
	defaultObjectValues = {
		-- Put built-in rules without a specified sequence higher than the user default.
		sequence = BS_DEFAULT_BUILTIN_CATEGORY_SEQUENCE,
	},
	wikiPage = BS_WIKI_PAGES.Categories,

	-- Default category ID when Categories:Categorize() can't find a match.
	defaultCategory = BS_DEFAULT_CATEGORY_ID,

	-- "Compiled" rules i.e. rule expressions run through `loadstring()`.
	finalizedCategoryRules = {},

	-- Error tracking.
	errors = {},  -- Errors for all categories.
	recentErrors = {},  -- Errors only stored until `Categories:ClearErrors()` is called.

	-- There's some initialization that needs to happen on `PLAYER_ENTERING_WORLD`
	-- (see `Categories:OnEvent()`), but that event fires when zoning and we
	-- only want to do the stuff once.
	finalInitComplete = false,

	-- Debug.
	debugResetOnLoad = false and BS_DEBUG,
})



--- Initialize categories list.
function Categories:Init()

	-- Add sorting by sequence (doing this before superclass init so that it will get sorted automatically).
	self.sortedIdLists.sequence = {}
	self.idListSortFunctions.sequence = function(idA, idB)
		return (self._idListSortFunctions_objectList[idA].sequence or BS_DEFAULT_CATEGORY_SEQUENCE) < (self._idListSortFunctions_objectList[idB].sequence or BS_DEFAULT_CATEGORY_SEQUENCE)
	end

	-- Calls ObjectList:Init().
	self._super.Init(self, true)


	-- Add auto-split Categories menu.
	Bagshui.prototypes.Menus:AddAutoSplitMenu(
		BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
		{
			defaultIdList = self.sortedIdLists.name,
			sortFunc = function(categoryIds)
				self:SortIdList(categoryIds, nil, "name")
			end,
			nameFunc = function(id)
				return self:GetName(id) or tostring(id)
			end,
		}
	)

	-- Register events.
	Bagshui:RegisterEvent("PLAYER_ENTERING_WORLD", self)
	Bagshui:RegisterEvent("BAGSHUI_CATEGORIES_CACHE_LOAD", self)

	self.initialized = true

end



--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function Categories:OnEvent(event, arg1)
	--Bagshui:PrintDebug("Categories OnEvent " .. event .. " (prototype: " .. tostring(self == Categories) .. ")")

	-- Check to see if the ObjectList prototype is handling this event
	if self._super.OnEvent(self, event, arg1) then
		return
	end

	-- After PLAYER_ENTERING_WORLD, wait a bit and finish loading.
	if event == "PLAYER_ENTERING_WORLD" and not self.finalInitComplete then
		-- Need to wait to finalize rules so 3rd party integrations can register first.
		Bagshui:QueueClassCallback(self, self.FinalizeAllRules, 1)
		-- Don't make the client too busy with server queries immediately.
		Bagshui:QueueEvent("BAGSHUI_CATEGORIES_CACHE_LOAD", 3)
		-- Make sure this only happens once.
		self.finalInitComplete = true
		return
	end

	-- Queued event has fired, so perform the item cache load.
	if event == "BAGSHUI_CATEGORIES_CACHE_LOAD" then
		self:LoadListItemsIntoGameCache()
		return
	end

end



--- Ensure all items referenced in category item lists are in the local cache so that GetItemInfo() works.
--- (There's too much of a delay to try and do this in real-time while editing a category).
function Categories:LoadListItemsIntoGameCache()
	if self.finalInitComplete then
		return
	end
	for _, category in pairs(self.list) do
		if category.classes then
			for _, classCategory in pairs(category.classes) do
				self:ItemInfoCacheLoad(classCategory.list)
			end
		else
			self:ItemInfoCacheLoad(category.list)
		end
	end
end



--- Helper for LoadListItemsIntoGameCache() to share code between standard and class categories.
function Categories:ItemInfoCacheLoad(itemList)
	if type(itemList) == "table" and table.getn(itemList) > 0 then
		for _, itemId in pairs(itemList) do
			BsItemInfo:LoadItemIntoLocalGameCache(itemId)
		end
	end
end



--- See `ObjectList:GetUses()`.
---@param objectId string|number
---@param objectMetadata table Metadata about the object.
---@return boolean inUse Whether the object is being used.
function Categories:GetUses(objectId, objectMetadata)
	return BsProfiles:GetProfilesUsingObject(objectId, objectMetadata, BsCategories)
end



--- Things that need to happen before ObjectList:Save() actually saves the category.
---@param categoryId string|number ID of the new category.
---@param category table New category information.
function Categories:DoPreSaveOperations(categoryId, category)

	-- Don't allow empty rules or lists
	if category.rule and string.len(tostring(category.rule)) == 0 then
		category.rule = nil
	end
	if type(category.list) ~= "table" or (type(category.list) == "table" and table.getn(category.list) == 0) then
		category.list = nil
	end

	-- Default sequence number / type check
	if not category.sequence then
		category.sequence = BS_DEFAULT_CATEGORY_SEQUENCE
	end
	if type(category.sequence) ~= "number" then
		category.sequence = tonumber(category.sequence)
	end

end



--- Things that need to happen after ObjectList:Save() actually saves the category.
---@param categoryId string|number ID of the new category.
---@param category table New category information.
function Categories:DoPostSaveOperations(categoryId, category)

	-- Sort list entries so they look good in the editor.
	if type(category.list) == "table" and table.getn(category.list) > 0 then
		table.sort(
			category.list,
			function(itmA, itmB)
				local itmAName = _G.GetItemInfo(itmA)
				local itmBName = _G.GetItemInfo(itmB)
				return string.lower(itmAName or "") < string.lower(itmBName or "")
			end
		)
	end

	-- Compile the rule functions.
	-- Blocking this at startup because FinalizeAllRules() will take care of the first compile.
	if self.initialized then
		self:FinalizeCategoryRules(categoryId, true)
	end

end



--- Loop through all categories and pre-compile them.
function Categories:FinalizeAllRules()
	if type(self.list) ~= "table" then
		return
	end
	for categoryId, _ in pairs(self.list) do
		self:FinalizeCategoryRules(categoryId, true)
	end
	-- Need to reset recent errors to avoid the error indicator from showing up
	-- in the Inventory window regardless of errors in the current Structure.
	self:ClearErrors()
end



--- "Compile" a category's rule expression(s) by passing to `Categories:FinalizeRule()`.
--- This wrapper is needed because class categories can contain one rule per class.
---@param categoryId string|number ID of the category.
---@param recompile boolean true to force recompilation.
function Categories:FinalizeCategoryRules(categoryId, recompile)
	assert(categoryId, "categoryId must be specified")

	local category = self:Get(categoryId)

	if category.classes then
		for class, classCategory in pairs(category.classes) do
			self:FinalizeRule(categoryId, classCategory, class, recompile)
		end
	else
		self:FinalizeRule(categoryId, category, nil, recompile)
	end

end




--- "Compile" a category's rule expression(s) by passing to `Rules:Compile()`.
--- Ultimately this will run it through loadstring() to produce a function.
--- Store the result in `Categories.finalizedCategoryRules` so we don't have
--- to do this over and over while categorizing items.
---@param categoryId string|number ID of the category.
---@param category table Category object.
---@param ruleIdSuffix string? Suffix to uniquely identify the compiled rule.
---@param recompile boolean true to force recompilation.
---@return function compiledRule
function Categories:FinalizeRule(categoryId, category, ruleIdSuffix, recompile)
	assert(categoryId, "categoryId must be specified")
	assert(category, "category must be specified")

	--Bagshui:PrintDebug("FinalizeRule: "..categoryId)
	local finalRuleId = self:BuildFinalizedRuleId(categoryId, ruleIdSuffix)

	-- When a recompile isn't being forced and the finalized rule already exists, just return it.
	-- This optimization is leveraged by MatchCategory() to avoid constantly calling loadstring().
	if self.finalizedCategoryRules[finalRuleId] and not recompile then
		return self.finalizedCategoryRules[finalRuleId]
	end

	-- Otherwise, proceed with compiling/recompiling the rule.
	local finalRule = ""
	category.ruleError = nil

	-- Remove previously compiled rule if it exists.
	-- This does mean that when a rule is changed and the recompile fails, the rule will become invalid.
	self.finalizedCategoryRules[finalRuleId] = nil

	-- The rule expression is the category.rule property, so long as it's not the magic
	-- match-anything "*".
	if type(category.rule) == "string" and string.len(category.rule) > 0 and category.rule ~= "*" then
		finalRule = category.rule
	end


	-- Handling item lists in MatchCategory() instead of here to improve efficiency;
	-- it just loops through the list looking for an ID match instead of invoking
	-- the overhead of the rules engine.
	-- if type(category.list) == "table" and table.getn(category.list) > 0 then
	-- 	if string.len(finalRule) > 0 then
	-- 		finalRule = "(" .. finalRule .. ") or "
	-- 	end
	-- 	finalRule = finalRule .. "id(" .. table.concat(category.list, ",") .. ")"


	-- Make sure there's a rule to compile.
	if string.len(finalRule) > 0 then

		-- Validate before compiling and store status.
		local valid, errorMessage = BsRules:Validate(category.rule)
		if valid then
			-- Compile the rule once we know it's good.
			self.finalizedCategoryRules[finalRuleId] = BsRules:Compile(finalRule)
			self:ClearError(categoryId)
		else
			category.ruleError = errorMessage
			self:ReportError(categoryId, errorMessage)
		end

	end

	return self.finalizedCategoryRules[finalRuleId]
end



--- Create a unique ID for a rule based on the category ID and optional suffix.
---@param categoryId string|number ID of the category.
---@param ruleIdSuffix string? Suffix to uniquely identify the compiled rule.
---@return string ruleId `"<categoryId>:[<ruleIdSuffix>]"`
function Categories:BuildFinalizedRuleId(categoryId, ruleIdSuffix)
	return categoryId .. (ruleIdSuffix and (":" .. tostring(ruleIdSuffix)) or "")
end




--- Given an item, a list of sequenced category IDs, a table mapping categories to group IDs,
--- and a default category ID, determine the category to which that item should be assigned.
---@param item table An item from the Bagshui inventory cache (should be based on `BS_ITEM_SKELETON`).
---@param character table? Character information table (uses `Bagshui.currentCharacterInfo` if not provided).
---@param sortedSequenceNumbers number[] An array of numbers that correspond to indexes of the `categoriesToGroups` table. This is what dictates priority of category evaluation.
---@param categoriesToGroups table Table of `{ <sequence number> = { categoryId1 = groupId1, categoryId2, = groupId2 } }`. (The `categoryIdsGroupedBySequence` table produced by `Inventory:UpdateLayoutLookupTables()`).
---@param defaultCategoryId string|number? If no matching category is found, assign the item to this category. (When not specified, use `Categories.defaultCategoryId`).
function Categories:Categorize(item, character, sortedSequenceNumbers, categoriesToGroups, defaultCategoryId)
	if not item then
		return
	end

	character = character or Bagshui.currentCharacterInfo
	defaultCategoryId = defaultCategoryId or self.defaultCategory

	-- Start a rule engine session so that we can call BsRules:Match() without needing to constantly check/update Rules.item and Rules.character.
	local ruleSession = BsRules:SetItemAndCharacter(item, character)

	-- Process categories in sequence order.
	for _, sequenceNum in ipairs(sortedSequenceNumbers) do
		--Bagshui:PrintDebug("processing categories with sequence #"..sequenceNum)
		for categoryId, groupId in pairs(categoriesToGroups[sequenceNum]) do
			--Bagshui:PrintDebug("testing category ID " .. categoryId)
			-- Try to match the category.
			if
				groupId
				and string.len(groupId or "") > 0
				and self:MatchCategory(categoryId, item, character, ruleSession)
			then
				--Bagshui:PrintDebug("Category " .. categoryId .. " and group " .. groupId .. " assigned to " .. item.name)
				item.bagshuiGroupId = groupId
				item.bagshuiCategoryId = categoryId
				item.uncategorized = (categoryId == defaultCategoryId) and 1 or 0
				return
			end
		end
	end

	-- If we make it this far, assign the default category.
	Bagshui:PrintDebug(tostring(item.Name) .. " is uncategorized")
	item.bagshuiGroupId = categoriesToGroups[defaultCategoryId]
	item.bagshuiCategoryId = defaultCategoryId
	item.uncategorized = 1

end



-- Reusable variables for MatchCategory() to reduce garbage collector load.
local category, ruleIdSuffix, finalRule, status, retVal, errorMessage

--- Return true/false based on whether the given item matches the given category
---@param categoryId string|number ID of the category.
---@param item table An item from the Bagshui inventory cache.
---@param character table? Character information table (uses `Bagshui.currentCharacterInfo` if not provided).
---@param ruleSession number Rule session ID from `Rules:SetItemAndCharacter()`.
---@return boolean
function Categories:MatchCategory(categoryId, item, character, ruleSession)
	category = self:Get(categoryId)
	if not category then
		return false
	end

	-- Very fast processing for catchall category.
	if category.rule == "*" then
		return true
	end

	ruleIdSuffix = nil
	character = character or Bagshui.currentCharacterInfo

	-- Class-specific categories.
	if category.classes then
		-- Redefine the category reference to be the class-specific category.
		category = category.classes[character.class]
		-- There's nothing to try and match when there's not an entry for the current class.
		if not category then
			return false
		end
		-- When this class-specific rule is compiled, make it unique by adding the class name as the ID suffix.
		ruleIdSuffix = character.class
	end

	-- Try to match item lists first.
	if type(category.list) == "table" and table.getn(category.list) > 0 then
		for _, itemId in ipairs(category.list) do
			if itemId == item.id then
				return true
			end
		end
	end

	-- If the rule is in error status, just fail (checking this here makes sense
	-- because item lists can't have errors).
	if category.ruleError then
		self:ReportError(categoryId, category.ruleError)
		return false
	end

	-- Quick fail if no rule.
	if not category.rule or string.len(tostring(category.rule)) == 0 then
		return false
	end

	-- Get the compiled rule to be evaluated.
	finalRule = self:FinalizeRule(categoryId, category, ruleIdSuffix, false)

	-- Final check to ensure there's a rule to execute.
	if not finalRule or type(finalRule) ~= "function" then
		return false
	end

	-- Do the test.
	retVal, errorMessage = BsRules:Match(finalRule, item, character, ruleSession)

	if errorMessage == nil then
		-- Successful rule evaluation, return rule function value.
		return retVal

	else
		self:ReportError(categoryId, errorMessage)
		return false
	end
end



-- Reusable variables for ReportError() to reduce garbage collector load.
local formattedMessage

--- Display an error when so long as it hasn't yet been shown.
---@param categoryId any
---@param errorMessage any
function Categories:ReportError(categoryId, errorMessage)
	assert(categoryId, "categoryId must be specified")
	if not self.errors[categoryId] or not self.recentErrors[categoryId] then
		formattedMessage = self:FormatErrorMessage(errorMessage, categoryId)
		self.errors[categoryId] = formattedMessage
		self.recentErrors[categoryId] = formattedMessage
		-- Don't spam chat with errors at startup.
		if self.initialized then
			Bagshui:PrintError(formattedMessage, L.Category)
		end
	end
end



--- Given information about an error, fill out the error message template.
---@param errorMessage string The error.
---@param categoryId string|number ID of the category that caused the error.
---@param categoryName string? Category name. If not provided, the category ID will be used to look it up. Or if nothing is found, this is assumed to be a new category.
---@return string errorMessage Display-ready error message.
function Categories:FormatErrorMessage(errorMessage, categoryId, categoryName)
	return string.format(
		L.Error_CategoryEvaluation,
		tostring(categoryName or (self.list[categoryId] and self.list[categoryId].name) or string.format(L.Prefix_New, L.Category)),
		tostring(errorMessage)
	)
end



--- Reset error tracking. Only clears `recentErrors` unless `all` is `true`.
---@param all boolean?
function Categories:ClearErrors(all)
	BsUtil.TableClear(self.recentErrors)
	if all then
		BsUtil.TableClear(self.errors)
	end
end



--- Reset all error tracking for a specific category.
---@param categoryId string|number ID of the category.
---@param all boolean?
function Categories:ClearError(categoryId, all)
	assert(categoryId, "categoryId must be specified")
	self.recentErrors[categoryId] = nil
	self.errors[categoryId] = nil
end



--- Get all current errors as a single newline-separated string.
--- Returns the contents of `recentErrors` unless `all` is `true`.
---@param all boolean?
---@return string errors
function Categories:GetErrors(all)
	local errorTable = all and self.errors or self.recentErrors
	if BsUtil.TrueTableSize(errorTable) == 0 then
		return ""
	end
	local errors = ""
	for _, categoryId in ipairs(self.sortedIdLists.name) do
		if errorTable[categoryId] then
			errors = errors .. (string.len(errors) > 0 and BS_NEWLINE or "") .. errorTable[categoryId]
		end
	end
	return errors
end




--- Obtain the list of categories to which a given item ID has been manually assigned.
---@param itemId number Item ID.
---@param categoryIdListOutput any[] Array to fill with category IDs (will be cleared).
---@param limitToCategoryIds (string|number)[]? When provided, only allow category IDs within this array to be matched.
function Categories:GetDirectCategoryAssignmentsForItem(itemId, categoryIdListOutput, limitToCategoryIds)
	assert(type(categoryIdListOutput) == "table", "Categories:GetDirectCategoryAssignmentsForItem(): categoryIdListOutput is required and must be the table to fill.")
	BsUtil.TableClear(categoryIdListOutput)
	for categoryId, categoryInfo in pairs(self.list) do
		if categoryInfo.classes ~= nil then
			for class, classInfo in pairs(categoryInfo.classes) do
				self:ItemInDirectAssignmentList(
					classInfo.list,
					categoryId,
					itemId,
					categoryIdListOutput,
					limitToCategoryIds
				)
			end
		else
			self:ItemInDirectAssignmentList(
				categoryInfo.list,
				categoryId,
				itemId,
				categoryIdListOutput,
				limitToCategoryIds
			)
		end
	end
end



--- Test whether the given Category contains the specified item ID in its Direct Assignment list.
--- Two modes:
--- 1. Helper for `Categories:GetDirectCategoryAssignmentsForItem()` to fill `categoryIdListOutput`.
--- 2. Return `true` if the Category has the item. Used for Direct Assignment Class menus in Edit Mode.
---@param list number[]? Direct Assignment list.
---@param itemId number Item ID.
---@param categoryId number|string Unique Category identifier.
---@param categoryIdListOutput? any[] See `Categories:GetDirectCategoryAssignmentsForItem()`
---@param limitToCategoryIds (string|number)[]? See `Categories:GetDirectCategoryAssignmentsForItem()`
---@param class string? Required if `list` is not provided and `categoryId` represents a Class Category.
---@return boolean?
function Categories:ItemInDirectAssignmentList(list, categoryId, itemId, categoryIdListOutput, limitToCategoryIds, class)
	if not list then
		local categoryInfo = self.list[categoryId]
		if not categoryInfo then
			return
		end
		if categoryInfo.classes then
			if
				not class
				or not categoryInfo.classes[class]
			then
				return
			end

			list = categoryInfo.classes[class].list
		else
			list = categoryInfo.list
		end
	end

	if type(list) == "table" then
		for i, categoryItemId in ipairs(list) do
			if
				categoryItemId == itemId
				and (
					(limitToCategoryIds and BsUtil.TableContainsValue(limitToCategoryIds, itemId) ~= nil)
					or not limitToCategoryIds
				)
			then
				if categoryIdListOutput then
					table.insert(categoryIdListOutput, categoryId)
				end
				return true
			end
		end
	end
end



--- Directly assign an item to a category.
---@param categoryId string|number
---@param itemId string|number
---@param class string? Required for class categories.
function Categories:AssignItemToCategory(categoryId, itemId, class)
	assert(itemId, "Categories:AssignItemToCategory(): itemID is required.")

	local categoryInfo = self.list[categoryId]
	if not categoryInfo then
		return
	end

	local list

	if categoryInfo.classes ~= nil then
		assert(class, "Categories:AssignItemToCategory(): class is required for Class Categories.")

		if not categoryInfo.classes[class] then
			categoryInfo.classes[class] = {}
		end
		if not categoryInfo.classes[class].list then
			categoryInfo.classes[class].list = {}
		end

		list = categoryInfo.classes[class].list

	else
		if not categoryInfo.list then
			categoryInfo.list = {}
		end
		list = categoryInfo.list
	end

	if not list then
		return
	end

	if BsUtil.TableContainsValue(list, itemId) == nil then
		table.insert(list, itemId)
	end
	self:Save(categoryId, categoryInfo)
end



--- Remove the direct assignment of an item to a category.
---@param categoryId string|number
---@param itemId string|number
---@param class string? Required for class categories.
function Categories:RemoveItemFromCategory(categoryId, itemId, class)
	assert(itemId, "Categories:RemoveItemFromCategory(): itemID is required.")

	local categoryInfo = self.list[categoryId]
	if not categoryInfo then
		return
	end

	local list = categoryInfo.list

	if categoryInfo.classes ~= nil then
		assert(class, "Categories:RemoveItemFromCategory(): class is required for Class Categories.")

		if not categoryInfo.classes[class] then
			return
		end

		list = categoryInfo.classes[class].list
	end

	if not list then
		return
	end

	BsUtil.TableRemoveArrayItem(list, itemId)
	self:Save(categoryId, categoryInfo)
end



--- Assign/unassign and item to a category, depending on its current status.
---@param categoryId string|number
---@param itemId string|number
---@param class string? Required for class categories.
function Categories:ToggleItemCategoryAssignment(categoryId, itemId, class)
	assert(itemId, "Categories:ToggleItemCategoryAssignment(): itemID is required.")

	local categoryInfo = self.list[categoryId]
	if not categoryInfo then
		return
	end

	local list = categoryInfo.list

	if categoryInfo.classes ~= nil then
		assert(class, "Categories:ToggleItemCategoryAssignment(): class is required for Class Categories.")

		if
			categoryInfo.classes[class]
			and categoryInfo.classes[class].list
		then
			list = categoryInfo.classes[class].list
		end
	end

	if list and BsUtil.TableContainsValue(list, itemId) ~= nil then
		self:RemoveItemFromCategory(categoryId, itemId, class)
	else
		self:AssignItemToCategory(categoryId, itemId, class)
	end
end



--- Obtain the list of all categories that match an item, whether via rules or direct assignment.
---@param item table Bagshui item cache entry.
---@param character table? Character to use for rule matching.
---@param categoryIdListOutput any[] Array to fill with category IDs (will be cleared).
function Categories:GetAllMatchingCategoriesForItem(item, character, categoryIdListOutput)
	assert(type(categoryIdListOutput) == "table", "Categories:GetDirectCategoryAssignmentsForItem(): categoryIdListOutput is required and must be the table to fill.")
	if type(categoryIdListOutput) ~= "table" then
		categoryIdListOutput = {}
	else
		BsUtil.TableClear(categoryIdListOutput)
	end
	local ruleSession = BsRules:SetItemAndCharacter(item)
	for categoryId, _ in pairs(self.list) do
		if self:MatchCategory(categoryId, item, character, ruleSession) then
			table.insert(categoryIdListOutput, categoryId)
		end
	end

end



-- Exports and initialization
Bagshui.environment.BsCategories = Categories
Bagshui.components.Categories = Categories
Bagshui:RegisterEvent("BAGSHUI_ADDON_LOADED", Categories)


end)