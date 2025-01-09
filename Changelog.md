# Bagshui Changelog

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