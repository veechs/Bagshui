-- Bagshui UI Class: Scrollable Lists
-- Warning: Messy code ahead.

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui


-- Inter-column and ScrollFrame edge padding.
local COLUMN_SPACING = 5

local HEADER_SPACING = 6


--- Create a new scrollable list.
---
--- `params` table values:
--- ```
--- {
--- 	---@type string Unique string that will be suffixed per-element and passed to `Ui:CreateElementName()`.
--- 	namePrefix,
--- 	---@type number Width of the scrollable list.
--- 	width,
--- 	---@type table? Parent frame.
--- 	parent,
--- 	---@type BS_UI_SCROLLABLE_LIST_TYPE?? Type of the list.
--- 	listType,
--- 	---@type boolean? Can list entries be selected?
--- 	selectable,
--- 	---@type boolean? Can multiple list entries be selected simultaneously using control/shift?
--- 	multiSelect,
--- 	---@type boolean? When `selectable` and `multiSelect` are true, show a checkbox next to each entry.
--- 	checkboxes,
--- 	---@type boolean? When `checkboxes` is true, headers will get checkboxes too unless this is false.
--- 	headerCheckboxes,
--- 	---@type boolean? List is fully read-only and cannot be changed. Gets stored in the list's `bagshuiData.readOnly` property.
--- 	readOnly,
--- 	---@type string? ASC/DESC
--- 	initialSortOrder,
--- 	---@type number?
--- 	rowHeight,
--- 	---@type number?
--- 	rowSpacing,
--- 	---@type (table|string)?
--- 	font,
--- 	---@type (table|string)?
--- 	headerFont,
--- 	---@type table[]? Array of columns to display (see below), if more than one field needs to be displayed.
--- 	entryColumns,
--- 	---@type boolean? `true` to disable display of column names above the list.
--- 	hideColumnHeaders,
--- 	---@type function(entry)? -> table|string Given a list entry value, return display information about that entry. Can return a table whose values should correspond to `entryColumns` fields, with `entryDisplayProperty` being the primary (first) value.
--- 	entryInfoFunc,
--- 	---@type string? When `entryInfoFunc` returns a table, this property value will be placed in the first column.
--- 	entryDisplayProperty,
--- 	---@type function(entryFrameName, entryFrame, ui)? Called after each entry frame is created to allow for custom modifications.
--- 	entryFrameCreationFunc,
--- 	---@type function(listFrame, entryFrame, entry, ui, entryFrameCallbacksExtraParam)? Called after each entry frame is populated to allow for custom modifications.
--- 	entryFramePopulateFunc,
--- 	---@type any? Additional parameter for `entryFramePopulateFunc()`.
--- 	entryFrameCallbacksExtraParam,
--- 	---@type function(entryDisplayProperty, entry, entryInfo, entryPrimaryText)? -> string When `entryInfoFunc()` returns a table, this will be called to further refine the display value.
--- 	entryColumnTextFunc
--- 	---@type function(sortField, listFrame)? Triggered when the sort field is changed by clicking a column header. Must call `Ui:PopulateScrollableList()` with the new list of entries, **sorted ascending**.
--- 	onSortFieldChanged,
--- 	---@type table? Alternate parent frame when `buttons` and the search box should be parented differently than the scrollable list itself.
--- 	buttonAndSearchBoxParent,
--- 	---@type table[]? Array of buttons to create (see below).
--- 	buttons,
--- 	---@type number? Custom x offset of first button that gets created.
--- 	firstButtonXOffset,
--- 	---@type boolean? Don't create a search box.
--- 	noSearchBox,
--- 	---@type string? Placeholder text for empty search box.
--- 	searchPlaceholderText,
--- 	---@type function(entries, entryFrame)? Called after the entire list is updated.
--- 	onChangeFunc,
--- 	---@type function(listFrame)? Callback triggered after a selection is made and the list has been updated to the new state.
--- 	onSelectionChangedFunc,
--- 	---@type function? Called when a list entry is double-clicked.
--- 	onDoubleClickFunc,
--- 	---@type function(entryFrame, modifierKeyRefresh)? Called when the mouse enters a list frame (this is already handled for item lists and will be ignored).
--- 	entryOnEnterFunc,
--- 	---@type function(entryFrame)? Called when the mouse leaves a list frame (this is already handled for item lists and will be ignored).
--- 	entryOnLeaveFunc,
--- 	---@type table? Frame that should receive drag events for item lists.
--- 	itemDragTarget
--- }
--- ```
--- `entryColumns` is an array of:
--- ```
--- {
--- 	---@type string Property in the table returned from `entryInfoFunc()` to display.
--- 	field = "name",
--- 	---@type string Column title to display in the UI.
--- 	title = L.CategoryManager_Name,
--- 	---@type number Absolute width of this column. Either `width` or `widthPercent` is required, with the former prioritized over the latter.
--- 	width = 200,
--- 	---@type number Relative width of this column.
--- 	widthPercent = 90,
--- 	---@type string Only one column should have this property. This will be the initial sort order of the list.
---		currentSortOrder = "ASC",
--- 	---@type string Starting sort order for this column if the user chooses to sort by it.
---		lastSortOrder = "ASC",
--- 	---@type boolean Disallow changing sort order for this column.
---		lockSortOrder = true,
--- }
--- ```
--- 	
--- `buttons` is an array of `Ui:CreateIconButton()` `buttonOpts` parameter values, plus the special properties below.
--- Note that the `*_Disable` properties can be updated at any time before calling `PopulateScrollableList()`
--- and the changes will be taken into account.
--- ```
--- {
--- 	---@type boolean? Don't create this button.
--- 	skip,
--- 	---@type BS_UI_SCROLLABLE_LIST_BUTTON_NAME? One of the pre-configured scrollable list button types, some of which come with built-in behaviors. 
--- 	scrollableList_ButtonName,
--- 	---@type boolean? When true, anchor this button to the previous one in the array.
--- 	scrollableList_AutomaticAnchor,
--- 	---@type boolean? When true, anchor this button to the search box for the list frame.
--- 	scrollableList_AnchorToSearchBox,
--- 	---@type boolean? When true, anchor this button to the scroll frame itself (technically anchors to the background since that's the visual representation of the ScrollFrame).
--- 	scrollableList_AnchorToScrollFrame,
--- 	---@type boolean? When true, disable the button.
--- 	scrollableList_Disable,
--- 	---@type boolean? When true, disable the button if nothing in the list is selected.
--- 	scrollableList_DisableIfNothingSelected,
--- 	---@type boolean? When true, disable the button if multiple items in the list are selected.
--- 	scrollableList_DisableIfMultipleSelected,
--- 	---@type boolean? When true, disable the button when the first item in the list is selected.
--- 	scrollableList_DisableIfFirstEntrySelected,
--- 	---@type boolean? When true, disable the button only when the last item in the list is selected.
--- 	scrollableList_DisableIfLastEntrySelected,
--- 	---@type boolean? When true, disable the button if the list entry information has a `readOnly` property that is true.
--- 	scrollableList_DisableIfReadOnly,
--- 	---@type function(scrollableListEntryInfo) -> boolean? When true is returned, disable the button.
--- 	scrollableList_DisableFunc,
--- }
---```
---@param params table 
---@return table scrollFrame
---@return table scrollChild
---@return table listFrame
function Ui:CreateScrollableList(params)
	assert(type(params) == "table", "Parameter list for Ui:CreateScrollableList() must be a table")
	assert(params.namePrefix, "CreateScrollableItemList(): namePrefix is required")
	assert(params.width, "CreateScrollableItemList(): width is required")

	-- Default to text list if not specified.
	local listType = params.listType or BS_UI_SCROLLABLE_LIST_TYPE.TEXT

	-- Prepare list of available buttons (this can't be done sooner due to localization stuff).
	-- Using `Ui` instead of `self` here so it's only done once -- this is constant across all instances of the Ui class.
	if not Ui._createScrollableList_AvailableButtons then
		Ui._createScrollableList_AvailableButtons = {
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.NEW] = {
				name = "New",
				texture = "Add",
				tooltipTitle = L.New,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.ADD] = {
				name = "Add",
				texture = "Add",
				tooltipTitle = L.Add,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DELETE] = {
				name = "Delete",
				texture = "Delete",
				tooltipTitle = L.Delete,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfReadOnly = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN] = {
				name = "Down",
				texture = "Down",
				tooltipTitle = L.MoveDown,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfLastEntrySelected = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DUPLICATE] = {
				name = "Duplicate",
				texture = "Duplicate",
				tooltipTitle = L.Duplicate,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfMultipleSelected = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.EDIT] = {
				name = "Edit",
				texture = "Edit",
				tooltipTitle = L.Edit,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfMultipleSelected = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.IMPORT] = {
				name = "Import",
				texture = "Import",
				tooltipTitle = L.Import,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.REMOVE] = {
				name = "Remove",
				texture = "Remove",
				tooltipTitle = L.Remove,
				scrollableList_DisableIfNothingSelected = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.REPLACE] = {
				name = "Replace",
				texture = "Replace",
				tooltipTitle = L.Replace,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfMultipleSelected = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.SHARE] = {
				name = "Share",
				texture = "Share",
				tooltipTitle = L.Share,
				scrollableList_DisableIfEmptyList = true,
			},
			[BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP] = {
				name = "Up",
				texture = "Up",
				tooltipTitle = L.MoveUp,
				scrollableList_DisableIfNothingSelected = true,
				scrollableList_DisableIfFirstEntrySelected = true,
			},
		}
	end

	-- Helper functions -- declared here to capture `self`.
	if not self._scrollableList_SetSelection then

		-- OnClick helper function for list selection and pulling items from the cursor.
 		self._scrollableList_SetSelection = function()
			-- If there is an item on the cursor, add that to the list.
			local item
			if _G.this.bagshuiData.listFrame.bagshuiData.scrollableListType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
				item = Bagshui:GetCursorItem()
			end
			if item then
				-- The cursor held an item.
				self:ItemListAdd(_G.this.bagshuiData.listFrame, item.id)
				_G.ClearCursor()
			else
				-- Normal behavior.
				self:CloseMenusAndClearFocuses(true, true, false)
				self:SetScrollableListSelection(_G.this.bagshuiData.listFrame, _G.this)
			end
		end

		-- OnMouseUp/OnReceiveDrag helper function for item lists to pull items from the cursor.
		self._scrollableItemList_ReceivedItem = function()
			if not _G.this.bagshuiData then
				return
			end
			local item = Bagshui:GetCursorItem()
			local targetListFrame =
				_G.this.bagshuiData.itemDragTargetListFrame
				or _G.this.bagshuiData.listFrame
				or (_G.this.bagshuiData.entries and _G.this)
			if item and targetListFrame then
				self:ItemListAdd(targetListFrame, item.id)
				_G.ClearCursor()
			end
		end

		-- OnClick helper function for column headers.
		self._scrollableList_SetSortOrder = function()
			-- Changing the sort field is only possible if there's a callback function
			-- to re-sort the entry list. As noted in the `params` table description for
			-- `Ui:CreateScrollableList()`, this function is responsible for calling
			-- `Ui:PopulateScrollableList()` with the updated entry list, **sorted ascending**.
			if _G.this.bagshuiData.listFrame.bagshuiData.onSortFieldChanged then
				_G.PlaySound("igMainMenuOptionCheckBoxOn")

				-- Get the sort field name and the most recent way it was sorted.
				local sortField = _G.this.bagshuiData.columnParams.sortField or _G.this.bagshuiData.columnParams.field
				local newSortOrder = _G.this.bagshuiData.columnParams.lastSortOrder

				-- If the field is the current sort order field, reverse it.
				if _G.this.bagshuiData.columnParams.currentSortOrder and not _G.this.bagshuiData.columnParams.lockSortOrder then
					if _G.this.bagshuiData.columnParams.currentSortOrder == "ASC" then
						newSortOrder = "DESC"
					else
						newSortOrder = "ASC"
					end
				end

				-- Update the state of all sort fields
				for _, col in ipairs(_G.this.bagshuiData.listFrame.bagshuiData.entryColumns) do
					if (col.sortField or col.field) == sortField then
						col.currentSortOrder = newSortOrder
						col.lastSortOrder = newSortOrder
					else
						col.currentSortOrder = nil
					end
				end

				-- Store the sort order so `PopulateScrollableList()` can decide whether
				-- it's working forwards or backwards through the entry list.
				_G.this.bagshuiData.listFrame.bagshuiData.sortOrder = newSortOrder

				-- Trigger the callback.
				_G.this.bagshuiData.listFrame.bagshuiData.onSortFieldChanged(sortField, _G.this.bagshuiData.listFrame)
			end
		end
	end


	-- Create the scrollable list components and store cross-references everywhere for easy access.

	local scrollFrame, scrollChild, listFrame = self:CreateScrollableContent(params.namePrefix, params.parent)
	scrollChild.bagshuiData.listFrame = listFrame
	scrollFrame.bagshuiData.listFrame = listFrame
	scrollFrame.bagshuiData.scrollableListType = listType
	scrollChild.bagshuiData.scrollableListType = listType
	listFrame.bagshuiData.scrollableListType = listType


	-- Initialize Bagshui properties.

	-- Array of list entry values, as provided to `Ui:PopulateScrollableList()`.
	---@type any[]
	listFrame.bagshuiData.entries = {}

	-- All frames that are currently populated and displayed in the list.
	listFrame.bagshuiData.entryFrames = {}

	-- Key-value table representing all currently selected objects in the list.
	-- Keys are object IDs and values are always `true`.
	---@type table<any, true>
	listFrame.bagshuiData.selectedEntries = {}

	-- When only one item in the list is selected, this will be populated with
	-- its object ID (it will also have an entry in `selectedEntries`; this is
	-- provided for convenience so functions that only deal with one selected
	-- item don't need to iterate and do extra work).
	---@type any
	listFrame.bagshuiData.selectedEntry = nil


	-- Pass parameters through for later use (see this function's definition for details).

	listFrame.bagshuiData.entryInfoFunc = params.entryInfoFunc
	listFrame.bagshuiData.entryColumnTextFunc = params.entryColumnTextFunc
	listFrame.bagshuiData.sortOrder = params.initialSortOrder or "ASC"
	listFrame.bagshuiData.onSortFieldChanged = params.onSortFieldChanged
	listFrame.bagshuiData.entryFrameCreationFunc = params.entryFrameCreationFunc
	listFrame.bagshuiData.entryColumns = params.entryColumns
	listFrame.bagshuiData.entryFramePopulateFunc = params.entryFramePopulateFunc
	listFrame.bagshuiData.entryFrameCallbacksExtraParam = params.entryFrameCallbacksExtraParam
	listFrame.bagshuiData.entryColumns = params.entryColumns
	listFrame.bagshuiData.entryDisplayProperty = (params.entryColumns and params.entryColumns[1].field) or params.entryDisplayProperty or "Name"
	listFrame.bagshuiData.rowHeight = params.rowHeight or (params.listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM and 24 or 16)
	listFrame.bagshuiData.rowSpacing = params.rowSpacing or (params.listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM and 3 or 0)
	listFrame.bagshuiData.font = params.font or "GameFontHighlight"
	listFrame.bagshuiData.headerFont = params.headerFont or "GameFontNormal"
	listFrame.bagshuiData.selectable = params.selectable or params.multiSelect
	listFrame.bagshuiData.multiSelect = params.multiSelect
	listFrame.bagshuiData.checkboxes = params.multiSelect and params.checkboxes
	listFrame.bagshuiData.headerCheckboxes = params.headerCheckboxes
	listFrame.bagshuiData.readOnly = params.readOnly
	listFrame.bagshuiData.onSelectionChangedFunc = params.onSelectionChangedFunc
	listFrame.bagshuiData.onDoubleClickFunc = params.onDoubleClickFunc
	listFrame.bagshuiData.entryOnEnterFunc = params.entryOnEnterFunc
	listFrame.bagshuiData.entryOnLeaveFunc = params.entryOnLeaveFunc
	listFrame.bagshuiData.onChangeFunc = params.onChangeFunc


	-- Add drag handling for item lists.
	if listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM and params.itemDragTarget then
		if not params.itemDragTarget.bagshuiData then
			params.itemDragTarget.bagshuiData = {}
		end

		-- Required by `self._scrollableItemList_ReceivedItem()` for the itemDragTarget.
		-- (Not needed for the other scrollable list components -- see logic in the aforementioned ReceivedItem function.)
		params.itemDragTarget.bagshuiData.itemDragTargetListFrame = listFrame

		-- Drag target + scrollable list components should respond to drag events.
		params.itemDragTarget:EnableMouse(true)
		params.itemDragTarget:SetScript("OnReceiveDrag", self._scrollableItemList_ReceivedItem)
		listFrame:SetScript("OnReceiveDrag", self._scrollableItemList_ReceivedItem)
		scrollFrame:SetScript("OnReceiveDrag", self._scrollableItemList_ReceivedItem)
		scrollChild:SetScript("OnReceiveDrag", self._scrollableItemList_ReceivedItem)


		-- In addition to drag events, everybody needs to receive MouseUp so that
		-- clicking with an item on the cursor works. Capturing the existing OnMouseUp
		-- so nothing gets broken.

		local oldItemDragTargetOnMouseUp = params.itemDragTarget:GetScript("OnMouseUp")
		params.itemDragTarget:SetScript("OnMouseUp", function()
			self._scrollableItemList_ReceivedItem()
			if oldItemDragTargetOnMouseUp then
				oldItemDragTargetOnMouseUp()
			end
		end)

		local oldListFrameOnMouseUp = listFrame:GetScript("OnMouseUp")
		listFrame:SetScript("OnMouseUp", function()
			self._scrollableItemList_ReceivedItem()
			if oldListFrameOnMouseUp then
				oldListFrameOnMouseUp()
			end
		end)

		local scrollChildOnMouseUp = scrollChild:GetScript("OnMouseUp")
		scrollChild:SetScript("OnMouseUp", function()
			self._scrollableItemList_ReceivedItem()
			if scrollChildOnMouseUp then
				scrollChildOnMouseUp()
			end
		end)

		local scrollFrameOnMouseUp = scrollFrame:GetScript("OnMouseUp")
		scrollFrame:SetScript("OnMouseUp", function()
			self._scrollableItemList_ReceivedItem()
			if scrollFrameOnMouseUp then
				scrollFrameOnMouseUp()
			end
		end)
	end


	-- Set initial width.
	self:SetWidth(scrollFrame, params.width)  -- Using Ui:SetWidth for ScrollFrame as explained in the function declaration.
	listFrame:SetWidth(params.width)


	-- Add headers if there are columns.
	if params.entryColumns then
		local nextAnchorToFrame = scrollFrame.bagshuiData.background
		local nextAnchorToPoint = "TOPLEFT"

		listFrame.bagshuiData.columnHeaders = {}

		-- Populate listFrame.bagshuiData.columnHeaders with a table of { fieldName = columnFrame }.
		for i, col in ipairs(params.entryColumns) do
			assert(col.field, "Column " .. i .. " in the " .. params.namePrefix .. " scrollable list does not have a field property")
			assert(col.width or col.widthPercent, "Column " .. i .. " in the " .. params.namePrefix .. " scrollable list does not have a width or widthPercent property")

			local columnFrame = _G.CreateFrame(
				"Button",
				params.namePrefix .. col.field .. "ColumnHeader",
				params.parent
			)
			listFrame.bagshuiData.columnHeaders[col.field] = columnFrame

			columnFrame.bagshuiData = {
				listFrame = listFrame,
				columnNum = i,
				columnParams = col,
				text = self:CreateShadowedFontString(columnFrame, nil, "GameFontNormalSmall"),
			}

			columnFrame.bagshuiData.text:SetText(col.title or col.name or col.field)

			-- headerHeight is used by `Ui:SetPoint()` to account for headers when
			-- setting the top point of the scrollFrame.
			if scrollFrame.bagshuiData.headerHeight == 0 and not params.hideColumnHeaders then
				scrollFrame.bagshuiData.headerHeight = columnFrame.bagshuiData.text:GetHeight() + 2
			end

			-- Formatting.
			columnFrame.bagshuiData.text:SetJustifyH("LEFT")
			columnFrame.bagshuiData.text:SetJustifyV("MIDDLE")
			columnFrame.bagshuiData.text:SetPoint("TOPLEFT", columnFrame, COLUMN_SPACING, 0)
			columnFrame.bagshuiData.text:SetPoint("BOTTOMRIGHT", columnFrame, -COLUMN_SPACING, 0)

			-- Calculate width and set size/position.
			local columnWidth = col.width or (scrollFrame:GetWidth() * (col.widthPercent / 100))
			params.entryColumns[i].actualWidth = columnWidth - 10
			columnFrame:SetWidth(columnWidth)
			columnFrame:SetHeight(scrollFrame.bagshuiData.headerHeight)
			columnFrame:SetPoint("BOTTOMLEFT", nextAnchorToFrame, nextAnchorToPoint, 0, 1)

			columnFrame:SetScript("OnClick", self._scrollableList_SetSortOrder)

			nextAnchorToFrame = columnFrame
			nextAnchorToPoint = "BOTTOMRIGHT"
		end

		-- Set initial column header state.
		self:UpdateScrollableListColumnHeaders(listFrame)
	end

	-- Create search box
	if not params.noSearchBox then
		local searchBox = self:CreateSearchBox(
			params.namePrefix .. "SearchBox",
			params.buttonAndSearchBoxParent or params.parent,
			nil,  -- Width.
			nil,  -- Height.
			function()  -- OnTextChanged.
				self:ShowScrollableListEntries(listFrame, _G.this.bagshuiData.searchText)
			end,
			nil,  -- OnEnterPressed.
			nil,  -- OnIconClick.
			params.searchPlaceholderText
		)
		listFrame.bagshuiData.searchBox = searchBox
	end

	-- Create buttons (add, remove, etc.).
	listFrame.bagshuiData.buttons = {}
	if type(params.buttons) == "table" then

		-- Reusable table.
		if not self._createScrollableList_ButtonParams then
			self._createScrollableList_ButtonParams = {}
		end

		local lastCreatedButton
		local buttonParams = self._createScrollableList_ButtonParams


		for _, button in ipairs(params.buttons) do

			if not button.skip then
				BsUtil.TableClear(buttonParams)
				local buttonName = button.scrollableList_ButtonName or button.name

				-- Set initial parameters if available.
				if Ui._createScrollableList_AvailableButtons[buttonName] then
					BsUtil.TableCopy(Ui._createScrollableList_AvailableButtons[buttonName], buttonParams)
				end
				for key, val in pairs(button) do
					buttonParams[key] = val
				end

				buttonParams.name = params.namePrefix .. buttonParams.name
				buttonParams.parentFrame = params.buttonAndSearchBoxParent or params.parent

				-- Adjust anchor as requested.
				if button.scrollableList_AnchorToScrollFrame then
					-- Need to anchor to background since that's the visual representation of the ScrollFrame.
					buttonParams.anchorToFrame = scrollFrame.bagshuiData.background

				elseif button.scrollableList_AnchorToSearchBox and listFrame.bagshuiData.searchBox then
					buttonParams.anchorToFrame = listFrame.bagshuiData.searchBox

				elseif button.scrollableList_AutomaticAnchor then
					buttonParams.anchorToFrame = lastCreatedButton or buttonParams.parentFrame
					buttonParams.anchorPoint = buttonParams.anchorPoint or "LEFT"
					buttonParams.anchorToPoint = buttonParams.anchorToPoint or (not lastCreatedButton and "LEFT" or "RIGHT")

				end


				-- Automatic Add and Copy button handling for Item lists.

				if listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
					if button.scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.ADD then
						buttonParams.onClick = function()
							self:ItemListPromptForNew(listFrame)
						end
					end

					if button.scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.SHARE then
						buttonParams.onClick = function()
							self:ItemListOpenCopyDialog(listFrame)
						end
					end
				end


				-- Remove, Up, and Down buttons always do the same thing.
				if button.scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.REMOVE then
					-- Temporary table for removals to avoid errors.
					-- Without this, pairs() can fail depending on the removal order.
					local scrollableList_EntriesToRemove = {}
					buttonParams.onClick = function()
						-- Build temporary list of entries to remove.
						BsUtil.TableClear(scrollableList_EntriesToRemove)
						for selectedEntry, _ in pairs(listFrame.bagshuiData.selectedEntries) do
							table.insert(scrollableList_EntriesToRemove, selectedEntry)
						end
						-- Perform removals.
						for _, selectedEntry in ipairs(scrollableList_EntriesToRemove) do
							self:ScrollableListRemove(listFrame, selectedEntry)
						end
						BsUtil.TableClear(scrollableList_EntriesToRemove)
					end
				end

				if
					button.scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP
					or button.scrollableList_ButtonName == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN
				then
					local upDown = button.scrollableList_ButtonName
					buttonParams.onClick = function()
						self:ScrollableListMove(listFrame, listFrame.bagshuiData.selectedEntry, upDown)
					end
				end


				-- Pick up additional/override parameters.
				for param, value in pairs(button) do
					if param == "onClick" then
						local onClick = value
						buttonParams[param] = function()
							onClick(listFrame)
						end
					else
						buttonParams[param] = value
					end
				end

				-- Adjust X offset when this is the first button and automatic anchoring is enabled.
				if buttonParams.scrollableList_AutomaticAnchor and params.firstButtonXOffset and not lastCreatedButton then
					buttonParams.xOffset = params.firstButtonXOffset
				end

				-- Create button.
				listFrame.bagshuiData.buttons[buttonName] = self:CreateIconButton(buttonParams)
				listFrame.bagshuiData.buttons[buttonName].bagshuiData.listFrame = listFrame
				listFrame.bagshuiData.buttons[buttonName].bagshuiData.scrollableList_Disable = buttonParams.scrollableList_Disable or buttonParams.disable
				listFrame.bagshuiData.buttons[buttonName].bagshuiData.scrollableList_DisableFunc = buttonParams.scrollableList_DisableFunc or buttonParams.disableFunc
				for prop, val in pairs(buttonParams) do
					if string.find(prop, "^scrollableList_") then
						listFrame.bagshuiData.buttons[buttonName].bagshuiData[prop] = val
					end
				end


				lastCreatedButton = listFrame.bagshuiData.buttons[buttonName]
			end
		end
	end

	-- Same return values as CreateScrollableContent().
	return scrollFrame, scrollChild, listFrame
end



--- Fill or refresh a Bagshui scrollable list frame built by `CreateScrollableList()`.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entries table? Array of list entry values.
---@param refresh boolean? When `entries` is nil, don't clear the list and just refresh it.
---@param preserveSelection boolean? Don't de-select the currently selected list entry.
---@param preserveSearch boolean? Don't clear search text.
function Ui:PopulateScrollableList(listFrame, entries, refresh, preserveSelection, preserveSearch)
	assert(listFrame.bagshuiData.scrollableListType, "Ui:PopulateScrollableList(): Given listFrame is not a scrollable list")

	-- Clear search text.
	if listFrame.bagshuiData.searchBox and not preserveSearch then
		listFrame.bagshuiData.searchBox:SetText("")
	end

	-- Save list of entries to `listFrame.bagshuiData.entries` so they're accessible for filtering.
	if entries then
		-- We've been given a fresh set of entries, so replace the existing ones.
		BsUtil.TableCopy(entries, listFrame.bagshuiData.entries)

	elseif not refresh and not listFrame.bagshuiData.refreshAfterUnknownItems then
		-- This is not a refresh scenario and no entries were provided, so clear the list.
		-- Regarding `refreshAfterUnknownItems`, see the `listFrame.bagshuiData.hasUnknownItems`
		-- comment just below.
		BsUtil.TableClear(listFrame.bagshuiData.entries)
	end

	-- Release any existing item list frames
	self:ReleaseScrollableListFrames(listFrame.bagshuiData.entryFrames)
	BsUtil.TableClear(listFrame.bagshuiData.entryFrames)

	-- Used to track whether we saw any unknown items for item-type lists and schedule a refresh
	-- callback if we did.
	-- * It's updated by `PopulateScrollableListEntry()` if `ItemInfo:Get()` can't obtain
	--   information about an item.
	-- * If it's true at the end of this function, a refresh pass will be queued and
	--   `refreshAfterUnknownItems` will be set to true. This will hopefully give
	--   to receive information about the unknown item(s).
	listFrame.bagshuiData.hasUnknownItems = false

	-- This will be set to `true` in `PopulateScrollableListEntry()` if applicable.
	listFrame.bagshuiData.hasHeaders = false


	local listType = listFrame.bagshuiData.scrollableListType
	local entryFrames = listFrame.bagshuiData.entryFrames

	-- Prepare frames for everything in the list.
	if table.getn(listFrame.bagshuiData.entries) > 0 then

		-- Display in descending order if required.
		local entryStart = 1
		local entryEnd = table.getn(listFrame.bagshuiData.entries)
		local entryStep = 1
		if listFrame.bagshuiData.sortOrder == "DESC" then
			entryStart = entryEnd
			entryEnd = 1
			entryStep = -1
		end

		-- Used by `Ui:SetScrollableListSelection()` when Shift is down to select
		-- a range of frames.
		local sequentialFrameNum = 1

		-- Associate child frames with their headers.
		local lastHeaderFrame

		for i = entryStart, entryEnd, entryStep do
			local entry = listFrame.bagshuiData.entries[i]

			-- Grab an entry frame, reusing existing if possible.
			local entryFrame = self:GetAvailableScrollableListEntryFrame(listFrame, listType, listFrame.bagshuiData.entryFrameCreationFunc)
			entryFrame.bagshuiData.scrollableListEntry = entry
			entryFrame.bagshuiData.sequentialFrameNum = sequentialFrameNum

			-- Store data needed for list selection behavior.
			entryFrame.bagshuiData.listFrame = listFrame
			if entryFrame.bagshuiData.itemButton then
				entryFrame.bagshuiData.itemButton.bagshuiData.listFrame = listFrame
			end

			-- Add to this item list's array of item frames.
			table.insert(entryFrames, entryFrame)

			-- Update list entry with entry info.
			self:PopulateScrollableListEntry(listFrame, entryFrame, entry)

			-- Header tracking.
			if entryFrame.bagshuiData.isHeader then
				lastHeaderFrame = entryFrame
				entryFrame.bagshuiData.headerFrame = nil
			else
				entryFrame.bagshuiData.headerFrame = lastHeaderFrame
			end


			-- Manage selection and double-click behavior.

			local onMouseDown = nil
			if listFrame.bagshuiData.selectable then
				entryFrame:RegisterForClicks("LeftButtonUp")
				onMouseDown = self._scrollableList_SetSelection
			else
				entryFrame:RegisterForClicks(nil)
			end
			entryFrame:SetScript("OnMouseDown", onMouseDown)

			-- Item lists.
			if entryFrame.bagshuiData.itemButton then
				entryFrame.bagshuiData.itemButton:SetScript("OnMouseDown", onMouseDown)
			end

			entryFrame:SetScript("OnDoubleClick", listFrame.bagshuiData.onDoubleClickFunc)

			sequentialFrameNum = sequentialFrameNum + 1
		end
	end

	-- Make frames visible in the UI.
	self:ShowScrollableListEntries(listFrame, (listFrame.bagshuiData.searchBox and listFrame.bagshuiData.searchBox.bagshuiData.searchText))

	-- Update selection and button states.
	self:SetScrollableListSelection(listFrame, (preserveSelection and listFrame.bagshuiData.lastSelection or nil))


	-- Operations that only need to happen once and not after a second refresh for unknown items.
	if not listFrame.bagshuiData.refreshAfterUnknownItems then

		-- Update headers.
		self:UpdateScrollableListColumnHeaders(listFrame)

		-- Notify of change.
		if listFrame.bagshuiData.onChangeFunc then
			listFrame.bagshuiData.onChangeFunc(listFrame.bagshuiData.entries, listFrame)
		end
	end

	-- Refresh again if there were unknown items.
	if listFrame.bagshuiData.hasUnknownItems and not listFrame.bagshuiData.refreshAfterUnknownItems then
		listFrame.bagshuiData.hasUnknownItems = false
		listFrame.bagshuiData.refreshAfterUnknownItems = true
		Bagshui:QueueClassCallback(self, self.PopulateScrollableList, 0.5, false, listFrame, nil)
		return
	end

	-- Reset callback flag state if we make it this far.
	listFrame.bagshuiData.refreshAfterUnknownItems = nil
end



--- Add content to a scrollable list entry frame.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entryFrame table Frame from `GetAvailableScrollableListEntryFrame()`.
---@param entry any List entry pulled from the `entries` provided to `CreateScrollableList()`.
function Ui:PopulateScrollableListEntry(listFrame, entryFrame, entry)
	local listType = listFrame.bagshuiData.scrollableListType
	local entryPrimaryText
	local entryInfo = entry
	local textFrames = entryFrame.bagshuiData.textFrames
	entryFrame.bagshuiData.isHeader = false  -- Not currently supported for ITEM type lists.

	if listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
		-- Additional work for item lists -- get item information, assign to item slot button.

		-- entryInfo becomes an alias to the item button's reusable item info table.
		entryInfo = entryFrame.bagshuiData.itemButton.bagshuiData.item

		-- Always reset the item info table. Without this, switching from a known
		-- to an unknown item doesn't work because entryInfo.name still has a value.
		BsItemInfo:InitializeItem(entryInfo, true)

		-- When entry is already a Bagshui item, don't call GetItemInfo again.
		if type(entry) == "table" and type(entry.bagshuiInventoryType) then
			BsUtil.TableCopy(entry, entryInfo)
		else
			-- Obtain item info - reuse the itemButton's info table for this
			BsItemInfo:Get(
				entry,  -- itemIdentifier
				entryInfo,  -- itemInfoTable
				true,  -- initialize
				false,  -- reinitialize
				true  -- forceIntoLocalGameCache
			)
		end

		-- If we didn't get a name, set it to `Unknown (<itemID or itemString>)`
		-- since we need something to put on the label.
		if string.len(entryInfo.name or "") == 0 then
			if not listFrame.bagshuiData.refreshAfterUnknownItems then
				listFrame.bagshuiData.hasUnknownItems = true  -- Consumed by PopulateScrollableList() to trigger a refresh of item info.
				BsItemInfo:LoadItemIntoLocalGameCache(entry)
			end
			entryInfo.name = L.Unknown .. " (" .. tostring(entry) .. ")"
		end

		-- Assign to item slot button.
		self:AssignItemToItemButton(entryFrame.bagshuiData.itemButton, entryInfo)

		-- Change label to show item name.
		entryPrimaryText = entryInfo.name

	else
		-- All other list types.

		-- Figure out the primary entry text, using entry information functions if available.
		if listFrame.bagshuiData.entryInfoFunc then
			entryInfo = listFrame.bagshuiData.entryInfoFunc(entry, listFrame.bagshuiData.entryFrameCallbacksExtraParam)
		end

		if type(entryInfo) == "table" then
			entryPrimaryText = entryInfo[listFrame.bagshuiData.entryDisplayProperty]
			if listFrame.bagshuiData.entryColumnTextFunc then
				entryPrimaryText = listFrame.bagshuiData.entryColumnTextFunc(listFrame.bagshuiData.entryDisplayProperty, entry, entryInfo, entryPrimaryText, listFrame.bagshuiData.entryFrameCallbacksExtraParam)
			end
			entryFrame.bagshuiData.isHeader = entryInfo.scrollableList_Header
		else
			entryPrimaryText = tostring(entryInfo)
		end
	end

	-- Store entry information so it's accessible elsewhere.
	entryFrame.bagshuiData.scrollableListEntry = entry
	entryFrame.bagshuiData.scrollableListEntryInfo = entryInfo


	-- Set primary text.
	textFrames[1]:SetText(entryPrimaryText)

	-- Track which column frames to hide. Start at 2 since the first text frame is always visible.
	local frameHideStart = 2


	if listFrame.bagshuiData.entryColumns then
		-- This list has multiple columns.

		local nextAnchorToFrame = textFrames[1]

		for i, col in ipairs(listFrame.bagshuiData.entryColumns) do
			local columnWidth = col.actualWidth

			if i == 1 then
				-- The first frame has already been populated above and we just
				-- need to adjust the width.
				columnWidth = columnWidth - entryFrame.bagshuiData.widthOffset

			else
				-- Add another column text frame if needed.
				if not textFrames[i] then
					textFrames[i] = self:CreateShadowedFontString(entryFrame)
				end

				-- Get text and populate the frame.

				local columnText = entryInfo[col.field] ~= nil and tostring(entryInfo[col.field]) or ""
				if listFrame.bagshuiData.entryColumnTextFunc then
					columnText = listFrame.bagshuiData.entryColumnTextFunc(col.field, entry, entryInfo, columnText)
				end

				textFrames[i]:SetText(columnText)
				textFrames[i]:SetPoint("LEFT", nextAnchorToFrame, "RIGHT", 10, 0)
				textFrames[i]:SetJustifyH(col.align or "LEFT")

				nextAnchorToFrame = textFrames[i]
			end

			textFrames[i]:SetWidth(columnWidth)
			textFrames[i]:SetFontObject(listFrame.bagshuiData.font)

			frameHideStart = frameHideStart + 1
		end

	else
		-- Single column.
		textFrames[1]:SetWidth(listFrame:GetWidth() - entryFrame.bagshuiData.widthOffset)

	end


	-- Various other parts of ScrollableList need to know whether any headers exist.
	if entryFrame.bagshuiData.isHeader then
		listFrame.bagshuiData.hasHeaders = true
	end


	-- Hide unused frames.
	for i = frameHideStart, table.getn(textFrames) do
		textFrames[i]:Hide()
	end


	-- Show/hide checkboxes and apply header styling as needed.
	self:UpdateScrollableListEntryFrame(listFrame, entryFrame)

	-- Custom callback.
	if listFrame.bagshuiData.entryFramePopulateFunc then
		listFrame.bagshuiData.entryFramePopulateFunc(
			listFrame,
			entryFrame,
			entry,
			self,
			listFrame.bagshuiData.entryFrameCallbacksExtraParam
		)
	end
end



-- Display scrollable item list entries in the UI, filtering by searchText if provided.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param searchText string? Filter text. *Currently only works against the primary text (first column).*
function Ui:ShowScrollableListEntries(listFrame, searchText)
	local listType = listFrame.bagshuiData.scrollableListType
	local entryFrames = listFrame.bagshuiData.entryFrames
	local rowHeight = listFrame.bagshuiData.rowHeight
	local rowSpacing = listFrame.bagshuiData.rowSpacing

	local contentHeight = 0
	local contentFrameWidth = listFrame.bagshuiData.scrollChild:GetWidth()
	local nextAnchor = listFrame
	local nextAnchorPoint = "TOPLEFT"
	local nextYOffset = -5

	for _, entryFrame in ipairs(entryFrames) do

		entryFrame.bagshuiData.show = true

		if searchText then

			if listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
				-- Item list.
				entryFrame.bagshuiData.show = BsRules:Match(searchText, entryFrame.bagshuiData.itemButton.bagshuiData.item, nil, nil, true)

			else
				-- Text list.
				entryFrame.bagshuiData.show = (string.find(string.lower(BsUtil.RemoveUiEscapes(entryFrame.bagshuiData.textFrames[1]:GetText())), string.lower(searchText)) ~= nil)
			end
		end

	end


	-- Show headers when child frames are shown.
	if listFrame.bagshuiData.hasHeaders then
		for headerIndex, headerFrame in ipairs(entryFrames) do
			if headerFrame.bagshuiData.isHeader then
				headerFrame.bagshuiData.show = false
				-- Scan forward until we reach the next header frame.
				-- Within this range are the entry frames that belong to the current header.
				for child = headerIndex + 1, table.getn(entryFrames) do
					if entryFrames[child].bagshuiData.isHeader then
						break
					end
					if entryFrames[child].bagshuiData.show then
						headerFrame.bagshuiData.show = true
						break
					end
				end
			end
		end
	end


	-- Show/hide entries.
	for i, entryFrame in ipairs(entryFrames) do

		if entryFrame.bagshuiData.show then
			entryFrame:ClearAllPoints()
			entryFrame:SetParent(listFrame)
			entryFrame:SetPoint("TOPLEFT", nextAnchor, nextAnchorPoint, 0, nextYOffset - ((i > 1 and entryFrame.bagshuiData.isHeader) and HEADER_SPACING or 0))
			entryFrame:SetWidth(contentFrameWidth)
			entryFrame:SetHeight(rowHeight + (entryFrame.bagshuiData.isHeader and 1 or 0))
			entryFrame:Show()

			-- Make sure item slot button and checkbox are above the frame so they can receive events.
			if entryFrame.bagshuiData.itemButton then
				entryFrame.bagshuiData.itemButton:SetFrameLevel(entryFrame:GetFrameLevel() + 5)
			end
			if entryFrame.bagshuiData.checkbox and entryFrame.bagshuiData.checkbox:IsShown() then
				entryFrame.bagshuiData.checkbox:SetFrameLevel(entryFrame:GetFrameLevel() + 5)
			end

			-- Prepare for next loop
			nextAnchor = entryFrame
			nextAnchorPoint = "BOTTOMLEFT"
			nextYOffset = -rowSpacing
			contentHeight = contentHeight + rowHeight + rowSpacing

		else
			entryFrame:Hide()
		end

	end


	-- Update height of associated scrollChild.
	listFrame.bagshuiData.scrollChild:SetHeight(contentHeight + 10)
end



--- Reusable OnEnter function for item list entry frames, used in `GetAvailableScrollableListEntryFrame()`.
---@param targetEntryFrame table? Alternate frame to use instead of global `this`.
---@param fromChildElement boolean? This is being called as a result of the mouse entering an associated child element like and item button or checkbox (explained in the comment above `if fromChildElement then...`).
---@param modifierKeyRefresh boolean? Updating because there was a modifier key change.
local function ScrollableListEntryFrame_OnEnter(targetEntryFrame, fromChildElement, modifierKeyRefresh)
	local this = targetEntryFrame or _G.this

	this.bagshuiData.mouseIsOver = true

	if not modifierKeyRefresh then
		-- Coordinate OnEnter with the item slot button so that mousing over the
		-- list entry triggers the hover state for the item slot button.
		-- See `ItemButton_OnEnter()` for the other side.
		if fromChildElement then
			this:LockHighlight()
		elseif this.bagshuiData.checkbox then
			this.bagshuiData.checkbox:GetScript("OnEnter")(this.bagshuiData.checkbox, true)
		elseif this.bagshuiData.itemButton then
			this.bagshuiData.itemButton:GetScript("OnEnter")(this.bagshuiData.itemButton, true)
		end
	end

	if type(this.bagshuiData.listFrame.bagshuiData.entryOnEnterFunc) == "function" then
		this.bagshuiData.listFrame.bagshuiData.entryOnEnterFunc(this)
	end
end


--- Reusable OnLeave function for item list entry frames, used in `GetAvailableScrollableListEntryFrame()`.
---@param targetEntryFrame table? Alternate frame to use instead of global `this`.
---@param fromChildElement boolean? This is being called as a result of the mouse leaving an associated child element like and item button or checkbox (explained in the comment above `if fromItemButton then...`).
local function ScrollableListEntryFrame_OnLeave(targetEntryFrame, fromChildElement)
	local this = targetEntryFrame or _G.this

	this.bagshuiData.mouseIsOver = false

	-- Coordinate OnLeave with the item slot button so that the mouse leaving the
	-- list entry removes the hover state for the item slot button.
	-- See `ItemButton_OnLeave()` for the other side.
	if fromChildElement then
		if not this.bagshuiData.selected then
			this:UnlockHighlight()
		end
	elseif this.bagshuiData.checkbox then
		this.bagshuiData.checkbox:GetScript("OnLeave")(this.bagshuiData.checkbox, true)
	elseif this.bagshuiData.itemButton then
		this.bagshuiData.itemButton:GetScript("OnLeave")(this.bagshuiData.itemButton, true)
	end

	if this.bagshuiData.listFrame and type(this.bagshuiData.listFrame.bagshuiData.entryOnLeaveFunc) == "function" then
		this.bagshuiData.listFrame.bagshuiData.entryOnLeaveFunc(this)
	end
end


--- Call the entry frame OnEnter again when modifier key states change so tooltips can be refreshed if needed.
local function ScrollableListEntryFrame_OnUpdate()
	if not _G.this.bagshuiData.mouseIsOver then
		return
	end
	if
		_G.this.bagshuiData.altKeyState ~= _G.IsAltKeyDown()
		or _G.this.bagshuiData.controlKeyState ~= _G.IsControlKeyDown()
		or _G.this.bagshuiData.shiftKeyState ~= _G.IsShiftKeyDown()
	then
		ScrollableListEntryFrame_OnEnter(_G.this, false, true)
		_G.this.bagshuiData.altKeyState = _G.IsAltKeyDown()
		_G.this.bagshuiData.controlKeyState = _G.IsControlKeyDown()
		_G.this.bagshuiData.shiftKeyState = _G.IsShiftKeyDown()
	end
end


--- Obtain an item list frame, either by reusing an available one or creating new if needed.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param listType BS_UI_SCROLLABLE_LIST_TYPE
---@param entryFrameCreationFunc function? Callback that can be used to modify the entry frame after creation.
---@return table entryFrame
function Ui:GetAvailableScrollableListEntryFrame(listFrame, listType, entryFrameCreationFunc)
	-- This is where we'll store frames so they can be reused.
	-- The stringified pointer to the `entryFrameCreationFunc` is tagged on the end so that
	-- customized frames are stored separately.
	local listFrameTableName = listType .. (entryFrameCreationFunc and tostring(entryFrameCreationFunc) or "")

	-- Ensure frame storage table exists.
	if not self._reusableListFrames[listFrameTableName] then
		self._reusableListFrames[listFrameTableName] = {}
	end

	-- Find a reusable frame if we can.
	local reusableFrameTable = self._reusableListFrames[listFrameTableName]
	assert(reusableFrameTable, "Failed to find entry frame table " .. listFrameTableName .. " (this shouldn't happen!)")
	for i = 1, table.getn(reusableFrameTable) do
		if not reusableFrameTable[i].bagshuiData.listFrame then
			-- Bagshui:PrintDebug("reusing " .. listFrameTableName .. i)
			return reusableFrameTable[i]
		end
	end

	-- Bagshui:PrintDebug("creating new " .. listFrameTableName)

	-- Nothing found - create a new frame.

	local entryFrameNum = table.getn(reusableFrameTable) + 1
	local entryFrameName = "Reusable" .. listType .. 'Frame' .. entryFrameNum
	local entryFrame = _G.CreateFrame("Button", entryFrameName, _G.UIParent)
	entryFrame.bagshuiData = {
		scrollableListEntry = nil,  -- Will be filled by `PopulateScrollableList()`.
		textFrames = {}
	}
	self:SetFrameBackdrop(entryFrame, "NONE")
	entryFrame:SetBackdropColor(0, 0, 0, 0)
	entryFrame:SetHitRectInsets(-1, -1, -1, -1)
	-- Header background.
	entryFrame:SetNormalTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	entryFrame:GetNormalTexture():SetBlendMode("ADD")
	entryFrame:GetNormalTexture():SetAlpha(0)
	entryFrame:GetNormalTexture():SetVertexColor(0.5, 0.5, 0)
	-- Highlight background.
	entryFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	entryFrame:GetHighlightTexture():SetBlendMode("ADD")
	-- Default opacity for mouseover highlight. This also gets reset in `SetScrollableListSelection()`.
	entryFrame:GetHighlightTexture():SetAlpha(0.5)

	local text = self:CreateShadowedFontString(entryFrame)
	entryFrame.bagshuiData.textFrames[1] = text
	text:SetPoint("LEFT", entryFrame, "LEFT", COLUMN_SPACING, 0)
	-- Consumed by `Ui:GetAvailableScrollableListEntryFrame()` to figure out how wide the text frame(s) should be.
	entryFrame.bagshuiData.widthOffset = 5

	-- Coordinate OnEnter/OnLeave with child elements.
	entryFrame:SetScript("OnEnter", ScrollableListEntryFrame_OnEnter)
	entryFrame:SetScript("OnLeave", ScrollableListEntryFrame_OnLeave)
	entryFrame:SetScript("OnUpdate", ScrollableListEntryFrame_OnUpdate)

	if listType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
		-- Item lists require more work.

		local itemButtonMargin = 5 + BsSkin.itemSlotMarginFudge

		-- Create item slot button.
		-- Intentionally using `Ui` here instead of `self` so the name is `ReusableItemListFrame<Number>ItemSlotButton`.
		local itemButton = Ui:CreateItemSlotButton(entryFrameName .. "ItemSlotButton", entryFrame)
		entryFrame.bagshuiData.itemButton = itemButton
		itemButton:SetPoint("LEFT", entryFrame, "LEFT", itemButtonMargin, 0)
		itemButton.bagshuiData.item = {} -- Will be filled by PopulateScrollableList()
		itemButton.bagshuiData.entryFrame = entryFrame
		itemButton.bagshuiData.tooltipAnchor = "ANCHOR_PRESERVE"
		itemButton.bagshuiData.tooltipAnchorPoint = "TOPRIGHT"
		itemButton.bagshuiData.tooltipAnchorToPoint = "TOPLEFT"
		itemButton.bagshuiData.tooltipXOffset = -(3 + BsSkin.tooltipExtraOffset)
		itemButton.bagshuiData.tooltipYOffset = 3
		itemButton.bagshuiData.showBagshuiInfoWithoutAlt = true
		itemButton.bagshuiData.colorBorders = true
		-- Avoid highlighting the item button on click since it's already selecting the row.
		itemButton.bagshuiData.buttonComponents.pushedTexture:SetTexture("")

		-- Move left anchor of label.
		text:SetPoint("LEFT", entryFrame.bagshuiData.itemButton, "RIGHT", itemButtonMargin - 2, 0)
		entryFrame.bagshuiData.widthOffset = entryFrame.bagshuiData.widthOffset + entryFrame.bagshuiData.itemButton:GetWidth() + itemButtonMargin

		-- Set default height and handle future size changes.
		-- Height is updated when the frame is displayed by `ShowScrollableListEntries()`.
		entryFrame:SetScript("OnSizeChanged", function()
			self:SetItemButtonSize(itemButton, _G.this:GetHeight() - 2)
		end)
		entryFrame:SetHeight(30)

	else
		-- All other list types are much simpler.
		-- Set the default height (updated when the frame is displayed by `ShowScrollableListEntries()`).
		entryFrame:SetHeight(18)

		-- Custom events are handled in ScrollableListEntryFrame_OnEnter/OnLeave.
	end

	-- Custom callback.
	if entryFrameCreationFunc then
		entryFrameCreationFunc(entryFrameName, entryFrame, self)
	end

	-- Save to reusable frame list.
	table.insert(reusableFrameTable, entryFrame)

	return entryFrame
end



--- Reusable OnEnter function for item list entry frames, applied in `Ui:UpdateScrollableListEntryFrame()`.
---@param this table? Alternate frame to use instead of global `this`.
---@param fromEntryFrame boolean? This is being called as a result of the mouse entering an associated list entry frame.
local function ScrollableListCheckbox_OnEnter(this, fromEntryFrame)
	this = this or _G.this
	if fromEntryFrame then
		this:LockHighlight()
	else
		this.bagshuiData.entryFrame:GetScript("OnEnter")(this.bagshuiData.entryFrame, true)
	end
end



--- Reusable OnLeave function for item list entry frames, applied in `Ui:UpdateScrollableListEntryFrame()`.
---@param this table? Alternate frame to use instead of global `this`.
---@param fromEntryFrame boolean? This is being called as a result of the mouse leaving an associated list entry frame.
local function ScrollableListCheckbox_OnLeave(this, fromEntryFrame)
	this = this or _G.this
	if fromEntryFrame then
		this:UnlockHighlight()
	else
		this.bagshuiData.entryFrame:GetScript("OnLeave")(this.bagshuiData.entryFrame, true)
	end
end



--- Reusable OnClick function for item list entry frames, applied in `Ui:UpdateScrollableListEntryFrame()`.
local ScrollableListCheckbox_OnClick


--- Add checkboxes and header styling to entries.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entryFrame table List entry frame from `Ui:GetAvailableScrollableListEntryFrame()`.
function Ui:UpdateScrollableListEntryFrame(listFrame, entryFrame)
	-- Special styling isn't currently supported for item lists.
	if listFrame.bagshuiData.scrollableListType == BS_UI_SCROLLABLE_LIST_TYPE.ITEM then
		return
	end

	-- Grab the default text color so we can reapply it in when frames switch
	-- between header and non-header mode.
	if not listFrame.bagshuiData.textColorR then
		listFrame.bagshuiData.textColorR, listFrame.bagshuiData.textColorG, listFrame.bagshuiData.textColorB, listFrame.bagshuiData.textColorA = entryFrame.bagshuiData.textFrames[1]:GetTextColor()
	end

	if type(ScrollableListCheckbox_OnClick) ~= "function" then
		-- Reusable function for checkbox OnClick.
		function ScrollableListCheckbox_OnClick()
			self:SetScrollableListSelection(
				_G.this.bagshuiData.listFrame,
				_G.this.bagshuiData.entryFrame
			)
		end
	end


	if
		listFrame.bagshuiData.checkboxes
		and (
			not entryFrame.bagshuiData.isHeader
			or (
				entryFrame.bagshuiData.isHeader
				and listFrame.bagshuiData.headerCheckboxes ~= false
			)
		)
	then
		-- Create checkbox.
		if not entryFrame.bagshuiData.checkbox then
			entryFrame.bagshuiData.checkbox = self:CreateCheckbox(
				entryFrame:GetName() .. "Checkbox",
				entryFrame,  -- Parent.
				nil,  -- Template.
				nil,  -- Text.
				ScrollableListCheckbox_OnClick
			)
			entryFrame.bagshuiData.checkbox.bagshuiData.listFrame = listFrame
			entryFrame.bagshuiData.checkbox.bagshuiData.entryFrame = entryFrame
			entryFrame.bagshuiData.checkbox:SetScript("OnEnter", ScrollableListCheckbox_OnEnter)
			entryFrame.bagshuiData.checkbox:SetScript("OnLeave", ScrollableListCheckbox_OnLeave)
			entryFrame.bagshuiData.checkbox:Hide()
		end

		-- Display checkbox.
		if not entryFrame.bagshuiData.checkbox:IsShown() then
			entryFrame.bagshuiData.checkbox:Show()
			entryFrame.bagshuiData.checkbox:SetHeight(entryFrame:GetHeight() + 2)
			entryFrame.bagshuiData.checkbox:SetWidth(entryFrame:GetHeight() + 2)
		end

		-- Update checkbox and text position.
		entryFrame.bagshuiData.checkbox:ClearAllPoints()

		if entryFrame.bagshuiData.isHeader then
			-- Checkboxes for headers are positioned on the right.
			-- entryFrame.bagshuiData.checkbox:SetPoint("RIGHT", entryFrame, "RIGHT", 0, 0)
			self:SetPoint(entryFrame.bagshuiData.checkbox, "RIGHT", entryFrame, "RIGHT", 0, nil)
			entryFrame.bagshuiData.textFrames[1]:SetPoint("LEFT", entryFrame, "LEFT", COLUMN_SPACING, 0)
			entryFrame.bagshuiData.textFrames[1]:SetPoint("RIGHT", entryFrame.bagshuiData.checkbox, "LEFT", -COLUMN_SPACING, 0)
		else
			entryFrame.bagshuiData.checkbox:SetPoint("LEFT", entryFrame, "LEFT", 0, 0)
			-- self:SetPoint(entryFrame.bagshuiData.checkbox, "LEFT", entryFrame, "LEFT", 0, nil)
			entryFrame.bagshuiData.textFrames[1]:SetPoint("LEFT", entryFrame.bagshuiData.checkbox, "RIGHT", 0, 0)
			entryFrame.bagshuiData.textFrames[1]:SetPoint("RIGHT", entryFrame, "RIGHT", -COLUMN_SPACING, 0)
		end

	elseif entryFrame.bagshuiData.checkbox then
		entryFrame.bagshuiData.checkbox:Hide()
		entryFrame.bagshuiData.textFrames[1]:SetPoint("LEFT", entryFrame, "LEFT", COLUMN_SPACING, 0)
		entryFrame.bagshuiData.textFrames[1]:SetPoint("RIGHT", entryFrame, "RIGHT", -COLUMN_SPACING, 0)
	end


	-- Apply header or normal styling.
	if entryFrame.bagshuiData.isHeader then
		-- Display background.
		entryFrame:GetNormalTexture():SetAlpha(0.7)

		-- Change fonts.
		if not listFrame.bagshuiData.headerFontPath then
			entryFrame.bagshuiData.textFrames[1]:SetFontObject(listFrame.bagshuiData.headerFont)
			listFrame.bagshuiData.headerFontPath, listFrame.bagshuiData.headerFontSize, listFrame.bagshuiData.headerFontStyle = entryFrame.bagshuiData.textFrames[1]:GetFont()
			listFrame.bagshuiData.headerFontSize = math.floor(listFrame.bagshuiData.headerFontSize) + 2
			listFrame.bagshuiData.headerTextColorR, listFrame.bagshuiData.headerTextColorG, listFrame.bagshuiData.headerTextColorB, listFrame.bagshuiData.headerTextColorA = entryFrame.bagshuiData.textFrames[1]:GetTextColor()
		end
		entryFrame.bagshuiData.textFrames[1]:SetFont(listFrame.bagshuiData.headerFontPath, listFrame.bagshuiData.headerFontSize, listFrame.bagshuiData.headerFontStyle)
		entryFrame.bagshuiData.textFrames[1]:SetTextColor(listFrame.bagshuiData.headerTextColorR, listFrame.bagshuiData.headerTextColorG, listFrame.bagshuiData.headerTextColorB, listFrame.bagshuiData.headerTextColorA)
	else
		entryFrame.bagshuiData.textFrames[1]:SetFontObject(listFrame.bagshuiData.font)
		entryFrame.bagshuiData.textFrames[1]:SetTextColor(listFrame.bagshuiData.textColorR, listFrame.bagshuiData.textColorG, listFrame.bagshuiData.textColorB, listFrame.bagshuiData.textColorA)
		entryFrame:GetNormalTexture():SetAlpha(0)
	end


end



--- Select/deselect an item in a scrollable list.
--- Two properties detailing the current selection state are exposed on the list's
--- `bagshuiData` table: `selectedEntries` and `selectedEntry`. See the comments
--- in `Ui:CreateScrollableList()` for more information.
--- This could probably use a refactor at some point -- it's gotten messy since
--- multi-select was added and there should be a way to pass a list of multiple
--- entries to select/deselect.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entryToSelect any? `entryFrame` UI element (or an element within one) *or* list entry value to select *or* nil to deselect.
---@param selectionState boolean? Force `entryToSelect` to be selected or deselected.
---@param scrollTo boolean? Scroll the list to the selected element when true.
function Ui:SetScrollableListSelection(listFrame, entryToSelect, selectionState, scrollTo)

	-- Used to preserve selection.
	listFrame.bagshuiData.lastSelection = entryToSelect

	-- Consumed by `Ui:SetScrollableListEntrySelectionState()` to determine whether
	-- things should be reset.
	listFrame.bagshuiData._setScrollableListSelection_InProgress = true

	local entryFrameToSelect

	-- Flag to track when the selection was set by a user click as opposed to a programmatic value
	-- so that we know whether to toggle selection if Control is down and the frame is already selected.
	local entryToSelectWasFrame = false

	
	local forceSelect = (selectionState == true)
	local forceDeselect = (selectionState == false)

	-- Sometimes we need to deselect everything.
	-- Primarily for multi-select situations where the clicked entry was deselected
	-- and a range select was then initiated.
	local deselect = false

	-- Invert the selection state instead of just selecting or deselecting.
	local toggleSelection = (
		_G.IsControlKeyDown()
		or (
			listFrame.bagshuiData.checkboxes
			and not _G.IsShiftKeyDown()
		)
	)


	-- Figure out what we need to do.
	if type(entryToSelect) == "table" and entryToSelect.GetParent then
		-- entryToSelect is a UI element: Walk upwards to find the actual entry frame if this isn't one.
		entryFrameToSelect = entryToSelect
		while not entryFrameToSelect.bagshuiData.scrollableListEntry and entryFrameToSelect ~= _G.UIParent do
			entryFrameToSelect = entryFrameToSelect:GetParent()
		end
		entryToSelectWasFrame = true

		-- When true, the shift-key range selection tracking will be reset.
		local updateSelectionRangeTracking = false

		if
			(
				listFrame.bagshuiData.multiSelect
				and toggleSelection
			)
			or forceSelect
			or forceDeselect
		then
			updateSelectionRangeTracking = true
			-- Nothing else to do here, just preserve the existing selection.

		elseif listFrame.bagshuiData.multiSelect and _G.IsShiftKeyDown() then
			if listFrame.bagshuiData.lastUserSelectionAnchorStart then
				-- Deselect the most recent set of shift-selected frames, if applicable.
				-- This is what allows the behavior of decreasing or reversing the selection
				-- range from the previous anchor.
				if listFrame.bagshuiData.lastUserSelectionAnchorEnd then
					self:SetScrollableListSelectionRange(
						listFrame,
						listFrame.bagshuiData.lastUserSelectionAnchorStart,
						listFrame.bagshuiData.lastUserSelectionAnchorEnd,
						nil
					)
				end

				-- When the last action was to deselect, a shift+click range
				-- should deselect all frames in the range.
				if not listFrame.bagshuiData.lastUserSelectionAnchorWasSelected then
					deselect = true
				end

				-- Select the current range of frames -- this updates the `listFrame.bagshuiData.selectedEntries` table.
				-- Highlights will be applied updated the "Set selection" loop below.
				self:SetScrollableListSelectionRange(
					listFrame, entryFrameToSelect.bagshuiData.sequentialFrameNum,
					listFrame.bagshuiData.lastUserSelectionAnchorStart,
					not deselect
				)

				-- This will be used on the next call to deselect the previous shift-selected range, if applicable.
				listFrame.bagshuiData.lastUserSelectionAnchorEnd = entryFrameToSelect.bagshuiData.sequentialFrameNum

			end

		else
			updateSelectionRangeTracking = true
			-- List was not multi-select or Control/Shift were not pressed, so clear the existing selection.
			BsUtil.TableClear(listFrame.bagshuiData.selectedEntries)

		end

		-- Change the start anchor and clear the end anchor so shift-selection behavior will reset.
		if updateSelectionRangeTracking then
			listFrame.bagshuiData.lastUserSelectionAnchorStart = entryFrameToSelect.bagshuiData.sequentialFrameNum
			listFrame.bagshuiData.lastUserSelectionAnchorEnd = nil
		end

		-- Track the most recently-performed action so we know whether the next
		-- shift+click range should select or deselect.
		listFrame.bagshuiData.lastUserSelectionAnchorWasSelected = (not entryFrameToSelect.bagshuiData.selected or not _G.IsShiftKeyDown())

	else
		-- When either nil or the value of an entry within the list is provided,
		-- multi-select will not be an option and the existing selection will be cleared,
		-- unless the selection state is being forced.
		if not (forceSelect or forceDeselect) then
			BsUtil.TableClear(listFrame.bagshuiData.selectedEntries)
		end

		-- This was a programmatic value, not a frame clicked by the user.
		listFrame.bagshuiData.lastUserSelectionAnchorStart = nil
		listFrame.bagshuiData.lastUserSelectionAnchorEnd = nil

		-- entryToSelect was not a frame, so we need to -- find the entry frame that owns this value.
		if entryToSelect then
			for _, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
				if entryFrame.bagshuiData.scrollableListEntry == entryToSelect then
					entryFrameToSelect = entryFrame
					break
				end
			end
		end
	end

	-- Couldn't find the right thing to select.
	if entryToSelect and not entryFrameToSelect then
		Bagshui:PrintError("Failed to find selection for entry " .. tostring(entryToSelect) .. " -- this shouldn't happen!")
		return
	end


	-- Tracking variables for managing button state.

	local readOnly = false  -- One or more read-only entries are selected.
	local firstEntry = false  -- The selection includes the first entry.
	local lastEntry = false  -- The selection includes the last entry.
	local numEntries = table.getn(listFrame.bagshuiData.entryFrames)

	-- Set selection.
	for listPosition, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		if
			(
				(
					-- This is the frame being selected.
					(entryFrame == entryFrameToSelect)
					-- Frame was already selected and selection is preserved.
					or listFrame.bagshuiData.selectedEntries[entryFrame.bagshuiData.scrollableListEntry]
				)
				-- Frame was previously selected and control key is held or in checkbox mode -- toggle selection state.
				and not (
					(entryFrame == entryFrameToSelect)
					and listFrame.bagshuiData.multiSelect
					and entryToSelectWasFrame
					and entryFrame.bagshuiData.selected
					and toggleSelection
				)
				and not deselect
			)
			or (
				(entryFrame == entryFrameToSelect)
				and forceSelect
				and not forceDeselect
			)

		then
			listFrame.bagshuiData.selectedEntry = entryFrame.bagshuiData.scrollableListEntry
			self:SetScrollableListEntrySelectionState(listFrame, entryFrame, true)

			if
				type(entryFrame.bagshuiData.scrollableListEntryInfo) == "table"
				and entryFrame.bagshuiData.scrollableListEntryInfo.readOnly
			then
				readOnly = true
			end

			if listPosition == 1 then
				firstEntry = true
			elseif listPosition == numEntries then
				lastEntry = true
			end

		else
			self:SetScrollableListEntrySelectionState(listFrame, entryFrame, false)
		end


		-- When a header is selected/deselected in a multiSelect list, set the
		-- same state for all children. Since frames are processed in order,
		-- within SetScrollableListSelection(), changes made here to
		-- listFrame.bagshuiData.selectedEntries will be seen by the child frames
		-- once they're reached.
		if
			listFrame.bagshuiData.hasHeaders
			and entryFrameToSelect
			and entryFrame == entryFrameToSelect
			and listFrame.bagshuiData.multiSelect
			and listFrame.bagshuiData.headerCheckboxes ~= false
			and entryFrameToSelect.bagshuiData.isHeader
		then
			-- Scan forward until we reach the next header frame.
			-- Within this range are the entry frames that belong to the current header.
			for child = listPosition + 1, table.getn(listFrame.bagshuiData.entryFrames) do
				if listFrame.bagshuiData.entryFrames[child].bagshuiData.isHeader then
					break
				end
				listFrame.bagshuiData.selectedEntries[
					listFrame.bagshuiData.entryFrames[child].bagshuiData.scrollableListEntry
				] = listFrame.bagshuiData.selectedEntries[entryFrame.bagshuiData.scrollableListEntry]
			end
		end

	end


	-- Sync header selection state with that of children.
	local childCount = 0
	local selectedChildren = 0
	local lastHeader
	for listPosition, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		-- Increment child count.
		if lastHeader and not entryFrame.bagshuiData.isHeader then
			childCount = childCount + 1
			if entryFrame.bagshuiData.selected then
				selectedChildren = selectedChildren + 1
			end
		end

		-- Set header selection state.
		if
			lastHeader
			and (
				-- This is the next header.
				(
					entryFrame ~= lastHeader
					and entryFrame.bagshuiData.isHeader
					and childCount > 0
				)
				-- We've reached the end of the list.
				or listPosition == table.getn(listFrame.bagshuiData.entryFrames)
			)
		then
			self:SetScrollableListEntrySelectionState(listFrame, lastHeader, (selectedChildren >= childCount))
		end

		-- Reset at next header.
		if entryFrame.bagshuiData.isHeader then
			childCount = 0
			selectedChildren = 0
			lastHeader = entryFrame
		end
	end


	local numSelectedEntries = BsUtil.TrueTableSize(listFrame.bagshuiData.selectedEntries)

	-- The `selectedEntry` property is a convenience for when there is only one entry selected.
	if numSelectedEntries == 1 then
		for selectedEntry, _ in pairs(listFrame.bagshuiData.selectedEntries) do
			listFrame.bagshuiData.selectedEntry = selectedEntry
		end
	else
		listFrame.bagshuiData.selectedEntry = nil
	end

	-- Enable/disable buttons based on special properties.
	local enableDisableFunction

	for _, button in pairs(listFrame.bagshuiData.buttons) do
		enableDisableFunction = "Enable"

		-- Disable buttons for special scenarios:
		-- - Nothing is selected and button should only be enabled when something is selected.
		-- - First/last entries.
		-- - List entry has a readOnly property and button is flagged for read-only disable.
		-- - Button is flagged to stay disabled.
		if
			(numSelectedEntries < 1 and button.bagshuiData.scrollableList_DisableIfNothingSelected)
			or
			(numSelectedEntries > 1 and button.bagshuiData.scrollableList_DisableIfMultipleSelected)
			or
			(firstEntry and button.bagshuiData.scrollableList_DisableIfFirstEntrySelected)
			or
			(lastEntry and button.bagshuiData.scrollableList_DisableIfLastEntrySelected)
			or
			(readOnly and button.bagshuiData.scrollableList_DisableIfReadOnly)
			or
			(numEntries == 0 and button.bagshuiData.scrollableList_DisableIfEmptyList)
			or
			(type(button.bagshuiData.scrollableList_DisableFunc) == "function" and button.bagshuiData.scrollableList_DisableFunc(listFrame.bagshuiData.selectedEntries))
			or
			button.bagshuiData.scrollableList_Disable
		then
			enableDisableFunction = "Disable"
		end

		button[enableDisableFunction](button)
	end

	-- Done with internal updates and getting ready to invoke callback.
	listFrame.bagshuiData._setScrollableListSelection_InProgress = false

	-- Invoke callback.
	-- Need to track whether we've just called it to prevent stack overflow.
	if
		not listFrame.bagshuiData.onSelectionChangedFunc_Called
		and type(listFrame.bagshuiData.onSelectionChangedFunc) == "function"
	then
		listFrame.bagshuiData.onSelectionChangedFunc_Called = true
		listFrame.bagshuiData.onSelectionChangedFunc(listFrame)
		listFrame.bagshuiData.onSelectionChangedFunc_Called = false
	end

	-- Scroll to selected item if requested
	if scrollTo then
		-- Need a little delay for the ScrollFrame to know things have changed
		Bagshui:QueueClassCallback(
			self,
			self.ScrollToListEntry,
			0.005,
			false,
			listFrame,
			entryFrameToSelect
		)
	end

end



--- Helper for `Ui:SetScrollableListSelection()` to update the selection state of an entry frame.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entryFrame table Frame within the list that should be updated.
---@param select boolean? `true` to select, 'false' or `nil` to deselect.
function Ui:SetScrollableListEntrySelectionState(listFrame, entryFrame, select)
	if select then
		entryFrame.bagshuiData.selected = true
		listFrame.bagshuiData.selectedEntries[entryFrame.bagshuiData.scrollableListEntry] = true
		entryFrame:GetHighlightTexture():SetAlpha(1)
		entryFrame:LockHighlight()
	else
		entryFrame.bagshuiData.selected = false
		listFrame.bagshuiData.selectedEntries[entryFrame.bagshuiData.scrollableListEntry] = nil
		entryFrame:UnlockHighlight()
		entryFrame:GetHighlightTexture():SetAlpha(0.5)
	end

	-- Sync checkbox state.
	if entryFrame.bagshuiData.checkbox then
		if listFrame.bagshuiData._setScrollableListSelection_InProgress then
			entryFrame.bagshuiData.checkbox:Enable()
		end
		entryFrame.bagshuiData.checkbox:SetChecked(entryFrame.bagshuiData.selected)
	end
end



--- Helper for `Ui:SetScrollableListSelection()` to select or deselect a range of frames.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param startNum number First frame to select or deselect. Can be a higher OR lower number than `endNum`.
---@param endNum number Last frame to select or deselect. Can be a higher OR lower number than `startNum`.
---@param select boolean? `true` to select, 'false' or `nil` to deselect.
function Ui:SetScrollableListSelectionRange(listFrame, startNum, endNum, select)
	for i = startNum, endNum, (startNum < endNum and 1 or -1) do
		listFrame.bagshuiData.selectedEntries[listFrame.bagshuiData.entryFrames[i].bagshuiData.scrollableListEntry] = (select == true) or nil
	end
end



--- Scroll the ScrollFrame so the currently selected list item is visible.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entry any Value from the list's `bagshuiData.entries` array to scroll to, OR frame to scroll to.
function Ui:ScrollToListEntry(listFrame, entry)

	-- Make sure there's something selected.
	if not listFrame.bagshuiData.selectedEntry then
		return
	end

	-- Find the frame for the selected entry.
	local frameToShow
	for i, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		if entryFrame.bagshuiData.scrollableListEntry == entry or entryFrame == entry then
			frameToShow = i
		end
	end

	-- Couldn't find it - just bail.
	if not frameToShow then
		return
	end

	-- Find out how much we can scroll.
	local scrollRange = listFrame.bagshuiData.scrollFrame:GetVerticalScrollRange()

	-- There needs to be scrolling available.
	if scrollRange == 0 then
		return
	end

	-- Calculate where we need to scroll to.
	-- There is probably a better/more accurate way to do this, but it seems to work.
	local scrollHeight = listFrame.bagshuiData.scrollFrame:GetHeight()
	local entryFrameHeight = listFrame.bagshuiData.rowHeight + listFrame.bagshuiData.rowSpacing
	local entryFrameTop = (entryFrameHeight * (frameToShow - 1))

	-- Start by assuming we're at the last frame, then calculate the correct location if needed.
	local verticalScroll = scrollRange
	if frameToShow < table.getn(listFrame.bagshuiData.entryFrames) then
		verticalScroll = (entryFrameTop / (scrollHeight + scrollRange)) * scrollRange
	end

	-- Do the scroll.
	listFrame.bagshuiData.scrollFrame:SetVerticalScroll(verticalScroll)
end



--- Put column header sort indicators in the correct state.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
function Ui:UpdateScrollableListColumnHeaders(listFrame)
	if not listFrame.bagshuiData.entryColumns then
		return
	end

	for i, col in ipairs(listFrame.bagshuiData.entryColumns) do
		if listFrame.bagshuiData.columnHeaders[col.field] then
			local columnFrame = listFrame.bagshuiData.columnHeaders[col.field]
			local scrollFrame = listFrame.bagshuiData.scrollFrame

			if col.currentSortOrder then
				-- This is the colum we're sorting by, so show the sort indicator.

				self:SetIconButtonTexture(columnFrame, "UI\\SortColumn" .. (col.currentSortOrder == "ASC" and "Asc" or "Desc"))

				-- Make sure all textures are sized and positioned correctly.
				for _, textureName in ipairs(BS_UI_BUTTON_TEXTURES) do
					local texture = columnFrame["Get" .. textureName .. "Texture"](columnFrame)
					if texture then
						texture:ClearAllPoints()
						-- Manually position just to the right of the column header.
						texture:SetPoint("LEFT", columnFrame, "LEFT", columnFrame.bagshuiData.text:GetStringWidth() + 8, 0)
						texture:SetWidth(scrollFrame.bagshuiData.headerHeight - 2)
						texture:SetHeight(scrollFrame.bagshuiData.headerHeight - 2)
					end
				end

			else
				-- Hide the sort indicator for all other columns by removing the texture.
				self:SetIconButtonTexture(columnFrame, nil)
			end

		end
	end
end



--- Mark all scrollable list entry frames in given array as reusable.
--- Reusing frames is necessary because they can't be destroyed.
---@param frameList table[] Array of scrollable list entry frames.
function Ui:ReleaseScrollableListFrames(frameList)
	if type(frameList) ~= "table" then
		return
	end
	for i = 1, table.getn(frameList) do
		if frameList[i].bagshuiData and frameList[i].Hide then
			frameList[i].bagshuiData.listFrame = nil  -- This is the primary marker of reusability.
			frameList[i].bagshuiData.scrollableListEntry = nil
			frameList[i]:Hide()
			frameList[i]:ClearAllPoints()
			frameList[i]:SetParent(_G.UIParent)
		end
	end
end



--- Remove an entry from a scrollable list.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entry any Value from the list's `bagshuiData.entries` array to remove.
function Ui:ScrollableListRemove(listFrame, entry)
	if not entry or string.len(tostring(entry)) == 0 then
		return
	end

	-- Make sure we're working with a valid list.
	self:CheckScrollableListInitialized(listFrame)

	-- Find the location of the entry we're removing.
	local arrayPosition = BsUtil.TableContainsValue(listFrame.bagshuiData.entries, entry)

	-- Remove it and refresh the UI.
	table.remove(listFrame.bagshuiData.entries, arrayPosition)
	self:PopulateScrollableList(listFrame, nil, true, false)

	-- Select the previous entry in the list.
	if arrayPosition > 1 then
		arrayPosition = arrayPosition - 1
	end
	if arrayPosition > table.getn(listFrame.bagshuiData.entries) then
		arrayPosition = table.getn(listFrame.bagshuiData.entries)
	end
	self:SetScrollableListSelection(listFrame, listFrame.bagshuiData.entries[arrayPosition])
end



--- Move an entry in a scrollable list up or down.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param entry any Value from the list's `bagshuiData.entries` array to move.
---@param direction string BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP or BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN
function Ui:ScrollableListMove(listFrame, entry, direction)
	if not entry or string.len(tostring(entry)) == 0 then
		return
	end
	if direction ~= BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP and direction ~= BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN then
		return
	end

	-- Make sure we're working with a valid list.
	self:CheckScrollableListInitialized(listFrame)

	-- Find the location of the entry we're moving.
	local arrayPosition = BsUtil.TableContainsValue(listFrame.bagshuiData.entries, entry)

	-- Make sure it's not already at the top/bottom when being moved up/down.
	if
		(direction == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP and arrayPosition == 1)
		or
		(direction == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.DOWN and arrayPosition == table.getn(listFrame.bagshuiData.entries))
	then
		return
	end

	-- Move it, refresh the UI, and re-select it in the new position..
	local newPosition = direction == BS_UI_SCROLLABLE_LIST_BUTTON_NAME.UP and arrayPosition - 1 or arrayPosition + 1
	table.remove(listFrame.bagshuiData.entries, arrayPosition)
	table.insert(listFrame.bagshuiData.entries, newPosition, entry)
	self:PopulateScrollableList(listFrame, nil, true, false)
	self:SetScrollableListSelection(listFrame, entry, nil, true)
end



--- Prompt for item IDs, links, or item strings to add to a scrollable item list.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
function Ui:ItemListPromptForNew(listFrame)
	local dialogName = "itemListNew"

	if not self.dialogProperties[dialogName] then
		self:AddMultilineDialog(
			dialogName,
			{
				prompt = L.ItemList_NewPrompt,
				button1 = L.Add,
				button1DisableOnEmptyText = true,
				OnAccept = function(dialog)
					self:ItemListAdd(dialog.data.listFrame, dialog:GetText())
				end
			}
		)
	end

	local dialog = self:ShowDialog(dialogName, nil, nil, nil, nil, self:FindWindowFrame(listFrame:GetParent()))

	-- Pass stuff to dialog callbacks.
	if dialog then
		dialog.data.listFrame = listFrame
	end
end



--- Display a read-only dialog containing the IDs of items in an item-type list.
--- There will be one ID per line followed by a Lua-style comment with the name:
--- ```
--- 8932    -- Alterac Swiss
--- 13935   -- Baked Salmon
--- ```
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
function Ui:ItemListOpenCopyDialog(listFrame)
	local dialogName = "itemListCopy"

	if not self.dialogProperties[dialogName] then
		self:AddMultilineDialog(
			dialogName,
			{
				prompt = L.ItemList_CopyPrompt,
				readOnly = true,
				button1 = "",
				button2 = L.Close,
			}
		)
	end

	local items = ""

	for _, entryFrame in ipairs(listFrame.bagshuiData.entryFrames) do
		local itemInfo = entryFrame.bagshuiData.itemButton.bagshuiData.item
		items = items
			.. tostring(itemInfo.id)
			.. string.rep(" ", 8 - string.len(tostring(itemInfo.id)))
			..  "-- "
			.. tostring(itemInfo.name)
			.. BS_NEWLINE
	end
	items = string.sub(items, 1, -2)  -- Remove trailing newline.

	self:ShowDialog(dialogName, nil, nil, nil, items, self:FindWindowFrame(listFrame:GetParent()))
end



--- Add the given item to the specified scrollable item list.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param itemList string|number One or more item IDs, links, or itemStrings. Multiple should be separated by whitespace, commas, semicolons, ore newlines.
function Ui:ItemListAdd(listFrame, itemList)
	if
		not itemList
		or not listFrame.bagshuiData
		or listFrame.bagshuiData.readOnly
	then
		return
	end

	-- Make sure we're working with a valid list.
	self:CheckScrollableListInitialized(listFrame, BS_UI_SCROLLABLE_LIST_TYPE.ITEM)

	-- Remove comments.
	itemList = string.gsub(itemList, "%-%-.-\n", BS_NEWLINE)  -- Per-line.
	itemList = string.gsub(itemList, "%-%-.-$", "")  -- Very last line. 

	-- Break up the item list.
	local items = BsUtil.Split(itemList, "[%s,;\n]+", true)

	-- Add all items to the list.
	for _, item in ipairs(items) do

		-- Chat links pasted from databases will have a string like this:
		-- /script DEFAULT_CHAT_FRAME:AddMessage("\124cffffffff\124Hitem:8932::::::::60:::::\124h[Alterac Swiss]\124h\124r");
		-- We need to force the \124 into a pipe so it's parsed as an item.
		item = string.gsub(item, "\\124", "|")

		-- Parse out an item's ID from an item link.
		local _, _, itemNum = string.find(item, "item:(%d+)")

		-- Grab the first number in the provided string (or the item ID we found above).
		item = BsUtil.ExtractNumber(itemNum or item)

		-- Add to list.
		if item then
			BsUtil.TableInsertArrayItemUnique(listFrame.bagshuiData.entries, item)
		end
	end

	-- Refresh UI.
	self:PopulateScrollableList(listFrame, nil, true)
end



--- Ensure the supposed scrollable list frame passed to various functions is a valid Bagshui scrollable list frame.
---@param listFrame table `listFrame` return value from `Ui:CreateScrollableList()`.
---@param listType BS_UI_SCROLLABLE_LIST_TYPE? `listFrame` must be of this type or an error will be thrown.
function Ui:CheckScrollableListInitialized(listFrame, listType)
	assert(type(listFrame) == "table", "Ui:CheckScrollableListInitialized():  listFrame is not a table")
	assert(listFrame.GetName, "Ui:CheckScrollableListInitialized(): listFrame is not a frame")
	local frameName = listFrame:GetName() or "<Unnamed Frame>"
	assert(listFrame.bagshuiData, frameName .. " is not a Bagshui frame")
	assert(listFrame.bagshuiData.entries, frameName .. " is not a Bagshui list frame")
	assert(listFrame.bagshuiData.scrollableListType, frameName .. " is not a Bagshui scrollable list frame")
	if listType then
		assert(listFrame.bagshuiData.scrollableListType == listType, frameName .. " is not a Bagshui scrollable " .. tostring(listType) .. " list frame")
	end
end


end)