-- Bagshui UI Skinning settings processing.
-- Exposes:
-- - BsSkin (and Bagshui.components.Skin) - The currently active skin.
-- - BsSkinMgr (and Bagshui.components.SkinManager) - Class for registering/activating skins.
--
-- The default active skin is decided in Config\Skins.lua. When this component is loaded:
-- 1. The BsSkin Bagshui environment variable is pointed to the active skin.
-- 2. If the active skin isn't the default, a metatable is applied so that anything
--    missing from the active skin will be picked up from the default.

Bagshui:LoadComponent(function()

-- Bagshui.environment.BsSkin = Bagshui.config.Skins.Bagshui

-- -- Active skin is not the default.
-- if Bagshui.config.Skins.activeSkin ~= "Bagshui" and Bagshui.config.Skins[Bagshui.config.Skins.activeSkin] then
-- 	Bagshui.environment.BsSkin = Bagshui.config.Skins[Bagshui.config.Skins.activeSkin]
-- 	setmetatable(Bagshui.environment.BsSkin, Bagshui.config.Skins.Bagshui)
-- 	Bagshui.config.Skins.Bagshui.__index = Bagshui.config.Skins.Bagshui
-- end

-- Bagshui.components.Skin = Bagshui.environment.BsSkin


local SkinMgr = {
	activeSkin = "Bagshui",
	skins = {},
}
Bagshui.components.SkinManager = SkinMgr
Bagshui.environment.BsSkinMgr = SkinMgr



--- Initialize the SkinManager class.
function SkinMgr:Init()
	-- Load built-in skins.
	for skinName, skinConfig in pairs(Bagshui.config.Skins) do
		if skinName ~= "_activeSkin" then
			self:AddInterfaceSkin(skinName, skinConfig)
		end
	end

	-- Set default active skin.
	self:ActivateInterfaceSkin(Bagshui.config.Skins._activeSkin)
end



--- Register a new interface skin.
--- Designed to help Bagshui blend in with full UI replacement addons.
--- (This function is named as such in case Inventory-only skins are added in the future.)
--- 
--- 🛑 3rd party addons should not call this directly -- use the Bagshui:AddInterfaceSkin() API instead. 🛑
--- 
---@param skinName string Name of the skin. This may be visible to the user.
---@param skinConfig table Skin details. See **Config\Skins.lua** for the expected format.
function SkinMgr:AddInterfaceSkin(skinName, skinConfig)
	assert(type(skinName) == "string", "SkinMgr:AddInterfaceSkin(): skinName must be a string")
	assert(type(skinConfig) == "table", "SkinMgr:AddInterfaceSkin(): skinConfig must be a table")
	-- Not much to do here other than toss the skin in the list of known skins.
	self.skins[skinName] = skinConfig
end



--- Change the active skin.
--- ⚠️ As of now, this should **only** be called at startup, since it will *not*
---    apply changes to UI elements that have already been created. ⚠️
--- 
--- 🛑 3rd party addons should not call this directly -- use the Bagshui:AddInterfaceSkin() API instead. 🛑
--- 
---@param skinName any
function SkinMgr:ActivateInterfaceSkin(skinName)
	assert(type(skinName) == "string", "SkinMgr:ActivateInterfaceSkin(): skinName must be a string")
	assert(self.skins[skinName], "SkinMgr:ActivateInterfaceSkin(): " .. tostring(skinName) .. " is not a registered Bagshui interface skin")

	-- Don't let multiple interface skins fight each other.
	if self.activeSkin ~= "Bagshui" then
		Bagshui:PrintWarning(
			"An attempt was made to activate the " .. skinName .. " skin, but the " .. self.activeSkin .. " is already active. "
			.. "Only one interface skin can be active at a time, and the first one activated wins."
		)
		return
	end

	-- Activate the skin.
	self.activeSkin = skinName
	Bagshui.environment.BsSkin = self.skins[skinName]
	Bagshui.components.Skin = Bagshui.environment.BsSkin

	-- When the active skin isn't the default one, set a metatable to transparently
	-- handle any missing values.
	if skinName ~= "Bagshui" and self.skins[skinName] then
		setmetatable(Bagshui.environment.BsSkin, self.skins.Bagshui)
		self.skins.Bagshui.__index = self.skins.Bagshui
	end
end



--- Obtain the name of the active skin.
---@return string activeSkin
function SkinMgr:GetActiveSkinName()
	return self.activeSkin
end



-- Initialize immediately.
SkinMgr:Init()


end)