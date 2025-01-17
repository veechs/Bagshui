-- Bagshui Core: Output
-- Logging and printing.

Bagshui:LoadComponent(function()

--- Log a message, formatted as: `[<Localized Type> <Timestamp>] <Component>: <Message>`.
--- When component is not present, the message will be `[<Localized Type> <Timestamp>] <Message>`.
---@param msg string
---@param component string? Prefix for the log message.
---@param type BS_LOG_MESSAGE_TYPE Log message type (severity).
function Bagshui:Log(msg, component, type)
	if not msg or (msg and string.len(tostring(msg)) == 0) then
		return
	end

	self:PruneLog()

	-- Ensure type can be localized.
	if not BS_LOG_TYPE_LOCALIZATION_KEY[type] then
		type = BS_LOG_MESSAGE_TYPE.INFORMATION
	end

	-- Save log string.
	table.insert(
		self.log,
		string.format(
			"%s[%s %s]%s%s%s %s%s",
			BS_LOG_MESSAGE_COLOR[type],  -- Color opener.
			L[BS_LOG_TYPE_LOCALIZATION_KEY[type]],  -- Localized log type.
			_G.date(BS_LOG_DATE_STRING),  -- Timestamp.
			FONT_COLOR_CODE_CLOSE,
			HIGHLIGHT_FONT_COLOR_CODE,
			(component and string.format(" %s:", tostring(component)) or ""),  -- Component.
			tostring(msg),  -- Message.
			FONT_COLOR_CODE_CLOSE
		)
	)

	self:RaiseEvent("BAGSHUI_LOG_UPDATE")
end



--- Remove any log messages over the configured limit.
function Bagshui:PruneLog()
	if table.getn(self.log) > BS_LOG_LIMIT then
		for i = 1, (table.getn(self.log) - BS_LOG_LIMIT) do
			table.remove(self.log, i)
		end
	end
end



--- Reset the log.
function Bagshui:ClearLog()
	BsUtil.TableClear(self.log)
	self:RaiseEvent("BAGSHUI_LOG_UPDATE")
end



--- Obtain the log as a single newline-concatenated string.
---@return string
function Bagshui:GetLogText()
	return table.concat(self.log, BS_NEWLINE)
end




--- Add a line of text to the specified frame (default to the primary chat frame),
--- formatted as: `[Bagshui Component] <Message>` or `[Bagshui] <Message>`.
---@param msg string Text to add.
---@param component string? If specified, add this to the message prefix.
---@param r number? Text color: red component.
---@param g number? Text color: green component.
---@param b number? Text color: blue component.
---@param a number? Text color: alpha component.
---@param frame table? Alternate frame to use instead of the default chat frame.
---@param duration number? Time in seconds after which the message should fade out.
---@param noPrefix boolean? When true, omit the `[Bagshui]` prefix.
function Bagshui:Print(msg, component, r, g, b, a, frame, duration, noPrefix)
	frame = frame or _G.DEFAULT_CHAT_FRAME
	if frame then
		frame:AddMessage(
			string.format(
				"%s%s",
				(
					noPrefix and ""
					or string.format(
						"[Bagshui%s] ",
						(component and string.format(" %s", tostring(component)) or "")
					)
				),
				tostring(msg)
			),
			r or BS_COLOR.PRINT_BAGSHUI[1],
			g or BS_COLOR.PRINT_BAGSHUI[2],
			b or BS_COLOR.PRINT_BAGSHUI[3],
			a,
			duration
		)
	end
end



--- Wrapper for `Bagshui:Print()` with `noPrefix` set to `true`.
---@param msg string Parameter for `Bagshui:Print()`.
---@param r number? Parameter for `Bagshui:Print()`.
---@param g number? Parameter for `Bagshui:Print()`.
---@param b number? Parameter for `Bagshui:Print()`.
---@param a number? Parameter for `Bagshui:Print()`.
---@param component string? Parameter for `Bagshui:Print()`.
---@param frame table? Parameter for `Bagshui:Print()`.
---@param duration number? Parameter for `Bagshui:Print()`.
function Bagshui:PrintBare(msg, r, g, b, a, component, frame, duration)
	self:Print(msg, component, r, g, b, a, frame, duration, true)
end



--- Display and log an information-type message.
---@param msg string
---@param component string? If specified, add this to the message prefix.
function Bagshui:PrintInfo(msg, component)
	self:Log(msg, component, BS_LOG_MESSAGE_TYPE.INFORMATION)
	self:Print(msg, component)
end



--- Display and log an error-type message.
---@param msg string
---@param component string? If specified, add this to the message prefix.
function Bagshui:PrintError(msg, component)
	self:Log(msg, component, BS_LOG_MESSAGE_TYPE.ERROR)
	self:Print(
		msg,
		component,
		BS_COLOR.PRINT_ERROR[1],
		BS_COLOR.PRINT_ERROR[2],
		BS_COLOR.PRINT_ERROR[3]
	)
end



--- Display and log a warning-type message.
---@param msg string
---@param component string? If specified, add this to the message prefix.
function Bagshui:PrintWarning(msg, component)
	self:Log(msg, component, BS_LOG_MESSAGE_TYPE.WARNING)
	self:Print(
		msg,
		component,
		BS_COLOR.PRINT_WARNING[1],
		BS_COLOR.PRINT_WARNING[2],
		BS_COLOR.PRINT_WARNING[3]
	)
end



--- Display and (optionally) log a transient error message.
---@param msg string
---@param component string? If specified, add this to the message prefix.
---@param r number? Parameter for `Bagshui:Print()`.
---@param g number? Parameter for `Bagshui:Print()`.
---@param b number? Parameter for `Bagshui:Print()`.
---@param a number? Parameter for `Bagshui:Print()`.
---@param duration number? Time in seconds after which the message should fade out (default: 3 seconds).
---@param log boolean? `true` save the message to the log.
---@param noPrefix boolean? Parameter for `Bagshui:Print()`.
function Bagshui:ShowErrorMessage(msg, component, r, g, b, a, duration, log, noPrefix)
	if log then
		Bagshui:Log(msg, component, BS_LOG_MESSAGE_TYPE.ERROR)
	end
	self:Print(
		msg,
		component,
		r or 1,
		g or 0,
		b or 0,
		a or 1,
		_G.UIErrorsFrame,
		duration or 3,
		noPrefix
	)
end



--- Wrapper for `Bagshui:ShowErrorMessage()` that always logs the message.
---@param msg string
---@param component string?
---@param r number?
---@param g number?
---@param b number?
---@param a number?
---@param duration number?
function Bagshui:ShowAndLogErrorMessage(msg, component, r, g, b, a, duration)
	self:ShowErrorMessage(
		msg,
		component,
		r, g, b, a,
		duration,
		true
	)
end



--- Add a chat message only if `self.debug` is true.
---@param msg any Parameter for `Bagshui:Print()`.
---@param component string? Parameter for `Bagshui:Print()`.
---@param r number? Parameter for `Bagshui:Print()`.
---@param g number? Parameter for `Bagshui:Print()`.
---@param b number? Parameter for `Bagshui:Print()`.
function Bagshui:PrintDebug(msg, component, r, g, b)
	if self.debug then
		if type(msg) == "table" then
			self:PrintTable(msg, component)
		end
		-- Enable for timestamps
		--msg = _G.GetTime() .. ":" .. msg
		self:Print(tostring(msg), component, r, g, b)
	end
end



--- Display the contents of a table.
--- Credit: tprint from https://stackoverflow.com/a/47392487
---@param t any
---@param s any
---@param depth number?
---@param component string? Parameter for `Bagshui:Print()`.
function Bagshui:PrintTable(t, s, depth, component)
	depth = depth or 1
	if depth > 8 then
		self:PrintDebug(">> RECURSION STOPPED", component)
		return
	end
	if t == nil then
		self:PrintDebug('**nil**', component)
		return
	end
	if type(t) == 'function' then
		self:PrintDebug('<function>', component)
		return
	end
	-- Special handling for WoW frames.
	if type(t) == "table" and t.GetObjectType or t.GetName or (t[0] and type(t[0]) == "userdata") then
		self:PrintDebug(type(t)..(s or '')..' = '..t:GetObjectType()..": "..tostring(t:GetName()), component)
		return
	end
	if type(t) ~= 'table' then
		self:PrintDebug(t, component)
		return
	end
	for k, v in pairs(t) do
        local keyPrint = '[' .. BsUtil.ToPrintableString(k) ..']'
        local valuePrint = BsUtil.ToPrintableString(v, true)
        if type(v) == 'table' then
            self:PrintTable(v, (s or '')..keyPrint, depth + 1, component)
        else
            if type(v) ~= 'string' then
                valuePrint = tostring(v)
            end
			self:PrintDebug(type(t)..(s or '')..keyPrint..' = '..valuePrint, component)
        end
    end
end


end)