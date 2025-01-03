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

	BsRules:AddFunction(
		params.functionNames,
		params.ruleFunction,
		params.environmentVariables,
		params.ruleTemplates
	)
end



--- A change has occurred that requires Bagshui inventories to refresh.
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


end)