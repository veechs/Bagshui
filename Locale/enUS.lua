Bagshui:LoadComponent(function()

BsLocalization:AddLocale("enUS", {

-- ### Game Stuff ###

-- Player classes.
["Druid"] = "Druid",
["Hunter"] = "Hunter",
["Mage"] = "Mage",
["Paladin"] = "Paladin",
["Priest"] = "Priest",
["Rogue"] = "Rogue",
["Shaman"] = "Shaman",
["Warlock"] = "Warlock",
["Warrior"] = "Warrior",

-- Item classes and subclasses that can't be automatically localized because they're not
-- returned from `GetAuctionItemClasses()` / `GetAuctionItemSubClasses()`.
["Devices"] = "Devices",
["Explosives"] = "Explosives",
["Junk"] = "Junk",
["Key"] = "Key",
["Miscellaneous"] = "Miscellaneous",
["Parts"] = "Parts",
["Quest"] = "Quest",
["Trade Goods"] = "Trade Goods",

-- Skill types.
-- Must cover all keys in `LOCALIZED_TO_EN_SKILL_ID` and `IGNORE_SKILL_CATEGORY`.
["Class Skills"] = "Class Skills",
["Professions"] = "Professions",
["Secondary Skills"] = "Secondary Skills",
["Weapon Skills"] = "Weapon Skills",
["Armor Proficiencies"] = "Armor Proficiencies",
["Languages"] = "Languages",

-- Skills.
-- Must cover any skill that the game can return from `GetSkillLineInfo()`.
["Axes"] = "Axes",
["Dual Wield"] = "Dual Wield",
["Fishing"] = "Fishing",
["Maces"] = "Maces",
["Swords"] = "Swords",
["Plate Mail"] = "Plate Mail",
["Shield"] = "Shield",

-- Professions that have their own bag types.
-- Referenced in GameInfo.lua to build the `professionsToBags` table.
["Enchanting"] = "Enchanting",
["Herbalism"] = "Herbalism",




-- ### General ###

["AbandonChanges"] = "Abandon Changes",
["About"] = "About",
["Actions"] = "Actions",
["Add"] = "Add",
["AddSlashRemove"] = "Add/Remove",
["Aliases"] = "Aliases",
["AltClick"] = "Alt+Click",
["AltRightClick"] = "Alt+Right-Click",
["Ascending"] = "Ascending",
["Available"] = "Available",
["Background"] = "Background",
["Bag"] = "Bag",
["Border"] = "Border",
["Bottom"] = "Bottom",
["Cancel"] = "Cancel",
["Catalog"] = "Catalog",
["Categories"] = "Categories",
["Category"] = "Category",
["CharacterData"] = "Character Data",
["CategorySlashItem"] = "Category/Item",
["ClassCategory"] = "Class Category",
["Clear"] = "Clear",
["Click"] = "Click",
["Close"] = "Close",
["Color"] = "Color",
["Column"] = "Column",
["Copy"] = "Copy",
["Create"] = "Create",
["Creation"] = "Creation",
["Custom"] = "Custom",
["Default"] = "Default",
["Delete"] = "Delete",
["Deletion"] = "Deletion",
["Descending"] = "Descending",
["Details"] = "Details",
["Dialog"] = "Dialog",
["Disable"] = "Disable",
["Duplicate"] = "Duplicate",
["Edit"] = "Edit",
["Editing"] = "Editing",
["EmptyBagSlot"] = "Empty Bag Slot",
["Export"] = "Export",
["Full"] = "Full",
["Group"] = "Group",
["Help"] = "Help",
["Hidden"] = "Hidden",
["Hide"] = "Hide",  -- Verb, opposite of show
["HoldAlt"] = "Hold Alt",
["HoldControlAlt"] = "Hold Control+Alt",
["Horizontal"] = "Horizontal",
["Ignore"] = "Ignore",
["Import"] = "Import",
["ImportSlashExport"] = "Import/Export",
["Info"] = "Info",
["Information"] = "Information",
["Inventory"] = "Inventory",
["Item"] = "Item",
["ItemProperties"] = "Item Properties",
["KeepEditing"] = "Keep Editing",
["Label"] = "Label",
["Left"] = "Left",
["Location"] = "Location",
["Lock"] = "Lock",
["LogWindow"] = "Log Window",
["Manage"] = "Manage",
["Menu"] = "Menu",
["MoreInformation"] = "More Info",
["Move"] = "Move",
["MoveDown"] = "Move Down",
["MoveUp"] = "Move Up",
["Name"] = "Name",
["New"] = "New",
["No"] = "No",
["NotNow"] = "Not Now",
["NoItemsAvailable"] = "(No Items Available)",
["NoneAssigned"] = "(None Assigned)",
["NoneParenthesis"] = "(None)",
["NoRuleFunction"] = "(No Rule Function)",
["NoValue"] = "(No Value)",
["Open"] = "Open",
["PleaseWait"] = "Please wait...",
["Profile"] = "Profile",
["Prefix_Add"] = "Add %s",
["Prefix_Bag"] = "Bag %s",
["Prefix_Class"] = "Class %s",
["Prefix_ClickFor"] = "Click for %s",
["Prefix_Default"] = "Default %s",
["Prefix_Edit"] = "Edit %s",
["Prefix_Manage"] = "Manage %s",
["Prefix_Move"] = "Move %s",
["Prefix_New"] = "New %s",
["Prefix_OpenMenuFor"] = "Open Menu for %s",
["Prefix_Remove"] = "Remove %s",
["Prefix_Search"] = "Search %s",
["Prefix_Sort"] = "Sort %s",
["Prefix_Target"] = "Target %s",
["Prefix_Toggle"] = "Toggle %s",
["Prefix_Unnamed"] = "(Unnamed %s)",
["Profiles"] = "Profiles",
["Quality"] = "Quality",
["ReleaseAlt"] = "Release Alt",
["Reload"] = "Reload",
["Remove"] = "Remove",
["Rename"] = "Rename",
["Replace"] = "Replace",
["Report"] = "Report",
["ResetPosition"] = "Reset Position",
["Right"] = "Right",
["RightClick"] = "Right-Click",
["Row"] = "Row",
["Save"] = "Save",
["Search"] = "Search",
["Settings"] = "Settings",
["Share"] = "Share",
["Show"] = "Show",
["SortOrder"] = "Sort Order",
["SortOrders"] = "Sort Orders",
["Sorting"] = "Sorting",
["Stack"] = "Stack",  -- Verb
["Suffix_Default"] = "%s " .. LIGHTYELLOW_FONT_COLOR_CODE .. " [Default]" .. FONT_COLOR_CODE_CLOSE,
["Suffix_EmptySlot"] = "%s Empty Slot",
["Suffix_Menu"] = "%s Menu",
["Suffix_ReadOnly"] = "%s " .. LIGHTYELLOW_FONT_COLOR_CODE .. "[Read-Only]" .. FONT_COLOR_CODE_CLOSE,
["Suffix_Reversed"] = "%s [reversed]",  -- Used in explanations of sort orders when a field is reversed (i.e. Name [reversed])
["Suffix_Sets"] = "%d set(s)",
["Symbol_Brackets"] = "[%s]",
["Symbol_Colon"] = "%s:",
["Symbol_Ellipsis"] = "%s…",  -- Used in menus to indicate that clicking it will open another dialog or menu
["Templates"] = "Templates",
["Text"] = "Text",
["Toggle"] = "Toggle",  -- Verb
["Top"] = "Top",
["Total"] = "Total",
["Undo"] = "Undo",
["Unknown"] = "Unknown",
["Unlock"] = "Unlock",
["Unnamed"] = "(Unnamed)",
["Unstack"] = "Unstack",  -- Verb
["Used"] = "Used",
["UseDefault"] = "Use Default",
["Validate"] = "Validate",
["Vertical"] = "Vertical",
["VersionNumber"] = "Version %s",
["Yes"] = "Yes",

-- Inventory types.
["Bags"] = "Bags",
["Bank"] = "Bank",
["Equipped"] = "Equipped",
["Keyring"] = "Keyring",

-- Abbreviations for tooltip use.
["Abbrev_Bags"] = "Bag",
["Abbrev_Bank"] = "Bank",
["Abbrev_Keyring"] = "Key",
["Abbrev_Equipped"] = "Equip",

-- Slash command help message.
["Slash_Help"] = "%s commands:",
["Slash_Help_Postscript"] = "For a list of subcommands, append Help to the command.",

-- Key bindings (other than Inventory class names; those are handled in `Inventory:New()`).
["Binding_Resort"] = "Organize All",
["Binding_Restack"] = "Restack All",

-- Item properties to friendly names as `ItemPropFriendly_<propertyName>`.
-- Anything non-private in `BS_ITEM_SKELETON` or `BS_REALTIME_ITEM_INFO_PROPERTIES` must be present.
["ItemPropFriendly_activeQuest"] = "Active Quest Item",
["ItemPropFriendly_baseName"] = "Base Name",
["ItemPropFriendly_bagNum"] = "Bag Number",
["ItemPropFriendly_bagType"] = "Bag Type",
["ItemPropFriendly_bindsOnEquip"] = "Binds on Equip",
["ItemPropFriendly_charges"] = "Charges",
["ItemPropFriendly_count"] = "Count",
["ItemPropFriendly_equipLocation"] = "Equip Location",
["ItemPropFriendly_equipLocationLocalized"] = "Equip Location (Localized)",
["ItemPropFriendly_emptySlot"] = "Empty Slot",
["ItemPropFriendly_id"] = "Item ID",
["ItemPropFriendly_itemLink"] = "Item Link",
["ItemPropFriendly_itemString"] = "Item String",
["ItemPropFriendly_locked"] = "Locked",
["ItemPropFriendly_maxStackCount"] = "Maximum Stack Count",
["ItemPropFriendly_minLevel"] = "Minimum Level",
["ItemPropFriendly_name"] = "!!Name!!",
["ItemPropFriendly_periodicTable"] = "Periodic Table",
["ItemPropFriendly_quality"] = "!!Quality!!",
["ItemPropFriendly_qualityLocalized"] = "Quality (Localized)",
["ItemPropFriendly_readable"] = "Readable",
["ItemPropFriendly_slotNum"] = "Slot Number",
["ItemPropFriendly_soulbound"] = "Soulbound",
["ItemPropFriendly_stacks"] = "Stacks",
["ItemPropFriendly_subtype"] = "Subtype",
["ItemPropFriendly_SuffixName"] = "Suffix Name",
["ItemPropFriendly_tooltip"] = "Tooltip",
["ItemPropFriendly_type"] = "Type",
["ItemPropFriendly_uncategorized"] = "Uncategorized",




-- ### Inventory UI ###

["Inventory_NoData"] = "Offline inventory not available.",

-- Toolbar.
["Toolbar_Menu_TooltipTitle"] = "Menu",
["Toolbar_ExitEditMode"] = "Exit Edit Mode",
["Toolbar_Catalog_TooltipTitle"] = "Catalog (Account-Wide Inventory)",
["Toolbar_Catalog_TooltipText"] = "View and search the combined inventories of all characters on this account.",
["Toolbar_Character_TooltipTitle"] = "Character",
["Toolbar_Character_TooltipText"] = "View your other characters' %s.",  -- %s = Inventory type.
["Toolbar_Hide_TooltipTitle"] = "Don't Show Hidden",
["Toolbar_Show_TooltipTitle"] = "Show Hidden",
["Toolbar_Show_TooltipText"] = "Toggle display of hidden items.",
["Toolbar_Search_TooltipTitle"] = "Search",
["Toolbar_Search_TooltipText"] = "Filter the contents of your %s." .. BS_NEWLINE .. "Press Shift+Enter while searching to open the Catalog.",  -- %s = Inventory type.
["Toolbar_Resort_TooltipTitle"] = "Organize",
["Toolbar_Resort_TooltipText"] = "Categorize and sort.",
["Toolbar_Restack_TooltipTitle"] = "Restack",
["Toolbar_Restack_TooltipText"] = "Consolidate stackable items.",
["Toolbar_HighlightChanges_TooltipTitle"] = "Highlight Changes",
["Toolbar_HighlightChanges_TooltipText"] = "Toggle spotlighting of recently changed items." .. BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "Alt-click to mark all items as unchanged.",
["Toolbar_UnHighlightChanges_TooltipTitle"] = "Don't Highlight Changes",

-- Action Tooltips.
["Tooltip_Inventory_ToggleBagSlotHighlightLockHint"] = "%s to %s slot highlighting.",  -- "Alt-Click to lock/unlock slot highlighting"
["Tooltip_Inventory_ToggleEmptySlotStacking"] = "%s to %s empty slots.",  -- "Click to stack/unstack empty slots"
["Tooltip_Inventory_TradeShortcut"] = "%s to trade with %s.",  -- "Alt-Click to trade with <Player Name>"

-- Edit Mode.
["EditMode"] = "Edit Mode",
["EditMode_CategoryInGroup"] = "Currently assigned to group '%s' in the current structure.",  -- %s = group name or (Unnamed Group)
["EditMode_CategoryNotInGroup"] = "Not assigned to a group in the current structure.",
["EditMode_Prompt_NewGroupName"] = "Label for new group (optional but recommended):",
["EditMode_Prompt_RenameGroup"] = "New label for %s:",
["EditMode_Prompt_DeleteGroup"] = "Delete the selected group?!!Warning_NoUndo!!",
["EditMode_Tooltip_SelectNew"] = "Select new %s.",  -- %s = L.Location or L.Group

-- Main Menu.
["Menu_Main_EditMode_TooltipText"] = "Modify the current structure (rearrange groups, assign categories, etc.).",
["Menu_Main_Settings_TooltipText"] = "Open the Settings menu.",
["Menu_Main_ManageCategories_TooltipText"] = "Open the Category manager.",
["Menu_Main_ManageProfiles_TooltipText"] = "Open the Profile manager.",
["Menu_Main_ManageSortOrders_TooltipText"] = "Open the Sort Order manager.",
["Menu_Main_Toggle_TooltipText"] = "Toggle the %s window.",

-- Settings Menu (localizations for settings themselves are configured in `settingsStrings`).
["Menu_Settings"] = "%s Settings",  -- "Bags Settings"
["Menu_Settings_About"] = "About Bagshui",
["Menu_Settings_Accessibility"] = "Accessibility",
["Menu_Settings_Advanced"] = "Advanced",
["Menu_Settings_Anchoring"] = "Anchoring",
["Menu_Settings_Behaviors"] = "Behaviors",
["Menu_Settings_Badges"] = "Item Badges",
["Menu_Settings_ChangeTiming"] = "Stock Change Timers",
["Menu_Settings_Colors"] = "Colors",
["Menu_Settings_ColorHistory_TooltipTitle"] = "Color Picker History",
["Menu_Settings_Commands"] = "Commands",
["Menu_Settings_DefaultProfiles"] = "Default Profiles",
["Menu_Settings_Defaults"] = "Defaults",
["Menu_Settings_Etcetera"] = "Etcetera",
["Menu_Settings_General"] = "General",
["Menu_Settings_GroupDefaults"] = "Group Defaults",
["Menu_Settings_Groups"] = "Groups",
["Menu_Settings_Hooks_Suffix"] = "%s Hooks",  -- %s = Inventory type.
["Menu_Settings_InfoTooltip"] = "Info Tooltip",
["Menu_Settings_Integration"] = "Integration",
["Menu_Settings_Interface"] = "Interface",
["Menu_Settings_ItemSlots"] = "Item Slots",
["Menu_Settings_More"] = "More",
["Menu_Settings_More_TooltipTitle"] = "Additional Settings",
["Menu_Settings_Overrides"] = "Overrides",
["Menu_Settings_Open"] = "!!Open!!",
["Menu_Settings_Options"] = "Options",
["Menu_Settings_Profile"] = "Profile",
["Menu_Settings_Size"] = "Sizing",
["Menu_Settings_Tinting"] = "Item Tinting",
["Menu_Settings_Toggles"] = "Toggles",
["Menu_Settings_Toolbar"] = "Toolbar",
["Menu_Settings_Tooltips"] = "Tooltips",
["Menu_Settings_ToggleBagsWith"] = "Toggle Bags With",
["Menu_Settings_StockBadgeColors"] = "Stock Colors",
["Menu_Settings_View"] = "View",
["Menu_Settings_Window"] = "Window",

-- Category Menu.
["Menu_Category_Move_TooltipText"] = "Pick up this category so it can be moved to a new group.",
["Menu_Category_Edit_TooltipText"] = "Open this category in the editor.",
["Menu_Category_Remove_TooltipText"] = "Remove this category from the current group.!!Info_NoDelete!!",

-- Group Menu.
["Menu_Group_Rename_TooltipTitle"] = "Rename Group",
["Menu_Group_Rename_TooltipText"] = "Change this group's label.",
["Menu_Group_Move_TooltipTitle"] = "Move Group",
["Menu_Group_Move_TooltipText"] = "Pick this group up so it can be moved to a new location.",
["Menu_Group_Delete_TooltipTitle"] = "Delete Group",
["Menu_Group_Delete_TooltipText"] = "Delete this group completely and unassign any categories.!!Warning_NoUndo!!",

["Menu_Group_Add_Category_TooltipText"] = "Assign an existing category to this group.",
["Menu_Group_Configure_Category_TooltipText"] = "Display the context menu for this category.",
["Menu_Group_New_Category_TooltipTitle"] = "New Category",
["Menu_Group_New_Category_TooltipText"] = "Create a new category and assign it to this group.",
["Menu_Group_Move_Category_TooltipText"] = "Pick up a category that is currently assigned to this group so it can be moved to another group.",
["Menu_Group_Remove_Category_TooltipText"] = "Remove a category that is currently assigned to this group.!!Info_NoDelete!!",
["Menu_Group_Edit_Category_TooltipText"] = "Edit a category that is currently assigned to this group.",
["Menu_Group_DefaultColor_TooltipTitle"] = "Use Default Group %s Color",  -- %s = Background/Border
["Menu_Group_DefaultColor_TooltipText"] = "Apply the group %s color defined in Settings.",  -- %s = Background/Border
["Menu_Group_DefaultSortOrder_TooltipTitle"] = "Use Default Sort Order",
["Menu_Group_DefaultSortOrder_TooltipText"] = "Apply the current Structure's default sort order:" .. BS_NEWLINE .. "%s",  -- %s = <Name of default sort order>
["Menu_Group_HideGroup"] = "Hide Group",
["Menu_Group_HideGroup_TooltipText"] = "Don't display this group unless Show Hidden is toggled on.",
["Menu_Group_HideStockBadge"] = "Hide Stock Badge",
["Menu_Group_HideStockBadge_TooltipText"] = "Prevent the display of Stock Change Badges (new/increased/decreased) for this group.",
["Menu_Group_Settings_TooltipTitle"] = "Group Settings",
["Menu_Group_Settings_TooltipText"] = "Manage group-specific options, including background and border color.",
["Menu_Group_Color_TooltipTitle"] = "Group %s Color",  -- %s = Background/Border
["Menu_Group_Color_TooltipText"] = "Set the %s for this group.",  -- %s = background/border
["Menu_Group_SortOrder_TooltipTitle"] = "Group Sort Order",
["Menu_Group_SortOrder_TooltipText"] = "Change how items are sorted within this group.",

-- Item Menu.
["Menu_Item_AssignToCategory"] = "Direct Assignment",
["Menu_Item_AssignToCategory_TooltipTitle"] = "Direct Category Assignment",
["Menu_Item_AssignToCategory_TooltipText"] = "Assign this item's ID to one or more custom categories (as opposed to using rule functions).",
["Menu_Item_AssignToCategory_CreateNew_TooltipText"] = "Assign the item to a new custom category.",
["Menu_Item_AssignToCategory_Hint_CustomOnly"] = "Built-in Categories are read-only - see FAQ on the Bagshui Wiki for reasoning.",
["Menu_Item_AssignToClassCategory"] = "Direct Assignment to",
["Menu_Item_Information_TooltipTitle"] = "Item Information",
["Menu_Item_Information_TooltipText"] = "View details about this item's properties and access the Item Information window.",
["Menu_Item_Information_Submenu_TooltipText"] = "Click to open the Item Information window.",
["Menu_Item_Manage_TooltipTitle"] = "Manage Item",
["Menu_Item_Manage_TooltipText"] = "Bagshui-specific item actions.",
["Menu_Item_MatchedCategories"] = "Matched",
["Menu_Item_MatchedCategories_TooltipTitle"] = "Matched Categories",
["Menu_Item_MatchedCategories_TooltipText"] = "List of all categories that match this item, ordered by sequence.",
["Menu_Item_MatchedCategory_TooltipText"] = "Click to edit.",
["Menu_Item_Move_TooltipText"] = "Pick up this item so it can be directly assigned to a new category.",
["Menu_Item_RemoveFromEquippedGear"] = "Remove from Equipped",
["Menu_Item_RemoveFromEquippedGear_TooltipText"] = "Take this item out of the list of gear you've equipped (i.e. the Equipped() rule will no longer match).",
["Menu_Item_ResetStockState"] = "Reset Stock State",
["Menu_Item_ResetStockState_TooltipText"] = "Clear the new/increased/decreased status of this item.",

-- Item Stock State.
["StockState"] = "Stock State",
["StockLastChange"] = "Last Change",
-- BS_ITEM_STOCK_STATE localizations as `Stock_<BS_ITEM_STOCK_STATE value>`.
["Stock_New"] = "!!New!!",
["Stock_Up"] = "Increased",
["Stock_Down"] = "Decreased",
["Stock_"] = "N/A",

-- Item Information window title.
["BagshuiItemInformation"] = "Bagshui Item Information",



-- ### Categories and Groups ###

-- Templates.
["Suffix_Items"] = "%s Items",
["Suffix_Potions"] = "%s Potions",
["Suffix_Reagents"] = "%s Reagents",

-- Special categories.
["TurtleWoWGlyphs"] = "Glyphs (Turtle WoW)",
["SoulboundGear"] = "Soulbound Gear",

-- Name/Tooltip identifiers sed to categorize items using strings that appear
-- in their names or tooltips.
-- Using [[bracket quoting]] to avoid the need for any Lua pattern escapes (like \.).
-- Any Lua patterns must be wrapped in slashes per the normal Bagshui string
-- handling rules (see `TooltipIdentifier_PotionHealth` for an example).
["NameIdentifier_AntiVenom"] = [[Anti-Venom]],
["NameIdentifier_Bandage"] = [[Bandage]],
["NameIdentifier_Elixir"] = [[Elixir]],
["NameIdentifier_Firestone"] = [[Firestone]],
["NameIdentifier_FrostOil"] = [[Frost Oil]],
["NameIdentifier_HallowedWand"] = [[Hallowed Wand]],
["NameIdentifier_Idol"] = [[Idol]],
["NameIdentifier_Juju"] = [[Juju]],
["NameIdentifier_ManaOil"] = [[Mana Oil]],
["NameIdentifier_Poison"] = [[Poison]],
["NameIdentifier_Potion"] = [[Potion]],
["NameIdentifier_Scroll"] = [[^Scroll of]],
["NameIdentifier_ShadowOil"] = [[Shadow Oil]],
["NameIdentifier_SharpeningStone"] = [[Sharpening Stone]],
["NameIdentifier_Soulstone"] = [[Soulstone]],
["NameIdentifier_Spellstone"] = [[Spellstone]],
["NameIdentifier_TurtleWoWGlyph"] = [[Glyph]],  -- Used along with type('Key') to identify Turtle WoW glyphs.
["NameIdentifier_Weightstone"] = [[Weightstone]],
["NameIdentifier_WizardOil"] = [[Wizard Oil]],

["NameIdentifier_Recipe_BottomHalf"] = [[Bottom Half]],
["NameIdentifier_Recipe_TopHalf"] = [[Top Half]],

["TooltipIdentifier_Buff_AlsoIncreases"] = [[also increases your]],
["TooltipIdentifier_Buff_WellFed"] = [[well fed]],
["TooltipIdentifier_Companion"] = [[Right Click to summon and dismiss your]],
["TooltipIdentifier_Drink"] = [[Must remain seated while drinking]],
["TooltipIdentifier_Food"] = [[Must remain seated while eating]],
["TooltipIdentifier_Mount"] = [[Use: Summons and dismisses a rideable]],
["TooltipIdentifier_MountAQ40"] = [[Use: Emits a high frequency sound]],
["TooltipIdentifier_PotionHealth"] = [[/Restores [%d.]+ to [%d.]+ health\./]],  -- Wrap in slashes to activate pattern matching.
["TooltipIdentifier_PotionMana"] = [[/Restores [%d.]+ to [%d.]+ mana\./]],  -- Wrap in slashes to activate pattern matching.
["TooltipIdentifier_QuestItem"] = [[Quest Item]],

-- Tooltip parsing -- extracting data from tooltips.
["TooltipParse_Charges"] = [[^(%d+) Charges$]],  -- MUST contain the (%d) capture group.
-- ItemInfo:IsUsable() Tooltip parsing
["TooltipParse_AlreadyKnown"] = _G.ITEM_SPELL_KNOWN,
["TooltipParse_RequiresLevel"] = [[Requires (%a[%a%s]-) %((%d+)%)]],  -- Aiming to match "Requires Fishing (10)" and pull out "Fishing", "10". (Could probably use _G.ITEM_MIN_SKILL and replace its placeholders with the capture groups.)


-- Shared Category/Group Names.
["ActiveQuest"] = "Active Quest",
["Bandages"] = "Bandages",
["BindOnEquip"] = "Bind on Equip",
["Books"] = "Books",
["Buffs"] = "Buffs",
["Companions"] = "Companions",
["Consumables"] = "Consumables",
["Disguises"] = "Disguises",
["Drink"] = "Drink",
["Elixirs"] = "Elixirs",
["Empty"] = "Empty",
["EmptySlots"] = "Empty Slots",
["Equipment"] = "Equipment",
["EquippedGear"] = "Equipped Gear",
["FirstAid"] = "First Aid",
["Food"] = "Food",
["FoodBuffs"] = "Food Buffs",
["Gear"] = "Gear",
["Glyphs"] = "Glyphs",
["Gray"] = "Gray",  -- Used in "Gray Items"
["Health"] = "Health",
["Items"] = "Items",
["Juju"] = "Juju",
["Keys"] = "Keys",
["Mana"] = "Mana",
["Misc"] = "Misc",
["Mounts"] = "Mounts",
["MyGear"] = "My Gear",
["Other"] = "Other",
["Potions"] = "Potions",
["PotionsSlashRunes"] = "Potions/Runes",
["ProfessionBags"] = "Profession Bags",
["ProfessionCrafts"] = "Profession Crafts",
["ProfessionReagents"] = "Profession Reagents",
["Reagents"] = "Reagents",
["Recipes"] = "Recipes",
["Runes"] = "Runes",
["Scrolls"] = "Scrolls",
["Teleports"] = "Teleports",
["Tokens"] = "Tokens",
["Tools"] = "Tools",
["TradeTools"] = "Trade Tools",
["Uncategorized"] = "Uncategorized",
["WeaponBuffs"] = "Weapon Buffs",
["Weapons"] = "Weapons",

-- Category names that are different from group names.
["Category_ProfessionBags"] = "Profession Bags (Trained)",
["Category_ProfessionBagsAll"] = "Profession Bags (All)",
["Category_ProfessionCrafts"] = "Profession Crafts (Learned Recipes)",
["Category_ProfessionReagents"] = "Profession Reagents (Learned Recipes)",




-- ### Sort Orders ###

["SortOrder_Default_MinLevel"] = "Standard with Minimum Level",
["SortOrder_Default_MinLevelNameRev"] = "Standard with Minimum Level - Reversed Item Names",
["SortOrder_Default_NameRev"] = "Standard - Reversed Item Names",
["SortOrder_Default"] = "Standard",
["SortOrder_Manual"] = "Manual (Bag/Slot# Only)",




-- ### Profiles ###
["ManageProfile"] = "Manage Profiles",
-- Profile types.
["Profile_Design"] = "Design",
["Profile_Structure"] = "Structure",
["Profile_Abbrev_Design"] = "Dsgn",
["Profile_Abbrev_Structure"] = "Struct",

["Object_UsedInProfiles"] = "Used in Profiles:",
["Object_UsedByCharacters"] = "Used by characters:",
["Object_ProfileUses"] = "Profile uses:",


-- ### Object List/Manager/Editor ###

-- General.
["ObjectList_ActionNotAllowed"] = "%s is not allowed for %s.",  -- "<Creation/Editing/Deletion> is not allowed for <objectNamePlural>"
["ObjectList_ShowObjectUses"] = "Show %s Uses",
["ObjectList_ShowProfileUses"] = "Show Profile Uses",
["ObjectList_ImportSuccessful"] = "Imported %s '%s'.",  -- "Imported <objectType> '<objectName>'"
["ObjectList_ImportReusingExisting"] = "Skipping import of %s '%s' since it's identical to '%s'.",  -- "Skipping import of <objectType> '<objectName>' since it's identical to '<existingObjectName'."

-- Default column names.
["ObjectManager_Column_Name"] = "!!Name!!",
["ObjectManager_Column_InUse"] = "Used",
["ObjectManager_Column_Realm"] = "Realm",
["ObjectManager_Column_Sequence"] = "Seq.",
["ObjectManager_Column_Source"] = "Source",
["ObjectManager_Column_LastInventoryUpdate"] = "Inventory Updated",

-- The third %s after the ? is used to insert additional text if the ObjectManager's deletePromptExtraInfo property is set.
["ObjectManager_DeletePrompt"] = "Delete the following %s?%s%s!!Warning_NoUndo!!",  -- "Delete category '<category name>'?"
["ObjectManager_DeleteForPrompt"] = "Delete %s for '%s'?%s!!Warning_NoUndo!!",  -- "Delete character data for '<character name>'?"

["ObjectEditor_UnsavedPrompt"] = "Save changes to %s '%s' before closing?",   -- "Save changes to <objectType> '<objectName>' before closing?"
["ObjectEditor_RequiredField"] = "%s is required",

-- Object editor prompt when adding a new item to an item list.
["ItemList_NewPrompt"] = "Identifier(s) of item(s) to add:" .. BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "Can be IDs, ItemLinks/ItemStrings, or database URLs." .. BS_NEWLINE .. "Separate multiple by any combination of space, tab, comma, semicolon, or newline." .. FONT_COLOR_CODE_CLOSE,
["ItemList_CopyPrompt"] = "Item IDs:",



-- ### Managers and Windows ###

-- Category Manager/Editor.
["CategoryManager"] = "Bagshui Category Manager",  -- Window title.
["CategoryEditor"] = "Edit Category",  -- Window title.
["CategoryEditor_Field_name"] = "!!Name!!",
["CategoryEditor_Field_nameSort"] = "Name (Sort By)",
["CategoryEditor_Field_nameSort_TooltipText"] = "Override the Category Name used in Sort Orders without changing how its name is displayed.",
["CategoryEditor_Field_sequence"] = "Sequence",
["CategoryEditor_Field_sequence_TooltipText"] = "Control the order in which categories are evaluated." .. BS_NEWLINE .. "0 = first, 100 = last",
["CategoryEditor_Field_class"] = "Class",
["CategoryEditor_Field_rule"] = "Rule",
["CategoryEditor_Field_rule_TooltipText"] = "One or more Bagshui rule functions, combined with and/or/not keywords, optionally grouped via parentheses. See documentation for help.",
["CategoryEditor_Field_list"] = "Directly Assigned",
["CategoryEditor_Field_list_TooltipText"] = "List of items that are directly assigned to this category instead of using rule functions.",
-- Button tooltips.
["CategoryEditor_AddRuleFunction"] = "Add Rule Function",
["CategoryEditor_RuleFunctionWiki"] = "Rules Help",
["CategoryEditor_RuleValidation_Validate"] = "Validate rule",
["CategoryEditor_RuleValidation_Valid"] = "Rule is valid",
["CategoryEditor_RuleValidation_Invalid"] = "Rule validation error:",



-- Character Data Manager.
["CharacterDataManager"] = "Bagshui Character Data Manager",
["CharacterDataManager_DeleteInfo"] = "This only removes inventory data; profiles will NOT be touched.",


-- Sort Order Editor.
["SortOrderManager"] = "Bagshui Sort Order Manager",  -- Window title.
["SortOrderEditor"] = "Edit Sort Order",  -- Window title.
["SortOrderEditor_Field_name"] = "!!Name!!",
["SortOrderEditor_Field_fields"] = "Fields",
-- Button tooltips.
["SortOrderEditor_NormalWordOrder"] = "Normal Word Order",
["SortOrderEditor_ReverseWordOrder"] = "Reverse Word Order",



-- Profile Manager/Editor.
["ProfileManager"] = "Bagshui Profile Manager",  -- Window title.
["ProfileManager_ReplaceTooltipTitle"] = "Replace %s",  -- "Replace Design"
["ProfileManager_ReplaceTooltipText"] = "Copy the %s configuration from the '%s' profile to '%s'." ,  -- "Copy the Design configuration from the 'Source' profile to 'Target'."
["ProfileManager_ReplacePrompt"] = "Replace the %s configuration of the '%s' profile with that of '%s'?!!Warning_NoUndo!!",  -- "Replace the Design configuration of the 'Target' profile with that of 'Source'?"

["ProfileEditor"] = "Edit Profile",  -- Window title.
["ProfileEditor_Field_name"] = "!!Name!!",
["ProfileEditor_FooterText"] = "Profiles are edited via the Settings menu and Edit Mode.",


-- Share (Import/Export).
["ShareManager"] = "Bagshui Import/Export",
["ShareManager_ExportPrompt"] = "Press Ctrl+C to copy.",
["ShareManager_ExportEncodeCheckbox"] = "Optimize for sharing",
["ShareManager_ExportEncodeExplanation"] = "Please share the optimized (compressed/encoded) version, since it's pretty much guaranteed to survive any form of internet transmission. To review what is being shared, copy the un-optimized version into a text editor.",
["ShareManager_ImportPrompt"] = "Paste the Bagshui data you want to import using Ctrl+V.",


-- Catalog (Account-wide search).
["CatalogManager"] = "Bagshui Catalog",
["CatalogManager_SearchBoxPlaceholder"] = "Search Account-Wide Inventory",
["CatalogManager_KnownCharacters"] = "Displaying inventory from:",


-- Game Report
["GameReport"] = "Bagshui Game Environment Report",
["GameReport_Instructions"] = "Copy and paste the text below in the Environment section of your bug report.",


-- ### Rule Function Templates ###
-- See `Rules:AddRuleExamplesFromLocalization()` for details.

-- Shared values for rule function !!placeholders!! that will be replaced when the localization is loaded.
["RuleFunction_LuaStringPatternsSupported"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. 'Use Lua string patterns by "/wrapping with slashes/".' .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_PT_CaseSensitiveParameters"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "Set names are case-sensitive." .. FONT_COLOR_CODE_CLOSE,

-- DO NOT Localize rule function names (`ActiveQuest()`, `BindsOnEquip()`, etc. as they are NOT localized in the rule environment).

["RuleFunction_ActiveQuest_Example1"] = 'ActiveQuest()',
["RuleFunction_ActiveQuest_ExampleDescription1"] = "Check if the item is a quest objective in the current character's quest log.",

["RuleFunction_Bag_GenericDescription"] = "Check if the item is in the specified bag number",
["RuleFunction_Bag_ExampleDescription"] = "Check if the item is in the specified bag number (%d is container #%d in %s)",  -- "(0 is container #1 in Bags)"
["RuleFunction_Bag_ExampleExtra1"] = 'Bag(num1, num2, numN)',
["RuleFunction_Bag_ExampleDescriptionExtra1"] = "Check if the item is in any of the specified bag numbers.",

["RuleFunction_BagType_GenericDescription"] = "Check if the item is in a bag of the specified type.",
["RuleFunction_BagType_ExampleDescription"] = "Check if the item is in a bag of the type '%s'.",
["RuleFunction_BagType_ExampleExtra1"] = 'BagType(ProfessionBag)',
["RuleFunction_BagType_ExampleDescriptionExtra1"] = "Check if the item is in a bag that is specific to one of the current character's professions" .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "ProfessionBag is the special trigger for this functionality and must NOT be in quotes." .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_BagType_ExampleExtra2"] = 'BagType(AllProfessionBags)',
["RuleFunction_BagType_ExampleDescriptionExtra2"] = "Check if the item is in a bag that belongs to any profession-specific container." .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "AllProfessionBags is the special trigger for this functionality and must NOT be in quotes." .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_BagType_ExampleExtra3"] = 'BagType("type1", "type2", "typeN")',
["RuleFunction_BagType_ExampleDescriptionExtra3"] = 'Check if the item is in a bag of any of the specified types.',

["RuleFunction_BindsOnEquip_Example1"] = 'BindsOnEquip()',
["RuleFunction_BindsOnEquip_ExampleDescription1"] = string.format("Check if the item %s", string.lower(_G.ITEM_BIND_ON_EQUIP)),

["RuleFunction_CharacterLevelRange_GenericDescription"] = "Check if the item is usable based on the current character's level.",
["RuleFunction_CharacterLevelRange_Example1"] = 'CharacterLevelRange()',
["RuleFunction_CharacterLevelRange_ExampleDescription1"] = "Check if the item is usable at exactly the current character's level.",
["RuleFunction_CharacterLevelRange_Example2"] = 'CharacterLevelRange(levelsBelowOrAbove)',
["RuleFunction_CharacterLevelRange_ExampleDescription2"] = "Check if the item is usable at <levelsBelowOrAbove> the current character's level.",
["RuleFunction_CharacterLevelRange_Example3"] = 'CharacterLevelRange(levelsBelow, levelsAbove)',
["RuleFunction_CharacterLevelRange_ExampleDescription3"] = "Check if the item is usable at <below> through <above> levels around the current character's level.",

["RuleFunction_Count_GenericDescription"] = "Check if there are a specified number of items in the stack.",
["RuleFunction_Count_Example1"] = 'Count(number)',
["RuleFunction_Count_ExampleDescription1"] = "Check if there are at least <number> of the item in the stack.",
["RuleFunction_Count_Example2"] = 'Count(min, max)',
["RuleFunction_Count_ExampleDescription2"] = "Check if there are <min> to <max> of the item in the stack.",

["RuleFunction_EmptySlot_Example1"] = 'EmptySlot()',
["RuleFunction_EmptySlot_ExampleDescription1"] = "Check if there is NOT an item in the bag slot.",

["RuleFunction_EquipLocation_GenericDescription"] = "Check if the item can be equipped in the specified slot.",
["RuleFunction_EquipLocation_ExampleDescription"] = "Check if the item can be equipped in the %s slot.",
["RuleFunction_EquipLocation_ExampleExtra1"] = 'EquipLocation()',
["RuleFunction_EquipLocation_ExampleDescriptionExtra1"] = "Check if the item is equippable.",
["RuleFunction_EquipLocation_ExampleExtra2"] = 'EquipLocation("Slot1", "Slot2", "SlotN")',
["RuleFunction_EquipLocation_ExampleDescriptionExtra2"] = "Check if the item can be equipped in any of the specified slots.",

["RuleFunction_Equipped_Example1"] = 'Equipped()',
["RuleFunction_Equipped_ExampleDescription1"] = "Check if the item has been equipped (useful to match gear that is not soulbound)." .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "You can also pass the same parameters as EquipLocation() to only match a specific inventory slot." .. FONT_COLOR_CODE_CLOSE,

["RuleFunction_Id_GenericDescription"] = 'Check if the item ID is an exact match.',
["RuleFunction_Id_Example1"] = 'Id(number)',
["RuleFunction_Id_ExampleDescription1"] = "Check if the item ID is an exact match.",
["RuleFunction_Id_ExampleExtra1"] = 'Id(id1, id2, idN)',
["RuleFunction_Id_ExampleDescriptionExtra1"] = "Check if the item ID matches any of the specified parameters.",

["RuleFunction_ItemString_GenericDescription"] = "Check if the item string matches (use to match specific enchant or suffix IDs).",
["RuleFunction_ItemString_Example1"] = 'ItemString(number)',
["RuleFunction_ItemString_ExampleDescription1"] = RED_FONT_COLOR_CODE .. "Use Id(itemId) instead." .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. "Check if the item string begins with 'item:<itemId>:'",
["RuleFunction_ItemString_Example2"] = 'ItemString("item:number")',
["RuleFunction_ItemString_ExampleDescription2"] = RED_FONT_COLOR_CODE .. "Use Id(itemId) instead." .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. "Check if the item string begins with 'item:<itemId>:' (the item: prefix is optional).",
["RuleFunction_ItemString_Example3"] = 'ItemString("item:number:number")',
["RuleFunction_ItemString_ExampleDescription3"] = "Check if the item string begins with 'item:<itemId>:<enchantId>:' (the item: prefix is optional).",
["RuleFunction_ItemString_Example4"] = 'ItemString("item:number:number:number")',
["RuleFunction_ItemString_ExampleDescription4"] = "Check if the item string begins with 'item:<itemId>:<enchantId>:<suffixId>:' (the item: prefix is optional).",
["RuleFunction_ItemString_ExampleExtra1"] = 'ItemString(param1, param2, paramN)',
["RuleFunction_ItemString_ExampleDescriptionExtra1"] = 'Check if the item string matches any of the specified parameters.',

["RuleFunction_Location_GenericDescription"] = "Check if the item is stored in a specific location (Bags, Bank, etc.)",
["RuleFunction_Location_ExampleDescription"] = "Check if the item is in your %s",
["RuleFunction_Location_ExampleExtra1"] = 'Location("loc1", "loc2", "locN")',
["RuleFunction_Location_ExampleDescriptionExtra1"] = "Check if the item is stored in any of the specified locations.",

["RuleFunction_MinLevel_GenericDescription"] = "Check if the item is usable based on the specified level.",
["RuleFunction_MinLevel_Example1"] = 'MinLevel(level)',
["RuleFunction_MinLevel_ExampleDescription1"] = "Check if the item is usable at <level> or above.",
["RuleFunction_MinLevel_Example2"] = 'MinLevel(min, max)',
["RuleFunction_MinLevel_ExampleDescription2"] = "Check if the item is usable at <min> to <max> level.",

["RuleFunction_Name_GenericDescription"] = "Check if the item name contains the specified string(s).!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Name_Example1"] = 'Name("string")',
["RuleFunction_Name_ExampleDescription1"] = "Check if the item name contains the specified string.!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Name_ExampleExtra1"] = 'Name("string1", "string2", "stringN")',
["RuleFunction_Name_ExampleDescriptionExtra1"] = "Check if the item name contains any of the specified strings.!!RuleFunction_LuaStringPatternsSupported!!",

["RuleFunction_NameExact_GenericDescription"] = "Check if the item name exactly matches the specified string(s).",
["RuleFunction_NameExact_Example1"] = 'NameExact("string")',
["RuleFunction_NameExact_ExampleDescription1"] = "Check if the item name exactly matches the specified string.",
["RuleFunction_NameExact_ExampleExtra1"] = 'NameExact("string1", "string2", "stringN")',
["RuleFunction_NameExact_ExampleDescriptionExtra1"] = "Check if the item name exactly matches any of the specified strings.",

["RuleFunction_Outfit_GenericDescription"] = "Check if the item is part of an outfit in %s.",
["RuleFunction_Outfit_Example1"] = 'Outfit()',
["RuleFunction_Outfit_ExampleDescription1"] = "Check if the item is part of an outfit in %s.",
["RuleFunction_Outfit_Example2"] = 'Outfit("Outfit Name")',
["RuleFunction_Outfit_ExampleDescription2"] = "Check if the item is part of the specified outfit in %s.",
["RuleFunction_Outfit_ExampleExtra1"] = 'Outfit("outfit1", "outfit2", "outfitN")',
["RuleFunction_Outfit_ExampleDescriptionExtra1"] = "Check if the item is part of any of the specified outfits in %s.",

["RuleFunction_PeriodicTable_GenericDescription"] = "Check if the item belongs to a PeriodicTable set.!!RuleFunction_PT_CaseSensitiveParameters!!",
["RuleFunction_PeriodicTable_ExampleDescription"] = "Check if the item belongs to the '%s' PeriodicTable set.!!RuleFunction_PT_CaseSensitiveParameters!!",
["RuleFunction_PeriodicTable_ExampleExtra1"] = 'PeriodicTable("set1", "set2", "setN")',
["RuleFunction_PeriodicTable_ExampleDescriptionExtra1"] = "Check if the item belongs to any of the specified PeriodicTable sets.!!RuleFunction_PT_CaseSensitiveParameters!!",

["RuleFunction_ProfessionCraft_GenericDescription"] = "Check if the item is crafted by the current character's professions (learned recipes only).",
["RuleFunction_ProfessionCraft_Example1"] = 'ProfessionCraft()',
["RuleFunction_ProfessionCraft_ExampleDescription1"] = "Check if the item is crafted by any of the current character's professions (learned recipes only).",
["RuleFunction_ProfessionCraft_Example2"] = 'ProfessionCraft("Profession Name")',
["RuleFunction_ProfessionCraft_ExampleDescription2"] = "Check if the item is crafted by the current character's specified profession (learned recipes only).",
["RuleFunction_ProfessionCraft_ExampleExtra1"] = 'ProfessionCraft("Profession1", "Profession2", "ProfessionN")',
["RuleFunction_ProfessionCraft_ExampleDescriptionExtra1"] = "Check if the item is crafted by any of the current character's specified professions (learned recipes only).",

["RuleFunction_ProfessionReagent_GenericDescription"] = "Check if the item is a reagent for the current character's profession crafts (learned recipes only).",
["RuleFunction_ProfessionReagent_Example1"] = 'ProfessionReagent()',
["RuleFunction_ProfessionReagent_ExampleDescription1"] = "Check if the item is a reagent for any of the current character's profession crafts (learned recipes only).",
["RuleFunction_ProfessionReagent_Example2"] = 'ProfessionReagent("Profession Name")',
["RuleFunction_ProfessionReagent_ExampleDescription2"] = "Check if the item is a reagent for the current character's specified profession (learned recipes only).",
["RuleFunction_ProfessionReagent_ExampleExtra1"] = 'ProfessionReagent("Profession1", "Profession2", "ProfessionN")',
["RuleFunction_ProfessionReagent_ExampleDescriptionExtra1"] = "Check if the item is a reagent for any of the current character's specified professions (learned recipes only).",

["RuleFunction_Quality_GenericDescription"] = "Check if the item is of the specified quality.",
["RuleFunction_Quality_ExampleDescription"] = "Check if the item is %s quality.",
["RuleFunction_Quality_ExampleExtra1"] = 'Quality(qual1, qual2, qualN)',
["RuleFunction_Quality_ExampleDescriptionExtra1"] = "Check if the item is of any of the specified qualities.",

["RuleFunction_RequiresClass_GenericDescription"] = "Check if the item is usable by the specified class.",
["RuleFunction_RequiresClass_ExampleDescription"] = "Check if the item is usable by the %s class.",
["RuleFunction_RequiresClass_ExampleExtra1"] = 'RequiresClass("class1", "class2", "classN")',
["RuleFunction_RequiresClass_ExampleDescriptionExtra1"] = "Check if the item is usable by the any of the specified classes.",

["RuleFunction_Soulbound_Example1"] = 'Soulbound()',
["RuleFunction_Soulbound_ExampleDescription1"] = "Check if the item is soulbound.",

["RuleFunction_Stacks_Example1"] = 'Stacks()',
["RuleFunction_Stacks_ExampleDescription1"] = "Check if the item can be stacked.",

["RuleFunction_Subtype_GenericDescription"] = "Check the item is of the specified subtype",
["RuleFunction_Subtype_ExampleDescription"] = "Check if the item's subtype is '%s'.",
["RuleFunction_Subtype_ExampleExtra1"] = 'Subtype("type1", "type2", "typeN")',
["RuleFunction_Subtype_ExampleDescriptionExtra1"] = "Check the item is of any of the the specified subtypes.",

["RuleFunction_Tooltip_GenericDescription"] = "Check if the tooltip contains the specified string(s).!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Tooltip_Example1"] = 'Tooltip("string")',
["RuleFunction_Tooltip_ExampleDescription1"] = "Check if the item tooltip contains the specified string.!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Tooltip_ExampleExtra1"] = 'Tooltip("string1", "string2", "stringN")',
["RuleFunction_Tooltip_ExampleDescriptionExtra1"] = "Check if the tooltip contains any of the specified strings.!!RuleFunction_LuaStringPatternsSupported!!",

["RuleFunction_Transmog_GenericDescription"] = "Check if the item is in your transmog collection or is eligible to be transmogged.",
["RuleFunction_Transmog_Example1"] = 'Transmog()',
["RuleFunction_Transmog_ExampleDescription1"] = 'Check if the item is in your transmog collection.',
["RuleFunction_Transmog_Example2"] = 'Transmog(Eligible)',
["RuleFunction_Transmog_ExampleDescription2"] = 'Check if the item eligible to be transmogged.',
["RuleFunction_Transmog_Example3"] = 'Transmog(Eligible) and not Transmog()',
["RuleFunction_Transmog_ExampleDescription3"] = 'Check if the item is transmoggable but has not yet been added to your collection.',

["RuleFunction_Type_GenericDescription"] = "Check if the item is of the specified type.",
["RuleFunction_Type_ExampleDescription"] = "Check if the item's type is '%s'.",
["RuleFunction_Type_ExampleExtra1"] = 'Type("type1", "type2", "typeN")',
["RuleFunction_Type_ExampleDescriptionExtra1"] = "Check the item is of any of the the specified types.",

["RuleFunction_Usable_Example1"] = 'Usable()',
["RuleFunction_Usable_ExampleDescription1"] = "Check if the item is usable by the current character based on level, skills, and professions.",

["RuleFunction_Wishlist_Example1"] = 'Wishlist()',
["RuleFunction_Wishlist_ExampleDescription1"] = "Check if the item is on the %s wishlist.",


-- ### Tips/Help ###
["BagshuiTooltipIntro"] = "Show Bagshui Info Tooltip",


-- ### Errors/Warnings ###

["Error"] = "Error",
["Error_AddonDependency_Generic"] = "An additional addon is required to enable this rule function (refer to the Rules page on the Bagshui wiki).",
["Error_AddonDependency_Generic_FunctionName"] = "An additional addon is required to enable the use of %s (refer to the Rules page on the Bagshui wiki).",
["Error_AddonDependency"] = "%s is not installed or enabled.",
["Error_CategoryEvaluation"] = "%s: %s",  -- "<Category Name>: <Error Message>"
["Error_DuplicateName"] = "There is already a %s named %s.",  -- "There is already a <Object Type> named <Name>."
["Error_GroupNotFound"] = "Group ID %s not found.",
["Error_HearthstoneNotFound"] = "Hearthstone not found.",
["Error_ImportInvalidFormat"] = "Import failed: Data was in an unexpected format.`",
["Error_ImportVersionTooNew"] = "Import failed: Please upgrade to the latest version of Bagshui.",
["Error_ItemCategoryUnknown"] = "!Unknown! (This shouldn't happen).",  -- Placed in the tooltip if the item doesn't have a category.
["Error_RestackFailed"] = "Failed to restack %s",
["Error_SaveFailed"] = "%s could not be saved: %s",
["Error_Suffix_Retrying"] = "%s; retrying…",  -- Appended to the end of an error message when an action has failed but is being attempted again.

["Info_NoDelete"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "Does NOT delete the category." .. FONT_COLOR_CODE_CLOSE,

["Warning_NoUndo"] = BS_NEWLINE .. RED_FONT_COLOR_CODE .. "This cannot be undone!" .. FONT_COLOR_CODE_CLOSE,
["Warning_RuleFunctionOverwrite"] = "Overwriting existing rule environment function %s()",
["Warning_BuiltinRuleFunctionCollision"] = "3rd party rule function/alias %s() was not loaded because it is the name/alias of a built-in Bagshui rule function",

["Compat_ReloadUIPrompt"] = "A UI reload is required.",
["Compat_pfUIBags"] = "Disabling the pfUI Bags module is strongly recommended to avoid multiple Bank windows.",
["Compat_pfUIBagsInfo"] = "If you change your mind, the pfUI Bags module can be managed in pfUI Config > Components > Modules.",
["Compat_tDFAllInOneBags"] = "Disabling the tDF All-In-One-Bag module is recommended if you want to use Bagshui as your default bags.",
["Compat_tDFAllInOneBagsInfo"] = "If you change your mind, the tDF All-In-One-Bag module can be managed in tDF Options.",

-- Rule function errors.
["Error_RuleFunctionInvalid"] = '«%s» is not a valid rule function -- if intended as a parameter, be sure to quote it like Function("parameter")',
["Error_RuleVariablePropertyInvalid"] = "«%s» is not a valid %s property",
["Error_RuleExecution"] = "Error from rule function %s: %s",
["Error_RuleNoArguments"] = "At least one parameter is required but none were provided",
["Error_RuleNilArgument"] = "Invalid parameter %s: nil is not allowed",
["Error_RuleInvalidArgument"] = "Invalid parameter %s: «%s» is a %s, was expecting %s",
["Error_RuleInvalidArgumentType"] = "%s is not a valid parameter type; allowed parameter types are: %s",
["Error_RuleTooManyArguments"] = "Rule functions are limited to 50 parameters. To use more parameters, add a second call to %s separated by 'or', like this: or %s(param1, param2, etc)",

["Error_Rule_ItemLevelStat"] = "Vanilla WoW doesn't have item levels (ilvl) so ItemLevelStat() is not available.",
["Error_Rule_ItemStat"] = "ItemStat() and ItemStatActive() are not currently supported. Try using Tooltip() to check for stats instead.",

-- ### Logging ###

["LogWindowTitle"] = "Bagshui Log",
["ClearLog"] = "Clear Log",
-- Log types.
["Log_Info"] = "Info",
["Log_Warn"] = "Warn",
["Log_Error"] = "Error",

-- Settings reset messages.
["SettingReset_LogStart"] = "%s reset",
["SettingReset_InvalidValue"] = "invalid value",
["SettingReset_Outdated"] = "outdated",

["SettingReset_WindowPositionAuto"] = "Window position reset because it was offscreen.",
["SettingReset_WindowPositionManual"] = "Window position reset.",




-- ### Help/Misc ###

["BagshuiDataReset"] = "Configuration was reset due to version change (previous: %s / new: %s).",
["HowToUrl"] = "WoW can't open a URL directly, so copy this URL (Ctrl+C) and navigate in your web browser.",


-- ### Settings: Tooltips, Scopes, Special ###

-- Automatically generated settings.
["Setting_HookBagTooltipTitle"] = "Hook %s",
["Setting_HookBagTooltipText"] = "Take over the key binding for Toggle %s.",
-- Special settings stuff.
["SettingScope_Account"] = "Applies to all characters on this account.",
["SettingScope_Character"] = "Applies to all of this character's inventory windows.",
["Setting_DisabledBy_HideGroupLabels"] = "× Disabled because the active Structure has Hide Group Labels enabled.",
["Setting_EnabledBy_ColorblindMode"] = "√ Enabled because Colorblind Mode is on.",
["Setting_Profile_SetAllHint"] = "Shift+Click to use for all profile types.",
["Setting_Reset_TooltipText"] = "Reset to default: Ctrl+Alt+Shift+Click.",
["Setting_Profile_Use"] = "Make this the active %s %s profile.",  -- Make this the active Bags Design profile.


-- ### Settings ###
-- Keys are settingName, settingName_TooltipTitle, or settingName_TooltipText.
-- See localization notes in the declaration of `Settings:InitSettingsInfo()` for more information.

["aboutBagshui_TooltipTitle"] = "About Bagshui",

["colorblindMode"] = "Colorblind Mode",
["colorblindMode_TooltipText"] = "Always show item quality and unusable badges regardless of Design settings.",

["createNewProfileDesign"] = "Copy",
["createNewProfileDesign_TooltipTitle"] = "Create Design Profile Copy",
["createNewProfileDesign_TooltipText"] = "Duplicate the default profile for new characters.",

["createNewProfileStructure"] = "Copy",
["createNewProfileStructure_TooltipTitle"] = "Create Structure Profile Copy",
["createNewProfileStructure_TooltipText"] = "Duplicate the default profile for new characters.",

["defaultSortOrder"] = "Sort Order",
["defaultSortOrder_TooltipTitle"] = "Default Sort Order",
["defaultSortOrder_TooltipText"] = "How groups will be sorted when they don't have a specific sort order assigned.",

["defaultProfileDesign"] = "Design",
["defaultProfileDesign_TooltipTitle"] = "Default Design Profile",
["defaultProfileDesign_TooltipText"] = "Profile to use for new characters.",

["defaultProfileStructure"] = "Structure",
["defaultProfileStructure_TooltipTitle"] = "Default Structure Profile",
["defaultProfileStructure_TooltipText"] = "Profile to use for new characters.",

["disableAutomaticResort"] = "Manual Reorganization",
["disableAutomaticResort_TooltipText"] = "Don't categorize and sort items when the inventory window is closed and reopened." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "This is NOT the same as setting the default sort order to Manual." .. FONT_COLOR_CODE_CLOSE,

["windowDoubleClickActions"] = "Double-Click",
["windowDoubleClickActions_TooltipText"] = "Double-click a blank part of the inventory window to show/hide all toolbars." .. BS_NEWLINE .. "Alt+double-click to toggle position lock.",

["globalInfoTooltips"] = "Everywhere",
["globalInfoTooltips_TooltipTitle"] = "Hook All Item Tooltips ",
["globalInfoTooltips_TooltipText"] = "Show Bagshui Info Tooltip with Catalog counts when Alt is held anywhere (i.e. Character window, chat links, etc.).",

["groupBackgroundDefault"] = "Background",
["groupBackgroundDefault_TooltipTitle"] = "Default Group Background Color",
["groupBackgroundDefault_TooltipText"] = "Background color to use when a group-specific color has not been set.",

["groupBorderDefault"] = "Border",
["groupBorderDefault_TooltipTitle"] = "Default Group Border Color",
["groupBorderDefault_TooltipText"] = "Border color to use when a group-specific color has not been set.",

["groupLabelDefault"] = "Labels",
["groupLabelDefault_TooltipTitle"] = "Default Group Label Color",
["groupLabelDefault_TooltipText"] = "Label color to use when a group-specific color has not been set.",

["groupMargin"] = "Margin",
["groupMargin_TooltipTitle"] = "Group Margin",
["groupMargin_TooltipText"] = "Space between groups.",

["groupPadding"] = "Padding",
["groupPadding_TooltipTitle"] = "Group Padding",
["groupPadding_TooltipText"] = "Space between group border and items within.",

["groupUseSkinColors"] = "Use %s Colors",
["groupUseSkinColors_TooltipTitle"] = "%s Colors for Groups",
["groupUseSkinColors_TooltipText"] = "Use colors from %s instead of Bagshui's settings.",

["hideGroupLabelsOverride"] = "Hide Group Labels",
["hideGroupLabelsOverride_TooltipText"] = "Suppress the display of group labels, even if the Design Group Labels setting is enabled.",

["itemMargin"] = "Margin",
["itemMargin_TooltipTitle"] = "Item Margin",
["itemMargin_TooltipText"] = "Space between items.",

["itemActiveQuestBadges"] = "Active Quest",
["itemActiveQuestBadges_TooltipTitle"] = "Item Slot Active Quest Badges",
["itemActiveQuestBadges_TooltipText"] = "Show a ? in the top when the item is an objective of an active quest.",

["itemQualityBadges"] = "!!Quality!!",
["itemQualityBadges_TooltipTitle"] = "Item Quality Badges",
["itemQualityBadges_TooltipText"] = "Show icons in the bottom left for item rarity levels.",

["itemUsableBadges"] = "Unusable",
["itemUsableBadges_TooltipTitle"] = "Item Unusable Badges",
["itemUsableBadges_TooltipText"] = "Show icons in the top left for unusable/learned items.",

["itemUsableColors"] = "Unusable",
["itemUsableColors_TooltipTitle"] = "Item Unusable Tinting",
["itemUsableColors_TooltipText"] = "Apply red/green overlay for unusable/learned items.",

["itemSize"] = "Size",
["itemSize_TooltipTitle"] = "Item Size",
["itemSize_TooltipText"] = "Height and width of items.",

["itemStockBadges"] = "Stock",
["itemStockBadges_TooltipTitle"] = "Item Stock Badges",
["itemStockBadges_TooltipText"] = "Indicate when items are new or quantities increase/decrease.",

["itemStockChangeClearOnInteract"] = "Clear on Click",
["itemStockChangeClearOnInteract_TooltipTitle"] = "Clear Item Stock Badge On Click",
["itemStockChangeClearOnInteract_TooltipText"] = "Immediately reset the item stock change state (new/increased/decreased) upon interaction.",

["itemStockChangeExpiration"] = "Expiration",
["itemStockChangeExpiration_TooltipTitle"] = "Item Stock Badge Change Expiration",
["itemStockChangeExpiration_TooltipText"] = "After this time has elapsed, an item will no longer be considered changed (new/increased/decreased).",

["itemStockBadgeFadeDuration"] = "Fade",
["itemStockBadgeFadeDuration_TooltipTitle"] = "Item Stock Badge Fade Duration",
["itemStockBadgeFadeDuration_TooltipText"] = "Stock change badges (new/increased/decreased) will begin fading this amount of time prior to the Expiration setting.",

["profileDesign"] = "Profile",
["profileDesign_TooltipTitle"] = "Design Profile",
["profileDesign_TooltipText"] = "Profile to use for Design (how the inventory looks).",

["profileStructure"] = "Profile",
["profileStructure_TooltipTitle"] = "Structure Profile",
["profileStructure_TooltipText"] = "Profile to use for Structure (how the inventory is organized).",

["replaceBank"] = "Replace Bank",
["replaceBank_TooltipText"] = "Use the Bagshui Bank instead of the Blizzard Bank.",

["resetStockState"] = "Mark Items Unchanged",
["resetStockState_TooltipText"] = "Set all items in this inventory as no longer new, increased, or decreased.",

["showBagBar"] = "Bag Bar",
["showBagBar_TooltipText"] = "Show the bag bar in the bottom left.",

["showFooter"] = "Bottom Toolbar",
["showFooter_TooltipTitle"] = "Bottom Toolbar",
["showFooter_TooltipText"] = "Show the bottom toolbar." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "Hiding this will conceal everything below the items, including the Bag Bar and money display." .. FONT_COLOR_CODE_CLOSE,

["showGroupLabels"] = "Labels",
["showGroupLabels_TooltipTitle"] = "Group Labels",
["showGroupLabels_TooltipText"] = "Show labels above groups.",

["showHeader"] = "Top Toolbar",
["showHeader_TooltipTitle"] = "Top Toolbar",
["showHeader_TooltipText"] = "Show the top toolbar." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "Hiding this will conceal everything above the items, including the Close button, so you'll need to close via key bindings, action bar buttons, or macros." .. FONT_COLOR_CODE_CLOSE,

["showHearthstone"] = "Hearthstone Button",
["showHearthstone_TooltipText"] = "Show the hearthstone button." .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "Applies to Bags only." .. FONT_COLOR_CODE_CLOSE,

["showInfoTooltipsWithoutAlt"] = "Show Without Alt",
["showInfoTooltipsWithoutAlt_TooltipText"] = "Always display the Bagshui Info Tooltip (hold Shift to temporarily hide it).",

["showLogWindow_TooltipText"] = "Open the Bagshui log window.",

["showMoney"] = "Money",
["showMoney_TooltipText"] = "Display money in the bottom right.",

["stackEmptySlots"] = "Stack Empty",
["stackEmptySlots_TooltipTitle"] = "Stack Empty Slots",
["stackEmptySlots_TooltipText"] = "Combine empty slots into single stacks that can be expanded on click (profession bags will stack separately).",

["toolbarButtonColor"] = "Icons",
["toolbarButtonColor_TooltipTitle"] = "Toolbar Icon Color",
["toolbarButtonColor_TooltipText"] = "Color to use for this inventory's toolbar icons.",

["toggleBagsWithAuctionHouse"] = "Auction House",
["toggleBagsWithAuctionHouse_TooltipTitle"] = "Toggle Bags with Auction House",
["toggleBagsWithAuctionHouse_TooltipText"] = "Open and close Bags when you visit the Auction House.",

["toggleBagsWithBankFrame"] = "Bank",
["toggleBagsWithBankFrame_TooltipTitle"] = "Toggle Bags with Bank",
["toggleBagsWithBankFrame_TooltipText"] = "Open and close Bags when you visit the Bank.",

["toggleBagsWithMailFrame"] = "Mail",
["toggleBagsWithMailFrame_TooltipTitle"] = "Toggle Bags with Mail",
["toggleBagsWithMailFrame_TooltipText"] = "Open and close Bags when you use a mailbox.",

["toggleBagsWithTradeFrame"] = "Trade",
["toggleBagsWithTradeFrame_TooltipTitle"] = "Toggle Bags with Trade",
["toggleBagsWithTradeFrame_TooltipText"] = "Open and close Bags when trading with another player.",

["windowAnchorXPoint"] = "Horizontal",
["windowAnchorXPoint_TooltipTitle"] = "Horizontal Anchor",
["windowAnchorXPoint_TooltipText"] = "Window will grow horizontally from this edge of the screen.",

["windowAnchorYPoint"] = "Vertical",
["windowAnchorYPoint_TooltipTitle"] = "Vertical Anchor",
["windowAnchorYPoint_TooltipText"] = "Window will grow vertically from this edge of the screen.",

["windowBackground"] = "Background",
["windowBackground_TooltipTitle"] = "Window Background Color",
["windowBackground_TooltipText"] = "Color to use for this inventory window's background.",

["windowBorder"] = "Border",
["windowBorder_TooltipTitle"] = "Window Border Color",
["windowBorder_TooltipText"] = "Color to use for this inventory window's border.",

["windowLocked"] = "Lock Position",
["windowLocked_TooltipText"] = "Don't allow this window to be moved.",

["windowMaxColumns"] = "Maximum Columns",
["windowMaxColumns_TooltipText"] = "Window width limit in number of items per row.",

["windowScale"] = "Scale",
["windowScale_TooltipTitle"] = "Window Scale",
["windowScale_TooltipText"] = "Relative size of entire window.",

["windowUseSkinColors"] = "Use %s Colors",
["windowUseSkinColors_TooltipTitle"] = "%s Colors for Window",
["windowUseSkinColors_TooltipText"] = "Use colors from %s instead of Bagshui's settings.",


})


end)