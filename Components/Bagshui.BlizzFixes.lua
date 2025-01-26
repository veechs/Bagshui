-- Bagshui Core: Blizzard FrameXML code fixes
-- Patches to work around issues in game code that don't fit anywhere else go here.

Bagshui:LoadComponent(function()

--- Stupid monkeypatch for a difficult-to-reproduce bug in Blizzard's FrameXML code
--- that intermittently leads to this error when calling `CreateFrame()` with
--- `GameTooltipTemplate` as the frame template:
--- ```text
--- Message: Interface\FrameXML\MoneyFrame.lua:185: attempt to perform arithmetic on local `money' (a nil value)
--- Stack: Interface\FrameXML\MoneyFrame.lua:185: in function `MoneyFrame_Update'
--- Interface\FrameXML\MoneyFrame.lua:168: in function `MoneyFrame_UpdateMoney'
--- Interface\FrameXML\MoneyFrame.lua:161: in function `MoneyFrame_SetType'
--- [string "<TooltipName>MoneyFrame:OnLoad"]:3: in main chunk
--- [C]: in function `CreateFrame'
--- ```
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
function Bagshui:MoneyFrame_UpdateMoney(wowApiFunctionName)
	-- There doesn't seem to be anything that initializes the `staticMoney` property
	-- of money frames, but this is only a problem sometimes? It's confusing.
	-- Regardless, this prevents the error from happening.
	if _G.this.moneyType == "STATIC" and _G.this.staticMoney == nil then
		_G.this.staticMoney = 0
	end
	self.hooks:OriginalHook(wowApiFunctionName)
end



--- Hack to make stack splitting work consistently.
--- Without this, mouseover events can reset the ID of a group's parent frame,
--- changing the bag number of the pending split. As a result, the split ends
--- up targeting the wrong item. We work around it by doing a hard capture of
--- the bag/slot numbers in `Bagshui:PickupItem()` into the `pending` properties
--- just before calling `ContainerFrameItemButton_OnClick()`. Then once the
--- Blizzard code has done its thing and calls `OpenStackSplitFrame()`, we intercept
--- the call and reassign the frame's `SplitStack` property, which is the callback
--- used when the split is invoked.
---@param wowApiFunctionName string Hooked WoW API function that triggered this call. 
---@param maxStack any `OpenStackSplitFrame()` parameter.
---@param parent any `OpenStackSplitFrame()` parameter.
---@param anchor any `OpenStackSplitFrame()` parameter.
---@param anchorTo any `OpenStackSplitFrame()` parameter.
function Bagshui:OpenStackSplitFrame(wowApiFunctionName, maxStack, parent, anchor, anchorTo)

	-- Reset just teo be safe.
	self.splitStackBagNum = nil
	self.splitStackSlotNum = nil

	-- Create our override function only once.
	if not self.SplitStackOverride then
		function self.SplitStackOverride(button, amount)
			_G.SplitContainerItem(self.splitStackBagNum, self.splitStackSlotNum, amount)
		end
	end

	-- Detect values set by `Bagshui:PickupItem()` and prepare them for
	-- `self.SplitStackOverride() to consume. This will only execute
	-- when Bagshui code has set things up and won't interfere with normal
	-- stack splitting functionality.
	if
		type(parent) == "table"
		and self.pendingSplitStackBagNum
		and self.pendingSplitStackSlotNum
	then
		self.splitStackBagNum = self.pendingSplitStackBagNum
		self.splitStackSlotNum  = self.pendingSplitStackSlotNum
		self.pendingSplitStackBagNum = nil
		self.pendingSplitStackSlotNum = nil
		-- Replace the callback set by 
		parent.SplitStack = self.SplitStackOverride
	end

	-- Pass along to the normal `OpenStackSplitFrame()` to handle everything.
	self.hooks:OriginalHook(wowApiFunctionName, maxStack, parent, anchor, anchorTo)
end


end)