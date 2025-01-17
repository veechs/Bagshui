<h1>
<img src="Images/Logo.svg" width="204" align="left" alt="Bagshui">
<div width="100%">&nbsp;</div>
</h1>

**A Vanilla WoW 1.12 (and Turtle WoW) inventory addon.**<br><sup><small>Not for Classic or Retail; you have [so](https://www.curseforge.com/wow/addons/better-bags) [many](https://www.curseforge.com/wow/addons/ark-inventory) [options](https://www.curseforge.com/wow/search?class=addons&categories=bags-inventory&sortBy=popularity).</small></sup>

[![Bagshui](https://github.com/veechs/Bagshui/wiki/images/Bagshui_Thumb.png)](https://github.com/veechs/Bagshui/wiki/Screenshots)  
<sup>[More screenshots](https://github.com/veechs/Bagshui/wiki/Screenshots)</sup>

## Features

* Single window inventory for Bags, Bank, and Keyring.
* [Customizable layout and design](https://github.com/veechs/Bagshui/wiki/Profiles) with automatic grouping and sorting.
* [Categorization](https://github.com/veechs/Bagshui/wiki/Categories) via [rules](https://github.com/veechs/Bagshui/wiki/Rules) and item lists.
* Per-inventory and account-wide [search](https://github.com/veechs/Bagshui/wiki/Searching).
* Offline viewing of any character’s inventory and [item counts in tooltips](https://github.com/veechs/Bagshui/wiki/Item-Information#info-tooltip).
* Identification of [profession reagents and crafted items](https://github.com/veechs/Bagshui/wiki/Professions).<br><sup>Updated when the crafting window is opened.</sup>
* Color tinting of unusable items.
* Badges to indicate stock changes, quality, quest items, and unusability.
* Empty slot stacking and custom graphics for profession bag slots.
* [Colorblind mode](https://github.com/veechs/Bagshui/wiki/Accessibility#colorblind-mode) to help identify item quality and unusability.
* Lots of little niceties like a Hearthstone button, pfUI skinning, and more.

<details>

<summary>Recommended if you like…</summary>

AdiBags, ArkInventory, Baganator, Baggins, BetterBags, EngInventory/EngBags, TBag.  
And with “[OneBagshui](https://github.com/veechs/Bagshui/wiki/FAQ#how-do-i-switch-to-the-onebag-style-layout)”: Bagnon, Combuctor, Inventorian, LiteBag, OneBag3, SUCC-bag.

</details>

## Documentation

* [Wiki](https://github.com/veechs/Bagshui/wiki) + [FAQ](https://github.com/veechs/Bagshui/wiki/FAQ) + [Walkthroughs](https://github.com/veechs/Bagshui/wiki/Walkthroughs)
* [Version history](Changelog.md)

## Installation

### Easy mode (recommended)

Use [GitAddonsManager](https://woblight.gitlab.io/overview/gitaddonsmanager/).  
<sup>Or any tool that supports Git.</sup>

### Manual

1. [Download Bagshui](https://github.com/veechs/Bagshui/archive/refs/heads/main.zip).
2. Extract the zip file.
3. Rename the resulting `Bagshui-main` folder to `Bagshui`.
4. Move that folder to `[Path\To\WoW]\Interface\Addons`.
5. Ensure the structure is `Interface\Addons\Bagshui\Bagshui.toc`.  
   <sup>*These are all **wrong**:*  
    × `Bagshui-main\Bagshui.toc`  
    × `Bagshui\Bagshui\Bagshui.toc`  
	 × `Bagshui\Bagshui-main\Bagshui.toc`
   </sup>


## Compatibility

<table>

<tr>
<td>

### Auction and Mail
<sup>Right-click/Alt+click attach</sup>

</td>
<td>

* Blizzard UI
* [aux](https://github.com/gwetchen/aux-addon)
* [Mail](https://github.com/EinBaum/Mail)
* [Postal Returned](https://github.com/veechs/Postal-Returned) / Postal / CT_MailMod

</td>
</tr>


<tr>
<td>

### Cooldown counts

</td>
<td>

* [OmniCC](https://github.com/Otari98/OmniCC)
* [pfUI](https://shagu.org/pfUI/)
* [ShaguTweaks](https://shagu.org/ShaguTweaks/)
* [Turtle Dragonflight](https://github.com/TheLinuxITGuy/Turtle-Dragonflight)

</td>
</tr>


<tr>
<td>

### Interface replacement

</td>
<td>

* [pfUI](https://shagu.org/pfUI/) skin  
<sup>Manage in **pfUI Config** (`/pfui`) > **Components** > **Skins**</sup>

</td>
</tr>


<tr>
<td>

### [Rule functions](https://github.com/veechs/Bagshui/wiki/Rules#available-rule-functions)

</td>
<td>

* `Outfit()` - [ItemRack](https://turtle-wow.fandom.com/wiki/ItemRack) and [Outfitter](https://github.com/pepopo978/Outfitter)
* `Wishlist()` - [AtlasLoot](https://turtle-wow.fandom.com/wiki/AtlasLoot)

</td>
</tr>


<tr>
<td>

### Turtle WoW

</td>
<td>

* **Guild Bank** right-click to deposit.
* [`Transmog()`](https://github.com/veechs/Bagshui/wiki/Rules#available-rule-functions) collection queries.<br><sup>Requires [Tmog](https://github.com/Otari98/Tmog) and [Bagshui-Tmog](https://github.com/veechs/Bagshui-Tmog).

</td>
</tr>

</table>

<sup>If installed, [SuperWoW](https://github.com/balakethelock/SuperWoW) provides charge counts (the `x#` overlay for multi-use items) slightly more efficiently. This is pretty minor since you'll have the functionality regardless.</sup>


## Credits

Bagshui owes [so much to so many people](Credits.md).

## Localization

Translations are welcome! [Instructions here](Localization/Readme.md).
