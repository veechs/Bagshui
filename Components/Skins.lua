-- Bagshui UI Skinning settings processing.
-- Exposes: BsSkin (and Bagshui.components.Skin)
--
-- The active skin is decided in Config\Skins.lua. All we're doing here is:
-- 1. Pointing the BsSkin Bagshui environment variable to the active skin.
-- 2. If the active skin isn't the default, applying a metatable so that anything
--    missing from the active skin will be picked up from the default.

Bagshui:LoadComponent(function()

Bagshui.environment.BsSkin = Bagshui.config.Skins.Bagshui

-- Active skin is not the default.
if Bagshui.config.Skins.activeSkin ~= "Bagshui" and Bagshui.config.Skins[Bagshui.config.Skins.activeSkin] then
	Bagshui.environment.BsSkin = Bagshui.config.Skins[Bagshui.config.Skins.activeSkin]
	setmetatable(Bagshui.environment.BsSkin, Bagshui.config.Skins.Bagshui)
	Bagshui.config.Skins.Bagshui.__index = Bagshui.config.Skins.Bagshui
end

Bagshui.components.Skin = Bagshui.environment.BsSkin


end)