-- Bagshui Active Sort Order Management
-- Exposes: BsSortOrders (and Bagshui.components.SortOrders)
-- Raises: BAGSHUI_SORTORDER_UPDATE

Bagshui:AddComponent(function()


Bagshui:AddConstants({

	-- Allowed properties and default values.
	BS_SORT_ORDER_SKELETON = {
		name   = "",
		fields = {
			-- This permits an array of tables containing:
			{
				lookup       = "",
				field        = "",
				direction    = "asc",
				reverseWords = false,
			}
		},
	},

	-- Template for creating a new sort order.
	BS_NEW_SORT_ORDER_TEMPLATE = {
		name = "",
		fields = {},
	}

})


-- Key in _G.BagshuiData where sort orders will be stored.
local SORT_ORDERS_DATA_STORAGE_KEY = "sortOrders"


-- SortOrders class is built on the ObjectList prototype.
local SortOrders = Bagshui.prototypes.ObjectList:New({

	dataStorageKey = SORT_ORDERS_DATA_STORAGE_KEY,
	objectVersion = Bagshui.config.SortOrders.version,
	objectMigrationFunction = Bagshui.config.SortOrders.migrate,
	objectName = "SortOrder",
	objectNamePlural = "SortOrders",
	objectSkeleton = BS_SORT_ORDER_SKELETON,
	objectTemplate = BS_NEW_SORT_ORDER_TEMPLATE,
	defaults = Bagshui.config.SortOrders.defaults,
	wikiPage = BS_WIKI_PAGES.SortOrders,

	-- Can't initialize until Categories are done.
	initEvent = "BAGSHUI_CATEGORIES_LOADED",

	-- Lists of valid item fields, populated by AddValidItemFields.
	validItemFields = {},
	sortFields = {},
	sortFieldsSortedByName = {},

	-- Properties that need to be looked up in a table that isn't the item.
	-- ```
	-- <Lookup Name> = {
	-- 	property = "",
	-- 	table = <Lookup Table>,
	-- }
	-- ```
	-- Populated by AddValidItemFields().
	itemFieldLookups = {},

	-- Debug.
	debugResetOnLoad = false and BS_DEBUG,
})

Bagshui.environment.BsSortOrders = SortOrders
Bagshui.components.SortOrders = SortOrders



--- Initialization of Sort Orders depends on having the Categories class initialized
--- because of BS_CATEGORY_PROPERTIES_ALLOWED_IN_SORT_ORDERS. To deal with this,
--- Categories raises BAGSHUI_CATEGORIES_LOADED and we initialize based on that event.
function SortOrders:Init()

	-- Build list of field names that are valid for use in sort orders.

	-- Item properties.
	self:AddValidItemFields(
		BS_ITEM_PROPERTIES_ALLOWED_IN_SORT_ORDERS,
		BS_ITEM_SKELETON
	)

	-- Category properties as `Category.<property>`.
	self:AddValidItemFields(
		BS_CATEGORY_PROPERTIES_ALLOWED_IN_SORT_ORDERS,
		BS_CATEGORY_SKELETON,
		"Category",
		"bagshuiCategoryId",
		BsCategories.list
	)


	-- Load default sort orders and do other prototype class initialization.
	-- IMPORTANT: This can't happen until after valid field lists are built.
	-- Calls ObjectList:Init().
	self._super.Init(self)


	-- Link the list of sort orders to the defaultSortOrder setting's list of valid choices.
	-- This will let the Settings class know which sort orders are valid.
	Bagshui.prototypes.Settings._settingInfo.defaultSortOrder.choices = self.list


	-- Add the auto-split menus.

	-- Sort Orders (used in Settings and Group menus).
	Bagshui.prototypes.Menus:AddAutoSplitMenu(
		BS_AUTO_SPLIT_MENU_TYPE.SORT_ORDERS,
		{
			defaultIdList = self.sortedIdLists.name,
			sortFunc = function(sortOrderIds)
				self:SortIdList(sortOrderIds)
			end,
			nameFunc = function(id)
				return self:GetName(id) or tostring(id)
			end,
			tooltipTitleFunc = function()
				-- Since sort order names can be long, just display "Details:" as the tooltip title.
				return string.format(L.Symbol_Colon, L.Details)
			end,
			tooltipTextFunc = function(id, originalTooltipText)
				if not id then
					return originalTooltipText
				end
				-- Create a tooltip with one line per field, formatted like:
				-- Category Name ASC
				-- Type ASC
				-- Subtype ASC
				-- Quality DESC
				-- Name [reversed] ASC
				-- count DESC
				-- bagNum ASC
				-- slotNum ASC
				local tooltipText
				for _, sort in pairs(self.list[id].fields) do
					tooltipText =
						(tooltipText and tooltipText .. BS_NEWLINE or "")
						.. self.sortFields[self:GetFieldIdentifier(sort.field, sort.lookup, "::")].friendlyName
					if sort.reverseWords then
						tooltipText = string.format(L.Suffix_Reversed, tooltipText)
					end
					tooltipText = tooltipText .. " " .. LIGHTYELLOW_FONT_COLOR_CODE .. string.lower(sort.direction) .. FONT_COLOR_CODE_CLOSE
				end
				return tooltipText
			end,
			extraItems = {
				{
					text = string.format(L.Symbol_Ellipsis, L.Manage),
					tooltipTitle = L.Manage,
					tooltipText = string.format(L.Prefix_Manage, L.SortOrders),
					checked = false,
					value = {
						func = function()
							Bagshui:CloseMenus()
							self:Open()
						end,
					},
				}
			}
		}
	)

	-- Sort Fields (used by Sort Order editor).
	Bagshui.prototypes.Menus:AddAutoSplitMenu(
		BS_AUTO_SPLIT_MENU_TYPE.SORT_FIELDS,
		{
			defaultIdList = self.sortFieldsSortedByName,
			sortFunc = function(sortFieldIds)
				-- Don't need to do anything here - these don't ever change after startup.
			end,
			nameFunc = function(id, menuValue)
				return self.sortFields[id].friendlyName
			end,
		}
	)

end



-- Using a list of valid fields and an object template (table of `<fieldName> = <defaultValue>`), populate the validItemFields table.
---@param validFieldList string[] Array of fields that are allowed in sorting.
---@param objectTemplate table<string,string> List of `{ [fieldName] = [defaultValue] }`, used to figure out field type.
---@param lookupObjectName string? Name of the "lookup object" (for example, "Category").
---@param lookupProperty string? When lookup = lookupObjectName is encountered in a sort order, what item property should be used to find the lookup object (i.e. bagshuiCategoryId).
---@param lookupTable table? Where can the object identified by lookupObjectProperty be found? (for example, BsCategories.list).
function SortOrders:AddValidItemFields(validFieldList, objectTemplate, lookupObjectName, lookupProperty, lookupTable)
	assert(not lookupObjectName or (lookupObjectName and lookupProperty and lookupTable), "SortOrders:AddValidItemFields(): All lookup parameters are required when one is provided")

	-- This is a lookup object, so store lookup information.
	if string.len(lookupObjectName or "") > 0 then
		self.itemFieldLookups[lookupObjectName] = {
			property = lookupProperty,
			table = lookupTable,
		}
	end

	-- Iterate the list of fields and save information.
	for _, fieldName in pairs(validFieldList) do

		-- Add to the lists of available fields.
		local uniqueName = self:GetFieldIdentifier(fieldName, lookupObjectName)
		self.sortFields[uniqueName] = {
			friendlyName = self:GetFieldIdentifier(L["ItemPropFriendly_" .. fieldName], lookupObjectName, " "),
			property = fieldName,
			type = type(objectTemplate[fieldName]),
			allowReverseWords = (fieldName == "name"), -- Hardcoding this as I can't currently think of any scenario where anything other than item name would makes sense for reversed words.
			lookup = lookupObjectName,
			lookupProperty = lookupProperty,
			lookupTable = lookupTable,
		}

		table.insert(self.sortFieldsSortedByName, uniqueName)
	end

	table.sort(self.sortFieldsSortedByName)
end



-- Generate a unique ID for fields and to create their friendly name (when a space is passed in for separator).
---@param fieldName string Name of the field.
---@param lookupObjectName string? Name of the "lookup object" (for example, "Category"), if any.
---@param separator string? String to use between lookup object name and field name.
---@return string fieldIdentifier [lookupObjectName][separator][fieldName]
function SortOrders:GetFieldIdentifier(fieldName, lookupObjectName, separator)
	return (lookupObjectName and (lookupObjectName .. (separator or "::")) or "") .. fieldName
end



--- See `ObjectList:GetUses()`.
---@param objectId string|number
---@param objectMetadata table Metadata about the object.
---@return boolean inUse Whether the object is being used.
function SortOrders:GetUses(objectId, objectMetadata)
	return BsProfiles:GetProfilesUsingObject(objectId, objectMetadata, BsSortOrders)
end



-- Ensure the sort order is valid before saving.
---@param sortOrderId string|number ID of the sort order being saved.
---@param sortOrderInfo table Sort order object to be saved.
function SortOrders:DoPreSaveOperations(sortOrderId, sortOrderInfo)
	if not self:ValidateSortOrder(sortOrderId, sortOrderInfo) then
		return
	end
end



--- Test whether the given sort order is valid.
--- Throws an error if it's invalid.
---@param sortOrderId string|number
---@param sortOrderInfo table<string,any> Sort order object to validate.
---@return boolean
function SortOrders:ValidateSortOrder(sortOrderId, sortOrderInfo)
	assert(sortOrderId, "sortOrderId is required to perform validation")
	local baseError = "Sort order " .. sortOrderId .. " failed validation: "
	assert(sortOrderInfo.name, baseError .. "name is missing")
	assert(sortOrderInfo.fields, baseError .. "fields is missing")

	for _, sort in pairs(sortOrderInfo.fields) do
		local fieldId = self:GetFieldIdentifier(sort.field, sort.lookup)
		assert(self.sortFields[fieldId], baseError .. self:GetFieldIdentifier(sort.field, sort.lookup, ".") .. " is not a valid sort field")

		-- Ensure a valid value for asc/desc.
		if BsUtil.Trim(string.lower(sort.direction or "")) == "desc" then
			sort.direction = "desc"
		else
			sort.direction = "asc"
		end
	end

	return true
end



--- Helper function: Obtain either the normal or "Sort" version of a lookup table item property.
---@param lookupObject table Object to pull property values from.
---@param lookupProperty string Property to look up.
---@return any propertyValue Property value.
local function SortGroup_GetLookupFieldProperty(lookupObject, lookupProperty)
	if lookupObject[lookupProperty .. "Sort"] then
		return lookupObject[lookupProperty .. "Sort"]
	end
	return lookupObject[lookupProperty]
end



--- Helper function: Reverse a property, split by individual words.
--- Automatically handles item suffixes ("of the Whale", etc)
---@param item table Entry from the Bagshui inventory cache.
---@param propertyValue string String to be reversed.
---@param propertyName string Item property, used to determine whether to go into name suffix mode.
---@return string reversedString Reversed string.
local function SortGroup_GetReversedByWordsPropertyString(item, propertyValue, propertyName)
	-- Turn "A B C of the X" into "C B A X the of".
	if propertyName == "name" and string.len(item.suffixName or "") > 0 then
		return BsUtil.ReverseStringByWords(item.baseName)
				.. " "
				.. BsUtil.ReverseStringByWords(item.suffixName)
	end
	return BsUtil.ReverseStringByWords(propertyValue)
end



--- Do the work of sorting the items in a group.
---@param groupItems table[] Array of Bagshui inventory cache items.
---@param groupConfig table Group settings from the layout structure.
---@param defaultSortOrderId string|number? ID of sort order to use if the group doesn't have one configured. Falls back to BS_DEFAULT_SORT_ORDER_ID if needed.
function SortOrders:SortGroup(groupItems, groupConfig, defaultSortOrderId)


	-- Only declare the sorting function once.
	-- This function consumes self._sortGroup_SortFields as a way to get another parameter into the function.
	if not self._sortGroup_Sort then

		self._sortGroup_Sort = function(itmA, itmB)

			-- Loop through all sort fields in order and check each one to see if it's applicable
			for i, sort in ipairs(self._sortGroup_SortFields) do

				-- Start with some defaults.
				local itemProperty = sort.field
				local lookupTable = nil

				-- Determine whether this is a lookup field.
				if sort.lookup and self.itemFieldLookups[sort.lookup] then
					itemProperty = self.itemFieldLookups[sort.lookup].property
					lookupTable = self.itemFieldLookups[sort.lookup].table
				end

				-- Pull the value of the property we're sorting by.
				local valA = itmA[itemProperty]
				local valB = itmB[itemProperty]

				-- Special cases.
				if lookupTable then
					-- For lookup mode, we need to replace valA and valB with the lookup property values.
					valA = SortGroup_GetLookupFieldProperty(lookupTable[valA], sort.field)
					valB = SortGroup_GetLookupFieldProperty(lookupTable[valB], sort.field)

				elseif (sort.reverseWords) then
					-- Reverse properties if requested.
					valA = SortGroup_GetReversedByWordsPropertyString(itmA, valA, itemProperty)
					valB = SortGroup_GetReversedByWordsPropertyString(itmB, valB, itemProperty)
				end

				-- Make sure sort is not case-sensitive.
				if type(valA) == "string" then
					valA = string.lower(valA)
				end
				if type(valB) == "string" then
					valB = string.lower(valB)
				end

				-- Return the proper value depending on whether this is ascending or
				-- descending sort (true if valA should come before valB).
				if (sort.direction == "asc" and valA < valB) or (sort.direction == "desc" and valA > valB) then
					return true
				 elseif (sort.direction == "asc" and valA > valB) or (sort.direction == "desc" and valA < valB) then
					return false
				 end
			end

			return false
		end

	end


	-- SortGroup() actually starts here.

	-- Safety check.
	if type(groupItems) ~= "table" then
		return
	end

	-- Start by assuming the default sort order.
	local sortOrderId = (defaultSortOrderId and self.list[defaultSortOrderId]) and defaultSortOrderId or BS_DEFAULT_SORT_ORDER_ID

	-- If the group has a valid sort order, change to that.
	if type(groupConfig) == "table" and groupConfig.sortOrder then
		if self.list[groupConfig.sortOrder] then
			sortOrderId = groupConfig.sortOrder
		else
			-- If the configured sort order ID doesn't exist, reset it to to default.
			groupConfig.sortOrder = nil
		end
	end

	-- Sort the groupItems table.
	self._sortGroup_SortFields = self.list[sortOrderId].fields
	table.sort(
		groupItems,
		self._sortGroup_Sort
	)
end




end)