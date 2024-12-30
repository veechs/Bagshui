-- Bagshui Localization
-- Exposes:
-- - BSLocalization (and Bagshui.components.Localization)
-- - L[] and L_nil[]
-- Raises: BAGSHUI_LOCALIZATION_LOADED
-- 
-- Localization is performed in the Bagshui environment as via the L table, and
-- can be referenced as L.StringKey or L["StringKey"].
-- There is also the L_nil variant, which returns nil on a localization failure
-- instead of returning the original string.

-- Loading the Localization class happens in 2 phases:
-- 1. The LoadComponent() portion immediately injects the localization class into
--    the Bagshui namespace so that AddLocale() becomes available.
-- 2. Once everything is up and running, AddComponent() is processed and the localization is loaded.


-- Need to declare the class here so it's available to both LoadComponent() and AddComponent().
local Localization = {
	-- Proxy tables that handle localization calls -- see localizationMetatable below for details.
	localize = {},
	localizeNilOnMiss = {},  -- Used to trigger a nil return on a localization miss instead of returning the original string.

	-- Track the name of the active locale.
	activeLocaleId = nil,

	-- Localization tables.
	activeLocale = {},
	fallbackLocale = {},

	-- List of available locales in the form of `{ <locale> = { <localization table> } }`.
	locales = {},
}
Bagshui.environment.BsLocalization = Localization
Bagshui.components.Localization = Localization
Bagshui.environment.L = Localization.localize
Bagshui.environment.L_nil = Localization.localizeNilOnMiss


-- Phase 1: Set up the Localization class.
Bagshui:LoadComponent(function()


-- Metatable that handles localization magic.
--
-- The `localize`/`localizeNilOnMiss` tables are always empty, so any access will trigger
-- the `__index()` method. We can then intercept it and provide the correct localization.
--
-- Similarly, by providing `__newindex()`, we can redirect any changes into the correct
-- activeLocale table.
local localizationMetatable = {

	__index = function(localeTable, str)
		-- Localization debugging should be enabled when Bagshui debugging is on,
		-- but will short-circuit and not evaluate otherwise.
		if
			BS_DEBUG
			and (
				localeTable ~= Localization.localizeNilOnMiss
				and not (Localization.activeLocale[tostring(str)]
				or Localization.activeLocale[string.lower(tostring(str))])
			)
		then
			Bagshui:PrintDebug("!MISS!: " .. tostring(str), "Localization", 1, 0, 0)
		end

		return
			-- Active locale match.
			(Localization.activeLocale[tostring(str)] or Localization.activeLocale[string.lower(tostring(str))])
			-- Default locale match.
			or (Localization.fallbackLocale[tostring(str)] or Localization.fallbackLocale[string.lower(tostring(str))])
			-- No match -- return nil if requested or the original string.
			or (
				localeTable ~= Localization.localizeNilOnMiss
				and str
				or nil
			)
	end,

	-- Set a value in the active localization.
	__newindex = function(_, str, localized)
		if not Localization.activeLocaleId then
			return
		end
		Localization.activeLocale[str] = localized
	end
}

-- Assign metatable to both of the proxy tables.
setmetatable(Localization.localize, localizationMetatable)
setmetatable(Localization.localizeNilOnMiss, localizationMetatable)



--- Set the locale and do other localization preparations.
function Localization:Init()

	-- Choose the correct locale -- try the current locale first, then fall back to the default if needed.
	local locale = _G.GetLocale()
	if locale and self.locales[locale] then
		Localization.activeLocaleId = locale
	else
		Bagshui:PrintWarning("No localization available for " .. locale .. "; falling back to " .. BS_DEFAULT_LOCALE)
		Localization.activeLocaleId = BS_DEFAULT_LOCALE
	end
	self.activeLocale = self.locales[Localization.activeLocaleId]

	-- Add a the default localization as a fallback.
	if Localization.activeLocaleId ~= BS_DEFAULT_LOCALE then
		self.fallbackLocale = self.locales[BS_DEFAULT_LOCALE]
	end

	-- Localize key bindings in Blizzard UI.
	for i = 1, _G.GetNumBindings() do
		local localized
		local bindingName = (_G.GetBinding(i))

		-- First check to see if there is a localizable prefix.
		local found, _, prefix, toLocalize = string.find((_G.GetBinding(i)), "Bagshui_(.-)_(.+)")
		if found and L_nil["Prefix_" .. prefix] then
			localized = string.format(L["Prefix_" .. prefix], (L_nil["Binding_" .. toLocalize] or L[toLocalize]))
		else
			-- No prefix found, so we need to localize the whole thing.
			found, _, toLocalize = string.find((_G.GetBinding(i)), "Bagshui_(.+)")
			if found then
				-- Try to localize with a Binding_ prefix to allow for binding-only naming (Binding_Resort, Binding_Restack)
				-- and fall back to just the name (Bags, Bank, etc.).
				localized = (L_nil["Binding_" .. toLocalize] or L[toLocalize])
			end
		end
		if localized then
			_G["BINDING_NAME_" .. bindingName] = localized
		elseif found then
			Bagshui:PrintWarning("Failed to localize key binding " .. bindingName)
		end
	end


	-- Build automatic localization as much as possible (it's not all that much in Vanilla).

	-- Item classes.
	for enUS, localized in pairs(BsGameInfo.itemClasses) do
		if localized and not self.activeLocale[enUS] then
			self.activeLocale[enUS] = localized
		end
	end

	-- Item subclasses.
	for _, subClassList in pairs(BsGameInfo.itemSubclasses) do
		for enUS, localized in pairs(subClassList) do
			if localized and not self.activeLocale[enUS] then
				self.activeLocale[enUS] = localized
			end
		end
	end

	-- Inventory slots.
	for enUS, localized in pairs(BsGameInfo.inventorySlots) do
		if localized and not self.activeLocale[enUS] then
			self.activeLocale[enUS] = localized
		end
	end

	-- System chat messages.
	-- Needed for CHAT_MSG_SYSTEM events in `Inventory:OnEvent()`.
	self.activeLocale.ChatMsgIdentifier_LearnedRecipe =
		self.activeLocale.ChatMsgIdentifier_LearnedRecipe
		or string.format(_G.ERR_LEARN_RECIPE_S, ".+")

	-- Add lowercase versions.
	-- A temp table is required here because pairs() gets confused if the table
	-- being iterated is modified during iteration.
	local temp = BsUtil.TableCopy(self.activeLocale)
	for enUS, localized in pairs(temp) do
		local lowercase = string.lower(enUS)
		if not self.activeLocale[lowercase] then
			self.activeLocale[lowercase] = localized
		end
	end

	-- Populate a few useful combinations.
	L.UnnamedGroup = string.format(L.Prefix_Unnamed, L.Group)

	-- Initialization complete.
	Bagshui:RaiseEvent("BAGSHUI_LOCALIZATION_LOADED")
end



--- Add a new localization table.
---@param locale string [Locale identifier](https://warcraft.wiki.gg/index.php?title=API_GetLocale&oldid=4228097)
---@param strings table<string,string> List of `{ ["BagshuiLocalizationString"] = "localized string" }`.
function Localization:AddLocale(locale, strings)
	if self.locales[locale] then
		-- When a primary localization has already been loaded, additional strings
		-- can still be added by calling a second time. This won't override any
		-- of the existing strings though.
		for localizationString, localized in pairs(strings) do
			if not self.locales[locale][localizationString] then
				self.locales[locale][localizationString] = localized
			end
		end
	else
		self.locales[locale] = strings
	end


	-- for localizationString, localized in pairs(strings) do
	-- 	if type(localized) == "table" then
	-- 		Bagshui:PrintWarning("Localization of '" .. localizationString .. "' is a table. Maybe a global string got overwritten?")
	-- 	end
	-- end

	-- Replace any !!placeholders!! with their actual localized values.
	for localizationString, localized in pairs(self.locales[locale]) do
		self.locales[locale][localizationString] = string.gsub(
			localized,
			"(!!(.-)!!)",
			function(match, placeholderToReplace)
				if self.locales[locale][placeholderToReplace] then
					return self.locales[locale][placeholderToReplace]
				else
					Bagshui:PrintWarning("Localization placeholder " .. tostring(match) .. " not found!")
					return match
				end
			end
		)
	end
end


end) -- LoadComponent (Phase 1) complete.



-- Phase 2: Load localization and make localization functions available.
Bagshui:AddComponent(function()

Localization:Init()

end)