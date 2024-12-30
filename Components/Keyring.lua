-- Bagshui Keyring Inventory Class Instance
-- Exposes: Bagshui.components.Bags [via Inventory:New()]

Bagshui:AddComponent(function()


-- Create class instance.
local Keyring = Bagshui.prototypes.Inventory:New(BS_INVENTORY_TYPE.KEYRING)



--- The only special thing about Keyring is that it hooks ToggleKeyring.
---@param hookFunctionName string Name of the original WoW API function.
---@param bagNumParam number Container ID.
function Keyring:ToggleKeyring(hookFunctionName, bagNumParam)
	self:OpenCloseToggle(BS_INVENTORY_UI_VISIBILITY_ACTION.TOGGLE, hookFunctionName, bagNumParam)
end


end)