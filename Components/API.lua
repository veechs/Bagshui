-- Bagshui API
-- Exposes functions for easy 3rd party integrations.

Bagshui:LoadComponent(function()


--- Add a new rule function to Bagshui.
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
---@param functionNames string|string[] If the function has no aliases, just pass its name as a string, or to provide aliases, pass a list of strings (see notes above).
---@param ruleFunction function The actual function (see notes above).
---@param environmentVariables table<string,string>? List of variables to add to the rule environment. See the BagType rule in Config\RuleFunctions.lua for an example.
---@param ruleTemplates { code: string, description: string }[]? List of examples for use in the Category Editor rule function menu (see notes above).
function Bagshui:AddRuleFunction(functionNames, ruleFunction, environmentVariables, ruleTemplates)
	BsRules:AddFunction(functionNames, ruleFunction, environmentVariables, ruleTemplates)
end


end)