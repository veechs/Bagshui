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


end)