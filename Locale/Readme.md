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
5. Translate the strings on the **RIGHT** sides of the equals signs (*do not* edit anything on the left), taking into account the guidance below. You can test changes by reloading the UI.

## Guidance

### 🟢 Matching in-game text
It's critical that some localized strings aren't just translated, but that they ***exactly*** match what the game provides:
* Everything in the `### Game Stuff ###` section at the top of the locale file.
* `NameIdentifier_.*`
* `TooltipIdentifier_.*`
* `TooltipParse_.*`

If these are inaccurate, some rules and other functionality won't work properly.

### 🟥 `%s`, `%d`
Any time you see `%s`, `%d`, or any other Lua formatting placeholder or pattern class, it must continue to exist ***unaltered*** at the appropriate location in the translated version of the string.

### 🟥 `!!DoubleExclamationMarks!!`

Anything surrounded by `!!DoubleExclamationMarks!!` is a placeholder reference to a localization string that will be replaced when the localization is loaded. It must ***not*** be changed.

### 🟥 Variables and concatenation

Some strings are concatenated, for example:
```lua
"Show the hearthstone button." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "Applies to Bags only" .. FONT_COLOR_CODE_CLOSE,
```
Only the string parts (inside "quotation marks") should be translated. The `LOUD_SNAKE_CASE` words are variables that must ***not*** be changed

### 🔶 `_G.<ANYTHING>`

When `_G.<ANYTHING>` is on the right side, this is referencing a built-in global string that *probably* should not require manual translation.

### ℹ️ Ignore comments

There's no need to translate the comments at the end of some lines (the part outside the final `"` that is demarcated by `--`).

```lua
["String"] = "Translation",  -- This is a comment
```