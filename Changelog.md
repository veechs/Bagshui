# Bagshui Changelog

## 1.5.15 - 2025-08-23
### Fixed
* *Actually* fix [empty slot backgrounds in non-enUS clients that don't have a Bagshui localization](https://github.com/veechs/Bagshui/issues/175) (was working in 1.5.13, but only due to the bug that was resolved in 1.5.14). <sup><small>🪲&nbsp;[@Trust-WoW](https://github.com/Trust-WoW)</small></sup>
* *Actually* move Turtle WoW's **Verdant Rune** [to the Teleports Category](https://github.com/veechs/Bagshui/issues/179). <sup><small>🗃️&nbsp;[@xeropresence](https://github.com/xeropresence)</small></sup>

## 1.5.14 - 2025-08-23
### Fixed
* Remove stray double negative in localization checks introduced by the #175 fix.

## 1.5.13 - 2025-08-23
### Fixed
* Empty slot backgrounds in non-enUS clients that don't have a Bagshui localization [shouldn't go on vacation anymore](https://github.com/veechs/Bagshui/issues/175). <sup><small>🪲&nbsp;[@Trust-WoW](https://github.com/Trust-WoW)</small></sup>
* Prevent [an error](https://github.com/veechs/Bagshui/issues/177) during the bank slot purchase flow. <sup><small>🪲&nbsp;[@Arcitec](https://github.com/Arcitec)</small></sup>
* Fix for [rare occurrence of missing toolbars](https://github.com/veechs/Bagshui/issues/172). <sup><small>🪲&nbsp;[@Sleepybear](https://github.com/Sleepybear)</small></sup>
* Turtle WoW's **Verdant Rune** is now [correctly placed in the Teleports Category](https://github.com/veechs/Bagshui/issues/179). <sup><small>🗃️&nbsp;[@xeropresence](https://github.com/xeropresence)</small></sup>

## 1.5.12 - 2025-08-20
### Fixed
* The new "Concoctions" in Turtle WoW 1.18 are now [correctly categorized with elixirs](https://github.com/veechs/Bagshui/issues/173). <sup><small>🗃️&nbsp;[@xeropresence](https://github.com/xeropresence) + [@Sunelegy](https://github.com/Sunelegy) for zhCN</small></sup>

## 1.5.11 - 2025-08-04
### Fixed
* [Sharing works consistently now](https://github.com/veechs/Bagshui/issues/160) (previously there were errors if all objects of a given type were selected). <sup><small>🪲&nbsp;[@Szalor](https://github.com/Szalor)</small></sup>

## 1.5.10 - 2025-04-26
### Fixed
* Prevent lag while in a raid group. Additional protections for in-combat performance are being tested, but this should resolve the worst of the [issues](https://github.com/veechs/Bagshui/issues/153). Thanks to jj for their patient testing that helped me locate the root cause.

## 1.5.9 - 2025-04-26
### Fixed
* Avoid localization errors. Whoops (x2).

## 1.5.7 - 2025-04-26
### Changes
* zhCN localization now includes everything added/changed in 1.5. Many thanks to [@Sunelegy](https://github.com/Sunelegy) for keeping up with this!

## 1.5.6 - 2025-04-26
### Fixed
* Matching item properties that contain Lua pattern characters (most notably `-` but could be any of `^$()%.[]*+-?`) [now works as it should](https://github.com/veechs/Bagshui/issues/149). <sup><small>🪲&nbsp;[@AsunaSalata](https://github.com/AsunaSalata)</small></sup>

## 1.5.5 - 2025-04-15
### Fixed
* Prevent [doubled cooldown text](https://github.com/veechs/Bagshui/issues/143) when ShaguPlates, ShaguTweaks, and pfQuest are enabled. Thanks to [@shagu](https://github.com/shagu) for identifying the cause and suggesting how to fix it. <sup><small>🪲&nbsp;[@Vymya](https://github.com/Vymya)</small></sup>
* Capture custom Turtle WoW recipes that are [wrongly categorized on the server side](https://github.com/veechs/Bagshui/issues/144). <sup><small>🗃️&nbsp;[@Szalor](https://github.com/Szalor)</small></sup>

## 1.5.4 - 2025-04-12
### Fixed
* Ensure Alt+click bag highlights [persist correctly](https://github.com/veechs/Bagshui/issues/141).

## 1.5.3 - 2025-04-12
### Fixed
* Prevent [items from getting stuck in locked (grayed-out) state](https://github.com/veechs/Bagshui/issues/138). <sup><small>🪲&nbsp;[@Szalor](https://github.com/Szalor)</small></sup>

## 1.5.2 - 2025-04-06
### Fixed
* Avoid [error from Manage Character Data window](https://github.com/veechs/Bagshui/issues/132) when a character has never logged out. <sup><small>🪲&nbsp;[@Szalor](https://github.com/Szalor)</small></sup>

## 1.5.1 - 2025-04-06
### Fixed
* Prevent [error when unequipping a tabard](https://github.com/veechs/Bagshui/issues/130). <sup><small>🪲&nbsp;bonho</small></sup>

## 1.5.0 - 2025-04-05
### Changes
* **Automated bag swapping**<br>One of the most-requested features! Just equip a new bag and Bagshui [takes care of the rest](https://github.com/veechs/Bagshui/wiki/FAQ#how-do-i-swap-bags-when-i-get-bigger-ones).<br><sup><small>Sufficient free space is required, but you can visit the Bank to supplement without cleaning your Bags.</small></sup><br><sup><small>🫶&nbsp;[@Nikki1993](https://github.com/Nikki1993), Kralomax, and everyone on the TW Discord who has asked</small></sup>
* **Shiny new toolbar buttons**<br>**Clam** (Open Container), **Disenchant**, and **Pick Lock**. <sup><small>🫶&nbsp;[@melbaa](https://github.com/melbaa), [@Azzc0](https://github.com/Azzc0)</small>
* **Selling protection for your valuables**<br>Ever accidentally right-clicked the wrong thing at a vendor? High quality, active quest, and soulbound items now require confirmation.<sup><small>🫶&nbsp;[@selax1](https://github.com/selax1)</small></sup><br><sup><small>Configurable in **Settings** > **General**. Can also include anything you've ever equipped.</small></sup>
* **More sensible gear slot sorting**<br>Equipment is now sorted by character sheet order (head first, fingers last) instead of slot name, which should be a little more intuitive. <sup><small>🫶&nbsp;Kord2998</small></sup>
* **Improved utilization display**<br>Even if you hide bag slots, you can now show free/used totals. <sup><small>🫶&nbsp;[@thecreth](https://github.com/thecreth)</small></sup><br><sup><small>Super customizable in **Settings** > **View** > **Utilization**.</small></sup>
* **Powerful new [rule functions](https://github.com/veechs/Bagshui/wiki/Rules#available-rule-functions)**<br>`MatchCategory()`, `RecentlyChanged()`, `Zone()`/`Subzone()`, `PlayerInGroup()`, and `LootMethod()`/`LootMaster()` allow more dynamic categorization than ever before. Plus `Openable()` for chests and lockboxes. <sup><small>🫶&nbsp;[@melbaa](https://github.com/melbaa)</small></sup>
* **But wait, there’s more…**
  * Synchronized searches between open inventory windows. <sup><small>🫶&nbsp;[@thecreth](https://github.com/thecreth)</small></sup>
  * The **Organize** toolbar button is smarter and should only light up if there's something to do.
  * New **Openable** default Category and Group.
  * Hidden Groups have an indicator in Edit Mode.
  * `/Bagshui Info <ItemId>` will open the Item Information window for an arbitrary item.
  * Empty slot graphics can be hidden and a custom background color set. <sup><small>🫶&nbsp;[@RetroCro](https://github.com/RetroCro)</small></sup>
  * Settings menu has been given a thorough polishing.

### Fixed
* Dropping a profession now correctly removes it from Bagshui's reagents and crafts tracking.
* Highlight Changes mode should be much more reliable.
* Equipping gear should now more consistently update the history.
* Key internal data is now validated to avoid errors (things you should hopefully never need to care about).

## 1.4.11 - 2025-03-29
### Fixed
* Mounts, companions, and toys should all be [correctly categorized now](https://github.com/veechs/Bagshui/issues/116) on both Turtle WoW and true Vanilla. Thanks as always to [@Sunelegy](https://github.com/Sunelegy) for zhCN guidance.<sup><small>🗃️ [@jilinge2](https://github.com/jilinge2)</small></sup>
* Attempt to protect against [rare errors during sorting](https://github.com/veechs/Bagshui/issues/127). <sup><small>🪲&nbsp;bonho</small></sup>

## 1.4.10 - 2025-03-28
### Fixed
* Locking a bag's highlight via Alt+Click now [temporarily unhides all items in that bag](https://github.com/veechs/Bagshui/issues/125). <sup><small>🪲&nbsp;[@RetroCro](https://github.com/RetroCro)</small></sup>

## 1.4.9 - 2025-03-27
### Changed
* zh-CN localization updates by [@Sunelegy](https://github.com/Sunelegy).

### Fixed
* ItemRack integration now also ignores enchant codes since, like Outfitter, it seems they aren't always updated. <sup><small>🪲&nbsp;Surtugal</small></sup>

## 1.4.8 - 2025-03-26
### Changed
* pfUI tooltip "Dodge"-mode lovers, rejoice! Bagshui now tells pfUI when to anchor the tooltip to its windows. Thanks to [@shagu](https://github.com/shagu) for [making this possible](https://github.com/shagu/pfUI/issues/1391). <sup><small>🫶&nbsp;Bahamutxd</small></sup>

## 1.4.7 - 2025-03-26
### Fixed
* The first time a character logged in, [using Edit Mode in Bags would not change the Structure for Bank and vice-versa](https://github.com/veechs/Bagshui/issues/121). <sup><small>🪲&nbsp;[@Szalor](https://github.com/Szalor)</small></sup>
* Renaming a group could throw an error under certain circumstances.
* Tooltips in Edit Mode for left-anchored inventory windows will no longer decide to be super wide.

## 1.4.6 - 2025-03-15
### Fixed
* Alt/Ctrl+click and right-click [compatibility](https://github.com/veechs/Bagshui/issues/118) with ["Old Interface" Aux](https://github.com/mrrosh/aux-addon_old-interface/). <sup><small>🪲&nbsp;[@StrayDemon-13](https://github.com/StrayDemon-13)</small></sup>

## 1.4.5 - 2025-03-04
### Fixed
* Picking up the Hearthstone by dragging the toolbar button [works again](https://github.com/veechs/Bagshui/issues/111). <sup><small>🪲&nbsp;[@p3isman](https://github.com/p3isman)</small></sup>

## 1.4.4 - 2025-03-02
### Fixed
* Keep Bags and Bank settings [in sync](https://github.com/veechs/Bagshui/issues/108) when they are using the same profiles (hard to believe I missed this for so long). <sup><small>🪲&nbsp;Evilko</small></sup>
* Ensure bottom toolbar size doesn't [do silly things](https://github.com/veechs/Bagshui/issues/107) when bag slots are hidden. <sup><small>🪲&nbsp;Evilko</small></sup>

## 1.4.3 - 2025-03-01
### Fixed
* Clicking a bag slot with Outfitter installed will no longer [error](https://github.com/veechs/Bagshui/issues/101) (this was somehow an issue since 1.0‽). <sup><small>🪲&nbsp;bonho</small></sup>
* Prevent [errors](https://github.com/veechs/Bagshui/issues/102) while processing items with very long tooltips. <sup><small>🪲&nbsp;bonho</small></sup>

## 1.4.2 - 2025-02-22
### Fixed
* Hearthstone toolbar button won't throw errors anymore.

## 1.4.1 - 2025-02-22
### Fixed
* Small improvement to item slot button proxying to avoid errors from Blizzard code.

## 1.4.0 - 2025-02-22
### Changed
* Added [window strata option](https://github.com/veechs/Bagshui/issues/91). Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **Advanced** > **Window** • **Strata**. <sup><small>🫶&nbsp;[@Nikki1993](https://github.com/Nikki1993)</small></sup>

### Fixed
* Yet another rework of how Bagshui's item slot buttons interact with Blizzard code. Hopefully third time's the charm! This also fixes [partial stack selling](https://github.com/veechs/Bagshui/issues/93).
  * If you're interested in what's going on with this, [here's some exciting reading](https://github.com/veechs/Bagshui/pull/95).

## 1.3.0 - 2025-02-17
### Changed
* Accuracy of unusable item tinting has been vastly improved (things like fist weapons that gave it fits before now work correctly).<br><sup><small>Thanks to [@Sunelegy](https://github.com/Sunelegy) for bringing the problems to my attention and [@shagu](https://github.com/shagu) for the pfUI code pointing me to the right solution.</small></sup>

### Fixed
* Significant zh-CN localization refinements by [@Sunelegy](https://github.com/Sunelegy).
* No more errors in FrameXML.log. <sup><small>🪲&nbsp;[@RetroCro](https://github.com/RetroCro)</small></sup>

## 1.2.29 - 2025-02-16
### Fixed
* Another rule function menu fix. Hopefully the last one.

## 1.2.28 - 2025-02-16
### Fixed
* The rule function menu in the Category editor has been broken since 1.1. Big oops.

## 1.2.27 - 2025-02-15
### Changed
* Add [Gemstone of Ysera](https://github.com/veechs/Bagshui/issues/84) to default Keys Category. <sup>🗃️&nbsp;[@Mats391](https://github.com/Mats391)</sup>

## 1.2.26 - 2025-02-13
### Fixed
* Avoid [errors](https://github.com/veechs/Bagshui/issues/73) when making bulk purchases at merchants. <sup><small>🪲&nbsp;Roido</small></sup>

## 1.2.25 - 2025-02-12
### Changed
* Added zh-CN localization. Many thanks to [@Sunelegy](https://github.com/Sunelegy)!

## 1.2.24 - 2025-02-10
### Fixed
* Multiple objects (Categories, Sort Orders, etc.) created simultaneously will no longer run the risk of overwriting each other.

## 1.2.23 - 2025-02-09
### Fixed
* Unequipping a bag now [correctly unlocks slot highlighting](https://github.com/veechs/Bagshui/issues/70). <sup><small>🪲&nbsp;[@Nikki1993](https://github.com/Nikki1993)</small></sup>

## 1.2.22 - 2025-02-05
### Fixed
* [Don't reset window position while drag is in progress](https://github.com/veechs/Bagshui/issues/69). <sup><small>🪲&nbsp;[@Nikki1993](https://github.com/Nikki1993)</small></sup>

## 1.2.21 - 2025-02-04
### Changed
* Added `Lock` and `Unlock` parameters to `/Bagshui Bags/Bank`.

### Fixed
* Significant improvements to Settings menu positioning to keep it onscreen at all times. <sup><small>🪲&nbsp;leiaravdenheilagekyrkja</small></sup>
* Resetting the window position via `/Bagshui Bags/Bank ResetPosition` now works correctly regardless of window anchoring. <sup><small>🪲&nbsp;leiaravdenheilagekyrkja</small></sup>

## 1.2.20 - 2025-01-25
### Fixed
* Ensure [stack splitting targets the correct item](https://github.com/veechs/Bagshui/issues/63) (and don't break everything like 1.2.17 did).

## 1.2.19 - 2025-01-25
### Fixed
* Temporarily revert change from 1.2.17 because it seems to be [breaking some things](https://github.com/veechs/Bagshui/issues/65).

## 1.2.18 - 2025-01-25
### Fixed
* Outfitter integration now [ignores enchant codes](https://github.com/veechs/Bagshui/issues/62) since those don't always seem to be updated on the Outfitter side. <sup><small>🪲&nbsp;bonho</small></sup>

## 1.2.17 - 2025-01-25
### Fixed (but not really, since it caused all kinds of issues)
* Ensure [stack splitting targets the correct item](https://github.com/veechs/Bagshui/issues/63). <sup><small>🪲&nbsp;bonho</small></sup>

## 1.2.16 - 2025-01-21
### Fixed
* [Offline tooltips in Bags](https://github.com/veechs/Bagshui/issues/60) work, which were broken since 1.2.4. <sup><small>🪲&nbsp;[@Kirius88](https://github.com/Kirius88)</small></sup>

## 1.2.15 - 2025-01-19
### Fixed
* Improve [accuracy of unusable item coloring](https://github.com/veechs/Bagshui/issues/58). <sup><small>🪲&nbsp;bonho</small></sup>

## 1.2.14 - 2025-01-19
### Fixed
* Prevent errors when opening menus. <sup><small>🪲&nbsp;Miwi</small></sup>

## 1.2.13 - 2025-01-18
### Changed
* Item stock change badges (new/increased/decreased) [will not disappear immediately when the item is clicked](https://github.com/veechs/Bagshui/issues/57) by default.  
ℹ️ If you prefer the old behavior, it's available by enabling **Clear on Click** under **Settings** > **More** > **Stock Change Timers**.

## 1.2.12 - 2025-01-18
### Fixed
* Locked items now [dim like they should](https://github.com/veechs/Bagshui/issues/56).

## 1.2.11 - 2025-01-18
### Fixed
* Edit Mode [Direct Assignment](https://github.com/veechs/Bagshui/wiki/Edit-Mode#managing-direct-assignment) didn't work correctly with Class Categories. [Now it does](https://github.com/veechs/Bagshui/issues/55).

## 1.2.10 - 2025-01-17
### Fixed
* Better error handling [when a quest link is clicked in chat and pfQuest isn't installed](https://github.com/veechs/Bagshui/issues/52). <sup><small>🪲&nbsp;[@doctorwizz](https://github.com/doctorwizz)</small></sup>
* Really truly [prevent built-in Categories from being edited](https://github.com/veechs/Bagshui/issues/35). <sup><small>🪲&nbsp;bonho</small></sup>

## 1.2.9 - 2025-01-16
### Changed
* [Add Tokens to default Profiles](https://github.com/veechs/Bagshui/issues/42) to capture most pseudo-currency items like reputation and battleground turn-ins. <sup><small>🗃️&nbsp;[@KameleonUK](https://github.com/KameleonUK)</small></sup><br>***Please note:***
  * If the Profiles you're using are still pretty close to the default, you should get Tokens added automatically.
  * If you don't receive a Tokens Group and want one, [it's pretty easy](https://github.com/veechs/Bagshui/wiki/Walkthroughs#creating-a-group) to create a Group and assign the Tokens Category.
### Fixed
* Fix [Bank bag slot highlighting](https://github.com/veechs/Bagshui/issues/50) and a [possible tooltip error](https://github.com/veechs/Bagshui/issues/51). <sup><small>🪲&nbsp;[@Nikki1993](https://github.com/Nikki1993)</small></sup>
* Fix Edit Mode Group tooltips potentially not displaying all Categories.

## 1.2.8 - 2025-01-15
### Fixed
* [Improved offscreen window detection](https://github.com/veechs/Bagshui/issues/49). <sup><small>🪲&nbsp;[@doctorwizz](https://github.com/doctorwizz)</small></sup>

## 1.2.7 - 2025-01-15
### Fixed
* Stop item charge counts from [disappearing](https://github.com/veechs/Bagshui/issues/36).

## 1.2.6 - 2025-01-15
### Fixed
* 🚨 Important bug fix to avoid [the wrong quest being abandoned](https://github.com/veechs/Bagshui/issues/48). <sup><small>🪲&nbsp;[@Nikki1993](https://github.com/Nikki1993)</small></sup>
* Item categorization updates for [Bright Dream Shard](https://github.com/veechs/Bagshui/issues/44) and [Arena Mark of Honor](https://github.com/veechs/Bagshui/issues/41). <sup><small>🗃️&nbsp;bonho and [@KameleonUK](https://github.com/KameleonUK)</small></sup>

## 1.2.5 - 2025-01-11
### Changed
*The [Info Tooltip Taming](https://github.com/veechs/Bagshui/milestone/2?closed=1) Update*
* [Bagshui Info Tooltips](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) should behave much better with fewer edge cases and improved compatibility. <sup><small>🫶&nbsp;[@Distrattos](https://github.com/Distrattos), [@doctorwizz](https://github.com/doctorwizz), and [@thecreth](https://github.com/thecreth)</small></sup>
* It will appear above the item tooltip for auction listings to avoid obscuring the row.
* Listings in [aux](https://github.com/shirsig/aux-addon-vanilla) will now get Info Tooltips too.<br><sup>This was a *whole thing* because aux likes to do things its own special way.</sup>

## 1.2.4 - 2025-01-11
### Fixed
* [Improve compatibility with tooltip addons](https://github.com/veechs/Bagshui/issues/11), including **CompareStats** and anything **GFW_**. <sup><small>🪲&nbsp;bonho and [@thecreth](https://github.com/thecreth)</small></sup>

## 1.2.3 - 2025-01-09
### Fixed
* Catalog won't [annoyingly clear your search text when it shouldn't](https://github.com/veechs/Bagshui/issues/24). <sup><small>🪲&nbsp;[@tippfelher](https://github.com/tippfelher)</small></sup>
* [Turn off Highlight Changes when there's nothing left to highlight](https://github.com/veechs/Bagshui/issues/19). <sup><small>🪲&nbsp;[@Distrattos](https://github.com/Distrattos)</small></sup><br><sup>There's some interplay between Bags and Keyring around this that still needs to be resolved but I don't think anyone uses Keyring enough to *really* care.</sup>
* Tweak Recipes category to include Top Half/Bottom Half Advanced Volumes (thanks Melo)
* Try to make it clear during Direct Assignment in Edit Mode that a [custom Category is required](https://github.com/veechs/Bagshui/wiki/FAQ#why-cant-i-edit-built-in-objects).

## 1.2.2 - 2025-01-08
### Fixed
* [Windows that try to go for an adventure off the screen](https://github.com/veechs/Bagshui/issues/18) should now be brought back. `/bagshui Bags ResetPosition` (or `Bank`) has also been made available in case manual intervention is required.

## 1.2.1 - 2025-01-06
### Fixed
* Fix [Direct Assignment bug](https://github.com/veechs/Bagshui/issues/17) that was causing a lot of confusion. Sorry everyone, and thanks to Kord2998, Secrett, and [@saintsareprey](https://github.com/saintsareprey) for bringing this to my attention.

## 1.2.0 - 2025-01-05
### Changed
* [Add setting](https://github.com/veechs/Bagshui/issues/14) to prevent automatic reorganization when the Inventory window is closed and reopened. <sup><small>🫶&nbsp;Serbz and Caveira</small></sup>
  * Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **Advanced** > **Behaviors** > **Manual Reorganization**.
* [Add setting](https://github.com/veechs/Bagshui/issues/12) to display [Bagshui Info Tooltip](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) without holding Alt. <sup><small>🫶&nbsp;[@doctorwizz](https://github.com/doctorwizz)</small></sup>
  * Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **More** > **Integration** > **Info Tooltip** > **Show Without Alt**.

## 1.1.1 - 2025-01-04
### Fixed
* [Remove "long cooldown" workaround](https://github.com/veechs/Bagshui/issues/10) (special thanks to [@shagu](https://github.com/shagu) for working through this).

## 1.1.0 - 2025-01-04
### Changed
* Add `Transmog()` [rule function](https://github.com/veechs/Bagshui/wiki/Rules) stub to support Turtle transmog collection data via [Bagshui-Tmog](https://github.com/veechs/Bagshui-Tmog). <sup><small>🫶&nbsp;Tyrchast</small></sup>
* Internal rework of rule function management.
* Refactor [3rd party API](https://github.com/veechs/Bagshui/wiki/Developers:-API).

## 1.0.8 - 2025-01-02
### Fixed
* Fix [Profile Replace error](https://github.com/veechs/Bagshui/issues/9).

## 1.0.7 - 2025-01-01
### Fixed
* Fixes to [3rd party `Bagshui:AddRuleFunction()` API](https://github.com/veechs/Bagshui/wiki/Developers:-API) (i.e. it'll actually work now).

## 1.0.6 - 2025-01-01
### Fixed
* Fix [Active Quest Item error](https://github.com/veechs/Bagshui/issues/6). <sup>💞&nbsp;[absir](https://github.com/absir)</sup>

## 1.0.5 - 2024-12-31
### Fixed
* Fix [tDF MinimapButtonBag tweaks](https://github.com/veechs/Bagshui/issues/5). <sup><small>🪲&nbsp;Amon_RA</small></sup>

## 1.0.4 - 2024-12-31
### Changed
* [Window scale setting added](https://github.com/veechs/Bagshui/issues/4). <sup><small>🫶&nbsp;[mmrosh](https://github.com/mrrosh)</small></sup>
* Adjust default categories: <sup><small>🗃️&nbsp;[@melba](https://github.com/melbaa)</small></sup>
  * Add Turtle WoW items to Teleport and decrease sequence number to run before Soulbound.
  * Add missing Anti-Venoms to First Aid (formerly Bandages).

## 1.0.3 - 2024-12-30
### Changed
* Open All Bags key binding will now [toggle Bags to match default Blizzard behavior](https://github.com/veechs/Bagshui/issues/3).

## 1.0.2 - 2024-12-30
### Fixed
* Prevent [nil colorStr error](https://github.com/veechs/Bagshui/issues/2). <sup><small>🪲&nbsp;Gondoleon</small></sup>

## 1.0.1 - 2024-12-30
### Fixed
* Improve efficiency of [searching via rules](https://github.com/veechs/Bagshui/wiki/Searching#advanced-searches).

## 1.0.0 - 2024-12-30
* Initial release.
