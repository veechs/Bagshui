-- Bagshui Inventory Prototype: Edit Mode
-- Most Edit Mode related things live here, although there are a few bits in
-- OnClick/OnEnter/OnLeave events for item buttons and groups.

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory


--- Enter or exit Edit Mode.
---@param enable boolean
function Inventory:SetEditMode(enable)
	self:ClearEditModeCursor()
	self:ManagePendingGroupAssignments(nil, false)  -- Discard any pending group assignments.
	self.highlightItemsInContainerId = nil
	self.highlightItemsInContainerLocked = nil
	self.editMode = (enable == true)
	self:ClearSearch()
	self:UpdateEditModeUiStateBasedOnCursor()
	self.windowUpdateNeeded = true
	self.forceResort = true
	self:Update()
end



--- Turn Edit Mode on if it's off and vice versa.
function Inventory:ToggleEditMode()
	self:SetEditMode(not self.editMode)
end



--- Trigger window update only if Edit Mode is enabled.
---@param forceResort boolean?
---@param itemSlotColorsOnly boolean?
function Inventory:EditModeWindowUpdate(forceResort, itemSlotColorsOnly)
	if not self.editMode then
		return
	end

	if itemSlotColorsOnly and forceResort ~= true then
		-- High-performance window redraw to update category highlighting.
		-- Using normal Update() is way too slow to keep pace with mouse movements.
		self:UpdateItemSlotColors()
	else
		self.cacheUpdateNeeded = false
		self.windowUpdateNeeded = true
		self.forceResort = (forceResort == true)
		self.lastCategorizeItems = 0  -- Force clearing errors in `Inventory:CategorizeItems()`.
		self:Update()
		Bagshui:RaiseEvent("BAGSHUI_INVENTORY_EDIT_MODE_UPDATE")
	end
end



--- Since we're faking cursor attachment via a tooltip, we need a way to determine
--- whether something has been picked up.
---@return boolean # true if there's an item on the cursor in Edit Mode.
function Inventory:EditModeCursorHasItem()
	return (self.editMode and self.editState.cursorItem ~= nil)
end



-- Intelligently display the Edit Mode cursor if there's an item to be held.
function Inventory:ShowEditModeCursor()
	if
		self.editMode
		and self.editState.cursorItem ~= nil
		and self.editState.cursorTooltipTitle ~= nil
	then
		-- This is a quick hack to enable Edit Mode cursor clearing on Escape press.
		-- See Bagshui:CloseAllWindows() for details.
		self.uiFrame.bagshuiData.hasCursorItem = self

		local cursorTooltip = BsCursorTooltip
		cursorTooltip:SetOwner(self.uiFrame, "ANCHOR_CURSOR")
		cursorTooltip:ClearLines()

		-- Add text.
		cursorTooltip:AddLine(self.editState.cursorTooltipTitle)
		if self.editState.cursorTooltipText then
			cursorTooltip:AddLine(self.editState.cursorTooltipText)
		end

		-- Display correct icon.
		local cursorTooltipIcon = "Icons\\Question"
		if self.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.GROUP then
			cursorTooltipIcon = "Icons\\Group"
		elseif self.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.CATEGORY then
			cursorTooltipIcon = "Icons\\Category"
		elseif self.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.ITEM then
			if self.editState.cursorItem.emptySlot == 1 then
				cursorTooltipIcon = self:GetEmptySlotTexture(self.editState.cursorItem)
			else
				cursorTooltipIcon = self.editState.cursorItem.texture
			end
		end
		cursorTooltip.bagshuiData.texture1:SetTexture(BsUtil.GetFullTexturePath(cursorTooltipIcon))

		-- Display the tooltip so it will calculate its initial width based on the text.
		cursorTooltip:Show()

		-- Adjust width to account for icon.
		local currentWidth = cursorTooltip:GetWidth()
		local firstLineWidthWithIcon = cursorTooltip.bagshuiData.textLeft1:GetStringWidth() + 36
		if firstLineWidthWithIcon > currentWidth then
			cursorTooltip:SetWidth(firstLineWidthWithIcon)
		end

		-- Make the cursor glow.
		_G.SetCursor("CAST_CURSOR")

		-- Make sure tooltips aren't fighting.
		BsInfoTooltip:Hide()

		self:UpdateEditModeUiStateBasedOnCursor()
	end
end



--- Hide the Edit Mode cursor tooltip without clearing it (used when the cursor
--- leaves the inventory window).
function Inventory:HideEditModeCursor()
	BsCursorTooltip:Hide()
	_G.SetCursor(nil)
end



--- Drop whatever the Edit Mode cursor is carrying without doing anything with it.
function Inventory:ClearEditModeCursor()
	if self.editState.cursorItem ~= nil then
		-- This is part of a quick hack to enable Edit Mode cursor clearing on Escape press.
		-- See Bagshui:CloseAllWindows() for details.
		self.uiFrame.bagshuiData.hasCursorItem = nil

		-- Reset all editState variables.
		self.editState.cursorItem = nil
		self.editState.cursorItemType = nil
		self.editState.cursorTooltipTitle = nil
		self.editState.cursorTooltipText = nil

		self.editState.highlightCategory = nil
		self.editState.highlightItem = nil

		self:HideEditModeCursor()
		self:UpdateEditModeUiStateBasedOnCursor()
		self:EditModeWindowUpdate()
	end
end



--- Make changes to UI based on picking up/putting down elements.
--- - Set the correct text on group move targets based on what's on the cursor.
--- - Enable/disable group/item slot interactivity.
function Inventory:UpdateEditModeUiStateBasedOnCursor()
	local cursorHasItem = self:EditModeCursorHasItem()
	local cursorItemIsGroup = (cursorHasItem and self.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.GROUP)

	-- Update group move target text and colors.
	local groupMoveTargetText = cursorItemIsGroup and "•" or "+"
	for _, groupMoveTarget in ipairs(self.ui.frames.groupMoveTargets) do
		groupMoveTarget.bagshuiData.text:SetText(groupMoveTargetText)
		self.ui:SetGroupColors(groupMoveTarget.bagshuiData.button, false)
	end

	-- Enable/disable group interactivity.
	for _, group in ipairs(self.ui.frames.groups) do
		group:Enable()
	end

	-- Item slots should NOT get mouse input when there's something on the cursor,
	-- since we always want it directed to the group.
	for _, itemSlotButton in pairs(self.ui.buttons.itemSlots) do
		itemSlotButton:EnableMouse(not cursorHasItem)
	end

end



--- Build the correct text for the Edit Mode cursor tooltip.
---@param objectName string
---@param objectType string
---@return string tooltipTitle
function Inventory:FormatEditModeCursorTooltipTitle(objectName, objectType)
	return 
		BS_FONT_COLOR.BAGSHUI .. string.format(L.Symbol_Colon, objectType) .. FONT_COLOR_CODE_CLOSE
		.. " " .. HIGHLIGHT_FONT_COLOR_CODE .. objectName .. FONT_COLOR_CODE_CLOSE
end



--- "Pick up" an item and place it on the cursor.
---@param item table Inventory item cache entry.
function Inventory:EditModePickUpItem(item)
	assert(item, "Inventory<" .. tostring(self.inventoryType) .. ">:EditModePickUpItem() - item is required")
	if item.id == 0 then
		return
	end

	self.editState.cursorItem = item
	self.editState.cursorItemType = BS_INVENTORY_OBJECT_TYPE.ITEM
	self.editState.cursorTooltipTitle = self:FormatEditModeCursorTooltipTitle(BsItemInfo:GetQualityColoredName(item), L.Item)
	self.editState.cursorTooltipText = string.format(L.EditMode_Tooltip_SelectNew, string.lower(L.Location))
	self.editState.highlightItem = item.id

	_G.PlaySound("INTERFACESOUND_CURSORGRABOBJECT")
	self:ShowEditModeCursor()
end



--- When a group is clicked with an item on the cursor in Edit Mode, display the
--- menu so the item can be assigned to a category within the group.
---@param item table Inventory item cache entry.
---@param groupWidget table Group UI frame.
function Inventory:ShowItemCategoryAssignmentMenuForGroup(item, groupWidget)
	self:ClearEditModeCursor()
	local groupId = groupWidget.bagshuiData.groupId

	-- Already in the correct place; nothing to do.
	if groupId == item.bagshuiGroupId then
		return
	end

	if not self:GroupExists(groupId) then
		return
	end

	-- Show menu at cursor if mouse is over the group widget,
	-- or force it to be at the widget otherwise.
	self.menus:OpenMenu(
		"Item",
		item,
		groupId,
		(groupWidget.mouseIsOver) and "cursor" or groupWidget
	)
end



--- "Pick up" a category and place it on the cursor.
--- Named EditModePickUpCategory to fit with EditModePickUpItem.
---@param categoryId string|number
function Inventory:EditModePickUpCategory(categoryId)
	if not categoryId then
		return
	end

	local categoryName = BsCategories:GetName(categoryId)
	if categoryName then
		Bagshui:CloseMenus()

		-- Grab category info.
		self.editState.cursorItem = categoryId
		self.editState.cursorItemType = BS_INVENTORY_OBJECT_TYPE.CATEGORY
		self.editState.cursorTooltipTitle = self:FormatEditModeCursorTooltipTitle(categoryName, L.Category)
		self.editState.cursorTooltipText = string.format(L.EditMode_Tooltip_SelectNew, string.lower(L.Group))
		self.editState.highlightCategory = categoryId

		-- Attach the category to the cursor.
		self:ShowEditModeCursor()
		_G.PlaySound("INTERFACESOUND_CURSORGRABOBJECT")
	end
end



-- Assign a category to a group (move from previous group or assign for the first time).
---@param categoryId string|number
---@param groupId string Group identifier in `"row:column"` format.
---@param noHighlight boolean? When true, do not highlight `categoryId` when the window update occurs.
function Inventory:AssignCategoryToGroup(categoryId, groupId, noHighlight)
	if not self:GroupExists(groupId) then
		return
	end

	-- Parse the destination location.
	local destRow, destColumn = unpack(BsUtil.Split(groupId, ":"))
	destRow = tonumber(destRow)
	destColumn = tonumber(destColumn)

	-- Remove from previous location, if present.
	self:RemoveCategoryFromGroup(categoryId, self.categoriesToGroups[categoryId], true)

	-- Assign to the destination location.
	table.insert(self.layout[destRow][destColumn].categories, categoryId)

	self:ClearEditModeCursor()

	if not noHighlight then
		self.editState.highlightCategory = categoryId
	end

	-- Update window to show new organization
	self:EditModeWindowUpdate(true)
end



--- Unassign a category from a group.
---@param categoryId string|number
---@param groupId string Group identifier in `"row:column"` format.
---@param noWindowUpdate boolean? When true, don't call `EditModeWindowUpdate()` after making changes.
function Inventory:RemoveCategoryFromGroup(categoryId, groupId, noWindowUpdate)
	if not self:GroupExists(groupId) then
		return
	end

	-- Parse the group location.
	local sourceRow, sourceColumn = unpack(BsUtil.Split(groupId, ":"))
	sourceRow = tonumber(sourceRow)
	sourceColumn = tonumber(sourceColumn)

	-- Find the category in the categories array and remove it.
	for index, groupCategoryId in ipairs(self.layout[sourceRow][sourceColumn].categories) do
		if groupCategoryId == categoryId then
			table.remove(self.layout[sourceRow][sourceColumn].categories, index)
			break
		end
	end

	-- Update window to show new organization.
	if not noWindowUpdate then
		self:EditModeWindowUpdate(true)
	end
end



--- Assign/unassign a group to/from a category.
---@param categoryId any
---@param groupId string Group identifier in `"row:column"` format.
---@param noHighlight boolean? When true, do not highlight `categoryId` when the window update occurs.
function Inventory:ToggleCategoryGroupAssignment(categoryId, groupId, noHighlight)
	if not self:GroupExists(groupId) then
		return
	end

	if self.categoriesToGroups[categoryId] == groupId then
		self:RemoveCategoryFromGroup(categoryId, groupId)
	else
		self:AssignCategoryToGroup(categoryId, groupId, noHighlight)
	end
end



--- "Pick up" a group so it can be moved to a new location.
--- Named EditModePickUpGroup to fit with EditModePickUpItem.
---@param groupId string Group identifier in `"row:column"` format.
function Inventory:EditModePickUpGroup(groupId)
	assert(groupId, "Inventory<" .. tostring(self.inventoryType) .. ">:EditModePickUpGroup() - groupId is required")

	self.editState.cursorItem = groupId
	self.editState.cursorItemType = BS_INVENTORY_OBJECT_TYPE.GROUP
	self.editState.cursorTooltipTitle = self:FormatEditModeCursorTooltipTitle(((string.len(self.groups[groupId].name or "") > 0) and self.groups[groupId].name or L.UnnamedGroup), L.Group)
	self.editState.cursorTooltipText = string.format(L.EditMode_Tooltip_SelectNew, string.lower(L.Location))

	-- Attach the group to the cursor
	_G.PlaySound("INTERFACESOUND_CURSORGRABOBJECT")
	self:ShowEditModeCursor()
end



--- Assign a group to the current layout. This includes:
--- - Moving a group from its current location to a new one.
--- - Creating a new group when a category or item is on the cursor and a group move target is clicked.
---@param objectId string|number
---@param objectType BS_INVENTORY_OBJECT_TYPE
---@param insertType BS_INVENTORY_LAYOUT_DIRECTION
---@param destRow number Row to place the group in.
---@param destColumn number Column to place the group in.
function Inventory:AssignGroupToLayout(objectId, objectType, insertType, destRow, destColumn)
	self:ClearEditModeCursor()

	local group = nil
	local groupIsNew = false

	if objectType == BS_INVENTORY_OBJECT_TYPE.GROUP then
		-- This is a group that is already assigned to the layout in another spot.

		-- Get info about the group we need to move.
		local sourceRow, sourceColumn = unpack(BsUtil.Split(objectId, ":"))
		sourceRow = tonumber(sourceRow)
		sourceColumn = tonumber(sourceColumn)

		-- Can't move a group onto itself or just next ot itself.
		if
			insertType == BS_INVENTORY_LAYOUT_DIRECTION.COLUMN
			and sourceRow == destRow
			and (
				destColumn == sourceColumn
				or destColumn == sourceColumn + 1
			)
		then
			return
		end

		-- Remove group from old position.
		group, destRow, destColumn = self:RemoveGroupFromLayout(sourceRow, sourceColumn, destRow, destColumn, true)


	else
		-- When a category or item is placed on a group move target, a new group needs to be created.
		if
			objectType == BS_INVENTORY_OBJECT_TYPE.CATEGORY
			or objectType == BS_INVENTORY_OBJECT_TYPE.ITEM
		then
			-- Set variables that will eventually be consumed by ManagePendingGroupAssignments().
			self.pendingGroupAssignmentObject = objectId
			self.pendingGroupAssignmentObjectType = objectType
		end

		-- Create a new empty group. ManagePendingGroupAssignments() will take care of filling it if needed.
		group = {
			categories = {},
			name = "",
		}
		groupIsNew = true

	end

	-- Add group to new position.
	if insertType == BS_INVENTORY_LAYOUT_DIRECTION.ROW then
		table.insert(self.layout, destRow, { group })
	else
		table.insert(self.layout[destRow], destColumn, group)
	end

	self:EditModeWindowUpdate(true)

	-- Prompt to name new groups.
	if groupIsNew then
		self:RenameGroup(destRow .. ":" .. destColumn, true)
	end
end



--- Apply or clear the pending group assignments from `self.pendingGroupAssignmentObject`/`pendingGroupAssignmentObjectType`.
---@param groupId string? Group to which the pending assignment should apply.
---@param apply boolean? If false, discard the pending assignments instead of applying them.
function Inventory:ManagePendingGroupAssignments(groupId, apply)
	if apply then
		local objectId = self.pendingGroupAssignmentObject
		local objectType = self.pendingGroupAssignmentObjectType
		if objectType == BS_INVENTORY_OBJECT_TYPE.CATEGORY then
			self:AssignCategoryToGroup(objectId, groupId, true)

		elseif objectType == BS_INVENTORY_OBJECT_TYPE.ITEM then
			self:ShowItemCategoryAssignmentMenuForGroup(
				objectId,
				self.groupsIdsToFrames[groupId]
			)

		end
	end
	self.pendingGroupAssignmentObject = nil
	self.pendingGroupAssignmentObjectType = nil
end



--- Prompt for group name and update if changed.
---@param groupId string Group identifier in `"row:column"` format.
---@param groupIsNew boolean? When true, delete the group when the Undo (Cancel) button is clicked.
function Inventory:RenameGroup(groupId, groupIsNew)
	if not self:GroupExists(groupId) then
		return
	end

	local dialogName = "BAGSHUI_RENAME_GROUP"

	if not _G.StaticPopupDialogs[dialogName] then
		_G.StaticPopupDialogs[dialogName] = {
			text = "",
			button1 = _G.OKAY,
			button2 = _G.CANCEL,
			hasEditBox = 1,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
			EditBoxOnEnterPressed = BsUtil.StaticPopupDialogs_EnterClicksFirstButton,
			-- Extra property to be used in OnShow to fill the edit box.
			-- Blizzard doesn't provide an easy way to do this in Vanilla as the
			-- data property isn't accessible in OnShow, and all the FrameXML code uses
			-- global variables and functions.
			_bagshuiDefaultEditBoxText = "",

			-- Set the default value for the edit box.
			OnShow = function()
				_G[_G.this:GetName().."EditBox"]:SetText(
					_G.StaticPopupDialogs[dialogName]._bagshuiDefaultEditBoxText
				)
				_G[_G.this:GetName().."EditBox"]:SetFocus()
			end,

			--- Okay was clicked, so change the group name.
			---@param data table Reference to `self.renameGroup_Data`, passed through via the dialog's `data` property.
			OnAccept = function(data)
				self.editModeGroupHighlight = nil
				if self.groups[data.groupId] then
					self.groups[data.groupId].name = _G[_G.this:GetParent():GetName() .. "EditBox"]:GetText()
				end
				self:ManagePendingGroupAssignments(data.groupId, true)
				self:EditModeWindowUpdate()
			end,

			--- Cancel was clicked.
			--- For new groups, this means the group is no longer wanted.
			--- For existing groups, just remove highlighting.
			---@param data table Reference to `self.renameGroup_Data`, passed through via the dialog's `data` property.
			OnCancel = function(data)
				if data.groupIsNew then
					local row, column = self:GroupIdToRowColumn(data.groupId)
					if row and column then
						self:RemoveGroupFromLayout(row, column)
					end
				end
				self.editModeGroupHighlight = nil
				self:ManagePendingGroupAssignments(data.groupId, false)
				self:EditModeWindowUpdate()
			end,

			-- Clear text on hide so it doesn't bleed over to other dialogs.
			OnHide = BsUtil.StaticPopupDialogs_ClearTextOnHide
		}

		self.renameGroup_Data = {}
	end

	-- Current group name and text to prompt user with.
	local currentName = self.groups[groupId].name
	local prompt =
		groupIsNew and L.EditMode_Prompt_NewGroupName
		or string.format(L.EditMode_Prompt_RenameGroup, (string.len(currentName or "") > 0 and currentName or L.UnnamedGroup))

	-- Update dialog properties.
	local dialogProps = _G.StaticPopupDialogs[dialogName]
	dialogProps.text = prompt
	dialogProps._bagshuiDefaultEditBoxText = currentName or ""

	-- Lock group highlight so it's more clear what group is being renamed.
	self.editModeGroupHighlight = groupId
	self:EditModeWindowUpdate()

	-- Set properties we need the dialog scripts to know.
	self.renameGroup_Data.groupId = groupId
	self.renameGroup_Data.groupIsNew = groupIsNew

	-- Change button labels based on what is happening.
	if groupIsNew then
		_G.StaticPopupDialogs[dialogName].button1 = L.Create
		_G.StaticPopupDialogs[dialogName].button2 = L.Undo
	else
		_G.StaticPopupDialogs[dialogName].button1 = _G.OKAY
		_G.StaticPopupDialogs[dialogName].button2 = _G.CANCEL
	end

	-- Show the dialog.
	local dialog = _G.StaticPopup_Show(dialogName)

	-- Pass stuff to dialog functions via the magic data property.
	if dialog then
		dialog.data = self.renameGroup_Data
	end
end



--- Delete a group after confirmation.
---@param groupId string Group identifier in `"row:column"` format.
function Inventory:DeleteGroup(groupId)
	if not self:GroupExists(groupId) then
		return
	end

	local dialogName = "BAGSHUI_DELETE_GROUP"

	if not _G.StaticPopupDialogs[dialogName] then
		_G.StaticPopupDialogs[dialogName] = {
			text = L.EditMode_Prompt_DeleteGroup,
			button1 = L.Delete,
			button2 = L.Cancel,
			showAlert = 1,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,

			-- Delete the group.
			-- The groupId parameter comes from the dialog's data property which is set below.
			OnAccept = function(groupId)
				local row, column = self:GroupIdToRowColumn(groupId)
				self.editModeGroupHighlight = nil
				self:RemoveGroupFromLayout(row, column)
			end,

			-- Remove highlighting.
			OnCancel = function()
				self.editModeGroupHighlight = nil
				self:EditModeWindowUpdate()
			end,
		}
	end

	-- Lock group highlight so it's more clear which group is up for deletion.
	self.editModeGroupHighlight = groupId
	self:EditModeWindowUpdate()

	-- Display the dialog and provide the object type and object name to the prompt text.
	local dialog = _G.StaticPopup_Show(dialogName)

	-- Pass groupId through to StaticPopupDialog via the magical data property.
	if dialog then
		dialog.data = groupId
	end

end



--- Remove a group from the current layout, returning adjusted destination row/column values if provided.
--- These adjusted values are needed when a group is moved, because removing it from its current position
--- can change where it needs to be inserted. For example, moving a group from 1:1 to 1:4 will mean it
--- actually needs to be inserted at 1:3, since the removal shifts everything down by 1. Similarly,
--- 2:4 to 4:1 requires inserting at 3:1 if the group being moved was the only one on row 2.
---@param row number Row of the group being deleted.
---@param column number Column of the group being deleted.
---@param destRow number? Desired destination row to be adjusted.
---@param destColumn number? Desired destination column to be adjusted.
---@param noWindowUpdate boolean? When true, don't call EditModeWindowUpdate() after performing the removal.
---@return table? group # Group object.
---@return number? destRow # Adjusted destination row.
---@return number? destColumn # Adjusted destination column.
function Inventory:RemoveGroupFromLayout(row, column, destRow, destColumn, noWindowUpdate)
	assert(row and column, "Inventory:RemoveGroupFromLayout(): row and column are both required.")

	local group = table.remove(self.layout[row], column)

	-- Remove empty row.
	local rowRemoved = false
	if table.getn(self.layout[row]) == 0 then
		table.remove(self.layout, row)
		rowRemoved = true
	end

	-- Destination layout adjustments.
	if destRow ~= nil and destColumn ~= nil then
		-- Decrement destination column number by 1 if staying on the same row since
		-- everything is shifted down by removal (but only if the destination column
		-- is higher than the source).
		if destRow == row and destColumn > column then
			destColumn = destColumn - 1
		end

		-- Decrement destination row number by 1 (same reasoning as column adjustment above).
		if rowRemoved and destRow > row then
			destRow = destRow - 1
		end
	end

	-- Update window to show new organization.
	if not noWindowUpdate then
		self:EditModeWindowUpdate(true)
	end

	return group, destRow, destColumn
end



--- Parse row and column numbers from a "row:column" string.
---@param groupId string Group identifier in `"row:column"` format.
---@return number? row
---@return number? column
function Inventory:GroupIdToRowColumn(groupId)
	local row, column = unpack(BsUtil.Split(groupId, ":"))
	row = tonumber(row)
	column = tonumber(column)
	return row, column
end



--- Assign a sort order to a group.
---@param sortOrderId string|number|nil Sort order identifier, or nil to reset to default.
---@param groupId string Group identifier in `"row:column"` format.
function Inventory:AssignSortOrderToGroup(sortOrderId, groupId)
	if not self:GroupExists(groupId) then
		return
	end

	self.groups[groupId].sortOrder = sortOrderId

	-- Update window to show new organization.
	self:EditModeWindowUpdate(true)
end



--- Test whether a group exists.
---@param groupId string Group identifier in `"row:column"` format.
---@return boolean
function Inventory:GroupExists(groupId)
	if not groupId then
		return false
	end
	if not self.groups[groupId] then
		Bagshui:PrintError(string.format(L.Error_GroupNotFound, tostring(groupId)))
		return false
	end
	return true
end



end)