# How to Localize Bagshui
1. Find the name of the new locale by running this chat command in-game. This will be referred to as `{newLocale}` throughout this document and is *case-sensitive*.
   ```none
   /run DEFAULT_CHAT_FRAME:AddMessage(GetLocale())
   ```
   [A list of known locale identifiers](https://warcraft.wiki.gg/index.php?title=API_GetLocale&oldid=4228097) is also available.
2. Make a copy of **enUS.lua**.
3. Name the new file `{newLocale}.lua`:
4. Change `enUS` on line 3 of the new file to `{newLocale}`.
6. Add a new entry to **Locales.xml**:
   ```xml
   <Include file="{newLocale}.lua" />
   ```
5. Translate everything on the **RIGHT** sides of the equals signs (*do not* edit anything on the left), taking into account the guidance below. You can test changes by reloading the UI.

## Guidance

* Any time you see `%s`, `%d`, or any other Lua pattern, it must continue to exist *unaltered* at the appropriate location in the translated version of the string.

* When `_G.<WORD>` is on the right side, this is referencing a built-in global string that *probably* should not require manual translation.

* Anything surrounded by `!!DoubleExclamationMarks!!` is a placeholder reference to a localization string that will be replaced when the localization is loaded. It must *not* be changed.

* Some strings are concatenated, for example:
  ```lua
  "Show the hearthstone button." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "Applies to Bags only" .. FONT_COLOR_CODE_CLOSE,
  ```
  Only the string parts (inside "quotation marks") should be translated. The `LOUD_SNAKE_CASE` words are variables that must *not* be changed.
