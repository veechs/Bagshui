-- Bagshui Utility Functions
-- Exposes: BsUtil (and Bagshui.components.Util)

Bagshui:LoadComponent(function()


local Util = {}
Bagshui.environment.BsUtil = Util
Bagshui.components.Util = Util


--#region Strings


-- In Lua, "." won't match multi-byte UTF8 characters. This pattern will.
local ANY_CHAR_INCL_UTF8 = "[%z\1-\127\194-\244][\128-\191]*"



--- Remove whitespace (or desired characters) from beginning and end of a string.
---@param str string
---@param trim string? Characters to trim instead of whitespace.
---@return string
function Util.Trim(str, trim)
	trim = trim or "[%s\n]"
	return (string.gsub(str, "^" .. trim .. "*(.-)" .. trim .. "*$", "%1"))
end



-- Reusable table for Util.Split().
local split_ReturnTable = {}


--- Split a string by the provided delimiter (whitespace by default).
--- Credit: https://stackoverflow.com/a/76989560
---@param str string
---@param delimiter string Character(s) or pattern by which to split the string.
---@param delimiterIsPattern boolean? Don't escape pattern characters in `delimiter`.
---@param includeEmpty boolean? Include empty strings in the results.
---@return string[] # `str` split into multiple strings.
function Util.Split(str, delimiter, delimiterIsPattern, includeEmpty)
	assert(type(str) == "string", "Util.Split() - str must be a string (was " .. type(str) .. ": " .. tostring(str) .. ")")

	Util.TableClear(split_ReturnTable)

	if not delimiter then
		delimiter = "%s+"
	elseif not delimiterIsPattern then
		delimiter = Util.EscapeMagicCharacters(delimiter)
	end

	str = string.gsub(str, delimiter, "\1")

	for match in string.gfind(str, "([^\1]" .. (includeEmpty and "*" or "+") .. ")") do
		table.insert(split_ReturnTable, match)
	end

	return split_ReturnTable
end



--- Escape the magic characters used in Lua patterns so they are interpreted literally.
---@param str any
---@return string
function Util.EscapeMagicCharacters(str)
	return (string.gsub(str, "([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"))
end



-- Clean all WoW UI escape sequences from the given string.
-- Useful for matching text against tooltips which may contain formatting.
---@param str string
---@param extractHyperlinkContentsInsteadOfText boolean Get item links instead of the text displayed in the UI. ("|Hitem:1234:0:0:0|h[Item Name]|h" becomes "item:1234:0:0:0" instead of "[Item Name]")
---@return string
function Util.RemoveUiEscapes(str, extractHyperlinkContentsInsteadOfText)
	-- Font colors.
	str = string.gsub(str, "|c%w%w%w%w%w%w%w%w(.+)|r", "%1")
	-- Links.
	if extractHyperlinkContentsInsteadOfText then
		str = string.gsub(str, "|H(.+)|h.+|h", "%1")
	else
		str = string.gsub(str, "|H.+|h(.+)|h", "%1")
	end

	return str
end



--- Turn "This is a string" into "string a is This"
---@param str string
---@return string
function Util.ReverseStringByWords(str)
	local reversed = ""
    local nextWord = nil
	local remainingString = str

	repeat
		nextWord, remainingString = Util.SplitOnFirstSpace(remainingString)
		if reversed == "" then
			reversed = nextWord
		else
			reversed = nextWord .. " " .. reversed
		end
	until remainingString == ""

	return reversed
end



-- Split a string at the first instance of a space.
-- Used by ReverseStringByWords
---@param str string
---@return string nextWord
---@return string remainingString
function Util.SplitOnFirstSpace(str)
	if str then
		local firstWord = str
		local leftoverString = ""
		local nextSpacePosition = string.find(str, " ")

		if nextSpacePosition then
			firstWord = string.sub(str, 1, nextSpacePosition - 1)
			leftoverString = string.sub(str, nextSpacePosition + 1)
		end

		return firstWord, leftoverString
	else
		return "", ""
	end
end



-- Truncate a string to the specified length.
---@param str string
---@param len number
---@param noEllipsis boolean? Don't add an ellipsis to the end of the string when it's truncated.
---@return string
function Util.TruncateString(str, len, noEllipsis)
	local ret = Util.Utf8Sub(str, 1, len)
	-- Add ellipsis if needed.
	if not noEllipsis and Util.Utf8Len(ret) < Util.Utf8Len(str) then
		ret = ret .. "…"
	end
	return ret
end



--- Lowercase the first letter of a string.
---@param str string
---@return string
function Util.LowercaseFirstLetter(str)
	if type(str) ~= "string" then
		return ""
	end
	return (string.gsub(str, "^%w", string.lower))
end



--- Capitalize a string (uppercase first letter, lowercase the rest).
---@param str string
---@return string
function Util.Capitalize(str)
	if type(str) ~= "string" then
		return ""
	end
	return (string.gsub(string.lower(str), "^%w", string.upper))
end



-- Return a substring, taking UTF8 characters into account (UTF8 version of `string.sub()`).
---@param str string
---@param first number
---@param last number
---@return string
function Util.Utf8Sub(str, first, last)
	-- We'll need he original string length repeatedly.
	local len = Util.Utf8Len(str)

	if len == 0 then
		return ""
	end

	-- Go through the end if we didn't get a final position.
	if not last then
		last = len
	end

	-- Handle negatives.
	if first < 0 then
		first = len + first + 1
	end
	if last < 0 then
		last = len + last + 1
	end

	-- Prevent out of bounds.
	first = math.max(first, 1)
	last = math.min(last, len)

	-- Nothing to do if positions are inverted.
	if last < first then
		return ""
	end

	local desiredReturnLen = last - first + 1
	local ret = ""
	local i, firstChar, lastChar, charsFound, newLen

	-- Update i to be the REAL start (accounting for UTF8ness) point by iterating character-by-character.
	if first > 1 then
		charsFound = 0
		lastChar = 0
		repeat
			i = lastChar + 1
			_, lastChar = string.find(str, ANY_CHAR_INCL_UTF8, i) -- Step forward by the next single UTF character, which can be one or more ASCII character points.
			charsFound = charsFound + 1
		until charsFound == first
	end

	-- Build up the return string
	repeat
		-- Find the ASCII character positions of the next single UTF character.
		firstChar, lastChar = string.find(str, ANY_CHAR_INCL_UTF8, i)
		-- Add to return string.
		ret = ret .. string.sub(str, firstChar, lastChar)
		-- Increment start point for next iteration.
		i = lastChar + 1
		-- Calculate true length of return string.
		newLen = Util.Utf8Len(ret)
	until newLen >= desiredReturnLen or newLen >= len  -- (This is written with >= just to be safe).

	return ret
end



-- String length, taking into account UTF8 characters (UTF8 version of `string.len()`).
---@param str any
---@return integer
function Util.Utf8Len(str)
	if not str or type(str) == "table" then
		return 0
	end
	local _, len = string.gsub(tostring(str), ANY_CHAR_INCL_UTF8, "")
	return len
end



--- Return true when `str` matches either `strToMatch` or its localized equivalent.
--- Case-insensitive. 
---@param str string String to test.
---@param strToMatch string String to match.
---@return boolean
function Util.MatchLocalizedOrNon(str, strToMatch)
	if not str then
		return false
	end
	return
		string.lower(Util.Trim(str)) == string.lower(strToMatch)
		or string.lower(Util.Trim(str)) == string.lower(L[strToMatch])
end



function Util.ExtractErrorMessage(str)
	return string.gsub(str, "^.-:.-:%s*", "")
end


--#endregion Strings


--#region Numbers


--- Get the first number from a string.
---@param str any
---@return number?
function Util.ExtractNumber(str)
	local _, _, num = string.find(tostring(str), "(%d+)")
	return tonumber(num)
end



--- Scale a number from one range to another.
---@param num number Number to scale.
---@param originalMin number Source range minimum value.
---@param originalMax number Source range maximum value.
---@param scaledMin number Target range minimum value.
---@param scaledMax number Target range maximum value.
---@return number
function Util.ScaleNumber(num, originalMin, originalMax, scaledMin, scaledMax)
	return scaledMin + ((num - originalMin) * (scaledMax-scaledMin)) / (originalMax - originalMin)
end



--- Lua doesn't have native rounding.
---@param num number Number to round.
---@param decimals number? Precision (default: 2).
---@return number?
function Util.Round(num, decimals)
	if not num then
		return
	end
	return tonumber(string.format(
		"%." .. (decimals or 2) .. "f",
		num
  	))
end


--#endregion Numbers



--#region Tables


--- Deep table copy, optionally using a template table to filter keys and values.
--- Copy will be performed in-place (i.e. `dest` will be overwritten and will *not*
--- be returned). The only time a value is returned is when `dest` is not provided,
--- since a new table is created in this scenario.
---
--- #### `template` notes:
--- The general idea is that template keys define what keys will be copied from `source`,
--- and template values define the allowed data types for `source`'s values.
--- There are a few special cases:
--- * An associative key-value table as a template key will define a set of multiple
---   allowed keys. Each value associated with these keys in `source` will be expected
---   to follow the data types allowed by this template key's value.
---   See `BS_CATEGORY_SKELETON` for an example.
--- * A key with a single-value array-type table as its value will allow an array-type
---   table in the corresponding `source` location, with the data type of the single
---   value in the template's array. BS_CATEGORY_SKELETON also has an example of this.
--- * Providing a `tableWildcard` will whitelist any table found in `source` at a
---   template location that has the pointer to `tableWildcard` as its value.
---   See the profileSkeleton setup in Components\Profiles.lua for an example.
---@param source table Table to copy from.
---@param dest table? Table to copy into, or `nil` to copy into a new table and return that.
---@param forceKeyValueCopy boolean? Use key-value copy even when `table.getn(source) > 0`.
---@param template table? Table that defines the allowable structure of `source`. Anything not found in the template won't be copied.
---@param tableWildcard table? When the pointer to this table appears in the template, anything in the corresponding `source` location will be copied over.
---@param parentHadTableWildcard boolean? Will be `true` when a recursive call is made and the `tableWildcard` was found as the value.
---@return table? newDest Newly created copy if `dest` was not provided..
function Util.TableCopy(source, dest, forceKeyValueCopy, template, tableWildcard, parentHadTableWildcard)
	assert(type(source) == "table", "TableCopy(): type(source) = " .. type(source) .. " instead of table")
	assert(dest == nil or type(dest) == "table", "TableCopy:() type(dest) = " .. type(dest) .. " instead of table or nil")

	-- Use an empty table if we don't have a destination (or if destination is the same as source).
	local target = (dest and dest ~= source) and dest or {}

	-- Ensure the destination table is empty.
	Util.TableClear(target)

	-- Assume that table.getn() > 0 is an array -- pass forceKeyValueCopy to override this.
	if table.getn(source) > 0 and not forceKeyValueCopy then
		for i = 1, table.getn(source) do
			if type(source[i]) == "table" then
				table.insert(target, Util.TableCopy(source[i]))
			else
				table.insert(target, source[i])
			end
		end

	else
		-- Only process the template when the parent element in the template wasn't a wildcard.
		if template and not parentHadTableWildcard then

			-- Templates are handled by looping through the template instead of
			-- the source table, since anything that isn't in the template should
			-- be omitted.
			for key, templateVal in pairs(template) do

				if type(key) == "table" then
					-- If a table is found as a template key, use that to define
					-- a set of multiple allowed keys.
					for refKey, refVal in pairs(key) do
						if source[refKey] then
							if type(templateVal) == "table" then
								target[refKey] = Util.TableCopy(source[refKey], nil, nil, templateVal)
							else
								target[refKey] = source[refKey]
							end
						end
					end

				elseif type(templateVal) == "table" and table.getn(templateVal) == 1 and source[key] and templateVal ~= tableWildcard then
					-- When the template has an array-type table with a single value,
					-- use that to determine what type is allowed in the target array.
					target[key] = {}
					for _, sourceVal in ipairs(source[key]) do
						if type(sourceVal) == type(templateVal[1]) then
							if type(templateVal[1]) == "table" then
								table.insert(target[key], Util.TableCopy(sourceVal, nil, nil, templateVal[1]))
							else
								table.insert(target[key], sourceVal)
							end
						end
					end

				elseif source[key] ~= nil and type(source[key]) == type(templateVal) then
					-- Normal behavior - only copy if type matches.
					if type(templateVal) == "table" then
						-- Recurse for tables.
						target[key] = Util.TableCopy(
							source[key],
							nil,  -- No dest since we need to create a new table.
							nil,
							templateVal,
							tableWildcard,
							templateVal == tableWildcard  -- parentHadTableWildcard.
						)
					else
						target[key] = source[key]
					end
				end
			end

		else
			-- No template -- just copy everything.
			for key, val in pairs(source) do
				if type(val) == "table" then
					target[key] = Util.TableCopy(val)
				else
					target[key] = val
				end
			end
		end
	end

	-- Only return if dest was nil.
	if not dest then
		return target
	end
end



--- Wipe a table. Using this is easier on the garbage collector than creating a new table.
---@param tbl table
function Util.TableClear(tbl)
	if type(tbl) ~= "table" then
		return
	end

	-- Clear array-type tables first so table.insert will start over at 1.
	for i = table.getn(tbl), 1, -1 do
        table.remove(tbl, i)
    end

	-- Remove any remaining associative table elements.
	-- Credit: https://stackoverflow.com/a/27287723
	for k in next, tbl do rawset(tbl, k, nil) end
end



--- Get the actual table size regardless of whether it's a numeric or associative array.
---@param tbl table
---@return integer # Count of all elements.
function Util.TrueTableSize(tbl)
	if type(tbl) ~= "table" then
		return 0
	end
	local size = 0
	for k,v in pairs(tbl) do
		size = size + 1
	end
	return size
end



--- Find the key (index) of the given element in a table.
---@param table table
---@param element any
---@return any? # Key/index of element, or nil if not found.
function Util.TableContainsValue(table, element)
	if type(table) ~= "table" then
		return nil
	end
	for key, value in pairs(table) do
		if value == element then
			return key
		end
	end
	return nil
end



--- `table.insert()`, but only if `val` isn't `nil`.
---@param tbl table Table into which `val` will be inserted.
---@param val any Value to insert.
---@param emptyStringAsNil boolean? Treat empty string as nil.
---@return boolean # Whether insert was performed.
function Util.TableInsertNonNil(tbl, val, emptyStringAsNil)
	if
		type(tbl) ~= "table"
		or val == nil
		or (emptyStringAsNil and type(val) == "string" and string.len(val) == 0)
	then
		return false
	end
	table.insert(tbl, val)
	return true
end



--- Remove an item from an array-type table.
---@param tbl table
---@param item any Value of array entry to remove.
function Util.TableRemoveArrayItem(tbl, item)
	if type(tbl) ~= "table" then
		return
	end

	for i = table.getn(tbl), 1, -1 do
		if tbl[i] == item then
			table.remove(tbl, i)
		end
	end
end



--- Add an item to an array-type table only if it isn't already present.
---@param tbl table
---@param item any Value to add.
function Util.TableInsertArrayItemUnique(tbl, item)
	if type(tbl) ~= "table" then
		return
	end
	if not Util.TableContainsValue(tbl, item) then
		table.insert(tbl, item)
	end
end


--#endregion Tables



--#region Classes


--- Instantiate a new class with multiple inheritance.
--- https://www.lua.org/pil/16.3.html
---@param ... table Parent classes, in order of priority (i.e. array index #1 is the highest priority superclass).
---@return table newClass
function Util.NewClass(...)
	local newClass = {}
	local metatable = {}

	-- newClass will search for each property it doesn't have in
	-- its superclasses (arg is the list of superclasses).
	setmetatable(metatable, {
		__index = function(_, prop)
			return Util.FindSuperclassProperty(prop, arg)
		end
	})
	metatable.__index = metatable

	-- Create and return the new class.
	setmetatable(newClass, metatable)
	return newClass
end



--- Helper function to implement multiple inheritance.
--- Iterates the list of superclasses and return the value of `prop` from the first one that has it.
---@param prop any
---@param parents table[]
---@return any?
function Util.FindSuperclassProperty(prop, parents)
	for i = 1, table.getn(parents) do
		local value = parents[i][prop]
		if value then
			return value
		end
	end
end


--#endregion Classes



--#region WoW UI


-- Convert "LEFT" to "RIGHT" and "TOP" to "BOTTOM" (and vice versa).
---@param point string
---@return string
function Util.FlipAnchorPoint(point)
	if point == "LEFT" or point == "RIGHT" then
		return (point == "LEFT") and "RIGHT" or "LEFT"
	elseif point == "TOP" or point == "BOTTOM" then
		return (point == "TOP") and "BOTTOM" or "TOP"
	end
	return point
end



--- Flip only one part of a multi-component anchor.
---```
--- Util.FlipAnchorPointComponent("TOPLEFT", 1) -> "BOTTOMLEFT"
--- Util.FlipAnchorPointComponent("TOPLEFT", 2) -> "TOPRIGHT"
---```
---@param point string
---@param componentNum number? 1 for the first half, 2 for the second half (defaults to 1).
---@return string
function Util.FlipAnchorPointComponent(point, componentNum)
	-- "^%s" for componentNum 1 or "%s$" for componentNum 2.
	-- This allows matching "^TOP"/"^BOTTOM" at the start of the string for
	-- `componentNum` 1, but "^LEFT"/"^RIGHT" will never match (and the same
	-- for `componentNum` 2 with "LEFT$"/"RIGHT$").
	local searchAnchor = ((componentNum == 1 or not componentNum) and "^" or "") .. "%s" .. (componentNum == 2 and "$" or "")

	if string.find(point, string.format(searchAnchor, "LEFT")) then
		return (string.gsub(point, string.format(searchAnchor, "LEFT"), "RIGHT"))
	end

	if string.find(point, string.format(searchAnchor, "RIGHT")) then
		return (string.gsub(point, string.format(searchAnchor, "RIGHT"), "LEFT"))
	end

	if string.find(point, string.format(searchAnchor, "BOTTOM")) then
		return (string.gsub(point, string.format(searchAnchor, "BOTTOM"), "TOP"))
	end

	if string.find(point, string.format(searchAnchor, "TOP")) then
		return (string.gsub(point, string.format(searchAnchor, "TOP"), "BOTTOM"))
	end

	return point
end



-- Return "LEFT", "RIGHT", or "" (i.e. center) depending on the provided anchor.
---@param point string
---@return string
function Util.GetAnchorLeftRight(point)
	return (
		(point ~= "BOTTOM" and point ~= "TOP")
		and (point and (string.find(point, "RIGHT$") and "RIGHT" or "LEFT"))
		or ""
	)
end



--- Take a RGB percent set (0.0-1.0) and convert it to a hex string.
--- Credit: https://warcraft.wiki.gg/wiki/RGBPercToHex
---@param r number Red
---@param g number Blue
---@param b number Green
---@return string hexColor
function Util.RGBPercentToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r*255, g*255, b*255)
end



--- Get a texture with its full path.
--- If the path has more than 2 backslashes, the path will be returned as-is.
--- Otherwise, the Bagshui addon path will be prefixed.
---@param path string
---@return string?
function Util.GetFullTexturePath(path)
	if not path then
		return
	end
	local _, slashCount = string.gsub(path, "\\", "")
	return slashCount > 1 and path or ("Interface\\AddOns\\Bagshui\\Images\\" .. path)
end



--- Helper function to remove some redundant code for determining when a menu frame
--- is offscreen and how much adjustment needs to be done to bring it back on.
--- This uses `UIParent:GetLeft/Right/Top/Bottom()` in lieu of `GetScreenWidth/Height()`,
--- which seems to work much better.
--- Written primarily for `Bagshui:ToggleDropDownMenu()` but also used elsewhere.
---@param frame table Menu frame.
---@param xy "x"|"y" Horizontal or vertical adjustment.
---@return number adjustment How much the frame needs to be moved to bring it back onscreen.
function Util.GetFrameOffscreenAmount(frame, xy)
	assert(frame and frame.GetScale, "Util.GetFrameOffscreenAmount(): frame does not appear to be a valid WoW UI frame.")
	xy = xy or "x"

	local lesserDirection = "Left"
	local greaterDirection = "Right"
	if string.lower(xy) == "y" then
		lesserDirection = "Bottom"
		greaterDirection = "Top"
	end

	local frameScale = frame:GetScale()

	-- Only apply UI scale to non-menu frames. For some reason I'm not going to bother figuring out,
	-- menu frame positions are only accurately calculated if they are NOT scaled by UIParent's scale,
	-- but other frames' positions need to be scaled. *shrug*
	if not string.find(frame:GetName(), "^DropDownList%d$") then
		frameScale = frameScale * _G.UIParent:GetScale()
	end

	local lesserDimension = frame["Get"..lesserDirection] and frame["Get"..lesserDirection](frame) or nil
	lesserDimension = lesserDimension and lesserDimension * frameScale
	local greaterDimension = frame["Get"..greaterDirection] and frame["Get"..greaterDirection](frame) or nil
	greaterDimension = greaterDimension and greaterDimension * frameScale


	local uiParentLesserDimension = _G.UIParent["Get"..lesserDirection](_G.UIParent) * _G.UIParent:GetScale()
	local uiParentGreaterDimension = _G.UIParent["Get"..greaterDirection](_G.UIParent) * _G.UIParent:GetScale()
	-- Bagshui:PrintDebug(xy .. " UIParent Lesser: " .. uiParentLesserDimension)
	-- Bagshui:PrintDebug(xy .. " Frame Lesser: " .. tostring(lesserDimension))
	-- Bagshui:PrintDebug(xy .. " UIParent Greater: " .. uiParentGreaterDimension)
	-- Bagshui:PrintDebug(xy .. " Frame Greater: " .. tostring(greaterDimension))

	if lesserDimension and lesserDimension < uiParentLesserDimension then
		-- Left/Bottom will be less than the corresponding UIParent coordinate if offscreen.
		return (uiParentLesserDimension - lesserDimension) / frameScale

	elseif greaterDimension and greaterDimension > uiParentGreaterDimension then
		-- Right/Top will be greater than the corresponding UIParent coordinate if offscreen.
		return (uiParentGreaterDimension - greaterDimension) / frameScale
	end

	return 0
end



--- StaticPopupDialogs substitute for the `enterClicksFirstButton` property since
--- that doesn't exist in Vanilla. Assign this to the `EditBoxOnEnterPressed` property.
function Util.StaticPopupDialogs_EnterClicksFirstButton()
	_G.StaticPopup_OnClick(_G.this:GetParent(), 1)
end



--- Dialogs with a text box should clear their text when hidden because some built-in
--- ones (like `DELETE_GOOD_ITEM`) don't do it OnShow.
function Util.StaticPopupDialogs_ClearTextOnHide()
	_G[_G.this:GetName().."EditBox"]:SetText("")
end


--#endregion WoW UI



--#region Import/Export


--- Prepare a table for export by serializing, compressing, and encoding.
---@param tbl table Object to export.
---@param humanReadable boolean? `true` to only pretty-print and NOT compress/encode.
---@return string?
function Util.Export(tbl, humanReadable)
	local export = Util.Serialize(tbl)
	if not humanReadable then
		export = Util.Encode(Util.Compress(export))
	end
	return export
end



--- Import a table previously prepared by `Util.Export()`.
---@param str string
---@return table?
function Util.Import(str)
	local import = Util.Trim(str)
	if not string.find(import, "^{") then
		import = Util.Trim(Util.Decompress(Util.Decode(import)) or "")
	end
	if not string.find(import, "^{") then
		return nil
	end
	return Util.Deserialize(import)
end



--- Serialize a table to a string.
--- Credit: pfUi serialize() by Shagu - https://github.com/shagu/pfUI/blob/master/modules/share.lua
---@param tbl table Object to serialize.
---@param comp table? Anything in this table that is the same as `tbl` will be excluded.
---@param key string? Key name.
---@param spacing string? Indentation.
---@return string?
function Util.Serialize(tbl, comp, key, spacing)
	if type(tbl) ~= "table" then
		return tostring(tbl)
	end

	spacing = spacing or ""
	local match = nil
	local str = (spacing ~= "" and key) and (spacing .. "[" .. Util.ToPrintableString(key) .. "] = {\n") or "{\n"

	for k, v in pairs(tbl) do
		if not comp or not comp[k] or comp[k] ~= tbl[k] then
			if type(v) == "table" then
				local result = Util.Serialize(tbl[k], comp and comp[k], k, spacing .. "  ")
				if result then
					match = true
					str = str .. result
				end
			elseif type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
				match = true
				str = str .. spacing .. "  [" .. Util.ToPrintableString(k) .. "] = " .. Util.ToPrintableString(v) .. ",\n"
			end
		end
	end

	str = str .. spacing .. "}" .. (spacing == "" and "" or ",") .. BS_NEWLINE
	return match and str or nil
end




--- Transform the given value into a string that can be printed or used in serialization.
--- Strings will be surrounded by double quotes (and double quotes within the string escaped)
---@param v any
---@param noStringEscapes boolean? Don't escape quotes and backslashes in strings.
---@return string
function Util.ToPrintableString(v, noStringEscapes)
	if type(v) == "string" or type(v) == "userdata" then
		if noStringEscapes then
			return "\"" .. v .. "\""
		else
			return "\"" .. string.gsub(string.gsub(v, "\\", "\\\\"), "\"", "\\\"") .. "\""
		end
	end
	return tostring(v)
end



--- Turn a previously-serialized table in string form back into a table.
---@param str string? Serialized table.
---@return table?
function Util.Deserialize(str)
	if type(str) ~= "string" or string.len(str) < 1 then
		return nil
	end
	local deserialize = assert(loadstring("return " .. str))
	if type(deserialize) == "function" then
		-- Add some sort of protection against code injection.
		setfenv(deserialize, {})
		return deserialize()
	end
end



--- LZW-compress a string.
--- Credit: pfUi compress() by Shagu - https://github.com/shagu/pfUI/blob/master/modules/share.lua
---@param input any
---@return nil
function Util.Compress(input)
	-- based on Rochet2's lzw compression
	if type(input) ~= "string" then
		return nil
	end
	local len = string.len(input)
	if len <= 1 then
		return "u" .. input
	end

	local dict = {}
	for i = 0, 255 do
		local ic, iic = string.char(i), string.char(i, 0)
		dict[ic] = iic
	end
	local a, b = 0, 1

	local result = { "c" }
	local resultLen = 1
	local n = 2
	local word = ""
	for i = 1, len do
		local c = string.sub(input, i, i)
		local wc = word .. c
		if not dict[wc] then
			local write = dict[word]
			if not write then
				return nil
			end
			result[n] = write
			resultLen = resultLen + string.len(write)
			n = n + 1
			if len <= resultLen then
				return "u" .. input
			end
			local str = wc
			if a >= 256 then
				a, b = 0, b + 1
				if b >= 256 then
					dict = {}
					b = 1
				end
			end
			dict[str] = string.char(a, b)
			a = a + 1
			word = c
		else
			word = wc
		end
	end
	result[n] = dict[word]
	resultLen = resultLen + string.len(result[n])
	n = n + 1
	if len <= resultLen then
		return "u" .. input
	end
	return table.concat(result)
end



--- Decompress a previously LZW-compressed string.
--- Credit: pfUi decompress() by Shagu - https://github.com/shagu/pfUI/blob/master/modules/share.lua
---@param input any
---@return nil
function Util.Decompress(input)
	-- based on Rochet2's lzw compression
	if type(input) ~= "string" or string.len(input) < 1 then
		return nil
	end

	local control = string.sub(input, 1, 1)
	if control == "u" then
		return string.sub(input, 2)
	elseif control ~= "c" then
		return nil
	end
	input = string.sub(input, 2)
	local len = string.len(input)

	if len < 2 then
		return nil
	end

	local dict = {}
	for i = 0, 255 do
		local ic, iic = string.char(i), string.char(i, 0)
		dict[iic] = ic
	end

	local a, b = 0, 1

	local result = {}
	local n = 1
	local last = string.sub(input, 1, 2)
	result[n] = dict[last]
	n = n + 1
	for i = 3, len, 2 do
		local code = string.sub(input, i, i + 1)
		local lastStr = dict[last]
		if not lastStr then
			return nil
		end
		local toAdd = dict[code]
		if toAdd then
			result[n] = toAdd
			n = n + 1
			local str = lastStr .. string.sub(toAdd, 1, 1)
			if a >= 256 then
				a, b = 0, b + 1
				if b >= 256 then
					dict = {}
					b = 1
				end
			end
			dict[string.char(a, b)] = str
			a = a + 1
		else
			local str = lastStr .. string.sub(lastStr, 1, 1)
			result[n] = str
			n = n + 1
			if a >= 256 then
				a, b = 0, b + 1
				if b >= 256 then
					dict = {}
					b = 1
				end
			end
			dict[string.char(a, b)] = str
			a = a + 1
		end
		last = code
	end
	return table.concat(result)
end



--- Base64-encode a string.
--- Credit: pfUi enc() by Shagu - https://github.com/shagu/pfUI/blob/master/modules/share.lua
---@param to_encode string?
---@return string
function Util.Encode(to_encode)
	if type(to_encode) ~= "string" or string.len(to_encode) < 1 then
		return ""
	end

	local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local bit_pattern = ''
	local encoded = ''
	local trailing = ''

	for i = 1, string.len(to_encode) do
		local remaining = tonumber(string.byte(string.sub(to_encode, i, i)))
		local bin_bits = ''
		for j = 7, 0, -1 do
			local current_power = math.pow(2, j)
			if remaining >= current_power then
				bin_bits = bin_bits .. '1'
				remaining = remaining - current_power
			else
				bin_bits = bin_bits .. '0'
			end
		end
		bit_pattern = bit_pattern .. bin_bits
	end

	if mod(string.len(bit_pattern), 3) == 2 then
		trailing = '=='
		bit_pattern = bit_pattern .. '0000000000000000'
	elseif mod(string.len(bit_pattern), 3) == 1 then
		trailing = '='
		bit_pattern = bit_pattern .. '00000000'
	end

	local count = 0
	for i = 1, string.len(bit_pattern), 6 do
		local byte = string.sub(bit_pattern, i, i + 5)
		local offset = tonumber(tonumber(byte, 2))
		encoded = encoded .. string.sub(index_table, offset + 1, offset + 1)
		count = count + 1
		if count >= 92 then
			encoded = encoded .. BS_NEWLINE
			count = 0
		end
	end

	return string.sub(encoded, 1, -1 - string.len(trailing)) .. trailing
end



--- Decode a Base64-encoded string.
--- Credit: pfUi dec() by Shagu - https://github.com/shagu/pfUI/blob/master/modules/share.lua
---@param to_decode any
---@return string?
function Util.Decode(to_decode)
	if type(to_decode) ~= "string" or string.len(to_decode) < 1 then
		return ""
	end

	local index_table = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	local padded = string.gsub(to_decode, "%s", "")
	local unpadded = string.gsub(padded, "=", "")
	local bit_pattern = ''
	local decoded = ''

	to_decode = string.gsub(to_decode, BS_NEWLINE, "")
	to_decode = string.gsub(to_decode, " ", "")

	for i = 1, string.len(unpadded) do
		local char = string.sub(to_decode, i, i)
		local offset, _ = string.find(index_table, char)
		if offset == nil then return nil end

		local remaining = tonumber(offset - 1)
		local bin_bits = ''
		for i = 7, 0, -1 do
			local current_power = math.pow(2, i)
			if remaining >= current_power then
				bin_bits = bin_bits .. '1'
				remaining = remaining - current_power
			else
				bin_bits = bin_bits .. '0'
			end
		end

		bit_pattern = bit_pattern .. string.sub(bin_bits, 3)
	end

	for i = 1, string.len(bit_pattern), 8 do
		local byte = string.sub(bit_pattern, i, i + 7)
		decoded = decoded .. string.char(tonumber(byte, 2))
	end

	local padding_length = string.len(padded) - string.len(unpadded)

	if (padding_length == 1 or padding_length == 2) then
		decoded = string.sub(decoded, 1, -2)
	end

	return decoded
end


--#endregion Import/Export



--#region Misc


--- Compare two objects.
--- Based on: https://gist.github.com/sapphyrus/fd9aeb871e3ce966cc4b0b969f62f539?permalink_comment_id=4563041#gistcomment-4563041
---@param obj1 any
---@param obj2 any
---@param ignoreKeys table<string, true>? Table keys listed here (expressed in level1.level2.level3 notation) will not affect the outcome of the comparison.
---@param keyPath string? Recursion parameter for keeping track of the key path.
---@return boolean equal
function Util.ObjectsEqual(obj1, obj2, ignoreKeys, keyPath)
	keyPath = keyPath or ""

	-- Same object.
	if obj1 == obj2 then
		return true
	end

	-- Different type.
	if type(obj1) ~= type(obj2) then
		return false
	end

	-- Same type but not table: we already know they're different
	-- because of the very first test.
	if type(obj1) ~= "table" then
		return false
	end

	-- Build table key path separated by dots.
	local keyPrefix = string.len(keyPath) > 0 and (keyPath .. ".") or ""

	-- Iterate over obj1 and make sure every value is found in obj2.
	for key1, value1 in pairs(obj1) do
		local value2 = obj2[key1]
		if
			not (ignoreKeys and ignoreKeys[keyPrefix .. key1])
			and (
				value2 == nil
				or Util.ObjectsEqual(
					value1,
					value2,
					ignoreKeys,
					keyPrefix .. key1
				) == false
			)
		then
			return false
		end
	end

	--- Check for keys that exist in obj2 but not obj1.
	for key2, _ in pairs(obj2) do
		if
			not (ignoreKeys and ignoreKeys[keyPrefix .. key2])
			and obj1[key2] == nil 
		then
			return false
		end
	end

	-- All table values are equal.
	return true
end



--- Use built-in formatting strings to nicely display remaining time expressed
--- in the largest unit `timeRemaining` contains.
---@param timeRemaining number Time in seconds.
---@return string
function Util.FormatTimeRemainingString(timeRemaining)
	-- 60 secs in a minute.
	-- 3600 secs in an hour.
	-- 86400 secs in a day.
	local days, hours, minutes, seconds
	days = math.floor(timeRemaining / 86400)
	timeRemaining = timeRemaining - 86400 * days
	hours = math.floor(timeRemaining / 3600)
	timeRemaining = timeRemaining - 3600 * hours
	minutes = math.floor(timeRemaining / 60)
	seconds = math.floor(timeRemaining - 60 * minutes)
	if days > 0 then
		return string.format(_G.INT_SPELL_DURATION_DAYS, days+1)
	elseif hours > 0 then
		return string.format(_G.INT_SPELL_DURATION_HOURS_P1, hours+1)
	elseif minutes > 0 then
		return string.format(_G.INT_SPELL_DURATION_MIN, minutes+1)
	else
		return string.format(_G.INT_SPELL_DURATION_SEC, seconds)
	end
end



--- Transform a money amount into a nicely formatted string.
--- Credit: `pfUI.api.CreateGoldString()` from [pfUI](https://github.com/shagu/pfUI/) (api.lua) by Shagu.
---@param money number Amount of money in copper (i.e. `GetMoney()` result).
---@return string # Colorized gold, silver, copper string (XgYsZc).
function Util.FormatMoneyString(money)
	if type(money) ~= "number" then
		return "-"
	end

	local gold = math.floor(money/ 100 / 100)
	local silver = math.floor(mod((money/100), 100))
	local copper = math.floor(mod(money, 100))

	local string = ""
	if gold > 0 then
		string = string .. "|cffffffff" .. gold .. "|cffffd700g"
	end
	if silver > 0 or gold > 0 then
			string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs"
	end
	string = string .. "|cffffffff " .. copper .. "|cffeda55fc" .. FONT_COLOR_CODE_CLOSE

	return string
end



--- Always returns `true`.
--- Used to temporarily override IsAltKeyDown/IsControlKeyDown/IsShiftKeyDown.
---@return boolean # false
function Util.ReturnFalse()
	return false
end



--- Always returns `false`.
--- Used to temporarily override IsAltKeyDown/IsControlKeyDown/IsShiftKeyDown.
---@return boolean # true
function Util.ReturnTrue()
	return true
end


--#endregion Misc


end)