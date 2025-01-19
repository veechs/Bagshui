# Bagshui Changelog

## 1.2.15 - 2025-01-19
* Improve [accuracy of unusable item coloring](https://github.com/veechs/Bagshui/issues/58) (thanks bonho).

## 1.2.14 - 2025-01-19
* Prevent errors when opening menus (thanks Miwi).

## 1.2.13 - 2025-01-18
* Item stock change badges (new/increased/decreased) [will not disappear immediately when the item is clicked](https://github.com/veechs/Bagshui/issues/57) by default.  
ℹ️ If you prefer the old behavior, it's available by enabling **Clear on Click** under **Settings** > **More** > **Stock Change Timers**.

## 1.2.12 - 2025-01-18
* Locked items now [dim like they should](https://github.com/veechs/Bagshui/issues/56).

## 1.2.11 - 2025-01-18
* Edit Mode [Direct Assignment](https://github.com/veechs/Bagshui/wiki/Edit-Mode#managing-direct-assignment) didn't work correctly with Class Categories. [Now it does](https://github.com/veechs/Bagshui/issues/55).

## 1.2.10 - 2025-01-17
* Better error handling [when a quest link is clicked in chat and pfQuest isn't installed](https://github.com/veechs/Bagshui/issues/52) (thanks [@doctorwizz](https://github.com/doctorwizz)).
* Really truly [prevent built-in Categories from being edited](https://github.com/veechs/Bagshui/issues/35) (thanks bonho).

## 1.2.9 - 2025-01-16
* [Add Tokens to default Profiles](https://github.com/veechs/Bagshui/issues/42) to capture most pseudo-currency items like reputation and battleground turn-ins (thanks [@KameleonUK](https://github.com/KameleonUK)).<br>***Please note:***
  * If the Profiles you're using are still pretty close to the default, you should get Tokens added automatically.
  * If you don't receive a Tokens Group and want one, [it's pretty easy](https://github.com/veechs/Bagshui/wiki/Walkthroughs#creating-a-group) to create a Group and assign the Tokens Category.
* Fix [Bank bag slot highlighting](https://github.com/veechs/Bagshui/issues/50) and a [possible tooltip error](https://github.com/veechs/Bagshui/issues/51) (thanks [@Nikki1993](https://github.com/Nikki1993)).
* Fix Edit Mode Group tooltips potentially not displaying all Categories.

## 1.2.8 - 2025-01-15
* [Improved offscreen window detection](https://github.com/veechs/Bagshui/issues/49) (thanks [@doctorwizz](https://github.com/doctorwizz)).

## 1.2.7 - 2025-01-15
* Stop item charge counts from [disappearing](https://github.com/veechs/Bagshui/issues/36).

## 1.2.6 - 2025-01-15
* 🚨 Important bug fix to avoid [the wrong quest being abandoned](https://github.com/veechs/Bagshui/issues/48) (thanks [@Nikki1993](https://github.com/Nikki1993)).
* Item categorization updates for [Bright Dream Shard](https://github.com/veechs/Bagshui/issues/44) and [Arena Mark of Honor](https://github.com/veechs/Bagshui/issues/41) (thanks bonho and [@KameleonUK](https://github.com/KameleonUK)).

## 1.2.5 - 2025-01-11
*The [Info Tooltip Taming](https://github.com/veechs/Bagshui/milestone/2?closed=1) Update*
* [Bagshui Info Tooltips](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) should behave much better with fewer edge cases and improved compatibility (thanks [@Distrattos](https://github.com/Distrattos), [@doctorwizz](https://github.com/doctorwizz), and [@thecreth](https://github.com/thecreth)).
* It will appear above the item tooltip for auction listings to avoid obscuring the row.
* Listings in [aux](https://github.com/shirsig/aux-addon-vanilla) will now get Info Tooltips too.<br><sup>This was a *whole thing* because aux likes to do things its own special way.</sup>

## 1.2.4 - 2025-01-11
* [Improve compatibility with tooltip addons](https://github.com/veechs/Bagshui/issues/11), including CompareStats and anything GFW_ (thanks bonho and [@thecreth](https://github.com/thecreth)).

## 1.2.3 - 2025-01-09
* Catalog won't [annoyingly clear your search text when it shouldn't](https://github.com/veechs/Bagshui/issues/24) (thanks [@tippfelher](https://github.com/tippfelher)).
* [Turn off Highlight Changes when there's nothing left to highlight](https://github.com/veechs/Bagshui/issues/19) (thanks [@Distrattos](https://github.com/Distrattos)).<br><sup>There's some interplay between Bags and Keyring around this that still needs to be resolved but I don't think anyone uses Keyring enough to *really* care.</sup>
* Tweak Recipes category to include Top Half/Bottom Half Advanced Volumes (thanks Melo)
* Try to make it clear during Direct Assignment in Edit Mode that a [custom Category is required](https://github.com/veechs/Bagshui/wiki/FAQ#why-cant-i-edit-built-in-objects).

## 1.2.2a - 2025-01-08
* [Windows that try to go for an adventure off the screen](https://github.com/veechs/Bagshui/issues/18) should now be brought back. `/bagshui Bags ResetPosition` (or `Bank`) has also been made available in case manual intervention is required.

## 1.2.1 - 2025-01-06
* Fix [Direct Assignment bug](https://github.com/veechs/Bagshui/issues/17) that was causing a lot of confusion. Sorry everyone, and thanks to Kord2998, Secrett, and [@saintsareprey](https://github.com/saintsareprey) for bringing this to my attention.

## 1.2 - 2025-01-05
* [Add setting](https://github.com/veechs/Bagshui/issues/14) to prevent automatic reorganization when the Inventory window is closed and reopened (thanks Serbz and Caveira). Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **Advanced** > **Behaviors** > **Manual Reorganization**.
* [Add setting](https://github.com/veechs/Bagshui/issues/12) to display [Bagshui Info Tooltip](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip) without holding Alt (thanks JackTupp). Find it at **[Settings](https://github.com/veechs/Bagshui/wiki/Home#settings)** > **More** > **Integration** > **Info Tooltip** > **Show Without Alt**.

## 1.1.1 - 2025-01-04
* [Remove "long cooldown" workaround](https://github.com/veechs/Bagshui/issues/10) (special thanks to [shagu](https://github.com/shagu)).

## 1.1 - 2025-01-04
* Add `Transmog()` [rule function](https://github.com/veechs/Bagshui/wiki/Rules) stub to support Turtle transmog collection data via [Bagshui-Tmog](https://github.com/veechs/Bagshui-Tmog) (thanks Tyrchast).
* Internal rework of rule function management.
* Refactor [3rd party API](https://github.com/veechs/Bagshui/wiki/Developers:-API).

## 1.0.8 - 2025-01-02
* Fix [Profile Replace error](https://github.com/veechs/Bagshui/issues/9).

## 1.0.7 - 2025-01-01
* Fixes to [3rd party `Bagshui:AddRuleFunction()` API](https://github.com/veechs/Bagshui/wiki/Developers:-API) (i.e. it'll actually work now).

## 1.0.6 - 2025-01-01
* Fix [Active Quest Item error](https://github.com/veechs/Bagshui/issues/6) (thanks [absir](https://github.com/absir)).

## 1.0.5 - 2024-12-31
* Fix [tDF MinimapButtonBag tweaks](https://github.com/veechs/Bagshui/issues/5) (thanks Amon_RA).

## 1.0.4 - 2024-12-31
* [Window scale setting added](https://github.com/veechs/Bagshui/issues/4) (thanks [mmrosh](https://github.com/mrrosh)).
* Adjust default categories (thanks [melba](https://github.com/melbaa)):
  * Add Turtle WoW items to Teleport and decrease sequence number to run before Soulbound.
  * Add missing Anti-Venoms to First Aid (formerly Bandages).

## 1.0.3 - 2024-12-30
* Open All Bags key binding will now [toggle Bags to match default Blizzard behavior](https://github.com/veechs/Bagshui/issues/3).

## 1.0.2 - 2024-12-30
* Prevent [nil colorStr error](https://github.com/veechs/Bagshui/issues/2) (thanks Gondoleon).

## 1.0.1 - 2024-12-30
* Improve efficiency of [searching via rules](https://github.com/veechs/Bagshui/wiki/Searching#advanced-searches).

## 1.0 - 2024-12-30
* Initial release.