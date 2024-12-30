-- Bagshui Core: Cursor
-- Picking up, putting down, tracking what's being held.

Bagshui:LoadComponent(function()


--- There's no `GetCursorInfo()` in 1.12 so we're going to do a little trickery in order to accomplish a couple of things:
--- 1. Use escape to clear the cursor.
--- 2. Allow dragging items from bags to category editors to populate item lists.
--- This is NOT hooking the global `PickupContainerItem()`, so only Bagshui item slots are going to use this.
---@param item table Populated by `ItemInfo:Get()`.
---@param inventoryClass table? Inventory class instance that owns the item being picked up or put down.
---@param itemSlotButton table? 
---@param callPickupContainerItem boolean?
function Bagshui:PickupItem(item, inventoryClass, itemSlotButton, callPickupContainerItem)

	-- Track where the pickup call came from so we know whether it's being put down
	-- in the same inventory or moved to a different one.
	local owningFrame = inventoryClass and inventoryClass.uiFrame or _G.this

	-- Reasons to update or clear tracking properties.
	if
		-- Item was put in a different spot in the same inventory, so hold onto the
		-- "pickedUp" values and add "putDown" values. Note that these may be changed
		-- in the loop that chooses an empty slot below.
		_G.CursorHasItem()
		and self.cursorItem ~= nil
		and self.pickedUpItemBagNum ~= nil
		and self.pickedUpItemSlotNum ~= nil
		and (
			self.pickedUpItemBagNum ~= item.bagNum
			or self.pickedUpItemSlotNum ~= item.slotNum
		)
		and self.cursorItemOwningFrame == owningFrame
	then
		self.putDownItemBagNum = item.bagNum
		self.putDownItemSlotNum = item.slotNum


	elseif
		-- Tracking needs to be cleared when...
		(
			not _G.CursorHasItem()
			and (
				(
					-- Item was put back down in the same spot.
					self.cursorItemOwningFrame == owningFrame
					and self.pickedUpItemBagNum == item.bagNum
					and self.pickedUpItemSlotNum == item.slotNum
				)
				or
				(
					-- First call with nothing on cursor but tracking hasn't been reset.
					self.pickedUpItemBagNum
					and self.pickedUpItemSlotNum
					and self.putDownItemBagNum
					and self.putDownItemSlotNum
				)
			)
		)
		or
		(
			-- Item was moved to a different inventory.
			_G.CursorHasItem()
			and self.cursorItemOwningFrame ~= nil
			and self.cursorItemOwningFrame ~= owningFrame
		)
	then
		-- Clear tracking.
		self.pickedUpItemBagNum = nil
		self.pickedUpItemSlotNum = nil
		self.putDownItemBagNum = nil
		self.putDownItemSlotNum = nil
		if self.cursorItemOwningFrame then
			self.cursorItemOwningFrame.bagshuiData.hasCursorItem = false
		end
	end


	-- Every time we're called, start fresh with the basic tracking properties.
	-- These get updated at the end when we check whether anything was picked up.
	self.cursorItem = nil
	self.cursorItemOwningFrame = nil
	if not owningFrame.bagshuiData then
		owningFrame.bagshuiData = {}
	end
	owningFrame.bagshuiData.hasCursorItem = false


	-- Empty slot stack / normal handling.
	if inventoryClass and itemSlotButton and itemSlotButton.bagshuiData and itemSlotButton.bagshuiData.isEmptySlotStack then
		-- This is an empty slot stack.
		-- Instead of just putting the item in whatever slot happens to represent the empty slot stack, we're
		-- going to iterate all containers and find the first one with an empty slot. This also gives us a chance
		-- to work around accidentally trying to put a container into itself (see comment below).

		-- Only iterate containers that match the generic bag type of this slot.
		local allowedGenericBagType = inventoryClass.containers[item.bagNum].genericType

		-- When a bag is picked up from the bag bar and an attempt is made to place it into an empty slot,
		-- it's possible that the empty slot may belong to the bag that was picked up, especially if it's
		-- being put into an empty slot stack. This triggers an error message about not being able to put
		-- a bag into itself, which is unexpected if there are empty slots in other bags. To work around
		-- this, we iterate all empty slots that belong to non-profession bags looking for somewhere to
		-- place the bag that's on the cursor.
		local bagNumToAvoid
		if
			self.cursorBagSlotNum
			and _G.CursorHasItem()
			and inventoryClass
			-- This is the check to see if we're incorrectly trying to put the bag into itself.
			and item.bagNum == inventoryClass.inventoryIdsToContainerIds[self.cursorBagSlotNum]
		then
			bagNumToAvoid = item.bagNum
		end

		-- Find the best slot to use.
		local noEmptySlots = true
		for _, bagNum in ipairs(inventoryClass.containerIds) do
			if
				bagNum ~= bagNumToAvoid  -- This will work fine if bagNumToAvoid is nil.
				and inventoryClass.containers[bagNum].genericType == allowedGenericBagType
			then
				for slotNum, slotContents in ipairs(inventoryClass.inventory[bagNum]) do
					if
						slotContents.emptySlot == 1
						-- When moving an item into an empty slot stack, always peel off
						-- a new slot instead of using any that have already been peeled off.
						and not slotContents._bagshuiPreventEmptySlotStack
					then
						-- Update tracking variables so that inventory classes know that this item should
						-- have its stocks state restored.
						self.putDownItemBagNum = bagNum
						self.putDownItemSlotNum = slotNum
						-- Move the item.
						_G.PickupContainerItem(bagNum, slotNum)
						noEmptySlots = false
						break
					end
				end
			end
			if not noEmptySlots then
				break
			end
		end

		-- Couldn't find anywhere to put it.
		if noEmptySlots then
			self:ShowErrorMessage(_G.INVENTORY_FULL, (inventoryClass and inventoryClass.inventoryType))
			_G.ClearCursor()
		end

	else
		-- Not an empty slot stack (normal behavior).
		if callPickupContainerItem then
			_G.PickupContainerItem(item.bagNum, item.slotNum)
		else
			-- Don't need to (and can't) pass bagNum/slotNum to ContainerFrameItemButton_OnClick(),
			-- since it pulls them from _G.this:GetId()/_G.this:GetParent():GetId().
			_G.ContainerFrameItemButton_OnClick("LeftButton")
		end
	end

	-- Store tracking info if we picked something up.
	if _G.CursorHasItem() then
		self.cursorItem = item
		owningFrame.bagshuiData.hasCursorItem = true
		self.cursorItemOwningFrame = owningFrame
		self.lastCursorItemUniqueId = BsItemInfo:GetUniqueItemId(self.cursorItem)
		self.pickedUpItemBagNum = item.bagNum
		self.pickedUpItemSlotNum = item.slotNum
	end
end



--- Reset our cursor item tracking when the cursor is emptied.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call.
function Bagshui:ClearCursor(wowApiFunctionName)
	self.cursorItem = nil
	if self.cursorItemOwningFrame then
		self.cursorItemOwningFrame.bagshuiData.hasCursorItem = nil
	end
	self.cursorItemOwningFrame = nil
	self.cursorBagSlotNum = nil

	-- When the item was deleted, it can't exist any longer and lastCursorItemUniqueId
	-- needs to be cleared so that acquiring the same item again will cause it
	-- to be correctly seen as new.
	if wowApiFunctionName == "DeleteCursorItem" then
		self.lastCursorItemUniqueId = nil
	end
	self.hooks:OriginalHook(wowApiFunctionName)
end



--- Return the inventory item that was picked up via `Bagshui:PickupItem()`, if anything.
--- Will *not* work with `PickupContainerItem()`.
---@return table?
function Bagshui:GetCursorItem()
	if _G.CursorHasItem() and self.cursorItem then
		return self.cursorItem
	end
end



--- When containers are moved between slots, we need to do a fresh cache initialization for every `[bagNum][slotNum]`.
--- This results in the stock states being reset and every item becoming "new" when someone reorders their bags.
--- To prevent this, a shadow cache of stock state info is stored in `Inventory.shadowStockState`/`shadowBagshuiDate`,
--- and the restore is triggered by `Bagshui.pickedUpBagSlotNum`/`putDownBagSlotNum`, which are set here.
--- 
--- By hooking `PickupBagFromSlot()`, `PickupInventoryItem()`, and `PutItemInBag()`, we can cover all the ways containers are
--- picked up/put down, and track the changes that occur. Then `Inventory:Update()` can use that information to better
--- manage the stock state.
--- 
--- Note that since these API functions receive inventory slot IDs, not container numbers, the `Inventory.inventoryIdsToContainerIds`
--- table must be used to translate into something that will match `Inventory.containerIds`.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call.
---@param invSlotId number Inventory slot ID to pick up the item from.
---@return any wowApiFunctionReturnValue Return value from hooked WoW API function.
function Bagshui:PickupInventoryItem(wowApiFunctionName, invSlotId)

	-- Only store bag slot information if there's currently a bag on the cursor
	-- and the destination is different from the source.
	if
		_G.CursorHasItem()
		and self.cursorItem == nil
		and self.cursorBagSlotNum ~= nil
		and self.cursorBagSlotNum ~= invSlotId
	then
		self.pickedUpBagSlotNum = self.cursorBagSlotNum
		self.putDownBagSlotNum = invSlotId

	elseif self.cursorBagSlotNum == invSlotId then
		-- Bag was put back down in the same place.
		self.pickedUpBagSlotNum = nil
		self.putDownBagSlotNum = nil
	end

	-- cursorBagSlotNum will be compared with arg1 (invSlotId) of the second call to an API function to determine whether a change was made.
	self.cursorBagSlotNum = nil

	-- Let WoW handle all the actual work.
	local ret = self.hooks:OriginalHook(wowApiFunctionName, invSlotId)

	-- A bag was picked up.
	if _G.CursorHasItem() and self.cursorItem == nil then
		self.cursorBagSlotNum = invSlotId
	end

	-- Some of the API functions expect return values, so always return what we got back from the original call.
	return ret
end


end)