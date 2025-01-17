-- Bagshui Bank Inventory Class Instance
-- Exposes: Bagshui.components.Bags [via Inventory:New()]

Bagshui:AddComponent(function()


-- Create class instance.
local Bank = Bagshui.prototypes.Inventory:New(BS_INVENTORY_TYPE.BANK)



--- After normal Init() we need to replace the Blizzard bank frame.
function Bank:Init()

	self._super.Init(self)

	-- Store a reference to the Blizzard bank frame so it can be restored.
	if not self.blizzBankFrame then
		self.blizzBankFrame = _G.BankFrame
	end

	-- Take over bank frame duties if allowed.
	self:ReplaceBlizzardBank(self.settings.replaceBank)

	-- Bank should be offline by default.
	self.online = false
	-- Used to track whether the player is physically at the bank.
	self.atBank = false

end



--- Take over bank frame duties (or undo the takeover).
---@param replace boolean
function Bank:ReplaceBlizzardBank(replace)
	-- Intentionally comparing to false here so that nil will still trigger the takeover.
	if replace ~= false then

		-- For the Blizzard bank frame to stop opening, it has to stop receiving events.
		self.blizzBankFrame:UnregisterEvent("BANKFRAME_OPENED")
		self.blizzBankFrame:UnregisterEvent("BANKFRAME_CLOSED")

		-- Swap with the Blizzard bank frame.
		if self.blizzBankFrame:IsVisible() then
			self.blizzBankFrame:Hide()
		end
		_G.setglobal("BankFrame", self.uiFrame)

	else
		-- Can't restore if we haven't done the takeover.
		if not self.blizzBankFrame then
			return
		end

		-- Restore the Blizzard bank frame events.
		-- We don't need to unregister the BANKFRAME_* events for the Bank class
		-- because `Bank:Open()/Close()` filter based on the `replaceBank` setting.
		self.blizzBankFrame:RegisterEvent("BANKFRAME_OPENED")
		self.blizzBankFrame:RegisterEvent("BANKFRAME_CLOSED")

		-- Make the switch.
		self:Close()
		_G.setglobal("BankFrame", self.blizzBankFrame)
	end
end



--- Minor override to `Inventory:UpdateOnlineStatus()` so that online status will
--- match atBank status if the player arrives at or leaves the bank while
--- the window is open.
function Bank:UpdateOnlineStatus()
	self._super.UpdateOnlineStatus(self)
	if self.online and not self.atBank then
		self.online = false
	end
end



--- Build the bank slot purchase flow into the slot buttons themselves instead
-- of having a separate Purchase button.
---@param bagSlotButton table Bag slot button object.
function Bank:BagSlotButton_Init(bagSlotButton)

	bagSlotButton.bagshuiData.nextPurchasable = false
	bagSlotButton.bagshuiData.purchased = false

	-- OnEnter, if the slot is the next purchasable one, add the cost to the
	-- tooltip and change to the buy cursor.
	local oldOnEnter = bagSlotButton:GetScript("OnEnter")
	bagSlotButton:SetScript("OnEnter", function()
		local this = _G.this
		if oldOnEnter then
			oldOnEnter()
		end

		-- Can't buy bank slots offline.
		if not self.online then
			return
		end

		-- Ensure nextPurchasable is current for OnUpdate and OnClick.
		self:UpdateBagSlotPurchaseStatus(this)

		if self.containers[this.bagshuiData.bagNum].nextPurchasable then
			local nextSlotCost = _G.GetBankSlotCost(this.bagshuiData.bagSlotNum)
			_G.SetTooltipMoney(_G.GameTooltip, nextSlotCost)
			_G.GameTooltip:Show()
			_G.SetCursor("BUY_CURSOR")
		end
	end)

	-- OnClick, make the purchase if it's the next purchasable slot.
	local oldOnClick = bagSlotButton:GetScript("OnClick")
	bagSlotButton:SetScript("OnClick", function()
		local this = _G.this
		if not self.online then
			return
		end
		if self.containers[this.bagshuiData.bagNum].nextPurchasable then
			_G.PlaySound("igMainMenuOption")
			-- The CONFIRM_BUY_BANK_SLOT dialog looks at the nextSlotCost property of
			-- BankFrame to get the cost. Since we're replacing BankFrame with our frame,
			-- we need to set that property.
			self.uiFrame.nextSlotCost = _G.GetBankSlotCost(this.bagshuiData.bagSlotNum)
			_G.StaticPopup_Show("CONFIRM_BUY_BANK_SLOT")
		elseif not self.containers[this.bagshuiData.bagNum].purchased then
			return
		elseif
			not _G.IsAltKeyDown()
			and not _G.CursorHasItem()
		then
			-- Hack to get a call to PickupBagFromSlot().
			-- Without this, Bank bags can only be picked up by dragging.
			-- Another possibility is using `_G.BankFrameItemButtonBag_OnShiftClick()`.
			this:GetScript("OnDragStart")()
		else
			oldOnClick()
		end
	end)

	-- Pass on to parent to finish initialization.
	self._super.BagSlotButton_Init(self, bagSlotButton)
end



--- Update the Bagshui purchased and nextPurchasable properties for a bag slot.
--- numSlotsPurchased and allSlotsPurchased are the return values from `GetNumBankSlots()`.
--- (These parameters can be passed so that `GetNumBankSlots()` doesn't have to be called
--- repeatedly during the `Bank:UpdateBagBar()` loop).
---@param bagSlotButton table Bag slot button object.
---@param numSlotsPurchased number? How many bank slots have been purchased so far.
---@param allSlotsPurchased boolean? Whether all bank slots have been purchased.
---@return number numSlotsPurchased
function Bank:UpdateBagSlotPurchaseStatus(bagSlotButton, numSlotsPurchased, allSlotsPurchased)
	if numSlotsPurchased == nil then
		numSlotsPurchased, allSlotsPurchased = _G.GetNumBankSlots()
	end
	-- `<button>.bagshuiData.bagNum` is the sequential bag slot number as set in InitUi().
	self.containers[bagSlotButton.bagshuiData.bagNum].purchased = (
			allSlotsPurchased
			or bagSlotButton.bagshuiData.bagSlotNum <= numSlotsPurchased
		)
	self.containers[bagSlotButton.bagshuiData.bagNum].nextPurchasable = (
			not allSlotsPurchased
			and bagSlotButton.bagshuiData.bagSlotNum == numSlotsPurchased + 1
		)
	return numSlotsPurchased
end



--- Add special bag bar handling for bank slots because they're purchasable.
function Bank:UpdateBagBar()
	local tooltipText, textureColor
	local numSlotsPurchased, allSlotsPurchased = _G.GetNumBankSlots()

	for _, bagSlotButton in ipairs(self.ui.buttons.bagSlots) do

		-- The primary bank slot is never purchasable.
		if not bagSlotButton.bagshuiData.primary then
			self:UpdateBagSlotPurchaseStatus(bagSlotButton, numSlotsPurchased, allSlotsPurchased)

			if self.containers[bagSlotButton.bagshuiData.bagNum].purchased then
				-- Slot has been purchased.
				tooltipText = _G.BANK_BAG
				textureColor = BS_COLOR.WHITE

			elseif self.containers[bagSlotButton.bagshuiData.bagNum].nextPurchasable and self.online then
				-- Slot is next up for purchase.
				tooltipText = _G.BANKSLOTPURCHASE .. " " .. _G.BANK_BAG
				textureColor = BS_COLOR.DARK_GREEN

			else
				-- Slot is not yet purchasable.
				tooltipText = _G.BANK_BAG_PURCHASE
				textureColor = BS_COLOR.DARK_RED
			end

			-- This will be picked up by `Inventory:ShowBagSlotTooltip()`.
			bagSlotButton.tooltipText = tooltipText

			-- Set the slot button texture color.
			_G.SetItemButtonTextureVertexColor(bagSlotButton, textureColor[1], textureColor[2], textureColor[3])

			-- Set the background texture color.
			if bagSlotButton.bagshuiData.buttonComponents.background then
				bagSlotButton.bagshuiData.buttonComponents.background:SetVertexColor(textureColor[1], textureColor[2], textureColor[3])
			end

			-- Use cached bag texture offline.
			if not self.online and self.containers[bagSlotButton.bagshuiData.bagNum].texture then
				_G.SetItemButtonTexture(bagSlotButton, self.containers[bagSlotButton.bagshuiData.bagNum].texture)
			end

		end

	end

	self._super.UpdateBagBar(self)
end



--- Bank needs special logic for open.
function Bank:Open()
	-- Determine whether we're at the bank.
	-- `self.online` will be updated in `Bank:Update()`.
	self.atBank = (
		_G.event == "BANKFRAME_OPENED"
		or (self.settings.replaceBank == false and self.ui:IsFrameVisible(self.blizzBankFrame))
	)
	self.windowUpdateNeeded = true
	self:Update()

	-- Don't respond to open event when we're not hooking the Bank,
	-- but do update online state via `Bank:Update()`.
	if _G.event == "BANKFRAME_OPENED" and self.settings.replaceBank == false then
		return
	end

	self._super.Open(self)
end



--- Bank needs special logic for close.
function Bank:Close()
	-- Determine whether we're still at the bank.
	-- Closing the bank can never mean we're at the bank, so only
	-- change `atBank` if it's currently true.
	-- `self.online` will be updated in `Bank:Update()`.
	if self.atBank then
		self.atBank = (_G.event ~= "BANKFRAME_CLOSED")
	end
	self.windowUpdateNeeded = true
	self:Update()

	-- Don't respond to close event when we're not hooking the Bank.
	if _G.event == "BANKFRAME_CLOSED" and self.settings.replaceBank == false then
		return
	end

	self._super.Close(self)
end



--- Need to overload the OnHide script so that we can ensure the BANKFRAME_OPENED
--- event will always fire as expected. Unless `CloseBankFrame()` is called,
--- the game will think we never left the bank and it becomes impossible to open
--- the bank again until the UI is reloaded.
function Bank:UiFrame_OnHide()
	self._super.UiFrame_OnHide(self)
	if self.settings.replaceBank then
		_G.CloseBankFrame()
	end
	self.atBank = false
end


end)