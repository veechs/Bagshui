# Bagshui Changelog

## [1.4.3] - 2025-03-01
### Fixed
* Clicking a bag slot with Outfitter installed will no longer [error](https://github.com/veechs/Bagshui/issues/101) (this was somehow an issue since 1.0‽). <sup>🪲 bonho</sup>
* Prevent [errors](https://github.com/veechs/Bagshui/issues/102) while processing items with very long tooltips. <sup>🪲 bonho</sup>

## [1.4.2] - 2025-02-22
### Fixed
* Hearthstone toolbar button won't throw errors anymore.

## [1.4.1] - 2025-02-22
### Fixed
* Small improvement to item slot button proxying to avoid errors from Blizzard code.

## [1.4.0] - 2025-02-22
### Changed
* Added [window strata option](https://github.com/veechs/Bagshui/issues/91). Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **Advanced** > **Window** • **Strata**. <sup><small>🫶 [@Nikki1993](https://github.com/Nikki1993)</small></sup>

### Fixed
* Yet another rework of how Bagshui's item slot buttons interact with Blizzard code. Hopefully third time's the charm! This also fixes [partial stack selling](https://github.com/veechs/Bagshui/issues/93).
  * If you're interested in what's going on with this, [here's some exciting reading](https://github.com/veechs/Bagshui/pull/95).

## [1.3.0] - 2025-02-17
### Changed
* Accuracy of unusable item tinting has been vastly improved (things like fist weapons that gave it fits before now work correctly).<br><sup><small>Thanks to [@Sunelegy](https://github.com/Sunelegy) for bringing the problems to my attention and [@shagu](https://github.com/shagu) for the pfUI code pointing me to the right solution.</small></sup>

### Fixed
* Significant zh-CN localization refinements by [@Sunelegy](https://github.com/Sunelegy).
* No more errors in FrameXML.log. <sup><small>🪲 [@RetroCro](https://github.com/RetroCro)</small></sup>

## [1.2.29] - 2025-02-16
### Fixed
* Another rule function menu fix. Hopefully the last one.

## [1.2.28] - 2025-02-16
### Fixed
* The rule function menu in the Category editor has been broken since 1.1. Big oops.

## [1.2.27] - 2025-02-15
### Changed
* Add [Gemstone of Ysera](https://github.com/veechs/Bagshui/issues/84) to default Keys Category. <sup>🗃️ [@Mats391](https://github.com/Mats391)</sup>

## [1.2.26] - 2025-02-13
### Fixed
* Avoid [errors](https://github.com/veechs/Bagshui/issues/73) when making bulk purchases at merchants. <sup>🪲 Roido</sup>

## [1.2.25] - 2025-02-12
### Changed
* Added zh-CN localization. Many thanks to [@Sunelegy](https://github.com/Sunelegy)!

## [1.2.24] - 2025-02-10
### Fixed
* Multiple objects (Categories, Sort Orders, etc.) created simultaneously will no longer run the risk of overwriting each other.

## [1.2.23] - 2025-02-09
### Fixed
* Unequipping a bag now [correctly unlocks slot highlighting](https://github.com/veechs/Bagshui/issues/70). <sup>🪲 [@Nikki1993](https://github.com/Nikki1993)</sup>

## [1.2.22] - 2025-02-05
### Fixed
* [Don't reset window position while drag is in progress](https://github.com/veechs/Bagshui/issues/69). <sup>🪲 [@Nikki1993](https://github.com/Nikki1993)</sup>

## [1.2.21] - 2025-02-04
### Changed
* Added `Lock` and `Unlock` parameters to `/Bagshui Bags/Bank`.

### Fixed
* Significant improvements to Settings menu positioning to keep it onscreen at all times. <sup>🪲 leiaravdenheilagekyrkja</sup>
* Resetting the window position via `/Bagshui Bags/Bank ResetPosition` now works correctly regardless of window anchoring. <sup>🪲 leiaravdenheilagekyrkja</sup>

## [1.2.20] - 2025-01-25
### Fixed
* Ensure [stack splitting targets the correct item](https://github.com/veechs/Bagshui/issues/63) (and don't break everything like 1.2.17 did).

## [1.2.19] - 2025-01-25
### Fixed
* Temporarily revert change from 1.2.17 because it seems to be [breaking some things](https://github.com/veechs/Bagshui/issues/65).

## [1.2.18] - 2025-01-25
### Fixed
* Outfitter integration now [ignores enchant codes](https://github.com/veechs/Bagshui/issues/62) since those don't always seem to be updated on the Outfitter side. <sup>🪲 bonho</sup>

## [1.2.17] - 2025-01-25
### Fixed (but not really, since it caused all kinds of issues)
* Ensure [stack splitting targets the correct item](https://github.com/veechs/Bagshui/issues/63). <sup>🪲 bonho</sup>

## [1.2.16] - 2025-01-21
### Fixed
* [Offline tooltips in Bags](https://github.com/veechs/Bagshui/issues/60) work, which were broken since 1.2.4. <sup>🪲 [@Kirius88](https://github.com/Kirius88)</sup>

## [1.2.15] - 2025-01-19
### Fixed
* Improve [accuracy of unusable item coloring](https://github.com/veechs/Bagshui/issues/58). <sup>🪲 bonho</sup>

## [1.2.14] - 2025-01-19
### Fixed
* Prevent errors when opening menus. <sup>🪲 Miwi</sup>

## [1.2.13] - 2025-01-18
### Changed
* Item stock change badges (new/increased/decreased) [will not disappear immediately when the item is clicked](https://github.com/veechs/Bagshui/issues/57) by default.  
ℹ️ If you prefer the old behavior, it's available by enabling **Clear on Click** under **Settings** > **More** > **Stock Change Timers**.

## [1.2.12] - 2025-01-18
### Fixed
* Locked items now [dim like they should](https://github.com/veechs/Bagshui/issues/56).

## [1.2.11] - 2025-01-18
### Fixed
* Edit Mode [Direct Assignment](https://github.com/veechs/Bagshui/wiki/Edit-Mode#managing-direct-assignment) didn't work correctly with Class Categories. [Now it does](https://github.com/veechs/Bagshui/issues/55).

## [1.2.10] - 2025-01-17
### Fixed
* Better error handling [when a quest link is clicked in chat and pfQuest isn't installed](https://github.com/veechs/Bagshui/issues/52). <sup>🪲 [@doctorwizz](https://github.com/doctorwizz)</sup>
* Really truly [prevent built-in Categories from being edited](https://github.com/veechs/Bagshui/issues/35). <sup>🪲 bonho</sup>

## [1.2.9] - 2025-01-16
### Changed
* [Add Tokens to default Profiles](https://github.com/veechs/Bagshui/issues/42) to capture most pseudo-currency items like reputation and battleground turn-ins. <sup>🫶 [@KameleonUK](https://github.com/KameleonUK)</sup><br>***Please note:***
  * If the Profiles you're using are still pretty close to the default, you should get Tokens added automatically.
  * If you don't receive a Tokens Group and want one, [it's pretty easy](https://github.com/veechs/Bagshui/wiki/Walkthroughs#creating-a-group) to create a Group and assign the Tokens Category.
### Fixed
* Fix [Bank bag slot highlighting](https://github.com/veechs/Bagshui/issues/50) and a [possible tooltip error](https://github.com/veechs/Bagshui/issues/51). <sup>🪲 [@Nikki1993](https://github.com/Nikki1993)</sup>
* Fix Edit Mode Group tooltips potentially not displaying all Categories.

## [1.2.8] - 2025-01-15
### Fixed
* [Improved offscreen window detection](https://github.com/veechs/Bagshui/issues/49). <sup>🪲 [@doctorwizz](https://github.com/doctorwizz)</sup>

## [1.2.7] - 2025-01-15
### Fixed
* Stop item charge counts from [disappearing](https://github.com/veechs/Bagshui/issues/36).

## [1.2.6] - 2025-01-15
### Fixed
* 🚨 Important bug fix to avoid [the wrong quest being abandoned](https://github.com/veechs/Bagshui/issues/48). <sup>🪲 [@Nikki1993](https://github.com/Nikki1993)</sup>
* Item categorization updates for [Bright Dream Shard](https://github.com/veechs/Bagshui/issues/44) and [Arena Mark of Honor](https://github.com/veechs/Bagshui/issues/41). <sup>🪲 bonho and [@KameleonUK](https://github.com/KameleonUK)</sup>

## [1.2.5] - 2025-01-11
### Changed
*The [Info Tooltip Taming](https://github.com/veechs/Bagshui/milestone/2?closed=1) Update*
* [Bagshui Info Tooltips](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) should behave much better with fewer edge cases and improved compatibility. <sup>🫶 [@Distrattos](https://github.com/Distrattos), [@doctorwizz](https://github.com/doctorwizz), and [@thecreth](https://github.com/thecreth)</sup>
* It will appear above the item tooltip for auction listings to avoid obscuring the row.
* Listings in [aux](https://github.com/shirsig/aux-addon-vanilla) will now get Info Tooltips too.<br><sup>This was a *whole thing* because aux likes to do things its own special way.</sup>

## [1.2.4] - 2025-01-11
### Fixed
* [Improve compatibility with tooltip addons](https://github.com/veechs/Bagshui/issues/11), including CompareStats and anything GFW_. <sup>🪲 bonho and [@thecreth](https://github.com/thecreth)</sup>

## [1.2.3] - 2025-01-09
### Fixed
* Catalog won't [annoyingly clear your search text when it shouldn't](https://github.com/veechs/Bagshui/issues/24). <sup>🪲 [@tippfelher](https://github.com/tippfelher)</sup>
* [Turn off Highlight Changes when there's nothing left to highlight](https://github.com/veechs/Bagshui/issues/19). <sup>🪲 [@Distrattos](https://github.com/Distrattos)</sup><br><sup>There's some interplay between Bags and Keyring around this that still needs to be resolved but I don't think anyone uses Keyring enough to *really* care.</sup>
* Tweak Recipes category to include Top Half/Bottom Half Advanced Volumes (thanks Melo)
* Try to make it clear during Direct Assignment in Edit Mode that a [custom Category is required](https://github.com/veechs/Bagshui/wiki/FAQ#why-cant-i-edit-built-in-objects).

## [1.2.2]a - 2025-01-08
### Fixed
* [Windows that try to go for an adventure off the screen](https://github.com/veechs/Bagshui/issues/18) should now be brought back. `/bagshui Bags ResetPosition` (or `Bank`) has also been made available in case manual intervention is required.

## [1.2.1] - 2025-01-06
### Fixed
* Fix [Direct Assignment bug](https://github.com/veechs/Bagshui/issues/17) that was causing a lot of confusion. Sorry everyone, and thanks to Kord2998, Secrett, and [@saintsareprey](https://github.com/saintsareprey) for bringing this to my attention.

## [1.2.0] - 2025-01-05
### Changed
* [Add setting](https://github.com/veechs/Bagshui/issues/14) to prevent automatic reorganization when the Inventory window is closed and reopened. <sup>🫶 Serbz and Caveira</sup>
  * Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **Advanced** > **Behaviors** > **Manual Reorganization**.
* [Add setting](https://github.com/veechs/Bagshui/issues/12) to display [Bagshui Info Tooltip](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) without holding Alt. <sup>🫶 [@doctorwizz](https://github.com/doctorwizz)</sup>
  * Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **More** > **Integration** > **Info Tooltip** > **Show Without Alt**.

## [1.1.1] - 2025-01-04
### Fixed
* [Remove "long cooldown" workaround](https://github.com/veechs/Bagshui/issues/10) (special thanks to [shagu](https://github.com/shagu)).

## [1.1.0] - 2025-01-04
### Changed
* Add `Transmog()` [rule function](https://github.com/veechs/Bagshui/wiki/Rules) stub to support Turtle transmog collection data via [Bagshui-Tmog](https://github.com/veechs/Bagshui-Tmog). <sup>🫶 Tyrchast</sup>
* Internal rework of rule function management.
* Refactor [3rd party API](https://github.com/veechs/Bagshui/wiki/Developers:-API).

## [1.0.8] - 2025-01-02
### Fixed
* Fix [Profile Replace error](https://github.com/veechs/Bagshui/issues/9).

## [1.0.7] - 2025-01-01
### Fixed
* Fixes to [3rd party `Bagshui:AddRuleFunction()` API](https://github.com/veechs/Bagshui/wiki/Developers:-API) (i.e. it'll actually work now).

## [1.0.6] - 2025-01-01
### Fixed
* Fix [Active Quest Item error](https://github.com/veechs/Bagshui/issues/6). <sup>💕 [absir](https://github.com/absir)</sup>

## [1.0.5] - 2024-12-31
### Fixed
* Fix [tDF MinimapButtonBag tweaks](https://github.com/veechs/Bagshui/issues/5). <sup>🪲 Amon_RA</sup>

## [1.0.4] - 2024-12-31
### Changed
* [Window scale setting added](https://github.com/veechs/Bagshui/issues/4). <sup>🫶 [mmrosh](https://github.com/mrrosh)</sup>
* Adjust default categories (thanks [melba](https://github.com/melbaa)):
  * Add Turtle WoW items to Teleport and decrease sequence number to run before Soulbound.
  * Add missing Anti-Venoms to First Aid (formerly Bandages).

## [1.0.3] - 2024-12-30
### Changed
* Open All Bags key binding will now [toggle Bags to match default Blizzard behavior](https://github.com/veechs/Bagshui/issues/3).

## [1.0.2] - 2024-12-30
### Fixed
* Prevent [nil colorStr error](https://github.com/veechs/Bagshui/issues/2). <sup>🪲 Gondoleon</sup>

## [1.0.1] - 2024-12-30
### Fixed
* Improve efficiency of [searching via rules](https://github.com/veechs/Bagshui/wiki/Searching#advanced-searches).

## [1.0.0] - 2024-12-30
* Initial release.