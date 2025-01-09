-- Bagshui Slash Command Handler
-- Exposes: BsSlash (and Bagshui.components.Slash)
-- 
-- This is pretty minimal and only handles first-level tokens (/bagshui [something]).
-- Any higher-level tokens need to be dealt with by the handler function.
-- 
-- If slash commands ever get more complex, this will need to be expanded.

Bagshui:LoadComponent(function()

local Slash = {
	handlerList = {},
	handlerLocalized = {},
	hiddenHandlers = {},
	tokens = {},
}

Bagshui.environment.BsSlash = Slash
Bagshui.components.Slash = Slash



--- Handle a slash command.
---@param msg string Message provided by WoW from the user's input.
function Slash:Process(msg)
	self:Tokenize(msg)

	if not self.tokens[1] or not self.handlerList[self.tokens[1]] then
		self:PrintHandlers()
		return
	end

	self.handlerList[self.tokens[1]](self.tokens)
end



--- Add both the given and localized version of the `handlerName` to the
--- `Slash.handlerList` table so that it can be referenced either way.
---@param handlerName string Identifier for the handler command.
---@param handlerFunction function Function to call when the handler is invoked.
---@param hide boolean? When `true` the handler will not appear in the list output by `Slash:PrintHandlers()`.
function Slash:AddHandler(handlerName, handlerFunction, hide)
	handlerName = string.gsub(handlerName, "%s+", "")
	local localizedHandlerName = L_nil[handlerName] and string.gsub(L[handlerName], "%s+", "")
	self.handlerList[string.lower(handlerName)] = handlerFunction
	if localizedHandlerName then
		self.handlerList[string.lower(localizedHandlerName)] = handlerFunction
	else
		Bagshui:PrintWarning("No localized version of slash command handler '" .. handlerName .. "' has been defined!")
	end
	table.insert(self.handlerLocalized, localizedHandlerName or handlerName)
	table.sort(self.handlerList)
	table.sort(self.handlerLocalized)
	if hide then
		self.hiddenHandlers[localizedHandlerName or handlerName] = true
	end
end



--- Add a "smart" handler for classes that have Toggle/Open/Close actions.
--- This could be refactored to be more general-purpose but it's not worth it right now.
---@param handlerName string Identifier for the handler command.
---@param classObj table Class object.
---@param extraVerbs string[]? Additional verbs to list when `PrintHandlers()` is called.
---@param extraHandler function? `function(tokens) -> boolean` Handle other verbs, returning true if the handler should stop.
function Slash:AddOpenCloseHandler(handlerName, classObj, extraVerbs, extraHandler)

	-- List of available handler actions based on class functions.
	local handlerList = {}
	if type(classObj.Toggle) == "function" then
		table.insert(handlerList, L.Toggle)
	end
	if type(classObj.Open) == "function" then
		table.insert(handlerList, L.Show)
		table.insert(handlerList, L.Open)
	end
	if type(classObj.Close) == "function" then
		table.insert(handlerList, L.Hide)
		table.insert(handlerList, L.Close)
	end
	if type(extraVerbs) == "table" then
		for _, verb in ipairs(extraVerbs) do
			table.insert(handlerList, (string.gsub(verb, "%s+", "")))
		end
	end

	self:AddHandler(handlerName, function(tokens)
		if
			type(extraHandler) == "function"
			and extraHandler(tokens)
		then
			return

		elseif
			type(classObj.Toggle) == "function"
			and (
				not tokens[2]  -- Default to Toggle if available and if no verb is specified.
				or BsUtil.MatchLocalizedOrNon(tokens[2], "toggle")
			)
		then
			classObj:Toggle()
			return

		elseif
			type(classObj.Open) == "function"
			and (
				not tokens[2]  -- Fall back to Open if no verb is specified and Toggle not available.
				or BsUtil.MatchLocalizedOrNon(tokens[2], "show")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "open")
			)
		then
			classObj:Open()
			return

		elseif
			type(classObj.Close) == "function"
			and (
				BsUtil.MatchLocalizedOrNon(tokens[2], "hide")
				or BsUtil.MatchLocalizedOrNon(tokens[2], "close")
			)
		then
			classObj:Close()
			return

		end

		-- Couldn't find any matching actions to take.
		self:PrintHandlers(handlerList, handlerName)
	end)
end



--- Break slash command parameters into individual words and store in `Slash.tokens`.
---@param msg string Message provided by WoW -- this is everything after /bagshui or /bs.
function Slash:Tokenize(msg)
	BsUtil.TableClear(self.tokens)
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(self.tokens, word)
	end
	if self.tokens[1] then
		self.tokens[1] = string.lower(self.tokens[1])
	end
end



--- Print the list of known handlers, or a provided alternative list.
---@param handlerList string[]? Array of strings to print.
---@param parentCommand string? Name of the parent command.
function Slash:PrintHandlers(handlerList, parentCommand)
	local indent = BS_NEWLINE .. "  "
	local list = ""
	if handlerList then
		table.sort(handlerList)
	end
	for _, handler in ipairs(handlerList or self.handlerLocalized) do
		if not self.hiddenHandlers[handler] then
			list =  list .. indent .. handler
		end
	end
	list = list .. indent .. L.Help
	if not parentCommand then
		list = list .. BS_NEWLINE .. L.Slash_Help_Postscript
	end
	Bagshui:PrintBare(
		string.format(L.Slash_Help, (parentCommand or "Bagshui")) .. list,
		nil, nil, nil, nil, nil, nil, nil, true
	)
end



-- Register slash commands.
_G.SLASH_Bagshui1 = "/bagshui"
_G.SLASH_Bagshui2 = "/bs"
function _G.SlashCmdList.Bagshui(msg)
	Slash:Process(msg)
end


end)