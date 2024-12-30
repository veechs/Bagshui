-- Bagshui Sort Order Management UI

Bagshui:AddComponent(function()

local SortOrders = BsSortOrders


--- Subclass override for InitUI() to handle class-specific details.
function SortOrders:InitUi()
	-- ObjectList:InitUi() has the same check, but let's avoid doing any unnecessary work
	-- since the superclass function isn't called immediately.
	if self.objectManager then
		return
	end

	-- Custom menus.
	self.menus = Bagshui.prototypes.Menus:New()

	-- Reusable table for pruning sort fields out of the Add menu
	self._addSortField_IdsToOmit = {}

	-- Menu for Add Sort Field button.
	self.menus:AddMenu(
		"AddSortField",
		-- Level 1 is an auto-split SortFields menu full replacement.
		{
			autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.SORT_FIELDS,
			func = function(listFrame, fieldId)
				-- Construct a sort field entry to be added to the list.
				local fieldInfo = SortOrders.sortFields[fieldId]
				local sortFieldEntry = {
					field = fieldInfo.property,
					lookup = fieldInfo.lookup,
					direction = 'asc',
				}

				-- Figure out where in the list it belongs.
				-- When nothing is selected, put it at the end.
				-- If an item is selected, put it directly after.
				local insertPoint = table.getn(listFrame.bagshuiData.entries) + 1
				if listFrame.bagshuiData.selectedEntry then
					for i = 1, insertPoint do
						if listFrame.bagshuiData.entries[i] == listFrame.bagshuiData.selectedEntry then
							insertPoint = i + 1
							break
						end
					end
				end

				-- Add to list and refresh display.
				table.insert(listFrame.bagshuiData.entries, insertPoint, sortFieldEntry)
				self.objectManager.ui:PopulateScrollableList(listFrame, nil, true, true)
				self.objectManager.ui:SetScrollableListSelection(listFrame, sortFieldEntry, nil, true)
			end,
			notCheckable = true,
		},
		-- Level 2/3 are empty.
		nil, nil,
		-- The pre-open callback handles getting information across to the func callback.
		function(menu, button, listFrame)
			-- Figure out which fields are already in the Sort Order and omit them from the dropdown.
			BsUtil.TableClear(self._addSortField_IdsToOmit)
			for _, entry in ipairs(listFrame.bagshuiData.entries) do
				table.insert(self._addSortField_IdsToOmit, SortOrders:GetFieldIdentifier(entry.field, entry.lookup))
			end
			menu.levels[1].idsToOmit = self._addSortField_IdsToOmit
			-- Pass listFrame through to func as the first argument.
			menu.levels[1].objectId = listFrame
		end
	)


	-- Custom object editor for Sort Orders.
	local sortingEditor = {}

	-- Calls ObjectList:InitUi().
	self._super.InitUi(self,
		nil,  -- No custom Object Manager needed.
		sortingEditor,  -- This is our custom Object Editor.
		-- All the overrides.
		{
			-- Basic Object Manager settings.

			managerWidth  = 575,
			managerHeight = 400,

			managerColumns = {
				{
					field = "name",
					title = L.ObjectManager_Column_Name,
					widthPercent = "78",
					currentSortOrder = "ASC",
					lastSortOrder = "ASC",
				},
				{
					field = "builtin",
					title = L.ObjectManager_Column_Source,
					widthPercent = "12",
					lastSortOrder = "ASC",
				},
				{
					field = "inUse",
					title = L.ObjectManager_Column_InUse,
					widthPercent = "10",
					lastSortOrder = "ASC",
				},
			},


			-- Basic Object Editor settings.

			editorWidth  = 500,
			editorHeight = 350,

			editorFields = {
				"name",
				"fields",
			},

			-- Configuration for editor fields.
			editorFieldProperties = {
				name = {
					required = true
				},
				fields = {
					widgetType = "ScrollableList",
					scrollableListType = "SortOrder",  -- Unique ID for custom list.
					noSearchBox = true,
					widgetHeight = 250,
					widgetWidth = 275,

					-- Open AddSortField menu when the Add button is clicked.
					addButtonOnClick = function(listFrame)
						self.menus:OpenMenu("AddSortField", _G.this, listFrame, _G.this, 0, 0, "TOPLEFT", "BOTTOMLEFT")
					end,

					extraButtons = {
						-- Move sort field up.
						{
							scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP,
							scrollableList_AutomaticAnchor = true,
							anchorPoint = "TOPLEFT",
							anchorToPoint = "BOTTOMLEFT",
							xOffset = 0,
							yOffset = -BsSkin.toolbarGroupSpacing,
						},
						-- Move sort field down.
						{
							scrollableList_ButtonName = BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN,
							scrollableList_AutomaticAnchor = true,
							anchorPoint = "TOPLEFT",
							anchorToPoint = "BOTTOMLEFT",
							xOffset = 0,
							yOffset = -BsSkin.toolbarSpacing,
						},
					},

					-- Additional processing to do when a new list frame in the sort field list is created.
					entryFrameCreationFunc = function(entryFrameName, entryFrame, ui)

						local buttonSize = 12
						local buttonPadding = 5
						local buttonSpacing = 8

						local directionButton = ui:CreateIconButton({
							name =  "Direction",
							namePrefix = entryFrameName,
							parentFrame = entryFrame,
							texture = "SortDirectionAsc",
							textureDir = "UI",
							anchorPoint = "RIGHT",
							anchorToFrame = entryFrame,
							anchorToPoint = "RIGHT",
							width = buttonSize,
							height = buttonSize,
							xOffset = -buttonPadding,
							tooltipTitle = "Sort Direction",  -- Text here doesn't matter since it gets replaced real-time.
							tooltipText = "Click for the opposite",  -- Text here doesn't matter since it gets replaced real-time.
							noTooltipDelayShorting = true,

							onClick = function()
								entryFrame.bagshuiData.scrollableListEntry.direction = string.lower(entryFrame.bagshuiData.scrollableListEntry.direction or "") == "desc" and "asc" or "desc"
								ui:PopulateScrollableList(entryFrame.bagshuiData.listFrame, nil, true, true)
							end
						})
						directionButton.bagshuiData.listFrame = entryFrame.bagshuiData.listFrame

						local reverseButton = ui:CreateIconButton({
							name = "Reverse",
							namePrefix = entryFrameName,
							parentFrame = entryFrame,
							texture = "ReverseWordsOff",
							textureDir = "UI",
							anchorPoint = "RIGHT",
							anchorToFrame = directionButton,
							anchorToPoint = "LEFT",
							width = buttonSize,
							height = buttonSize,
							xOffset = -buttonSpacing,
							tooltipTitle = "Word Order",  -- Text here doesn't matter since it gets replaced real-time.
							tooltipText = "Click for the opposite",  -- Text here doesn't matter since it gets replaced real-time.
							noTooltipDelayShorting = true,

							onClick = function()
								entryFrame.bagshuiData.scrollableListEntry.reverseWords = (not entryFrame.bagshuiData.scrollableListEntry.reverseWords) and true or nil
								ui:PopulateScrollableList(entryFrame.bagshuiData.listFrame, nil, true, true)
							end
						})
						reverseButton.bagshuiData.listFrame = entryFrame.bagshuiData.listFrame

						entryFrame.bagshuiData.directionButton = directionButton
						entryFrame.bagshuiData.reverseButton = reverseButton

						-- Decrease the available width used to figure out how wide the text frame
						-- should be (consumed by Ui:GetAvailableScrollableListEntryFrame()).
						entryFrame.bagshuiData.widthOffset = entryFrame.bagshuiData.widthOffset + (buttonSize * 2) + buttonPadding + buttonSpacing

					end,

					-- Via entryInfoFunc we're going to return a completely
					-- different set of data to `Ui:PopulateScrollableListEntry()`.
					entryDisplayProperty = "friendlyName",

					-- For the two callbacks below, ObjectManager automatically sets the
					-- entryFrameCallbacksExtraParam to the sortingEditorInstance.

					entryInfoFunc = function(entry, sortingEditorInstance)
						return sortingEditorInstance:GetSortFieldInfo(entry)
					end,

					-- Additional processing to do when a list frame in the sort field list is populated.
					entryFramePopulateFunc = function(listFrame, entryFrame, entry, ui, sortingEditorInstance)
						sortingEditorInstance:UpdateSortOrderFieldState(entryFrame, entry, ui)
					end
				},
			},

		}
	)


	--- Set correct state of a sort order field button (sort direction, reversed words) in the list.
	---@param entryFrame table Scrollable list frame.
	---@param button table Button to update.
	---@param ui table Bagshui Ui class instance.
	---@param texturePrefix string Prefix to which the appropriate state texture suffix will be added.
	---@param isStateA boolean True to use the stateA* parameters, false to use the stateB* parameters.
	---@param stateATextureSuffix string Texture suffix to use when isStateA == true.
	---@param stateATooltipTitle string Tooltip title to use when isStateA == true.
	---@param stateATooltipText string Tooltip text to use when isStateA == true.
	---@param stateBTextureSuffix string Texture suffix to use when isStateA ~= true.
	---@param stateBTooltipTitle string Tooltip title to use when isStateA ~= true.
	---@param stateBTooltipText string Tooltip text to use when isStateA ~= true.
	function sortingEditor:UpdateSortOrderIconButton(
		entryFrame,
		button,
		ui,
		texturePrefix,
		isStateA,
		stateATextureSuffix,
		stateATooltipTitle,
		stateATooltipText,
		stateBTextureSuffix,
		stateBTooltipTitle,
		stateBTooltipText
	)
		ui:SetIconButtonTexture(button, texturePrefix .. (isStateA and stateATextureSuffix or stateBTextureSuffix))
		button.bagshuiData.tooltipTitle = (isStateA and stateATooltipTitle or stateBTooltipTitle)
		button.bagshuiData.tooltipText = (isStateA and stateATooltipText or stateBTooltipText)
		-- Keep buttons clickable.
		-- For whatever reason, this needs to reference the list frame's (parent of the entry frame)
		-- FrameLevel, not the entry frame's FrameLevel, as the list frame's level increases when
		-- frames are shuffled around, but the entry frame's level doesn't.
		button:SetFrameLevel(entryFrame.bagshuiData.listFrame:GetFrameLevel() + 5)
		-- Enable/disable based on read-only status.
		button[(self.originalObject.readOnly and "Disable" or "Enable")](button)
	end


	--- Find information about a given sort field for use in the UI.
	---@param entry string Sort field identifier.
	---@return any
	function sortingEditor:GetSortFieldInfo(entry)
		if not entry then
			return
		end
		local sortFieldInfo = BsSortOrders.sortFields[BsSortOrders:GetFieldIdentifier(entry.field, entry.lookup, "::")]
		if not sortFieldInfo then
			Bagshui:PrintError("Sort field `" .. BsSortOrders:GetFieldIdentifier(entry.field, entry.lookup, " ") .. "` not found while updating Sort Order editor UI. This shouldn't happen!")
			return entry
		end
		return sortFieldInfo
	end


	--- Update the UI to match active sort field configuration.
	---@param entryFrame table Scrollable list frame.
	---@param entry table Sort field configuration.
	---@param ui table Bagshui Ui class instance.
	function sortingEditor:UpdateSortOrderFieldState(entryFrame, entry, ui)
		if not entry then
			return
		end

		local sortFieldInfo = entryFrame.bagshuiData.scrollableListEntryInfo or self:GetSortFieldInfo(entry)

		-- Update Direction button.
		self:UpdateSortOrderIconButton(
			entryFrame,
			entryFrame.bagshuiData.directionButton,
			ui,
			"UI\\SortDirection",  -- texturePrefix
			string.lower(entry.direction or "") == "desc",  -- isStateA
			-- stateA parameters:
			"Desc",
			string.format(L.Prefix_Sort, L.Descending),
			string.format(L.Prefix_ClickFor, L.Ascending),
			-- stateB parameters:
			"Asc",
			string.format(L.Prefix_Sort, L.Ascending),
			string.format(L.Prefix_ClickFor, L.Descending)
		)

		-- Update Reverse Words button.
		if sortFieldInfo.allowReverseWords then
			self:UpdateSortOrderIconButton(
				entryFrame,
				entryFrame.bagshuiData.reverseButton,
				ui,
				"UI\\ReverseWords",  -- texturePrefix
				entry.reverseWords,  -- isStateA
				-- stateA parameters:
				"On",
				L.SortOrderEditor_ReverseWordOrder,
				string.format(L.Prefix_ClickFor, L.SortOrderEditor_NormalWordOrder),
				-- stateB parameters:
				"Off",
				L.SortOrderEditor_NormalWordOrder,
				string.format(L.Prefix_ClickFor, L.SortOrderEditor_ReverseWordOrder)
			)
			entryFrame.bagshuiData.reverseButton:Show()
		else
			entryFrame.bagshuiData.reverseButton:Hide()
		end

	end

end


end)