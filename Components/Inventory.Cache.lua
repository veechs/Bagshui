-- Bagshui Inventory Prototype: Cache Management

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory


--- Primary cache management function that copies inventory contents into `self.inventory[bag][slot]`.
---
--- Also responsible for deciding:
--- * Whether resort/window update is required.
--- * Item stock states (including saving/restoring when an items/bags are moved around).
--- * If each empty slot is allowed to stack.
--- * When toolbar icons that act on the inventory should be enabled (toolbar updates are performed in Inventory.layout.lua).
function Inventory:UpdateCache()
	--self:PrintDebug("UpdateCache()")

	-- Don't even try any updates until they're permitted.
	if not self.inventoryUpdateAllowed or not self.online then
		return
	end

	-- forceFullCacheUpdate should also satisfy any forceCacheUpdate condition.
	self.forceCacheUpdate = self.forceCacheUpdate or self.forceFullCacheUpdate

	-- If an update wasn't actually required, skip it.
	if not self.cacheUpdateNeeded and not self.forceCacheUpdate then
		return
	end

	-- If this was triggered by a bag change, wait for the next update.
	if
		self.lastEvent == "ITEM_LOCK_CHANGED"
		and BsUtil.TrueTableSize(self.lastUpdateLockedContainers) > 0
	then
		BsUtil.TableClear(self.lastUpdateLockedContainers)
		-- Queuing another update here instead of completely ignoring to ensure that an update
		-- does happen eventually (and it should typically happen sooner than the delay here).
		self:QueueUpdate(0.1)
		return
	end


	self:PrintDebug("Updating inventory cache")

	-- We've passed the initial checks and can start preparing to update the cache.

	-- Reference to self.inventory[bagNum][slotNum].
	local item

	-- The `*Changes` variables are used to figure out what needs to occur be once this function has finished.

	-- New items added, items removed, counts changed, etc. Most commonly true of the three `*Changes` variables.
	local majorChanges = false
	-- Usually just means that an item has locked or unlocked.
	local cosmeticChanges = false
	-- Not currently used; used to be called `resort_suggested` in EngInventory. Leaving in case it comes in handy in the future.
	local minorChanges = false

	-- Track whether there are multiple partial stacks of the same item to decide whether the
	-- Restack button should be enabled.
	self.multiplePartialStacks = false

	-- Bag (outer loop) variables.
	local bagName, bagNumSlots, bagTexture, bagType, bagSlotLink, bagItemCode, bagInfo

	-- Slot (inner loop) variables.
	local itemReadable
	-- Used to compare current cache item and actual item now present in the slot
	local preCharges, preCount, preItemLink, preLocked, preItemString, preTooltip,
			nowCount, nowItemLink, nowLocked, nowCharges
	-- These two variables are used to maintain and restore from the stock state cache.
	-- (See Bagshui:PickupInventoryItem() for reasoning.)
	local shadowId, prevShadowId


	-- Reset partial stack tracking table.
	BsUtil.TableClear(self.partialStacks)

	-- Identify any container changes triggered by moving bags between slots.
	if Bagshui.pickedUpBagSlotNum and Bagshui.putDownBagSlotNum then
		-- Container changes are only applicable if it's one of our containers.
		local pickedUpContainerId = self.inventoryIdsToContainerIds[Bagshui.pickedUpBagSlotNum]
		local putDownContainerId = self.inventoryIdsToContainerIds[Bagshui.putDownBagSlotNum]
		if pickedUpContainerId and putDownContainerId then
			self.pendingContainerChanges[pickedUpContainerId] = putDownContainerId
			self.pendingContainerChanges[putDownContainerId] = pickedUpContainerId
		end
	end
	local hasPendingContainerChanges = BsUtil.TrueTableSize(self.pendingContainerChanges) > 0

	-- Loop through bags.
	-- Using _bagIndex instead of _ as the throwaway variable for this loop because
	-- _ is used heavily within, and overwriting the loop variable can cause issues.
	for _bagIndex, bagNum in ipairs(self.containerIds) do

		-- Initialize bag cache if needed.
		if self.inventory[bagNum] == nil then
			self.inventory[bagNum] = {}
		end


		-- Get bag info.
		bagName = nil
		bagNumSlots = self:GetContainerNumSlots(bagNum)  -- self:GetContainerNumSlots() intelligently handles this for for all container types.
		bagTexture = nil
		bagType = nil
		bagSlotLink = nil
		bagItemCode = nil
		if self.primaryContainer.id == bagNum then
			-- Can't pull primary container information from the API.
			bagName = self.primaryContainer.name
			bagTexture = self.primaryContainer.texture
			bagType = self.primaryContainer.name
		else
			bagName = _G.GetBagName(bagNum)
			bagSlotLink = _G.GetInventoryItemLink("player", _G.ContainerIDToInventoryID(bagNum))
			if bagSlotLink ~= nil then
				_, _, bagItemCode = string.find(bagSlotLink, "(%d+):")
				_, _, _, _, _, bagType, _, _, bagTexture = _G.GetItemInfo(bagItemCode)
			end
		end

		-- Keep track of whether this bag got locked to help coordinate bag change updates after it's unlocked.
		self.lastUpdateLockedContainers[bagNum] = _G.IsInventoryItemLocked(_G.ContainerIDToInventoryID(bagNum))

		-- No reason to store full texture paths since they're always in Interface\Icons.
		bagTexture = bagTexture

		-- self.containers[bagNum] always already exists in SavedVariables or has been
		-- initialized to {} during Inventory:Init().
		bagInfo = self.containers[bagNum]

		bagInfo.bagNum = bagNum

		-- Bag has changed or isn't initialized.
		if
			self.pendingContainerChanges[bagNum]
			or bagInfo.name ~= bagName
			or bagInfo.numSlots ~= bagNumSlots
			or bagInfo.texture ~= bagTexture
			or bagInfo.type ~= bagType
			or (
				-- Need to check for numSlots > 0 to avoid constantly rebuilding container info for empty bag slots
				bagInfo.numSlots > 0 and
				(
					not bagInfo.name
					or not bagInfo.type
				)
			)
			or self.initialInventoryUpdateNeeded
		then
			-- When the bag changes after startup, wipe its cache.
			if (bagInfo.numSlots or 0) > 0 and not self.initialInventoryUpdateNeeded then
				BsUtil.TableClear(self.inventory[bagNum])
			end
			bagInfo.name = bagName
			bagInfo.numSlots = bagNumSlots
			bagInfo.texture = bagTexture
			bagInfo.type = bagType

			-- isProfessionBag and genericType are used primarily for empty slot stacking.
			-- Anything that isn't a normal bag class and isn't the primary container
			-- is going to be considered a profession bag.
			bagInfo.isProfessionBag = (
				bagType ~= BsGameInfo.itemSubclasses["Container"]["Bag"]
				and bagType ~= self.primaryContainer.name
			)

			-- A bag's "generic type" is the the item class returned by GetItemInfo for profession
			-- bags or the localized version of "Bag" for any other bag and the primary container.
			bagInfo.genericType = bagInfo.isProfessionBag and bagInfo.type or BsGameInfo.itemSubclasses["Container"]["Bag"]

			-- Bag changes require a resort even if the window is visible.
			self.forceResort = true
		end

		-- Reset tracking of filled slots.
		self.containers[bagNum].slotsFilled = 0

		-- Make sure this bag has slots to process.
		if bagNumSlots > 0 then

			-- Prepare to stack empty slots (actual stacking is handled during UpdateWindow()).
			self:InitializeEmptySlotStackTracking(bagInfo)

			-- Time to go through all the bag slots and look at each item.
			for slotNum = 1, bagNumSlots do
				shadowId = nil
				prevShadowId = nil

				-- Initialize this slot in the cache when it doesn't exist yet.
				-- Using table.insert here to ensure table.getn() works correctly.
				if table.getn(self.inventory[bagNum]) < slotNum then
					table.insert(self.inventory[bagNum], {})
					BsItemInfo:InitializeItem(self.inventory[bagNum][slotNum])
				end

				item = self.inventory[bagNum][slotNum]

				-- Store previous information so we can determine whether changes occurred.
				preItemLink = item.itemLink
				preItemString = item.itemString
				preCharges = item.charges or 0
				preCount = item.count or 0
				preLocked = item.locked
				preTooltip = item.tooltip

				-- Get current item information.
				nowItemLink = _G.GetContainerItemLink(bagNum, slotNum)
				-- Ignoring quality (return value 4) from GetContainerItemInfo because
				-- it sometimes returns -1, which according to https://warcraft.wiki.gg/index.php?title=API_GetContainerItemInfo&oldid=2497880
				-- means it's somehow special (stackable, unique or a quest item).
				-- We'll obtain it from GetItemInfo() instead. (We also don't need
				-- texture since that will be obtained during ItemInfo:Get()).
				_, nowCount, nowLocked, _, itemReadable = _G.GetContainerItemInfo(bagNum, slotNum)

				-- Update filled slot count for this container.
				if nowItemLink ~= nil then
					self.containers[bagNum].slotsFilled = self.containers[bagNum].slotsFilled + 1
				end

				-- If count was nil, set it to 0 so that the cache isn't constantly getting
				-- re-processed (otherwise preCount won't equal nowCount for empty slots).
				nowCount = nowCount or 0

				-- Assume there are no charges. This property will be filled either by Bagshui's
				-- native tooltip charges parsing in ItemInfo:GetTooltip() or just below
				-- if SuperWoW is loaded. Making item.charges not equal preCharges is also the
				-- trigger for native charges parsing when the item doesn't change.
				item.charges = 0
				nowCharges = 0

				-- Item charges from SuperWoW: move negative item counts, which indicate charges, into the charges field.
				if nowCount < 0 then
					nowCharges = math.abs(nowCount)
					item.charges = nowCharges
					nowCount = 1
				end

				-- Process item if there are changes.
				if
					preItemLink ~= nowItemLink  -- Item has changed.
					or item.bagNum == nil  -- AddItemBagInfo() hasn't been called on this slot yet.
					or preLocked ~= nowLocked  -- Locked/unlocked.
					or preCount ~= nowCount  -- Count has changed (changes to charges are checked separately).
					or preTooltip ~= item.tooltip
					or self.initialInventoryUpdateNeeded
					or self.pendingContainerChanges[bagNum]
					or item._getItemInfoFailed  -- Item was flagged as requiring a refresh.
					or self.forceFullCacheUpdate  -- Update even items that may not appear to need it.
				then

					-- Clear the failure flag (see explanation just below the call to ItemInfo:Get()).
					item._getItemInfoFailed = nil


					-- Bag information is needed regardless of whether the slot is empty (bagNum, slotNum, bagType).
					-- This must happen before calling ItemInfo:Get() so that bagNum/slotNum are available.
					self:AddItemBagInfo(item, bagInfo)
					item.slotNum = slotNum


					-- Populate basic item information.
					if
						not BsItemInfo:Get(
							nowItemLink,  -- itemIdentifier
							item,  -- itemInfoTable
							false,  -- initialize
							(preItemLink ~= nowItemLink),  -- reinitialize
							false,  -- forceIntoLocalGameCache
							self  -- Inventory class instance
						)
					then
						-- If GetItemInfo() returns nil, ItemInfo:Get() will return false. When this occurs,
						-- bail and rely on cached inventory data until the next update attempt. This should only
						-- happen during the first second or two after login, so we do delay the initial inventory
						-- cache update to attempt to account for this. However, it's still safest to keep the
						-- check in place.

						-- Add a flag to this item's cache entry so we know that it absolutely has to be refreshed
						-- next time around.
						item._getItemInfoFailed = true
						return
					end


					-- Need to store different data for filled vs. empty slots.
					if item.itemString ~= nil then
						-- Slot contains an item.
						item.count = nowCount
						item.locked = nowLocked
						item.readable = itemReadable
						-- We got charges from GetContainerItemInfo() and need to restore
						-- because ItemInfo:Get() might have wiped them.
						if nowCharges > 0 then
							item.charges = nowCharges
						end

					else
						-- Slot is empty.
						self:InitializeEmptySlotItem(item)
						if self.containers[bagNum].isProfessionBag then
							item.name = item.bagType .. " " .. item.name
						end

						-- Slot has just become empty - don't allow it to collapse back
						-- into the stack until re-sorting occurs.
						if preItemLink ~= nowItemLink then
							item._bagshuiPreventEmptySlotStack = true
						end

					end

					-- Check for stock state changes.
					if
						item.itemString ~= nil
						and not self.freshCache
						-- Nothing has actually changed if the item was just picked up and put back down.
						and Bagshui.lastCursorItemUniqueId ~= BsItemInfo:GetUniqueItemId(item)
					then

						if
							item.itemString ~= preItemString
							and item.bagshuiDate == -1
						then
							-- Item itself has changed, so flag it as new.
							item._proposedStockState = BS_ITEM_STOCK_STATE.NEW
							item._proposedDate = _G.time()

							-- Enable resorting because an item DID change.
							-- Even if the stock state change isn't approved, resort may be needed.
							majorChanges = true

						elseif
							item.itemString == preItemString
							and item.count ~= preCount
							and preCount ~= -1
						then
							-- Item has not changed, but count did, so stock state needs to be updated.
							if item.count > preCount then
								item._proposedStockState = BS_ITEM_STOCK_STATE.UP
							else
								item._proposedStockState = BS_ITEM_STOCK_STATE.DOWN
							end
							item._proposedDate = _G.time()

							-- Also enable resorting since count is usually a sort property.
							-- This isn't dependent on the stock change being approved since the item
							-- slot count DID change, which can require a resort.
							majorChanges = true

						elseif
							self.initialInventoryUpdateNeeded
							and Bagshui.currentCharacterData.lastLogout
							and (item.bagshuiDate or 0) > 0
						then
							-- Just logged in, so move item dates forward by the amount of time since this
							-- character last logged out. This makes it so that only in-game time is counted.
							item.bagshuiDate = item.bagshuiDate + (_G.time() - Bagshui.currentCharacterData.lastLogout)

						end

					end


				elseif
					not BS_SUPER_WOW_LOADED
					and preCharges ~= item.charges
					-- Tooltip gets loaded earlier when a full cache update happens.
					and not self.forceFullCacheUpdate
				then
					-- None of the "big" changes happened to trigger a call to ItemInfo:Get(),
					-- but the item had some number of charges that we parsed from the tooltip
					-- previously, so we need to refresh it.
					-- (Normally the call to GetTooltip() happens automatically within ItemInfo:Get().)
					BsItemInfo:GetTooltip(item, self)

				end  -- Item changes check.


				-- When charges has changed, a re-sort is probably needed.
				-- This check is here so that it works for both SuperWoW and native charges parsing.
				if item.charges ~= preCharges then
					majorChanges = true
				end


				-- Build "shadow" IDs for non-empty slots. (See comment above the declaration of shadowId for full explanation.)
				if item.emptySlot ~= 1 then
					shadowId = BsItemInfo:GetUniqueItemId(item)

					-- Determine whether a restoration of stock state is required.
					if self.pendingContainerChanges[bagNum] then
						-- Bag swap.
						prevShadowId = BsItemInfo:GetUniqueItemId(item, self.pendingContainerChanges[bagNum])

					elseif
						Bagshui.pickedUpItemBagNum and Bagshui.pickedUpItemSlotNum
						and self.myContainerIds[Bagshui.pickedUpItemBagNum]
						and Bagshui.putDownItemBagNum and Bagshui.putDownItemSlotNum
						and self.myContainerIds[Bagshui.putDownItemBagNum]
						and (
							(item.bagNum == Bagshui.pickedUpItemBagNum and item.slotNum == Bagshui.pickedUpItemSlotNum)
							or
							(item.bagNum == Bagshui.putDownItemBagNum and item.slotNum == Bagshui.putDownItemSlotNum)
						)
					then
						-- Item moved.
						if (item.bagNum == Bagshui.pickedUpItemBagNum and item.slotNum == Bagshui.pickedUpItemSlotNum) then
							prevShadowId = BsItemInfo:GetUniqueItemId(item, Bagshui.putDownItemBagNum, Bagshui.putDownItemSlotNum)
						else
							prevShadowId = BsItemInfo:GetUniqueItemId(item, Bagshui.pickedUpItemBagNum, Bagshui.pickedUpItemSlotNum)
						end
					end
				end


				-- Reasons to restore or clear the item stock state.
				if prevShadowId and self.shadowStockState[prevShadowId] then
					-- Restore stock state from the item's most recent location after a container move.
					-- (See Bagshui:PickupInventoryItem() for reasoning).
					item.bagshuiDate = (self.shadowBagshuiDate[prevShadowId] or 0)
					item.bagshuiStockState = self.shadowStockState[prevShadowId]

				elseif item.bagshuiDate == -1 then
					-- -1 means to clear the stock state.
					-- Among other things, this can be triggered by Inventory:ItemButton_OnClick().
					item.bagshuiDate = 0
					item.bagshuiStockState = BS_ITEM_STOCK_STATE.NO_CHANGE
				end


				-- Update partial stack tracking.
				if item.count < (tonumber(item.maxStackCount) or 0) then
					if self.partialStacks[item.id] == nil then
						self.partialStacks[item.id] = 1
					else
						self.partialStacks[item.id] = self.partialStacks[item.id] + 1
						self.multiplePartialStacks = true
					end
				end


				-- Item isn't assigned to a group, so resort is required.
				if item.bagshuiGroupId == "" then
					majorChanges = true
				end

				-- Locked status has changed, so an update is a good idea.
				if item.locked ~= preLocked then
					cosmeticChanges = true
				end

				-- Clean up any vestigial properties at startup.
				if self.initialInventoryUpdateNeeded then
					for key, _ in pairs(item) do
						if BS_ITEM_SKELETON[key] == nil then
							item[key] = nil
						end
					end
				end

				-- Update the "shadow" stock state cache, but only if all pending
				-- changes are cleared so that we don't overwrite anything too soon.
				-- (See Bagshui:PickupInventoryItem() for reasoning.)
				if shadowId and not hasPendingContainerChanges then
					self.shadowBagshuiDate[shadowId] = item.bagshuiDate
					self.shadowStockState[shadowId] = item.bagshuiStockState
				end

				-- Update item counts for use in stock state rectification.
				if item.itemString then
					if not self.postUpdateItemCounts[item.itemString] then
						self.postUpdateItemCounts[item.itemString] = 0
					end
					self.postUpdateItemCounts[item.itemString] = self.postUpdateItemCounts[item.itemString] + item.count
				end

			end  -- Item slot loop within each bag.


		else
			-- There are no slots, so wipe the cache for this bag.
			-- self:PrintDebug("no slots in bag "..bagNum.." wiping cache")
			if table.getn(self.inventory[bagNum]) ~= 0 then
				majorChanges = true
			end
			BsUtil.TableClear(self.inventory[bagNum])
		end

	end -- Bag [container] loop.


	-- Post-update stock state rectification.
	-- Only allow changes to stock state when they make sense at an inventory level,
	-- not just because an individual slot changed.
	for _, container in pairs(self.inventory) do
		for _, item in pairs(container) do
			if
				item._proposedStockState
				and (
					(
						-- Down: New count must be less than old count.
						item._proposedStockState == BS_ITEM_STOCK_STATE.DOWN
						and self.postUpdateItemCounts[item.itemString] < (self.preUpdateItemCounts[item.itemString] or 0)
					)
					or
					(
						-- New/Up: New count must be greater than old count.
						item._proposedStockState ~= BS_ITEM_STOCK_STATE.DOWN
						and self.postUpdateItemCounts[item.itemString] > (self.preUpdateItemCounts[item.itemString] or 0)
					)
				)
			then
				-- self:PrintDebug(item.name .. " proposed " .. tostring(item._proposedStockState) .. " " .. tostring(self.preUpdateItemCounts[item.itemString]) .. " -> " .. tostring(self.postUpdateItemCounts[item.itemString]) .. " approved")
				item.bagshuiStockState = item._proposedStockState
				item.bagshuiDate = item._proposedDate
			-- elseif item._proposedStockState then
				-- self:PrintDebug(item.name .. " proposed " .. tostring(item._proposedStockState) .. " " .. tostring(self.preUpdateItemCounts[item.itemString]) .. " -> " .. tostring(self.postUpdateItemCounts[item.itemString]) .. " DENIED")
			end
			item._proposedStockState = nil
			item._proposedDate = nil
			item._allowStockStateChange = nil
		end
	end
	-- This update cycle's post-update counts become next cycle's pre-update counts.
	BsUtil.TableCopy(self.postUpdateItemCounts, self.preUpdateItemCounts)
	BsUtil.TableClear(self.postUpdateItemCounts)

	-- Store resort/update status for use by Update() and friends in Inventory.Layout.lua.
	if majorChanges then
		self.resortNeeded = true
		self.windowUpdateNeeded = true
	elseif minorChanges then
		self.resortNeeded = self.resortNeeded or false
		self.windowUpdateNeeded = true
	elseif cosmeticChanges then
		self.windowUpdateNeeded = true
	end

	-- Make sure we don't do a full cache rebuild again.
	self.initialInventoryUpdateNeeded = false

	-- Item stock states can now be tracked.
	self.freshCache = false

	-- Reset cache flags.
	self.cacheUpdateNeeded = false
	self.forceCacheUpdate = false
	self.forceFullCacheUpdate = false

	-- Reset triggers for container-change based stock state restoration.
	-- (See Bagshui:PickupInventoryItem() for reasoning.)
	if
		hasPendingContainerChanges
		and Bagshui.pickedUpBagSlotNum
		and Bagshui.putDownBagSlotNum
	then
		Bagshui.pickedUpBagSlotNum = nil
		Bagshui.putDownBagSlotNum = nil
		BsUtil.TableClear(self.pendingContainerChanges)
	end

	-- Raise change event.
	if majorChanges or minorChanges or cosmeticChanges then
		Bagshui:RaiseEvent("BAGSHUI_INVENTORY_CACHE_UPDATE")
	end

end



--- Smart version of GetContainerNumSlots that will switch functions if it's
--- a special container that requires a different function.
---@param bagNum integer Container number for which to get the slot count.
---@return integer bagSlotCount
function Inventory:GetContainerNumSlots(bagNum)
	local bagNumSlotsFunction = _G.GetContainerNumSlots
	if self.primaryContainer.numSlotsFunction and self.primaryContainer.id == bagNum then
		bagNumSlotsFunction = self.primaryContainer.numSlotsFunction
	end
	return bagNumSlotsFunction(bagNum)
end



--- Add bag information to the given cache item.
---@param item table self.inventory cache entry.
---@param bagInfo table self.containers entry.
---@param isEmptySlotStack boolean? true if this slot 
function Inventory:AddItemBagInfo(item, bagInfo, isEmptySlotStack)
	item.bagNum = bagInfo.bagNum
	-- Empty slot stack proxy items expected to have their "generic type" as their bagType
	-- instead of the value returned by GetItemInfo() for the bag. This is needed
	-- so that profession bag slots can be named properly in InitializeEmptySlotItem().
	item.bagType = isEmptySlotStack and bagInfo.genericType or bagInfo.type
end



--- Set the proper cache values for an empty slot item.
---@param item table self.inventory cache entry.
---@param isEmptySlotStack boolean? true for empty slot stack proxy entries.
function Inventory:InitializeEmptySlotItem(item, isEmptySlotStack)
	item.id = 0
	-- Using 0/1 for ease of sorting.
	item.emptySlot = 1
	-- Add "[Profession Bag Type]" to the name when needed.
	item.name =
		(isEmptySlotStack and item.bagType ~= BsGameInfo.itemSubclasses.Container.Bag)
		and string.format(L.Suffix_EmptySlot, item.bagType)
		or L.ItemPropFriendly_emptySlot
	item.subtype = item.bagType
	item.quality = -1
	item.charges = -1
	item.texture = nil
	item.readable = nil
	if not item._bagsRepresented then
		item._bagsRepresented = {}
	else
		BsUtil.TableClear(item._bagsRepresented)
	end
end



--- Prepare an entry in the emptySlotStacks table for to track the empty slot count for a given bag.
---@param bagInfo table self.containers entry.
function Inventory:InitializeEmptySlotStackTracking(bagInfo)
	if not bagInfo.genericType then
		return
	end

	if not self.emptySlotStacks[bagInfo.genericType] then
		self.emptySlotStacks[bagInfo.genericType] = {}
	end

	-- Always re-initialize when called to ensure bag changes don't result in incorrect empty slot textures.
	BsItemInfo:InitializeItem(self.emptySlotStacks[bagInfo.genericType])
	self:AddItemBagInfo(self.emptySlotStacks[bagInfo.genericType], bagInfo, true)
	self:InitializeEmptySlotItem(self.emptySlotStacks[bagInfo.genericType], true)
end



--- Clear all stock change indicators.
function Inventory:ResetStockState()
	for _, container in pairs(self.inventory) do
		for _, item in pairs(container) do
			item.bagshuiDate = 0
			item.bagshuiStockState = BS_ITEM_STOCK_STATE.NO_CHANGE
		end
	end
	self:ForceUpdateWindow()
end



--- Sort and organize inventory while the window is open.
--- Used from toolbars, menus, and key bindings.
function Inventory:Resort()
	self.forceResort = true
	-- Do NOT use QueueUpdate() here.
	self:Update()
	-- Trigger docked inventory resort.
	if self.dockedInventory then
		self.dockedInventory:Resort()
	end
end



--- Initiate the restacking process.
--- This doesn't do the actual work; it just sets up a queue of restack operations,
--- which is necessary because there needs to be a slight delay between each operation.
--- That process is handled by ProcessRestackQueue().
function Inventory:Restack()
	-- Ensure inventory cache is up to date.
	self.cacheUpdateNeeded = true
	self:UpdateCache()

	-- This function can be called when a docked inventory has partial stacks
	-- but this one doesn't. The case where this one has partials and the docked
	-- one may or may not is handled once Inventory:ProcessRestackQueue() is done.
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
	BsUtil.TableClear(self.restackQueue.sources)
	BsUtil.TableClear(self.restackQueue.targets)

	-- Reset restack retry count (used by ProcessRestackQueue() to decide when to give up if items are locked).
	self.restackRetryCount = 0

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
						table.insert(self.restackQueue.sources, source)
						table.insert(self.restackQueue.targets, target)
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
	--self:PrintDebug(table.getn(self.restackQueue.sources) .. " moves queued")

	-- Make the actual moves.
	self:ProcessRestackQueue()
end



-- Perform the restack operations queued up by Restack().
function Inventory:ProcessRestackQueue()

	--self:PrintDebug("Starting ProcessRestackQueue()")

	-- Are we done?
	if table.getn(self.restackQueue.sources) <= 0 then
		--self:PrintDebug("Nothing left to do")
		Bagshui:QueueClassCallback(self, self.Update, 0.1)
		-- Trigger docked inventory restack.
		if self.dockedInventory then
			self.dockedInventory:Restack()
		end
		return
	end

	--self:PrintDebug("starting move # " .. table.getn(self.restackQueue.sources))

	-- Defaults.
	local queueDelay = 0.15
	local removeFromQueue = false

	-- Get info about the current operation.
	local source = self.restackQueue.sources[1]
	local target = self.restackQueue.targets[1]

	-- Empty the cursor just in case, since we're technically picking up and putting down items.
	_G.ClearCursor()

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

		-- Do the actual move.
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
		_G.PickupContainerItem(target.bagNum, target.slotNum)
		_G.IsAltKeyDown = oldIsAltKeyDown
		_G.IsControlKeyDown = oldIsControlKeyDown
		_G.IsShiftKeyDown = oldIsShiftKeyDown

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
		removeFromQueue = true

		-- Reset retry count.
		self.restackRetryCount = 0

	else
		-- Show error message and retry if we haven't reached the limit.
		local baseError = string.format(L.Error_RestackFailed, source.name)

		if self.restackRetryCount < 5 then

			-- Longer delay until retry if either item was locked.
			queueDelay = 0.5

			if self.restackRetryCount > 1 then
				Bagshui:ShowErrorMessage(string.format(L.Error_Suffix_Retrying, baseError), self.inventoryType, 1.0, 0.578, 0)
				queueDelay = 1.0
			end

			self.restackRetryCount = self.restackRetryCount + 1

		else
			-- Once we've tried several times, give up on this operation and move to the next one.
			Bagshui:ShowAndLogErrorMessage(baseError)
			self.restackRetryCount = 0
			removeFromQueue = true
		end

	end

	-- Once we're done with this set, take them out of the queue.
	if removeFromQueue then
		table.remove(self.restackQueue.sources, 1)
		table.remove(self.restackQueue.targets, 1)
	end

	-- Queue either the next restack operation.
	-- The check at the beginning of this function will stop things when we're done.
	--self:PrintDebug("Remaining: " .. table.getn(self.restackQueue.sources))
	Bagshui:QueueClassCallback(self, self.ProcessRestackQueue, queueDelay)

end


end)