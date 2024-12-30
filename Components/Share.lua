-- Bagshui Share (Import/Export)
-- Exposes: BsShare (and Bagshui.components.Share)

Bagshui:AddComponent(function()


-- Define the order objects will appear in the UI.
local OBJECT_LISTS = {
	BsProfiles,
	BsCategories,
	BsSortOrders,
}

-- Object IDs within `Share.list` are built as `<objectType><OBJECT_ID_SEPARATOR><id>`.
-- These are then linked back to the original class by splitting on the separator.
local OBJECT_ID_SEPARATOR = "::"

-- Headers in `Share.list` have an ID of `<OBJECT_HEADER_PREFIX><OBJECT_ID_SEPARATOR><objectType>`
-- that can then the related to an entry in `Share.objectHeaders`.
local OBJECT_HEADER_PREFIX = "HEADER"



local Share = {
	-- Map of objectType to the corresponding ObjectList class instance.
	objectLists = {},

	-- Event to class instance mapping.
	objectChangeEvents = {},

	-- Header entries for the UI.
	objectHeaders = {},

	-- Unique IDs for all exportable items.
	list = {},

	---@type table<string, string[]>
	-- Dependency tracking for list selection management (keep Categories/Sort Orders
	-- selected when a profile that references them is selected).
	-- This is a key-value table where keys are IDs from self.list and values
	-- are tables of the dependent object IDs, also from self.list.
	listDependencies = {},

	-- Reusable tables for import/export processes.
	temp = {
		export = {},
		dependencyMap = {},  -- See `ObjectList:Export()` for format.
	},

	-- Order in which objects will be processed for import so dependency mapping can be done.
	-- Export order doesn't really matter.
	importOrder = {},

	-- Has `Init()` finished?
	initialized = false,

}
Bagshui.environment.BsShare = Share
Bagshui.components.Share = Share



--- Event processing.
---@param event string WoW API event
---@param arg1 any First event argument.
function Share:OnEvent(event, arg1)
	-- Bagshui:PrintDebug("Share event " .. event)

	-- Initial processing at startup. Delayed since it's not needed immediately.
	-- Other update events are allowed to delay initial processing even further.
	if event == "PLAYER_ENTERING_WORLD" or not self.initialized then
		if not self.initialized then
			Bagshui:QueueClassCallback(self, self.Init, 1)
		end
		return
	end

	-- Update objects for the list that raised the event.
	if self.objectChangeEvents[event] then
		self:Update(self.objectChangeEvents[event])
	end

end



--- Initialize the Share class.
--- Also calculates item totals for all characters other than the current one.
function Share:Init()
	-- Bagshui:PrintDebug("Share:Init()")

	-- Initialize storage tables and register for ObjectList events.
	for _, objectList in ipairs(OBJECT_LISTS) do
		self:Update(objectList)

		-- Build the import order.
		-- Get any dependencies and add them to the front.
		local importExportDependencies = objectList:GetImportExportDependencies()
		if importExportDependencies then
			for _, dependentObjectList in pairs(importExportDependencies) do
				local currentPosition = BsUtil.TableContainsValue(self.importOrder, dependentObjectList)
				if currentPosition then
					table.remove(self.importOrder, currentPosition)
				end
				table.insert(self.importOrder, 1, dependentObjectList)
			end
		end
		-- Add this ObjectList to the end of the import order.
		if not BsUtil.TableContainsValue(self.importOrder, objectList) then
			table.insert(self.importOrder, objectList)
		end
	end

	-- Register slash command.
	BsSlash:AddOpenCloseHandler("Share", self)

	-- Allow events to be processed normally.
	self.initialized = true
end



--- Set up tracking of an ObjectList class instance's contents.
---@param objectList table ObjectList instance.
function Share:AddTrackedClass(objectList)
	assert(type(objectList) == "table" and objectList._super == Bagshui.prototypes.ObjectList, "Share: the given objectList does not appear to be a Bagshui ObjectList instance.")
	if not self.objectLists[objectList.objectType] then
		self.objectLists[objectList.objectType] = objectList
		self.objectHeaders[self:MakeIdentifier(OBJECT_HEADER_PREFIX, objectList.objectType)] = {
			name = L[objectList.objectNamePlural],
			scrollableList_Header = true
		}
		self.objectChangeEvents[objectList.objectChangeEvent] = objectList
		self.temp.export[objectList.objectType] = {}
		Bagshui:RegisterEvent(objectList.objectChangeEvent, self)
	end
end




--- Refresh tracking of sharable objects from the given list.
---@param objectList table One of the classes from `OBJECT_LISTS`.
function Share:Update(objectList)
	-- Bagshui:PrintDebug("Share:Update() for " .. (objectList and tostring(objectList.objectType) or "unknown object list(!?)"))

	-- Ensure this ObjectList instance is valid and we're set up to track its contents.
	self:AddTrackedClass(objectList)

	-- Prep dependency list.
	if not self.listDependencies[objectList.objectType] then
		self.listDependencies[objectList.objectType] = {}
	end
	BsUtil.TableClear(self.listDependencies[objectList.objectType])

	local insertionPoint = table.getn(self.list) + 1

	-- Remove all existing IDs for this object list.
	for i = table.getn(self.list), 1, -1 do
		if
			string.find(self.list[i], self:MakeIdentifier("^" .. objectList.objectType))
			or self.list[i] == self:MakeIdentifier(OBJECT_HEADER_PREFIX, objectList.objectType)
		then
			table.remove(self.list, i)
			insertionPoint = i
		end
	end

	-- The header should be (re-)inserted at the very first spot.
	local headerPoint = insertionPoint

	-- Get all object IDs from the ObjectList, sorted by name, and add them to our tracking list.
	for _, id in ipairs(objectList.sortedIdListsForManager.name) do
		if not objectList.list[id].builtin then
			local shareObjectId = self:MakeIdentifier(objectList.objectType, tostring(id))
			table.insert(self.list, insertionPoint, shareObjectId)
			insertionPoint = insertionPoint + 1

			-- Store dependency lists for this item.
			-- Piggybacking on Export() for convenience.
			-- Obviously this could be done more cleanly with some refactoring.
			local export = objectList:Export(id)
			if export then
				self.listDependencies[shareObjectId] = export.dependencies
			end
		end
	end

	-- (Re-)insert the header.
	if insertionPoint > headerPoint then
		table.insert(self.list, headerPoint, self:MakeIdentifier(OBJECT_HEADER_PREFIX, objectList.objectType))
	end

	-- Refresh the list if it's visible.
	if self.objectManager and self.objectManager.uiFrame:IsVisible() then
		self.objectManager:UpdateList()
	end
end



--- Concatenate `prefix`, `OBJECT_ID_SEPARATOR`, and `suffix` to create a unique ID.
---@param prefix string
---@param suffix string|number?
---@return string
function Share:MakeIdentifier(prefix, suffix)
	return prefix .. OBJECT_ID_SEPARATOR .. (suffix or "")
end



--- Turn an entry from `Share.list` back into the original object.
---@param objectTypeAndId string `<prefix>:<id>` string generated by `Share:Update()`.
---@return table? object If found, will be the object corresponding to `<id>` or the objectType's header.
---@return (string|number)? objectId Only returned when `object` is NOT a header, this is unique ID of `object` within `objectList.list`.
---@return table? objectList Only returned when `object` is NOT a header, this is the ObjectList class instance that owns `object`.
function Share:GetObjectInfo(objectTypeAndId)
	if self.objectHeaders[objectTypeAndId] then
		return self.objectHeaders[objectTypeAndId]
	end
	-- 1 = objectType
	-- 2 = objectId
	local objectInfo = BsUtil.Split(objectTypeAndId, OBJECT_ID_SEPARATOR)
	if not self.objectLists[objectInfo[1]] then
		return
	end

	-- Everything comes as a string, but custom objects in ObjectList have numbers
	-- as their IDs, so we need to try to convert or the object won't be found.
	objectInfo[2] = tonumber(objectInfo[2]) or objectInfo[2]

	-- It would be nice to use the ObjectList instance's GetObjectInfo() here
	-- but that doesn't get set up until InitUi() is called, and I don't feel
	-- like refactoring.
	return
		self.objectLists[objectInfo[1]].list[objectInfo[2]],
		objectInfo[2],
		self.objectLists[objectInfo[1]]
end



--- Perform an export.
---@param selectedEntries table List of items to export from `self.list`.
function Share:Export(selectedEntries)
	local dialogName = "shareExport"

	self:InitUi()

	local ui = self.objectManager.ui

	if not ui.dialogProperties[dialogName] then
		ui:AddMultilineDialog(
			dialogName,
			{
				prompt = L.ShareManager_ExportPrompt,
				button1 = L.Close,
				button2 = "",
				readOnly = true,

				dialogCustomizationFunc = function(dialog)


					dialog.uiFrame.bagshuiData.encodeCheckbox = ui:CreateCheckbox(
						"Encode",
						dialog.uiFrame,
						"UIOptionsCheckButtonTemplate",
						L.ShareManager_ExportEncodeCheckbox,
						function(this)
							this = this or _G.this
							self:ImportExportAction(dialog.uiFrame, function()
								dialog:SetText(BsUtil.Export(dialog.data.toExport, (not this:GetChecked())))
							end)
						end
					)

					local checkboxWidth = dialog.uiFrame.bagshuiData.encodeCheckbox:GetWidth()

					dialog.uiFrame.bagshuiData.encodeExplanation = dialog.uiFrame:CreateFontString(nil, nil, "GameFontNormalSmall")
					dialog.uiFrame.bagshuiData.encodeExplanation:SetTextColor(0.5, 0.5, 0.5)
					dialog.uiFrame.bagshuiData.encodeExplanation:SetJustifyH("LEFT")
					dialog.uiFrame.bagshuiData.encodeExplanation:SetText(L.ShareManager_ExportEncodeExplanation)
					dialog.uiFrame.bagshuiData.encodeExplanation:SetPoint(
						"BOTTOMLEFT",
						dialog.uiFrame.bagshuiData.button1,
						"TOPLEFT",
						checkboxWidth,
						6
					)
					dialog.uiFrame.bagshuiData.encodeExplanation:SetPoint(
						"BOTTOMRIGHT",
						dialog.uiFrame.bagshuiData.button2,
						"TOPRIGHT",
						0,
						6
					)
					dialog.uiFrame.bagshuiData.encodeExplanation:SetWidth(dialog.uiFrame:GetWidth() - BsSkin.windowPadding * 2 - checkboxWidth)

					dialog.uiFrame.bagshuiData.encodeCheckbox = ui:CreateCheckbox(
						"Encode",
						dialog.uiFrame,
						"UIOptionsCheckButtonTemplate",
						L.ShareManager_ExportEncodeCheckbox,
						function(this)
							this = this or _G.this
							self:ImportExportAction(dialog.uiFrame, function()
								dialog:SetText(BsUtil.Export(dialog.data.toExport, (not this:GetChecked())))
							end)
						end
					)
					-- Insert checkbox above buttons.
					dialog.uiFrame.bagshuiData.encodeCheckbox:SetPoint("BOTTOMLEFT", dialog.uiFrame.bagshuiData.encodeExplanation, "TOPLEFT", -dialog.uiFrame.bagshuiData.encodeCheckbox:GetWidth(), -2)

					-- Re-anchor bottom of ScrollFrame to encode checkbox.
					ui:SetPoint(dialog.uiFrame.bagshuiData.scrollFrame, "BOTTOM", dialog.uiFrame.bagshuiData.encodeCheckbox, "TOP", 0, 4)


					dialog.dialogProperties.height = dialog.dialogProperties.height + dialog.uiFrame.bagshuiData.encodeExplanation:GetHeight() + dialog.uiFrame.bagshuiData.encodeCheckbox:GetHeight()

				end,
			}
		)
	end

	-- Populate self.temp.export.
	self:BuildExportObject(selectedEntries)

	-- Don't need to pass text to ShowDialog() because encodeCheckbox's OnClick
	-- is going to be called just after and will take care of it.
	local dialog = ui:ShowDialog(
		dialogName, nil, nil, nil, nil, self.objectManager.uiFrame
	)

	dialog.data.toExport = self.temp.export

	dialog.uiFrame.bagshuiData.encodeCheckbox:SetChecked(true)
	-- SetChecked doesn't call OnClick; we need to do it in order to fill the text.
	dialog.uiFrame.bagshuiData.encodeCheckbox:GetScript("OnClick")(dialog.uiFrame.bagshuiData.encodeCheckbox)
end



--- Populate `self.temp.export` in preparation for serializing and encoding.
---@param selectedEntries table List of items to export from `self.list`.
function Share:BuildExportObject(selectedEntries)
	BsUtil.TableClear(self.temp.export)
	self.temp.export.bagshuiExportFormat = BS_EXPORT_VERSION

	-- Build up the export table. ObjectList dependency mapping isn't needed for
	-- export, so we don't need to pay attention to self.importOrder.
	for shareObjectId, _ in pairs(selectedEntries) do
		local _, objectId, objectList = self:GetObjectInfo(shareObjectId)
		self:AddToExport(objectList, objectId)
	end
end



--- Add the given object and its dependencies to `self.temp.export`.
---@param objectList table Bagashui ObjectList class of the `objectId`.
---@param objectId string|number ID of object being exported.
function Share:AddToExport(objectList, objectId)
	assert(type(objectList) == "table" and objectList.Export, "Share:AddToExport() -- objectList does not appear to be a Bagshui ObjectList instance.")

	-- Add key for this object class.
	if not self.temp.export[objectList.objectType] then
		self.temp.export[objectList.objectType] = {}
	end

	-- Retrieve the exported object.
	local export = objectList:Export(objectId)

	if export.object then
		self.temp.export[objectList.objectType][objectId] = export.object

		-- Recurse for dependencies.
		if type(export.dependencies) == "table" then
			for dependencyObjectList, dependencies in pairs(export.dependencies) do
				if type(dependencies) == "table" and table.getn(dependencies) > 0 then
					for _, dependencyObjectId in ipairs(dependencies) do
						self:AddToExport(dependencyObjectList, dependencyObjectId)
					end
				end
			end
		end
	end
end



--- Display the Import dialog and allow the user to initiate an import.
function Share:Import()
	local dialogName = "shareImport"

	self:InitUi()
	local ui = self.objectManager.ui

	if not ui.dialogProperties[dialogName] then
		ui:AddMultilineDialog(
			dialogName,
			{
				prompt = L.ShareManager_ImportPrompt,
				button1 = L.Import,
				button1DisableOnEmptyText = true,
				button2 = L.Cancel,

				OnAccept = function(dialog)
					local text = dialog:GetText()  -- Need an upvalue here so we get a value for the callback BEFORE the dialog is hidden.
					self:ImportExportAction(dialog.uiFrame, function()
						self:ProcessImport(text)
					end)
				end,
			}
		)
	end

	local dialog = ui:ShowDialog(
		dialogName, nil, nil, nil, nil, self.objectManager.uiFrame
	)

end



--- Import data provided by the user.
---@param text string Serialized and probably compressed and base64 encoded Bagshui export data.
function Share:ProcessImport(text)
	local imported = BsUtil.Import(text)

	if type(imported) ~= "table" or not imported.bagshuiExportFormat then
		Bagshui:PrintError(L.Error_ImportInvalidFormat)
		return
	end

	if imported.bagshuiExportFormat > BS_EXPORT_VERSION then
		Bagshui:PrintError(L.Error_ImportVersionTooNew)
		return
	end

	-- Reset the dependency map so it can be built fresh.
	BsUtil.TableClear(self.temp.dependencyMap)

	-- Import objects in the previously determined order.
	for _, objectList in ipairs(self.importOrder) do
		if imported[objectList.objectType] then
			self.temp.dependencyMap[objectList] = {}
			for exportedId, objectInfo in pairs(imported[objectList.objectType]) do
				self.temp.dependencyMap[exportedId] = objectList:Import(objectInfo, self.temp.dependencyMap)
			end
		end
	end

end



--- Display a "Please Wait..." message over the given frame while an action is in progress.
---@param frameToShade table Window frame to place the message over.
---@param action function Callback to trigger after the window is shaded. This is where the blocking work should occur.
function Share:ImportExportAction(frameToShade, action)
	self.objectManager.ui:SetWindowShade(frameToShade, true, L.PleaseWait)
	Bagshui:QueueEvent(function()
		action()
		self.objectManager.ui:SetWindowShade(frameToShade, false)
	end, 0.05)
end



-- Reusable table for `Share:KeepDependenciesSelected()`.
local keepDependenciesSelected_listIdsToSelect = {}

--- Update list selection to reflect visually that any dependencies will be exported
--- along with the dependent objects.
---@param listFrame any
function Share:KeepDependenciesSelected(listFrame)
	BsUtil.TableClear(keepDependenciesSelected_listIdsToSelect)
	-- Build the list of dependencies that need to be selected.
	for _, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		if
			entryFrame.bagshuiData.selected
			and self.listDependencies[entryFrame.bagshuiData.scrollableListEntry]
		then
			for objectList, objectIds in pairs(self.listDependencies[entryFrame.bagshuiData.scrollableListEntry]) do
				for _, objectId in ipairs(objectIds) do
					keepDependenciesSelected_listIdsToSelect[self:MakeIdentifier(objectList.objectType, objectId)] = true
				end
			end
		end
	end
	-- Select the dependencies and lock their checkboxes.
	for _, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		if keepDependenciesSelected_listIdsToSelect[entryFrame.bagshuiData.scrollableListEntry] then
			self.objectManager.ui:SetScrollableListEntrySelectionState(listFrame, entryFrame, true)
			entryFrame.bagshuiData.checkbox:Disable()
		end
	end
end


--- Build the export interface.
function Share:InitUi()
	-- Don't initialize multiple times.
	if self.objectManager then
		return
	end

	-- Upvalue for use inside ObjectManager class functions.
	local share = self

	-- Build on ObjectManager to get most things for free.
	self.objectManager = Bagshui.prototypes.ObjectManager:New({
		objectType = "Share",
		managerMultiSelect = true,
		managerCheckboxes = true,
		disableObjectCreation = true,
		disableObjectDeletion = true,
		disableObjectEditing = true,
		managerDisplayProperty = "name",
		managerSelectionChangedFunc = function(listFrame)
			share:KeepDependenciesSelected(listFrame)
		end,
		wikiPage = BS_WIKI_PAGES.Share,
	})

	function self.objectManager:GetObjectList()
		return share.list
	end


	function self.objectManager:GetObjectInfo(objectTypeAndId)
		-- Wrapped in parentheses to only return the first value.
		return (share:GetObjectInfo(objectTypeAndId))
	end


	function self.objectManager:Share(selectedEntries)
		share:Export(selectedEntries)
	end


	function self.objectManager:Import()
		share:Import()
	end

end



--- Open the Import/Export interface.
---@param sourceObjectManager table? Bagshui ObjectManager that originated the request. If objects are selected in the ObjectList's ObjectManager, those objects will be selected in the Share UI.
---@param objectIds table<string|number, true>? Table of currently selected object IDs.
function Share:Open(sourceObjectManager, objectIds)
	self:InitUi()
	self.objectManager.Open(self.objectManager)
end



--- Open the Import interface with preselected items.
---@param sourceObjectManager table? Bagshui ObjectManager that originated the request.
---@param objectIds table<string|number, true>? Table of object IDs to select.
function Share:OpenForExport(sourceObjectManager, objectIds)
	self:Open()
	if
		sourceObjectManager and sourceObjectManager.objectType
		and objectIds
		and self.objectManager and self.objectManager.ui and self.objectManager.ui.listFrame
	then
		-- Directly manipulate the scrollable list selection since I haven't yet
		-- bothered to implement the ability to pass a list of entries to select.
		self.objectManager.ui:SetScrollableListSelection(self.objectManager.ui.listFrame)  -- Clear existing selection.
		for id, _ in pairs(objectIds) do
			self.objectManager.ui:SetScrollableListSelection(
				self.objectManager.ui.listFrame,
				self:MakeIdentifier(sourceObjectManager.objectType, id),
				true
			)
		end
	end
end



--- Open the Import interface.
function Share:OpenForImport()
	self:Open()
	self:Import()
end



--- Hide the Share window.
function Share:Close()
	for _, tbl in pairs(self.temp) do
		BsUtil.TableClear(tbl)
	end
	self.objectManager:Close()
end



--- Open the Share window if it's closed and vice-versa.
function Share:Toggle()
	if self:Visible() then
		self.objectManager:Close()
	else
		self:Open()
	end
end



--- Determine whether the Share window is open.
function Share:Visible()
	return self.objectManager and self.objectManager.uiFrame and self.objectManager.uiFrame:IsVisible()
end



-- Class event registration.
-- This is done at the end because RegisterEvent expects the class to have an OnEvent function.
-- Additional registrations are added in Share:Init().
Bagshui:RegisterEvent("PLAYER_ENTERING_WORLD", Share)


end)