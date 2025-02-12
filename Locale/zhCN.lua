Bagshui:LoadComponent(function()

BsLocalization:AddLocale("zhCN", {

-- ### Game Stuff ###

-- Player classes.
["Druid"] = "德鲁伊",
["Hunter"] = "猎人",
["Mage"] = "法师",
["Paladin"] = "圣骑士",
["Priest"] = "牧师",
["Rogue"] = "盗贼",
["Shaman"] = "萨满祭司",
["Warlock"] = "术士",
["Warrior"] = "战士",

-- Item classes and subclasses that can't be automatically localized because they're not
-- returned from `GetAuctionItemClasses()` / `GetAuctionItemSubClasses()`.
["Devices"] = "装置",
["Explosives"] = "炸药",
["Junk"] = "垃圾",
["Key"] = "钥匙",
["Miscellaneous"] = "杂物",
["Parts"] = "零件",
["Quest"] = "任务物品",
["Trade Goods"] = "交易物品",

-- Skill types.
-- Must cover all keys in `LOCALIZED_TO_EN_SKILL_ID` and `IGNORE_SKILL_CATEGORY`.
["Class Skills"] = "职业技能",
["Professions"] = "专业技能",
["Secondary Skills"] = "辅助技能",
["Weapon Skills"] = "武器技能",
["Armor Proficiencies"] = "护甲精通",
["Languages"] = "语言",

-- Skills.
-- Must cover any skill that the game can return from `GetSkillLineInfo()`.
["Axes"] = "斧类武器",
["Dual Wield"] = "双持",
["Fishing"] = "钓鱼",
["Maces"] = "锤类武器",
["Swords"] = "剑类武器",
["Plate Mail"] = "板甲",
["Shield"] = "盾牌",

-- Professions that have their own bag types.
-- Referenced in GameInfo.lua to build the `professionsToBags` table.
["Enchanting"] = "附魔",
["Herbalism"] = "草药学",




-- ### General ###

["AbandonChanges"] = "放弃更改",
["About"] = "关于",
["Actions"] = "操作",
["Add"] = "添加",
["AddSlashRemove"] = "添加/移除",
["Aliases"] = "别名",
["AltClick"] = "Alt + 点击",
["AltRightClick"] = "Alt + 右键点击",
["Ascending"] = "升序",
["Available"] = "可用",
["Background"] = "背景",
["Bag"] = "背包",
["Border"] = "边框",
["Bottom"] = "底部",
["Cancel"] = "取消",
["Catalog"] = "目录",
["Categories"] = "类别",
["Category"] = "类别",
["CharacterData"] = "角色数据",
["CategorySlashItem"] = "类别/物品",
["ClassCategory"] = "职业类别",
["Clear"] = "清除",
["Click"] = "点击",
["Close"] = "关闭",
["Color"] = "颜色",
["Column"] = "列",
["Copy"] = "复制",
["Create"] = "创建",
["Creation"] = "创建",
["Custom"] = "自定义",
["Default"] = "默认",
["Delete"] = "删除",
["Deletion"] = "删除",
["Descending"] = "降序",
["Details"] = "详情",
["Dialog"] = "对话框",
["Disable"] = "禁用",
["Duplicate"] = "复制",
["Edit"] = "编辑",
["Editing"] = "编辑中",
["EmptyBagSlot"] = "空背包栏位",
["Export"] = "导出",
["Full"] = "已满",
["Group"] = "组",
["Help"] = "帮助",
["Hidden"] = "隐藏",
["Hide"] = "隐藏",  -- 动词，与 show 相反
["HoldAlt"] = "按住 Alt",
["HoldControlAlt"] = "按住 Control + Alt",
["Horizontal"] = "水平",
["Ignore"] = "忽略",
["Import"] = "导入",
["ImportSlashExport"] = "导入/导出",
["Info"] = "信息",
["Information"] = "信息",
["Inventory"] = "背包",
["Item"] = "物品",
["ItemProperties"] = "物品属性",
["KeepEditing"] = "继续编辑",
["Label"] = "标签",
["Left"] = "左边",
["Location"] = "位置",
["Lock"] = "锁定",
["LogWindow"] = "日志窗口",
["Manage"] = "管理",
["Menu"] = "菜单",
["MoreInformation"] = "更多信息",
["Move"] = "移动",
["MoveDown"] = "向下移动",
["MoveUp"] = "向上移动",
["Name"] = "名称",
["New"] = "新建",
["No"] = "否",
["NotNow"] = "稍后再说",
["NoItemsAvailable"] = "(无可用物品)",
["NoneAssigned"] = "(未分配)",
["NoneParenthesis"] = "(无)",
["NoRuleFunction"] = "(无规则函数)",
["NoValue"] = "(无值)",
["Open"] = "打开",
["PleaseWait"] = "请稍候...",
["Profile"] = "配置文件",
["Prefix_Add"] = "添加 %s",
["Prefix_Bag"] = "背包 %s",
["Prefix_Class"] = "职业 %s",
["Prefix_ClickFor"] = "点击查看 %s",
["Prefix_Default"] = "默认 %s",
["Prefix_Edit"] = "编辑 %s",
["Prefix_Manage"] = "管理 %s",
["Prefix_Move"] = "移动 %s",
["Prefix_New"] = "新建 %s",
["Prefix_OpenMenuFor"] = "打开 %s 菜单",
["Prefix_Remove"] = "移除 %s",
["Prefix_Search"] = "搜索 %s",
["Prefix_Sort"] = "排序 %s",
["Prefix_Target"] = "目标 %s",
["Prefix_Toggle"] = "切换 %s",
["Prefix_Unnamed"] = "(未命名 %s)",
["Profiles"] = "配置文件",
["Quality"] = "品质",
["ReleaseAlt"] = "松开 Alt",
["Reload"] = "重新加载",
["Remove"] = "移除",
["Rename"] = "重命名",
["Replace"] = "替换",
["Report"] = "报告",
["ResetPosition"] = "重置位置",
["Right"] = "右边",
["RightClick"] = "右键点击",
["Row"] = "行",
["Save"] = "保存",
["Search"] = "搜索",
["Settings"] = "设置",
["Share"] = "分享",
["Show"] = "显示",
["SortOrder"] = "排序顺序",
["SortOrders"] = "排序顺序",
["Sorting"] = "排序",
["Stack"] = "堆叠",  -- 动词
["Suffix_Default"] = "%s ".. LIGHTYELLOW_FONT_COLOR_CODE.. " [默认]".. FONT_COLOR_CODE_CLOSE,
["Suffix_EmptySlot"] = "%s 空栏位",
["Suffix_Menu"] = "%s 菜单",
["Suffix_ReadOnly"] = "%s ".. LIGHTYELLOW_FONT_COLOR_CODE.. "[只读]".. FONT_COLOR_CODE_CLOSE,
["Suffix_Reversed"] = "%s [反转]",  -- 用于在解释排序顺序时，当某个字段被反转（即名称 [反转]）
["Suffix_Sets"] = "%d 套",
["Symbol_Brackets"] = "[%s]",
["Symbol_Colon"] = "%s:",
["Symbol_Ellipsis"] = "%s…",  -- 用于菜单中，表示点击将打开另一个对话框或菜单
["Templates"] = "模板",
["Text"] = "文本",
["Toggle"] = "切换",  -- 动词
["Top"] = "顶部",
["Total"] = "总计",
["Undo"] = "撤销",
["Unknown"] = "未知",
["Unlock"] = "解锁",
["Unnamed"] = "(未命名)",
["Unstack"] = "拆分堆叠",  -- 动词
["Used"] = "已使用",
["UseDefault"] = "使用默认值",
["Validate"] = "验证",
["Vertical"] = "垂直",
["VersionNumber"] = "版本 %s",
["Yes"] = "是",

-- Inventory types.
["Bags"] = "背包",
["Bank"] = "银行",
["Equipped"] = "已装备",
["Keyring"] = "钥匙链",

-- Abbreviations for tooltip use.
["Abbrev_Bags"] = "背包",
["Abbrev_Bank"] = "银行",
["Abbrev_Keyring"] = "钥匙",
["Abbrev_Equipped"] = "装备",

-- Slash command help message.
["Slash_Help"] = "%s 命令:",
["Slash_Help_Postscript"] = "如需子命令列表，请在命令后附加 Help。",

-- Key bindings (other than Inventory class names; those are handled in `Inventory:New()`).
["Binding_Resort"] = "整理全部",
["Binding_Restack"] = "全部重新堆叠",

-- Item properties to friendly names as `ItemPropFriendly_<propertyName>`.
-- Anything non-private in `BS_ITEM_SKELETON` or `BS_REALTIME_ITEM_INFO_PROPERTIES` must be present.
["ItemPropFriendly_activeQuest"] = "活跃任务物品",
["ItemPropFriendly_baseName"] = "基础名称",
["ItemPropFriendly_bagNum"] = "背包编号",
["ItemPropFriendly_bagType"] = "背包类型",
["ItemPropFriendly_bindsOnEquip"] = "装备后绑定",
["ItemPropFriendly_charges"] = "充能次数",
["ItemPropFriendly_count"] = "数量",
["ItemPropFriendly_equipLocation"] = "装备位置",
["ItemPropFriendly_equipLocationLocalized"] = "装备位置（本地化）",
["ItemPropFriendly_emptySlot"] = "空栏位",
["ItemPropFriendly_id"] = "物品ID",
["ItemPropFriendly_itemLink"] = "物品链接",
["ItemPropFriendly_itemString"] = "物品字符串",
["ItemPropFriendly_locked"] = "锁定",
["ItemPropFriendly_maxStackCount"] = "最大堆叠数量",
["ItemPropFriendly_minLevel"] = "最低等级",
["ItemPropFriendly_name"] = "!!Name!!",
["ItemPropFriendly_periodicTable"] = "元素周期表",
["ItemPropFriendly_quality"] = "!!Quality!!",
["ItemPropFriendly_qualityLocalized"] = "品质（本地化）",
["ItemPropFriendly_readable"] = "可阅读",
["ItemPropFriendly_slotNum"] = "栏位编号",
["ItemPropFriendly_soulbound"] = "灵魂绑定",
["ItemPropFriendly_stacks"] = "可堆叠",
["ItemPropFriendly_subtype"] = "子类型",
["ItemPropFriendly_SuffixName"] = "后缀名称",
["ItemPropFriendly_tooltip"] = "提示框",
["ItemPropFriendly_type"] = "类型",
["ItemPropFriendly_uncategorized"] = "未分类",




-- ### Inventory UI ###

["Inventory_NoData"] = "离线背包数据不可用。",

-- Toolbar.
["Toolbar_Menu_TooltipTitle"] = "菜单",
["Toolbar_ExitEditMode"] = "退出编辑模式",
["Toolbar_Catalog_TooltipTitle"] = "目录（账号共享背包）",
["Toolbar_Catalog_TooltipText"] = "查看和搜索此账号下所有角色的合并背包。",
["Toolbar_Character_TooltipTitle"] = "角色",
["Toolbar_Character_TooltipText"] = "查看你其他角色的 %s。",  -- %s = 背包类型。
["Toolbar_Hide_TooltipTitle"] = "不显示隐藏物品",
["Toolbar_Show_TooltipTitle"] = "显示隐藏物品",
["Toolbar_Show_TooltipText"] = "切换隐藏物品的显示。",
["Toolbar_Search_TooltipTitle"] = "搜索",
["Toolbar_Search_TooltipText"] = "过滤你的 %s 内容。".. BS_NEWLINE.. "搜索时按 Shift + Enter 可打开目录。",  -- %s = 背包类型。
["Toolbar_Resort_TooltipTitle"] = "整理",
["Toolbar_Resort_TooltipText"] = "分类和排序。",
["Toolbar_Restack_TooltipTitle"] = "重新堆叠",
["Toolbar_Restack_TooltipText"] = "合并可堆叠物品。",
["Toolbar_HighlightChanges_TooltipTitle"] = "突出显示更改",
["Toolbar_HighlightChanges_TooltipText"] = "切换最近更改物品的突出显示。".. BS_NEWLINE.. GRAY_FONT_COLOR_CODE.. "Alt + 点击可将所有物品标记为未更改。",
["Toolbar_UnHighlightChanges_TooltipTitle"] = "不突出显示更改",

-- Action Tooltips.
["Tooltip_Inventory_ToggleBagSlotHighlightLockHint"] = "%s 以 %s 栏位突出显示。",  -- "Alt + 点击以锁定/解锁栏位突出显示"
["Tooltip_Inventory_ToggleEmptySlotStacking"] = "%s 以 %s 空栏位。",  -- "点击以堆叠/拆分空栏位"
["Tooltip_Inventory_TradeShortcut"] = "%s 以与 %s 交易。",  -- "Alt + 点击以与 <玩家名称> 交易"

-- Edit Mode.
["EditMode"] = "编辑模式",
["EditMode_CategoryInGroup"] = "当前分配到当前结构中的 '%s' 组。",  -- %s = 组名或 (未命名组)
["EditMode_CategoryNotInGroup"] = "未分配到当前结构中的任何组。",
["EditMode_Prompt_NewGroupName"] = "新组标签（可选但推荐）:",
["EditMode_Prompt_RenameGroup"] = "%s 的新标签:",
["EditMode_Prompt_DeleteGroup"] = "Delete the selected group?!!Warning_NoUndo!!",
["EditMode_Tooltip_SelectNew"] = "选择新的 %s。",  -- %s = L.位置或 L.组

-- Main Menu.
["Menu_Main_EditMode_TooltipText"] = "修改当前结构（重新排列组、分配类别等）。",
["Menu_Main_Settings_TooltipText"] = "打开设置菜单。",
["Menu_Main_ManageCategories_TooltipText"] = "打开类别管理器。",
["Menu_Main_ManageProfiles_TooltipText"] = "打开配置文件管理器。",
["Menu_Main_ManageSortOrders_TooltipText"] = "打开排序顺序管理器。",
["Menu_Main_Toggle_TooltipText"] = "切换 %s 窗口。",

-- Settings Menu (localizations for settings themselves are configured in `settingsStrings`).
["Menu_Settings"] = "%s 设置",  -- "背包设置"
["Menu_Settings_About"] = "关于Bagshui",
["Menu_Settings_Accessibility"] = "辅助功能",
["Menu_Settings_Advanced"] = "高级",
["Menu_Settings_Anchoring"] = "锚定",
["Menu_Settings_Behaviors"] = "行为",
["Menu_Settings_Badges"] = "物品徽章",
["Menu_Settings_ChangeTiming"] = "库存变化定时器",
["Menu_Settings_Colors"] = "颜色",
["Menu_Settings_ColorHistory_TooltipTitle"] = "颜色选择器历史记录",
["Menu_Settings_Commands"] = "命令",
["Menu_Settings_DefaultProfiles"] = "默认配置文件",
["Menu_Settings_Defaults"] = "默认值",
["Menu_Settings_Etcetera"] = "其他",
["Menu_Settings_General"] = "常规",
["Menu_Settings_GroupDefaults"] = "组默认值",
["Menu_Settings_Groups"] = "组",
["Menu_Settings_Hooks_Suffix"] = "%s 挂钩",  -- %s = 背包类型。
["Menu_Settings_InfoTooltip"] = "信息提示框",
["Menu_Settings_Integration"] = "集成",
["Menu_Settings_Interface"] = "界面",
["Menu_Settings_ItemSlots"] = "物品栏位",
["Menu_Settings_More"] = "更多",
["Menu_Settings_More_TooltipTitle"] = "其他设置",
["Menu_Settings_Overrides"] = "覆盖",
["Menu_Settings_Open"] = "!!Open!!",
["Menu_Settings_Options"] = "选项",
["Menu_Settings_Profile"] = "配置文件",
["Menu_Settings_Size"] = "尺寸",
["Menu_Settings_Tinting"] = "物品着色",
["Menu_Settings_Toggles"] = "切换",
["Menu_Settings_Toolbar"] = "工具栏",
["Menu_Settings_Tooltips"] = "提示框",
["Menu_Settings_ToggleBagsWith"] = "使用以下功能切换背包",
["Menu_Settings_StockBadgeColors"] = "库存徽章颜色",
["Menu_Settings_View"] = "视图",
["Menu_Settings_Window"] = "窗口",

-- Category Menu.
["Menu_Category_Move_TooltipText"] = "拿起此分类，以便将其移动到新的组。",
["Menu_Category_Edit_TooltipText"] = "在编辑器中打开此分类。",
["Menu_Category_Remove_TooltipText"] = "从当前组中移除该分类。!!Info_NoDelete!!",

-- Group Menu.
["Menu_Group_Rename_TooltipTitle"] = "重命名组",
["Menu_Group_Rename_TooltipText"] = "更改此组的标签。",
["Menu_Group_Move_TooltipTitle"] = "移动组",
["Menu_Group_Move_TooltipText"] = "拿起此组，以便将其移动到新位置。",
["Menu_Group_Delete_TooltipTitle"] = "删除组",
["Menu_Group_Delete_TooltipText"] = "彻底删除此组并取消分配任何分类。!!Warning_NoUndo!!",

["Menu_Group_Add_Category_TooltipText"] = "将现有分类分配到此组。",
["Menu_Group_Configure_Category_TooltipText"] = "显示此分类的上下文菜单。",
["Menu_Group_New_Category_TooltipTitle"] = "新建分类",
["Menu_Group_New_Category_TooltipText"] = "创建一个新分类并将其分配到此组。",
["Menu_Group_Move_Category_TooltipText"] = "拿起当前分配到此组的分类，以便将其移动到另一组。",
["Menu_Group_Remove_Category_TooltipText"] = "移除当前分配到此组的分类。!!Info_NoDelete!!",
["Menu_Group_Edit_Category_TooltipText"] = "编辑当前分配到此组的分类。",
["Menu_Group_DefaultColor_TooltipTitle"] = "使用默认组 % s 颜色",  -- % s = 背景 / 边框
["Menu_Group_DefaultColor_TooltipText"] = "应用在设置中定义的组 % s 颜色。",  -- % s = 背景 / 边框
["Menu_Group_DefaultSortOrder_TooltipTitle"] = "使用默认排序顺序",
["Menu_Group_DefaultSortOrder_TooltipText"] = "应用当前结构的默认排序顺序：".. BS_NEWLINE.. "% s",  -- % s = < 默认排序顺序名称 >
["Menu_Group_HideGroup"] = "隐藏组",
["Menu_Group_HideGroup_TooltipText"] = "除非打开 “显示隐藏”，否则不显示此组。",
["Menu_Group_HideStockBadge"] = "隐藏库存徽章",
["Menu_Group_HideStockBadge_TooltipText"] = "阻止此组显示库存变化徽章（新增 / 增加 / 减少）。",
["Menu_Group_Settings_TooltipTitle"] = "组设置",
["Menu_Group_Settings_TooltipText"] = "管理特定于组的选项，包括背景和边框颜色。",
["Menu_Group_Color_TooltipTitle"] = "组 % s 颜色",  -- % s = 背景 / 边框
["Menu_Group_Color_TooltipText"] = "设置此组的 % s。",  -- % s = 背景 / 边框
["Menu_Group_SortOrder_TooltipTitle"] = "组排序顺序",
["Menu_Group_SortOrder_TooltipText"] = "更改此组内物品的排序方式。",

-- Item Menu.
["Menu_Item_AssignToCategory"] = "直接分配",
["Menu_Item_AssignToCategory_TooltipTitle"] = "直接分类分配",
["Menu_Item_AssignToCategory_TooltipText"] = "将此物品的 ID 分配给一个或多个自定义分类（与使用规则函数相反）。",
["Menu_Item_AssignToCategory_CreateNew_TooltipText"] = "将物品分配到一个新的自定义分类。",
["Menu_Item_AssignToCategory_Hint_CustomOnly"] = "内置分类为只读 - 有关原因，请参阅 Bagshui 维基上的常见问题解答。",
["Menu_Item_AssignToClassCategory"] = "直接分配到",
["Menu_Item_Information_TooltipTitle"] = "物品信息",
["Menu_Item_Information_TooltipText"] = "查看有关此物品属性的详细信息并访问物品信息窗口。",
["Menu_Item_Information_Submenu_TooltipText"] = "点击打开物品信息窗口。",
["Menu_Item_Manage_TooltipTitle"] = "管理物品",
["Menu_Item_Manage_TooltipText"] = "Bagshui 特定的物品操作。",
["Menu_Item_MatchedCategories"] = "匹配的",
["Menu_Item_MatchedCategories_TooltipTitle"] = "匹配的分类",
["Menu_Item_MatchedCategories_TooltipText"] = "与此物品匹配的所有分类列表，按顺序排列。",
["Menu_Item_MatchedCategory_TooltipText"] = "点击编辑。",
["Menu_Item_Move_TooltipText"] = "拿起此物品，以便将其直接分配到新分类。",
["Menu_Item_RemoveFromEquippedGear"] = "从已装备中移除",
["Menu_Item_RemoveFromEquippedGear_TooltipText"] = "将此物品从已装备的物品列表中移除（即，Equipped () 规则将不再匹配）。",
["Menu_Item_ResetStockState"] = "重置库存状态",
["Menu_Item_ResetStockState_TooltipText"] = "清除此物品的新增 / 增加 / 减少状态。",

-- Item Stock State.
["StockState"] = "库存状态",
["StockLastChange"] = "上次更改",
-- BS_ITEM_STOCK_STATE localizations as `Stock_<BS_ITEM_STOCK_STATE value>`.
["Stock_New"] = "!!New!!",
["Stock_Up"] = "增加",
["Stock_Down"] = "减少",
["Stock_"] = "N/A",

-- Item Information window title.
["BagshuiItemInformation"] = "bagshui 物品信息",



-- ### Categories and Groups ###

-- Templates.
["Suffix_Items"] = "% s 物品",
["Suffix_Potions"] = "% s 药水",
["Suffix_Reagents"] = "% s 试剂",

-- Special categories.
["TurtleWoWGlyphs"] = "雕文（Turtle WoW）",
["SoulboundGear"] = "灵魂绑定装备",

-- Name/Tooltip identifiers sed to categorize items using strings that appear
-- in their names or tooltips.
-- Using [[bracket quoting]] to avoid the need for any Lua pattern escapes (like \.).
-- Any Lua patterns must be wrapped in slashes per the normal Bagshui string
-- handling rules (see `TooltipIdentifier_PotionHealth` for an example).
["NameIdentifier_AntiVenom"] = [[解毒剂]],
["NameIdentifier_Bandage"] = [[绷带]],
["NameIdentifier_Elixir"] = [[药剂]],
["NameIdentifier_Firestone"] = [[火焰石]],
["NameIdentifier_FrostOil"] = [[冰霜之油]],
["NameIdentifier_HallowedWand"] = [[神圣魔杖]],
["NameIdentifier_Idol"] = [[神像]],
["NameIdentifier_Juju"] = [[祖祖]],
["NameIdentifier_ManaOil"] = [[法力之油]],
["NameIdentifier_Poison"] = [[毒药]],
["NameIdentifier_Potion"] = [[药水]],
["NameIdentifier_Scroll"] = [[^ 卷轴：]],
["NameIdentifier_ShadowOil"] = [[暗影之油]],
["NameIdentifier_SharpeningStone"] = [[磨刀石]],
["NameIdentifier_Soulstone"] = [[灵魂石]],
["NameIdentifier_Spellstone"] = [[法术石]],
["NameIdentifier_TurtleWoWGlyph"] = [[雕文]],  -- 与 type ('Key') 一起用于识别 Turtle WoW 雕文。
["NameIdentifier_Weightstone"] = [[平衡石]],
["NameIdentifier_WizardOil"] = [[巫师之油]],

["NameIdentifier_Recipe_BottomHalf"] = [[下半部分]],
["NameIdentifier_Recipe_TopHalf"] = [[上半部分]],

["TooltipIdentifier_Buff_AlsoIncreases"] = [[还会提高你的]],
["TooltipIdentifier_Buff_WellFed"] = [[吃得很饱]],
["TooltipIdentifier_Companion"] = [[右键点击以召唤和解散你的]],
["TooltipIdentifier_Drink"] = [[饮用时必须保持坐姿]],
["TooltipIdentifier_Food"] = [[进食时必须保持坐姿]],
["TooltipIdentifier_Mount"] = [[使用：召唤并解散一匹可骑乘的]],
["TooltipIdentifier_MountAQ40"] = [[使用：发出高频声音]],
["TooltipIdentifier_PotionHealth"] = [[/ 恢复 [%.d]+ 至 [%.d]+ 点生命值./]],  -- 用斜杠括起来以激活模式匹配。
["TooltipIdentifier_PotionMana"] = [[/ 恢复 [%.d]+ 至 [%.d]+ 点法力值./]],  -- 用斜杠括起来以激活模式匹配。
["TooltipIdentifier_QuestItem"] = [[任务物品]],

-- Tooltip parsing -- extracting data from tooltips.
["TooltipParse_Charges"] = [[^(% d+) 次使用 $]],  -- 必须包含 (% d) 捕获组。
-- ItemInfo:IsUsable() Tooltip parsing
["TooltipParse_AlreadyKnown"] = _G.ITEM_SPELL_KNOWN,
["TooltipParse_RequiresLevel"] = [[需要 (% a [^\s]*) %((% d+)%)]],  -- 旨在匹配 “需要钓鱼 (10)” 并提取 “钓鱼”，“10”。（可能可以使用_G.ITEM_MIN_SKILL 并用捕获组替换其占位符。）


-- Shared Category/Group Names.
["ActiveQuest"] = "进行中的任务",
["Bandages"] = "绷带",
["BindOnEquip"] = "装备后绑定",
["Books"] = "书籍",
["Buffs"] = "增益",
["Companions"] = "宠物",
["Consumables"] = "消耗品",
["Disguises"] = "伪装",
["Drink"] = "饮料",
["Elixirs"] = "药剂",
["Empty"] = "空的",
["EmptySlots"] = "空插槽",
["Equipment"] = "装备",
["EquippedGear"] = "已装备的装备",
["FirstAid"] = "急救",
["Food"] = "食物",
["FoodBuffs"] = "食物增益",
["Gear"] = "装备",
["Glyphs"] = "雕文",
["Gray"] = "灰色",  -- 用于 “灰色物品”
["Health"] = "生命",
["Items"] = "物品",
["Juju"] = "祖祖",
["Keys"] = "钥匙",
["Mana"] = "法力",
["Misc"] = "杂物",
["Mounts"] = "坐骑",
["MyGear"] = "我的装备",
["Other"] = "其他",
["Potions"] = "药水",
["PotionsSlashRunes"] = "药水 / 符文",
["ProfessionBags"] = "专业背包",
["ProfessionCrafts"] = "专业制作",
["ProfessionReagents"] = "专业试剂",
["Reagents"] = "试剂",
["Recipes"] = "配方",
["Runes"] = "符文",
["Scrolls"] = "卷轴",
["Teleports"] = "传送",
["Tokens"] = "代币",
["Tools"] = "工具",
["TradeTools"] = "商业工具",
["Uncategorized"] = "未分类",
["WeaponBuffs"] = "武器增益",
["Weapons"] = "武器",

-- Category names that are different from group names.
["Category_ProfessionBags"] = "专业背包（已学习）",
["Category_ProfessionBagsAll"] = "专业背包（所有）",
["Category_ProfessionCrafts"] = "专业制作（已学习配方）",
["Category_ProfessionReagents"] = "专业试剂（已学习配方）",




-- ### Sort Orders ###

["SortOrder_Default_MinLevel"] = "标准排序（含最低等级）",
["SortOrder_Default_MinLevelNameRev"] = "标准排序（含最低等级 - 物品名称倒序）",
["SortOrder_Default_NameRev"] = "标准排序（物品名称倒序）",
["SortOrder_Default"] = "标准排序",
["SortOrder_Manual"] = "手动排序（仅背包 / 插槽编号）",




-- ### Profiles ###
["ManageProfile"] = "管理配置文件",
-- Profile types.
["Profile_Design"] = "外观设计",
["Profile_Structure"] = "结构设计",
["Profile_Abbrev_Design"] = "外观",
["Profile_Abbrev_Structure"] = "结构",

["Object_UsedInProfiles"] = "在配置文件中使用：",
["Object_UsedByCharacters"] = "被角色使用：",
["Object_ProfileUses"] = "配置文件使用：",


-- ### Object List/Manager/Editor ###

-- General.
["ObjectList_ActionNotAllowed"] = "% s 操作不允许用于 % s。",  -- "< 创建 / 编辑 / 删除 > 操作不允许用于 < 对象复数名称 >"
["ObjectList_ShowObjectUses"] = "显示 % s 的使用情况",
["ObjectList_ShowProfileUses"] = "显示配置文件使用情况",
["ObjectList_ImportSuccessful"] = "已导入 % s '% s'。",  -- "已导入 < 对象类型 > '< 对象名称 >'"
["ObjectList_ImportReusingExisting"] = "跳过导入 % s '% s'，因为它与 '% s' 相同。",  -- "跳过导入 < 对象类型 > '< 对象名称 >'，因为它与 '< 现有对象名称 >' 相同。"

-- Default column names.
["ObjectManager_Column_Name"] = "!!Name!!",
["ObjectManager_Column_InUse"] = "使用中",
["ObjectManager_Column_Realm"] = "服务器",
["ObjectManager_Column_Sequence"] = "序号",
["ObjectManager_Column_Source"] = "来源",
["ObjectManager_Column_LastInventoryUpdate"] = "库存更新时间",

-- The third %s after the ? is used to insert additional text if the ObjectManager's deletePromptExtraInfo property is set.
["ObjectManager_DeletePrompt"] = "是否删除以下 % s？% s% s!!Warning_NoUndo!!",  -- "是否删除分类 '< 分类名称 >'？"
["ObjectManager_DeleteForPrompt"] = "是否删除 '% s' 的 % s？% s!!Warning_NoUndo!!",  -- "是否删除 '< 角色名称 >' 的角色数据？"

["ObjectEditor_UnsavedPrompt"] = "是否在关闭前保存对 % s '% s' 的更改？",   -- "是否在关闭前保存对 < 对象类型 > '< 对象名称 >' 的更改？"
["ObjectEditor_RequiredField"] = "% s 是必填项",

-- Object editor prompt when adding a new item to an item list.
["ItemList_NewPrompt"] = "要添加的物品标识符：".. BS_NEWLINE.. GRAY_FONT_COLOR_CODE.. "可以是 ID、物品链接 / 物品字符串或数据库网址。".. BS_NEWLINE.. "用空格、制表符、逗号、分号或换行符分隔多个标识符。".. FONT_COLOR_CODE_CLOSE,
["ItemList_CopyPrompt"] = "物品 ID：",



-- ### Managers and Windows ###

-- Category Manager/Editor.
["CategoryManager"] = "Bagshui 分类管理器",  -- 窗口标题。
["CategoryEditor"] = "编辑分类",  -- 窗口标题。
["CategoryEditor_Field_name"] = "!!Name!!",
["CategoryEditor_Field_nameSort"] = "排序名称",
["CategoryEditor_Field_nameSort_TooltipText"] = "覆盖排序顺序中使用的分类名称，而不改变其显示名称。",
["CategoryEditor_Field_sequence"] = "顺序",
["CategoryEditor_Field_sequence_TooltipText"] = "控制分类的评估顺序。".. BS_NEWLINE.. "0 = 最先，100 = 最后",
["CategoryEditor_Field_class"] = "职业",
["CategoryEditor_Field_rule"] = "规则",
["CategoryEditor_Field_rule_TooltipText"] = "一个或多个 Bagshui 规则函数，结合 and/or/not 关键字，可通过括号分组。如需帮助，请参阅文档。",
["CategoryEditor_Field_list"] = "直接分配",
["CategoryEditor_Field_list_TooltipText"] = "直接分配到此分类的物品列表，而非使用规则函数。",
-- Button tooltips.
["CategoryEditor_AddRuleFunction"] = "添加规则函数",
["CategoryEditor_RuleFunctionWiki"] = "规则帮助",
["CategoryEditor_RuleValidation_Validate"] = "验证规则",
["CategoryEditor_RuleValidation_Valid"] = "规则有效",
["CategoryEditor_RuleValidation_Invalid"] = "规则验证错误：",



-- Character Data Manager.
["CharacterDataManager"] = "Bagshui 角色数据管理器",
["CharacterDataManager_DeleteInfo"] = "这仅删除库存数据；配置文件不会受到影响。",


-- Sort Order Editor.
["SortOrderManager"] = "Bagshui 排序顺序管理器",  -- 窗口标题。
["SortOrderEditor"] = "编辑排序顺序",  -- 窗口标题。
["SortOrderEditor_Field_name"] = "!!Name!!",
["SortOrderEditor_Field_fields"] = "字段",
-- Button tooltips.
["SortOrderEditor_NormalWordOrder"] = "正常词序",
["SortOrderEditor_ReverseWordOrder"] = "倒序词序",



-- Profile Manager/Editor.
["ProfileManager"] = "Bagshui 配置文件管理器",  -- 窗口标题。
["ProfileManager_ReplaceTooltipTitle"] = "替换 % s",  -- "替换外观设计"
["ProfileManager_ReplaceTooltipText"] = "将 '% s' 配置文件的 % s 配置复制到 '% s'。",  -- "将 ' 源 ' 配置文件的外观设计配置复制到 ' 目标 '。"
["ProfileManager_ReplacePrompt"] = "是否用 '% s' 的配置替换 '% s' 配置文件的 % s 配置？!!Warning_NoUndo!!",  -- "是否用 ' 源 ' 的配置替换 ' 目标 ' 配置文件的外观设计配置？"

["ProfileEditor"] = "编辑配置文件",  -- 窗口标题。
["ProfileEditor_Field_name"] = "!! 名称！！",
["ProfileEditor_FooterText"] = "配置文件可通过设置菜单和编辑模式进行编辑。",


-- Share (Import/Export).
["ShareManager"] = "Bagshui 导入 / 导出",
["ShareManager_ExportPrompt"] = "按 Ctrl + C 进行复制。",
["ShareManager_ExportEncodeCheckbox"] = "优化共享",
["ShareManager_ExportEncodeExplanation"] = "请共享优化（压缩 / 编码）后的版本，因为它几乎可以保证在任何形式的网络传输中正常使用。若要查看共享内容，请将未优化版本复制到文本编辑器中。",
["ShareManager_ImportPrompt"] = "使用 Ctrl + V 粘贴您要导入的 Bagshui 数据。",


-- Catalog (Account-wide search).
["CatalogManager"] = "Bagshui 目录",
["CatalogManager_SearchBoxPlaceholder"] = "搜索账号范围内的物品清单",
["CatalogManager_KnownCharacters"] = "显示来自以下角色的物品清单：",


-- Game Report
["GameReport"] = "Bagshui 游戏环境报告",
["GameReport_Instructions"] = "将以下文本复制并粘贴到您的错误报告的环境部分。",


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
["BagshuiTooltipIntro"] = "显示Bagshui信息提示框",


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

["LogWindowTitle"] = "Bagshui日志",
["ClearLog"] = "清除日志",
-- Log types.
["Log_Info"] = "信息",
["Log_Warn"] = "警告",
["Log_Error"] = "错误",

-- Settings reset messages.
["SettingReset_LogStart"] = "%s 已重置",
["SettingReset_InvalidValue"] = "无效值",
["SettingReset_Outdated"] = "已过时",

["SettingReset_WindowPositionAuto"] = "窗口位置已重置，因为它超出了屏幕范围。",
["SettingReset_WindowPositionManual"] = "窗口位置已重置。",




-- ### Help/Misc ###

["BagshuiDataReset"] = "由于版本变更，配置已重置（之前：%s / 新：%s）。",
["HowToUrl"] = "魔兽世界无法直接打开URL，因此请复制此URL（Ctrl+C）并在网页浏览器中访问。",


-- ### Settings: Tooltips, Scopes, Special ###

-- Automatically generated settings.
["Setting_HookBagTooltipTitle"] = "Hook %s",
["Setting_HookBagTooltipText"] = "Take over the key binding for Toggle %s.",
-- Special settings stuff.
["SettingScope_Account"] = "适用于此账号下的所有角色。",
["SettingScope_Character"] = "适用于此角色的所有背包窗口。",
["Setting_DisabledBy_HideGroupLabels"] = "× 由于当前结构已启用隐藏组标签，此设置已禁用。",
["Setting_EnabledBy_ColorblindMode"] = "√ 由于启用了色盲模式，此设置已启用。",
["Setting_Profile_SetAllHint"] = "Shift+点击可用于所有配置文件类型。",
["Setting_Reset_TooltipText"] = "重置为默认值：Ctrl+Alt+Shift+点击。",
["Setting_Profile_Use"] = "将此设置为当前的 %s %s 配置文件。",  -- 将此设置为当前的背包设计配置文件。


-- ### Settings ###
-- Keys are settingName, settingName_TooltipTitle, or settingName_TooltipText.
-- See localization notes in the declaration of `Settings:InitSettingsInfo()` for more information.

["aboutBagshui_TooltipTitle"] = "关于Bagshui",

["colorblindMode"] = "色盲模式",
["colorblindMode_TooltipText"] = "无论设计设置如何，始终显示物品品质和不可用标记。",

["createNewProfileDesign"] = "复制",
["createNewProfileDesign_TooltipTitle"] = "创建设计配置文件副本",
["createNewProfileDesign_TooltipText"] = "为新角色复制默认配置文件。",

["createNewProfileStructure"] = "复制",
["createNewProfileStructure_TooltipTitle"] = "创建结构配置文件副本",
["createNewProfileStructure_TooltipText"] = "为新角色复制默认配置文件。",

["defaultSortOrder"] = "排序顺序",
["defaultSortOrder_TooltipTitle"] = "默认排序顺序",
["defaultSortOrder_TooltipText"] = "当组没有指定特定排序顺序时，将使用此排序方式。",

["defaultProfileDesign"] = "设计",
["defaultProfileDesign_TooltipTitle"] = "默认设计配置文件",
["defaultProfileDesign_TooltipText"] = "新角色将使用的配置文件。",

["defaultProfileStructure"] = "结构",
["defaultProfileStructure_TooltipTitle"] = "默认结构配置文件",
["defaultProfileStructure_TooltipText"] = "新角色将使用的配置文件。",

["disableAutomaticResort"] = "手动重新整理",
["disableAutomaticResort_TooltipText"] = "关闭并重新打开背包窗口时，不自动对物品进行分类和排序。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "这与将默认排序顺序设置为手动不同。" .. FONT_COLOR_CODE_CLOSE,

["windowDoubleClickActions"] = "双击操作",
["windowDoubleClickActions_TooltipText"] = "双击背包窗口的空白部分可显示/隐藏所有工具栏。" .. BS_NEWLINE .. "Alt+双击可切换位置锁定。",

["globalInfoTooltips"] = "全局",
["globalInfoTooltips_TooltipTitle"] = "挂钩所有物品提示框",
["globalInfoTooltips_TooltipText"] = "按住Alt键时，在任何地方（如角色窗口、聊天链接等）显示带有目录计数的Bagshui信息提示框。",

["groupBackgroundDefault"] = "背景",
["groupBackgroundDefault_TooltipTitle"] = "默认组背景颜色",
["groupBackgroundDefault_TooltipText"] = "未设置组特定颜色时使用的背景颜色。",

["groupBorderDefault"] = "边框",
["groupBorderDefault_TooltipTitle"] = "默认组边框颜色",
["groupBorderDefault_TooltipText"] = "未设置组特定颜色时使用的边框颜色。",

["groupLabelDefault"] = "标签",
["groupLabelDefault_TooltipTitle"] = "默认组标签颜色",
["groupLabelDefault_TooltipText"] = "未设置组特定颜色时使用的标签颜色。",

["groupMargin"] = "边距",
["groupMargin_TooltipTitle"] = "组边距",
["groupMargin_TooltipText"] = "组与组之间的间距。",

["groupPadding"] = "内边距",
["groupPadding_TooltipTitle"] = "组内边距",
["groupPadding_TooltipText"] = "组边框与内部物品之间的间距。",

["groupUseSkinColors"] = "使用 %s 颜色",
["groupUseSkinColors_TooltipTitle"] = "组使用 %s 颜色",

["groupUseSkinColors_TooltipText"] = "使用 %s 的颜色，而不是Bagshui的设置。",
["hideGroupLabelsOverride"] = "隐藏组标签",
["hideGroupLabelsOverride_TooltipText"] = "即使设计中的组标签设置已启用，也禁止显示组标签。",

["itemMargin"] = "边距",
["itemMargin_TooltipTitle"] = "物品边距",
["itemMargin_TooltipText"] = "物品与物品之间的间距。",

["itemActiveQuestBadges"] = "活跃任务",
["itemActiveQuestBadges_TooltipTitle"] = "物品栏活跃任务标记",
["itemActiveQuestBadges_TooltipText"] = "当物品是活跃任务的目标时，在顶部显示一个问号。",

["itemQualityBadges"] = "!!Quality!!",
["itemQualityBadges_TooltipTitle"] = "物品品质标记",
["itemQualityBadges_TooltipText"] = "在左下角显示物品稀有度等级的图标。",

["itemUsableBadges"] = "不可用",
["itemUsableBadges_TooltipTitle"] = "物品不可用标记",
["itemUsableBadges_TooltipText"] = "在左上角显示不可用/已学习物品的图标。",

["itemUsableColors"] = "不可用",
["itemUsableColors_TooltipTitle"] = "物品不可用着色",
["itemUsableColors_TooltipText"] = "为不可用/已学习物品应用红色/绿色覆盖层。",

["itemSize"] = "大小",
["itemSize_TooltipTitle"] = "物品大小",
["itemSize_TooltipText"] = "物品的高度和宽度。",

["itemStockBadges"] = "库存",
["itemStockBadges_TooltipTitle"] = "物品库存标记",
["itemStockBadges_TooltipText"] = "指示物品是否为新物品或数量是否增加/减少。",

["itemStockChangeClearOnInteract"] = "点击清除",
["itemStockChangeClearOnInteract_TooltipTitle"] = "点击清除物品库存标记",
["itemStockChangeClearOnInteract_TooltipText"] = "交互时立即重置物品库存变化状态（新物品/增加/减少）。",

["itemStockChangeExpiration"] = "过期时间",
["itemStockChangeExpiration_TooltipTitle"] = "物品库存标记变化过期时间",
["itemStockChangeExpiration_TooltipText"] = "经过此时间后，物品将不再被视为有变化（新物品/增加/减少）。",

["itemStockBadgeFadeDuration"] = "淡入淡出时间",
["itemStockBadgeFadeDuration_TooltipTitle"] = "物品库存标记淡入淡出持续时间",
["itemStockBadgeFadeDuration_TooltipText"] = "库存变化标记（新物品/增加/减少）将在过期设置时间之前开始淡入淡出。",

["profileDesign"] = "配置文件",
["profileDesign_TooltipTitle"] = "设计配置文件",
["profileDesign_TooltipText"] = "用于设计（背包外观）的配置文件。",

["profileStructure"] = "配置文件",
["profileStructure_TooltipTitle"] = "结构配置文件",
["profileStructure_TooltipText"] = "用于结构（背包组织方式）的配置文件。",

["replaceBank"] = "替换银行",
["replaceBank_TooltipText"] = "使用Bagshui银行代替暴雪银行。",

["resetStockState"] = "标记物品无变化",
["resetStockState_TooltipText"] = "将此背包中的所有物品标记为不再是新物品、数量未增加或减少。",

["showBagBar"] = "背包栏",
["showBagBar_TooltipText"] = "在左下角显示背包栏。",

["showFooter"] = "底部工具栏",
["showFooter_TooltipTitle"] = "底部工具栏",
["showFooter_TooltipText"] = "显示底部工具栏。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "隐藏此工具栏将隐藏物品下方的所有内容，包括背包栏和金钱显示。" .. FONT_COLOR_CODE_CLOSE,

["showGroupLabels"] = "标签",
["showGroupLabels_TooltipTitle"] = "组标签",
["showGroupLabels_TooltipText"] = "在组上方显示标签。",

["showHeader"] = "顶部工具栏",
["showHeader_TooltipTitle"] = "顶部工具栏",
["showHeader_TooltipText"] = "显示顶部工具栏。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "隐藏此工具栏将隐藏物品上方的所有内容，包括关闭按钮，因此你需要通过快捷键、动作条按钮或宏来关闭窗口。" .. FONT_COLOR_CODE_CLOSE,

["showHearthstone"] = "炉石按钮",
["showHearthstone_TooltipText"] = "显示炉石按钮。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "仅适用于背包。" .. FONT_COLOR_CODE_CLOSE,

["showInfoTooltipsWithoutAlt"] = "无需Alt显示",
["showInfoTooltipsWithoutAlt_TooltipText"] = "始终显示Bagshui信息提示框（按住Shift可暂时隐藏）。",

["showLogWindow_TooltipText"] = "打开Bagshui日志窗口。",

["showMoney"] = "金钱",
["showMoney_TooltipText"] = "在右下角显示金钱。",

["stackEmptySlots"] = "堆叠空槽位",
["stackEmptySlots_TooltipTitle"] = "堆叠空槽位",
["stackEmptySlots_TooltipText"] = "将空槽位合并为单个堆叠，可点击展开（专业背包将单独堆叠）。",

["toolbarButtonColor"] = "图标",
["toolbarButtonColor_TooltipTitle"] = "工具栏图标颜色",
["toolbarButtonColor_TooltipText"] = "此背包工具栏图标的颜色。",

["toggleBagsWithAuctionHouse"] = "拍卖行",
["toggleBagsWithAuctionHouse_TooltipTitle"] = "随拍卖行开关背包",
["toggleBagsWithAuctionHouse_TooltipText"] = "访问拍卖行时打开和关闭背包。",

["toggleBagsWithBankFrame"] = "银行",
["toggleBagsWithBankFrame_TooltipTitle"] = "随银行开关背包",
["toggleBagsWithBankFrame_TooltipText"] = "访问银行时打开和关闭背包。",

["toggleBagsWithMailFrame"] = "邮箱",
["toggleBagsWithMailFrame_TooltipTitle"] = "随邮箱开关背包",
["toggleBagsWithMailFrame_TooltipText"] = "使用邮箱时打开和关闭背包。",

["toggleBagsWithTradeFrame"] = "交易",
["toggleBagsWithTradeFrame_TooltipTitle"] = "随交易开关背包",
["toggleBagsWithTradeFrame_TooltipText"] = "与其他玩家交易时打开和关闭背包。",

["windowAnchorXPoint"] = "水平方向",
["windowAnchorXPoint_TooltipTitle"] = "水平锚点",
["windowAnchorXPoint_TooltipText"] = "窗口将从屏幕的此边缘开始水平扩展。",

["windowAnchorYPoint"] = "垂直方向",
["windowAnchorYPoint_TooltipTitle"] = "垂直锚点",
["windowAnchorYPoint_TooltipText"] = "窗口将从屏幕的此边缘开始垂直扩展。",

["windowBackground"] = "背景",
["windowBackground_TooltipTitle"] = "窗口背景颜色",
["windowBackground_TooltipText"] = "此背包窗口背景使用的颜色。",

["windowBorder"] = "边框",
["windowBorder_TooltipTitle"] = "窗口边框颜色",
["windowBorder_TooltipText"] = "此背包窗口边框使用的颜色。",

["windowLocked"] = "锁定位置",
["windowLocked_TooltipText"] = "禁止移动此窗口。",

["windowMaxColumns"] = "最大列数",
["windowMaxColumns_TooltipText"] = "窗口宽度限制，以每行物品数量计算。",

["windowScale"] = "缩放",
["windowScale_TooltipTitle"] = "窗口缩放比例",
["windowScale_TooltipText"] = "整个窗口的相对大小。",

["windowUseSkinColors"] = "使用 %s 颜色",
["windowUseSkinColors_TooltipTitle"] = "窗口使用 %s 颜色",
["windowUseSkinColors_TooltipText"] = "使用 %s 的颜色，而非 Bagshui 的设置。",


})


end)