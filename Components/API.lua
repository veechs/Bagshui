-- Bagshui API
-- Exposes functions for easy 3rd party integrations.

Bagshui:LoadComponent(function()


--- Add a new rule function to Bagshui. A simple example is below. `params`
--- uses the same basic format as the built-in rule functions, so you can refer
--- to Config\RuleFunctions.lua for more examples.
---
--- ## `params` values
--- ```
--- {
--- 	-- If the function has no aliases, just pass its name as a string. 
--- 	-- To provide aliases, pass a list of strings, where the first item is
--- 	-- the primary name and all subsequent values are the aliases.
--- 	---@type table|string
--- 	functionNames,
--- 
--- 	-- The rule function must accept two parameters and return a boolean.
--- 	---@type function
--- 	---@param rules table The Rules class, with rules.item being the current item under evaluation.
--- 	---@param ruleArguments any[] List of all arguments provided by the user to the rule function.
--- 	---@return boolean
--- 	ruleFunction,
--- 	
--- 	-- (Optional but recommended) List of examples for use in the Category Editor
--- 	-- rule function [Fx] menu.
--- 	-- `code` is the menu text and what will be inserted in the editor;
--- 	-- `description` will be in the tooltip.
--- 	---@type { code: string, description: string }[]?
--- 	ruleTemplates,
--- 
--- 	-- (Optional) Tooltip text for the top-level rule function menu item in the Category editor.
--- 	---@type string?
--- 	description,
--- 
--- 	-- (Optional) List of variables to add to the rule environment.
--- 	-- See the BagType rule in Config\RuleFunctions.lua for an example.
--- 	---@type table<string,any>?
--- 	environmentVariables,
--- }
--- ```
--- 
---
--- ## Example
--- ```
---	Bagshui:AddRuleFunction({
---		functionNames = {
---			"IsSolidStone",
---			"Stone"
---		},
---		ruleFunction = function(rules, ruleArguments)
---			if rules.item.name == "Solid Stone" then
---				return true
---			end
---
---			return false
---		end,
---		ruleTemplates = {
---			{
---				code = 'IsSolidStone()',
---				description = 'Check if the item is Solid Stone.',
---			},
---		}
---	})
--- ```
---@param params table Parameters -- see function comments for details.
function Bagshui:AddRuleFunction(params)
	assert(type(params) == "table", "Bagshui:AddRuleFunction() - params must be a table.")
	assert(type(params.functionNames) == "string" or type(params.functionNames) == "table", "Bagshui:AddRuleFunction() - params.functionNames is required and must be a string or a table.")
	assert(type(params.ruleFunction) == "function", "Bagshui:AddRuleFunction() - params.ruleFunction is required and it must be a function.")
	assert(params.environmentVariables == nil or type(params.environmentVariables) == "table", "Bagshui:AddRuleFunction() - params.environmentVariables must be a table.")
	assert(params.ruleTemplates == nil or type(params.ruleTemplates) == "table", "Bagshui:AddRuleFunction() - params.ruleTemplates must be a table.")

	BsRules:AddFunction(params)
end



--- Notify Bagshui that a change has occurred which requires inventories to refresh.
---@param delay number? Seconds to wait before starting the update. Useful if there are likely to be a series of events that require updates.
---@param resortNeeded boolean? Light up the Reorganize toolbar icon if the inventory window is open. Pass `true` when a change has occurred that may require items to be re-categorized or resorted.
---@param cacheUpdateNeeded boolean? Check all items for changes, but don't refresh them GetItemInfo() unless there's a major change.
---@param fullCacheUpdateNeeded boolean? Force all item properties to be refreshed, including tooltips.
function Bagshui:QueueInventoryUpdate(delay, resortNeeded, cacheUpdateNeeded, fullCacheUpdateNeeded)
	for _, inventoryType in pairs(BS_INVENTORY_TYPE) do
		self.components[inventoryType].resortNeeded = self.components[inventoryType].resortNeeded or resortNeeded
		self.components[inventoryType].windowUpdateNeeded = self.components[inventoryType].windowUpdateNeeded or windowUpdateNeeded
		self.components[inventoryType].cacheUpdateNeeded = self.components[inventoryType].cacheUpdateNeeded or cacheUpdateNeeded
		self.components[inventoryType].forceFullCacheUpdate = self.components[inventoryType].forceFullCacheUpdate or fullCacheUpdateNeeded
		self.components[inventoryType]:QueueUpdate(delay)
	end
end



--- Register and immediately activate a 3rd party interface skin.
--- 
--- ## ℹ️ About
--- This API is designed for use by full UI replacements like Dragonflight: Reloaded
--- to help Bagshui blend in. It *cannot* be used to provide additional optional
--- appearances for Bagshui's item slots.
--- 
--- ### 🧩 `skinConfig` values
--- When calling `Bagshui:AddInterfaceSkin()`, the second parameter is a table containing
--- all the information needed to apply your skin. Refer to **Config\Skins.lua** for documentation
--- of available properties and expected values, along with an example implementation in the
--- pfUI skin.
--- 
--- Note that any values you omit from your `skinConfig` will automatically be picked up from
--- the default "Bagshui" skin. In other words, you *don't* need to provide properties unless
--- they're different from the default.
--- 
--- ### ⚠️ Limitations
--- 
---   - Bagshui does *not* currently provide the user a way to switch skins or
---      deactivate them; it's up to the 3rd party addon to handle this.
--- 
---   - First interface skin registered wins, so if a user loads (for example) both
---     pfUI and Dragonflight: Reloaded, the built-in pfUI interface skin will already
---     be active when DF:RL tries to add its skin, an error will be printed to chat.
--- 
--- ### 📖 Sample code
--- ```
--- -- Bagshui Interface Skin API Example
--- -- Simple demonstration of registering a 3rd party interface skin for Bagshui.
--- 
--- -- Explicit access to global environment for clarity.
--- local _G = _G or getfenv()
--- 
--- -- Need a frame to process events.
--- local SkinDemo = _G.CreateFrame("Frame")
--- 
--- --- Event handler.
--- --- Vanilla event parameters come via global variables, not function parameters.
--- SkinDemo:SetScript("OnEvent", function()
--- 
--- 	-- Interface skin registration *must* occur during ADDON_LOADED so it's done before
--- 	-- Bagshui starts building the interface during PLAYER_LOGIN/PLAYER_ENTERING_WORLD.
--- 	if _G.event == "ADDON_LOADED" then
--- 		-- Only respond to the event for this addon.
--- 		if _G.arg1 == "YourAddonName" then
--- 			-- Make sure Bagshui is loaded and a new enough version to have the interface skin API.
--- 			if _G.IsAddOnLoaded("Bagshui") and _G.Bagshui and _G.Bagshui.AddInterfaceSkin then
--- 				Bagshui:AddInterfaceSkin(
--- 					"Demo",
--- 					{
--- 						-- Garish, but readily apparent that it's working.
--- 						-- This is just a demo, after all.
--- 						inventoryBackgroundColorFromSkin = { 0.5, 0, 0.4 },
--- 						inventoryBorderColorFromSkin = { 0, 0.3, 0.8 },
--- 					}
--- 				)
--- 			end
--- 		end
--- 		return
--- 	end
--- 
--- end)
--- 
--- -- Have WoW send us the required event.
--- SkinDemo:RegisterEvent("ADDON_LOADED")
--- ```
--- 
---@param skinName string Name of the skin. This may be visible to the user.
---@param skinConfig table Skin details. See **Config\Skins.lua** for the expected format.
function Bagshui:AddInterfaceSkin(skinName, skinConfig)
	BsSkinMgr:AddInterfaceSkin(skinName, skinConfig)
	BsSkinMgr:ActivateInterfaceSkin(skinName)
end


end)