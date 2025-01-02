-- Bagshui API
-- Exposes functions for easy 3rd party integrations.

Bagshui:LoadComponent(function()


--- Add a new rule function to Bagshui. A simple example is below. The parameters
--- use the same basic format as the built-in rule functions, so you can refer
--- to Config\RuleFunctions.lua for more examples.
---
--- `functionNames` notes: For aliases, the first item in the array is the primary name, and all subsequent items are aliases.
--- 
--- `ruleFunction` notes: The function must accept two parameters and return a boolean. Example:
--- ```
--- ---@param rules table # The Rules class, with rules.item being the current item under evaluation.
--- ---@param ruleArguments any[] # List of all arguments provided to the function.
--- ---@return boolean
--- function(rules, ruleArguments)
---   return rules:TestItemAttribute("bagNum", ruleArguments, "number")
--- end
--- ```
---
--- `ruleTemplates` notes: `code` is the menu text and what will be inserted in the editor; `description` will be in the tooltip.
---
--- # Example
--- ```
---	Bagshui:AddRuleFunction(
---		{
---			"IsSolidStone",
---			"Stone"
---		},
---		function(rules, ruleArguments)
---			if rules.item.name == "Solid Stone" then
---				return true
---			end
---
---			return false
---		end,
---		nil,
---		{
---			{
---				code = 'IsSolidStone()',
---				description = 'Check if the item is Solid Stone.',
---			},
---		}
---	)
--- ```
---@param functionNames string|string[] If the function has no aliases, just pass its name as a string, or to provide aliases, pass a list of strings (see notes above).
---@param ruleFunction function The actual function (see notes above).
---@param environmentVariables table<string,string>? List of variables to add to the rule environment. Will usually be nil. See the BagType rule in Config\RuleFunctions.lua for an example.
---@param ruleTemplates { code: string, description: string }[]? List of examples for use in the Category Editor rule function menu (see notes above).
function Bagshui:AddRuleFunction(functionNames, ruleFunction, environmentVariables, ruleTemplates)
	BsRules:AddFunction(functionNames, ruleFunction, environmentVariables, ruleTemplates)
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