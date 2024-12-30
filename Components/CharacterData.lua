-- Bagshui Character Data Management UI
-- Exposes: BsCharacterData (and Bagshui.components.CharacterData)
-- Raises: BAGSHUI_CHARACTERDATA_UPDATE
-- Consumes: BAGSHUI_CHARACTERDATA_UPDATE

Bagshui:AddComponent(function()

-- CharacterData class is built on the ObjectList prototype, even though it
-- only exists to provide a UI for deleting old alts.
local CharacterData = Bagshui.prototypes.ObjectList:New({

	dataStorageKey = "characters",
	objectName = "CharacterData",
	objectNamePlural = "CharacterData",
	wikiPage = BS_WIKI_PAGES.CharacterData,

	-- Disable all table content filters.
	objectSkeleton = BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD,
	objectTemplate = BS_OBJECT_LIST_TEMPLATE_TABLE_WILDCARD,

	managerMultiSelect = false,

	disableObjectCreation = true,
	disableObjectEditing = true,
	disableObjectSharing = true,

	disableObjectDeletionFunc = function(characterId)
		-- Loop for scrollable list entries.
		if type(characterId) == "table" then
			for charId, _ in pairs(characterId) do
				if charId == Bagshui.currentCharacterId then
					return true
				end
			end
		end
		-- Single object ID.
		return characterId == Bagshui.currentCharacterId
	end,

	-- This metatable will be assigned to each character in SavedVariables BagshuiData.characters.
	-- It's basically a hack that quickly makes the character data structures compatible
	-- with ObjectList's expectations, since ObjectList wasn't originally designed
	-- to handle an object that stores its primary data in a sub-table. (Adding this metatable
	-- is safe because there is no arbitrary access to keys in the character table.)
	objectMetatable = {
		__index = function(tbl, key)
			if rawget(tbl, key) then
				return rawget(tbl, key)
			end
			if rawget(tbl, "info") then
				return rawget(tbl, "info")[key]
			end
			return rawget(tbl, key)
		end
	},

	---@type string[]
	-- List of cached characters that will be used for the Character menu.
	-- Managed by `CharacterData:Update()`.
	characterIdList = {},

	---@type string[]
	-- Same as `characterIdList`, but formatted names.
	characterNameList = {},

})

Bagshui.environment.BsCharacterData = CharacterData
Bagshui.components.CharacterData = CharacterData



--- Initialize the CharacterData class.
function CharacterData:Init()

	-- Add sorting functions.
	self.sortedIdLists.realm = {}
	self.idListSortFunctions.realm = function(idA, idB)
		return (self._idListSortFunctions_objectList[idA].realm or "") < (self._idListSortFunctions_objectList[idB].realm or "")
	end
	self.sortedIdLists.lastLogout = {}
	self.idListSortFunctions.lastLogout = function(idA, idB)
		return (self._idListSortFunctions_objectList[idA].lastLogout or 0) < (self._idListSortFunctions_objectList[idB].lastLogout or 0)
	end

	-- Calls ObjectList:Init().
	self._super.Init(self)

	-- Generate the Character auto-split menu's initial list.
	CharacterData:Update()

	-- Add auto-split menu that lists all characters.
	Bagshui.prototypes.Menus:AddAutoSplitMenu(
		BS_AUTO_SPLIT_MENU_TYPE.CHARACTERS,
		{
			defaultIdList = self.characterIdList,
			nameFunc = function(id)
				return BsCharacter:FormatCharacterName(id, true) or id
			end,
			-- Manage...
			extraItems = {
				{
					text = string.format(L.Symbol_Ellipsis, L.Manage),
					tooltipTitle = L.Manage,
					tooltipText = string.format(L.Prefix_Manage, L.CharacterData),
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


--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function CharacterData:OnEvent(event, arg1)

	-- Check to see if the ObjectList prototype is handling this event
	if self._super.OnEvent(self, event, arg1) then
		return
	end

	-- Refresh the Character auto-split menu.
	if event == "BAGSHUI_CHARACTERDATA_UPDATE" then
		self:Update()
		return
	end
end


--- Subclass override for InitUI() to handle class-specific details.
function CharacterData:InitUi()

	-- Calls ObjectList:InitUi().
	self._super.InitUi(self,
		nil,  -- No custom Object Manager needed.
		nil,  -- No custom Object Editor needed.
		-- Not much to configure since there's no editing.
		{
			managerHeight = 400,
			managerWidth = 450,
			managerColumns = {
				{
					field = "name",
					title = L.ObjectManager_Column_Name,
					widthPercent = "45",
					currentSortOrder = "ASC",
					lastSortOrder = "ASC",
				},
				{
					field = "realm",
					title = L.ObjectManager_Column_Realm,
					widthPercent = "25",
					lastSortOrder = "ASC",
				},
				{
					field = "lastLogout",
					title = L.ObjectManager_Column_LastInventoryUpdate,
					widthPercent = "25",
					lastSortOrder = "ASC",
				},
			},

			-- Add error indicator to category name.
			managerColumnTextFunc = function(fieldName, id, obj, preliminaryDisplayValue)
				if fieldName == "name" then
					return BsCharacter:FormatCharacterName(id) or preliminaryDisplayValue
				elseif fieldName == "lastLogout" then
					return _G.date("%Y-%b-%d", preliminaryDisplayValue)
				end
				return preliminaryDisplayValue
			end,

			deletePrompt = L.ObjectManager_DeleteForPrompt,
			deletePromptExtraInfo = L.CharacterDataManager_DeleteInfo,
		}
	)

end



-- Keep the Character auto-split menu current when old alts are deleted.
function CharacterData:Update()
	BsUtil.TableClear(self.characterIdList)

	-- Sort the list of characters alphabetically but sort by realm first.
	for character, _ in pairs(Bagshui.characters) do
		if character ~= Bagshui.currentCharacterId then
			table.insert(self.characterIdList, character)
		end
	end
	table.sort(self.characterIdList, function(a, b)
		return
			tostring(Bagshui.characters[a].info.realm or "") .. " " .. tostring(Bagshui.characters[a].info.name or "")
			<
			tostring(Bagshui.characters[b].info.realm or "") .. " " .. tostring(Bagshui.characters[b].info.name or "")
	end)
	-- Place the current character at the top.
	table.insert(self.characterIdList, 1, Bagshui.currentCharacterId)

	-- Refresh formatted name list.
	BsUtil.TableClear(self.characterNameList)
	for _, id in ipairs(self.characterIdList) do
		table.insert(self.characterNameList, BsCharacter:FormatCharacterName(id, true) or id)
	end
end



-- Class event registration.
-- This is done at the end because RegisterEvent expects the class to have an OnEvent function.
Bagshui:RegisterEvent("BAGSHUI_CHARACTERDATA_UPDATE", CharacterData)


end)