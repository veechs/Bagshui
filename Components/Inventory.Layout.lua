-- Bagshui Inventory Prototype: Window Layout
-- Categorizing, Sorting, Putting Things On The Screen, etc.
-- Most of the functions here shouldn't be called directly as Inventory:Update() handles the coordination.

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory


--- This is the main workhorse for orchestrating UI changes; it's called when almost anything happens.
function Inventory:Update()
	-- self:PrintDebug(string.format("Update() windowUpdateBlocked=%s", tostring(self.windowUpdateBlocked)))

	-- Only update if we haven't been blocked from doing so.
	-- One of the main reasons this can happen is when the window is being dragged --
	-- see `Inventory:SaveWindowPosition()` for details.
	if self.windowUpdateBlocked then
		return
	end

	-- Update is only needed if the window is visible.
	if not self:Visible() and not self.forceCacheUpdate then
		self.windowUpdateBlocked = false
		return
	end

	-- We're updating!
	self.windowUpdateBlocked = true

	-- Before doing anything else, we need to know if we're online.
	self:UpdateOnlineStatus()

	-- Always update the cache if we get this far.
	self:UpdateCache()

	-- self.forceCacheUpdate was true, but the window might not be visible.
	if not self:Visible() then
		-- No need to redraw everything when we're not visible.
		self.windowUpdateBlocked = false
		return
	end

	-- Perform all updates in the necessary order.
	self:ValidateLayout()
	self:CategorizeAndSort()
	self:FindSpecialItems()
	self:UpdateWindow()
	self:UpdateBagBar()
	self:UpdateToolbar()

	-- Reset status.
	self.windowUpdateBlocked = false
end



--- Force a window redraw without updating the inventory cache.
function Inventory:ForceUpdateWindow()
	self.cacheUpdateNeeded = false
	self.windowUpdateNeeded = true
	self.forceResort = false
	self:Update()
end



--- Refresh only item slot colors without all the overhead of calculating the window layout.
--- High-performance -- much better than `UpdateWindow()`/`ForceUpdateWindow()`, so it should be used for
--- changing highlights or opacity (searching, bag bar mouseover, Edit Mode highlighting, etc.).
function Inventory:UpdateItemSlotColors()
	for _, button in ipairs(self.ui.buttons.itemSlots) do
		if button:IsVisible() then
			self.ui:UpdateItemButtonColorsAndBadges(button)
		end
	end
end



--- Ensure there will be no errors when using the active layout.
function Inventory:ValidateLayout()
	-- Completely empty layouts need at least a row and a group.
	if table.getn(self.layout) == 0 then
		table.insert(self.layout, {})
		BsUtil.TableCopy(BS_NEW_PROFILE_TEMPLATE.structure.primary.layout, self.layout)
	end

	-- Validate categories assigned to the layout.
	for row = 1, table.getn(self.layout) do
		for group = 1, table.getn(self.layout[row]) do
			local groupCategories = self.layout[row][group].categories
			if groupCategories then
				-- Remove invalid categories.
				-- Need to step backwards so we can use table.remove().
				for catNum = table.getn(groupCategories), 1, -1 do
					local categoryId = groupCategories[catNum]
					if not BsCategories.list[categoryId] then
						table.remove(groupCategories, catNum)
					end
				end
			else
				-- This group needs a categories property.
				self.layout[row][group].categories = {}
			end
		end
	end
end



--- Assign inventory items to Bagshui categories and sort into the correct order for display.  
--- **Should not be called directly!** Use `Inventory:Update()` to coordinate the process.
---
--- Inventory cache to lookup table relationships:
--- - Cache is stored as `self.inventory[bagNum][slotNum]`
--- - Group items store references to the inventory cache items:  
---     `self.groupItems[groupNum][position] = <reference to self.inventory[bagNum][slotNum]>`
function Inventory:CategorizeAndSort()
	--self:PrintDebug("CategorizeAndSort()")

	-- sortingAllowed tracks whether items can be moved between groups and sorted within groups.
	-- Defaults to true but is turned off when the inventory window is open and the user hasn't
	-- explicitly requested a resort.
	self.sortingAllowed = true

	-- Ensure items don't shift around when the window is open under normal usage.
	-- self.forceResort can be used to override (usually when the user clicks the Resort button).
	if
		(
			not self.resortNeeded
			or self:Visible()
		)
		and not self.forceResort
	then
		-- self:PrintDebug("CategorizeAndSort() - sorting not allowed")
		-- There was a change that would have triggered a resort, but it wasn't allowed, so enable the toolbar icon.
		if self.resortNeeded then
			self.enableResortIcon = true
		end
		-- Don't allow anything to move around; just update categorization.
		self.sortingAllowed = false
	end

	-- self:PrintDebug("---------- CategorizeAndSort() PROCEEDING --------------")
	-- self:PrintDebug("forceResort: " .. tostring(self.forceResort))
	-- self:PrintDebug("visible: " .. tostring(self:Visible()))
	-- self:PrintDebug("sortingAllowed: " .. tostring(self.sortingAllowed))

	-- Reset force resort flag.
	self.forceResort = false

	-- Only refresh lookup tables when sorting can be performed.
	if self.sortingAllowed then
		self:UpdateLayoutLookupTables()

		-- We're taking care of getting everything moved to the correct places now,
		-- so the resort icon can be disabled.
		self.enableResortIcon = false
	end

	-- Categorize items and assign to groups.
	self:CategorizeItems()

	-- Nothing more to do when items can't be moved.
	if not self.sortingAllowed then
		return
	end

	-- Sort items within groups.
	self:SortGroups()

	-- Reset flags.
	self.resortNeeded = false
	self.windowUpdateNeeded = true
end



--- Fill the lookup tables that are used when building the interface.  
--- ***Generally* should not be called directly!** Use `Inventory:Update()` to coordinate the process.
---
--- Lookup tables managed by this function:
--- - `activeGroups`: `{ <Group ID> = <Reference to group> }`
--- - `categoryIdsGroupedBySequence` is used to determine the order of execution for category matching:  
--- ```
--- 	{
--- 		[<Sequence Num 1>] = {
--- 			[<Category ID 1>],
--- 			[<Category ID 2>],
--- 		},
--- 		[<Sequence Num 2>] = {
--- 			[<Category ID 3>],
--- 		},
--- 	}
--- ```
--- - `sortedCategorySequenceNumbers` is just an array of the sequence numbers from `categoryIdsGroupedBySequence`
--- so that it can easily be sorted. This avoids having to resort the sequence numbers in `categoryIdsGroupedBySequence`
--- on every call to `Categories:Categorize()`.
--- - `categoriesToGroups` is exactly what it sounds like - the mapping of category IDs to group IDs (which are simply row:position)
--- and is used by `CategorizeAndSort()` when filling the groupItems table.
function Inventory:UpdateLayoutLookupTables()
	if not self.sortingAllowed then
		return
	end
	--self:PrintDebug("UpdateLayoutLookupTables()")
	-- self:PrintDebug(BsCategories.list)

	-- This will be used at the end if defaultCategoryFound is still false.
	local lastGroupId = ""
	local defaultCategoryFound = false

	-- Wipe all the lookup tables managed by this function.
	BsUtil.TableClear(self.groups)
	BsUtil.TableClear(self.activeGroups)
	BsUtil.TableClear(self.groupsIdsToFrames)
	BsUtil.TableClear(self.categoryIdsGroupedBySequence)
	BsUtil.TableClear(self.sortedCategorySequenceNumbers)
	BsUtil.TableClear(self.categoriesToGroups)

	-- Process the layout and update lookup tables.
	for rowNum, rowGroups in ipairs(self.layout) do
		for groupNum, groupDetails in ipairs(rowGroups) do
			local groupId = rowNum .. ":" .. groupNum
			lastGroupId = groupId

			-- Store reference to the group for easy access later.
			self.groups[groupId] = groupDetails

			-- Store the group ID on the group so it's easily accessible for use by Update()
			groupDetails.groupId = groupId

			-- Groups aren't technically active unless they have categories assigned and at least one category is valid.
			if groupDetails.categories and table.getn(groupDetails.categories) > 0 then

				for _, categoryId in ipairs(groupDetails.categories) do
					self:AddCategoryToLookupTables(categoryId, groupId)

					if categoryId == BsCategories.defaultCategory then
						defaultCategoryFound = true
					end
				end
			end
		end
	end

	-- Ensure the default category is always assigned to a group. This is a failsafe and really shouldn't ever be reached.
	if not defaultCategoryFound then
		self:PrintDebug("WARNING: no default category found!")
		self:AddCategoryToLookupTables(BsCategories.defaultCategory, lastGroupId)
	end

	-- Order sortedCategorySequenceNumbers by category sequence.
	table.sort(self.sortedCategorySequenceNumbers)
end



--- Helper function to add a category to the lookup tables.
---@param categoryId string ID of the category.
---@param groupId string ID of the group to associate with the category.
function Inventory:AddCategoryToLookupTables(categoryId, groupId)

	-- Ensure this is a valid category.
	-- Shouldn't ever really be an issue because ValidateLayout() is called first, but let's be safe.
	if BsCategories.list[categoryId] then

		-- Get info about the category.
		local categoryDetails = BsCategories.list[categoryId]
		-- self:PrintDebug(categoryDetails)

		-- We haven't seen this sequence number yet.
		if self.categoryIdsGroupedBySequence[categoryDetails.sequence] == nil then
			-- Add it to sortedCategorySequenceNumbers so it can be used during categorization.
			table.insert(self.sortedCategorySequenceNumbers, categoryDetails.sequence)
			-- Initialize a place for it in the categoryIdsGroupedBySequence table.
			self.categoryIdsGroupedBySequence[categoryDetails.sequence] = {}
		end

		-- Create the category-to-group relationship in categoryIdsGroupedBySequence[<sequence>][<categoryId].
		self.categoryIdsGroupedBySequence[categoryDetails.sequence][categoryId] = groupId

		-- Add to the flat category-to-group relationship table.
		self.categoriesToGroups[categoryId] = groupId

		-- This is a an active group.
		self.activeGroups[groupId] = self.groups[groupId]

	end
end



--- Assign categories and groups to all items in the inventory cache.  
--- **Should not be called directly!** Use `Inventory:Update()` to coordinate the process.
---
--- Lookup tables managed by this function:
--- - `groupItems` stores the sorted list of items that belong to each group.
---
--- Also updates each item's `bagshuiGroupId` and `bagshuiCategoryId` properties.
function Inventory:CategorizeItems()

	-- groupItems stores the list of items that belongs to each group.
	-- Start clean each time we categorize and sort.
	-- This can only occur when items are allowed to be moved around!
	if self.sortingAllowed then
		-- groupItems is a table of tables, so only wipe the 2nd level tables to keep the garbage collector happy.
		for groupId, _ in pairs(self.groupItems) do
			BsUtil.TableClear(self.groupItems[groupId])
		end
		-- Using groups instead of activeGroups here just to ensure every possibility is initialized.
		for groupId, _ in pairs(self.groups) do
			if not self.groupItems[groupId] then
				self.groupItems[groupId] = {}
			end
		end
	end

	local defaultGroupId = self.categoriesToGroups[BsCategories.defaultCategory]
	local groupId

	-- Reset error tracking for the categorization process so that category errors
	-- are only displayed once per category and only every 10 seconds.
	if _G.GetTime() - (self.lastCategorizeItems or 0) > 10 then
		BsCategories:ClearErrors()
	end
	self.lastCategorizeItems = _G.GetTime()

	-- Perform the actual categorization.
	for _, bagNum in ipairs(self.containerIds) do

		-- Only process bags that have contents.
		if self.containers[bagNum].numSlots > 0 and table.getn(self.inventory[bagNum]) > 0 then

			-- Process all bag slots.
			local bagNumSlots = self.containers[bagNum].numSlots
			if bagNumSlots > 0 then
				for slotNum = 1, bagNumSlots do

					-- Categorize each item.
					-- This must ALWAYS be performed so new items don't show up with an unknown category in the Bagshui tooltip.
					BsCategories:Categorize(
						self.inventory[bagNum][slotNum],
						nil,  -- Categorization as any alternate character is not currently enabled.
						self.sortedCategorySequenceNumbers,
						self.categoryIdsGroupedBySequence
					)

					-- Nothing more to do if we can't sort.
					if self.sortingAllowed then
						-- Fall back to the default group if one wasn't assigned.
						groupId = self.inventory[bagNum][slotNum].bagshuiGroupId
						if string.len(tostring(groupId or "")) == 0 then
							groupId = defaultGroupId
						end

						-- Empty slots are now allowed to stack since they've been through the categorizing process.
						-- (When an empty slot is first seen during a cache update, it gets the _bagshuiPreventEmptySlotStack
						-- property set so that empty slots don't just "disappear" into a stack when the window is open
						-- and the user moves an item out of a slot.)
						if self.inventory[bagNum][slotNum].emptySlot == 1 then
							self.inventory[bagNum][slotNum]._bagshuiPreventEmptySlotStack = nil
						end

						-- Final safety check to ensure we don't somehow try to assign to a group that doesn't exist.
						if not self.groupItems[groupId] then
							groupId = defaultGroupId
						end

						-- Add to group positions lookup table.
						table.insert(
							self.groupItems[groupId],
							self.inventory[bagNum][slotNum]
						)
					end

				end -- bagNumSlots loop

			end -- bagNumSlots > 0

		end -- Known bag check

	end -- self.containerIds loop

	-- Show the error button if there were problems.
	self.errorText = BsCategories:GetErrors()

end



-- Sort each group's items in the configured order.  
-- **Should not be called directly!** Use `Inventory:Update()` to coordinate the process.
function Inventory:SortGroups()
	for groupId, groupConfig in pairs(self.activeGroups) do
		BsSortOrders:SortGroup(self.groupItems[groupId], groupConfig, self.settings.defaultSortOrder)
	end
end


--- Actually do the work of updating the UI.  
--- **Should not be called directly!** Use `Inventory:Update()` or `Inventory:ForceWindowUpdate()` to coordinate the process.
---
--- This function handles:
--- - Sizing and placing groups so everything fits within the allowed number of columns
--- - Calling `AssignItemsToSlots()` to fill item slot buttons
--- - Stacking/unstacking empty slots
--- - Hiding/showing components and setting window colors based on preferences
--- - Sizing the window
function Inventory:UpdateWindow()
	-- self:PrintDebug("UpdateWindow()")

	-- Clear the "never online" message once we're online.
	if self.online then
		Bagshui.currentCharacterData[self.inventoryTypeSavedVars].neverOnline = nil
	end

	-- Safeguard: Turn off Highlight Changes if there's nothing to highlight.
	if not self.hasChanges and self.highlightChanges then
		self.highlightChanges = false
	end


	-- Always update window colors.

	self.windowColor = self.settings.windowBackground
	self.borderColor = self.settings.windowBorder

	if self.settings.windowUseSkinColors and BsSkin.skinBackgroundColor then
		self.windowColor = BsSkin.skinBackgroundColor
	end

	if not self.online then
		self.borderColor = BS_COLOR.RED
	elseif self.settings.windowUseSkinColors and BsSkin.skinBorderColor then
		self.borderColor = BsSkin.skinBorderColor
	end

	self.uiFrame:SetBackdropColor(
		self.windowColor[1],
		self.windowColor[2],
		self.windowColor[3],
		self.windowColor[4]
	)
	self.uiFrame:SetBackdropBorderColor(
		self.borderColor[1],
		self.borderColor[2],
		self.borderColor[3],
		self.borderColor[4]
	)

	-- if Bagshui.currentCharacterData[self.inventoryTypeSavedVars].neverOnline then
	-- 	Bagshui:PrintDebug("neverOnline")
	-- end


	-- Only do the intensive work of redrawing the UI if we have to.
	if self.windowUpdateNeeded then

		local uiFrames = self.ui.frames
		local groupFrames = uiFrames.groups
		local uiButtons = self.ui.buttons

		local itemSlotSize = self.settings.itemSize
		local itemSlotScale = self.ui:GetItemButtonScale(self.ui.buttons.itemSlots[1], itemSlotSize)
		local adjustedItemSlotSize = self.ui:GetItemButtonScaledSize(self.ui.buttons.itemSlots[1], itemSlotSize)
		local itemSlotMargin = self.settings.itemMargin + (BsSkin.itemSlotMarginFudge or 0)

		local groupMarginFudged = self.settings.groupMargin + BsSkin.groupMarginFudge
		local groupLabelHeight = groupFrames[1].bagshuiData.text:GetHeight() + math.abs(BsSkin.groupLabelMinPadding)
		local groupPadding = self.settings.groupPadding + (BsSkin.groupPaddingFudge or 0) + ((BsSkin.itemSlotMarginFudge / 2) * itemSlotScale)

		local maxColumns = self.settings.windowMaxColumns
		local anchorLeft = self.settings.windowContentAlignment == "LEFT"
		local showGroupLabels = (self.settings.showGroupLabels and not self.settings.hideGroupLabelsOverride) or self.editMode

		local firstFrame, widestRowLastFrame, topmostFrame

		-- Window component visibility.
		local showHeader = (self.settings.showHeader and not self.dockTo) or self.temporarilyShowWindowHeader
		local showFooter = (self.settings.showFooter and not self.dockTo) or self.temporarilyShowWindowFooter

		-- Reset hidden group and item tracking.
		self.hasHiddenGroups = false  -- Updated in this function.
		self.hasHiddenItems = false  -- Updated in GetGroupItemCountForLayout().
		self.hasChanges = false  -- Updated in AssignItemsToSlots().

		-- Full reset of empty slot stack counts is needed so that the tracking of which
		-- bag they represent is rebuilt.
		self:ResetEmptySlotStackCounts(true)

		-- Is empty slot stacking currently allowed?
		self.emptySlotStackingAllowed = (
			self.settings.stackEmptySlots  -- User setting.
			and not self.expandEmptySlotStacks -- Temporary expansion.
			and not self.editMode  -- Always expand in Edit Mode.
		)

		-- Used to track row changes so they include group move targets (the normal
		-- rowNum variable is just an iteration over self.layout).
		local uiRowNum = 0

		-- These three rowGroup* variables control which direction we step though
		-- the groups (left-to-right or right-to-left).
		local rowGroupStart, rowGroupEnd, rowGroupStep

		-- Exactly what it says on the tin.
		local numGroupsInRow
		local totalItemsInRow = 0
		local rowWidthInItems = 0
		local rowHeightInItems = 0
		local finalWindowWidth = 0
		local finalWindowHeight = 0
		local hideGroup = false

		-- Used to track which row is actually the widest after the frames are positioned.
		local widestRowLastFrameOutsideX = 0
		local currentRowLastFrameOutsideX

		-- Used during row width calculations to determine the point when we need
		-- to increase the row height again.
		local unshrinkableGroupCount = 0

		-- The uiGroupNum* variables are used to keep track of which group frame(s)
		-- we should be using for each row and the overall progress as we step through the layout.
		local uiGroupNum = 1  -- Need to have a default value here since we use uiGroupNum later to hide unused groups.
		local uiGroupNumStart = 1
		local uiGroupNumEnd

		-- currentItemSlotButtonNum tracks the progress of assigning items to buttons.
		local currentItemSlotButtonNum = 1

		-- Groups can have some weird padding going on because of their edge textures,
		-- so we need to adjust the group spacing so the visual outcome is correct.
		local groupXSpacing = groupMarginFudged

		-- Similarly, the initial position of everything isn't straightforward and
		-- gets affected by Edit Mode.
		local groupEdgeOffset = groupMarginFudged
		-- Increase the space between the bottom edge and the first group when the footer is visible.
		local groupEdgeYOffset = groupMarginFudged - (showFooter and BsSkin.groupMarginFudge or 0)

		-- When group labels are shown, we may need more Y space.
		local groupYSpacing = groupXSpacing
		if showGroupLabels then
			if groupYSpacing < groupLabelHeight then
				groupYSpacing = groupLabelHeight
			end
			groupYSpacing = groupYSpacing + BsSkin.groupLabelYPadding
		end

		-- Don't need to calculate the row (horizontal) group move target width outside Edit Mode.
		local rowGroupMoveTargetWidth = 0

		-- Edit Mode spacing adjustments -- keep things as tight as possible since the window will
		-- almost always grow due to more groups being visible.
		if self.editMode then
			groupXSpacing = -1
			groupYSpacing = groupXSpacing
			groupEdgeOffset = BsSkin.inventoryEditModeMargin
			groupEdgeYOffset = groupEdgeOffset

			-- The horizontal group move target is basically the width of a single group.
			rowGroupMoveTargetWidth =
				adjustedItemSlotSize
				+ (itemSlotMargin * 2)
				+ (groupPadding * 2)
				+ ((BsSkin.groupMoveTargetThinDimension + BsSkin.groupMoveTargetAnchorOffset) * 2)
		end

		-- Reset group move target count tracking for ShowNextGroupMoveTarget().
		self.groupMoveTargetCount = 0

		-- Column number adjustment for insertion via group move targets.
		-- This is needed so that we get the correct insertion point regardless of
		-- whether we're going from left to right or vice versa.
		local groupMoveTargetLeadingColumnNumAdjustment = 0
		local groupMoveTargetTrailingColumnNumAdjustment = 0

		-- Prepare to use ShowFrameInNextPosition() for groups.
		self:InitFramePositioningTable(
			"UpdateWindow",  -- Position tracking table.
			groupXSpacing,  -- Frame X spacing.
			groupYSpacing,  -- Frame Y spacing.
			uiFrames.main,  -- Initial frame to anchor to.
			-groupEdgeOffset,
			groupEdgeYOffset
		)

		-- Reset tracking tables.
		BsUtil.TableClear(self.groupItemCounts)  -- How many items are in each group.
		BsUtil.TableClear(self.groupWidthsInItems)  -- Group width in items (actual count EXCEPT in Edit Mode, where 0 becomes 1 to force the group to be visible when empty)
		BsUtil.TableClear(self.actualGroupWidths)  -- Group width in screen units.

		-- Groups are placed starting at the bottom of the main frame and working upwards.
		-- Since we're starting at the bottom of the window, we need to start at the last row of the layout table.
		for rowNum = table.getn(self.layout), 1, -1 do
			-- self:PrintDebug("ROW "..rowNum)

			-- Get the number of groups in this row.
			numGroupsInRow = table.getn(self.layout[rowNum])
			-- Use that information to figure out the number of the end group.
			uiGroupNumEnd = uiGroupNumStart + numGroupsInRow - 1

			-- Ensure all group UI elements exist.
			for groupNum = uiGroupNumStart, uiGroupNumEnd do
				self.ui:CreateGroup(groupNum)
			end

			-- Determine anchoring.
			if anchorLeft then
				rowGroupStart = 1
				rowGroupEnd = numGroupsInRow
				rowGroupStep = 1
				groupMoveTargetLeadingColumnNumAdjustment = 0
				groupMoveTargetTrailingColumnNumAdjustment = 1
			else
				rowGroupStart = numGroupsInRow
				rowGroupEnd = 1
				rowGroupStep = -1
				groupMoveTargetLeadingColumnNumAdjustment = 1
				groupMoveTargetTrailingColumnNumAdjustment = 0
			end


			-- Populate lists that are used to determine how tall each group needs to
			-- be in order to fit all items within the maximum column count.
			totalItemsInRow = 0
			for columnNum = rowGroupStart, rowGroupEnd, rowGroupStep do
				local groupId = self.layout[rowNum][columnNum].groupId

				if groupId then
					hideGroup = false

					-- Determine whether this group is visible and update hasHiddenGroups
					-- to control whether the Show/Hide toolbar button is enabled.
					if self.groups[groupId] and self.groups[groupId].hide then
						hideGroup = true
						self.hasHiddenGroups = true
					end

					-- Determine how many items are in each group in this row based on group visibility.
					if not self.editMode and not self.showHidden and hideGroup then
						-- Set the groupItemCounts for this group to 0 if it's not visible.
						self.groupItemCounts[groupId] = 0
					else
						self.groupItemCounts[groupId] = self:GetGroupItemCountForLayout(groupId)
					end

					-- Increment total for this row.
					totalItemsInRow = totalItemsInRow + self.groupItemCounts[groupId]

					-- Starting width for all groups is the number of items in the group.
					self.groupWidthsInItems[groupId] = self.groupItemCounts[groupId]

					-- groupWidthsInItems gets fudged for Edit Mode to make all groups visible, even if they're empty.
					if self.groupWidthsInItems[groupId] == 0 and self.editMode then
						self.groupWidthsInItems[groupId] = 1
					end
				else
					Bagshui:PrintWarning("Inventory update call should have forced resort!")
				end
			end

			-- Starting values for row height/width.
			rowWidthInItems = totalItemsInRow
			rowHeightInItems = 1

			-- Shrink group widths until everything fits within the configured column limit. Basically:
			-- 1. Increment the row height by 1.
			-- 2. Loop through all columns and decrease width of each by 1 (so long as that's possible and won't make it too tall).
			-- 3. See if everything fits now. If not, go back to step 2 unless all groups are now too tall, in which case, go back to step 1.
			-- (No need to do any of this unless there are too many items in the row to fit in the configured number of columns.)
			while rowWidthInItems > maxColumns do
				rowHeightInItems = rowHeightInItems + 1
				repeat
					rowWidthInItems = 0
					unshrinkableGroupCount = 0
					for columnNum = rowGroupStart, rowGroupEnd, rowGroupStep do
						local groupId = self.layout[rowNum][columnNum].groupId

						-- Shrink the group by 1, if possible.
						if self.groupWidthsInItems[groupId] > 1 then
							local newWidth = self.groupWidthsInItems[groupId] - 1
							-- Make sure this width would't make the group too tall for this row height.
							if self.groupItemCounts[groupId] / newWidth <= rowHeightInItems then
								self.groupWidthsInItems[groupId] = newWidth
							else
								unshrinkableGroupCount = unshrinkableGroupCount + 1
							end
						else
							unshrinkableGroupCount = unshrinkableGroupCount + 1
						end
						rowWidthInItems = rowWidthInItems + self.groupWidthsInItems[groupId]
					end
				until rowWidthInItems <= maxColumns or unshrinkableGroupCount >= numGroupsInRow
			end

			-- Is there anything to display on this row?
			if totalItemsInRow == 0 and not self.editMode then
				-- All groups are not visible.
				for groupNum = uiGroupNumStart, uiGroupNumEnd do
					groupFrames[groupNum]:Hide()
				end

			else
				-- There are groups to display, so let's continue.
				-- Calculate the actual group widths, which we need to know when we make the group frame visible.
				local totalActualGroupWidths = 0  -- Will be used to determine how wide the window needs to be.
				for columnNum = rowGroupStart, rowGroupEnd, rowGroupStep do
					local group = self.layout[rowNum][columnNum]

					-- Make sure this group will be displayed before adding it to the totals.
					if self.groupWidthsInItems[group.groupId] > 0 or self.editMode then
						self.actualGroupWidths[group.groupId] = (
							-- Item slot widths, margin included.
							(self.groupWidthsInItems[group.groupId] * (adjustedItemSlotSize + itemSlotMargin))
							-- This accounts for the space on the opposite side of the last item.
							+ itemSlotMargin
							-- Left and right group padding.
							+ (groupPadding * 2)
						)
						totalActualGroupWidths = totalActualGroupWidths + self.actualGroupWidths[group.groupId]
					else
						self.actualGroupWidths[group.groupId] = 0
					end
				end

				-- Every group on the row gets the same height even if it's not full of items.
				local actualGroupHeight =
				    -- Item slot heights, margin included.
					(rowHeightInItems * (adjustedItemSlotSize + itemSlotMargin))
					-- This accounts for the space above the last item.
					+ itemSlotMargin
					-- Top and bottom group padding
					+ (groupPadding * 2)


				-- Edit Mode accommodations
				if self.editMode then
					-- Group labels move inside in Edit Mode and need to be added to the height.
					actualGroupHeight = actualGroupHeight + groupLabelHeight

					-- Show the between-row group move target below this row.
					uiRowNum = uiRowNum + 1
					self:ShowNextGroupMoveTarget(
						rowGroupMoveTargetWidth,
						BsSkin.groupMoveTargetThinDimension,
						uiRowNum,
						rowNum + 1,
						1,
						BS_INVENTORY_LAYOUT_DIRECTION.ROW
					)
				end


				-- Put the groups in their places.
				uiGroupNum = uiGroupNumStart
				uiRowNum = uiRowNum + 1

				for columnNum = rowGroupStart, rowGroupEnd, rowGroupStep do
					local groupId = self.layout[rowNum][columnNum].groupId

					-- Ensure the group exists.
					self.ui:CreateGroup(uiGroupNum)
					local group = groupFrames[uiGroupNum]

					-- Store a reference to the group widget so it's easily accessible via group ID.
					-- Primarily used when an item needs to be assigned to a new group in ManagePendingGroupAssignments().
					self.groupsIdsToFrames[groupId] = group

					-- Show leading group move target for this group in Edit Mode.
					if self.editMode then
						self:ShowNextGroupMoveTarget(
							BsSkin.groupMoveTargetThinDimension,
							actualGroupHeight,
							uiRowNum,
							rowNum,
							columnNum + groupMoveTargetLeadingColumnNumAdjustment,
							BS_INVENTORY_LAYOUT_DIRECTION.COLUMN
						)
						-- In Edit Mode, the group move target should be used for height/width calculations.
						if not firstFrame then
							firstFrame = self.positioningTables.UpdateWindow.anchorToFrame
						end
					end

					-- Display the group.
					if self.groupWidthsInItems[groupId] > 0 then

						-- Update info on the UI object.
						group.bagshuiData.groupId = groupId
						group.bagshuiData.rowNum = rowNum
						group.bagshuiData.columnNum = columnNum

						-- Add the group to the window.
						self:ShowFrameInNextPosition(
							"UpdateWindow",
							uiRowNum,
							group,
							self.actualGroupWidths[groupId],
							actualGroupHeight
						)

						-- This is the group that should be used for height/width calculations.
						if not firstFrame then
							firstFrame = self.positioningTables.UpdateWindow.anchorToFrame
						end

						-- Set background and border colors.
						self.ui:SetGroupColors(group)

						-- Labels.
						if showGroupLabels then
							-- Move to the correct location depending on whether we're in Edit Mode.
							group.bagshuiData.labelFrame:SetHeight(groupLabelHeight)
							group.bagshuiData.labelFrame:ClearAllPoints()
							if self.editMode then
								group.bagshuiData.labelFrame:SetWidth(self.actualGroupWidths[groupId] - (groupPadding * 2) - itemSlotMargin)
								group.bagshuiData.labelFrame:SetPoint("TOPLEFT", group, "TOPLEFT", BsSkin.groupLabelEditModeXOffset, BsSkin.groupLabelEditModeYOffset)
								group.bagshuiData.labelFrame:EnableMouse(false)
							else
								group.bagshuiData.labelFrame:SetWidth(self.actualGroupWidths[groupId] + BsSkin.groupLabelRelativeWidth)
								group.bagshuiData.labelFrame:SetPoint("BOTTOMLEFT", group, "TOPLEFT", BsSkin.groupLabelXOffset, BsSkin.groupLabelYOffset)
								group.bagshuiData.labelFrame:EnableMouse(true)
							end

							-- Set text to group name, or a single space if the group name is empty.
							-- The single space is necessary so that the height can be measured properly.
							group.bagshuiData.text:SetText(
								string.len(self.layout[rowNum][columnNum].name or "") > 0
								and self.layout[rowNum][columnNum].name
								or " "
							)

							group.bagshuiData.labelFrame:Show()

						else
							-- Labels are turned off.
							group.bagshuiData.labelFrame:Hide()
						end

						-- Assign items to the group (only if there are items in the group).
						if self.groupItemCounts[groupId] > 0 then
							currentItemSlotButtonNum = self:AssignItemsToSlots(
								groupId,
								uiGroupNum,
								currentItemSlotButtonNum,
								self.groupWidthsInItems[groupId],
								groupPadding,
								itemSlotSize,
								itemSlotMargin
							)
						end

						-- Give groups mouse input and display group manager buttons in Edit Mode.
						self.ui:SetGroupInteractivityEnabled(group, self.editMode)

					else
						-- Group should not be visible.
						group:Hide()
					end

					uiGroupNum = uiGroupNum + 1

				end

				-- Display the trailing group move target for this row.
				if self.editMode then
					self:ShowNextGroupMoveTarget(
						BsSkin.groupMoveTargetThinDimension,
						actualGroupHeight,
						uiRowNum,
						rowNum,
						rowGroupEnd + groupMoveTargetTrailingColumnNumAdjustment,
						BS_INVENTORY_LAYOUT_DIRECTION.COLUMN
					)
				end

				-- Update the widest row record so we can make the window the correct width.
				currentRowLastFrameOutsideX = (
					anchorLeft
					and self.positioningTables.UpdateWindow.anchorToFrame:GetRight()
					or self.positioningTables.UpdateWindow.anchorToFrame:GetLeft()
				)
				if
					widestRowLastFrameOutsideX == 0
					or (
						anchorLeft
						and widestRowLastFrameOutsideX < currentRowLastFrameOutsideX
						or widestRowLastFrameOutsideX > currentRowLastFrameOutsideX
					)
				then
					widestRowLastFrameOutsideX = currentRowLastFrameOutsideX
					widestRowLastFrame = self.positioningTables.UpdateWindow.anchorToFrame
				end

			end

			uiGroupNumStart = uiGroupNumStart + numGroupsInRow
		end

		-- Add the final group move target above the last row.
		if self.editMode then
			uiRowNum = uiRowNum + 1
			self:ShowNextGroupMoveTarget(
				rowGroupMoveTargetWidth,
				BsSkin.groupMoveTargetThinDimension,
				uiRowNum,
				1,
				1,
				BS_INVENTORY_LAYOUT_DIRECTION.ROW
			)
		end

		-- Hide unused item slot buttons, groups, and group move targets.
		local itemSlotButtonCount = table.getn(uiButtons.itemSlots)
		if currentItemSlotButtonNum <= itemSlotButtonCount then
			for buttonNum = currentItemSlotButtonNum, itemSlotButtonCount do
				uiButtons.itemSlots[buttonNum]:Hide()
			end
		end
		for i = uiGroupNum, table.getn(uiFrames.groups) do
			uiFrames.groups[i]:Hide()
		end
		for i = self.groupMoveTargetCount + 1, table.getn(uiFrames.groupMoveTargets) do
			uiFrames.groupMoveTargets[i]:Hide()
		end

		-- The last frame to be placed is always going to be the highest one vertically,
		-- unlike the frame used for horizontal sizing, which is dependent on which row is the widest.
		topmostFrame = self.positioningTables.UpdateWindow.anchorToFrame

		-- Show the "No inventory data" message for when the cache has never been populated.
		if not self.editMode and BsUtil.TrueTableSize(self.inventory) == 0 then
			self.ui.text.noData:Show()
		else
			self.ui.text.noData:Hide()
		end

		-- Calculate what we always know for width and height (header/footer are added next).
		finalWindowWidth =
			-- Inventory content.
			(
				(firstFrame and widestRowLastFrame)
				and math.abs(firstFrame:GetRight() - widestRowLastFrame:GetLeft())
				or 0
			)
			-- Outer group margins.
			+ groupEdgeOffset * 2
			-- Window padding.
			+ BsSkin.inventoryWindowPadding * 2

		finalWindowHeight =
			-- Inventory content.
			(
				(topmostFrame and firstFrame)
				and (topmostFrame:GetTop() - firstFrame:GetBottom())
				or 0
			)
			-- Bottom group margin.
			+ groupEdgeYOffset
			-- Edit Mode messes with the sizing.
			+ (
				self.editMode
				and (
					-- Account for the top group move target.
					BsSkin.groupMoveTargetThinDimension
				)
				or (
					-- Top group margin is the standard one.
					groupEdgeOffset
					-- Need some breathing room above the topmost labels.
					+ (showGroupLabels and (groupLabelHeight - BsSkin.groupMarginFudge) or 0)
				)
			)
			-- "No data" message
			+ (self.ui.text.noData:IsShown() and self.ui.text.noData:GetHeight() or 0)
			-- Window padding.
			+ BsSkin.inventoryWindowPadding * 2


		-- Show/hide header/footer (toolbars) and add to window dimensions.
		if showHeader then
			-- Ensure main frame anchor is correct.
			uiFrames.main:SetPoint("TOP", uiFrames.header, "BOTTOM", 0, 0)
			uiFrames.header:Show()
			-- Update window height.
			finalWindowHeight =
				finalWindowHeight
				+ (uiFrames.header:GetHeight())
				+ math.abs(BsSkin.inventoryHeaderFooterYAdjustment)
		else
			-- When the header is hidden, the main frame needs to anchor to the UI frame instead.
			uiFrames.main:SetPoint("TOP", self.uiFrame, "TOP", 0, BsSkin.inventoryWindowPadding)
			uiFrames.header:Hide()
		end

		if showFooter then
			-- Ensure main frame anchor is correct.
			uiFrames.main:SetPoint("BOTTOM", uiFrames.footer, "TOP", 0, 0)

			-- Show/hide Bag Bar.
			if self.settings.showBagBar then
				uiFrames.bagBar:Show()
			else
				uiFrames.bagBar:Hide()
			end

			-- Variables for hearthstone button position based on whether money frame is shown.
			local hearthButtonAnchorToFrame = uiButtons.toolbar.hearthstone.bagshuiData.defaultAnchorToFrame
			local hearthButtonAnchorToPoint = uiButtons.toolbar.hearthstone.bagshuiData.defaultAnchorToPoint

			-- Show/hide Money frame.
			if self.settings.showMoney then
				uiFrames.money:Show()
				uiFrames.money:SetAlpha(self.editMode and 0.2 or 1)
				-- Use label colors for money text.
				for _, text in pairs(uiFrames.money.bagshuiData.texts) do
					text:SetTextColor(self.settings.groupLabelDefault[1], self.settings.groupLabelDefault[2], self.settings.groupLabelDefault[3], self.settings.groupLabelDefault[4])
				end
			else
				uiFrames.money:Hide()
				-- Move the hearthstone button to the money frame's position.
				_, hearthButtonAnchorToFrame, hearthButtonAnchorToPoint = uiFrames.money:GetPoint(1)
			end

			-- Show/hide Hearthstone button.
			if
				self.hearthButton
				and self.settings.showFooter
				and self.settings.showHearthstone
				and self.hearthstoneItemRef
			then
				uiButtons.toolbar.hearthstone:SetPoint(
					"RIGHT",
					hearthButtonAnchorToFrame,
					hearthButtonAnchorToPoint,
					uiButtons.toolbar.hearthstone.bagshuiData.defaultXOffset,
					0
				)
				uiButtons.toolbar.hearthstone:Show()

				-- Display cooldown.
				local cooldownStart, cooldownDuration, isOnCooldown = _G.GetContainerItemCooldown(self.hearthstoneItemRef.bagNum, self.hearthstoneItemRef.slotNum)
				self.ui:SetIconButtonCooldown(uiButtons.toolbar.hearthstone, cooldownStart, cooldownDuration, isOnCooldown)

			else
				uiButtons.toolbar.hearthstone:Hide()
			end

			-- Apply bag bar scaling and opacity.
			local bagBarScale = (itemSlotSize / uiButtons.itemSlots[1].bagshuiData.originalSizeAdjusted) * BsSkin.bagBarScale
			uiFrames.bagBar:SetScale(bagBarScale)
			-- Invert scaling for available space display so text is the normal size.
			uiFrames.spaceSummary:SetScale(1 / bagBarScale)
			-- Invert scaling for borders if needed.
			-- If bag bar scaling was reworked to scale the individual buttons, Ui:SetItemButtonSize()
			-- could be used to handle this automatically, but that refactor is not happening now.
			if BsSkin.itemSlotBorderInverseScale then
				for _, bagSlotButton in ipairs(self.ui.buttons.bagSlots) do
					bagSlotButton.bagshuiData.buttonComponents.border:SetScale(1 / bagBarScale)
				end
			end


			-- Determine footer height based on whether the bag bar is visible.
			local footerHeight = self.settings.showBagBar
				and (uiButtons.itemSlots[1].bagshuiData.originalSizeAdjusted * bagBarScale)  -- Bag bar visible.
				or (BsSkin.inventoryHeaderFooterHeight)  -- Bag bar hidden.

			uiFrames.footer:SetHeight(footerHeight)
			uiFrames.footer:Show()

			-- Update window height.
			finalWindowHeight =
				finalWindowHeight
				+ footerHeight
				+ BsSkin.inventoryHeaderFooterYAdjustment

		else
			-- When the footer is hidden, the main frame needs to anchor to the UI frame instead.
			uiFrames.main:SetPoint("BOTTOM", self.uiFrame, "BOTTOM", 0, BsSkin.inventoryWindowPadding)
			uiFrames.footer:Hide()
		end

		-- We can finally size the window frame.
		self.uiFrame:SetWidth(math.max(finalWindowWidth, BsSkin.inventoryWindowMinWidth))
		self.uiFrame:SetHeight(finalWindowHeight)

		-- Set scale and anchor for docked frame.
		if self.dockTo then
			-- Scaling of docked frames is accomplished by scaling the Main frame, then changing the
			-- dimensions of the window frame. This is done instead of just scaling self.uiFrame to keep
			-- the window border looking the same as the frame it's docked to; it looks a little weird if
			-- the border of the docked frame is shrunk.
			local dockedFrameScale = BsSkin.inventoryDockedScale * Bagshui.components[self.dockTo].uiFrame:GetScale()
			self.ui.frames.main:SetScale(dockedFrameScale)
			self.uiFrame:SetWidth(finalWindowWidth * dockedFrameScale)
			self.uiFrame:SetHeight(finalWindowHeight * dockedFrameScale)

			-- Determine how to anchor the docked window based on how the parent window is docked.
			self.uiFrame:ClearAllPoints()
			local anchorY = "BOTTOM"
			local anchorX = "RIGHT"
			local anchorToY = "TOP"
			local anchorToX = "RIGHT"
			local xOffset = 0
			local yOffset = -4

			if Bagshui.components[self.dockTo].settings.windowAnchorXPoint == "LEFT" then
				anchorX = "LEFT"
				anchorToX = "LEFT"
			end

			if Bagshui.components[self.dockTo].settings.windowAnchorYPoint == "TOP" then
				anchorY = "TOP"
				anchorToY = "BOTTOM"
				yOffset = -yOffset
			end

			self.uiFrame:SetPoint(
				anchorY .. anchorX,
				Bagshui.components[self.dockTo].uiFrame,
				anchorToY .. anchorToX,
				xOffset,
				yOffset
			)

		else
			-- Set scale and anchor for non-docked frame.
			self.uiFrame:SetScale(self.settings.windowScale)
			-- Ensure the window stays in the right place as it resizes.
			-- WoW will change the anchor point to TOPLEFT when the frame is dragged, so we need to reset it.
			self:FixWindowPosition()
		end

	end

	-- Check for mouse over state for interact-able elements to ensure tooltips stay current.
	Bagshui:QueueClassCallback(self, self.ItemSlotAndGroupMouseOverCheck)

	-- Reset statuses.
	self.lastExpandEmptySlotStacks = self.expandEmptySlotStacks
	self.windowUpdateNeeded = false
end



--- Fill the given UI group frame with the items assigned to the given group.
---@param groupId number ID of the group to which items should be assigned.
---@param uiGroupNum number Frame in the `self.ui.frames.groups` table to use for display.
---@param currentItemSlotButtonNum number Frame in the `self.ui.frames.buttons.itemSlots` table to use next.
---@param groupWidthInItems number Count of items to place on each row of the group.
---@param groupPadding number Padding between group edge and item slots.
---@param itemSlotSize number Height/width of the item slot button.
---@param itemSlotMargin number Margin around the outer edge of each item slot button.
---@return any currentItemSlotButtonNum Index of the last frame from `self.ui.frames.buttons.itemSlots` that was used.
function Inventory:AssignItemsToSlots(
	groupId,
	uiGroupNum,
	currentItemSlotButtonNum,
	groupWidthInItems,
	groupPadding,
	itemSlotSize,
	itemSlotMargin
)
	-- self:PrintDebug(string.format("AssignItemsToSlots() groupId=%s uiGroupNum=%s groupWidthInItems=%s", groupId, uiGroupNum, groupWidthInItems))

	local itemsPlacedInCurrentRow = 0
	local rowNum = 0
	local genericBagType
	local button
	local isEmptySlotStack

	-- We need the real item count here to be able to step through all items.
	-- (Using the count for layout from upstream won't work if empty slot
	-- stacking is on because we can end up missing items).
	local groupItemCount = table.getn(self.groupItems[groupId])

	-- Make sure there are items to assign in this group.
	if groupItemCount > 0 then

		local buttons = self.ui.buttons
		local frames = self.ui.frames

		local groupFrame = frames.groups[uiGroupNum]

		-- Prepare for layout
		local initialOffset = groupPadding + itemSlotMargin
		self:InitFramePositioningTable(
			"AssignItemsToSlots",  -- Position tracking table
			itemSlotMargin,        -- Frame X spacing
			itemSlotMargin,        -- Frame Y spacing
			groupFrame,            -- Initial frame to anchor to
			-initialOffset,        -- Initial X offset
			initialOffset          -- Initial Y offset
		)

		-- Update empty slot stack count for this group.
		if self.emptySlotStackingAllowed then
			self:CountEmptySlots(groupId)
		end

		-- Need to go in reverse because we're building right to left.
		local firstItem = groupItemCount
		local lastItem = 1
		local step = -1
		local item = nil
		local hideItem = false
		for position = firstItem, lastItem, step do

			-- Grab the item info.
			item = self.groupItems[groupId][position]
			genericBagType = self.containers[item.bagNum].genericType

			-- Item hiding and empty slot handling
			hideItem = false
			isEmptySlotStack = false

			-- Empty slot stacking.
			if
				self.emptySlotStackingAllowed  -- Empty slot stacking must be on.
				and item.emptySlot == 1  -- This item must be an empty slot.
				and not item._bagshuiPreventEmptySlotStack  -- This slot must not be temporarily blocked from stacking (usually if it just became empty and re-sorting hasn't occurred yet).
			then
				-- We've already shown one empty slot of this type in this group, so hide all the others.
				if self.emptySlotStacks[genericBagType].displayed then
					hideItem = true
				else
					-- Prevent any more empty slots of this generic container type from appearing in this group.
					self.emptySlotStacks[genericBagType].displayed = true
					-- Override the normal empty slot item with the stack so the count displays.
					item = self.emptySlotStacks[genericBagType]
					isEmptySlotStack = true
				end
			end

			-- Determine whether this item is hidden.
			if not self.editMode and not self.showHidden and self.hideItems[item.id] then
				hideItem = true
			end


			if not hideItem then
				-- Ensure slot button exists.
				self.ui:CreateInventoryItemSlotButton(currentItemSlotButtonNum)

				button = buttons.itemSlots[currentItemSlotButtonNum]

				-- Ensure parentage of item slot button is set to current group frame.
				-- This is required to get the layering right -- without it, stuff can end up behind groups.
				button:SetParent(groupFrame)

				-- Record details of this button's assignments so we can access
				-- them during UI events.
				button.bagshuiData.groupId = groupId
				button.bagshuiData.position = position
				-- These always need to refer to the original item's location so
				-- empty slot stacks magically work with click events
				button.bagshuiData.bagNum = self.groupItems[groupId][position].bagNum
				button.bagshuiData.slotNum = self.groupItems[groupId][position].slotNum
				button.bagshuiData.isEmptySlotStack = isEmptySlotStack

				-- Display the item slot button.
				self:ShowFrameInNextPosition(
					"AssignItemsToSlots",
					rowNum,
					button,
					itemSlotSize
				)

				-- Add the item to the button (texture, tooltip, etc.).
				self.ui:AssignItemToItemButton(button, item, groupId)

				-- Update tracking of whether there are highlight-able items.
				if item.bagshuiStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE then
					self.hasChanges = true
				end

				-- Increment counters.
				itemsPlacedInCurrentRow = itemsPlacedInCurrentRow + 1
				currentItemSlotButtonNum = currentItemSlotButtonNum + 1

				-- When we reach the end of a row, move to the next one.
				if itemsPlacedInCurrentRow == groupWidthInItems then
					itemsPlacedInCurrentRow = 0
					rowNum = rowNum + 1
				end
			end
		end
	end

	return currentItemSlotButtonNum
end



--- Call this before using `UpdateEmptySlotStackCount()` to zero the counts on the self.emptySlotStacks items
---@param resetBagsRepresented boolean? Clear the `_bagsRepresented` property of the empty slot stack items. Should only be called with `true` once per window update.
function Inventory:ResetEmptySlotStackCounts(resetBagsRepresented)
	for _, emptySlotStack in pairs(self.emptySlotStacks) do
		emptySlotStack.count = 0
		emptySlotStack.displayed = false
		if resetBagsRepresented then
			BsUtil.TableClear(emptySlotStack._bagsRepresented)
		end
	end
end



--- Loop through all items in a group and add their counts to the appropriate empty
--- slot stack using `UpdateEmptySlotStackCount()`
---@param groupId number ID of group to count empty slots for.
function Inventory:CountEmptySlots(groupId)
	self:ResetEmptySlotStackCounts()
	for _, item in pairs(self.groupItems[groupId]) do
		self:UpdateEmptySlotStackCount(item)
	end
end



--- Determine whether a slot is empty, and if so, add 1 to the appropriate per-bag-type empty slot stack.
---@param item table Bagshui inventory cache entry.
---@return boolean # true if the item is an empty slot.
function Inventory:UpdateEmptySlotStackCount(item)
	-- Only increment the count for slots that are empty AND not temporarily prevented from stacking.
	if item.emptySlot == 1 and not item._bagshuiPreventEmptySlotStack then
		-- genericType SHOULD be filled in, but let's just be sure.
		local genericBagType = self.containers[item.bagNum].genericType or BsGameInfo.itemSubclasses.Container.Bag
		-- Increment the count.
		self.emptySlotStacks[genericBagType].count = self.emptySlotStacks[genericBagType].count + 1
		-- Record that the bag containing this item is represented by this stack
		-- (used during container mouseover slot highlighting).
		self.emptySlotStacks[genericBagType]._bagsRepresented[item.bagNum] = true
		-- Return true so calling functions can know the item is an empty slot.
		return true
	end
	return false
end



--- Return the number of items in a group that will be visible, accounting for stacked slots and hidden items.  
--- Also updates `self.hasHiddenItems`.
---@param groupId number ID of group to get the number of items for.
---@return integer visibleItemCount
function Inventory:GetGroupItemCountForLayout(groupId)
	-- No items.
	if not self.groupItems[groupId] then
		return 0
	end

	-- Quickly return real count when we're in Edit Mode since nothing can be hidden.
	if self.editMode then
		return table.getn(self.groupItems[groupId])
	end

	-- Slot stacking / item hiding is enabled, so prepare for more complex counting.
	local visibleItemCount = 0
	local itemVisible
	local hasEmptySlots = false

	-- We'll be using the permanent self.emptySlotStacks items, so reset their counts first.
	self:ResetEmptySlotStackCounts()

	-- Count up the number of visible items while figuring out if there are any empty slots or hidden items.
	for _, item in ipairs(self.groupItems[groupId]) do
		-- Assume the item will be counted
		itemVisible = true

		-- Empty slot stacks and hidden items.
		if self:UpdateEmptySlotStackCount(item) then
			-- This is an empty slot stack, which we know because in addition to
			-- updating the appropriate empty slot stack proxy item in self.emptySlotsStacks,
			-- UpdateEmptySlotStackCount() returns true if the given item is an empty slot.
			if self.emptySlotStackingAllowed then
				itemVisible = false
				hasEmptySlots = true
			end

		elseif self.hideItems[item.id] then
			-- Hidden items.
			-- We need to update hasHiddenItems even if we're not actually hiding this item so that the toolbar icon will be enabled.
			self.hasHiddenItems = true
			-- Need to count the item when in Edit Mode or hidden items are shown.
			itemVisible = (self.editMode or self.showHidden)
		end

		-- Increment count if visible.
		if itemVisible then
			visibleItemCount = visibleItemCount + 1
		end
	end

	-- Add 1 for each empty slot stack that contains 1 or more slots.
	if hasEmptySlots then
		for _, emptySlotStack in pairs(self.emptySlotStacks) do
			if emptySlotStack.count > 0 then
				visibleItemCount = visibleItemCount + 1
			end
		end
	end

	return visibleItemCount
end



--- Prepare a layout table to be used by `ShowFrameInNextPosition()`.
---@param positioningTableName string Identifier for this positioning table that will also be passed to `ShowFrameInNextPosition()`.
---@param frameXSpacing number Horizontal space between frames.
---@param frameYSpacing number Vertical space between frames.
---@param initialAnchorToFrame table Frame to which the first frame should be attached.
---@param initialXOffset number Horizontal space between initialAnchorToFrame and first frame.
---@param initialYOffset number Vertical space between initialAnchorToFrame and first frame.
function Inventory:InitFramePositioningTable(
	positioningTableName,
	frameXSpacing,
	frameYSpacing,
	initialAnchorToFrame,
	initialXOffset,
	initialYOffset
)
	-- Set up positioning variable storage.
	-- The table doesn't need to be cleared if it already exists because all its values will be reset below.
	if self.positioningTables[positioningTableName] == nil then
		self.positioningTables[positioningTableName] = {}
	end
	local positioningTable = self.positioningTables[positioningTableName]

	-- Define anchor points and spacing.
	positioningTable.anchorXPoint = self.settings.windowContentAlignment
	positioningTable.anchorLeft = positioningTable.anchorXPoint == "LEFT"
	positioningTable.anchorToPointXRowStart = "TOP" .. positioningTable.anchorXPoint
	positioningTable.anchorToPointXSubsequent = "BOTTOM" .. BsUtil.FlipAnchorPoint(positioningTable.anchorXPoint)
	positioningTable.frameXSpacing = frameXSpacing
	positioningTable.frameYSpacing = frameYSpacing

	-- Track the current row so we know when to move to a new one.
	positioningTable.currentRow = nil

	-- Each time we move to a new row, this is the frame the first element of the new row will anchor to.
	positioningTable.firstVisibleFrameInPreviousRow = nil

	-- The very first frame anchors to the bottom corner of the given frame.
	positioningTable.anchorPoint = "BOTTOM" .. positioningTable.anchorXPoint
	positioningTable.initialAnchorToFrame = initialAnchorToFrame
	positioningTable.anchorToFrame = initialAnchorToFrame
	positioningTable.anchorToPoint = positioningTable.anchorPoint

	-- These are the initial values for X and Y offsets.
	positioningTable.anchorXOffset = initialXOffset
	positioningTable.anchorYOffset = initialYOffset
end



--- Helper function for `UpdateWindow()` to manage the process of displaying the grid of
--- groups and items within those groups at the correct location.
---@param positioningTableName string Identifier for this positioning table that was prepared in `InitFramePositioningTable()`.
---@param rowNum number Current row number.
---@param frame table Frame to display.
---@param width number Frame width.
---@param height number? Frame height (will use width if not specified).
---@param scale number? Frame scale.
function Inventory:ShowFrameInNextPosition(
	positioningTableName,
	rowNum,
	frame,
	width,
	height,
	scale
)
	local positioningTable = self.positioningTables[positioningTableName]

	assert(positioningTable, "Inventory:ShowFrameInNextPosition(): Positioning table '" .. tostring(positioningTableName) .. "' has not been initialized; must call InitFramePositioningTable() first!")

	-- self:PrintDebug(
	-- 	"Showing " .. frame:GetName() .. " for row " .. rowNum
	-- 	.. "\nAnchor point:" .. positioningTable.anchorPoint
	-- 	.. "\nAnchor frame:" .. positioningTable.anchorToFrame:GetName()
	-- 	.. "\nAnchor frame point:" .. positioningTable.anchorToPoint
	-- 	.. "\nX offset:" .. (positioningTable.anchorLeft and -positioningTable.anchorXOffset or positioningTable.anchorXOffset)
	-- 	.. "\nY offset:" .. positioningTable.anchorYOffset
	-- 	.. "\nWidth" .. width
	-- 	.. "\nHeight" .. height
	-- 	.. "\nScale" .. tostring(scale)
	-- )

	-- Is this a new row?
	-- nil check is so this only happens once we're above the first row.
	if positioningTable.currentRow ~= nil and positioningTable.currentRow ~= rowNum then
		-- Anchor to the first frame in the previous row.
		positioningTable.anchorToFrame = positioningTable.firstVisibleFrameInPreviousRow
		positioningTable.anchorToPoint = positioningTable.anchorToPointXRowStart
		positioningTable.anchorXOffset = 0
		-- First frame in the row needs to be higher up.
		positioningTable.anchorYOffset = positioningTable.frameYSpacing
	end

	-- Display the frame.
	self:SizeAndShowFrame(
		frame,
		positioningTable.anchorPoint,
		positioningTable.anchorToFrame,
		positioningTable.anchorToPoint,
		positioningTable.anchorLeft and -positioningTable.anchorXOffset or positioningTable.anchorXOffset,
		positioningTable.anchorYOffset,
		width,
		height,
		scale,
		-positioningTable.frameXSpacing  -- HitRectInsets
	)

	-- The next element in a row always anchors to the previous one.
	positioningTable.anchorToFrame = frame

	-- When we move to a new row, update positioning variables to the proper state for anchoring within the same row.
	if positioningTable.currentRow ~= rowNum then
		-- Update the row number of the tracking variable so we know we've found the first visible element in this row.
		positioningTable.currentRow = rowNum
		-- Change the anchor point for subsequent frames.
		positioningTable.anchorToPoint = positioningTable.anchorToPointXSubsequent
		-- Subsequent frames in this row will be spaced using the frameXSpacing set by InitFramePositioningTable().
		positioningTable.anchorXOffset = -positioningTable.frameXSpacing
		-- Subsequent frames in this same row should be at the same vertical offset.
		positioningTable.anchorYOffset = 0
		-- Keep a note of the first frame int this row because the first frame in the next row will anchor to it.
		positioningTable.firstVisibleFrameInPreviousRow = frame
	end
end



-- SizeAndShowFrame() gets called a LOT so let's reuse variables to cut down on garbage collection.
local sizeAndShow_frame, sizeAndShow_finalScale, sizeAndShow_inverseScale, sizeAndShow_sizeWasSetViaScaling

--- Display the given frame at the specified position and size.
---@param frameObjOrName table|string Frame or name of frame.
---@param frameAttachPoint string Point on `frameObjOrName` that should be be attached.
---@param attachToFrame table|string Frame to which `frameObjOrName` should be attached.
---@param attachToPoint string Point on `attachToFrame` to which `frameObjOrName` should be attached..
---@param xOffset number? Horizontal offset for `frameObjOrName` (negative for left).
---@param yOffset number? Vertical offset for `frameObjOrName` (negative for down).
---@param width number Width of the frame.
---@param height number? Height of the frame (will use width if not specified).
---@param scale number? Scaling factor (0 - 1) that should be applied to the frame.
---@param hitRectInsets number? Hit rectangle insets to should be applied to the frame.
function Inventory:SizeAndShowFrame(
	frameObjOrName,
	frameAttachPoint,
	attachToFrame,
	attachToPoint,
	xOffset,
	yOffset,
	width,
	height,
	scale,
	hitRectInsets
)
	-- Get the frame object.
	sizeAndShow_frame = frameObjOrName
	if type(frameObjOrName) == "string" then
		sizeAndShow_frame = _G[frameObjOrName]
	end

	assert(sizeAndShow_frame ~= nil, "Invalid frame '" .. tostring(frameObjOrName) .. "' provided to SizeAndShowFrame().")

	-- When an item slot button is sized by calling SetItemButtonSize, calling SetWidth/SetHeight isn't necessary.
	sizeAndShow_sizeWasSetViaScaling = false

	-- Item slot buttons should always be sized by scaling if possible, so do it automatically.
	if not scale and sizeAndShow_frame.bagshuiData and sizeAndShow_frame.bagshuiData.type == BS_UI_ITEM_BUTTON_TYPE.ITEM then
		scale = self.ui:SetItemButtonSize(sizeAndShow_frame, width)
		sizeAndShow_sizeWasSetViaScaling = scale ~= nil
	end

	-- We need to know both the scale factor to apply to the frame and the inverse scale,
	-- because SetPoint() uses the frame scale for offsets, so we need to un-scale the offsets.
	sizeAndShow_finalScale = scale or 1
	sizeAndShow_inverseScale = 1/sizeAndShow_finalScale

	-- Normal behavior -- set height, width, and scale.
	if not sizeAndShow_sizeWasSetViaScaling then
		sizeAndShow_frame:SetWidth(width)
		sizeAndShow_frame:SetHeight(height or width)
		sizeAndShow_frame:SetScale(sizeAndShow_finalScale)
	end

	-- Move frame to the specified point.
	sizeAndShow_frame:ClearAllPoints()
	sizeAndShow_frame:SetPoint(
		frameAttachPoint,
		attachToFrame,
		attachToPoint,
		xOffset * sizeAndShow_inverseScale,
		yOffset * sizeAndShow_inverseScale
	)

	-- Adjust hit rectangle insets.
	if hitRectInsets then
		sizeAndShow_frame:SetHitRectInsets(hitRectInsets, hitRectInsets, hitRectInsets, hitRectInsets)
	end

	sizeAndShow_frame:Show()

	-- For some reason, an initial call to GetTop() is sometimes necessary to prevent it
	-- from returning nil later.
	sizeAndShow_frame:GetTop()
end



--- Automatically select the next Group Move Target based on groupMoveTargetCount,
--- creating it if needed, then display using `ShowFrameInNextPosition()`
---@param width number Desired width of the group move target.
---@param height number Desired height of the group move target.
---@param uiRowNum number Current row number within the UI layout.
---@param layoutRowNum number Current layout/structure row number that the group move target should act on.
---@param layoutColumnNum number Current layout/structure column number that the group move target should act on.
---@param insertType BS_INVENTORY_LAYOUT_DIRECTION Whether the roup move target should act on rows or columns.
function Inventory:ShowNextGroupMoveTarget(
	width,
	height,
	uiRowNum,
	layoutRowNum,
	layoutColumnNum,
	insertType
)
	-- Increment count of targets and create a new one if needed.
	self.groupMoveTargetCount = self.groupMoveTargetCount + 1
	self.ui:CreateGroupMoveTarget(self.groupMoveTargetCount)

	local groupMoveTarget = self.ui.frames.groupMoveTargets[self.groupMoveTargetCount]

	-- Snag the button within the group move target frame so we can resize it and set properties.
	local button = self.ui.frames.groupMoveTargets[self.groupMoveTargetCount].bagshuiData.button

	-- This information will be pulled when the group move target button is clicked.
	button.bagshuiData.insert = insertType
	button.bagshuiData.rowNum = layoutRowNum
	button.bagshuiData.columnNum = layoutColumnNum

	-- Select button offsets based on whether the group is horizontal or vertical (start by assuming vertical).
	local xOffsetLeft = BsSkin.groupMoveTargetAnchorOffset
	local xOffsetRight = xOffsetLeft
	local yOffset = BsSkin.groupMoveTargetLongDimensionSubtraction
	if width > height then
		-- This one is horizontal.
		xOffsetRight = -(BsSkin.groupMoveTargetLongDimensionSubtraction + BsSkin.groupMoveTargetThinDimension + 1)
		xOffsetLeft = xOffsetRight - BsSkin.groupMoveTargetAnchorOffset * 2
		yOffset = -BsSkin.groupMoveTargetAnchorOffset
	end

	-- Set button offsets so the move target is visually shorter than the height/width of the groups.
	button:SetPoint(
		"TOPLEFT",
		groupMoveTarget,
		"TOPLEFT",
		-xOffsetLeft,
		-yOffset
	)
	button:SetPoint(
		"BOTTOMRIGHT",
		groupMoveTarget,
		"BOTTOMRIGHT",
		xOffsetRight,
		yOffset
	)

	-- Display the frame.
	self:ShowFrameInNextPosition(
		"UpdateWindow",
		uiRowNum,
		groupMoveTarget,
		width,
		height
	)

end



--- Update free/available slot counts. Subclasses should override for special bag bar stuff.
function Inventory:UpdateBagBar()

	local shouldShowSpaceInformation = false

	-- We always need to do one loop through the bag buttons to refresh the appearance and make some decisions.
	for _, bagSlotButton in ipairs(self.ui.buttons.bagSlots) do

		-- Set button textures -- necessary for them to be correct when viewing another character's inventory.
		_G.SetItemButtonTexture(bagSlotButton, self.containers[bagSlotButton.bagshuiData.bagNum].texture)

		-- Locked highlight border.
		if self.highlightItemsInContainerLocked == bagSlotButton.bagshuiData.bagNum then
			bagSlotButton.bagshuiData.buttonComponents.border:SetBackdropBorderColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotBorderContainerHighlightOpacity
			)
			bagSlotButton.bagshuiData.buttonComponents.innerGlow:SetVertexColor(
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[1],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[2],
				BS_COLOR.ITEM_SLOT_HIGHLIGHT[3],
				BsSkin.itemSlotInnerGlowOpacity + 0.2
			)
			bagSlotButton.bagshuiData.highlightBorderApplied = true

		elseif self.highlightItemsInContainerLocked ~= bagSlotButton.bagshuiData.bagNum then
			bagSlotButton.bagshuiData.buttonComponents.border:SetBackdropBorderColor(
				BsSkin.itemSlotBorderDefaultColor.r,
				BsSkin.itemSlotBorderDefaultColor.g,
				BsSkin.itemSlotBorderDefaultColor.b,
				BsSkin.itemSlotBorderOpacity
			)
			bagSlotButton.bagshuiData.buttonComponents.innerGlow:SetVertexColor(
				0, 0, 0, 0
			)
			bagSlotButton.bagshuiData.highlightBorderApplied = false

		end

		-- Offline icon texture opacity.
		bagSlotButton.bagshuiData.buttonComponents.iconTexture:SetVertexColor(
			BS_COLOR.ITEM_SLOT_STATE_NORMAL[1],
			BS_COLOR.ITEM_SLOT_STATE_NORMAL[2],
			BS_COLOR.ITEM_SLOT_STATE_NORMAL[3],
			(
				not self.online
				and BsSkin.itemSlotTextureOfflineOpacity
				or 1
			)
		)

		-- Overall button opacity.
		bagSlotButton:SetAlpha(
			self.editMode
			and 0.2
			-- When an item in the inventory is moused over, we want to dim everything but the container it's in.
			or (
				self.hoveredItem
				and (
					(
						-- Empty slot stack.
						self.hoveredItem._bagsRepresented
						and self.hoveredItem._bagsRepresented[bagSlotButton.bagshuiData.bagNum]
						-- Normal item.
						or self.hoveredItem.bagNum == bagSlotButton.bagshuiData.bagNum
					) and 1
					or 0.4
				)
			)
			-- When the container highlight is locked on, dim other bags.
			or (
				(
					self.highlightItemsInContainerLocked
					and self.highlightItemsInContainerLocked ~= bagSlotButton.bagshuiData.bagNum
				)
				and 0.7
			)
			-- No item currently hovered.
			or 1
		)

		-- Display free space information when the mouse is over any button.
		if bagSlotButton.bagshuiData.mouseIsOver then
			shouldShowSpaceInformation = true
		end

	end

	-- Also display free space information when the mouse is over the summary area.
	if self.ui.frames.spaceSummary.bagshuiData.mouseIsOver then
		shouldShowSpaceInformation = true
	end

	-- Cancel free space display in Edit Mode.
	if self.editMode then
		shouldShowSpaceInformation = false
	end

	-- Width of bag space summary text area to the right of the bag bar that will be added
	-- to the overall bag bar width.
	local summaryWidth = 0

	-- Don't bother with calculations if space information isn't going to be shown.
	if shouldShowSpaceInformation then

		-- Reset space tracking - don't need to worry about whether the table members
		-- are initialized because that's handled below. Here we're only iterating over
		-- what already exists.
		for _, spaceInfo in pairs(self.containerSpace) do
			spaceInfo.available = 0
			spaceInfo.used = 0
			spaceInfo.total = 0
		end
		self.availableSlots, self.usedSlots, self.totalSlots = 0, 0, 0

		-- Gether free space information.
		for _, bagSlotButton in ipairs(self.ui.buttons.bagSlots) do
			-- Step through bag slot buttons and determine available/used/total space.
			local container = self.containers[bagSlotButton.bagshuiData.bagNum]
			local available, used = 0, 0
			local slotText = ""
			if container.numSlots > 0 then
				used = container.slotsFilled
				if container.slotsFilled < container.numSlots then
					available = container.numSlots - used
					slotText = string.format("%s/%s", used, container.numSlots)
				else
					slotText = L.Full
				end
			end
			bagSlotButton.bagshuiData.buttonComponents.stock:SetText(slotText)
			bagSlotButton.bagshuiData.buttonComponents.stock:Show()

			local genericType = container.genericType or BsGameInfo.itemSubclasses["Container"]["Bag"]

			-- Initialize space tracking if needed.
			if not self.containerSpace[genericType] then
				self.containerSpace[genericType] = {
					available = 0,
					used = 0,
					total = 0
				}
			end

			-- Update calculations.
			local spaceInfo = self.containerSpace[genericType]
			spaceInfo.available = spaceInfo.available + available
			spaceInfo.used = spaceInfo.used + used
			spaceInfo.total = spaceInfo.total + container.numSlots
			self.availableSlots = self.availableSlots + available
			self.usedSlots = self.usedSlots + used
			self.totalSlots = self.totalSlots + container.numSlots
		end

		-- Set text.
		self.ui.frames.spaceSummary.bagshuiData.text:SetText(self.availableSlots)
		self.ui.frames.spaceSummary.bagshuiData.text:SetTextColor(self.settings.groupLabelDefault[1], self.settings.groupLabelDefault[2], self.settings.groupLabelDefault[3], self.settings.groupLabelDefault[4])
		self.ui.frames.spaceSummary.bagshuiData.subtext:SetText(string.format("%s/%s", self.usedSlots, self.totalSlots))
		self.ui.frames.spaceSummary.bagshuiData.subtext:SetTextColor(self.settings.groupLabelDefault[1], self.settings.groupLabelDefault[2], self.settings.groupLabelDefault[3], self.settings.groupLabelDefault[4])

		-- Resize and show/hide.
		summaryWidth = math.max(self.ui.frames.spaceSummary.bagshuiData.text:GetStringWidth(), self.ui.frames.spaceSummary.bagshuiData.subtext:GetStringWidth())
		self.ui.frames.spaceSummary:SetWidth(summaryWidth)
		self.ui.frames.spaceSummary:SetAlpha(1)  -- Reversing the SetAlpha(0) call that happens when we hide the summary.

	else
		-- Hide totals.
		for _, bagSlotButton in ipairs(self.ui.buttons.bagSlots) do
			bagSlotButton.bagshuiData.buttonComponents.stock:Hide()
		end

		-- Hide space summary.
		self.ui.frames.spaceSummary:SetAlpha(0)  -- Using SetAlpha() instead of Hide() so it's still responsive to mouseover.
	end

	-- Set the Bag Bar to the correct width.
	self.ui.frames.bagBar:SetWidth(
		self.ui.frames.bagBar.bagshuiData.baseWidth
		+ (math.max(summaryWidth, 15) * self.ui.frames.spaceSummary:GetScale())
		+ 10  -- Buffer so nothing gets cut off.
	)
end



--- Enable/disable/highlight toolbar buttons as appropriate.
function Inventory:UpdateToolbar()
	local toolbarButtons = self.ui.buttons.toolbar

	-- Resort icon.
	self:SetToolbarButtonState(
		toolbarButtons.resort,
		nil,
		(
			self.enableResortIcon
			or (
				-- Docked inventory needs resorting.
				self.dockedInventory
				and self.dockedInventory.enableResortIcon
			)
		)
	)

	-- Restack icon.
	self:SetToolbarButtonState(
		toolbarButtons.restack,
		nil,
		(
			self.multiplePartialStacks
			or (
				-- Docked inventory has needs restack.
				self.dockedInventory
				and self.dockedInventory.multiplePartialStacks
			)
		)
	)

	-- Show/Hide icon.
	self:SetToolbarButtonState(
		toolbarButtons.showHide,
		nil,
		(self.hasHiddenGroups or self.hasHiddenItems) and not self.editMode,
		self.showHidden,
		L.Toolbar_Hide_TooltipTitle,
		L.Toolbar_Show_TooltipTitle
	)

	-- Highlight Changes icon.
	self:SetToolbarButtonState(
		toolbarButtons.highlightChanges,
		nil,
		self.hasChanges and not self.editMode,
		self.highlightChanges,
		L.Toolbar_UnHighlightChanges_TooltipTitle,
		L.Toolbar_HighlightChanges_TooltipTitle
	)

	-- Character icon.
	self:SetToolbarButtonState(
		toolbarButtons.character,
		nil,
		table.getn(BsCharacterData.characterIdList) > 1,  -- Only enable when there's more than one character.
		self.activeCharacterId ~= Bagshui.currentCharacterId
	)

	-- Lock highlights for inventories when they're open.
	for inventoryType, _ in self:OtherInventoryTypesInToolbarIconOrder(true) do
		self:SetToolbarButtonState(
			toolbarButtons[inventoryType],
			nil,
			true,
			Bagshui.components[inventoryType]:Visible()
		)
	end
	-- Catalog.
	self:SetToolbarButtonState(
		toolbarButtons.catalog,
		nil,
		true,
		BsCatalog:Visible()
	)

	-- Refresh toolbar button colors in case they've changed.
	for _, button in pairs(toolbarButtons) do
		self.ui:SetIconButtonColors(button)
	end

	-- State buttons.
	self:SetToolbarButtonState(toolbarButtons.offline, (not self.online))
	self:SetToolbarButtonState(toolbarButtons.error, (string.len(self.errorText or "") > 0))
	self:SetToolbarButtonState(toolbarButtons.editMode, self.editMode, nil, self.editMode)

	-- Error button needs its tooltip updated.
	toolbarButtons.error.bagshuiData.tooltipText = self.errorText

	-- Update status text.
	if self.editMode then
		-- Show active Structure profile name when editing.
		self.ui.text.status:SetText(
			NORMAL_FONT_COLOR_CODE .. string.format(L.Symbol_Colon, L.Profile_Structure) .. FONT_COLOR_CODE_CLOSE
			.. " " .. BsProfiles:GetName(self.settings.profileStructure)
		)
		self.ui.frames.status:Show()
		-- Move the offline character name into the tooltip in edit mode.
		toolbarButtons.offline.bagshuiData.tooltipText = GRAY_FONT_COLOR_CODE .. self.activeCharacterId .. FONT_COLOR_CODE_CLOSE
	else
		self.ui.text.status:SetText(self.activeCharacterId)
		if self.activeCharacterId ~= Bagshui.currentCharacterId then
			self.ui.frames.status:Show()
		else
			self.ui.frames.status:Hide()
		end
		-- Don't need the offline character name in the tooltip normally.
		toolbarButtons.offline.bagshuiData.tooltipText = nil
	end

	-- Re-anchor all toolbar widgets based on visibility.
	self:UpdateToolbarAnchoring(self.ui.ordering.leftToolbar, "LEFT")
	self:UpdateToolbarAnchoring(self.ui.ordering.rightToolbar, "RIGHT")

	-- Disable unusable stuff in Edit Mode.
	local editModeState = (self.editMode) and "Disable" or "Enable"
	-- Hearthstone
	if self.hearthButton then
		self.ui.buttons.toolbar.hearthstone[editModeState](self.ui.buttons.toolbar.hearthstone)
	end
	-- Search
	self.ui.buttons.toolbar.search[editModeState](self.ui.buttons.toolbar.search)

	-- Parent toolbar needs to sync state.
	if self.dockedToInventory then
		self.dockedToInventory:UpdateToolbar()
	end
end



--- Control the state and appearance of a toolbar button.
---@param button table Button object.
---@param visible boolean? Whether the button should be displayed.
---@param enable boolean? Whether the button should be enabled.
---@param lockHighlight boolean? Whether the button should be highlighted.
---@param lockedHighlightTooltip string? Tooltip title to display when the button highlight is locked.
---@param unlockedHighlightTooltip string? Tooltip title to display when the button highlight is unlocked.
function Inventory:SetToolbarButtonState(
	button,
	visible,
	enable,
	lockHighlight,
	lockedHighlightTooltip,
	unlockedHighlightTooltip
)

	if visible == nil then
		visible = true
	end
	button[visible and "Show" or "Hide"](button)

	if enable == nil then
		enable = true
	end
	button[enable and "Enable" or "Disable"](button)

	if lockHighlight then
		if lockedHighlightTooltip then
			button.bagshuiData.tooltipTitle = lockedHighlightTooltip
		end
		button:LockHighlight()
	else
		if unlockedHighlightTooltip then
			button.bagshuiData.tooltipTitle = unlockedHighlightTooltip
		end
		button:UnlockHighlight()
	end

	-- Update tooltip if it's visible so that text stays current.
	if
		button.bagshuiData.mouseIsOver
		and BsIconButtonTooltip:IsVisible()
		and BsIconButtonTooltip:IsOwned(button)
	then
		self.ui:ShowIconButtonTooltip(button, 0)
	end
end



--- Toolbar icons need their anchors updated based on what's shown.
---@param widgetList (table|number)[] WoW UI widgets, in display order. Numbers are spacing directives that override the default.
---@param anchorPoint "LEFT"|"RIGHT" Place to anchor each widget. This point will be anchored to the opposing point of the previous widget.
function Inventory:UpdateToolbarAnchoring(widgetList, anchorPoint)
	local defaultOffset = (anchorPoint == "RIGHT" and -1 or 1) * BsSkin.toolbarSpacing
	local nextOffset

	-- Go through the list of widgets in order, but skip the first one since
	-- that's only there as the left/rightmost anchor.
	for widgetPosition = 2, table.getn(widgetList) do
		local widget = widgetList[widgetPosition]
		-- Ignore spacing directives when finding widgets.
		if type(widget) == "table" and widget:IsShown() then
			-- Assume default spacing.
			nextOffset = defaultOffset
			-- Walk backwards through the list of widgets and anchor to the first visible one.
			for anchorPosition = widgetPosition - 1, 1, -1 do

				if type(widgetList[anchorPosition]) ~= "table" then
					-- Spacing directive found. Use this instead of the default.
					if type(widgetList[anchorPosition]) == "number" then
						nextOffset = widgetList[anchorPosition]
					end
				else
					-- Check visibility and update anchoring.
					local anchorButton = widgetList[anchorPosition]
					if anchorButton:IsShown() then
						widget:SetPoint(
							anchorPoint,
							anchorButton,
							BsUtil.FlipAnchorPoint(anchorPoint),
							nextOffset,
							0
						)
						break
					end
				end

			end  -- Inner anchor finding loop.
		end

	end -- Widget iteration.
end


--- It seems like the client doesn't always catch situations where frames move out from
--- under the cursor. When empty slots are expanded/collapsed, that's exactly what happens, so
--- we have to manually hide the tooltip (handled in `ItemButton_OnClick()`) and we also need to determine
--- if the mouse is over an item button **after** the UI is redrawn. To do that, `UpdateWindow()` queues a
--- call to this function on the next frame update. Then we can evaluate whether the mouse is present,
--- and if so, update the UI to reflect that.
--- This is also an issue when picking up and putting down Categories/Groups/Items in Edit Mode,
--- where we manually hide tooltips and need to make them reappear when something is put back down.
function Inventory:ItemSlotAndGroupMouseOverCheck()
	local mouseOverFound = false
	for _, button in self.ui.buttons.itemSlots do
		-- The IsVisible() check is needed because item slot frames that are hidden will still return true for MouseIsOver().
		if _G.MouseIsOver(button) and button:IsVisible() then
			self:ItemButton_OnEnter(button)
			mouseOverFound = true
			break
		end
	end
	if self.editMode and not mouseOverFound then
		for _, group in self.ui.frames.groups do
			if _G.MouseIsOver(group) and group:IsVisible() then
				self:Group_OnEnter(group)
			end
		end
	end
end



--- Look through the inventory cache to find and record references to any special items.
--- Currently only used for the Hearthstone.
function Inventory:FindSpecialItems()

	-- Reset Hearthstone item tracking.
	self.hearthstoneItemRef = nil
	self.hideItems[BS_INVENTORY_HEARTHSTONE_ITEM_ID] = (
			self.hearthButton
			and self.settings.showHearthstone
			and self.settings.showFooter
		) or nil

	for _, bagContents in pairs(self.inventory) do
		for __, item in ipairs(bagContents) do
			-- Check for Hearthstone.
			if self.hearthButton and item.id == BS_INVENTORY_HEARTHSTONE_ITEM_ID then
				self.hearthstoneItemRef = item
			end
		end
	end
end



--- Toggle an inventory class property.
--- Used to display/hide hidden items, enable/disable highlighting of changes,
--- maybe more in the future?
---@param propertyName any
function Inventory:ToggleProperty(propertyName)
	if not propertyName then
		return
	end
	_G.PlaySound("igMainMenuOptionCheckBox" .. (self[propertyName] and "Off" or "On"))
	self[propertyName] = not self[propertyName]
	self:ForceUpdateWindow()

	if self.dockedInventory then
		self.dockedInventory:ToggleProperty(propertyName)
	end
end


end)