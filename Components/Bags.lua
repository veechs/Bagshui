-- Bagshui Bags Inventory Class Instance
-- Exposes: Bagshui.components.Bags [via Inventory:New()]

Bagshui:AddComponent(function()


-- Create class instance.
local Bags = Bagshui.prototypes.Inventory:New(BS_INVENTORY_TYPE.BAGS)


-- Hook handling.

-- The original WoW API function needs to be called for Close* and Toggle* if the
-- original container frame is open. If this isn't done, clicking the close button
-- on the original frame will only affect Bagshui and leave the  original frame
-- stuck on the screen forever.

--- Open bag hooks (OpenAllBags, OpenBackpack, OpenBag(bagNum)).
---@param hookFunctionName string Name of the original WoW API function.
---@param bagNumParam number Container ID.
function Bags:OpenBag(hookFunctionName, bagNumParam)
	self:OpenCloseToggle(BS_INVENTORY_UI_VISIBILITY_ACTION.OPEN, hookFunctionName, bagNumParam)
end

--- Close bag hooks (CloseBackpack, CloseBag(bagNum)).
---@param hookFunctionName string Name of the original WoW API function.
---@param bagNumParam number Container ID.
function Bags:CloseBag(hookFunctionName, bagNumParam)
	self:OpenCloseToggle(BS_INVENTORY_UI_VISIBILITY_ACTION.CLOSE, hookFunctionName, bagNumParam, self:OriginalContainerFrameVisible(bagNumParam))
end

--- Toggle bag hooks (ToggleBackpack, ToggleBag(bagNum)).
---@param hookFunctionName string Name of the original WoW API function.
---@param bagNumParam number Container ID.
function Bags:ToggleBag(hookFunctionName, bagNumParam)
	self:OpenCloseToggle(BS_INVENTORY_UI_VISIBILITY_ACTION.TOGGLE, hookFunctionName, bagNumParam, self:OriginalContainerFrameVisible(bagNumParam))
end




--- Register additional events and properties to make bag slot buttons "just work" with Blizzard code.
---@param bagSlotButton table Bag slot button instance.
function Bags:BagSlotButton_Init(bagSlotButton)

	bagSlotButton:RegisterEvent("BAG_UPDATE")
	bagSlotButton.isBag = 1  -- We're not relying too much on PaperDollItemSlotButton, but let's set this just to be safe.

	local oldOnClick = bagSlotButton:GetScript("OnClick")
	--- If there was an item in the cursor when the slot was clicked, catch it and prevent the original
	--- from being called, since since PaperDollItemSlotButton will interpret that as trying to *equip*
	--- the item in that slot, instead of trying to put it in the bag. Note that due to the behavior of
	--- `PutItemInBag()`, this will *not* intercept BOE bags. Changing this would require detouring into
	--- `Bagshui:PickupItem()` when a bag is on the cursor, which we're not currently tracking.
	bagSlotButton:SetScript("OnClick", function()
		if not _G.PutItemInBag(_G.this.bagshuiData.inventorySlotId) then
			oldOnClick()
		end
	end)
end



--- Override Inventory:UpdateBagBar() and Inventory:UiFrame_OnHide() so we can correctly set the
--- highlight state of the Blizzard action bar bag slot buttons when our window opens/closes/updates.
function Bags:UpdateBagBar()
	self._super.UpdateBagBar(self)
	-- Don't update action bar bag slot buttons until the next update tick.
	-- This avoids having the Blizzard UI code immediately turn off the checked state.
	Bagshui:QueueClassCallback(self, self.UpdateActionBarBagSlotButtonState)
end


--- Ensure the Blizzard action bar bag buttons are un-highlighted when the Bags window is closed.
function Bags:UiFrame_OnHide()
	self._super.UiFrame_OnHide(self)
	-- It's safe to instantly un-highlight the action bar bag buttons when the window is closed.
	self:UpdateActionBarBagSlotButtonState()
end



Bags._actionBarButtonWasChecked = {}
--- Set Blizzard action bar bag slot buttons to "checked" (highlighted) when our
--- window is open and unchecked when it's closed.
function Bags:UpdateActionBarBagSlotButtonState()

	local shouldBeChecked = self:Visible()
	local actionBarButtonName, actionBarButton

	for _, bagNum in pairs(self.containerIds) do
		local hookEnabled = self:GetHookEnabled("Bag", bagNum)
		-- Only highlight bags in the action bar that we're hooking.
		if
			(hookEnabled or self._actionBarButtonWasChecked[bagNum])
			and type(self.currentCharacterInventory[bagNum]) == "table"
		then
			if bagNum == 0 then
				actionBarButtonName = "MainMenuBarBackpackButton"
			else
				actionBarButtonName = string.format("CharacterBag%dSlot", bagNum + self.bagSlotNameNumberOffset)
			end
			actionBarButton = _G[actionBarButtonName]
			-- Avoid messing with the highlight state when the original container frame is open.
			if actionBarButton and not self:OriginalContainerFrameVisible(bagNum) then
				actionBarButton:SetChecked(
					shouldBeChecked
					and hookEnabled
					-- Only highlight buttons where there are bags.
					and (table.getn(self.currentCharacterInventory[bagNum]) > 0)
				)
				self._actionBarButtonWasChecked[bagNum] = hookEnabled
			end
		end
	end
end



--- Helper to determine when when one of the Blizzard bag frames is open.
---@param bagNum any
---@return boolean frameVisible
function Bags:OriginalContainerFrameVisible(bagNum)
	if not bagNum then
		return false
	end
	return self.ui:IsFrameVisible("ContainerFrame" .. tostring(bagNum))
end



--- Execute `self:Open()/Close()` and the superclass version only if there isn't a reason to block it.
---@param action "Open"|"Close"
---@return boolean? # false if event was blocked.
function Bags:SmartOpenClose(action)

	-- Block based on settings.
	if
		type(_G.event) == "string"
		and (
			(string.find(_G.event, "^AUCTION_HOUSE_") and self.settings.toggleBagsWithAuctionHouse == false)
			or
			(string.find(_G.event, "^BANKFRAME_") and self.settings.toggleBagsWithBankFrame == false)
			or
			(string.find(_G.event, "^MAIL_") and self.settings.toggleBagsWithMailFrame == false)
			or
			(string.find(_G.event, "^TRADE_") and self.settings.toggleBagsWithTradeFrame == false)
		)
	then
		return
	end

	-- Proceed with action.
	self._super[action](self)
end

--- Add intelligence to Open().
function Bags:Open()
	self:SmartOpenClose("Open")
end

--- Add intelligence to Close().
function Bags:Close()
	self:SmartOpenClose("Close")
	self.lastOpenEventTrigger = nil
end



end)