-- Bagshui Inventory Prototype: Actions
-- Moving, equipping, making stuff happen.

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory


--- Clear all stock change indicators.
function Inventory:ResetStockState()
	for _, container in pairs(self.inventory) do
		for _, item in pairs(container) do
			item.bagshuiDate = 0
			item.bagshuiStockState = BS_ITEM_STOCK_STATE.NO_CHANGE
		end
	end
	-- Update the window, cascade to docked inventory, and force cache update.
	-- (Inventory:UpdateCache() is where hasChanges is updated).
	self:ForceUpdateWindow(true, true)
end



--- Return `true` if an item is protected from sale by the current settings.
---@param item table Bagshui inventory cache entry.
---@return string? protectionType Localized reason the item was protected ("Soulbound", "Quality", etc.), if any.
function Inventory:GetItemSellProtectionReason(item)
	-- Protection is completely disabled.
	if not self.settings.sellProtectionEnabled then
		return
	end

	-- Active Quest.
	if self.settings.sellProtectionActiveQuest and Bagshui.activeQuestItems[item.name] then
		return L.ItemPropFriendly_activeQuest
	end

	-- Soulbound.
	if self.settings.sellProtectionSoulbound and BsRules:Match("Soulbound()", item) then
		return L.ItemPropFriendly_soulbound
	end

	-- Equipped Gear.
	if self.settings.sellProtectionEquipped and BsCharacter.equippedHistory[item.itemString] then
		return L.EquippedGear
	end

	-- Quality at or above threshold.
	if (item.quality or 1) >= self.settings.sellProtectionQualityThreshold then
		return L.Quality
	end
end



--- Reset the pending sale of an item so it's no longer highlighted.
---@param itemButton table? If provided, call OnEnter for this item button to update the tooltip.
---@param noUpdate boolean? Don't call `Inventory:UpdateItemSlotColors()`.
function Inventory:ClearItemPendingSale(itemButton, noUpdate)
	self.itemPendingSale = nil
	self.highlightItemsInContainerId = nil
	self.highlightItemsContainerSlot = nil
	if itemButton then
		self:ItemButton_OnEnter(itemButton)
	end
	if not noUpdate then
		self:UpdateItemSlotColors()
	end
end



--- Sort and organize inventory while the window is open.
--- Used from toolbars, menus, and key bindings.
function Inventory:Resort()
	self.forceResort = true
	-- Do NOT use QueueUpdate() here.
	self:Update(true)
end



--- Initiate the restacking process.
--- This doesn't do the actual work; it just sets up a queue of restack operations,
--- which is necessary because there needs to be a slight delay between each operation.
--- That process is handled by ProcessMoveQueue().
function Inventory:Restack()
	-- Ensure inventory cache is up to date.
	self.cacheUpdateNeeded = true
	self:UpdateCache()

	-- This function can be called when a docked inventory has partial stacks
	-- but this one doesn't. The case where this one has partials and the docked
	-- one may or may not is handled once Inventory:ProcessMoveQueue() is done.
	if not self.multiplePartialStacks then
		if self.dockedInventory then
			self.dockedInventory:Restack()
		end
		return
	end

	-- Prepare the helper function for sorting partial stacks.
	if not self._PartialStackSortHelper then
		self._PartialStackSortHelper = function(itmA, itmB)
			return itmA.count > itmB.count
		end
	end

	-- Reset restack queues.
	self:ClearMoveQueue()

	-- Reset restack retry count (used by ProcessMoveQueue() to decide when to give up if items are locked).
	self.moveRetryCount = 0

	-- Find all the partial stacks.
	-- This will build out a table:
	-- ```
	-- {
	--   [itemId1] = {
	--     itemCacheReference1,
	--     itemCacheReference2,
	--     itemCacheReference3,
	--   }
	--   [itemId2] = {
	--     itemCacheReference4,
	--     itemCacheReference5,
	--   }
	-- }
	-- ```
	local allPartialStacks = {}
	for _, bagContents in pairs(self.inventory) do
		for _, item in ipairs(bagContents) do
			if (self.partialStacks[item.id] or 0) > 1 and item.count < item.maxStackCount then
				if allPartialStacks[item.id] == nil then
					allPartialStacks[item.id] = {}
				end
				table.insert(allPartialStacks[item.id], item)
			end
		end
	end

	-- Sort partial stack lists for each item from largest to smallest.
	for _, partialStacks in pairs(allPartialStacks) do
		table.sort(partialStacks, self._PartialStackSortHelper)
	end

	local target, source, oldTargetCount, sourceLoopStart

	-- Process each item's set of partial stacks in turn to create the restack queue.
	for _, partialStacks in pairs(allPartialStacks) do
		--self:PrintDebug("Restacking item ID " .. _)

		-- Sources are obtained starting from the end of the list since it's
		-- sorted largest to smallest and we're trying to move stacks with the
		-- lowest counts onto those with the highest counts.
		sourceLoopStart = table.getn(partialStacks)

		-- Likewise, targets are obtained from the beginning of the list.
		for targetIndex = 1, table.getn(partialStacks) - 1 do
			target = partialStacks[targetIndex]
			--self:PrintDebug("> starting target count: " .. target.count .. " (of max " .. target.maxStackCount .. " )")

			if target.count < target.maxStackCount then

				-- Work backwards through the list of partial stacks, potentially
				-- up to the next-to-first (which is the initial target, so we
				-- know we can never use it as a source).
				for sourceIndex = sourceLoopStart, 2, -1 do
					source = partialStacks[sourceIndex]
					--self:PrintDebug(">> source count: " .. source.count)

					if
						source ~= target
						and source.count > 0
						and target.count < target.maxStackCount
						and target.count > 0
					then

						-- Queue move of source stacks onto target.
						self:QueueMove(source, target)
						--self:PrintDebug(string.format(">>> queued %s:%s (%s) to %s:%s (%s)", source.bagNum, source.slotNum, source.count, target.bagNum, target.slotNum, target.count))

						-- Calculate the changes.
						oldTargetCount = target.count
						target.count = math.min(target.count + source.count, target.maxStackCount)
						source.count = source.count - (target.count - oldTargetCount)
						--self:PrintDebug(">> NEW source count: " .. source.count)
						--self:PrintDebug(">> NEW target count: " .. target.count)

						-- We're done with this source and can move on to the next one.
						if source.count == 0 then
							sourceLoopStart = sourceLoopStart - 1
						end

						-- Stop the inner loop if current target is maxed out.
						if target.count == target.maxStackCount then
							--self:PrintDebug(">> target maxed; breaking inner loop")
							break
						end

					end
				end
			end
		end
	end
	--self:PrintDebug(table.getn(self.queuedMoveSources) .. " moves queued")

	-- Reusable function for restacking docked Inventory class.
	if self.dockedInventory and not self.restack_callback then
		self.restack_callback = function()
			self.dockedInventory:Restack()
		end
	end

	-- Make the actual moves.
	self:MoveItems(self.restack_callback)
end



function Inventory:ClearMoveQueue()
	BsUtil.TableClear(self.queuedMoveSources)
	BsUtil.TableClear(self.queuedMoveTargets)
end


function Inventory:QueueMove(source, target)
	table.insert(self.queuedMoveSources, source)
	table.insert(self.queuedMoveTargets, target)
end



--- Perform queued item move operations.
--- 
--- 🚦 Before calling, the `Inventory.queuedMoveSources/Targets` arrays must be
--- filled with the corresponding items that should be moved. (There aren't any
--- functions to do this; just use `table.insert()`).
--- 
--- `Inventory:Restack()` is a good example of how to do this.
---@param onComplete function? Will receive one boolean parameter indicating the success or failure of the move operations.
---@param onProgress function? Will receive one number parameter indicating the current item in the list of moves that just completed.
---@param resortAfterEachMove boolean? Organize the inventory after every action.
function Inventory:MoveItems(onComplete, onProgress, resortAfterEachMove)
	-- Tracks the overall success of all operations in this session and is passed to `moveQueue_onComplete`.
	self.moveQueue_success = true
	-- Invoked when the move queue is empty and passed the success/failure status.
	self.moveQueue_onComplete = onComplete
	-- Used to calculate the current step for `moveQueue_onProgress()` since 
	self.moveQueue_totalItems = table.getn(self.queuedMoveSources)
	-- Invoked after each move and passed the number of the move.
	self.moveQueue_onProgress = onProgress
	-- Organize inventory after every move.
	self.moveQueue_resort = resortAfterEachMove
	-- Reset tracking.
	self.moveQueue_LastSource = nil
	self:ProcessMoveQueue()
end


--- # 🛑 Do not call directly; use `Inventory:MoveItems()` 🛑.
--- Recursive item mover with delayed retry on fail.
--- Utilizes the class properties that are set by `Inventory:MoveItems()`.
function Inventory:ProcessMoveQueue()

	--self:PrintDebug("Starting ProcessMoveQueue()")

	-- Are we done?
	if table.getn(self.queuedMoveSources) <= 0 then
		--self:PrintDebug("Nothing left to do")
		self:QueueUpdate(0.1)
		-- Trigger callback.
		if type(self.moveQueue_onComplete) == "function" then
			self.moveQueue_onComplete(self.moveQueue_success)
		end
		return
	end

	--self:PrintDebug("starting move # " .. table.getn(self.queuedMoveSources))

	-- Defaults.
	local queueDelay = 0.15
	local thisMoveSucceeded = false

	-- Get info about the current operation.
	local source = self.queuedMoveSources[1]
	local target = self.queuedMoveTargets[1]

	-- Reset retry count.
	if source ~= self.moveQueue_LastSource then
		self.moveRetryCount = 0
	end

	-- Make sure neither item is locked
	local _, _, sourceLocked = _G.GetContainerItemInfo(source.bagNum, source.slotNum)
    local _, _, targetLocked = _G.GetContainerItemInfo(target.bagNum, target.slotNum)

	-- Only attempt the move if everything is unlocked
	if not sourceLocked and not targetLocked then
		-- Record stock states so we can revise them.
		local oldSourceStockState = source.bagshuiStockState
		local oldSourceDate = source.bagshuiDate or 0
		local oldTargetStockState = target.bagshuiStockState
		local oldTargetDate = target.bagshuiDate or 0

		-- Set resorting for this inventory and any supplemental storage.
		if self.moveQueue_resort then
			self.forceResort = self.forceResort or self.moveQueue_resort
			if
				type(self.bagSwappingSupplementalStorage) == "table"
				and table.getn(self.bagSwappingSupplementalStorage) > 0
			then
				for _, inventoryClassName in ipairs(self.bagSwappingSupplementalStorage) do
					if Bagshui.components[inventoryClassName] and Bagshui.components[inventoryClassName].online then
						Bagshui.components[inventoryClassName].forceResort = Bagshui.components[inventoryClassName].forceResort or self.moveQueue_resort
					end
				end
			end
		end

		-- Do the actual move.
		self:MoveItem(source, target)

		if not _G.CursorHasItem() then

			-- Try to make stock states and dates make sense.
			-- Always copy source stock state over target if the source was new/increased,
			-- but only copy a decreased stock state if the target didn't have a state.
			if
				oldSourceStockState
				and oldSourceStockState ~= BS_ITEM_STOCK_STATE.NO_CHANGE
				and (
					oldSourceStockState ~= BS_ITEM_STOCK_STATE.DOWN
					or (
						oldSourceStockState == BS_ITEM_STOCK_STATE.DOWN
						and (
							not oldTargetStockState
							or oldTargetStockState == BS_ITEM_STOCK_STATE.NO_CHANGE
						)
					)
				)
			then
				target.bagshuiStockState = oldSourceStockState
			end
			target.bagshuiDate = math.max(oldSourceDate, oldTargetDate)

			-- These can come out of the queue now.
			thisMoveSucceeded = true

			-- Reset retry count.
			self.moveRetryCount = 0
		end

	end

	-- Move attempt failed.
	if not thisMoveSucceeded then
		-- Show error message and retry if we haven't reached the limit.
		local baseError = string.format(L.Error_RestackFailed, source.name)

		if (self.moveRetryCount or 0) < 5 then

			-- Longer delay until retry if either item was locked.
			queueDelay = 0.5

			if self.moveRetryCount > 1 then
				Bagshui:ShowErrorMessage(string.format(L.Error_Suffix_Retrying, baseError), self.inventoryType, 1.0, 0.578, 0)
				queueDelay = 1.0
			end

			self.moveRetryCount = self.moveRetryCount + 1

		else
			-- Once we've tried several times, give up on this operation and move to the next one.
			Bagshui:ShowAndLogErrorMessage(baseError)
			self.moveQueue_success = false
			self.moveRetryCount = 0
			thisMoveSucceeded = true
		end

	end

	-- Once we're done with this set, take them out of the queue.
	if thisMoveSucceeded then
		table.remove(self.queuedMoveSources, 1)
		table.remove(self.queuedMoveTargets, 1)
		-- Update progress.
		if type(self.moveQueue_onProgress) == "function" then
			self.moveQueue_onProgress(self.moveQueue_totalItems - table.getn(self.queuedMoveSources))
		end
	end

	-- Queue either the next restack operation or retry the current one.
	-- The check at the beginning of this function will stop things when we're done.
	--self:PrintDebug("Remaining: " .. table.getn(self.queuedMoveSources))
	Bagshui:QueueClassCallback(self, self.ProcessMoveQueue, queueDelay, nil)
end



--- Move an item from one place to another, ensuring no modifier keys get in the way.
---@param source table Inventory cache entry.
---@param target table|number Inventory cache entry *or* bag number, if equipping a bag.
---@param onComplete function? Called once the operation is complete with a boolean parameter indicating whether the cursor still has an item.
function Inventory:MoveItem(source, target, onComplete)
	local doCallback = true

	-- Empty the cursor just in case, since we're technically picking up and putting down items.
	_G.ClearCursor()

	-- Intentionally calling the game's `PickupContainerItem()` instead of `Bagshui:PickupItem()`
	-- because it's immediately picked up and put down, and we don't need (or want) to invoke
	-- `ContainerFrameItemButton_OnClick()` either. As an extra safety measure, force all
	-- modifier keys to return false for the duration of the move since some addons
	-- hook `PickupContainerItem()` and change its behavior when a modifier is pressed.

	local oldIsAltKeyDown = _G.IsAltKeyDown
	local oldIsControlKeyDown = _G.IsControlKeyDown
	local oldIsShiftKeyDown = _G.IsShiftKeyDown
	_G.IsAltKeyDown = BsUtil.ReturnFalse
	_G.IsControlKeyDown = BsUtil.ReturnFalse
	_G.IsShiftKeyDown = BsUtil.ReturnFalse
	_G.PickupContainerItem(source.bagNum, source.slotNum)
	if type(target) == "table" then
		_G.PickupContainerItem(target.bagNum, target.slotNum)
	elseif type(target) == "number" then
		-- This is an item being equipped to a slot.
		_G.EquipCursorItem(_G.ContainerIDToInventoryID(target))
		-- Might be BOE, so pass callback responsibilities over.
		-- (Could check for BOE but there's really no reason to do so when
		-- WaitForStaticPopupClose() will just invoke the callback immediately
		-- if the BOE dialog doesn't open.)
		BsUtil.WaitForStaticPopupClose(
			"EQUIP_BIND",
			300,  -- Five minute wait.
			function(waitSuccess)
				if type(onComplete) == "function" then
					if waitSuccess == false then
						onComplete(false)
					else
						onComplete((not _G.CursorHasItem()))
					end
				end
			end
		)
		-- Callback is handled by WaitForStaticPopupClose().
		doCallback = false
	end
	_G.IsAltKeyDown = oldIsAltKeyDown
	_G.IsControlKeyDown = oldIsControlKeyDown
	_G.IsShiftKeyDown = oldIsShiftKeyDown

	if doCallback and type(onComplete) == "function" then
		onComplete((not _G.CursorHasItem()))
	end
end



-- When the bag being swapped in is inside the bag it's replacing, we need
-- to know where it gets moved to so we can actually equip it.
local swapBag_sourceItemTracker = {}


--- Vanilla doesn't allow non-empty bags to be swapped, and manually emptying and
--- refilling is a pain. Let's make that better.
--- ### Note about profession bags and swapping.
--- There doesn't seem to be a way to ask whether an item can go in a container
--- other than calling `PutItemInBag()` and seeing whether it errors. For this
--- reason, profession bags are being excluded as valid temporary storage during
--- bag swapping. (Profession bags themselves can still be swapped.)
---@param sourceItem table New bag (entry from inventory cache).
---@param bagNum number Bag slot to swap.
---@param phase number? Used internally by the swapping process to trigger each phase (empty / swap / fill).
function Inventory:SwapBag(sourceItem, bagNum, phase, force)
	if
		type(sourceItem) ~= "table"
		or sourceItem.emptySlot == 1
		or not BsItemInfo:IsContainer(sourceItem)
	then
		-- If this is the initial call and the item isn't a bag, error out.
		-- After that, jump straight to refilling the original bag.
		if (phase or 1) == 1 then
			Bagshui:ShowErrorMessage(_G.BAG_NOT_EQUIPPABLE, nil, nil, nil, nil, nil, nil, false, true)
			return
		else
			phase = 3
		end
	end

	if (phase or 1) == 1 then
		-- PHASE 1: Empty the old bag.

		-- Total steps is:
		--   Number of items in the bag being emptied
		-- + 1 (Equip the new bag)
		-- + Number of items to put back in the new bag
		self.swapBag_totalSteps = self.containers[bagNum].slotsFilled * 2 + 1
		-- Consumed by `Inventory:UpdateSwapBagProgress()`.
		self.swapBag_currentStep = 0

		-- In case the bag was inside the bag we're swapping, we'll need to know its
		-- new location so we can actually equip it.
		swapBag_sourceItemTracker[1] = sourceItem

		self:EmptyBag(
			bagNum,
			swapBag_sourceItemTracker,
			-- Completion callback.
			function(success)
				if success == false or type(success) == "string" then
					Bagshui:ShowErrorMessage(type(success) == "string" and success or L.Error_BagSwap_EmptyOldFailed)
					self:UpdateSwapBagProgress(bagNum)
					-- Try to put things back.
					self:SwapBag(sourceItem, bagNum, 3)
					return
				end

				-- Need a slight delay here so the cache has time to catch up.
				Bagshui:QueueClassCallback(
					self,
					self.SwapBag,
					0.15,
					nil,
					swapBag_sourceItemTracker[1],
					bagNum,
					2
				)
			end,
			-- Progress callback.
			function()
				self:UpdateSwapBagProgress(bagNum)
			end
		)

	elseif phase == 2 then
		-- PHASE 2: Equip the new bag.

		self:EquipBag(
			sourceItem,
			bagNum,
			-- Completion callback.
			function(success)
				if success == false or type(success) == "string" then
					Bagshui:ShowErrorMessage(type(success) == "string" and success or L.Error_BagSwap_EquipNewFailed)
				end
				self:UpdateSwapBagProgress(bagNum)
				-- Always put things back even if the equip attempt failed.
				self:SwapBag(sourceItem, bagNum, 3)
			end
		)

	elseif phase == 3 then
		-- PHASE 3: Fill the new bag.

		Bagshui:QueueClassCallback(
			self,
			self.FillBag,
			0.15,
			nil,
			bagNum,
			self.tempMoveTargets,
			-- Completion callback.
			function()
				BsUtil.TableClear(self.tempMoveTargets)
				self:UpdateSwapBagProgress(bagNum, true)
				self.forceResort = true
				self:Update()
			end,
			-- Progress callback.
			function()
				self:UpdateSwapBagProgress(bagNum)
			end
		)
	end
end



--- Increment the progress indicator to show how far along the bag swap is.
--- Always call with `done = true` at the end of the swap to ensure the progress indicator is hidden.
---@param bagNum number Bag slot being swapped.
---@param done boolean? Swap is complete.
function Inventory:UpdateSwapBagProgress(bagNum, done)
	if done then
		self.temporarilyShowBagBar = false
		self.ui.buttons.bagSlots[self.myContainerIds[bagNum]].bagshuiData.progressPercent = 100
	else
		-- We're using the bag bar and cooldown to display progress.
		if not self.temporarilyShowBagBar then
			self.temporarilyShowBagBar = true
			self:UpdateWindow()
		end
		self.swapBag_currentStep = self.swapBag_currentStep + 1
		self.ui.buttons.bagSlots[self.myContainerIds[bagNum]].bagshuiData.progressPercent = self.swapBag_currentStep / self.swapBag_totalSteps * 100
	end
end



-- Used to determine whether there are enough free slots to empty a bag.
-- (Reusable table for `Inventory:EmptyBag()`.)
local emptyBag_potentialAvailableSlots = {}


--- Remove all items from a bag.
--- Automatically backs up the new locations to `Inventory.tempMoveTargets`.
---@param bagNum number Container to empty.
---@param itemsToTrack table? Array of cache items to find the future position of if they move.
---@param onComplete function? Completion callback (will be called from `Inventory:MoveItems()`).
---@param onProgress function? Per-move callback (will be called from `Inventory:MoveItems()`).
function Inventory:EmptyBag(bagNum, itemsToTrack, onComplete, onProgress)
	if not self.containers[bagNum] then
		return
	end

	-- We're going to make things simpler by just working with the list of all empty
	-- slots and skipping the ones that belong to the bag being emptied in the
	-- loop where we fill `queuedMoveSources/Targets`.
	BsUtil.TableCopyFlat(self.emptyGenericContainerSlots, emptyBag_potentialAvailableSlots)

	-- Find out how much free space there is, excluding the bag being emptied.
	local availableEmptySlotCount = self:GetAdjustedEmptySlotCount(bagNum)

	-- Extra space is needed. See if we can find any.
	if (self.containers[bagNum].slotsFilled or 0) > availableEmptySlotCount then
		availableEmptySlotCount = availableEmptySlotCount + self:GetSupplementalEmptySlotCount(emptyBag_potentialAvailableSlots)
	end

	-- Before going any further, make sure there's enough space.
	-- This is a variable instead of being in the `if` just below because it
	-- needs to be updated if we run out of slots in `emptyBag_potentialAvailableSlots`.
	local readyToEmpty = self.containers[bagNum].slotsFilled <= availableEmptySlotCount

	if readyToEmpty then

		-- Reset queues used by `Inventory:ProcessMoveQueue()`
		self:ClearMoveQueue()

		-- We'll need to iterate through `emptyGenericContainerSlots` to find the
		-- next one that doesn't belong to this bag.
		local nextTargetSlotIndex = 0
		local nextTargetSlot

		-- Find a corresponding empty slot for every item in this bag.
		for _, item in ipairs(self.inventory[bagNum]) do
			if item.emptySlot ~= 1 then
				repeat
					nextTargetSlotIndex = nextTargetSlotIndex + 1
					nextTargetSlot = emptyBag_potentialAvailableSlots[nextTargetSlotIndex]
				until (
					not nextTargetSlot
					or nextTargetSlot.bagNum ~= bagNum
				)
				if not nextTargetSlot then
					-- This hopefully shouldn't be hit but just in case.
					readyToEmpty = false
					break
				end
				-- Update tracking.
				if type(itemsToTrack) == "table" then
					for i = 1, table.getn(itemsToTrack) do
						if itemsToTrack[i] == item then
							itemsToTrack[i] = nextTargetSlot
						end
					end
				end
				-- Instructions for MoveItems().
				self:QueueMove(item, nextTargetSlot)
			end
		end
	end

	-- Are we good to go?
	if readyToEmpty then
		-- Make items available for refilling.
		BsUtil.TableCopyFlat(self.queuedMoveTargets, self.tempMoveTargets)

		-- Move! Those! Items!
		self:MoveItems(onComplete, onProgress, true)

		-- No need to hold onto this.
		BsUtil.TableClear(emptyBag_potentialAvailableSlots)

	else
		-- Failure state.
		self:ClearMoveQueue()

		local errorMessage = (
			self:GetBagSlotSwappableText(bagNum, true)
			or L.Error_BagSwap_EmptyOldInsufficientSpace
		)

		if type(onComplete) == "function" then
			onComplete(errorMessage)
		else
			Bagshui:ShowErrorMessage(errorMessage)
		end
	end
end



--- Move the given list of items into a different bag.
---@param bagNum number Bag into which the items should be placed.
---@param items table[] Array of inventory cache entries.
---@param onComplete function? Completion callback (will be called from `Inventory:MoveItems()`).
---@param onProgress function? Per-move callback (will be called from `Inventory:MoveItems()`).
function Inventory:FillBag(bagNum, items, onComplete, onProgress)
	if not self.inventory[bagNum] then
		return
	end

	BsUtil.TableCopyFlat(items, self.queuedMoveSources)
	BsUtil.TableCopyFlat(self.inventory[bagNum], self.queuedMoveTargets)

	-- Prune source table if there aren't enough slots in the destination.
	if table.getn(self.queuedMoveSources) > table.getn(self.queuedMoveTargets) then
		for i = table.getn(self.queuedMoveSources), table.getn(self.queuedMoveTargets) + 1, -1 do
			table.remove(self.queuedMoveSources, i)
		end
	end

	self:MoveItems(onComplete, onProgress, true)
end



--- Equip a bag.
---@param item table Inventory cache entry of the bag to be equipped.
---@param bagNum number Bag slot into which the bag will be placed.
---@param onComplete function? Success/failure callback.
function Inventory:EquipBag(item, bagNum, onComplete)
	self:MoveItem(item, bagNum, onComplete)
end



--- Find the count of free bag slots, less those belonging to `excludeBagNum` and
--- any profession bags.
---@param excludeBagNum number? Bag to omit.
---@return integer emptySlots
function Inventory:GetAdjustedEmptySlotCount(excludeBagNum)
	local availableEmptySlotCount = 0
	for containerNum, container in pairs(self.containers) do
		if
			containerNum ~= excludeBagNum
			and container.numSlots > 0
			and container.slotsFilled < container.numSlots
			-- Generic bags only (no profession bags). It's too hard to know what
			-- is allowed in a container without trying it, so we're just going
			-- to ignore profession bags as swap targets.
			and container.genericType == BsGameInfo.itemSubclasses["Container"]["Bag"]
		then
			availableEmptySlotCount = availableEmptySlotCount + (container.numSlots - container.slotsFilled)
		end
	end
	return availableEmptySlotCount
end



-- Reusable table for `Inventory:GetSupplementalEmptySlotCount()`.
local getSupplementalEmptySlotCount_inventoriesChecked = {}

--- Determine how many slots are available in other inventories to help with bag swapping.
---@param availableSlotTable table? Array to which additional slots should be added.
---@return integer availableEmptySlotCount
---@return table<string,true> inventoriesChecked Other inventory classes that were checked for available slots.
function Inventory:GetSupplementalEmptySlotCount(availableSlotTable)
	local availableEmptySlotCount = 0
	BsUtil.TableClear(getSupplementalEmptySlotCount_inventoriesChecked)
	if
		-- Other inventory classes that can be used during swapping are configured in this property.
		type(self.bagSwappingSupplementalStorage) == "table"
		and table.getn(self.bagSwappingSupplementalStorage) > 0
	then
		for _, inventoryClassName in ipairs(self.bagSwappingSupplementalStorage) do
			local supplemental = Bagshui.components[inventoryClassName]
			if supplemental and supplemental.online then
				if table.getn(supplemental.emptyGenericContainerSlots) > 0 then
					availableEmptySlotCount = availableEmptySlotCount + table.getn(supplemental.emptyGenericContainerSlots)
					if availableSlotTable then
						for _, slot in ipairs(supplemental.emptyGenericContainerSlots) do
							table.insert(emptyBag_potentialAvailableSlots, slot)
						end
					end
				end
				getSupplementalEmptySlotCount_inventoriesChecked[inventoryClassName] = true
			end
		end
	end
	return availableEmptySlotCount, getSupplementalEmptySlotCount_inventoriesChecked
end



--- Calculate how many more slots are required before a swap of the specified bag can be performed.
---@param bagNum number Container to check.
---@return integer slotsNeeded
---@return table<string, true>? inventoriesChecked Second return value from `Inventory:GetSupplementalEmptySlotCount()`.
function Inventory:GetAdditionalSlotsNeededToSwapBag(bagNum)
	local filledSlots = (self.containers[bagNum].slotsFilled or 0)

	if filledSlots == 0 then
		return 0
	end

	local availableEmptySlots = self:GetAdjustedEmptySlotCount(bagNum)

	if availableEmptySlots >= filledSlots then
		return 0
	end

	local supplementalEmptySlots, inventoriesChecked = self:GetSupplementalEmptySlotCount()

	if availableEmptySlots + supplementalEmptySlots >= filledSlots then
		return 0, inventoriesChecked
	end

	return (filledSlots - availableEmptySlots - supplementalEmptySlots), inventoriesChecked
end



--- Error-triggered bag swapping (as opposed to native bag swapping via a Bagshui
--- bag slot button's OnClick). This allows Bagshui to perform bag swaps even
--- if the equip action is invoked via the main action bar or any other method.
--- 
--- Methodology based on Swapper by Gabriele Cimolino
--- https://github.com/cubenicke/Swapper
---@param wowApiFunctionName any
---@param event any
---@param message any
function Inventory:UIErrorsFrame_OnEvent(wowApiFunctionName, event, message)
	if
		event == "UI_ERROR_MESSAGE"
		and message == _G.TEXT(_G.ERR_DESTROY_NONEMPTY_BAG)
	then
		local newBag, bagSlot

		-- Find the bag that needs to be equipped.
		for _, bagContents in pairs(self.inventory) do
			for __, item in ipairs(bagContents) do
				if item.locked == 1 then
					newBag = item
				end
			end
		end

		-- Find the slot into which it should be put.
		for _, containerId in ipairs(self.containerIds) do
			if _G.IsInventoryItemLocked(_G.ContainerIDToInventoryID(containerId)) then
				bagSlot = containerId
			end
		end

		-- Suppress the error and do the swap.
		if newBag and bagSlot then
			self:SwapBag(newBag, bagSlot)
			-- Can't just return here or it seems to break things, so
			-- we'll blank the message instead.
			message = ""
		end

	end
	self.hooks:OriginalHook(wowApiFunctionName, event, message)
end


end)