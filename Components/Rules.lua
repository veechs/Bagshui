-- Bagshui Rules Engine
-- Exposes: BsRules (and Bagshui.components.Rules)
-- Raises: BAGSHUI_RULES_LOADED
--
-- Manage the evaluation of rule functions.

Bagshui:AddComponent(function()


-- Set up the Rules class.
local Rules = {

	-- Input and output for rule evaluation.

	item = nil,  -- Populated by `Rules:SetItemAndCharacter()`.
	character = nil,  -- Populated by `Rules:SetItemAndCharacter()`.
	---@type string?
	-- Rule functions should use this (as `rules.errorMessage`, assuming the first parameter accepted is being named `rules`) to return errors.
	errorMessage = nil,

	-- Reusable table in lieu of variadic arguments (`...`/`arg`) so we can avoid
	-- a Lua memory leak (see notes in `Rules:AddEnvironmentFunction()` for details).
	ruleFunctionArguments = {},

	-- Known rule functions `{ <environmentFunctionName (string)> = <actualFunction> }`.
	ruleFunctions = {},

	-- Once the built-in rule functions have been loaded, don't allow them to
	-- be overwritten by 3rd parties unless it's also in `replaceableRuleFunctions`.
	builtInRuleFunctions = {},
	builtinRulesLoaded = false,

	-- Overwriting these built-in rule functions is allowed without even a warning.
	-- Designed for "proxy" functions like `Outfit()` or `Wishlist()`.
	replaceableRuleFunctions = {},

	-- Rule function templates are used by the category editor to provide a list of all available functions.
	ruleFunctionTemplates = {},
	ruleFunctionTemplatesExtra = {},
	ruleFunctionTemplateGenericDescriptions = {},
	sortedRuleFunctionTemplateNames = {},

	-- Rule evaluation session tracking -- see `Rules:SetItemAndCharacter()`.
	currentSession = nil,

	-- When an ad-hoc rule needs to be compiled, it will be cached in `lastRuleStringCompiled` so searches can be more efficient.
	lastRuleString = "",
	-- Compiled version of `lastRuleString`.
	lastRuleStringCompiled = nil,

	-- List of allowed argument types for error messages.
	allowedArgumentTypes = "",

	-- When validating a rule expression, `self.validationModeReturnValueOverride` will cause `Rules:Call()`
	-- to return the value of `validationModeReturnValueOverride` instead of the actual rule function return value.
	validationModeReturnValueOverride = nil,

	-- The rule evaluation environment is intentionally different from `Bagshui.environment`
	-- because rule functions should not have access to the global environment.
	-- Aliases for these items will be added by `Rules:PrepareEnvironment()`.
	environment = {
		item = {},      -- Alias: i
		character = {}, -- Alias: c
	},
}
Bagshui.environment.BsRules = Rules
Bagshui.components.Rules = Rules



--- Initialize rule functions and environment.
function Rules:Init()

	self:LoadBuiltinRuleFunctions()
	self.builtinRulesLoaded = true

	self:PrepareEnvironment()

	-- Add generic environment variables.
	for var, value in pairs(BS_RULE_ENVIRONMENT_VARIABLES) do
		self.environment[var] = value
	end

	-- Build the list of allowed argument types for error messages.
	for argumentType, _ in pairs(BS_RULE_ARGUMENT_TYPE) do
		self.allowedArgumentTypes = self.allowedArgumentTypes .. BS_NEWLINE .. " - " .. string.lower(argumentType)
	end
	self.allowedArgumentTypes = self.allowedArgumentTypes .. BS_NEWLINE

	-- Notify of rules engine availability.
	Bagshui:RaiseEvent("BAGSHUI_RULES_LOADED")
end



--- Pull everything from Config\RuleFunctions.lua and Config\RuleFunctionTemplates.lua.
function Rules:LoadBuiltinRuleFunctions()
	for _, rule in ipairs(Bagshui.config.RuleFunctions) do
		if not (type(rule.functionNames) == "table" and type(rule.functionNames[1]) == "string") then
			Bagshui:PrintError("Built-in rules must have a functionNames property and it must be an array with at least one string value")
		elseif type(rule.ruleFunction) ~= "function" then
			Bagshui:PrintError("Built-in rules must have a ruleFunction = function(rules, ruleArguments) property")
		else
			rule.templates = rule.templates or Bagshui.config.RuleFunctionTemplates[rule.functionNames[1]]
			self:AddFunction(rule)
		end
	end
end



--- Create a new rule function, which is stored on the Rules class as Rule_FunctionName.
--- `params` uses the same basic format as the built-in rule functions, so you can refer
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
--- 	-- The rule function must accept two parameters and return a boolean (see below).
--- 	---@type function
--- 	---@param rules table The Rules class, with rules.item being the current item under evaluation.
--- 	---@param ruleArguments any[] List of all arguments provided by the user to the rule function.
--- 	---@return boolean
--- 	ruleFunction,
--- 	
--- 	-- (Optional but recommended) List of examples for use in the Category Editor
--- 	-- rule function [Fx] menu. When not provided, `Rules:AddRuleExamplesFromLocalization()`
---		-- will be used to attempt to populate it.
--- 	-- `code` is the menu text and what will be inserted in the editor;
--- 	-- `description` will be in the tooltip.
--- 	---@type { code: string, description: string }[]?
--- 	ruleTemplates,
--- 
--- 	-- (Optional) List of variables to add to the rule environment.
--- 	-- See the BagType rule in Config\RuleFunctions.lua for an example.
--- 	---@type table<string,any>?
--- 	environmentVariables,
--- 
--- 	-- (Optional) Don't display the function in the Category Editor rule function menu.
--- 	---@type boolean?
--- 	hideFromUi,
--- 
--- 	-- (Optional) Treat this function as a proxy or stub that can be overwritten
--- 	-- by another rule function. Only relevant to built-ins.
--- 	---@type boolean?
--- 	replaceable,
--- 
--- 	-- (Optional) Don't add this function if false.
--- 	---@type boolean|function?
--- 	conditional,
--- 
--- 	-- (Optional) Array of strings that will be used, in the order given,
---		-- to replace any %s placeholders in the templates pulled from localization.
---
--- 	---@type string[]
--- 	ruleFunctionTemplateFormatStrings,
--- }
--- ```
--- 
--- ## `ruleFunction` example
--- ```
--- ---@param rules table # The Rules class, with rules.item and rules.character being the current objects under evaluation.
--- ---@param ruleArguments any[] # List of all arguments provided to the function.
--- ---@return boolean
--- function(rules, ruleArguments)
---   return rules:TestItemAttribute("bagNum", ruleArguments, "number")
--- end
--- ```
--- ### How to return errors
--- Set the `rules.errorMessage` property to the error text and return `false`.
--- (This assumes your rule function's first parameter is named `rules`).  
--- **DO NOT** rely on `error()` since some addons (\*cough\* pfUI) break its normal functionality.
---@param params table Parameters -- see function comments for details.
function Rules:AddFunction(params)
	assert(type(params) == "table", "Rules:AddFunction() - params must be a table.")
	assert(type(params.functionNames) == "string" or type(params.functionNames) == "table", "Rules:AddFunction() - params.functionNames is required and must be a string or a table.")
	assert(type(params.ruleFunction) == "function", "Rules:AddFunction() - params.ruleFunction is required and it must be a function.")
	assert(params.environmentVariables == nil or type(params.environmentVariables) == "table", "Rules:AddFunction() - params.environmentVariables must be a table.")
	assert(params.ruleTemplates == nil or type(params.ruleTemplates) == "table", "Rules:AddFunction() - params.ruleTemplates must be a table.")

	-- Support for overwriting aliases hasn't been added, so reject it for now.
	if params.replaceable and type(params.functionNames) == "table" and table.getn(params.functionNames) > 1 then
		Bagshui:PrintWarning("Aliases for stub functions are currently not supported. Please pass " .. tostring(params.functionNames[1]) .. " the only value in `functionNames` property table.")
		return
	end

	-- Ensure rule functions with conditions should be added.
	if
		(
			type(params.conditional) == "function"
			and not params.conditional()
		)
		or params.conditional == false
	then
		return
	end

	-- This function's API changed from individual parameters to a table so
	-- these could be cleaned up later.

	local functionNames = params.functionNames
	local ruleFunction = params.ruleFunction
	local environmentVariables = params.environmentVariables
	local ruleTemplates = params.ruleTemplates
	local hideFromUi = params.hideFromUi

	-- We'll accept a string as the function name but let's turn it into a table to make things consistent.
	if type(functionNames) == "string" then
		functionNames = { functionNames }
	end

	-- Create the function and add to environment.
	-- The first name that doesn't fail will become the primary name of the function.
	local primaryName

	-- This will be used to find example templates from localization in the case
	-- where an alternate primary name needs to be chosen.
	local desiredPrimaryName = functionNames[1]

	-- Track where the list of aliases starts.
	local firstAlias

	for i = 1, table.getn(functionNames) do
		---@diagnostic disable-next-line: assign-type-mismatch
		if self:AddEnvironmentFunction(ruleFunction, functionNames[i], nil, params.replaceable) then
			primaryName = functionNames[i]
			firstAlias = i + 1
			break
		end
	end

	-- We didn't find an acceptable name and the function hasn't been loaded,
	-- so there's nothing more to do.
	if not primaryName then
		return
	end

	-- Aliases are added as full environment functions so that error messages can
	-- reference the function as called. If we just used pointers, then a call to n()
	-- would result in error messages about Name(), which could be confusing.
	local aliasTooltipAddendum = ""
	for i = firstAlias, table.getn(functionNames) do
		self:AddEnvironmentFunction(ruleFunction, primaryName, functionNames[i], params.replaceable)
		aliasTooltipAddendum = aliasTooltipAddendum .. BS_NEWLINE .. functionNames[i] .. "()"
	end

	-- Add any rule environment variables.
	if environmentVariables then
		for variable, value in pairs(environmentVariables) do
			---@diagnostic disable-next-line: assign-type-mismatch
			self.environment[variable] = value
		end
	end

	-- Add rule function examples for use in the Category Editor rule function menu.
	if not hideFromUi then
		if ruleTemplates then
			-- Templates were provided directly to the function.
			self.ruleFunctionTemplates[primaryName] = ruleTemplates

			-- Sort entries within the templates list by code content.
			table.sort(
				self.ruleFunctionTemplates[primaryName],
				function(a, b)
					return (
						string.lower(a.text or a.code or "") < string.lower(b.text or b.code or "")
					)
				end
			)

		else
			-- Templates were not provided directly, so try to load from localization.
			self.ruleFunctionTemplates[primaryName] = {}

			self:AddRuleExamplesFromLocalization(primaryName, self.ruleFunctionTemplates, nil, desiredPrimaryName, params.ruleFunctionTemplateFormatStrings)

			-- If nothing was available, ensure there's at least one template entry
			-- of just the function name.
			if table.getn(self.ruleFunctionTemplates[primaryName]) == 0 then
				table.insert(
					self.ruleFunctionTemplates[primaryName],
					{
						code = (primaryName .. "()"),
					}
				)
			end
		end

		-- Check for supplemental examples and add them to the end of the list.
		-- (These are `RuleFunction_<PrimaryName>_ExampleExtraN` / `RuleFunction_<PrimaryName>_ExampleDescriptionExtraN`.)
		self:AddRuleExamplesFromLocalization(primaryName, self.ruleFunctionTemplatesExtra, "Extra", desiredPrimaryName, params.ruleFunctionTemplateFormatStrings)

		-- Add alias info to rule function examples.
		if type(self.ruleFunctionTemplates[primaryName]) == "table" then

			if string.len(aliasTooltipAddendum) > 0 then
				aliasTooltipAddendum =
					LIGHTYELLOW_FONT_COLOR_CODE .. string.format(L.Symbol_Colon, L.Aliases) .. FONT_COLOR_CODE_CLOSE
					.. GRAY_FONT_COLOR_CODE .. aliasTooltipAddendum .. FONT_COLOR_CODE_CLOSE

				-- Store the list of aliases as a single newline-separated string
				-- so it can be picked up by the Category editor and added to
				-- rule function menu tooltips. (This is adding a string-key
				-- value to an array-type table, which probably isn't ideal, but
				-- it doesn't cause issues with getn() and is an easy way to
				-- pass this information along.
				self.ruleFunctionTemplates[primaryName].aliasTooltipAddendum = BS_NEWLINE .. BS_NEWLINE .. aliasTooltipAddendum

				-- Append alias list to all rule example descriptions.
				for _, templateInfo in ipairs(self.ruleFunctionTemplates[primaryName]) do
					templateInfo.description =
						(templateInfo.description and (templateInfo.description .. BS_NEWLINE .. BS_NEWLINE) or "")
						.. aliasTooltipAddendum
				end


			end
		end

		-- Add to sorted list of rule function names so menus can be built in order.
		if not BsUtil.TableContainsValue(self.sortedRuleFunctionTemplateNames, primaryName) then
			table.insert(self.sortedRuleFunctionTemplateNames, primaryName)
			table.sort(self.sortedRuleFunctionTemplateNames)
		end

	end

end



--- Rules can have up to 20 examples added from localization (Locale folder), configured via:
--- * `RuleFunction_<PrimaryFunctionName>_ExampleN`
--- * `RuleFunction_<PrimaryFunctionName>_ExampleDescriptionN`
---
--- There can also be up to 20 "extra" examples added at the end of the list
--- which are usually leveraged to demonstrate multi-parameter usage.
--- * `RuleFunction_<PrimaryFunctionName>_ExampleExtraN`
--- * `RuleFunction_<PrimaryFunctionName>_ExampleDescriptionExtraN`
--- 
--- The presence of a `RuleFunction_<PrimaryFunctionName>_GenericDescription`
--- will set the tooltip for the parent menu item that opens the submenu.
---@param ruleFunctionName string Key to search for in localization.
---@param ruleFunctionTemplates table? If not provided, just get the count of examples.
---@param exampleSuffix string? "Extra" to get extra items.
---@param desiredRuleFunctionName? string Use this to search for examples instead of `ruleFunctionName`, then switch the code examples from this to `ruleFunctionName`.
---@param exampleDescriptionFormatStrings table? Up to 5 strings that will be used as %s replacements in the rule example description.
---@return number exampleCount Number of examples that were added.
function Rules:AddRuleExamplesFromLocalization(ruleFunctionName, ruleFunctionTemplates, exampleSuffix, desiredRuleFunctionName, exampleDescriptionFormatStrings)
	if type(ruleFunctionName) ~= "string" then
		return 0
	end

	exampleSuffix = exampleSuffix or ""
	local exampleCount = 0

	local functionNameForLocalization = desiredRuleFunctionName or ruleFunctionName

	-- Determine the generic description of this rule function that will be used
	-- in the tooltip for the parent menu item in the Category Editor rule function menu.
	if exampleSuffix == "" then
		local genericDescription = L_nil["RuleFunction_" .. functionNameForLocalization .. "_GenericDescription"]
		if type(exampleDescriptionFormatStrings) == "table" and genericDescription then
			genericDescription = string.format(
				genericDescription,
				exampleDescriptionFormatStrings[1] or "",
				exampleDescriptionFormatStrings[2] or "",
				exampleDescriptionFormatStrings[3] or "",
				exampleDescriptionFormatStrings[4] or "",
				exampleDescriptionFormatStrings[5] or ""
			)
		end

		self.ruleFunctionTemplateGenericDescriptions[ruleFunctionName] = genericDescription
	end

	-- Pull all the available examples from localization.
	for i = 1, 20 do
		local code = L_nil["RuleFunction_" .. functionNameForLocalization .. "_Example" .. exampleSuffix .. i]
		if not code then
			break
		end

		exampleCount = exampleCount + 1

		-- This check is to allow calling the function to just get the count of examples.
		if ruleFunctionTemplates then
			local exampleDescription = L_nil["RuleFunction_" .. functionNameForLocalization .. "_ExampleDescription" .. exampleSuffix .. i]

			-- Update description with format strings.
			if type(exampleDescriptionFormatStrings) == "table" and exampleDescription then
				exampleDescription = string.format(
					exampleDescription,
					exampleDescriptionFormatStrings[1] or "",
					exampleDescriptionFormatStrings[2] or "",
					exampleDescriptionFormatStrings[3] or "",
					exampleDescriptionFormatStrings[4] or "",
					exampleDescriptionFormatStrings[5] or ""
				)
			end


			-- This rule function couldn't be loaded under its original name so the code needs to change.
			if desiredRuleFunctionName ~= ruleFunctionName and desiredRuleFunctionName ~= nil then
				code = (string.gsub(code, desiredRuleFunctionName .. "%(", ruleFunctionName .. "("))
			end

			if not ruleFunctionTemplates[ruleFunctionName] then
				ruleFunctionTemplates[ruleFunctionName] = {}
			end
			table.insert(
				ruleFunctionTemplates[ruleFunctionName],
				{
					code = code,
					description = exampleDescription,
				}
			)
		end
	end

	return exampleCount
end



--- Test an item attribute to see if it matches.
--- This is the function that most rules will use to perform their tests.
---@param attributeName string One of the properties in the `BS_ITEM_SKELETON` table.
---@param argumentList any[] The list of arguments proved to the rule function.
---@param validArgumentTypes string? Key from `BS_RULE_ARGUMENT_TYPE` (case and whitespace insensitive). Defaults to "STRING". NOTE: When matchType is `BS_RULE_MATCH_TYPE.BETWEEN`, `validArgumentTypes` is forced to `BS_RULE_ARGUMENT_TYPE.NUMBER`.
---@param matchType BS_RULE_MATCH_TYPE? How will matching be performed (Equals/Contains/Between)? Defaults to EQUALS.
---@param betweenStartingPoint number? In BS_RULE_MATCH_TYPE.BETWEEN mode, use this to shift the lower lower (argumentList[1]) and upper (argumentList[2]) bounds: upper = betweenStartingPoint + upper, lower = betweenStartingPoint - lower (Primary use is for CharacterLevelRange()).
---@param betweenInfiniteUpperBound boolean? In BS_RULE_MATCH_TYPE.BETWEEN mode, when `table.getn(argumentList) == 11, any amount greater than lower will be a match.
---@param matchViaLocalization boolean? When true, also test to see if `L[<argument>]` matches.
---@return boolean itemAttributeMatches
function Rules:TestItemAttribute(
	attributeName,
	argumentList,
	validArgumentTypes,
	matchType,
	betweenStartingPoint,
	betweenInfiniteUpperBound,
	matchViaLocalization
)

	local errorMessage

	-- We need to have arguments.
	self.errorMessage = self:RequireArguments(argumentList)
	if errorMessage then
		return false
	end

	-- Default for matchType is "equal".
	matchType = matchType and string.upper(tostring(matchType))
	if not matchType or (matchType and not BS_RULE_MATCH_TYPE[matchType]) then
		matchType = BS_RULE_MATCH_TYPE.EQUALS
	end

	-- Validate validArgumentTypes by removing any spaces and uppercasing everything
	validArgumentTypes = validArgumentTypes and string.gsub(string.upper(tostring(validArgumentTypes)), "%s", "")

	-- Only permit numbers for "between" comparisons.
	if matchType == BS_RULE_MATCH_TYPE.BETWEEN then
		validArgumentTypes = BS_RULE_ARGUMENT_TYPE.NUMBER
	end

	-- Allow validArgumentTypes to be a key from the BS_RULE_ARGUMENT_TYPE table.
	if type(validArgumentTypes) == "string" then
		if not BS_RULE_ARGUMENT_TYPE[validArgumentTypes] then
			self.errorMessage = string.format(L.Error_RuleInvalidArgumentType, validArgumentTypes, self.allowedArgumentTypes)
			return false
		end
		validArgumentTypes = BS_RULE_ARGUMENT_TYPE[validArgumentTypes]
	end

	-- Default to string.
	if not validArgumentTypes then
		validArgumentTypes = BS_RULE_ARGUMENT_TYPE.STRING
	end

	-- Figure out whether we need to convert everything to lowercase strings.
	local isString = validArgumentTypes.string


	-- Make sure there's an attribute to work with.

	local itemAttribute = self.item[attributeName]

	if (itemAttribute == nil or itemAttribute == "") and not self.validationMode then
		return false
	end


	-- Test.
	if matchType == BS_RULE_MATCH_TYPE.BETWEEN then
		-- "Between" match: Check if the specified numeric attribute is between the given arguments.

		-- Determine upper and lower bounds.
		local lower, upper
		local infiniteUpperBound = (betweenInfiniteUpperBound == true)

		-- Lower is always the first argument, but default to 0 just to be safe.
		lower = argumentList[1] or 0

		-- Upper is either the second argument or it becomes equal to the lower bound,
		-- unless it should be infinite.
		if table.getn(argumentList) > 1 then
			upper = argumentList[2]
		elseif not infiniteUpperBound then
			upper = lower
		end

		-- Validate arguments.
		self.errorMessage = self:ValidateArgumentType(lower, 1, BS_RULE_ARGUMENT_TYPE.NUMBER)
		if errorMessage then
			return false
		end
		-- Silly way of allowing infiniteUpperBound without argumentList[2] to pass the test.
		self.errorMessage = self:ValidateArgumentType(upper or (infiniteUpperBound and 0), 2, BS_RULE_ARGUMENT_TYPE.NUMBER)
		if errorMessage then
			return false
		end

		-- Change starting point of bounds comparison.
		if betweenStartingPoint then
			lower = betweenStartingPoint - lower
			upper = upper and (betweenStartingPoint + upper)  -- Leave nil if it was nil to begin with.
		end

		return
			itemAttribute >= lower
			and (
				(upper and (itemAttribute <= upper))
				or (not upper and infiniteUpperBound)
			)


	else
		-- All other match types.

		-- Convert to lowercase string if needed.
		if isString then
			itemAttribute = string.lower(tostring(itemAttribute) or "")
		end

		-- Compare arguments.
		-- Need to iterate by using getn() instead of ipairs() so nil doesn't stop iteration.
		for i = 1, table.getn(argumentList) do
			local argument = argumentList[i]
			self.errorMessage = self:ValidateArgumentType(argument, i, validArgumentTypes)
			if self.errorMessage then
				return false
			end

			-- Convert to lowercase string if needed.
			if isString then
				argument = BsUtil.Trim(tostring(argument) or "")

				-- Wrapping a string in slashes triggers Lua pattern matching.
				-- Otherwise, magic characters will be escaped.
				if string.find(argument, "^/.-/$") then
					-- Avoid lowercasing escaped Lua pattern class complements (%A, for example),
					-- by wrapping them with a unique string, then unwrapping them afterwards.
					argument = string.gsub(
						string.lower(
							string.gsub(
								string.gsub(argument, "^/(.-)/$", "%1"),  -- Remove wrapping slashes.
								"(%%[ACDGLPSUWX])",
								"~~~@@@%1@@@~~~"
							)
						),
						"~~~@@@(%%[acdglpsuwx])@@@~~~",
						function(match)
							return string.upper(match)
						end
					)
				else
					-- String literal -- just lowercase it.
					argument = string.lower(BsUtil.EscapeMagicCharacters(argument))
				end
			end

			-- Bagshui:PrintDebug("TESTING " .. itemAttribute .. " == " .. argument)

			-- Do we have a match?
			if matchType == BS_RULE_MATCH_TYPE.EQUALS then
				if itemAttribute == argument or (matchViaLocalization and itemAttribute == L[argument]) then
					return true
				end

			elseif matchType == BS_RULE_MATCH_TYPE.CONTAINS then
				if string.find(itemAttribute, argument) then
					return true
				end
			end

		end

	end

	-- Default to false.
	return false
end



--- Throw an error if no arguments were provided to a function that needs them.
---@param ruleArguments any[] The list of arguments proved to the rule function.
---@return string? errorMessage
function Rules:RequireArguments(ruleArguments)
	if type(ruleArguments) ~= "table" or table.getn(ruleArguments) == 0 then
		return L.Error_RuleNoArguments
	end
end



-- Throw an error if invalid argument types were provided
-- Usage: ArgumentType(argument, argumentNum, <BS_RULE_ARGUMENT_TYPE constant>)
--- Throw an error if invalid argument types were provided.
---@param ruleArgument any User-supplied rule parameter.
---@param argumentNum number Parameter position, used in the error message.
---@param validArgumentTypes BS_RULE_ARGUMENT_TYPE? Value from the BS_RULE_ARGUMENT_TYPE enum. Defaults to string if not provided.
---@return string? errorMessage
function Rules:ValidateArgumentType(ruleArgument, argumentNum, validArgumentTypes)
	if ruleArgument == nil then
		return string.format(L.Error_RuleNilArgument, argumentNum)
	end

	-- Default to string
	if type(validArgumentTypes) ~= "table" then
		validArgumentTypes = BS_RULE_ARGUMENT_TYPE.STRING
	end

	-- Check the argument type
	local argumentType = type(ruleArgument)
	if not validArgumentTypes[argumentType] then
		return string.format(
			L.Error_RuleInvalidArgument,
			argumentNum,
			tostring(ruleArgument),
			argumentType,
			(function()
				local types = ""
				for type, _ in pairs(validArgumentTypes) do
					types = types .. (string.len(types) > 0 and ", " or "") .. type
				end
				return types
			end)()
		)
	end
end



--- Test whether a rule expression is valid.
---@param expression string
---@param startup boolean? Sets the `Rules.startup` property, which is read by `Rules:RuleErrorNotAtStartup()`
---@return boolean valid Is the rule valid?
---@return string? errorMessage When the rule is invalid, this is the error message.
function Rules:Validate(expression, startup)
	-- Run the rule expression through multiple scenarios to try and catch every possible failure state:
	-- 1. Normal
	-- 2. Return true from every rule function
	-- 3. Return false from every rule function
	-- Not using a session here because SetItemAndCharacter() already does a check to only update when the item changes.
	self.startup = startup
	self.validationMode = true
	self.validationModeReturnValueOverride = nil
	local _, errorMessage = self:Match(expression, BS_ITEM_SKELETON)
	if errorMessage == nil then
		self.validationModeReturnValueOverride = true
		_, errorMessage = self:Match(expression, BS_ITEM_SKELETON)
		if errorMessage == nil then
			self.validationModeReturnValueOverride = false
			_, errorMessage = self:Match(expression, BS_ITEM_SKELETON)
		end
		self.validationModeReturnValueOverride = nil
	end
	self.validationMode = false
	self.startup = nil
	return (errorMessage == nil), errorMessage
end



--- Evaluate an arbitrary rule expression against the given item.
---@param ruleFunctionOrExpression string|function|nil Rule expression or pre-compiled expression that will return a boolean. Needs to accept functions because the Categories class pre-compiles rule expressions for speed.
---@param item table? Entry from the Bagshui item cache or `ItemInfo:Get()`. Required *unless* `session` is provided.
---@param character table? Character information as generated by the Bagshui Character class.
---@param session number? Session identifier obtained by calling `Rules:SetItemAndCharacter()` (see that function's declaration for details).
---@return boolean
---@return string? errorMessage
function Rules:Match(ruleFunctionOrExpression, item, character, session, isSearch)
	self.errorMessage = nil

	-- Wrap simple strings in `Name()` and strip `=` from the beginning of expressions.
	if isSearch then
		ruleFunctionOrExpression = self:CreateSearchRule(ruleFunctionOrExpression)
	end

	-- We cached the compiled version of this rule string.
	if ruleFunctionOrExpression == self.lastRuleString and type(self.lastRuleStringCompiled) == "function" then
		ruleFunctionOrExpression = self.lastRuleStringCompiled
	end

	-- Didn't get a usable input.
	if type(ruleFunctionOrExpression) ~= "function" and type(ruleFunctionOrExpression) ~= "string" then
		return false
	end

	-- Here's what we're working on.
	self:SetItemAndCharacter(item, character, session)

	---@type string|function?
	local ruleFunction = ruleFunctionOrExpression
	local errorMessage

	-- Compile if needed.
	if type(ruleFunctionOrExpression) ~= "function" then
		ruleFunction, errorMessage = self:Compile(ruleFunctionOrExpression)
	end
	if type(ruleFunction) ~= "function" or errorMessage then
		return false, errorMessage
	end

	-- Evaluate the rule.
	setfenv(ruleFunction, self.environment)
	local status, retVal = pcall(ruleFunction)

	-- Return values.
	if status and self.errorMessage == nil then
		-- Cache the most recent rule compilation for quick reuse during searches.
		if type(ruleFunctionOrExpression) == "string" then
			self.lastRuleString = ruleFunctionOrExpression
			self.lastRuleStringCompiled = ruleFunction
		end
		return retVal
	else
		return false, self.errorMessage or retVal
	end
end



--- Prepare the rule environment for evaluation by:
--- 1. Setting `self.item` and `self.character` to the given item and character, respectively.
--- 2. Making `item`/`character` available within the rule environment (and therefore as the `i`/`c` aliases).
---
--- This is called from `Rules:Match()` before testing a rule expression, but to speed things up
--- just a little more, it can also be used to establish a "session", which short-circuits
--- everything and stops any further checks or updates to item/character within the same session.
--- A session can be established by storing this function's return value and passing it to `Rules:Match()`.
---@param item table? Entry from the Bagshui item cache or `ItemInfo:Get()`. Required *unless* `session` is provided.
---@param character table? Character information as generated by the Bagshui Character class.
---@param session number? Session identifier obtained from a previous call to `Rules:SetItemAndCharacter()` (see notes above).
---@return number|nil session
function Rules:SetItemAndCharacter(item, character, session)
	-- Established session - don't do anything.
	if session ~= nil and session == self.currentSession then
		return
	end

	assert(type(item) == "table", "item is required for rule evaluation to occur")

	-- Only update item in the rule environment if it has changed.
	if self.item ~= item then
		self.item = item
		-- Copy item to the rule environment so things can't be broken by accidental misuse of = instead of ==.
		BsUtil.TableCopy(item, self.environment.item)
	end

	-- Only update character in the rule environment if it has changed.
	if self.character ~= character or (not character and self.character ~= Bagshui.currentCharacterInfo) then
		self.character = character or Bagshui.currentCharacterInfo
		-- Copy character to the rule environment so things can't be broken by accidental misuse of = instead of ==.
		-- character gets basic stuff only, no spells or skills.
		BsUtil.TableClear(self.environment.character)
		for key, value in pairs(self.character) do
			if type(value) ~= "table" then
				self.environment.character[key] = value
			end
		end
	end

	self.currentSession = _G.GetTime()
	return self.currentSession
end



--- Wrap the given ruleExpression string in `"return ( )"` and run it through loadstring to turn it into a function.
---@param ruleExpression string Lua code to load. Expected to produce a boolean.
---@return function?
---@return string? errorMessage
function Rules:Compile(ruleExpression)
	assert(type(ruleExpression) == "string", "ruleExpression must be a string")
	return loadstring("return (" .. ruleExpression .. ")")
end



--- Transform the given text to either a `name()` rule or if prefixed by `=`,
--- return the string as-is without the `=`.
---@param searchText any
---@return string|nil
function Rules:CreateSearchRule(searchText)
	if type(searchText) == "number" then
		searchText = tostring(searchText)
	elseif type(searchText) ~= "string" then
		return
	end
	if string.find(searchText, "^=") then
		return (string.gsub(searchText, "^=", ""))
	else
		return string.format("Name('%s')", string.gsub(searchText, "'", "\\'"))
	end
end



--- Execute the given rule function after performing basic validation.
---@param calledRuleFunctionName string Rule function to call.
---@param ruleArguments any[] List of user-provided arguments.
---@return boolean ruleFunctionReturnValue
---@return string? errorMessage
function Rules:Call(calledRuleFunctionName, ruleArguments)

	-- Make sure the function exists.
	-- Really just a safeguard since the environment metatable is primarily responsible for this.
	if not self.ruleFunctions[calledRuleFunctionName] then
		return false, string.format(L.Error_RuleFunctionInvalid, calledRuleFunctionName)
	end

	-- Make sure there's an item.
	if not self.item or (self.item and not self.item.id) then
		return false, "No item (this shouldn't happen!)"
	end

	-- Call the rule function.
	local status, retVal = pcall(self.ruleFunctions[calledRuleFunctionName], self, ruleArguments)
	if status and not self.errorMessage then
		-- Successful call to the rule function; return whatever the rule function returned.
		-- Override with self.validationModeReturnValueOverride if it's set.
		return (self.validationModeReturnValueOverride ~= nil) and self.validationModeReturnValueOverride or retVal
	else
		-- Something went wrong; pass the error on up.
		return false, string.format(L.Error_RuleExecution, calledRuleFunctionName .. "()", self.errorMessage or retVal)
	end

end



--- Add rule environment functions for all rule functions and aliases.
function Rules:PrepareEnvironment()

	-- Helper table so that caseInsensitiveMetatable can identify which variables are which.
	local environmentVariables = {
		item = self.environment.item,
		character = self.environment.character,
	}

	-- Metatable that makes table key lookups case-insensitive and adds keys
	-- when a miss occurs and a match is found.
	local caseInsensitiveMetatable = {
		__index = function(tbl, missingKey)
			for existingKey, exitingValue in pairs(tbl) do
				if string.lower(missingKey) == string.lower(existingKey) then
					-- Make the differently-cased rule function name available for `Rules:Call()` to reference.
					if tbl == self.environment and self.ruleFunctions[existingKey] then
						self.ruleFunctions[missingKey] = exitingValue
					end
					-- Cache the differently-cased key for future lookups. This will be persistent for
					-- Rules.environment. For item/character, it will only last until the next one,
					-- but that's fine.
					rawset(tbl, missingKey, exitingValue)
					return exitingValue
				end
			end

			-- Couldn't find a match.
			if tbl == self.environment then
				-- This occurred in the rule environment itself, so it was an issue with an invalid rule function.
				self.errorMessage = string.format(L.Error_RuleFunctionInvalid, missingKey)
				-- Make an assertion that will always fail to short-circuit code execution.
				-- Like everywhere else, not using error() because pfUI breaks it.
				-- We're not relying on assert()'s second parameter because there's no way to suppress line numbers from the 
				-- assertion and parsing it seems silly when we already have the class errorMessage property set up.
				-- This is safe to do because the Rules:Match() wrapper pcall()s the compiled rule function and
				-- when an error condition occurs, it prioritizes Rules.errorMessage over the pcall() error.
				assert(false)
			else
				-- The missing key was in the item or character tables, so figure out which.
				for environmentVariable, _ in pairs(environmentVariables) do
					if rawget(self.environment, environmentVariable) == tbl then
						self.errorMessage = string.format(L.Error_RuleVariablePropertyInvalid, missingKey, environmentVariable)
						-- Short-circuit code evaluation (see comment about the assert(false) just above).
						assert(false)
					end
				end
			end

		end
	}
	setmetatable(self.environment, caseInsensitiveMetatable)
	setmetatable(self.environment.item, caseInsensitiveMetatable)
	setmetatable(self.environment.character, caseInsensitiveMetatable)

	-- Add aliases for variables.

	self.environment.i = self.environment.item
	self.environment.c = self.environment.character
end



--- When a rule function has already been added, we want to keep the same letter-casing,
--- so do a case-insensitive search of the existing rule functions and aliases.
function Rules:GetExistingRuleFunctionName(ruleFunctionName)
	for existing, _ in pairs(self.ruleFunctions) do
		if string.lower(existing) == string.lower(ruleFunctionName) then
			return existing
		end
	end
	return ruleFunctionName
end



-- Add a function to the rule environment.
---@param ruleFunction function Function that will be called (see `Rules:AddFunction()` notes).
---@param primaryName string Name by which this function is primarily known.
---@param alias string? Alias to associate with the function, if any.
---@param replaceable boolean? See `replaceable` parameter of `Rules:AddFunction()`.
---@return boolean added True if the function was added.
function Rules:AddEnvironmentFunction(ruleFunction, primaryName, alias, replaceable)
	primaryName = self:GetExistingRuleFunctionName(primaryName)
	alias = self:GetExistingRuleFunctionName(alias or primaryName)

	-- Ensure we have the names formatted correctly.
	local classFunctionName, ruleFunctionName = self:GetRuleFunctionNames(primaryName, alias)

	-- Need a trigger to know when we're going to replace an existing function.
	local overwrite = false

	-- Warn on overwriting an existing rule function (or fail if a 3rd party tries to overwrite).
	if self.ruleFunctions[ruleFunctionName] then

		if
			self.builtInRuleFunctions[string.lower(ruleFunctionName)]
			and self.replaceableRuleFunctions[string.lower(ruleFunctionName)]
		then
			overwrite = true
			-- Only allow built-in stub functions to be overwritten once.
			self.replaceableRuleFunctions[string.lower(ruleFunctionName)] = nil

		elseif self.builtInRuleFunctions[string.lower(ruleFunctionName)] then
			-- Denied!
			Bagshui:PrintWarning(string.format(L.Warning_BuiltinRuleFunctionCollision, ruleFunctionName))
			return false
		else
			-- This is a 3rd party rule function -- allow overwriting with a warning.
			Bagshui:PrintWarning(string.format(L.Warning_RuleFunctionOverwrite, ruleFunctionName))
		end
	end

	-- Create primary function that lives on the rules class if it doesn't exist yet.
	if not self[classFunctionName] or overwrite then
		---@diagnostic disable-next-line: assign-type-mismatch
		self[classFunctionName] = ruleFunction
	end

	-- Save in the list of valid environment rule functions to actual functions so Call() can translate.
	self.ruleFunctions[ruleFunctionName] = self[classFunctionName]

	-- Need to know which rules are built-in for accurate warning messages.
	if not self.builtinRulesLoaded then
		self.builtInRuleFunctions[string.lower(ruleFunctionName)] = true
		if replaceable then
			self.replaceableRuleFunctions[string.lower(ruleFunctionName)] = true
		end
	end

	-- This is the actual function that exists within the rule environment. It's simply a wrapper that collects arguments,
	-- stores them, and passes them on to the actual rule function that lives outside the limited environment.
	-- Using explicit arguments instead of variadic (...) to avoid memory leaks per <https://github.com/shagu/pfUI/commit/e7dd8776f142a708e4677c1299ff89f1bcbe2baf>.
	-- If Vanilla's Lua interpreter was better-behaved, we could just use `self.environment[ruleFunctionName] = function(...)`.
	-- Somewhat arbitrarily limiting to 50 arguments -- could be changed if needed.
	-- The reason the table is passed instead of having rule functions reference it on the class is that the rule engine was
	-- initially designed to use variadic arguments and pass the magic arg table to the rule functions, so it was easier to
	-- keep that structure and swap self.ruleFunctionArguments in for arg.
	---@diagnostic disable-next-line: assign-type-mismatch
	self.environment[ruleFunctionName] = function(
		a1, a2, a3, a4, a5, a6, a7, a8, a9,
		a10, a11, a12, a13, a14, a15, a16, a17, a18, a19,
		a20, a21, a22, a23, a24, a25, a26, a27, a28, a29,
		a30, a31, a32, a33, a34, a35, a36, a37, a38, a39,
		a40, a41, a42, a43, a44, a45, a46, a47, a48, a49,
		a50, a51
	)
		-- Provide feedback if somehow the 50 argument limit is reached.
		if a51 ~= nil then
			self.error = string.format(L.Error_RuleTooManyArguments, ruleFunctionName, ruleFunctionName)
			return false
		end
		-- Reset reusable argument table and fill it up.
		BsUtil.TableClear(self.ruleFunctionArguments)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a1)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a2)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a3)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a4)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a5)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a6)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a7)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a8)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a9)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a10)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a11)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a12)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a13)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a14)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a15)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a16)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a17)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a18)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a19)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a20)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a21)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a22)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a23)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a24)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a25)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a26)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a27)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a28)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a29)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a30)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a31)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a32)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a33)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a34)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a35)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a36)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a37)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a38)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a39)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a40)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a41)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a42)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a43)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a44)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a45)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a46)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a47)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a48)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a49)
		BsUtil.TableInsertNonNil(self.ruleFunctionArguments, a50)
		-- Call the actual rule function.
		return self:Call(ruleFunctionName, self.ruleFunctionArguments)
	end

	-- Preemptively add lowercase version to sidestep metatable lookup (see `caseInsensitiveMetatable` in `Rules:PrepareEnvironment()`).
	if string.lower(ruleFunctionName) ~= ruleFunctionName then
		self.ruleFunctions[string.lower(ruleFunctionName)] = self.ruleFunctions[classFunctionName]
		self.environment[string.lower(ruleFunctionName)] = self.environment[ruleFunctionName]
	end

	return true
end



--- Generate the names rule functions are known by outside and inside the rule environment.
---@param primaryName string Main name of the rule function.
---@param alias string? Alias of the rule function.
---@return string classFunctionName Outside (rule class) function name: `Rule_<primaryName>`.
---@return string ruleFunctionName Inside (rule environment) function name: `<alias or primaryName>`.
function Rules:GetRuleFunctionNames(primaryName, alias)
	alias = alias or primaryName
	return
		-- The actual function we're calling on the Rule class SHOULD start with Rule_ (but don't double it up).
		"Rule_" .. string.gsub((primaryName or ""), "^[Rr]ule_", ""),

		-- The function INSIDE the rule environment should NOT start with Rule_.
		"" .. string.gsub((alias or ""), "^[Rr]ule_", "")
end



--
function Rules:RuleErrorNotAtStartup(errorMessage)
	if not self.startup then
		self.errorMessage = errorMessage
	end
end




-- Perform initialization
Rules:Init()


end)