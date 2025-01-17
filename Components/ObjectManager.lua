-- Bagshui Object Management UI
-- Exposes: Bagshui.prototypes.ObjectManager and Bagshui.prototypes.ObjectEditor
--
-- Interface prototype for editing objects (Categories, Sort Orders, etc.).
-- The ObjectList class automatically prepares the management UI, so these
-- classes don't usually need to be manually instantiated.

Bagshui:AddComponent(function()


--#region ObjectManager


local ObjectManager = {}
Bagshui.prototypes.ObjectManager = ObjectManager


--- Return the list of object IDs (sorted ASCENDING) that should be displayed in the object list.  
--- **REQUIRED** subclass method.
---@param sortProperty string? Get the list sorted by the given property. When not specified, use `self.sortField`.
---@return (string|number)[]
function ObjectManager:GetObjectList(sortProperty)
	Bagshui:PrintError("GetObjectList() has not been implemented for this instance of the ObjectManager class")
	return {}
end


--- Return a table with information about a given object based on its ID.  
--- **REQUIRED** subclass method *unless* `listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM` is true.
---@param objectId string|number
---@return table? objectInfo
function ObjectManager:GetObjectInfo(objectId)
	Bagshui:PrintError("GetObjectInfo() has not been implemented for this instance of the ObjectManager class")
	return nil
end



--- Delete an object (confirmation will have already been obtained).
--- **REQUIRED** subclass method *unless* `disableObjectDeletion` is true.
---@param objectId string|number
---@return boolean? # true if deletion was successful, false if it failed, nil if object ID was invalid.
function ObjectManager:DeleteObject(objectId)
	Bagshui:PrintError("DeleteObject() has not been implemented for this instance of the ObjectManager class")
	return nil
end



--- Share one ore more objects.
--- **REQUIRED** subclass method if using Share button.
---@param objectIds table<string|number, true> Table of currently selected object IDs.
function ObjectManager:Share(objectIds)
	BsShare:OpenForExport(self, objectIds)
	-- Bagshui:PrintError("Share() has not been implemented for this instance of the ObjectManager class")
end



--- Import data.
--- **REQUIRED** subclass method if using Import button.
function ObjectManager:Import()
	BsShare:OpenForImport()
	-- Bagshui:PrintError("Import() has not been implemented for this instance of the ObjectManager class")
end



--- Return the name of an object based on its ID.  
--- *Optional* subclass method.
---@param objectId string|number
---@return string? # Name of the requested object, if available.
function ObjectManager:GetObjectName(objectId)
	local objectInfo = self:GetObjectInfo(objectId)
	if objectInfo and objectInfo.name then
		return objectInfo.name
	end
	return nil
end



--- Advanced validation of object properties.
--- *Optional* subclass method.
---@param objectId string|number
---@param property string Name of the property to validate.
---@param objectInfo table Object to validate.
---@return boolean
function ObjectManager:IsObjectPropertyValid(objectId, property, objectInfo)
	return true
end



--- Create a new instance of the ObjectManager class.
---
--- At a minimum, the props parameter must contain the following required properties:
---  * `objectType` string: Kind of object this class operates on (Category, SortOrder, etc.), used for:
---    * Object manager name: `<objectType>Manager`
---    * Ui instance name (same as object manager name), if a Ui instance wasn't passed in.
---    * Window title, as `L[<objectType>Manager]` and editor title as `L[<objectType>Editor]`
---    * Field name localization, as `L[<objectType>_Editor_<fieldName>]`
---  * `objectTemplate` table: Template upon which new objects should be based.
---  * `managerColumns` table: Define what columns should be displayed in the Object Manager window (provide this OR `managerDisplayProperty`):
---   ```
---   {
---   	{
---   		field = "fieldName",
---   		title = "Localized Column Title"
---   		widthPercent = [number]  -- Percentage of the list widget the column should take.
---   		currentSortOrder = "ASC/DESC"  -- Only one field should have this populated. This will be the initial sort order.
---   		lastSortOrder = "ASC/DESC",  -- When a column header is clicked, sorting will be done in the OPPOSITE of this.
---   	}
---   }
---   ```
---  * `managerDisplayProperty` string: Name of the object property to be displayed in the Object Manager window (provide this OR `managerColumns`):
---  * `editorFields` string[]: List of field names, in the order they should be displayed.
---  * `editorFieldProperties` table: Defines how properties from objectTemplate map into the editor UI:
---   ```
---   {
---   	[fieldName] = {
---   		required = [true/false], -- Default: false.
---   		widgetType = [EditBox/ScrollableEditBox/ItemList],  -- Default: EditBox.
---   		widgetWidth = [number]  -- Default: Whatever editorDimensions.widgetWidth is.
---   		widgetHeight = [number]  -- Default: Whatever editorDimensions.widgetHeight is.
---   		monospace = [true/false],  -- Default: false (only applicable to EditBox/ScrollableEditBox).
---   	}
---   }
---   ```
---
--- Optional fields:
---
---  * `objectName`/`objectNamePlural` string: Localizable strings for object name.
---  * `listType` BS_UI_SCROLLABLE_LIST_TYPE: List type (defaults to TEXT).
---  * `managerMultiSelect` boolean: Set false to disable multiple selection for the main list (default is true!).
---  * `managerCheckboxes` boolean: Set true to show a checkbox next to each item (managerMultiSelect must be true).
---  * `managerHideColumnHeaders` boolean: Set true to prevent list column headers from showing.
---  * `managerAddButtonOnClick` function: Override the normal behavior of the Add button in the Object Manger UI.
---  * `managerToolbarModification` function(toolbarButtonTable) -> nil: Modify the Object Manger toolbar configuration prior to UI creation.
---  * `disableObject<Creation/Deletion/Editing/Sharing>` boolean: Prevent the associated action and hide the toolbar button, unless `showDisabledToolbarButtons` is `true`.
---  * `disableObject<Creation/Deletion/Editing/Sharing>Func` function(objectId/objectIds) -> boolean: Per-object based disables. Must accept a string, number, or table. If string/number, will be a single object ID. If a table, the keys will be object IDs.
---  * `showDisabledToolbarButtons` boolean: Display toolbar buttons that are disabled by the `disableObject*` properties instead of hiding them.
---  * `deletePrompt` / `deletePromptExtraInfo` string: Overrides for object deletion prompt text.
---  * `managerSuperclass` / `editorSuperclass` table: Additional class prototypes that will be used to instantiate each manager/editor with multiple inheritance. These classes override anything in this file.
---  * `managerColumnTextFunc` function: See managerColumnTextFunc() declaration just below.
---  * `managerListEntryOnEnter` / `managerListEntryOnLeave` function: `entryOnEnterFunc` / `entryOnLeaveFunc` for `Ui:CreateScrollableList()`.
---  * `managerHeight` / `managerWidth` / `editorWidth` / `editorHeight` number: Override window dimensions.
---  * `editorLabelWidth` / `editorWidgetHeight` / `editorWidgetWidth` number: Override editor widget dimensions.
---  * `updateEvent` string: When this event is raised, refresh the ObjectManager UI list.
---  * `searchPlaceholderText` string: Text to display when the search box is empty.
---  * `wikiPage` string: Name of the Bagshui wiki page to link the help button to.
---  * `helpUrl` string: Full URL to link the help button to.
---@param props table List 
---@return table
function ObjectManager:New(props)
	assert(type(props) == "table", "ObjectManager:New(props): props parameter is required and must be a table")
	assert(type(props.objectType) == "string", "Unable to instantiate ObjectManager: props.objectType is required and must be a string")

	local name = props.objectType .. "Manager"

	assert(props.disableObjectCreation or type(props.objectTemplate) == "table", "Unable to instantiate " .. name .. " ObjectManager: props.objectTemplate is required and must be a table")
	assert(props.disableObjectCreation or props.objectTemplate.name, "Unable to instantiate " .. name .. " ObjectManager: props.objectTemplate MUST have a Name property")

	assert((props.disableObjectCreation and props.disableObjectEditing) or type(props.editorFields) == "table", "Unable to instantiate " .. name .. " ObjectManager: props.editorFields is required and must be a table")
	assert((props.disableObjectCreation and props.disableObjectEditing) or type(props.editorFieldProperties) == "table", "Unable to instantiate " .. name .. " ObjectManager: props.editorFieldProperties is required and must be a table")

	assert(props.listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM or props.managerColumns or props.managerDisplayProperty, "Unable to instantiate " .. name .. " ObjectManager: props.managerColumns or props.managerDisplayProperty is required")


	--- Given a field name, return the text that should be displayed in the Object Manager column view.
	---@param fieldName string
	---@param objectId string|number
	---@param objectInfo table Object data.
	---@param preliminaryDisplayValue string The text that has been selected for display.
	---@return string displayString
	local function managerColumnTextFunc(fieldName, objectId, objectInfo, preliminaryDisplayValue)
		local updatedDisplayValue = preliminaryDisplayValue
		if props.managerColumnTextFunc then
			updatedDisplayValue = props.managerColumnTextFunc(fieldName, objectId, objectInfo, preliminaryDisplayValue)
		end
		if updatedDisplayValue == preliminaryDisplayValue then
			if fieldName == "builtin" then
				updatedDisplayValue = objectInfo[fieldName] ~= nil and (GRAY_FONT_COLOR_CODE .. "Bagshui" .. FONT_COLOR_CODE_CLOSE) or L.Custom
			end
			if fieldName == "inUse" then
				updatedDisplayValue = objectInfo[fieldName] and L.Yes or (GRAY_FONT_COLOR_CODE .. L.No .. FONT_COLOR_CODE_CLOSE)
			end
		end
		return updatedDisplayValue
	end


	-- Prepare new class object.
	local objectManager = {
		_super = ObjectManager,

		name = name,
		listType = props.listType or BS_UI_SCROLLABLE_LIST_TYPE.TEXT,

		-- Array of exiting ObjectEditor instances to check for reusability before creating a new one.
		editors = {},

		objectType = props.objectType or "Undefined",
		objectTemplate = props.objectTemplate,

		objectName = props.objectName,
		objectNamePlural = props.objectNamePlural,

		-- When this event is raised, refresh the ObjectManager UI list.
		updateEvent = props.updateEvent,

		-- Object Manger UI information.
		managerMultiSelect = props.managerMultiSelect ~= false and true or false,
		managerCheckboxes = props.managerCheckboxes,
		managerColumns = props.managerColumns,
		managerDisplayProperty = props.managerDisplayProperty,
		managerHideColumnHeaders = props.managerHideColumnHeaders,
		managerColumnTextFunc = managerColumnTextFunc,
		managerListEntryOnEnter = props.managerListEntryOnEnter,
		managerListEntryOnLeave = props.managerListEntryOnLeave,
		managerSelectionChangedFunc = props.managerSelectionChangedFunc,
		addButtonOnClick = props.managerAddButtonOnClick,
		managerToolbarModification = props.managerToolbarModification,
		searchPlaceholderText = props.searchPlaceholderText,
		managerHelpUrl = props.helpUrl or (props.wikiPage and (BS_WIKI_URL .. props.wikiPage)),

		-- Object Editor UI information.
		editorFields = props.editorFields or {},
		editorFieldProperties = props.editorFieldProperties or {},
		requiredFields = {},

		-- Window sizing.
		dimensions = {
			width = props.managerWidth or 350,
			height = props.managerHeight or 600,
		},
		editorDimensions = {
			width = props.editorWidth or 500,
			height = props.editorHeight or 500,
			labelWidth = props.editorLabelWidth or 150,
			widgetWidth = props.editorWidgetWidth or 350,
			widgetHeight = props.editorWidgetHeight or 18,
		},

		-- Deletion prompt.
		deletePrompt = props.deletePrompt,
		deletePromptExtraInfo = props.deletePromptExtraInfo,

		-- Full read-only modes (we're mostly using per-object read-only).
		disableObjectCreation = props.disableObjectCreation,
		disableObjectDeletion = props.disableObjectDeletion,
		disableObjectEditing = props.disableObjectEditing,
		disableObjectSharing = props.disableObjectSharing,
		disableObjectCreationFunc = props.disableObjectCreationFunc,
		disableObjectDeletionFunc = props.disableObjectDeletionFunc,
		disableObjectEditingFunc = props.disableObjectEditingFunc,
		disableObjectSharingFunc = props.disableObjectSharingFunc,
		showDisabledToolbarButtons = props.showDisabledToolbarButtons,

		-- Used to ensure InitUi() is only called once.
		interfaceInitialized = false,

		-- Consumed by ObjectEditor:New().
		editorSuperclass = props.editorSuperclass,
	}

	-- Instantiate ui class.
	objectManager.ui = Bagshui.prototypes.Ui:New(name, objectManager)

	-- Set up the class object.
	setmetatable(objectManager, self)
	self.__index = self

	-- What we're actually returning. This is a separate table so we can add multiple inheritance.
	local finalManager = objectManager

	-- Provide multiple inheritance.
	-- MUST be done before further initialization so that the correct inheritance path is followed.
	if props.managerSuperclass then
		finalManager = BsUtil.NewClass(props.managerSuperclass, objectManager)
	end

	-- Register update event.
	if props.updateEvent then
		Bagshui:RegisterEvent(props.updateEvent, finalManager)
	end

	-- Ensure all editor fields have a corresponding entry in `editorFieldProperties`
	-- to avoid errors later.
	for _, fieldName in ipairs(finalManager.editorFields) do
		if not finalManager.editorFieldProperties[fieldName] then
			finalManager.editorFieldProperties[fieldName] = {}
		end
	end

	-- Record required fields for Editor use.
	for fieldName, fieldProps in pairs(finalManager.editorFieldProperties) do
		if fieldProps.required then
			table.insert(finalManager.requiredFields, fieldName)
		end
	end

	return finalManager
end



--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function ObjectManager:OnEvent(event, arg1)
	if event == self.updateEvent and self.uiFrame and self.uiFrame:IsVisible() then
		-- Refresh the object list.
		self:UpdateList()
	end
end



--- Display the Object Manager UI.
function ObjectManager:Open()
	-- Ensure UI is built.
	self:InitUi()

	-- Bring to front if already open.
	if self.uiFrame:IsVisible() then
		self.uiFrame:Raise()
		return
	end

	-- Populate the object list.
	self:UpdateList(false)

	-- Display the UI.
	self.uiFrame:SetPoint("CENTER", 0, 0)
	self.uiFrame:Show()
end



--- Hide the Object Manager UI.
function ObjectManager:Close()
	if self.uiFrame then
		self.uiFrame:Hide()
	end
end



--- Initialize the Object Management UI.
function ObjectManager:InitUi()

	-- Things can get messed up if we do this more than once.
	if self.interfaceInitialized then
		return
	end
	self.interfaceInitialized = true

	local ui = self.ui

	-- Create window and add title bar area.
	self.uiFrame = ui:CreateWindowFrame("uiFrame", nil, self.dimensions.width, self.dimensions.height, L[self.name])
	local uiFrame = self.uiFrame

	-- Register this as a child window so the escape key works as expected.
	Bagshui:RegisterFrameAsChildWindow(uiFrame)

	-- Only allow escape to close the manager frame once all editors are closed.
	uiFrame.bagshuiData.lastDirtyCheck = _G.GetTime()
	uiFrame:SetScript("OnUpdate", function()
		if _G.GetTime() - _G.this.bagshuiData.lastDirtyCheck > 0.075 then
			_G.this.openChildrenCount = 0
			for _, editor in ipairs(self.editors) do
				if editor.uiFrame:IsVisible() then
					_G.this.openChildrenCount = _G.this.openChildrenCount + 1
				end
			end
			_G.this.bagshuiData.dirty = (_G.this.openChildrenCount > 0)
			_G.this.bagshuiData.lastDirtyCheck = _G.GetTime()
		end
	end)

	-- Prepare toolbar frame.
	self.toolbar = _G.CreateFrame("Frame", nil, self.uiFrame)
	self.toolbar:SetPoint("TOPLEFT", self.uiFrame.bagshuiData.header, "BOTTOMLEFT", 0, -2)
	self.toolbar:SetPoint("RIGHT", self.uiFrame, "RIGHT", -BsSkin.windowPadding, 0)
	self.toolbar:SetHeight(20)

	-- Toolbar button configuration.
	local toolbarButtons = {
		-- Add
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.ADD,
			skip = self.disableObjectCreation and not self.showDisabledToolbarButtons,
			disable = self.disableObjectCreation,
			scrollableList_DisableFunc = self.disableObjectCreationFunc,
			scrollableList_AutomaticAnchor = true,
			xOffset = BsSkin.toolbarSpacing,
			onClick = function()
				if self.addButtonOnClick then
					self.addButtonOnClick()
				else
					self:NewObject()
				end
			end,
		},
		-- Duplicate
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DUPLICATE,
			skip = self.disableObjectCreation and not self.showDisabledToolbarButtons,
			disable = self.disableObjectCreation,
			scrollableList_DisableFunc = self.disableObjectCreationFunc,
			scrollableList_AutomaticAnchor = true,
			xOffset = BsSkin.toolbarSpacing,
			onClick = function()
				self:EditSelectedObject(true)
			end,
		},
		-- Edit
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.EDIT,
			skip = self.disableObjectEditing and not self.showDisabledToolbarButtons,
			disable = self.disableObjectEditing,
			scrollableList_DisableFunc = self.disableObjectEditingFunc,
			scrollableList_AutomaticAnchor = true,
			xOffset = BsSkin.toolbarGroupSpacing,
			onClick = function()
				self:EditSelectedObject()
			end,
		},
		-- Delete
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DELETE,
			skip = self.disableObjectDeletion and not self.showDisabledToolbarButtons,
			disable = self.disableObjectDeletion,
			scrollableList_DisableFunc = self.disableObjectDeletionFunc,
			scrollableList_AutomaticAnchor = true,
			scrollableList_DisableIfReadOnly = true,
			xOffset = BsSkin.toolbarGroupSpacing,
			onClick = function()
				self:DeleteAfterConfirmation()
			end,
		},
		-- Share
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.SHARE,
			skip = self.disableObjectSharing and not self.showDisabledToolbarButtons,
			disable = self.disableObjectSharing,
			scrollableList_DisableFunc = self.disableObjectSharingFunc,
			scrollableList_AutomaticAnchor = true,
			scrollableList_DisableIfNothingSelected = true,
			scrollableList_DisableIfReadOnly = true,
			xOffset = BsSkin.toolbarGroupSpacing,
			onClick = function()
				self:Share(self.ui.listFrame.bagshuiData.selectedEntries)
			end,
		},
		-- Import
		{
			scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.IMPORT,
			skip = self.disableObjectSharing and not self.showDisabledToolbarButtons,
			disable = self.disableObjectSharing,
			scrollableList_DisableFunc = self.disableObjectSharingFunc,
			scrollableList_AutomaticAnchor = true,
			xOffset = BsSkin.toolbarSpacing,
			onClick = function()
				self:Import()
			end,
		},
	}

	-- Apply any changes to the toolbar buttons.
	if type(self.managerToolbarModification) == "function" then
		self.managerToolbarModification(toolbarButtons)
	end

	-- Add help button.
	if self.managerHelpUrl then
		self.uiFrame.bagshuiData.helpButton = ui:CreateIconButton({
			name = "Help",
			texture = "Question",
			tooltipTitle = L.Help,
			parentFrame = self.uiFrame.bagshuiData.header,
			anchorPoint = "RIGHT",
			anchorToFrame = self.uiFrame.bagshuiData.closeButton,
			anchorToPoint = "LEFT",
			xOffset = -BsSkin.toolbarCloseButtonOffset,
			onClick = function()
				self.ui:ShowUrl(self.managerHelpUrl)
			end,
		})
	end

	-- Build the object list.
	ui.listScrollFrame, ui.listScrollChild, ui.listFrame = ui:CreateScrollableList({
		listType = self.listType,
		namePrefix = "ListFrame",
		parent = uiFrame,
		width = self.dimensions.width - (BsSkin.windowPadding * 2),
		selectable = true,
		multiSelect = self.managerMultiSelect,
		checkboxes = self.managerCheckboxes,

		entryColumns = self.managerColumns,
		entryDisplayProperty = self.managerDisplayProperty,
		hideColumnHeaders = self.managerHideColumnHeaders,

		entryInfoFunc = function(objectId)
			return self:GetObjectInfo(objectId)
		end,

		entryColumnTextFunc = self.managerColumnTextFunc,

		onSortFieldChanged = function(sortField)
			self:SetObjectListSortField(sortField)
		end,

		entryOnEnterFunc = self.managerListEntryOnEnter,
		entryOnLeaveFunc = self.managerListEntryOnLeave,

		buttonAndSearchBoxParent = self.toolbar,
		firstButtonXOffset = 3,
		buttons = toolbarButtons,

		onSelectionChangedFunc = function(listFrame)
			self:UpdateToolbarState()
			if type(self.managerSelectionChangedFunc) == "function" then
				self.managerSelectionChangedFunc(listFrame)
			end
		end,

		onDoubleClickFunc = function()
			self:EditSelectedObject()
		end,

		searchPlaceholderText = self.searchPlaceholderText,
	})


	-- Attach the search box to the last visible button, or to the toolbar if no buttons.

	ui.searchBox = ui.listFrame.bagshuiData.searchBox
	local searchBoxAnchorToFrame, searchBoxAnchorToPoint, searchBoxSpacing

	for i = table.getn(toolbarButtons), 1, -1 do
		if ui:IsFrameShown(ui.listFrame.bagshuiData.buttons[toolbarButtons[i].scrollableList_ButtonName]) then
			searchBoxAnchorToFrame = ui.listFrame.bagshuiData.buttons[toolbarButtons[i].scrollableList_ButtonName]
			searchBoxAnchorToPoint = "RIGHT"
			searchBoxSpacing = BsSkin.toolbarGroupSpacing
			break
		end
	end

	if not searchBoxAnchorToFrame then
		searchBoxAnchorToFrame = self.toolbar
		searchBoxAnchorToPoint = "LEFT"
		searchBoxSpacing = 0
	end

	ui.searchBox:SetPoint("LEFT", searchBoxAnchorToFrame, searchBoxAnchorToPoint, searchBoxSpacing, 0)

	-- Clear search box focus appropriately.
	uiFrame:SetScript("OnMouseUp", function()
		self:CloseMenusAndClearFocuses()
	end)

	-- Using Ui class SetPoint() functions here for reasons explained in Ui.Util.lua.
	ui:SetPoint(ui.listScrollFrame, "TOPLEFT", self.toolbar, "BOTTOMLEFT",  0, -BsSkin.toolbarSpacing)
	ui:SetPoint(ui.listScrollFrame, "BOTTOMLEFT", uiFrame, "BOTTOMLEFT", BsSkin.windowPadding, BsSkin.windowPadding)


end



--- Load/refresh the object list.
---@param preserveSearch boolean? Keep any entered search text (default: true).
function ObjectManager:UpdateList(preserveSearch)
	preserveSearch = type(preserveSearch) ~= "boolean" and true or preserveSearch
	self.ui:PopulateScrollableList(self.ui.listFrame, self:GetObjectList(), nil, nil, preserveSearch)
end



--- Nothing to do by default -- enabling/disabling toolbar buttons is handled in Ui:CreateScrollableList().
--- This is just here in case subclasses need it
function ObjectManager:UpdateToolbarState()
end



--- Create a new object.
--- This is done by passing nil to Edit(), which in turns passes nil to ObjectEditor:Load().
--- (Can't call this New() because the New() method is being used to create a class instance).
---@param template table? Override the default object template.
---@param onFirstSave function? Callback for the first click of the Save button.
---@return string|number? objectId
function ObjectManager:NewObject(template, onFirstSave)
	if
		self.disableObjectCreation
		or (
			type(self.disableObjectCreationFunc) == "function"
			and self.disableObjectCreationFunc()
		)
	then
		return
	end
	return self:EditObject(nil, nil, template, onFirstSave)
end



--- Load the selected object into an ObjectEditor instance.
---@param duplicate boolean? Create a copy of the selected item instead of editing it.
---@param template table? Override the default object template.
function ObjectManager:EditSelectedObject(duplicate, template)
	if not self.ui.listFrame.bagshuiData.selectedEntry then
		return
	end
	if
		self.disableObjectEditing
		or (
			type(self.disableObjectEditingFunc) == "function"
			and self.disableObjectEditingFunc(self.ui.listFrame.bagshuiData.selectedEntry)
		)
	then
		return
	end
	return self:EditObject(self.ui.listFrame.bagshuiData.selectedEntry, duplicate, template)
end



--- Obtain an editor instance and load the given object into it.
---@param objectId string|number?
---@param duplicate boolean? Create a copy of the object instead of editing it.
---@param template table? Override the default object template.
---@param onFirstSave function? Callback for the first click of the Save button.
---@return string|number? # ID of object being edited.
function ObjectManager:EditObject(objectId, duplicate, template, onFirstSave)

	local editor

	-- Reuse an existing editor if it's been closed or if one for this object is already provisioned.
	for _, existingEditor in ipairs(self.editors) do
		if not existingEditor.uiFrame:IsVisible() or existingEditor.objectId == objectId then
			editor = existingEditor
			break
		end
	end

	-- Create new editor instance.
	if not editor then
		editor = self:NewEditor()
	end

	-- Something went terribly wrong.
	if not editor then
		Bagshui:PrintError("Failed to load editor (this shouldn't happen!)")
		return
	end

	-- Load it up.
	local returnObjectId = editor:Load(objectId, duplicate, template, nil, onFirstSave)

	-- Display it.
	editor:BringToFront()

	return returnObjectId
end



--- Prompt for confirmation and perform deletion.
function ObjectManager:DeleteAfterConfirmation()
	local dialogName = "BAGSHUI_DELETE_OBJECT"

	if not _G.StaticPopupDialogs[dialogName] then
		_G.StaticPopupDialogs[dialogName] = {
			text = L.ObjectManager_DeletePrompt,
			button1 = L.Delete,
			button2 = L.Cancel,
			showAlert = 1,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 0,
			--- Perform deletion (no need for OnCancel as that simply needs to do nothing).
			---@param data table Reference to `self.deleteAfterConfirmation_Data`, passed through via the dialog's `data` property.
			OnAccept = function(data)
				for objectId, _ in pairs(data.selectedObjects) do
					-- Final safety check.
					if not  (
							type(self.disableObjectDeletionFunc) == "function"
							and self.disableObjectDeletionFunc(objectId)
						)
					then
						data.manager:DeleteObject(objectId)
					end
				end
			end,
		}

		-- This is intentionally a reference to `ObjectManager` instead of `self` to 
		-- store the property on the class prototype. `self` will still work for other
		-- references via metatable.
		ObjectManager.deleteAfterConfirmation_Data = {
			manager = nil,
			selectedObjects = {},
		}
	end

	-- Make sure there's something to do
	if BsUtil.TrueTableSize(self.ui.listFrame.bagshuiData.selectedEntries) < 1 then
		return
	end

	-- Safety check to prevent deletion.
	if
		self.disableObjectDeletion
		or (
			type(self.disableObjectDeletionFunc) == "function"
			and self.disableObjectDeletionFunc(self.ui.listFrame.bagshuiData.selectedEntries)
		)
	then
		return
	end

	-- Don't preempt any other dialogs or they'll end up calling OnCancel
	if _G.StaticPopup_Visible(dialogName) then
		return
	end

	-- Update dialog properties.

	-- List of objects up for deletion in alphabetical order.
	local objectsToDelete = ""
	for _, objectId in ipairs(self:GetObjectList("name")) do
		if self.ui.listFrame.bagshuiData.selectedEntries[objectId] then
			objectsToDelete = objectsToDelete .. BS_NEWLINE .. self:GetObjectName(objectId)
		end
	end

	-- Prompt text.
	_G.StaticPopupDialogs[dialogName].text = string.format(
		(self.deletePrompt or L.ObjectManager_DeletePrompt),
		string.lower(L[self.objectNamePlural or self.objectName or self.objectType]),
		objectsToDelete,
		(self.deletePromptExtraInfo and (BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. self.deletePromptExtraInfo .. FONT_COLOR_CODE_CLOSE) or "")
	)

	-- Display the dialog and provide the object type and object name to the prompt text
	local dialog = _G.StaticPopup_Show(dialogName)

	-- Pass stuff to dialog functions via the magic data property.
	self.deleteAfterConfirmation_Data.manager = self
	BsUtil.TableCopy(self.ui.listFrame.bagshuiData.selectedEntries, self.deleteAfterConfirmation_Data.selectedObjects)
	if dialog then
		dialog.data = self.deleteAfterConfirmation_Data
	end
end



--- Change the object list sort order.
---@param sortField string
function ObjectManager:SetObjectListSortField(sortField)
	self.sortField = sortField
	self:UpdateList()
end



--- Create a new object editor instance.
--- Separated into its own function so subclasses can override.
---@return table objectEditorInstance
function ObjectManager:NewEditor()
	return Bagshui.prototypes.ObjectEditor:New(self)
end



--- ObjectManager localization is performed by prefixing strings with
--- `self.name` and an underscore.
---@param str string Localization identifier.
---@return string localizedString
function ObjectManager:Localize(str)
	return L[self.name .. "_" .. str]
end



--- Localizes field names via `<self.name>_field_<fieldName>`.
---@param fieldName string Field to be localized.
---@return string localizedString
function ObjectManager:LocalizeField(fieldName)
	return self:Localize("Field_" .. fieldName)
end



--- Multipurpose function that handles closing menus and de-focusing widgets.
--- **DO NOT RENAME** without updating `Ui:CloseMenusAndClearFocuses()`.
---@param menus boolean? Pass `false` to keep menus open.
---@param editBoxes boolean? Pass `false` to preserve text box focus.
---@param listSelections boolean? Pass `false` to keep list selections.
function ObjectManager:CloseMenusAndClearFocuses(menus, editBoxes, listSelections)
	if menus ~= false then
		Bagshui:CloseMenus()
	end
	if editBoxes ~= false then
		self.ui.listFrame.bagshuiData.searchBox:ClearFocus()
	end
	if listSelections ~= false then
		self.ui:SetScrollableListSelection(self.ui.listFrame)
	end
end


--#endregion ObjectManager



--#region ObjectEditor


local ObjectEditor = {}
Bagshui.prototypes.ObjectEditor = ObjectEditor


-- Save the object.
--- **REQUIRED** subclass method.
---@return boolean saveResult Must be true if save was successful.
function ObjectEditor:Save()
	Bagshui:PrintDebug("Save() has not been implemented by this ObjectEditor subclass")
	return false
end



-- Obtain an ID for a new object.
--- **REQUIRED** subclass method.
---@return string|number?
function ObjectEditor:GetNewObjectId()
	Bagshui:PrintDebug("GetNewObjectId() has not been implemented by this ObjectEditor subclass")
	return nil
end



--- Create a new instance of the ObjectEditor class.
---@param manager table ObjectManager class instance.
---@return table objectEditorInstance
function ObjectEditor:New(manager)
	local editorNum = table.getn(manager.editors) + 1
	local editorName = manager.objectType .. "Editor"

	-- Prepare new class object.
	local editor = {
		_super = ObjectEditor,

		name = editorName,

		-- Used for UI element names.
		nameAndNumber = editorName .. editorNum,

		-- Properties to track the object being edited.
		objectId = "",
		-- Copy of the object being edited in its pre-edit state.
		originalObject = nil,
		-- The object being edited in its post-edit state.
		updatedObject = {},
		-- The original object OR the object template, if it's a new object.
		-- This is a direct reference, so DO NOT CHANGE.
		referenceObject = nil,
		-- Subclasses can use this to override the storage destination of a field by
		-- setting `{ fieldName = <destinationTable> }`.
		fieldStorageRedirect = {},

		-- UI element storage.
		editBoxes = {},
		lists = {},
		labelWidgetPairs = {},
		scrollFrames = {},
		scrollChildren = {},
		buttons = {},

		-- Editor state tracking.
		dirtyFields = {},  -- Not currently used, but available if needed.
		fieldErrors = {},

		-- Easy access to ObjectManager properties/functions.
		manager = manager,
		ui = manager.ui,
		editorFields = manager.editorFields,
		objectTemplate = manager.objectTemplate,
		objectType = manager.objectType,
		Localize = manager.Localize,
		LocalizeField = manager.LocalizeField,
	}

	-- Set up the class object.
	setmetatable(editor, self)
	self.__index = self

	-- Determine what we're actually returning.
	local finalEditor = editor

	-- Provide multiple inheritance.
	-- MUST be done before further initialization so that the correct inheritance path is followed.
	if manager.editorSuperclass then
		finalEditor = BsUtil.NewClass(manager.editorSuperclass, editor)
	end

	-- Build the UI.
	finalEditor:InitUi()

	-- Register update event.
	if manager.updateEvent then
		Bagshui:RegisterEvent(manager.updateEvent, finalEditor)
	end

	-- Add to list of available editors.
	-- MUST use finalEditor here because it's going to be a different table than
	-- editor due to how multiple inheritance works.
	table.insert(manager.editors, finalEditor)

	-- Return final object.
	return finalEditor
end



--- Initialize the Object Editor UI.
function ObjectEditor:InitUi()

	local ui = self.ui
	local manager = self.manager

	local editorNum = table.getn(manager.editors) + 1

	-- Create window.
	self.uiFrame = ui:CreateWindowFrame(
		self.nameAndNumber,
		nil,
		manager.editorDimensions.width,
		manager.editorDimensions.height,
		manager.objectType .. " Editor " .. editorNum -- Title will be replaced automatically by SetTitle(), but we need a value here to trigger title bar creation
	)
	local uiFrame = self.uiFrame

	-- Clear search box focus appropriately.
	uiFrame:SetScript("OnMouseUp", function()
		self:CloseMenusAndClearFocuses(true, true, false)
	end)

	-- Provide easy access to title property for SetTitle().
	self.title = self.uiFrame.bagshuiData.title

	-- Wipe object info on close.
	uiFrame:SetScript("OnHide", function()
		self.objectId = nil
		self.originalObject = nil
		BsUtil.TableClear(self.updatedObject)
	end)


	--- Callback wrapper to prompt for save on dirty close.
	local function dirtyFunc()
		self:PromptForSave()
	end

	-- Function for Bagshui:CloseAllWindows hook callback.
	uiFrame.bagshuiData.onDirty = dirtyFunc

	-- Block close button if dirty.
	local oldCloseButtonOnClose = self.uiFrame.bagshuiData.closeButton:GetScript("OnClick")
	self.uiFrame.bagshuiData.closeButton:SetScript("OnClick", function()
		if uiFrame.bagshuiData.dirty then
			dirtyFunc()
		else
			oldCloseButtonOnClose()
		end
	end)

	-- Add toolbar icons.
	self.buttons.save = ui:CreateIconButton({
		name = self.nameAndNumber .. "SaveObject",
		texture = "Save",
		tooltipTitle = L.Save,
		parentFrame = self.uiFrame.bagshuiData.header,
		anchorPoint = "RIGHT",
		anchorToFrame = self.uiFrame.bagshuiData.closeButton,
		anchorToPoint = "LEFT",
		width = 16,
		height = 16,
		xOffset = -BsSkin.toolbarCloseButtonOffset,
		onClick = function()
			-- This should never be reached, but just to be extra sure...
			if self.originalObject and self.originalObject.readOnly then
				Bs:PrintError("Object is read-only; saving is not allowed.")
				return
			end
			if self:Save() then
				-- Call onFirstSave function if present.
				if type(self.onFirstSave) == "function" then
					self.onFirstSave(self.objectId)
				end
				-- Only fire once. It needs to be set again to repeat.
				self.onFirstSave = nil
			end
		end,
	})

	-- Re-anchor title to leftmost toolbar button so it doesn't run underneath.
	self.uiFrame.bagshuiData.title:SetPoint("RIGHT", self.buttons.save, "LEFT", -BsSkin.toolbarCloseButtonOffset, 0)

	-- Create frame to hold widgets.
	self.content = _G.CreateFrame("Frame", nil, uiFrame)
	self.content:SetPoint("TOPLEFT", self.uiFrame.bagshuiData.header, "BOTTOMLEFT", 0, -BsSkin.windowPadding)
	self.content:SetPoint("BOTTOMRIGHT", uiFrame, "BOTTOMRIGHT",  -BsSkin.windowPadding,  BsSkin.windowPadding)
	self.content:SetWidth(uiFrame:GetWidth() - (BsSkin.windowPadding * 2))

	-- Add widgets.
	local nextAnchor = self.content
	local nextAnchorToPoint = "TOPLEFT"

	local labelWidth = manager.editorDimensions.labelWidth
	local defaultWidgetWidth = manager.editorDimensions.widgetWidth
	local defaultWidgetHeight = manager.editorDimensions.widgetHeight

	if labelWidth + defaultWidgetWidth + 30 > manager.editorDimensions.width then
		defaultWidgetWidth = manager.editorDimensions.width - labelWidth - 50
	end

	for fieldIndex, fieldName in ipairs(self.editorFields) do

		local fieldProps = self.manager.editorFieldProperties[fieldName]

		if fieldProps and not fieldProps.hidden then
			assert(self.objectTemplate[fieldName], "objectTemplate property for " .. self.name .. " is missing " .. fieldName)

			local fieldType = (fieldProps and fieldProps.widgetType) or "EditBox"

			local widget
			local localizedFieldName = self:LocalizeField(fieldName)
			local fieldLabel = string.format(L.Symbol_Colon, localizedFieldName)
			local widgetNamePrefix = self.nameAndNumber .. fieldName
			local widgetWidth = (fieldProps and fieldProps.widgetWidth) or defaultWidgetWidth
			local widgetHeight = (fieldProps and fieldProps.widgetHeight) or defaultWidgetHeight

			-- Store an upvalue for widget functions since the loop variable fieldName will be lost once the loop is done.
			local upvalueFieldName = fieldName

			if fieldType == "EditBox" then
				-- Event handlers and other common properties will be added below.
				self.editBoxes[fieldName] = ui:CreateEditBox(widgetNamePrefix, self.content)
				widget = self.editBoxes[fieldName]
				-- WoW can lock fields into numeric-only.
				widget:SetNumeric(type(self.objectTemplate[fieldName]) == "number")


			elseif fieldType == "ScrollableEditBox" then
				-- Event handlers and other common properties will be added below.
				self.scrollFrames[fieldName], self.editBoxes[fieldName] = ui:CreateScrollableEditBox(
					widgetNamePrefix,
					self.content,
					nil,  -- borderStyle
					nil,  -- editBoxInherits
					(fieldProps and fieldProps.monospace and "BagshuiMono") or nil  -- fontObject
				)
				widget = self.scrollFrames[fieldName]


			elseif fieldType == "ScrollableList" or fieldType == "ItemList" then
				-- Default to text list unless it's an ItemList or a specific type has been provided.
				local scrollableListType =
					fieldProps.scrollableListType
					or fieldType == "ItemList" and BS_UI_SCROLLABLE_LIST_TYPE.ITEM
					or BS_UI_SCROLLABLE_LIST_TYPE.TEXT

				-- Defaults for the ScrollableList.
				local createScrollableListParams = {
					listType = scrollableListType,
					namePrefix = widgetNamePrefix,
					parent = self.content,
					width = widgetWidth,
					rowHeight = 20,
					font = "GameFontHighlightSmall",
					selectable = true,
					multiSelect = fieldProps.multiSelect,

					-- Default buttons (custom ones added below).
					buttons = {
						-- Add
						{
							scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.ADD,
							scrollableList_AnchorToSearchBox = (fieldProps.noSearchBox and false or true),
							scrollableList_DisableIfReadOnly = true,
							anchorPoint = "TOPLEFT",
							anchorToPoint = "BOTTOMLEFT",
							xOffset = 0,
							yOffset = -BsSkin.toolbarSpacing,
							tooltipTitle = string.format(L.Prefix_Add, L.Item),
							onClick = fieldProps.addButtonOnClick,
						},
						-- Remove
						{
							scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.REMOVE,
							scrollableList_DisableIfReadOnly = true,
							scrollableList_AutomaticAnchor = true,
							anchorPoint = "TOPLEFT",
							anchorToPoint = "BOTTOMLEFT",
							xOffset = 0,
							yOffset = -BsSkin.toolbarSpacing,
						},
					},

					-- OnChange callback -- Copy list values to updated object and refresh UI state.
					onChangeFunc = function(itemList, listFrame)
						local fieldStorage = self:GetFieldStorageTable(upvalueFieldName)
						-- Ensure a table is available for storage since lists are always stored in a table.
						if not fieldStorage[upvalueFieldName] then
							fieldStorage[upvalueFieldName] = {}
						end
						-- Copy value to self.updatedObject.
						BsUtil.TableCopy(itemList, fieldStorage[upvalueFieldName])

						self:UpdateState()
					end,

					-- Custom list population function passthrough.
					entryFrameCreationFunc = fieldProps.entryFrameCreationFunc,
					entryDisplayProperty = fieldProps.entryDisplayProperty,
					entryInfoFunc = fieldProps.entryInfoFunc,
					entryFramePopulateFunc = fieldProps.entryFramePopulateFunc,
					-- Pass this ObjectEditor instance as the final parameter of the entryFrame callbacks.
					-- See the SortOrders UI for an example of this in action.
					entryFrameCallbacksExtraParam = self,
				}

				-- Append buttons.

				-- Copy button for item list.
				if fieldType == "ItemList" then
					table.insert(
						createScrollableListParams.buttons,
						{
							scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.SHARE,
							scrollableList_AutomaticAnchor = true,
							anchorPoint = "TOPLEFT",
							anchorToPoint = "BOTTOMLEFT",
							xOffset = 0,
							yOffset = -BsSkin.toolbarGroupSpacing,
						}
					)
				end

				if fieldProps.extraButtons then
					for _, button in pairs(fieldProps.extraButtons) do
						table.insert(createScrollableListParams.buttons, button)
					end
				end

				-- Allow dragging items into the editor.
				if scrollableListType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
					createScrollableListParams.itemDragTarget = uiFrame
				end

				-- Create the widget.
				self.scrollFrames[fieldName],
					self.scrollChildren[fieldName],
					self.lists[fieldName] = ui:CreateScrollableList(createScrollableListParams)
				widget = self.scrollFrames[fieldName]

				-- Position the scrollable list toolbar.
				local firstToolbarItem = self.lists[fieldName].bagshuiData.searchBox
				if fieldProps.noSearchBox then
					firstToolbarItem = self.lists[fieldName].bagshuiData.buttons.add
				end
				firstToolbarItem:SetPoint(
					"TOPLEFT",
					self.scrollFrames[fieldName].bagshuiData.background,
					"TOPRIGHT",
					BsSkin.toolbarSpacing,
					0
				)

			end

			-- Unknown widget types won't get created.
			assert(widget, "ObjectEditor .. " .. self.name .. " failed to create widget for field " .. fieldName)

			-- Add handlers and icons to EditBoxes.
			if self.editBoxes[fieldName] then

				local editBox = self.editBoxes[fieldName]

				-- Data for callbacks.
				editBox.bagshuiData.fieldName = fieldName
				editBox.bagshuiData.fieldIndex = fieldIndex

				-- Add field state icon.
				local icon = ui:CreateIconButton({
					name = self.nameAndNumber .. fieldName .. "Icon",
					parentFrame = editBox,
					texture = "Asterisk",
					anchorPoint = "TOPRIGHT",
					anchorToFrame = editBox,
					anchorToPoint = "TOPRIGHT",
					xOffset = -3,
					yOffset = -3,
					width = manager.editorDimensions.widgetHeight - 6,
					height = manager.editorDimensions.widgetHeight - 6,
					tooltipDelay = 0,
					tooltipTitle = fieldName,
				})
				ui:SetIconButtonTexture(icon, "Icons\\Asterisk", BS_COLOR.UI_ORANGE)
				editBox.bagshuiData.icon = icon

				-- OnTabPressed callback -- move focus to the next EditBox.
				editBox:SetScript("OnTabPressed", function()
					_G.this:ClearFocus()

					-- First time tab is pressed, find the next EditBox.
					if not _G.this.bagshuiData.nextField then
						for i = _G.this.bagshuiData.fieldIndex + 1, table.getn(self.editorFields) do
							if self.editBoxes[self.editorFields[i]] then
								_G.this.bagshuiData.nextField = self.editBoxes[self.editorFields[i]]
								break
							end
						end

						-- Wrap around to the first EditBox if we reach the end.
						if not _G.this.bagshuiData.nextField and self.editBoxes[self.editorFields[1]] then
							_G.this.bagshuiData.nextField = self.editBoxes[self.editorFields[1]]
						end
					end

					-- Move to the next EditBox.
					if _G.this.bagshuiData.nextField then
						_G.this.bagshuiData.nextField:SetFocus()
					end

				end)

				-- OnTextChanged callback -- Copy value to updated object and refresh UI state.
				local oldOnChanged = editBox:GetScript("OnTextChanged")
				editBox:SetScript("OnTextChanged", function()
					-- Call original OnTextChanged and stop if it returns false.
					-- This is for faking read-only EditBoxes.
					if oldOnChanged and oldOnChanged() == false then
						return
					end

					-- Copy value to self.updatedObject.
					local value = _G.this:GetText()
					if string.len(value) > 0 then
						if type(self.objectTemplate[_G.this.bagshuiData.fieldName]) == "number" then
							value = tonumber(value)
						end
					else
						value = nil
					end
					self:GetFieldStorageTable(_G.this.bagshuiData.fieldName)[_G.this.bagshuiData.fieldName] = value

					self:UpdateState()
				end)
			end

			-- Add to UI.
			self.labelWidgetPairs[fieldName] = ui:CreateLabeledWidget(
				self.content,       -- Parent
				fieldLabel,         -- Label text
				labelWidth,         -- Label width
				widget,             -- Widget
				widgetWidth,        -- Widget width
				widgetHeight,       -- Widget height
				nextAnchor,         -- Anchor to frame
				nextAnchorToPoint   -- Anchor to point
			)

			-- Widget tooltips.
			local tooltipText = L_nil[self.objectType .. "Editor_Field_" .. fieldName .. "_TooltipText"]
			if tooltipText then
				local widgetHoldingFrame = self.labelWidgetPairs[fieldName]

				widget:SetScript("OnEnter", function()
					_G.GameTooltip:ClearLines()
					_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.this)
					_G.GameTooltip:AddLine(localizedFieldName, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, true)
					_G.GameTooltip:AddLine(tooltipText, nil, nil, nil, true)
					_G.GameTooltip:SetWidth(10)
					Bagshui:ShowTooltipAfterDelay(_G.GameTooltip, _G.this, widgetHoldingFrame)
				end)

				widget:SetScript("OnLeave", function()
					if _G.GameTooltip:IsOwned(_G.this) then
						Bagshui:ShortenTooltipDelay(_G.this, true)
						_G.GameTooltip:Hide()
					end
				end)
			end

			nextAnchor = self.labelWidgetPairs[fieldName]
			nextAnchorToPoint = "BOTTOMLEFT"
		end
	end


	-- Resize labels based on text width.
	local longestLabel = 0
	for _, labelWidgetPair in pairs(self.labelWidgetPairs) do
		local labelStringWidth = labelWidgetPair.bagshuiData.label:GetStringWidth()
		if labelStringWidth > longestLabel then
			longestLabel = labelStringWidth
		end
	end
	if longestLabel < labelWidth then
		local newLabelWidth = longestLabel + 30
		local labelDifference = labelWidth - newLabelWidth
		for _, labelWidgetPair in pairs(self.labelWidgetPairs) do
			labelWidgetPair.bagshuiData.labelFrame:SetWidth(newLabelWidth)
			ui:SetWidth(labelWidgetPair.bagshuiData.widget, labelWidgetPair.bagshuiData.initialWidgetWidth + labelDifference)
		end
		-- Update labelWidth so it can be captured into self.labelWidth below.
		labelWidth = newLabelWidth
	end

	-- This is saved for use by custom UI modifications (see Categories UI for an example).
	self.labelWidth = labelWidth
end



--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function ObjectEditor:OnEvent(event, arg1)
	if event == self.manager.updateEvent and self.uiFrame and self.uiFrame:IsVisible() and arg1 == self.objectId then
		if not self.manager:GetObjectInfo(arg1) then
			-- Object has been deleted.
			self.uiFrame:Hide()
		else
			-- There was a change to the object, so refresh it.
			self:Load(arg1, nil, nil, true)
		end
	end
end



--- Load an object into the editor, creating a new object as needed.
---@param objectId string|number? ID of the object from the associated object list.
---@param duplicate boolean? When true, create a new object based on objectId instead of editing that one.
---@param template table? Use this instead of self.objectTemplate when creating a new object.
---@param refresh boolean? Object has already been loaded into the editor but fields need to be refreshed due to a change (usually saving).
---@param onFirstSave function? Callback that will be triggered when the Save button is clicked for the first time.
---@return string|number # ID of the object being edited.
function ObjectEditor:Load(objectId, duplicate, template, refresh, onFirstSave)

	-- Newly created objects will need to have self.originalObject set to an empty table.
	local isNew = false

	-- Store information for future use.
	self.objectId = objectId  -- Needed when checking for editor reuse.
	-- Don't clear an existing `onFirstSave` -- that will be done in the Save toolbar button OnClick.
	if onFirstSave then
		self.onFirstSave = onFirstSave  -- Consumed by the OnClick for the Save toolbar button.
	end

	-- Grab existing object info.
	local objectInfo = self.manager:GetObjectInfo(objectId)
	self.referenceObject = objectInfo

	-- This is a new object, so generate an ID.
	if not objectInfo or duplicate then
		self.objectId = self:GetNewObjectId()
		isNew = true
	end

	-- This is a new object that isn't being cloned from an existing one, so copy from template.
	if not objectInfo then
		objectInfo = BsUtil.TableCopy(template or self.objectTemplate)
		self.referenceObject = template or self.objectTemplate
	end

	-- Reset field proxy table unless it's a refresh.
	-- Clearing this on a refresh breaks the UI state.
	if not refresh then
		BsUtil.TableClear(self.fieldStorageRedirect)
	end

	-- Make a copy and update properties for duplicates.
	if duplicate then
		objectInfo = BsUtil.TableCopy(objectInfo)
		objectInfo.readOnly = nil
		objectInfo.builtin = nil
		-- Enable this and restore `["Suffix_Copy"] = "%s (Copy)",` in localization
		-- to add text to the end of a duplicated object's name. This was disabled
		-- because it seems unnecessary, as the editor UI will prevent it from
		-- being saved until it is changed. (And in the case of duplicating a builtin,
		-- the name will only need to be changed if an existing custom object has
		-- the same name, which is the desired behavior.)
		-- objectInfo.name = string.len(objectInfo.name or "") > 0 and string.format(L.Suffix_Copy, objectInfo.name) or ""
	end

	-- Store original object for reference by dirty check.
	if isNew then
		self.originalObject = {}
	else
		self.originalObject = objectInfo
	end

	-- Copy over to updatedObject so it's ready to track changes.
	-- We can't just use objectInfo because it's the actual object and we don't want to change it live.
	BsUtil.TableCopy(objectInfo, self.updatedObject)

	-- Load whatever we can based on property and UI object names.
	for _, fieldName in ipairs(self.editorFields) do
		self:PopulateField(fieldName, objectInfo)
	end

	-- Remove focus from all edit boxes.
	for _, editBox in pairs(self.editBoxes) do
		editBox:ClearFocus()
	end

	-- Re-focus the Name field if it's a new object.
	if isNew then
		Bagshui:QueueEvent(function()
			self.editBoxes.name:SetFocus()
		end)
	end

	-- Prep the UI.
	self:UpdateState()

	return self.objectId
end



--- Set the contents of a field from the appropriate object storage table.
---@param fieldName string
---@param fallbackStorageTable table? Parameter for self:GetFieldStorageTable().
function ObjectEditor:PopulateField(fieldName, fallbackStorageTable)
	local fieldProps = self.manager.editorFieldProperties[fieldName]
	if fieldProps.hidden then
		return
	end

	-- Get the current value.
	local value = self:GetFieldStorageTable(fieldName, fallbackStorageTable)[fieldName]

	local readOnly = (
		self.originalObject.readOnly == true
		or self.manager.editorFieldProperties[fieldName].readOnly == true
	)

	-- Edit boxes and scrollable lists are different.
	if self.editBoxes[fieldName] then
		-- Set readOnlyText property for fake read-only-ness.
		self.editBoxes[fieldName].bagshuiData.readOnlyText = readOnly and value or nil

		-- Populate the EditBox.
		self.editBoxes[fieldName]:SetText(value or "")


	elseif self.lists[fieldName] then

		-- Keep list buttons disabled for read-only objects.
		-- Need to use `scrollableList_Disable` here instead of `scrollableList_DisableIfReadOnly`
		-- because the list entries themselves won't have a readOnly property; only the
		-- object being edited does. We still rely on the `scrollableList_DisableIfReadOnly` property
		-- to trigger the disable so that some buttons can be kept enabled if needed.
		for _, button in pairs(self.lists[fieldName].bagshuiData.buttons) do
			button.bagshuiData.scrollableList_Disable = button.bagshuiData.scrollableList_DisableIfReadOnly and readOnly or false
		end
		-- Also set the list to read-only. (This was added later so I'm not messing with the original code.)
		self.lists[fieldName].bagshuiData.readOnly = readOnly

		-- Fill the list and scroll it to the top.
		self.lists[fieldName].bagshuiData.scrollFrame:SetVerticalScroll(0)
		self.ui:PopulateScrollableList(self.lists[fieldName], value or {})

	end
end



--- Prompt before closing the window when the object has been edited.
function ObjectEditor:PromptForSave()
	local dialogName = "BAGSHUI_UNSAVED_OBJECT"

	if not _G.StaticPopupDialogs[dialogName] then
		_G.StaticPopupDialogs[dialogName] = {
			text = L.ObjectEditor_UnsavedPrompt,
			button1 = L.AbandonChanges,
			button2 = L.KeepEditing,
			showAlert = 1,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 0,
			notClosableByLogout = 1,
			-- Abandon changes to the object (no need for OnCancel as that simply needs to do nothing).
			-- The editor parameter comes from the dialog's data property which is set below.
			OnAccept = function(editor)
				editor.uiFrame.bagshuiData.dirty = false
				editor.uiFrame:Hide()
			end,
		}
	end

	-- Don't preempt any other save prompt dialogs or they'll end up calling OnCancel.
	if _G.StaticPopup_Visible(dialogName) then
		return
	end

	-- Bring the editor to the front before prompting.
	self:BringToFront()

	-- Display the dialog and provide the object type and object name to the prompt text.
	local dialog = _G.StaticPopup_Show(dialogName, string.lower(self.objectType), self:GetObjectNameForPrompt())

	-- Pass editor through to StaticPopupDialog via the magical data property.
	if dialog then
		dialog.data = self
	end
end



--- Keep the editor state current.
function ObjectEditor:UpdateState()

	-- This needs to be stored on uiFrame so that the Bagshui:CloseAllWindows
	-- hook can see that the window shouldn't be closed.
	self.uiFrame.bagshuiData.dirty = self:IsDirty()

	-- Clear errors since we're about to re-validate everything.
	for _, fieldName in pairs(self.editorFields) do
		if not self.fieldErrors[fieldName] then
			self.fieldErrors[fieldName] = {}
		end
		self.fieldErrors[fieldName].message = nil
	end

	-- Save button should be disabled if:
	-- - No changes have been made
	-- - A required field is missing
	-- - Name matches an existing object
	local enableDisableFunction = self.uiFrame.bagshuiData.dirty and "Enable" or "Disable"

	-- Require fields.
	for _, property in ipairs(self.manager.requiredFields) do
		if string.len(tostring(self.updatedObject[property] or "")) == 0 then
			self.fieldErrors[property].message = string.format(L.ObjectEditor_RequiredField, self:LocalizeField(property))
			self.fieldErrors[property].color = BS_COLOR.YELLOW
			self.fieldErrors[property].icon = "Icons\\Asterisk"
			enableDisableFunction = "Disable"
		end
	end

	-- Invalid input.
	for _, property in ipairs(self.editorFields) do
		local valid, message = self.manager:IsObjectPropertyValid(self.objectId, property, self.updatedObject)
		if not valid then
			self.fieldErrors[property].message = message
			self.fieldErrors[property].color = BS_COLOR.UI_ORANGE
			self.fieldErrors[property].icon = "Icons\\Exclamation"
			enableDisableFunction = "Disable"
		end
	end

	-- Read-only -- never allow saving.
	if self.originalObject.readOnly then
		enableDisableFunction = "Disable"
	end

	-- Update Save buttons state and show any errors.
	self.buttons.save[enableDisableFunction](self.buttons.save)
	self:UpdateErrorIndicators()

	-- Keep the title current.
	self:SetTitle()
end



--- For any fields in an error state, display the error indicator icon, set the
--- icon's tooltip, and (for non-EditBoxes), print the error message as a warning.
function ObjectEditor:UpdateErrorIndicators()
	for fieldName, editBox in pairs(self.editBoxes) do
		local icon = editBox.bagshuiData.icon
		if self.fieldErrors[fieldName].message then
			icon.bagshuiData.tooltipTitle = self.fieldErrors[fieldName].message
			self.ui:SetIconButtonTexture(icon, self.fieldErrors[fieldName].icon, self.fieldErrors[fieldName].color)
			icon:Show()
		else
			icon:Hide()
		end
	end
	for fieldName, errorInfo in pairs(self.fieldErrors) do
		if errorInfo.message and not self.editBoxes[fieldName] then
			Bs:PrintWarning(fieldName .. " - " .. errorInfo.message)
		end
	end
end



--- Determine whether changes have been made.
---@return boolean
function ObjectEditor:IsDirty()
	-- Never allow the Save button to enable for read-only objects
	if self.originalObject.readOnly then
		return false
	end

	local dirty = false
	--local comparisonObject = self.originalObject ~= nil and self.originalObject or self.objectTemplate
	--local debugDirtyType = (comparisonObject == self.objectTemplate) and "New" or "Existing"

	-- Check each field.
	for _, fieldName in ipairs(self.editorFields) do
		local original = self.originalObject[fieldName]
		local updated = self.updatedObject[fieldName]

		-- Bagshui:PrintDebug("checking " .. fieldName .. " " .. tostring(original) .. " ~= " .. tostring(updated))
		if self:IsObjectDirty(original, updated) then
			-- Not breaking on dirty so all fields can be marked dirty.
			dirty = true
			self.dirtyFields[fieldName] = _G.GetTime()
		else
			self.dirtyFields[fieldName] = nil
		end
	end

	return dirty
end



--- Inspect two objects to see if the updated object is different from the original.
---@param original any
---@param updated any
---@return boolean
function ObjectEditor:IsObjectDirty(original, updated)

	-- Allow empty tables to be considered equal to nil.
	if
		(type(original) == "table" and type(updated) == "nil" and BsUtil.TrueTableSize(original) == 0)
		or
		(type(original) == "nil" and type(updated) == "table" and BsUtil.TrueTableSize(updated) == 0)
	then
		-- Bagshui:PrintDebug("empty table/nil")
		return false
	end

	-- Allow empty strings to be considered equal to nil.
	if
		(type(original) == "string" and type(updated) == "nil" and string.len(original) == 0)
		or
		(type(original) == "nil" and type(updated) == "string" and string.len(updated) == 0)
	then
		-- Bagshui:PrintDebug("empty string/nil")
		return false
	end

	--- Do a deep object inspection to identify differences.
	if not BsUtil.ObjectsEqual(original, updated) then
		-- Bagshui:PrintDebug(" not equal: " .. tostring(original) .. " ~= " .. tostring(updated))
		return true
	end

	return false

end



--- Set the window title to `<objectType> Editor[: <objectName>]` and append a read-only indicator as appropriate.
function ObjectEditor:SetTitle()
	local objectName = self:GetObjectName()
	if self.originalObject.readOnly then
		objectName = string.format(L.Suffix_ReadOnly, objectName)
	end
	local title = L[self.objectType .. "Editor"]
	if string.len(objectName) > 0 then
		title = string.format(L.Symbol_Colon, title) .. " " .. HIGHLIGHT_FONT_COLOR_CODE .. objectName .. FONT_COLOR_CODE_CLOSE
	end
	self.title:SetText(title)
end



--- Return the name of the object being edited.
---@return string
function ObjectEditor:GetObjectName()
	return self.editBoxes.name:GetText()
end



--- Return either the name of the object being edited or `(Unnamed <objectType>)` if name is empty.
---@return string
function ObjectEditor:GetObjectNameForPrompt()
	local objectName = self:GetObjectName()
	if not objectName or string.len(tostring(objectName)) == 0 then
		objectName = string.format(L.Prefix_Unnamed, L[self.objectType])
	end
	return objectName
end



--- Return the table that should be used to store a field.
---@param fieldName string
---@param defaultTable table? Table to return instead of `self.updatedObject` if the field isn't being redirected.
---@return table
function ObjectEditor:GetFieldStorageTable(fieldName, defaultTable)
	return self.fieldStorageRedirect[fieldName] or defaultTable or self.updatedObject
end



--- Move the UI frame in front of any others.
--- Will also set the position if the frame wasn't visible.
function ObjectEditor:BringToFront()
	if not self.uiFrame:IsVisible() then
		-- Anchor the editor to either the Manager or the currently open editor that
		-- is furthest toward the bottom right.
		-- This *could* be improved to loop around and start positioning from the top
		-- left of the screen if the bottom right of the screen is reached, but the
		-- current approach  feels good enough for the number of editors that will
		-- probably usually be opened at once.
		local anchorToFrame = self.manager.uiFrame
		for _, existingEditor in ipairs(self.manager.editors) do
			if
				existingEditor ~= self
				and existingEditor.uiFrame
				and existingEditor.uiFrame:IsVisible()
				and (
					existingEditor.uiFrame:GetLeft() > anchorToFrame:GetLeft()
					and existingEditor.uiFrame:GetTop() < anchorToFrame:GetTop()
				)
			then
				anchorToFrame = existingEditor.uiFrame
			end
		end
		-- When the editor is narrower than the anchor frame, position it to the right
		-- so it will remain visible if the anchor frame is brought to the top.
		local point = (self.uiFrame:GetWidth() < anchorToFrame:GetWidth()) and "TOPRIGHT" or "TOPLEFT"
		self.uiFrame:ClearAllPoints()
		self.uiFrame:SetPoint(point, anchorToFrame, point, 20, -20)
		self.uiFrame:Show()
		self.uiFrame:ClearAllPoints()
	else
		self.uiFrame:Raise()
	end
end



--- Multipurpose function that handles closing menus and de-focusing widgets.
--- **DO NOT RENAME** without updating `Ui:CloseMenusAndClearFocuses()`.
---@param menus boolean? Pass `false` to keep menus open.
---@param editBoxes boolean? Pass `false` to preserve text box focus.
---@param listSelections boolean? Pass `false` to keep list selections.
function ObjectEditor:CloseMenusAndClearFocuses(menus, editBoxes, listSelections)
	if menus ~= false then
		Bagshui:CloseMenus()
	end

	if editBoxes ~= false then
		for _, editBox in pairs(self.editBoxes) do
			editBox:ClearFocus()
		end
	end

	if listSelections ~= false then
		for _, list in pairs(self.lists) do
			if list.bagshuiData.searchBox then
				list.bagshuiData.searchBox:ClearFocus()
			end
			self.ui:SetScrollableListSelection(list)
		end
	end
end


--#endregion ObjectEditor


end)