-- Bagshui ObjectList Prototype
-- Exposes: Bagshui.prototypes.ObjectList
-- Raises:
-- * BAGSHUI_[OBJECT_NAME]_UPDATE (i.e. BAGSHUI_CATEGORY_UPDATE)
-- * BAGSHUI_[OBJECT_NAME_PLURAL]_LOADED (i.e. BAGSHUI_CATEGORIES_LOADED)
--
-- Base class for Categories, Sort Orders, etc. since they share a lot of concepts.

Bagshui:AddComponent(function()


Bagshui:AddConstants({

	-- Use this in object skeletons to blindly accept any table provided
	-- as a property value without filtering. When this is used, the
	-- subclass should perform its own validation. See Components\Profiles.lua
	-- for an example of this in action.
	BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD = {},

})



local ObjectList = {}
Bagshui.prototypes.ObjectList = ObjectList



--- Create a new ObjectList instance.
--- ### `instanceProperties` Notes:
--- * The keys below are mandatory.
--- * Anything else in the table will be assigned to the final class instance
---   as well, so this can be used to override optional keys that are initialized
---   in the `objectList` table declared just after the `assert()`s.
---```
---{
--- ---@type string *Required* Key in BagshuiData where these objects will be stored.
--- dataStorageKey,
--- ---@type number? Current data version that can be used to determine when migration is required.
--- objectVersion,
--- ---@type function(data, oldVersion)? Take care of any migration actions that need to occur when object versions change. See below for example.
--- objectMigrationFunction,
--- ---@type string *Required* Localizable string for object name.
--- objectName
--- ---@type string *Required* Localizable string for plural object name.
--- objectNamePlural,
--- ---@type string *Required* Internal name of the object, used for localization. If not specified, will be derived from objectName by removing spaces.
--- objectType,
--- ---@type table<string,any> *Required* Template for use with TableCopy() that specifies what is valid for the object. Can leverage BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD.
--- objectSkeleton,
--- ---@type table<string,any> *Required* Template for creating a new object.
--- objectTemplate,
--- ---@type table<string,any>[]? Default objects that will be loaded into dataStorageKey.
--- defaults,
--- ---@type table<string,any>[]? List of template objects that can be created by the object manager UI.
--- templates,
--- ---@type table<string,any> If a property is missing from a default object, give it this value.
--- defaultObjectValues,
--- }
---```
---
---### `objectMigrationFunction` example
---```
---	---@param data table Contents of the SavedVariables `dataStorageKey` for this ObjectList.
---	---@param oldVersion number *Previous* version number before Bagshui was loaded this time.
---	function migrate(data, oldVersion)
---		if oldVersion < 2 then
---			-- Perform migration actions on object list data.
---		end
---	end
---```
---@param instanceProperties table List of properties for the new instance.
---@return table objectList New instance.
function ObjectList:New(instanceProperties)
	assert(type(instanceProperties.dataStorageKey) == "string", "instanceProperties.dataStorageKey must be a string")
	assert(type(instanceProperties.objectName) == "string", "instanceProperties.objectName must be a string")
	assert(type(instanceProperties.objectNamePlural) == "string", "instanceProperties.objectNamePlural must be a string")
	assert(type(instanceProperties.objectSkeleton) == "table", "instanceProperties.objectSkeleton must be a table")
	assert(type(instanceProperties.objectTemplate) == "table", "instanceProperties.objectTemplate must be a table")
	assert(type(instanceProperties.defaults) == "table" or not instanceProperties.defaults, "instanceProperties.defaults must be a table")

	local objectList = {
		_super = ObjectList,

		---@type table<string|number, table>
		-- This is the `<Object ID> = { Object }` table that is populated during Init().
		list = nil,

		---@type table<string|number, table>
		-- Metadata about objects.
		meta = {},

		-- Keep track of names to assist in preventing duplicates.
		defaultObjectNames = {},
		customObjectNames = {},

		-- Provide a base version.
		objectVersion = instanceProperties.objectVersion or 1,

		-- Derive objectType from objectName if needed.
		objectType = string.gsub(instanceProperties.objectType or instanceProperties.objectName, "%s", ""),

		-- Should everything in the defaults bet set to readOnly when LoadDefaults() is called?
		defaultsReadOnly = true,
		-- Should everything in the defaults bet set to hidden when LoadDefaults() is called?
		defaultsHidden = false,

		-- Prevent creation of new objects.
		disableObjectCreation = false,
		-- Prevent deletion of existing objects.
		disableObjectDeletion = false,
		-- Prevent editing of existing objects.
		disableObjectEditing = false,
		-- Prevent import/export.
		disableObjectSharing = false,



		---@type function(objectId) -> boolean
		-- Prevent creation of objects matching specific criteria.
		disableObjectCreationFunc = nil,
		---@type function(objectId) -> boolean
		-- Prevent deletion of objects matching specific criteria.
		disableObjectDeletionFunc = nil,
		---@type function(objectId) -> boolean
		-- Prevent editing of objects matching specific criteria.
		disableObjectEditingFunc = nil,

		-- Event that will trigger `ObjectList:Init()`.
		initEvent = "BAGSHUI_ADDON_LOADED",

		---@type string?
		-- Additional event that will trigger `ObjectList:RefreshUsage()`.
		-- See `ObjectList:OnEvent()` for events that are default triggers.
		refreshObjectUsageEvent = nil,

		---@type boolean?
		-- Set false to ignore the default events that would usually trigger
		-- a usage refresh. See `ObjectList:OnEvent()` for events that are default triggers.
		defaultObjectUsageRefreshEventsActive = true,

		-- Event that will be raised when objects change.
		-- Example: BAGSHUI_CATEGORY_UPDATE
		objectChangeEvent = "BAGSHUI_" .. string.gsub(string.upper(instanceProperties.objectName), "%s", "_") .. "_UPDATE",

		-- Arrays of object IDs sorted by certain properties.
		sortedIdLists = {
			name = {},
			builtin = {},
			inUse = {},
		},
		-- Arrays of object IDs filtered by certain properties.
		filteredIdLists = {
			builtin = {},
			custom = {},
		},
		-- This is the same as sortedIdLists but excluding any object with a hidden = true property.
		sortedIdListsForManager = {
			name = {},
			builtin = {},
			inUse = {},
		},

		---@type string[]
		-- List of object keys to delete in the exported version of an object.
		-- Only top-level keys are currently supported.
		exportRemoveKeys = {
			"inUse",
			"dateCreated",
			"dateModified",
		},
		---@type table<string, true>
		-- Object keys to ignore when determining whether an object that is about
		-- to be imported is identical to an existing object. This will automatically
		-- be updated to include everything in `exportRemoveKeys`.
		importIgnoreKeys = {
			name = true,
		},

		---@type table
		-- ObjectManager instance that will be initialized when Open() is called.
		-- DO NOT override it here -- use `<ClassInstance>:InitUi()` instead.
		objectManager = nil,

		-- Object change events won't be raised until `self.initialized == true`.
		initialized = false,

		---@type table<string,function> List of functions used for sorting by item properties.
		--- Keys are item properties, strings are functions that accept two IDs and return
		--- true if idA < idB. See `objectList.idListSortFunctions` setup below for examples.
		--- Subclasses can add their own property-specific sort functions by leveraging the
		--- `_idListSortFunctions_objectList` property just like the base functions.
		idListSortFunctions = nil,

		---@type table
		-- Table reference used to pass the object list into the `idListSortFunctions`.
		_idListSortFunctions_objectList = nil,

		-- Reusable table for GetUses().
		_getUses_temp = {},

		-- Should the object list be cleared at startup?
		debugResetOnLoad = false and BS_DEBUG,
	}

	-- (Need to wait to declare these so we have the objectList instance.)
	objectList.idListSortFunctions = {
		name = function(idA, idB)
			return string.lower(objectList._idListSortFunctions_objectList[idA].name or "") < string.lower(objectList._idListSortFunctions_objectList[idB].name or "")
		end,

		builtin = function(idA, idB)
			return
			((objectList._idListSortFunctions_objectList[idA].builtin and 1 or 0) .. string.lower(objectList._idListSortFunctions_objectList[idA].name or ""))
			<
			((objectList._idListSortFunctions_objectList[idB].builtin and 1 or 0) .. string.lower(objectList._idListSortFunctions_objectList[idB].name or ""))
		end,

		inUse = function(idA, idB)
			return
			((objectList._idListSortFunctions_objectList[idA].inUse and 1 or 0) .. string.lower(objectList._idListSortFunctions_objectList[idA].name or ""))
			<
			((objectList._idListSortFunctions_objectList[idB].inUse and 1 or 0) .. string.lower(objectList._idListSortFunctions_objectList[idB].name or ""))
		end
	}

	--- Helper function that can be passed as a parameter to `table.sort()`.
	---@param idA any ID of first object to compare.
	---@param idB any ID of second object to compare.
	---@return boolean # true if idA < idB.
	function objectList.idListSortWrapper(idA, idB)
		-- Need a safeguard for sorting to avoid errors if an object doesn't exist
		if
			not objectList._idListSortFunctions_objectList[idA]
			or not objectList._idListSortFunctions_objectList[idB]
		then
			return false
		end
		if not objectList.idListSortFunctions[objectList._idListSortProperty] then
			objectList._idListSortProperty = "name"
		end
		return objectList.idListSortFunctions[objectList._idListSortProperty](idA, idB)
	end


	-- Copy instance properties to final object.
	for key, value in pairs(instanceProperties) do
		objectList[key] = value
	end

	-- Ensure key properties are allowed by the object skeleton.
	objectList.objectSkeleton.name = ""
	objectList.objectSkeleton.builtin = false
	objectList.objectSkeleton.readOnly = false
	objectList.objectSkeleton.hidden = false
	objectList.objectSkeleton.inUse = false

	-- Set up the class object.
	setmetatable(objectList, self)
	self.__index = self

	-- Prepare for Init().
	Bagshui:RegisterEvent(objectList.initEvent, objectList)
	if objectList.defaultObjectUsageRefreshEventsActive then
		Bagshui:RegisterEvent("BAGSHUI_INVENTORY_EDIT_MODE_UPDATE", objectList)
		Bagshui:RegisterEvent("BAGSHUI_SETTING_UPDATE", objectList)
	end
	if objectList.refreshObjectUsageEvent then
		Bagshui:RegisterEvent(objectList.refreshObjectUsageEvent, objectList)
	end

	-- Register slash command handler (for example, /bagshui categories).
	BsSlash:AddOpenCloseHandler(instanceProperties.objectNamePlural, objectList)

	return objectList
end



--- Initialize object list after BagshuiData/SavedVariables are available.
---@param subclassWillSetInitializedProperty boolean? true when the calling subclass needs to complete other tasks before `self.initialized` becomes true.
function ObjectList:Init(subclassWillSetInitializedProperty)
	--Bagshui:PrintDebug("ObjectList:Init() -- " .. self.objectName)

	-- Initialize ObjectList config in SavedVariables.
	if _G.BagshuiData[self.dataStorageKey] == nil or self.debugResetOnLoad then
		-- Bagshui:PrintDebug("Resetting " .. self.dataStorageKey .. " for " .. self.objectName)
		_G.BagshuiData[self.dataStorageKey] = {}
		Bagshui.objectVersions[self.dataStorageKey] = self.objectVersion
	end
	-- Reference to `dataStorageKey` in BagshuiData.
	self.list = _G.BagshuiData[self.dataStorageKey]

	-- Perform migration if available.
	if type(self.objectMigrationFunction) == "function" then
		self.objectMigrationFunction(
			self,
			(Bagshui.objectVersions[self.dataStorageKey] or 1)
		)
	end
	-- Update object version so migration won't repeat.
	Bagshui.objectVersions[self.dataStorageKey] = self.objectVersion


	self:LoadDefaults(self.defaults)

	-- Get the sorted object list initialized.
	self:UpdateTrackingLists()

	-- Save operations should now raise BAGSHUI_<OBJECT_NAME>_UPDATE.
	if not subclassWillSetInitializedProperty then
		self.initialized = true
	end

	-- Raise event for loading finished, for example, BAGSHUI_CATEGORIES_LOADED.
	Bagshui:RaiseEvent("BAGSHUI_" .. string.upper(self.objectNamePlural) .. "_LOADED")
end



--- Event handling.
---@param event string Event identifier.
---@param arg1 any? Argument 1 from the event.
function ObjectList:OnEvent(event, arg1, arg2, arg3)
	-- Bagshui:PrintDebug("ObjectList " .. tostring(self.objectType) .. " OnEvent " .. event .. " (prototype: " .. tostring(self == ObjectList) .. ")")

	-- Don't call Init() on the prototype.
	if event == self.initEvent and self ~= ObjectList then
		if not self.initialized then
			self:Init()
		end
		return true
	end

	if
		self.defaultObjectUsageRefreshEventsActive
		and (
			event == "BAGSHUI_INVENTORY_EDIT_MODE_UPDATE"
			or (
				-- There is definitely a cleaner way to do this, but being able to disable
				-- via defaultObjectUsageRefreshEventsActive = false is going to be good enough for now.
				event == "BAGSHUI_SETTING_UPDATE"
				and (
					string.find(tostring(arg1), "^defaultProfile")
					or string.find(tostring(arg1), "^profile")
				)
			)
		)
		or event == self.refreshObjectUsageEvent
	then
		-- Get usage information up to date.
		self:RefreshUsage()
		return
	end
end



--- Call this to raise BAGSHUI_<OBJECT>_UPDATE.
---@param objectId string|number? Object that has changed.
function ObjectList:ObjectsChanged(objectId)
	-- Perform updates and send notifications only after startup
	if self.initialized then
		self:UpdateTrackingLists()
		-- Event will be, for example, BAGSHUI_CATEGORY_UPDATE
		Bagshui:RaiseEvent(self.objectChangeEvent, false, objectId)
	end
end



--- Update usage information for all objects.
function ObjectList:RefreshUsage()
	if self.GetUses ~= ObjectList.GetUses then
		for id, _ in pairs(self.list) do
			if not self.meta[id] then
				self.meta[id] = {
					usesLeft = {},
					usesRight = {},
					usesOfProfilesLeft = {},
					usesOfProfilesRight = {},
				}
			end
			self.list[id].inUse = self:GetUses(id, self.meta[id])
		end
	end
	-- When usage information changes, sorting by the inUse property can change.
	self:UpdateSortedObjectLists()
	-- Refresh UI.
	if self.objectManager then
		self.objectManager:UpdateList()
	end
end



-- Load default objects.
---@param objectList table<string,any>[] List of objects to load.
function ObjectList:LoadDefaults(objectList)
	local foundDefaults = {}

	if objectList then
		for _, objectInfo in ipairs(objectList) do
			-- Fill any missing default values.
			if self.defaultObjectValues then
				for key, defaultValue in pairs(self.defaultObjectValues) do
					if not objectInfo[key] then
						objectInfo[key] = defaultValue
					end
				end
			end
			-- Add flags.
			objectInfo.builtin = true
			if self.defaultsReadOnly then
				objectInfo.readOnly = true
			end
			if self.defaultsHidden then
				objectInfo.hidden = true
			end
			-- Save to self.list.
			self:Save(objectInfo.id, objectInfo)
			foundDefaults[objectInfo.id] = true
		end
	end

	-- Remove any built-ins that no longer exist.
	if not self.disableObjectDeletion then
		for id, objectInfo in pairs(self.list) do
			if
				objectInfo.builtin and not foundDefaults[id]
				and not (
					type(self.disableObjectDeletionFunc) == "function"
					and self.disableObjectDeletionFunc(id)
				)
			then
				self.list[id] = nil
			end
		end
	end

	-- Need to manually update here since automatic updates don't happen until after startup.
	self:UpdateObjectNameLists()
end



--- Retrieve an object.
---@param objectId string|number ID of object to retrieve.
---@return table|nil object
function ObjectList:Get(objectId)
	return self.list[objectId]
end



--- Determine whether an object is a builtin..
---@param objectId string|number ID of object to check.
---@return boolean
function ObjectList:IsBuiltIn(objectId)
	return self.list[objectId] and (self.list[objectId].builtin and true) or false
end



--- Retrieve a copy of an object for exporting.
--- The return value MUST be a table with the fallowing keys:
--- ```
--- {
--- 	object = <The object being exported. CAN BE NIL.>
--- 	dependencies = {
---			-- Yes, this should use the ACTUAL class as the key -- for example, BsCategories.
--- 		[<ObjectClass1>] = {
--- 			<Array of object IDs>
--- 		},
--- 		[<ObjectClass2>] = {
--- 			<Array of object IDs>
--- 		},
--- 	},
--- }
--- ```
--- *Optional* subclass method. When subclassing is required,
--- grab the return value of the superclass function and modify it,
--- along the lines of this pseudocode:
--- ```
--- function Subclass:Export(objectId)
--- 	local export = self._super.Export(self, objectId)
--- 	export.dependencies[DependencyClass.objectType] = {}
--- 	for <dependency iteration> do
--- 		table.insert(
--- 			export.dependencies[DependencyClass],
--- 			dependencyObjectId
--- 		)
--- 	end
--- end
--- ```
---@param objectId string|number
---@return table exportableData
function ObjectList:Export(objectId)
	local object = nil
	if self.list[objectId] and not self.list[objectId].builtin then
		object = BsUtil.TableCopy(self.list[objectId])
		for _, keyToRemove in ipairs(self.exportRemoveKeys) do
			object[keyToRemove] = nil
		end
	end
	local export = {
		object = object,
		dependencies = {},
	}
	return export
end



--- Import the given data as a new object.
--- *Optional* subclass method.
---@param objectInfo table
---@param dependencyMap table<table, table<number, number>>? Define the mapping of object IDs that were in the export to what they have become on import. See `ObjectList:Export()` for expected format. (Not used in the base class but subclasses like Profiles need it.)
---@param force boolean? Import even if an identical object already exists.
---@return number? newObjectId nil when import fails.
function ObjectList:Import(objectInfo, dependencyMap, force)
	if type(objectInfo) ~= "table" then
		return
	end

	-- Ensure the list of keys to ignore is up to date.
	for _, keyToIgnore in ipairs(self.exportRemoveKeys) do
		self.importIgnoreKeys[keyToIgnore] = true
	end

	-- Try to avoid importing by finding an existing identical object.
	for existingObjectId, existingObjectInfo in pairs(self.list) do
		if
			not existingObjectInfo.builtin
			and BsUtil.ObjectsEqual(objectInfo, existingObjectInfo, self.importIgnoreKeys)
		then
			Bagshui:Print(string.format(L.ObjectList_ImportReusingExisting, L[self.objectType], objectInfo.name, existingObjectInfo.name))
			return existingObjectId
		end
	end

	-- Get new object ID.
	local objectId = self:GetNewObjectId()

	-- Append a number to the end of the name if it's a duplicate.
	local desiredName = objectInfo.name
	local dupeCount = 1
	while self:IsNameDuplicate(objectId, objectInfo) do
		objectInfo.name = desiredName .. " [" .. dupeCount .. "]"
		dupeCount = dupeCount + 1
	end

	if self:Save(objectId, objectInfo) then
		Bagshui:Print(string.format(L.ObjectList_ImportSuccessful, L[self.objectType], objectInfo.name))
		return objectId
	end
end



--- Get the list of other ObjectList classes on which this one depends.
--- For example, `BsProfiles` would return `{ BsCategories, BsSortOrders }`.
--- *Optional* subclass method.
---@return ObjectList[]? dependencies
function ObjectList:GetImportExportDependencies()
	return nil
end



--- Populate the "uses" metadata properties of the object with tooltip-ready strings..
--- The `objectMetadata` parameter will be the object's metadata table, which will
--- have `usesLeft`, `usesRight`, `usesOfProfilesLeft`, and `usesOfProfilesRight` keys.
--- The function is then expected to fill these in with strings that will be displayed
--- in a tooltip (hence the left/right distinction).
--- *Optional* subclass method.
---@param objectId string|number
---@param objectMetadata table Metadata about the object.
---@return boolean inUse Whether the object is being
function ObjectList:GetUses(objectId, objectMetadata)
	return false
end



--- Make a new copy of an existing object.
---@param objectId string|number
---@param newName string Name of the cloned object.
---@return number|nil newObjectId If the object was cloned successfully, the ID of the newly cloned object is returned.
function ObjectList:Clone(objectId, newName)
	local newObjectId = self:GetNewObjectId()
	local newObjectInfo = BsUtil.TableCopy(self.list[objectId])
	newObjectInfo.name = newName
	newObjectInfo.builtin = nil
	newObjectInfo.readOnly = nil
	if self:Save(newObjectId, newObjectInfo) then
		return newObjectId
	end
end



--- Copy one object over another, optionally filtering to a single property.
---@param fromObjectId string|number Source object ID.
---@param toObjectId string Destination object ID.
---@param filterProperty string? Top-level property to copy instead of copying the entire source object.
---@return boolean success If the copy was completed successfully.
function ObjectList:Copy(fromObjectId, toObjectId, filterProperty)
	local fromObject = self.list[fromObjectId]
	local toObject = self.list[toObjectId]
	if not fromObject or not toObject then
		return false
	end

	-- Start by copying everything on the existing destination object.
	local newObjectInfo = BsUtil.TableCopy(toObject)

	-- Full/partial.
	if not filterProperty then
		-- Full copy.
		BsUtil.TableCopy(fromObject, newObjectInfo)
	else
		-- Partial copy.
		if type(fromObject[filterProperty]) == "table" then
			BsUtil.TableCopy(fromObject[filterProperty], newObjectInfo[filterProperty])
		else
			newObjectInfo[filterProperty] = fromObject[filterProperty]
		end
	end

	-- Keep key properties on destination object correct and save.
	newObjectInfo.name = toObject.name
	newObjectInfo.builtin = nil
	newObjectInfo.readOnly = nil
	return self:Save(toObjectId, newObjectInfo)
end



--- Save an object (wrapper for SaveObject that provides error handling).
---@param objectId string|number
---@param objectInfo table<string,any> Object properties.
---@return boolean success
function ObjectList:Save(objectId, objectInfo)
	local success, errorMessage = pcall(self.SaveObject, self, objectId, objectInfo)
	if not success or type(errorMessage) == "string" then
		Bagshui:PrintError(string.format(L.Error_SaveFailed, L[self.objectName], tostring(errorMessage)))
	end
	return success
end



--- Helper to save/update an object so we can pcall() it.
--- Use `ObjectList:Save()` instead of calling this directly.
---@param objectId string|number
---@param objectInfo table<string,any> Object properties.
---@return string? errorMessage When save fails, the error will be returned. Otherwise, nil.
function ObjectList:SaveObject(objectId, objectInfo)
	assert(objectId, "objectID must be specified")
	assert(type(objectInfo) == "table", "objectInfo must be a table")
	assert(type(objectInfo.name) == "string" and string.len(objectInfo.name) > 0, "Name must be specified")

	-- Ensure saving is allowed.
	if
		not self.list[objectId]
		and (
			self.disableObjectCreation
			or (type(self.disableObjectCreationFunc) == "function" and self.disableObjectCreationFunc(objectId))
		)
	then
		return string.format(L.ObjectList_ActionNotAllowed, L.Creation)
	end
	if
		self.list[objectId]
		and (
			self.disableObjectEditing
			or (type(self.disableObjectEditingFunc) == "function" and self.disableObjectEditingFunc(objectId))
		)
	then
		return string.format(L.ObjectList_ActionNotAllowed, L.Editing)
	end

	-- Check for name duplication.
	if self:IsNameDuplicate(objectId, objectInfo) then
		return string.format(L.Error_DuplicateName, L[self.objectName], objectInfo.name)
	end

	-- Allow subclasses to perform operations prior to saving.
	local errorMessage = self:DoPreSaveOperations(objectId, objectInfo)
	if errorMessage then
		return errorMessage
	end

	-- Initialize the object if it doesn't exist.
	if self.list[objectId] == nil then
		self.list[objectId] = {
			dateCreated = _G.time()
		}
	end

	-- Filter the provided information using the template.
	BsUtil.TableCopy(objectInfo, self.list[objectId], nil, self.objectSkeleton, BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD)

	self.list[objectId].dateModified = _G.time()

	-- Allow subclasses to perform operations after saving.
	self:DoPostSaveOperations(objectId, self.list[objectId])

	-- There's been a change.
	self:ObjectsChanged(objectId)
end



--- Pre-save subclass hook. Throwing an error/assertion or returning an
--- errorMessage will stop the save operation.
---@param objectId string|number
---@param objectInfo table<string,any> Object properties.
---@return string? errorMessage If an error is returned, the save operation will stop.
function ObjectList:DoPreSaveOperations(objectId, objectInfo)  end



--- Post-save subclass hook.
---@param objectId string|number
---@param objectInfo table<string,any> Object properties.
function ObjectList:DoPostSaveOperations(objectId, objectInfo) end



--- Delete the specified object.
---@param objectId string|number
---@return boolean success
function ObjectList:Delete(objectId)
	-- Ensure deletion is allowed.
	if
		not self.list[objectId] and (
			self.disableObjectDeletion
			or (type(self.disableObjectDeletionFunc) == "function" and self.disableObjectDeletionFunc(objectId, objectInfo))
		)
	then
		Bagshui:PrintWarning(string.format(L.ObjectList_ActionNotAllowed, L.Deletion))
		return false
	end

	if self.list[objectId] and not (self.list[objectId].builtin or self.list[objectId].readOnly) then
		self.list[objectId] = nil
		self:ObjectsChanged(objectId)
		return true
	end
	return false
end



--- Refresh lists of sorted object IDs and name-to-ID mappings.
function ObjectList:UpdateTrackingLists()
	self:UpdateSortedObjectLists()
	self:UpdateObjectNameLists()
end



--- Keep all sorted/filtered of object IDs current.
function ObjectList:UpdateSortedObjectLists()

	-- Reset filtered lists.
	BsUtil.TableClear(self.filteredIdLists.builtin)
	BsUtil.TableClear(self.filteredIdLists.custom)

	-- We need to start with something, so we'll copy all the IDs to the name table and work from that.
	BsUtil.TableClear(self.sortedIdLists.name)
	BsUtil.TableClear(self.sortedIdListsForManager.name)
	for id, object in pairs(self.list) do

		if self.objectMetatable and getmetatable(object) ~= self.objectMetatable then
			setmetatable(object, self.objectMetatable)
		end

		table.insert(self.sortedIdLists.name, id)
		if not object.hidden then
			table.insert(self.sortedIdListsForManager.name, id)
		end

		-- Add to appropriate filtered list
		table.insert(
			self.filteredIdLists[object.builtin and "builtin" or "custom"],
			id
		)
	end

	-- Sort filtered lists.
	self:SortIdList(self.filteredIdLists.builtin, nil, "name")
	self:SortIdList(self.filteredIdLists.custom, nil, "name")

	-- Sort other lists.
	for property, _ in pairs(self.sortedIdLists) do
		if not self.sortedIdListsForManager[property] then
			self.sortedIdListsForManager[property] = {}
		end
		-- Don't overwrite the `name` table since it's the one we're working from.
		if property ~= "name" then
			BsUtil.TableCopy(self.sortedIdLists.name, self.sortedIdLists[property])
			BsUtil.TableCopy(self.sortedIdLists.name, self.sortedIdListsForManager[property])
		end
		self:SortIdList(self.sortedIdLists[property], nil, property)
		self:SortIdList(self.sortedIdListsForManager[property], nil, property)
	end
end




--- Sort the given list of object IDs by the given property.
--- Needed as a separate function for menus and group tooltips.
---@param idList table List of object IDs to sort.
---@param objectList table? List of objects to use as a sorting reference. Will use `self.list` if not specified.
---@param property string? Property to sort by (defaults to `name`).
function ObjectList:SortIdList(idList, objectList, property)
	-- When objectList is provided, use that as the reference for sorting instead of self.list.
	-- (Alternate objectList is primarily used to sort templates).
	self._idListSortFunctions_objectList = objectList or self.list
	self._idListSortProperty = property or "name"

	table.sort(idList, self.idListSortWrapper)
end



--- Refresh name-to-ID mappings used by `IsNameDuplicate()`.
function ObjectList:UpdateObjectNameLists()
	BsUtil.TableClear(self.defaultObjectNames)
	BsUtil.TableClear(self.customObjectNames)
	for id, object in pairs(self.list) do
		if self.objectMetatable and getmetatable(object) ~= self.objectMetatable then
			setmetatable(object, self.objectMetatable)
		end
		local nameTable = object.builtin and self.defaultObjectNames or self.customObjectNames
		nameTable[object.name] = id
	end
end



--- Determine whether the object represented by `objectId` & `objectInfo` has the
--- same name as another object. The name being tested is pulled from `objectInfo.name`.
---@param objectId string|number
---@param objectInfo table<string,any>? Object properties.
---@param testCustomAgainstBuiltin boolean? When true, check to see if the given name belongs to both a built-in and custom object. Otherwise, only the same type of object is checked.
---@return boolean|nil
function ObjectList:IsNameDuplicate(objectId, objectInfo, testCustomAgainstBuiltin)
	if type(objectInfo) ~= "table" then
		objectInfo = self.list[objectId]
		if type(objectInfo) ~= "table" then
			return false
		end
	end
	-- The basic idea is that we check the appropriate name-to-ID mapping table
	-- (built-in or custom) to see whether an object with the same name as the
	-- one being checked exists.
	-- The only exception to this is when testCustomAgainstBuiltin is true. Then
	-- we check whether an object with the same name exists in both built-in and
	-- custom lists.
	return (
		(
			not objectInfo.builtin
			and self.customObjectNames[objectInfo.name] ~= nil
			and self.customObjectNames[objectInfo.name] ~= objectId
 		)
		or
		(
			objectInfo.builtin
			and self.defaultObjectNames[objectInfo.name] ~= nil
			and self.defaultObjectNames[objectInfo.name] ~= objectId
		)
		or
		(
			testCustomAgainstBuiltin
			and self.customObjectNames[objectInfo.name] ~= nil
			and self.defaultObjectNames[objectInfo.name] ~= nil
		)
	)
end



--- Obtain the name of the given object, appending [Bagshui] or [Custom] as
--- appropriate when a built-in object has the same name as a custom one or
--- vice-versa.
---@param objectId string|number
---@param noDupeSuffix boolean? Omit the [Bagshui/Custom] suffix for objects with duplicate names.
---@param dupeSuffixFontColorCode string|boolean? When false, don't color the duplicate suffix at all. Provide a string to use a custom color for the duplicate suffix.
---@return string|nil objectName
function ObjectList:GetName(objectId, noDupeSuffix, dupeSuffixFontColorCode)
	local objectInfo = self.list[objectId]
	if not objectInfo then
		return
	end
	-- Append duplicate suffix.
	if not noDupeSuffix and self:IsNameDuplicate(objectId, objectInfo, true) then
		local fontColor = LIGHTYELLOW_FONT_COLOR_CODE
		if dupeSuffixFontColorCode == false then
			fontColor = ""
		elseif type(dupeSuffixFontColorCode) == "string" then
			fontColor = dupeSuffixFontColorCode
		end
		return
			objectInfo.name .. " "
			.. fontColor
			.. string.format(L.Symbol_Brackets, (objectInfo.builtin and "Bagshui" or L.Custom))
			.. ((fontColor == "") and "" or FONT_COLOR_CODE_CLOSE)
	end
	return objectInfo.name
end



--- Obtain the next available sequential object ID.
---@return number
function ObjectList:GetNewObjectId()
	return self:GetNextId()
end



--- Work backwards from the maximum allowed ID to find the next available number.
--- * Doing it this way instead of tracking the next ID in a config file since working
---   backwards from 1 million barely takes any time.
--- * `table.getn()` won't work here because the tables we're using are associative, not array-type.
--- **Warning:** This requires any references to object IDs to be cleaned up when objects
--- are deleted. Otherwise, for example, if object 4 is the last in the list and
--- it is removed, this function will return 4 when asked for the next ID. Any
--- leftover references to object 4 will then point to the newly created object.
---@param existingObjects table? Defaults to `self.list`.
---@return integer
function ObjectList:GetNextId(existingObjects)
	existingObjects = existingObjects or self.list
	for i = 1000000, 1, -1 do
		if existingObjects[i] then
			return i + 1
		end
	end
    return 1
end



--- Add either a string or a series of strings to the given objectMetadata table.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
---@param useType string One of the metadata table key prefixes -- see `ObjectList:RefreshUsage()` for these (for example, `uses`). This must only be the prefix without the Left/Right suffix.
---@param left string|string[] String or array of strings to add to the `<useType>Left` table within `objectMetadata`.
---@param right string|string[] String or array of strings to add to the `<useType>Right` table within `objectMetadata`.
---@param position number? Position within the metadata use tables to insert the strings. If not specified, will insert at the end. 
---@param leftPrefix string? String with which to prefix all strings being inserted into the left use table.
function ObjectList:AddUse(objectMetadata, useType, left, right, position, leftPrefix)
	assert(type(useType) == "string", "ObjectList:AddUse() [" .. self.objectType .. "] - useType must be a string")
	assert(type(leftPrefix) == "nil" or type(leftPrefix) == "string", "ObjectList:AddUse() [" .. self.objectType .. "] - leftPrefix must be a string or nil")
	assert(type(objectMetadata[useType .. "Left"]) == "table", "ObjectList:AddUse() [" .. self.objectType .. "] - " .. useType .. " is not a valid uses useType")
	if type(left) == "string" then
		self:AddUseHelper(objectMetadata, useType, left, right, position, leftPrefix)
	elseif type(left) == "table" then
		for i = 1, table.getn(left) do
			self:AddUseHelper(objectMetadata, useType, left[i], type(right) == "table" and right[i] or "", position, leftPrefix)
		end
	end
end



--- Share code between string and table insertions for `ObjectList:AddUse()`.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
---@param useType string One of the metadata table key prefixes -- see `ObjectList:RefreshUsage()` for these (for example, `uses`). This must only be the prefix without the Left/Right suffix.
---@param left string What to add to the `<useType>Left` table within `objectMetadata`.
---@param right string What to add to the `<useType>Right` table within `objectMetadata`.
---@param position number? Position within the metadata use tables to insert the strings. If not specified, will insert at the end. 
---@param leftPrefix string? String with which to prefix `left`.
function ObjectList:AddUseHelper(objectMetadata, useType, left, right, position, leftPrefix)
	left = (leftPrefix or "") .. (left or "")
	right = right or ""
	position = position or (table.getn(objectMetadata[useType .. "Left"]) + 1)
	table.insert(objectMetadata[useType .. "Left"], position, left)
	table.insert(objectMetadata[useType .. "Right"], position, right)
end



--- Clear all the "uses" metadata tables.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
function ObjectList:ResetUses(objectMetadata)
	for key, val in pairs(objectMetadata) do
		if string.find(key, "^uses") and type(val) == "table" then
			BsUtil.TableClear(val)
		end
	end
end



--- Show the object management UI.
function ObjectList:Open()
	self:RefreshUsage()
	self:InitUi()
	self.objectManager:Open()
end



--- Hide the object management UI.
function ObjectList:Close()
	self.objectManager:Close()
end



--- Open the object editor UI.
---@param objectId string|number
function ObjectList:EditObject(objectId)
	self:Open()
	self.objectManager:EditObject(objectId)
end



--- Create a new object and open it in the editor UI.
---@param template table? Override the default object template.
---@param onFirstSave function? Callback for the first click of the Save button.
---@return string|number? objectId
function ObjectList:NewObject(template, onFirstSave)
	self:Open()
	return self.objectManager:NewObject(template, onFirstSave)
end



--- Initialize object management UI.
---@param objectManagerClass table? Additional superclass for this ObjectList's ObjectManager class instance. 
---@param objectEditorClass table? Additional superclass for this ObjectList's ObjectEditor class instance.
---@param objectManagerParamOverrides table? Any custom properties for the call to `ObjectManager:New()`.
function ObjectList:InitUi(objectManagerClass, objectEditorClass, objectManagerParamOverrides)
	if self.objectManager then
		return
	end

	-- Provide an upvalue for use inside the ObjectManager/ObjectEditor classes.
	local objectListInstance = self

	-- ObjectManager superclass.
	local objectManager = objectManagerClass or {}
	if not objectManager.sortField then
		objectManager.sortField = "name"
	end

	-- ObjectEditor superclass.
	local objectEditor = objectEditorClass or {}


	-- Add required methods to our ObjectManager/ObjectEditor superclasses.

	--- Obtain sorted list of object IDs based on active sorting criteria.
	---@param sortProperty string? Get the list sorted by the given property. When not specified, use `self.sortField`.
	---@return (string|number)[]
	function objectManager:GetObjectList(sortProperty)
		local property = sortProperty or self.sortField
		if not property or not objectListInstance.sortedIdListsForManager[property] then
			Bagshui:PrintError(self.objectType .. ".ObjectManager:GetObjectList(): " .. tostring(property) .. " not found! Using name sort instead (this shouldn't happen).")
			property = "name"
		end
		return objectListInstance.sortedIdListsForManager[property]
	end


	--- Return a table with information about a given object based on its ID.  
	---@param objectId any
	---@return table|nil objectInfo
	function objectManager:GetObjectInfo(objectId)
		return objectListInstance.list[objectId]
	end


	--- Delete an object (confirmation will have already been obtained).
	---@param objectId string|number
	---@return boolean|nil # true if deletion was successful, false if it failed, nil if object ID was invalid.
	function objectManager:DeleteObject(objectId)
		return objectListInstance:Delete(objectId)
	end


	-- Check for duplicate names before saving.
	---@param objectId any
	---@param property any
	---@param objectInfo any
	---@return boolean valid
	---@return string|nil errorMessage
	function objectManager:IsObjectPropertyValid(objectId, property, objectInfo)
		if property == "name" then
			if objectListInstance:IsNameDuplicate(objectId, objectInfo) then
				return false, string.format(L.Error_DuplicateName, L[objectListInstance.objectName], objectInfo.name)
			end
		end
		return true
	end


	-- Save the object.
	---@return boolean saveResult true if save was successful.
	function objectEditor:Save()
		return objectListInstance:Save(self.objectId, self.updatedObject)
	end


	-- Obtain an ID for a new object.
	---@return number objectId
	function objectEditor:GetNewObjectId()
		return objectListInstance:GetNewObjectId()
	end


	-- Create the ObjectManager instance.

	local listTooltipLines = {}

	local listTooltipLinesLeft = {}
	local listTooltipLinesRight = {}

	-- Parameters for `ObjectManager:New()`.
	local objectManagerParams = {
		objectType = self.objectType,
		objectTemplate = self.objectTemplate,
		updateEvent = self.objectChangeEvent,

		objectName = self.objectName,
		objectNamePlural = self.objectNamePlural,

		disableObjectCreation = self.disableObjectCreation,
		disableObjectDeletion = self.disableObjectDeletion,
		disableObjectEditing = self.disableObjectEditing,
		disableObjectSharing = self.disableObjectSharing,
		disableObjectCreationFunc = self.disableObjectCreationFunc,
		disableObjectDeletionFunc = self.disableObjectDeletionFunc,
		disableObjectEditingFunc = self.disableObjectEditingFunc,
		disableObjectSharingFunc = self.disableObjectSharingFunc,

		wikiPage = self.wikiPage,
		helpUrl = self.helpUrl,

		managerMultiSelect = self.managerMultiSelect,
		managerCheckboxes = self.managerCheckboxes,

		managerSuperclass = objectManager,
		managerWidth = 350,
		managerHeight = 600,
		managerColumns = {
			{
				field = "name",
				title = L.ObjectManager_Column_Name,
				widthPercent = "100",
				currentSortOrder = "ASC",
				lastSortOrder = "ASC",
			},
		},

		-- Show usage info on mouseover.
		managerListEntryOnEnter = function(this, modifierKeyRefresh)
			this = this or _G.this

			-- Must have metadata about this object.
			if not (
				this.bagshuiData.scrollableListEntryInfo
				and this.bagshuiData.scrollableListEntryInfo.inUse
				and this.bagshuiData.scrollableListEntry
				and self.meta[this.bagshuiData.scrollableListEntry]
			) then
				return
			end

			local tooltipStringsLeft = self.meta[this.bagshuiData.scrollableListEntry].usesLeft
			local tooltipStringsRight = self.meta[this.bagshuiData.scrollableListEntry].usesRight
			if
				_G.IsAltKeyDown()
				and table.getn(self.meta[this.bagshuiData.scrollableListEntry].usesOfProfilesLeft) > 0
			then
				tooltipStringsLeft = self.meta[this.bagshuiData.scrollableListEntry].usesOfProfilesLeft
				tooltipStringsRight = self.meta[this.bagshuiData.scrollableListEntry].usesOfProfilesRight
			end

			if type(tooltipStringsLeft) == "table" and table.getn(tooltipStringsLeft) > 0 then

				_G.GameTooltip:SetOwner(this, "ANCHOR_PRESERVE")
				_G.GameTooltip:ClearAllPoints()
				_G.GameTooltip:SetPoint(
					"TOPRIGHT",
					this,
					"TOPLEFT"
				)
				-- Iterate through the lines of usage info by splitting on newline
				-- and add to tooltip.
				-- In order to get past the 30 text field limit, we're going to
				-- add as single strings with newlines as much as possible.
				BsUtil.TableClear(listTooltipLinesLeft)
				BsUtil.TableClear(listTooltipLinesRight)

				local lastLinePartCount = 1
				local thisLinePartCount
				for i = 1, table.getn(tooltipStringsLeft) do
					thisLinePartCount = (string.len(tooltipStringsLeft[i]) > 0 and 1 or 0) + (string.len(tooltipStringsRight[i] or "") > 0 and 1 or 0)
					if thisLinePartCount ~= lastLinePartCount then
						_G.GameTooltip:AddDoubleLine(table.concat(listTooltipLinesLeft, BS_NEWLINE), (table.getn(listTooltipLinesRight) > 1 and table.concat(listTooltipLinesRight, BS_NEWLINE) or nil))
						BsUtil.TableClear(listTooltipLinesLeft)
						BsUtil.TableClear(listTooltipLinesRight)
					end
					table.insert(listTooltipLinesLeft, tooltipStringsLeft[i] or " ")
					if string.len(tooltipStringsRight[i] or "") > 0 then
						table.insert(listTooltipLinesRight, tooltipStringsRight[i])
					end
					lastLinePartCount = thisLinePartCount
				end
				_G.GameTooltip:AddDoubleLine(table.concat(listTooltipLinesLeft, BS_NEWLINE), (table.getn(listTooltipLinesRight) > 1 and table.concat(listTooltipLinesRight, BS_NEWLINE) or nil))


				-- Add hint about holding/releasing Alt.
				local altAction, altResult
				if _G.IsAltKeyDown() and table.getn(self.meta[this.bagshuiData.scrollableListEntry].usesLeft) > 0 and table.getn(self.meta[this.bagshuiData.scrollableListEntry].usesOfProfilesLeft) > 0 then
					altAction = L.ReleaseAlt
					altResult = string.format(L.ObjectList_ShowObjectUses, self.objectType)
				elseif table.getn(self.meta[this.bagshuiData.scrollableListEntry].usesOfProfilesLeft) > 0 then
					altAction = L.HoldAlt
					altResult = L.ObjectList_ShowProfileUses
				end
				if altAction and altResult then
					_G.GameTooltip:AddLine(BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. string.format(L.Symbol_Colon, altResult) .. " " .. altAction)
				end
				_G.GameTooltip:Show()
			end
		end,
		managerListEntryOnLeave = function(this)
			this = this or _G.this
			if _G.GameTooltip:IsOwned(this) then
				_G.GameTooltip:Hide()
			end
		end,

		editorSuperclass = objectEditor,
		editorWidth = 550,
		editorHeight = 550,
		editorFields = {
			"name",
		},
		editorFieldProperties = {
			name = {
				required = true
			},
		},
	}

	-- Add parameter overrides.
	if type(objectManagerParamOverrides) == "table" then
		for param, value in pairs(objectManagerParamOverrides) do
			objectManagerParams[param] = value
		end
	end

	self.objectManager = Bagshui.prototypes.ObjectManager:New(objectManagerParams)
	self.objectManager.objectList = self
end


end)