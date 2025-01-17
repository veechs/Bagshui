-- Bagshui Profiles
-- Exposes: BSProfiles (and Bagshui.components.Profiles)
-- Raises: BAGSHUI_PROFILE_UPDATE
--
-- Each profile contains one of every BS_PROFILE_TYPE, which allows things like
-- sharing the same Design profile across multiple characters but giving each
-- one its own Structure profile.
--
-- The built-in profiles are available for use as templates only; since they're
-- not editable it doesn't make sense to make them selectable for active use.

Bagshui:AddComponent(function()


-- ### Profile objects look like this:
-- ```
-- {
-- 	name = "Name",
-- 	structure = { profile data },
-- 	design = { profile data },
-- }
-- ```
--
-- ### `Structure` profile:
-- ```
-- {
-- 	primary = {
-- 		-- A `layout` table is an array of the rows that make up the layout,
-- 		-- with each row being an array of the groups within that row.
-- 		-- Additional group data (colors, sort order, etc.) can also be present.
-- 		---@type { name: string, categories: string[] }[]
-- 		layout = {
-- 			{
--				{
--					name = "Group 1",
--					categories = {
--						"categoryId1",
--						"categoryId2",
--						"categoryIdN",
--					},
--				},
--				{
--					name = "Group 2",
--					categories = {
--						"categoryId3",
--					},
--				},
--
-- 			},
-- 		},
-- 		-- Structure profiles will also contain any inventory-scoped setting
-- 		-- with `profileScope = BS_SETTING_PROFILE_SCOPE.STRUCTURE` in Config\Settings.lua.
-- 	},
--
-- 	-- Docked inventory classes currently don't have the option to select their
-- 	-- Structure profile independent of the class to which they're docked, so
-- 	-- their unique layout is stored in the same profile, just in a different spot.
-- 	---@type table<BS_INVENTORY_TYPE, { layout: table }>
-- 	docked = {
-- 		Keyring = { <same data structure as `primary` }
-- 	}
-- }
-- ```
--
-- ### `Design` profile:
-- These are simply a list of settings, since Designs are driven entirely by
-- inventory-scoped settings that have `profileScope = BS_SETTING_PROFILE_SCOPE.DESIGN`
-- in Config\Settings.lua.
-- 
-- ### Note about `BS_PROFILE_SKELETON`:
-- Building out a skeleton for all the profile data is too much of a pain,
-- so we're going to accept whatever is there by adding BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD
-- in the loop below. It all gets validated as it's used anyway.
---@type table<string|BS_PROFILE_TYPE, string|table> 
local profileSkeleton = {
	name = "",
}

-- The profile template is intentionally somewhat empty because:
-- - We're only providing the absolute minimum needed to start a layout.
-- - Layout for docked inventory will be filled in by Inventory:ValidateLayout().
-- - Keys for any other profile types will be added in the loop below.
local profileTemplate = {
	name = "",
	structure = {
		primary = {
			layout = {
				{
					{
						name = string.format(L.Prefix_New, L.Group),
						categories = {
							BS_DEFAULT_CATEGORY_ID
						},
					},
				},
			},
		},
	},
}


--- Translate a profile type (PythonCase) to storage key (camelCase).
---@param profileType any
---@return string
local function getProfileTypeStorageKey(profileType)
	return BsUtil.LowercaseFirstLetter(profileType)
end


-- Fill in the skeleton and template keys.
for _, profileType in pairs(BS_PROFILE_TYPE) do
	local profileTypeStorageKey = getProfileTypeStorageKey(profileType)
	profileSkeleton[profileTypeStorageKey] = BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD
	if not profileTemplate[profileTypeStorageKey] then
		profileTemplate[profileTypeStorageKey] = {}
	end
end

Bagshui:AddConstants({
	BS_PROFILE_SKELETON = profileSkeleton,
	BS_NEW_PROFILE_TEMPLATE = profileTemplate,
})

local PROFILES_DATA_STORAGE_KEY = "profiles"



local Profiles = Bagshui.prototypes.ObjectList:New({

	dataStorageKey = PROFILES_DATA_STORAGE_KEY,
	objectVersion = Bagshui.config.Profiles.version,
	objectMigrationFunction = Bagshui.config.Profiles.migrate,
	objectName = "Profile",
	objectNamePlural = "Profiles",
	objectSkeleton = BS_PROFILE_SKELETON,
	objectTemplate = BS_NEW_PROFILE_TEMPLATE,
	defaults = Bagshui.config.Profiles.defaults,
	wikiPage = BS_WIKI_PAGES.Profiles,

	debugResetOnLoad = false and BS_DEBUG,
})
Bagshui.environment.BsProfiles = Profiles
Bagshui.components.Profiles = Profiles



--- Initialize the Profiles class.
function Profiles:Init()
	-- Bagshui:PrintDebug("Profiles Init()")

	-- Calls ObjectList:Init().
	self._super.Init(self)

	-- Ensure profile-related settings are valid and have the data they need to function.
	for _, profileType in pairs(BS_PROFILE_TYPE) do

		-- Reset to Bagshui defaults if any currently configured default profiles don't exist.
		if not self.list[BsSettings["defaultProfile" .. profileType]] then
			-- Bagshui:PrintDebug("defaultProfile" .. profileType .. " doesn't exist!")
			BsSettings:SetDefaults(true, nil, nil, "defaultProfile" .. profileType)
			BsSettings:SetDefaults(true, nil, nil, "createNewProfile" .. profileType)
		end

		-- Link the list of profiles to corresponding settings' lists of valid choices.
		Bagshui.prototypes.Settings._settingInfo["profile" .. profileType].choices = self.list
		Bagshui.prototypes.Settings._settingInfo["defaultProfile" .. profileType].choices = self.list
	end

	-- Add auto-split menu that lists all profiles.
	Bagshui.prototypes.Menus:AddAutoSplitMenu(
		BS_AUTO_SPLIT_MENU_TYPE.PROFILES,
		{
			defaultIdList = self.sortedIdLists.name,
			itemList = self.list,
			sortFunc = function(sortOrderIds)
				self:SortIdList(sortOrderIds)
			end,
			nameFunc = function(id)
				return self:GetName(id) or tostring(id)
			end,
			-- Manage...
			extraItems = {
				{
					text = string.format(L.Symbol_Ellipsis, L.Manage),
					tooltipTitle = L.Manage,
					tooltipText = string.format(L.Prefix_Manage, L.Profiles),
					checked = false,
					value = {
						func = function()
							Bagshui:CloseMenus()
							self:Open()
						end,
					},
				},
			},
		}
	)

end



--- Retrieve a copy of a profile for exporting.
---@param objectId string|number
---@return table exportableData
function Profiles:Export(objectId)

	-- Do the export.
	local export = self._super.Export(self, objectId)

	-- Add dependency lists.
	if export.object then
		export.dependencies[BsCategories] = {}
		export.dependencies[BsSortOrders] = {}

		local profile = self.list[objectId]

		-- Primary Structure.
		self:HandleDependenciesForImportExport(profile.structure.primary, export)

		-- Docked Structure(s).
		if type(profile.structure.docked) == "table" then
			for _, dockedStructure in pairs(profile.structure.docked) do
				self:HandleDependenciesForImportExport(dockedStructure, export)
			end
		end

	end
	return export
end



--- Import the given data as a new profile.
---@param profile table
---@param dependencyMap table<table, table<number, number>>? Define the mapping of Group and Sort Order IDs that were in the export to what they have become on import. See `ObjectList:Export()` for expected format.
---@param force boolean? Import even if an identical object already exists.
---@return number? newObjectId nil when import fails.
function Profiles:Import(profile, dependencyMap, force)

	-- Update dependencies in primary Structure.
	self:HandleDependenciesForImportExport(profile.structure.primary, nil, dependencyMap)

	-- Update dependencies in docked Structure(s).
	if type(profile.structure.docked) == "table" then
		for _, dockedStructure in pairs(profile.structure.docked) do
			self:HandleDependenciesForImportExport(dockedStructure, nil, dependencyMap)
		end
	end

	-- Do the import.
	return self._super.Import(self, profile)
end



--- Get the list of other ObjectList classes on which this one depends.
---@return ObjectList[]? dependencies
function Profiles:GetImportExportDependencies()
	return { BsCategories, BsSortOrders }
end



--- When an export is happening, update the export object's `dependencies` table.
--- Otherwise, update the given `structure`'s dependency references based on `dependencyMap`.
---@param structure table Profile Structure component.
---@param export table? Profile export object.
---@param dependencyMap table? See `Profiles:Import()`.
function Profiles:HandleDependenciesForImportExport(structure, export, dependencyMap)

	-- Categories.
	for rowNum, row in ipairs(structure.layout) do
		for groupNum, group in ipairs(row) do
			if type(group.categories) == "table" then
				for i = 1, table.getn(group.categories) do
					if export then
						if not BsCategories:IsBuiltIn(group.categories[i]) then
							table.insert(
								export.dependencies[BsCategories],
								group.categories[i]
							)
						end
					elseif dependencyMap then
						self:UpdateDependency(group.categories, i, BsCategories, dependencyMap)
					end
				end
			end
		end
	end

	-- Sort Orders.
	if export then
		if not BsSortOrders:IsBuiltIn(structure.defaultSortOrder) then
			table.insert(
				export.dependencies[BsSortOrders],
				structure.defaultSortOrder
			)
		end
	elseif dependencyMap then
		self:UpdateDependency(structure, "defaultSortOrder", BsSortOrders, dependencyMap)
	end

	for rowNum, row in ipairs(structure.layout) do
		for groupNum, group in ipairs(row) do
			if group.sortOrder then
				if export then
					if not BsSortOrders:IsBuiltIn(group.sortOrder) then
						table.insert(
							export.dependencies[BsSortOrders],
							group.sortOrder
						)
					end
				elseif dependencyMap then
					self:UpdateDependency(group, "sortOrder", BsSortOrders, dependencyMap)
				end
			end
		end
	end
end



--- Replace a reference to a dependency.
---@param objectTable table List of object IDs.
---@param objectKey any Key within `objectTable` whose value should be updated.
---@param objectList table Bagshui ObjectList within `dependencyMap` where object ID mappings can be found.
---@param dependencyMap table Object mapping. See `ObjectList:Export()` for notes.
function Profiles:UpdateDependency(objectTable, objectKey, objectList, dependencyMap)
	if
		dependencyMap
		and dependencyMap[objectList]
		and objectTable
		and objectTable[objectKey]
		and dependencyMap[objectList][objectTable[objectKey]]
	then
		objectTable[objectKey] = dependencyMap[objectList][objectTable[objectKey]]
	end
end



--- Given a profile ID and type, returns the profile that SHOULD be used along with its id.
--- Also validates the profile structure, so this is the function that other classes should call.
--- Wrapper for `Profiles:GetUsableProfileId()`, so see that function for more details.
---@param profileId string|number A profile identifier.
---@param profileType BS_PROFILE_TYPE
---@return table profileToUse Profile object that should be used.
---@return string|number ID of the profile that should be used.
function Profiles:GetUsableProfile(profileId, profileType)
	assert(profileType, "Profiles:GetUsableProfile() - profileType is required")
	profileId = self:GetUsableProfileId(profileId, profileType)
	self:VerifyProfileStructure(profileId)
	return self.list[profileId], profileId
end



--- Given a profile ID and type, returns the ID of the profile that SHOULD be used.
--- Order of priority:
--- 1. Given profile, if valid and NOT a builtin.§
--- 2. Profile named after the current character, if one exists.§
--- 3. The account-wide default profile, if it exists.
--- 4. The default profile as configured in BS_DEFAULT_PROFILE.
--- 
--- § Only if `profileId` is nil, which indicates a first login. In that case
--- always proceed to defaults and cloning.
--- 
--- Cloning logic:
--- If a profile is selected in step 3, it will be cloned if createNewProfile[profileType] == true.
--- If a profile is selected in step 4, it will ALWAYS be cloned.
---@param profileId string|number A profile identifier.
---@param profileType BS_PROFILE_TYPE
---@return string|number # ID of the profile that should be used.
function Profiles:GetUsableProfileId(profileId, profileType)
	-- Bagshui:PrintDebug("GetUsableProfileId() " .. profileType .. " : " .. tostring(profileId))

	-- If the profile ID exists, just use it, so long as it's not a builtin
	-- (which needs to be cloned) or a first login.
	if profileId and self.list[profileId] and not self.list[profileId].builtin then
		return profileId
	end

	-- First fallback is a profile named after the current character.
	local characterProfileId
	if not self.list[profileId] then
		for existingProfileId, existingProfileInfo in pairs(self.list) do
			if existingProfileInfo.name == Bagshui.currentCharacterId then
				characterProfileId = existingProfileId
			end
		end
	end
	-- Only fall back to the character-named profile if it's not a first login.
	if profileId and characterProfileId then
		return characterProfileId
	end

	-- Check to see if we should be directly using or cloning an existing profile.
	local defaultProfileId = BsSettings["defaultProfile" .. profileType]
	local clone = BsSettings["createNewProfile" .. profileType]
	local profileTypeStorageKey = self:GetProfileStorageKey(profileType)

	-- Make sure that profile exists and has the needed profile data.
	-- If not, fall back to the default (which needs to be cloned).
	if not self.list[defaultProfileId] or not self.list[defaultProfileId][profileTypeStorageKey] then
		defaultProfileId = BS_DEFAULT_PROFILE[profileType]
		clone = true
	end

	-- Builtin profiles always require cloning because they're read-only.
	if self.list[defaultProfileId].builtin then
		clone = true
	end

	-- We've found a valid profile that should be used directly.
	if not clone then
		return defaultProfileId
	end

	-- We need to clone the profile.
	local newProfileId
	-- Don't try to create the same character profile multiple times.
	if characterProfileId then
		-- When the character profile already exists, overwrite this profile type's settings.
		self:Copy(defaultProfileId, characterProfileId, profileTypeStorageKey)
		newProfileId = characterProfileId
	else
		-- Character profile doesn't exist yet.
		newProfileId = self:Clone(defaultProfileId, Bagshui.currentCharacterId)
	end

	return newProfileId
end



--- Given a profile ID, ensure its structure is ready for use.
---@param profileId string|number A profile identifier.
function Profiles:VerifyProfileStructure(profileId)
	if not self.list[profileId] then
		return
	end

	for _, profileType in pairs(BS_PROFILE_TYPE) do
		if not self.list[profileId][BsUtil.LowercaseFirstLetter(profileType)] then
			self.list[profileId][BsUtil.LowercaseFirstLetter(profileType)] = {}
		end
	end

	-- Additional table creation for Structure profiles.
	if not self.list[profileId].structure.primary then
		self.list[profileId].structure.primary = {}
	end
	if not self.list[profileId].structure.primary.layout then
		self.list[profileId].structure.primary.layout = {}
		BsUtil.TableCopy(BS_NEW_PROFILE_TEMPLATE.structure.primary.layout, self.list[profileId].structure.primary.layout)
	end

	if not self.list[profileId].structure.docked then
		self.list[profileId].structure.docked = {}
	end
	for inventoryType, inventoryConfig in pairs(Bagshui.config.Inventory) do
		if inventoryConfig.dockTo then
			if not self.list[profileId].structure.docked[inventoryType] then
				self.list[profileId].structure.docked[inventoryType] = {}
			end
			if not self.list[profileId].structure.docked[inventoryType].layout then
				self.list[profileId].structure.docked[inventoryType].layout = {}
				BsUtil.TableCopy(BS_NEW_PROFILE_TEMPLATE.structure.primary.layout, self.list[profileId].structure.docked[inventoryType].layout)
			end
		end
	end

end



--- Translate a profile type (PythonCase) to storage key (camelCase).
---@param profileType any
---@return string
function Profiles:GetProfileStorageKey(profileType)
	return getProfileTypeStorageKey(profileType)
end





local _getUses_defaultProfiles = {}
local _getUses_inventoryTypes = {}
local _getUses_activeProfiles = {}


--- Populate the "uses" metadata properties of the profile with tooltip-ready strings.
--- 
--- Produces something like...
--- 
--- ```none
--- Profile uses:
--- Default:
--- • Structure
--- • Design
--- 
--- <Character Name>:
--- - Bags (Structure, Design)
--- - Bank (Design)
--- ```
---@param objectId string|number Profile ID.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
---@param compact boolean? Minimized version that doesn't take as many lines to display. Primarily intended for use by `Profiles:GetProfilesUsingObject()`.
---@return boolean inUse Whether the object is being used.
function Profiles:GetUses(objectId, objectMetadata, compact)
	if not BsCharacterData.list then
		return false
	end

	self:ResetUses(objectMetadata)

	-- BsUtil.TableClear(self._getUses_temp)
	BsUtil.TableClear(_getUses_defaultProfiles)

	-- Determine whether this is the default profile.
	for _, profileType in ipairs(BS_PROFILE_ORDER) do
		profileType = BS_PROFILE_TYPE[profileType]
		if BsSettings["defaultProfile" .. profileType] == objectId then
			table.insert(_getUses_defaultProfiles, L["Profile_" .. profileType])
		end
	end
	if table.getn(_getUses_defaultProfiles) > 0 then
		if compact then
			-- • Default: Structure, Design
			self:AddUse(objectMetadata, "uses", "• " .. string.format(L.Symbol_Colon, L.Default) .. " " .. table.concat(_getUses_defaultProfiles, ", "))
		else
			-- Default:
			-- • Structure
			-- • Design
			self:AddUse(objectMetadata, "uses", string.format(L.Symbol_Colon, L.Default))
			self:AddUse(objectMetadata, "uses", _getUses_defaultProfiles, nil, nil, "• ")
		end
	end

	-- Find inventories where this is the active profile by iterating characters,
	-- then going through their inventories.
	for characterId, characterData in pairs(BsCharacterData.list) do
		BsUtil.TableClear(_getUses_inventoryTypes)
		-- Iterate inventory types.
		for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
			-- Skip docked inventories (see inventoryName comment).
			if not Bagshui.components[inventoryType].dockTo then
				-- When there is another class docked to this one, show it as Primary/Docked
				-- since the docked class always shares the same profile settings as the primary.
				local inventoryName = L[inventoryType] .. (Bagshui.dockedInventories[inventoryType] and ("/" .. L[Bagshui.dockedInventories[inventoryType]]) or "")

				BsUtil.TableClear(_getUses_activeProfiles)

				-- The dockTo check isn't really necessary since we're skipping docked inventories,
				-- but it's getting left in case it's useful in the future.
				local inventoryData = characterData[Bagshui.components[Bagshui.components[inventoryType].dockTo or inventoryType].inventoryTypeSavedVars]

				-- Check active profile setting for each profile type in this inventory class.
				for _, profileType in ipairs(BS_PROFILE_ORDER) do
					profileType = BS_PROFILE_TYPE[profileType]
					if inventoryData and inventoryData.settings and inventoryData.settings["profile" .. profileType] == objectId then
						-- In compact mode, use the abbreviated version (i.e. Struct instead of Structure).
						table.insert(_getUses_activeProfiles, L["Profile_" .. (compact and "Abbrev_" or "") .. profileType])
					end
				end

				if table.getn(_getUses_activeProfiles) > 0 then
					-- Bags (Structure, Design)
					-- or for compact:
					-- Bags (Struct, Dsgn)
					table.insert(_getUses_inventoryTypes, inventoryName .. " (" .. table.concat(_getUses_activeProfiles, ", ") .. ")")
				end
			end
		end

		if table.getn(_getUses_inventoryTypes) > 0 then
			if compact then
				-- - <Character Name>
				--   Bags (Struct); Bank (Struct, Dsgn)
				-- table.insert(self._getUses_temp, "- " .. BsCharacter:FormatCharacterName(characterId, true) .. "\n   " .. table.concat(_getUses_inventoryTypes, "; "))
				self:AddUse(objectMetadata, "uses", "- " .. BsCharacter:FormatCharacterName(characterId, true))
				self:AddUse(objectMetadata, "uses", "   " .. table.concat(_getUses_inventoryTypes, "; "))
			else
				-- <Character Name>:
				-- - Bags (Structure, Design)
				-- - Bank (Design)
				-- table.insert(self._getUses_temp, BsCharacter:FormatCharacterName(characterId, true) .. ":\n- " .. table.concat(_getUses_inventoryTypes, "\n- "))
				self:AddUse(objectMetadata, "uses", BsCharacter:FormatCharacterName(characterId, true))
				self:AddUse(objectMetadata, "uses", _getUses_inventoryTypes, nil, nil, "- ")
			end
		end
	end

	-- Heading.
	if not compact and table.getn(objectMetadata.usesLeft) > 0 then
		self:AddUse(objectMetadata, "uses", BS_FONT_COLOR.BAGSHUI .. L.Object_ProfileUses .. FONT_COLOR_CODE_CLOSE, nil, 1)
	end

	return table.getn(objectMetadata.usesLeft) > 0
end



-- Reusable metadata table for `Profiles:GetProfilesUsingObject()`, since we need to get profile use information.
-- This table will be passed to `Profiles:GetUses()` instead of the normal object metadata table, and it will
-- fill in `usesLeft` and `usesRight`, which will then be transferred to the actual object's `usesOfProfilesLeft/Right`.
local _getProfilesUsingObject_tempMetadata = {
	usesLeft = {},
	usesRight = {},
	usesOfProfilesLeft = {},
	usesOfProfilesRight = {},
}


--- Find all profiles that reference a given object. Returns a single newline-separated
--- string, same as `GetUses()` (and is called from the `GetUses()` function of Categories
--- and SortOrders).
--- 
--- There is so much shared code between Categories and Sort Orders that it made
--- sense to consolidate it all here.
--- 
--- Produces something like...
--- 
--- ### Categories
--- 
--- ```none
--- Used in profiles:
--- Bagshui                Bind on Equip [4:2]
--- <Character> - <Realm>  Bind on Equip [4:2]
--- ```
--- ,
--- ```none
--- Profile uses:
--- Bagshui
--- • Default: Structure, Design
--- <Character> - <Realm> 
--- - <Character> [<Class>] • <Realm>
---   Bags/Keyring (Struct, Dsgn); Bank (Struct, Dsgn)
--- ```
--- 
--- ### Sort Orders
--- 
--- #### For defaults:
--- ```none
--- Used in profiles:
--- Bagshui                Default
--- <Character> - <Realm>  Default
--- ```
--- ,
--- ```none
--- Profile uses:
--- (Same as above)
--- ```
--- 
--- #### For those assigned to specific groups:
--- 
--- ```none
--- Used in profiles:
--- Bagshui
--- - Food [2:4]
--- <Character> - <Realm>
--- - Food [2:4]
--- ```
--- ,
--- ```none
--- Profile uses:
--- (Same as above)
--- ```
---@param objectId string|number Unique object identifier.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
---@param objectClass table The class (BsCategories or BsSortOrders) that the object belongs to.
---@return boolean inUse Whether the object is being used.
function Profiles:GetProfilesUsingObject(objectId, objectMetadata, objectClass)

	self:ResetUses(objectMetadata)

	-- We're going to iterate through all profiles, then within each profile,
	-- check the primary and docked Structure. These are the only places
	-- Categories and Sort Orders are referenced; there's no need to look at the
	-- Design parts.

	for _, profileId in ipairs(self.sortedIdLists.name) do
		local profile = self.list[profileId]
		-- Get the use information about this profile in compact form to add to the bottom of the output.
		local profileInUse = self:GetUses(profileId, _getProfilesUsingObject_tempMetadata, true)
		local profileName = (profileInUse and HIGHLIGHT_FONT_COLOR_CODE or GRAY_FONT_COLOR_CODE) .. (self:GetName(profileId, false, false) or tostring(profileId))
		local usedInProfile = false
		if type(profile.structure) == "table" then

			-- Primary Structure.
			if
				self:GetObjectUsesInStructure(
					objectId,
					objectMetadata,
					objectClass,
					profileName .. FONT_COLOR_CODE_CLOSE,
					profile.structure.primary
				)
			then
				usedInProfile = true
			end


			-- Docked Structure(s).
			if type(profile.structure.docked) == "table" then
				for dockedInventoryType, dockedStructure in pairs(profile.structure.docked) do
					if
						self:GetObjectUsesInStructure(
							objectId,
							objectMetadata,
							objectClass,
							profileName .. " (" .. L[dockedInventoryType] .. ")" .. FONT_COLOR_CODE_CLOSE,
							dockedStructure
						)
					then
						usedInProfile = true
					end
				end
			end

		end


		-- Add profile use information when the object is used in this profile.
		if usedInProfile and table.getn(_getProfilesUsingObject_tempMetadata.usesLeft) > 0 then
			self:AddUse(objectMetadata, "usesOfProfiles", profileName .. FONT_COLOR_CODE_CLOSE)
			-- Transfer profile use data from temp tables to this object's metadata.
			self:AddUse(objectMetadata, "usesOfProfiles", _getProfilesUsingObject_tempMetadata.usesLeft, _getProfilesUsingObject_tempMetadata.usesRight)
		end
	end

	-- Add header to uses.
	if table.getn(objectMetadata.usesLeft) > 0 then
		self:AddUse(objectMetadata, "uses", BS_FONT_COLOR.BAGSHUI .. L.Object_UsedInProfiles .. FONT_COLOR_CODE_CLOSE, nil, 1)
	end

	-- Add header to profile uses.
	if table.getn(objectMetadata.usesOfProfilesLeft) > 0 then
		self:AddUse(objectMetadata, "usesOfProfiles", BS_FONT_COLOR.BAGSHUI .. L.Object_ProfileUses .. FONT_COLOR_CODE_CLOSE, nil, 1)
	end

	return table.getn(objectMetadata.usesLeft) > 0
end



-- Reusable table for GetObjectUsesInStructure().
local _getObjectUsesInStructure_details = {}


--- Get information about where the given object (Category or Sort Order) is used within
--- the given Structure profile component.
--- 
--- There is so much shared code between Categories and Sort Orders that it made
--- sense to consolidate it all here.
---@param objectId string|number Unique ID for the object.
---@param objectMetadata table Metadata table created by `ObjectList:RefreshUsage()`.
---@param objectClass table Class that owns the object (the actual class object, not any sort of string). So for Categories, pass the `BsCategories` object.
---@param profileName string Profile to which the `structure` component belongs.
---@param structure table Structure profile component to be examined.
---@return boolean inUse
function Profiles:GetObjectUsesInStructure(objectId, objectMetadata, objectClass, profileName, structure)
	if type(structure) ~= "table" or type(structure.layout) ~= "table" then
		return false
	end

	if objectClass == BsCategories then
		-- Iterate the layout to find which group, if any, contains the given category.
		for rowNum, row in ipairs(structure.layout) do
			for groupNum, group in ipairs(row) do
				if type(group.categories) == "table" then
					for _, categoryInLayout in ipairs(group.categories) do
						if categoryInLayout == objectId then
							-- [Category Name]       [Group Using Category]
							self:AddUse(
								objectMetadata, "uses",
								profileName,
								(group.name or L.UnnamedGroup) .. GRAY_FONT_COLOR_CODE .. " [" .. rowNum .. ":" .. groupNum .. "]" .. FONT_COLOR_CODE_CLOSE
							)
							return true
						end
					end
				end
			end
		end


	elseif objectClass == BsSortOrders then
		-- For Sort Orders, we need to know whether it is the default for the Structure,
		-- and also need to iterate and find all groups where it's the chosen Sort Order.
		BsUtil.TableClear(_getObjectUsesInStructure_details)

		local isDefault = (structure.defaultSortOrder == objectId)

		-- Fill the details table with a list of groups that use this sort order so
		-- we can collapse them into a single comma-separated string.
		for rowNum, row in ipairs(structure.layout) do
			for groupNum, group in ipairs(row) do
				if group.sortOrder == objectId then
					table.insert(_getObjectUsesInStructure_details, group.name .. GRAY_FONT_COLOR_CODE .. " [" .. rowNum .. ":" .. groupNum .. "]" .. FONT_COLOR_CODE_CLOSE)
				end
			end
		end

		-- [Profile Name]        Default
		-- • [Group1], [Group2], [Group3]
		if isDefault or table.getn(_getObjectUsesInStructure_details) > 0 then
			self:AddUse(objectMetadata, "uses", profileName, isDefault and L.Default or nil)
			if table.getn(_getObjectUsesInStructure_details) > 0 then
				self:AddUse(objectMetadata, "uses", "• " .. table.concat(_getObjectUsesInStructure_details, ", "))
			end
			return true
		end
	end

	return false
end


end)