Bagshui:LoadComponent(function()

BsLocalization:AddLocale("zhCN", {

-- ### Game Stuff ###
-- ### 游戏相关内容 ###

-- Player classes.
-- 玩家职业。
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
-- 物品类别和子类别，由于它们不会从 `GetAuctionItemClasses()` / `GetAuctionItemSubClasses()` 返回，因此无法自动本地化。
["Devices"] = "装置",
["Explosives"] = "爆炸物",
["Junk"] = "垃圾",
["Key"] = "钥匙",
["Miscellaneous"] = "其它",
["Parts"] = "零件",
["Quest"] = "任务",
["Trade Goods"] = "商品",

-- Skill types.
-- Must cover all keys in `LOCALIZED_TO_EN_SKILL_ID` and `IGNORE_SKILL_CATEGORY`.
-- 技能类型。
-- 必须涵盖 `LOCALIZED_TO_EN_SKILL_ID` 和 `IGNORE_SKILL_CATEGORY` 中的所有键。
["Class Skills"] = "职业技能",
["Professions"] = "专业",
["Secondary Skills"] = "辅助技能",
["Weapon Skills"] = "武器技能",
["Armor Proficiencies"] = "护甲精通",
["Languages"] = "语言",

-- Skills.
-- Must cover any skill that the game can return from `GetSkillLineInfo()`.
-- 技能。
-- 必须涵盖游戏可以从 `GetSkillLineInfo()` 返回的任何技能。
["Axes"] = "单手斧",
--["Two-Handed Axes"] = "双手斧",
["Dual Wield"] = "双持",
["Fishing"] = "钓鱼",
["Maces"] = "单手锤",
--["Two-Handed Maces"] = "双手锤",
["Swords"] = "单手剑",
--["Two-Handed Swords"] = "双手剑",
["Plate Mail"] = "板甲",
["Shield"] = "盾牌",

-- Professions that have their own bag types.
-- Referenced in GameInfo.lua to build the `professionsToBags` table.
-- 拥有自己背包类型的专业。
-- 在 GameInfo.lua 中引用以构建 `professionsToBags` 表。
["Enchanting"] = "附魔",
["Herbalism"] = "草药学",




-- ### General ###
-- ### 通用内容 ###

["AbandonChanges"] = "放弃更改",
["About"] = "关于",
["Actions"] = "操作",
["Add"] = "添加",
["AddSlashRemove"] = "添加/移除",
["Aliases"] = "别名",
["AltClick"] = "Alt+点击",
["AltRightClick"] = "Alt+右键点击",
["Ascending"] = "升序",
["Available"] = "可用",
["Background"] = "背景",
["Bag"] = "背包",
["Border"] = "边框",
["Bottom"] = "底部",
["Cancel"] = "取消",
["Catalog"] = "目录",
["Categories"] = "分类",
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
["EmptyBagSlot"] = "空背包槽",
["Export"] = "导出",
["Full"] = "满",
["Group"] = "组",
["Help"] = "帮助",
["Hidden"] = "隐藏",
["Hide"] = "隐藏",  -- 动词 (Verb)，与 show 相反
["HoldAlt"] = "按住 Alt",
["HoldControlAlt"] = "按住 Control+Alt",
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
["Left"] = "左",
["Location"] = "位置",
["Lock"] = "锁定",
["LogWindow"] = "日志窗口",
["Manage"] = "管理",
["Menu"] = "菜单",
["MoreInformation"] = "更多信息",
["Move"] = "移动",
["MoveDown"] = "下移",
["MoveUp"] = "上移",
["Name"] = "名称",
["New"] = "新建",
["No"] = "否",
["NotNow"] = "稍后",
["NoItemsAvailable"] = "（无可用物品）",
["NoneAssigned"] = "（未分配）",
["NoneParenthesis"] = "（无）",
["NoRuleFunction"] = "（无规则函数）",
["NoValue"] = "（无值）",
["Open"] = "打开",
["PleaseWait"] = "请稍候...",
["Profile"] = "配置文件",
["Prefix_Add"] = "添加 %s",
["Prefix_Bag"] = "背包 %s",
["Prefix_Class"] = "职业 %s",
["Prefix_ClickFor"] = "点击以 %s",
["Prefix_Default"] = "默认 %s",
["Prefix_Edit"] = "编辑 %s",
["Prefix_Manage"] = "管理 %s",
["Prefix_Move"] = "移动 %s",
["Prefix_New"] = "新建 %s",
["Prefix_OpenMenuFor"] = "打开菜单以 %s",
["Prefix_Remove"] = "移除 %s",
["Prefix_Search"] = "搜索 %s",
["Prefix_Sort"] = "排序 %s",
["Prefix_Target"] = "目标 %s",
["Prefix_Toggle"] = "切换 %s",
["Prefix_Unnamed"] = "（未命名 %s）",
["Profiles"] = "配置文件",
["Quality"] = "品质",
["ReleaseAlt"] = "释放 Alt",
["Reload"] = "重新加载",
["Remove"] = "移除",
["Rename"] = "重命名",
["Replace"] = "替换",
["Report"] = "报告",
["ResetPosition"] = "重置位置",
["Right"] = "右",
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
["Stack"] = "堆叠",  -- 动词 (Verb)
["Suffix_Default"] = "%s " .. LIGHTYELLOW_FONT_COLOR_CODE .. " [默认]" .. FONT_COLOR_CODE_CLOSE,
["Suffix_EmptySlot"] = "%s 空槽",
["Suffix_Menu"] = "%s 菜单",
["Suffix_ReadOnly"] = "%s " .. LIGHTYELLOW_FONT_COLOR_CODE .. "[只读]" .. FONT_COLOR_CODE_CLOSE,
["Suffix_Reversed"] = "%s [反转]",  -- 用于解释排序顺序中字段反转的情况（例如 名称 [反转]）
["Suffix_Sets"] = "%d 套",
["Symbol_Brackets"] = "[%s]",
["Symbol_Colon"] = "%s：",
["Symbol_Ellipsis"] = "%s…",  -- 用于菜单中，表示点击它将打开另一个对话框或菜单
["Templates"] = "模板",
["Text"] = "文本",
["Toggle"] = "切换",  -- 动词 (Verb)
["Top"] = "顶部",
["Total"] = "总计",
["Undo"] = "撤销",
["Unknown"] = "未知",
["Unlock"] = "解锁",
["Unnamed"] = "（未命名）",
["Unstack"] = "取消堆叠",  -- 动词 (Verb)
["Used"] = "已使用",
["UseDefault"] = "使用默认",
["Validate"] = "验证",
["Vertical"] = "垂直",
["VersionNumber"] = "版本 %s",
["Yes"] = "是",

-- Inventory types.
-- 背包类型。
["Bags"] = "背包",
["Bank"] = "银行",
["Equipped"] = "已装备",
["Keyring"] = "钥匙链",

-- Abbreviations for tooltip use.
-- 用于提示框的缩写。
["Abbrev_Bags"] = "背包",
["Abbrev_Bank"] = "银行",
["Abbrev_Keyring"] = "钥匙",
["Abbrev_Equipped"] = "装备",

-- Slash command help message.
-- 斜杠命令帮助信息。
["Slash_Help"] = "%s 命令：",
["Slash_Help_Postscript"] = "要查看子命令列表，请在命令后附加 Help。",

-- Key bindings (other than Inventory class names; those are handled in `Inventory:New()`).
-- 按键绑定（除了背包类名称；这些在 `Inventory:New()` 中处理）。
["Binding_Resort"] = "整理所有",
["Binding_Restack"] = "重新堆叠所有",

-- Item properties to friendly names as `ItemPropFriendly_<propertyName>`.
-- Anything non-private in `BS_ITEM_SKELETON` or `BS_REALTIME_ITEM_INFO_PROPERTIES` must be present.
-- 物品属性的友好名称，格式为 `ItemPropFriendly_<属性名称>`。
-- `BS_ITEM_SKELETON` 或 `BS_REALTIME_ITEM_INFO_PROPERTIES` 中任何非私有属性都必须存在。
["ItemPropFriendly_activeQuest"] = "活跃任务物品",
["ItemPropFriendly_baseName"] = "基础名称",
["ItemPropFriendly_bagNum"] = "背包编号",
["ItemPropFriendly_bagType"] = "背包类型",
["ItemPropFriendly_bindsOnEquip"] = "装备后绑定",
["ItemPropFriendly_charges"] = "充能",
["ItemPropFriendly_count"] = "数量",
["ItemPropFriendly_equipLocation"] = "装备位置",
["ItemPropFriendly_equipLocationLocalized"] = "装备位置（本地化）",
["ItemPropFriendly_emptySlot"] = "空槽",
["ItemPropFriendly_id"] = "物品 ID",
["ItemPropFriendly_itemLink"] = "物品链接",
["ItemPropFriendly_itemString"] = "物品字符串",
["ItemPropFriendly_locked"] = "已锁定",
["ItemPropFriendly_maxStackCount"] = "最大堆叠数量",
["ItemPropFriendly_minLevel"] = "最低等级",
["ItemPropFriendly_name"] = "!!Name!!",
["ItemPropFriendly_periodicTable"] = "周期表",
["ItemPropFriendly_quality"] = "!!Quality!!",
["ItemPropFriendly_qualityLocalized"] = "品质（本地化）",
["ItemPropFriendly_readable"] = "可读",
["ItemPropFriendly_slotNum"] = "槽位编号",
["ItemPropFriendly_soulbound"] = "灵魂绑定",
["ItemPropFriendly_stacks"] = "堆叠",
["ItemPropFriendly_subtype"] = "子类型",
["ItemPropFriendly_suffixName"] = "后缀名称",
["ItemPropFriendly_tooltip"] = "提示",
["ItemPropFriendly_type"] = "类型",
["ItemPropFriendly_uncategorized"] = "未分类",




-- ### Inventory UI ###
-- ### 背包用户界面 ###

["Inventory_NoData"] = "离线背包数据不可用。",

-- Toolbar.
-- 工具栏。
["Toolbar_Menu_TooltipTitle"] = "菜单",
["Toolbar_ExitEditMode"] = "退出编辑模式",
["Toolbar_Catalog_TooltipTitle"] = "目录（账户范围背包）",
["Toolbar_Catalog_TooltipText"] = "查看和搜索此账户上所有角色的背包。",
["Toolbar_Character_TooltipTitle"] = "角色",
["Toolbar_Character_TooltipText"] = "查看其他角色的 %s。",  -- %s = 背包类型。
["Toolbar_Hide_TooltipTitle"] = "不显示隐藏",
["Toolbar_Show_TooltipTitle"] = "显示隐藏",
["Toolbar_Show_TooltipText"] = "切换隐藏物品的显示。",
["Toolbar_Search_TooltipTitle"] = "搜索",
["Toolbar_Search_TooltipText"] = "过滤你的 %s 内容。" .. BS_NEWLINE .. "在搜索时按 Shift+Enter 打开目录。",  -- %s = 背包类型。
["Toolbar_Resort_TooltipTitle"] = "整理",
["Toolbar_Resort_TooltipText"] = "分类和排序。",
["Toolbar_Restack_TooltipTitle"] = "重新堆叠",
["Toolbar_Restack_TooltipText"] = "合并可堆叠物品。",
["Toolbar_HighlightChanges_TooltipTitle"] = "高亮更改",
["Toolbar_HighlightChanges_TooltipText"] = "切换最近更改物品的高亮显示。" .. BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "Alt+点击将所有物品标记为未更改。",
["Toolbar_UnHighlightChanges_TooltipTitle"] = "不高亮更改",

-- Action Tooltips.
-- 操作提示框。
["Tooltip_Inventory_ToggleBagSlotHighlightLockHint"] = "%s 以 %s 槽位高亮。",  -- "Alt+点击以锁定/解锁槽位高亮显示"
["Tooltip_Inventory_ToggleEmptySlotStacking"] = "%s 以 %s 空槽。",  -- "点击以堆叠/取消堆叠空槽"
["Tooltip_Inventory_TradeShortcut"] = "%s 与 %s 交易。",  -- "Alt+点击与 <玩家名称> 交易"

-- Edit Mode.
-- 编辑模式。
["EditMode"] = "编辑模式",
["EditMode_CategoryInGroup"] = "当前分配到当前结构中的组 '%s'。",  -- %s = 组名称或 (未命名组)
["EditMode_CategoryNotInGroup"] = "未分配到当前结构中的组。",
["EditMode_Prompt_NewGroupName"] = "新组的标签（可选但建议）：",
["EditMode_Prompt_RenameGroup"] = "%s 的新标签：",
["EditMode_Prompt_DeleteGroup"] = "删除选定的组？!!Warning_NoUndo!!",
["EditMode_Tooltip_SelectNew"] = "选择新的 %s。",  -- %s = 位置或组

-- Main Menu.
-- 主菜单。
["Menu_Main_EditMode_TooltipText"] = "修改当前结构（重新排列组、分配类别等）。",
["Menu_Main_Settings_TooltipText"] = "打开设置菜单。",
["Menu_Main_ManageCategories_TooltipText"] = "打开类别管理器。",
["Menu_Main_ManageProfiles_TooltipText"] = "打开配置文件管理器。",
["Menu_Main_ManageSortOrders_TooltipText"] = "打开排序顺序管理器。",
["Menu_Main_Toggle_TooltipText"] = "切换 %s 窗口。",

-- Settings Menu (localizations for settings themselves are configured in `settingsStrings`).
-- 设置菜单（设置本身的本地化在在这个文件的末尾）。
["Menu_Settings"] = "%s 设置",  -- "背包设置"
["Menu_Settings_About"] = "关于 Bagshui",
["Menu_Settings_Accessibility"] = "可访问性",
["Menu_Settings_Advanced"] = "高级",
["Menu_Settings_Anchoring"] = "锚点",
["Menu_Settings_Behaviors"] = "行为",
["Menu_Settings_Badges"] = "物品徽章",
["Menu_Settings_ChangeTiming"] = "库存更改计时器",
["Menu_Settings_Colors"] = "颜色",
["Menu_Settings_ColorHistory_TooltipTitle"] = "颜色选择器历史",
["Menu_Settings_Commands"] = "命令",
["Menu_Settings_DefaultProfiles"] = "默认配置文件",
["Menu_Settings_Defaults"] = "默认值",
["Menu_Settings_Etcetera"] = "其他",
["Menu_Settings_General"] = "常规",
["Menu_Settings_GroupDefaults"] = "组默认值",
["Menu_Settings_Groups"] = "组",
["Menu_Settings_Hooks_Suffix"] = "%s 钩子",  -- %s = 背包类型。
["Menu_Settings_InfoTooltip"] = "信息提示",
["Menu_Settings_Integration"] = "集成",
["Menu_Settings_Interface"] = "界面",
["Menu_Settings_ItemSlots"] = "物品槽",
["Menu_Settings_More"] = "更多",
["Menu_Settings_More_TooltipTitle"] = "附加设置",
["Menu_Settings_Overrides"] = "覆盖",
["Menu_Settings_Open"] = "!!Open!!",
["Menu_Settings_Options"] = "选项",
["Menu_Settings_Profile"] = "配置文件",
["Menu_Settings_Size"] = "大小",
["Menu_Settings_SizeAndLayering"] = "尺寸和分层",
["Menu_Settings_Tinting"] = "物品着色",
["Menu_Settings_Toggles"] = "切换",
["Menu_Settings_Toolbar"] = "工具栏",
["Menu_Settings_Tooltips"] = "提示",
["Menu_Settings_ToggleBagsWith"] = "切换背包与",
["Menu_Settings_StockBadgeColors"] = "库存颜色",
["Menu_Settings_View"] = "视图",
["Menu_Settings_Window"] = "窗口",

-- Category Menu.
-- 类别菜单。
["Menu_Category_Move_TooltipText"] = "点击此类别以便将其移动到新组。",
["Menu_Category_Edit_TooltipText"] = "在编辑器中打开此类别。",
["Menu_Category_Remove_TooltipText"] = "从当前组中移除此类别。!!Info_NoDelete!!",

-- Group Menu.
-- 组菜单。
["Menu_Group_Rename_TooltipTitle"] = "重命名组",
["Menu_Group_Rename_TooltipText"] = "更改此组的标签。",
["Menu_Group_Move_TooltipTitle"] = "移动组",
["Menu_Group_Move_TooltipText"] = "点击此组以便将其移动到新位置。",
["Menu_Group_Delete_TooltipTitle"] = "删除组",
["Menu_Group_Delete_TooltipText"] = "完全删除此组并取消分配任何类别。!!Warning_NoUndo!!",

["Menu_Group_Add_Category_TooltipText"] = "将现有类别分配给此组。",
["Menu_Group_Configure_Category_TooltipText"] = "显示此类别的上下文菜单。",
["Menu_Group_New_Category_TooltipTitle"] = "新建类别",
["Menu_Group_New_Category_TooltipText"] = "创建新类别并将其分配给此组。",
["Menu_Group_Move_Category_TooltipText"] = "点击当前分配给此组的类别，以便将其移动到另一个组。",
["Menu_Group_Remove_Category_TooltipText"] = "移除当前分配给此组的类别。!!Info_NoDelete!!",
["Menu_Group_Edit_Category_TooltipText"] = "编辑当前分配给此组的类别。",
["Menu_Group_DefaultColor_TooltipTitle"] = "使用默认组%s颜色",  -- %s = 背景/边框
["Menu_Group_DefaultColor_TooltipText"] = "应用在设置中定义的组%s颜色。",  -- %s = 背景/边框
["Menu_Group_DefaultSortOrder_TooltipTitle"] = "使用默认排序顺序",
["Menu_Group_DefaultSortOrder_TooltipText"] = "应用当前结构的默认排序顺序：" .. BS_NEWLINE .. "%s",  -- %s = <默认排序顺序的名称>
["Menu_Group_HideGroup"] = "隐藏组",
["Menu_Group_HideGroup_TooltipText"] = "除非启用【显示隐藏】，否则不显示此组。",
["Menu_Group_HideStockBadge"] = "隐藏库存徽章",
["Menu_Group_HideStockBadge_TooltipText"] = "阻止为此组显示库存变化徽章（新/增加/减少）。",
["Menu_Group_Settings_TooltipTitle"] = "组设置",
["Menu_Group_Settings_TooltipText"] = "管理组特定选项，包括背景和边框颜色。",
["Menu_Group_Color_TooltipTitle"] = "组%s颜色",  -- %s = 背景/边框
["Menu_Group_Color_TooltipText"] = "设置此组的%s。",  -- %s = 背景/边框
["Menu_Group_SortOrder_TooltipTitle"] = "组排序顺序",
["Menu_Group_SortOrder_TooltipText"] = "更改此组内物品的排序方式。",

-- Item Menu.
-- 物品菜单。
["Menu_Item_AssignToCategory"] = "直接分配",
["Menu_Item_AssignToCategory_TooltipTitle"] = "直接类别分配",
["Menu_Item_AssignToCategory_TooltipText"] = "将此物品的ID分配给一个或多个自定义类别（而不是使用规则函数）。",
["Menu_Item_AssignToCategory_CreateNew_TooltipText"] = "将物品分配给新的自定义类别。",
["Menu_Item_AssignToCategory_Hint_CustomOnly"] = "内置类别是只读的 - 请参阅Bagshui Wiki上的FAQ了解原因。",
["Menu_Item_AssignToClassCategory"] = "直接分配到",
["Menu_Item_Information_TooltipTitle"] = "物品信息",
["Menu_Item_Information_TooltipText"] = "查看有关此物品属性的详细信息并访问物品信息窗口。",
["Menu_Item_Information_Submenu_TooltipText"] = "点击打开物品信息窗口。",
["Menu_Item_Manage_TooltipTitle"] = "管理物品",
["Menu_Item_Manage_TooltipText"] = "Bagshui特定的物品操作。",
["Menu_Item_MatchedCategories"] = "匹配",
["Menu_Item_MatchedCategories_TooltipTitle"] = "匹配的类别",
["Menu_Item_MatchedCategories_TooltipText"] = "按顺序排列的所有匹配此物品的类别列表。",
["Menu_Item_MatchedCategory_TooltipText"] = "点击编辑。",
["Menu_Item_Move_TooltipText"] = "点击此物品以便将其直接分配给新类别。",
["Menu_Item_RemoveFromEquippedGear"] = "从已装备中移除",
["Menu_Item_RemoveFromEquippedGear_TooltipText"] = "将此物品从您已装备的装备列表中移除（即Equipped()规则将不再匹配）。",
["Menu_Item_ResetStockState"] = "重置库存状态",
["Menu_Item_ResetStockState_TooltipText"] = "清除此物品的新/增加/减少状态。",

-- Item Stock State.
-- 物品库存状态。
["StockState"] = "库存状态",
["StockLastChange"] = "最后更改",
-- BS_ITEM_STOCK_STATE本地化为`Stock_<BS_ITEM_STOCK_STATE值>`。
["Stock_New"] = "!!New!!",
["Stock_Up"] = "增加",
["Stock_Down"] = "减少",
["Stock_"] = "N/A",

-- Item Information window title.
-- 物品信息窗口标题。
["BagshuiItemInformation"] = "Bagshui物品信息",



-- ### Categories and Groups ###
-- ### 类别和组 ###

-- Templates.
-- 模板。
["Suffix_Items"] = "%s 物品",
["Suffix_Potions"] = "%s 药水",
["Suffix_Reagents"] = "%s 材料",

-- Special categories.
-- 特殊类别。
["TurtleWoWGlyphs"] = "雕文（Turtle WoW）",
["SoulboundGear"] = "灵魂绑定装备",

-- Name/Tooltip identifiers sed to categorize items using strings that appear
-- in their names or tooltips.
-- Using [[bracket quoting]] to avoid the need for any Lua pattern escapes (like \.).
-- Any Lua patterns must be wrapped in slashes per the normal Bagshui string
-- handling rules (see `TooltipIdentifier_PotionHealth` for an example).
-- 用于通过物品名称或提示框中出现的字符串对物品进行分类的名称/提示框标识符。
-- 使用 [[括号引用]] 以避免需要任何 Lua 模式转义（如 \）。
-- 任何 Lua 模式必须按照正常的 Bagshui 字符串处理规则用斜杠包裹（请参阅 `TooltipIdentifier_PotionHealth` 示例）。
["NameIdentifier_AntiVenom"] = [[抗毒药剂]],
["NameIdentifier_Bandage"] = [[绷带]],
["NameIdentifier_Elixir"] = [[药剂]],
["NameIdentifier_Firestone"] = [[火焰石]],
["NameIdentifier_FrostOil"] = [[冰霜之油]],
["NameIdentifier_HallowedWand"] = [[神圣魔杖]],
["NameIdentifier_Idol"] = [[神像]],
["NameIdentifier_Juju"] = [[巫毒]],
["NameIdentifier_ManaOil"] = [[法力之油]],
["NameIdentifier_Poison"] = [[毒药]],
["NameIdentifier_Potion"] = [[药水]],
["NameIdentifier_Scroll"] = [[^卷轴：]],
["NameIdentifier_ShadowOil"] = [[暗影之油]],
["NameIdentifier_SharpeningStone"] = [[磨刀石]],
["NameIdentifier_Soulstone"] = [[灵魂石]],
["NameIdentifier_Spellstone"] = [[法术石]],
["NameIdentifier_TurtleWoWGlyph"] = [[雕文]],  -- 与 type('Key') 一起使用以识别 Turtle WoW 雕文。
["NameIdentifier_Weightstone"] = [[重石]],
["NameIdentifier_WizardOil"] = [[巫师之油]],

["NameIdentifier_Recipe_BottomHalf"] = [[下半部分]],
["NameIdentifier_Recipe_TopHalf"] = [[上半部分]],

["TooltipIdentifier_Buff_AlsoIncreases"] = [[同时增加你的]],
["TooltipIdentifier_Buff_WellFed"] = [[进食充分]],
["TooltipIdentifier_Companion"] = [[右键点击以召唤和解散你的]],
["TooltipIdentifier_Drink"] = [[必须在坐下时饮用]],
["TooltipIdentifier_Food"] = [[必须在坐下时进食]],
["TooltipIdentifier_Mount"] = [[使用：召唤和解散一个可骑乘的]],
["TooltipIdentifier_MountAQ40"] = [[使用：发出高频声音]],
["TooltipIdentifier_PotionHealth"] = [[/恢复%d+到%d+点生命值\。/]],  -- 用斜杠包裹以激活模式匹配。
["TooltipIdentifier_PotionMana"] = [[/恢复%d+到%d+点法力值\。/]],  -- 用斜杠包裹以激活模式匹配。
["TooltipIdentifier_QuestItem"] = [[任务物品]],

-- Tooltip parsing -- extracting data from tooltips.
-- 提示框解析 -- 从提示框中提取数据。
["TooltipParse_Charges"] = [[^(%d+) 充能$]],  -- 必须包含 (%d) 捕获组。
-- ItemInfo:IsUsable() Tooltip parsing
-- ItemInfo:IsUsable() 提示框解析
["TooltipParse_AlreadyKnown"] = _G.ITEM_SPELL_KNOWN,


-- Shared Category/Group Names.
-- 共享的类别/组名称。
["ActiveQuest"] = "活跃任务",
["Bandages"] = "绷带",
["BindOnEquip"] = "装备后绑定",
["Books"] = "书籍",
["Buffs"] = "增益",
["Companions"] = "伙伴",
["Consumables"] = "消耗品",
["Disguises"] = "伪装",
["Drink"] = "饮料",
["Elixirs"] = "药剂",
["Empty"] = "空",
["EmptySlots"] = "空槽",
["Equipment"] = "装备",
["EquippedGear"] = "已装备的装备",
["FirstAid"] = "急救",
["Food"] = "食物",
["FoodBuffs"] = "食物增益",
["Gear"] = "装备",
["Glyphs"] = "雕文",
["Gray"] = "灰色",  -- 用于 "灰色物品"
["Health"] = "生命值",
["Items"] = "物品",
["Juju"] = "巫毒",
["Keys"] = "钥匙",
["Mana"] = "法力值",
["Misc"] = "杂项",
["Mounts"] = "坐骑",
["MyGear"] = "我的装备",
["Other"] = "其他",
["Potions"] = "药水",
["PotionsSlashRunes"] = "药水/符文",
["ProfessionBags"] = "专业背包",
["ProfessionCrafts"] = "专业制作",
["ProfessionReagents"] = "专业材料",
["Reagents"] = "材料",
["Recipes"] = "配方",
["Runes"] = "符文",
["Scrolls"] = "卷轴",
["Teleports"] = "传送",
["Tokens"] = "代币",
["Tools"] = "工具",
["TradeTools"] = "交易工具",
["Uncategorized"] = "未分类",
["WeaponBuffs"] = "武器增益",
["Weapons"] = "武器",

-- Category names that are different from group names.
-- 与组名称不同的类别名称。
["Category_ProfessionBags"] = "专业背包（已学习）",
["Category_ProfessionBagsAll"] = "专业背包（全部）",
["Category_ProfessionCrafts"] = "专业制作（已学习配方）",
["Category_ProfessionReagents"] = "专业材料（已学习配方）",




-- ### Sort Orders ###
-- ### 排序顺序 ###

["SortOrder_Default_MinLevel"] = "标准与最低等级",
["SortOrder_Default_MinLevelNameRev"] = "标准与最低等级 - 反转物品名称",
["SortOrder_Default_NameRev"] = "标准 - 反转物品名称",
["SortOrder_Default"] = "标准",
["SortOrder_Manual"] = "手动（仅背包/槽位编号）",




-- ### Profiles ###
-- ### 配置文件 ###
["ManageProfile"] = "管理配置文件",
-- Profile types.
-- 配置文件类型。
["Profile_Design"] = "设计",
["Profile_Structure"] = "结构",
["Profile_Abbrev_Design"] = "设计",
["Profile_Abbrev_Structure"] = "结构",

["Object_UsedInProfiles"] = "在配置文件中使用：",
["Object_UsedByCharacters"] = "由角色使用：",
["Object_ProfileUses"] = "配置文件使用：",


-- ### Object List/Manager/Editor ###
-- ### 对象列表/管理器/编辑器 ###

-- General.
-- 通用。
["ObjectList_ActionNotAllowed"] = "%s 不允许用于 %s。",  -- "<创建/编辑/删除> 不允许用于 <对象名称复数>"
["ObjectList_ShowObjectUses"] = "显示 %s 使用",
["ObjectList_ShowProfileUses"] = "显示配置文件使用",
["ObjectList_ImportSuccessful"] = "导入 %s '%s'。",  -- "导入 <对象类型> '<对象名称>'"
["ObjectList_ImportReusingExisting"] = "跳过导入 %s '%s'，因为它与 '%s' 相同。",  -- "跳过导入 <对象类型> '<对象名称>'，因为它与 '<现有对象名称>' 相同。"

-- Default column names.
-- 默认列名称。
["ObjectManager_Column_Name"] = "!!Name!!",
["ObjectManager_Column_InUse"] = "使用中",
["ObjectManager_Column_Realm"] = "服务器",
["ObjectManager_Column_Sequence"] = "序列",
["ObjectManager_Column_Source"] = "来源",
["ObjectManager_Column_LastInventoryUpdate"] = "背包更新",

-- The third %s after the ? is used to insert additional text if the ObjectManager's deletePromptExtraInfo property is set.
-- 第三个 %s 在问号之后，用于在 ObjectManager 的 deletePromptExtraInfo 属性设置时插入额外文本。
["ObjectManager_DeletePrompt"] = "删除以下 %s？%s%s!!Warning_NoUndo!!",  -- "删除类别 '<类别名称>'？"
["ObjectManager_DeleteForPrompt"] = "删除 '%s' 的 %s？%s!!Warning_NoUndo!!",  -- "删除 '<角色名称>' 的角色数据？"

["ObjectEditor_UnsavedPrompt"] = "关闭前保存对 %s '%s' 的更改？",   -- "关闭前保存对 <对象类型> '<对象名称>' 的更改？"
["ObjectEditor_RequiredField"] = "%s 是必填项",

-- Object editor prompt when adding a new item to an item list.
-- 向物品列表中添加新物品时的对象编辑器提示。
["ItemList_NewPrompt"] = "要添加的物品的标识符：" .. BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "可以是 ID、物品链接/物品字符串或数据库 URL。" .. BS_NEWLINE .. "用空格、制表符、逗号、分号或换行符分隔多个。" .. FONT_COLOR_CODE_CLOSE,
["ItemList_CopyPrompt"] = "物品 ID：",



-- ### Managers and Windows ###
-- ### 管理器和窗口 ###

-- Category Manager/Editor.
-- 类别管理器/编辑器。
["CategoryManager"] = "Bagshui 类别管理器",  -- 窗口标题。
["CategoryEditor"] = "编辑类别",  -- 窗口标题。
["CategoryEditor_Field_name"] = "!!Name!!",
["CategoryEditor_Field_nameSort"] = "名称（排序用）",
["CategoryEditor_Field_nameSort_TooltipText"] = "覆盖用于排序顺序的类别名称，而不更改其显示名称。",
["CategoryEditor_Field_sequence"] = "序列",
["CategoryEditor_Field_sequence_TooltipText"] = "控制类别评估的顺序。" .. BS_NEWLINE .. "0 = 第一个，100 = 最后一个",
["CategoryEditor_Field_class"] = "职业",
["CategoryEditor_Field_rule"] = "规则",
["CategoryEditor_Field_rule_TooltipText"] = "一个或多个 Bagshui 规则函数，使用 and/or/not 关键字组合，可选地使用括号分组。请参阅文档以获取帮助。",
["CategoryEditor_Field_list"] = "直接分配",
["CategoryEditor_Field_list_TooltipText"] = "直接分配到此类别而不是使用规则函数的物品列表。",
-- Button tooltips.
-- 按钮提示框。
["CategoryEditor_AddRuleFunction"] = "添加规则函数",
["CategoryEditor_RuleFunctionWiki"] = "规则帮助",
["CategoryEditor_RuleValidation_Validate"] = "验证规则",
["CategoryEditor_RuleValidation_Valid"] = "规则有效",
["CategoryEditor_RuleValidation_Invalid"] = "规则验证错误：",

-- Character Data Manager.
-- 角色数据管理器。
["CharacterDataManager"] = "Bagshui 角色数据管理器",
["CharacterDataManager_DeleteInfo"] = "这只会移除背包数据；配置文件不会被触及。",

-- Sort Order Editor.
-- 排序顺序编辑器。
["SortOrderManager"] = "Bagshui 排序顺序管理器",  -- 窗口标题。
["SortOrderEditor"] = "编辑排序顺序",  -- 窗口标题。
["SortOrderEditor_Field_name"] = "!!Name!!",
["SortOrderEditor_Field_fields"] = "字段",
-- Button tooltips.
-- 按钮提示框。
["SortOrderEditor_NormalWordOrder"] = "正常单词顺序",
["SortOrderEditor_ReverseWordOrder"] = "反转单词顺序",



-- Profile Manager/Editor.
-- 配置文件管理器/编辑器。
["ProfileManager"] = "Bagshui 配置文件管理器",  -- 窗口标题。
["ProfileManager_ReplaceTooltipTitle"] = "替换 %s",  -- "替换设计"
["ProfileManager_ReplaceTooltipText"] = "将 '%s' 配置文件的 %s 配置复制到 '%s'。" ,  -- "将 '源' 配置文件的设计配置复制到 '目标'。"
["ProfileManager_ReplacePrompt"] = "将 '%s' 配置文件的 %s 配置替换为 '%s' 的配置？!!Warning_NoUndo!!",  -- "将 '目标' 配置文件的设计配置替换为 '源' 的配置？"

["ProfileEditor"] = "编辑配置文件",  -- 窗口标题。
["ProfileEditor_Field_name"] = "!!Name!!",
["ProfileEditor_FooterText"] = "通过设置菜单和编辑模式编辑配置文件。",


-- Share (Import/Export).
-- 分享（导入/导出）。
["ShareManager"] = "Bagshui 导入/导出",
["ShareManager_ExportPrompt"] = "按 Ctrl+C 复制。",
["ShareManager_ExportEncodeCheckbox"] = "优化分享",
["ShareManager_ExportEncodeExplanation"] = "请分享优化（压缩/编码）版本，因为它几乎可以保证在任何形式的互联网传输中存活。要查看正在分享的内容，请将未优化版本复制到文本编辑器中。",
["ShareManager_ImportPrompt"] = "使用 Ctrl+V 粘贴要导入的 Bagshui 数据。",


-- Catalog (Account-wide search).
-- 目录（账户范围搜索）。
["CatalogManager"] = "Bagshui 目录",
["CatalogManager_SearchBoxPlaceholder"] = "搜索账户范围的背包",
["CatalogManager_KnownCharacters"] = "显示来自的背包：",


-- Game Report
-- 游戏报告
["GameReport"] = "Bagshui 游戏环境报告",
["GameReport_Instructions"] = "在错误报告的环境部分中复制并粘贴以下文本。",


-- ### Rule Function Templates ###
-- See `Rules:AddRuleExamplesFromLocalization()` for details.
-- ### 规则函数模板 ###
-- 详情请参阅 `Rules:AddRuleExamplesFromLocalization()`。

-- Shared values for rule function !!placeholders!! that will be replaced when the localization is loaded.
-- 规则函数 !!占位符!! 的共享值，在本地化加载时将被替换。
["RuleFunction_LuaStringPatternsSupported"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. '使用 Lua 字符串模式时，请用 "/斜杠包裹/"。' .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_PT_CaseSensitiveParameters"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "集合名称区分大小写。" .. FONT_COLOR_CODE_CLOSE,

-- DO NOT Localize rule function names (`ActiveQuest()`, `BindsOnEquip()`, etc. as they are NOT localized in the rule environment).
-- 请勿本地化规则函数名称（如 `ActiveQuest()`、`BindsOnEquip()` 等，因为它们在规则环境中不进行本地化）。

["RuleFunction_ActiveQuest_Example1"] = 'ActiveQuest()',
["RuleFunction_ActiveQuest_ExampleDescription1"] = "检查物品是否是当前角色任务日志中的任务目标。",

["RuleFunction_Bag_GenericDescription"] = "检查物品是否在指定的背包编号中",
["RuleFunction_Bag_ExampleDescription"] = "检查物品是否在指定的背包编号中 (%d作为第#%d个物品存放于%s中。)",  -- "(0 是背包中的第 1 个容器)"
["RuleFunction_Bag_ExampleExtra1"] = 'Bag(num1, num2, numN)',
["RuleFunction_Bag_ExampleDescriptionExtra1"] = "检查物品是否在任何指定的背包编号中",

["RuleFunction_BagType_GenericDescription"] = "检查物品是否在指定类型的背包中。",
["RuleFunction_BagType_ExampleDescription"] = "检查物品是否在类型为 '%s' 的背包中。",
["RuleFunction_BagType_ExampleExtra1"] = 'BagType(ProfessionBag)',
["RuleFunction_BagType_ExampleDescriptionExtra1"] = "检查物品是否在当前角色的专业特定背包中。" .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "ProfessionBag 是此功能的特殊触发器，必须不在引号中。" .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_BagType_ExampleExtra2"] = 'BagType(AllProfessionBags)',
["RuleFunction_BagType_ExampleDescriptionExtra2"] = "检查物品是否在任何专业特定容器中。" .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "AllProfessionBags 是此功能的特殊触发器，必须不在引号中。" .. FONT_COLOR_CODE_CLOSE,
["RuleFunction_BagType_ExampleExtra3"] = 'BagType("type1", "type2", "typeN")',
["RuleFunction_BagType_ExampleDescriptionExtra3"] = '检查物品是否在任何指定类型的背包中。',

["RuleFunction_BindsOnEquip_Example1"] = 'BindsOnEquip()',
["RuleFunction_BindsOnEquip_ExampleDescription1"] = string.format("检查物品 %s 是否", string.lower(_G.ITEM_BIND_ON_EQUIP)),

["RuleFunction_CharacterLevelRange_GenericDescription"] = "检查物品是否基于当前角色的等级可用。",
["RuleFunction_CharacterLevelRange_Example1"] = 'CharacterLevelRange()',
["RuleFunction_CharacterLevelRange_ExampleDescription1"] = "检查物品是否在当前角色的等级可用。",
["RuleFunction_CharacterLevelRange_Example2"] = 'CharacterLevelRange(levelsBelowOrAbove)',
["RuleFunction_CharacterLevelRange_ExampleDescription2"] = "检查物品是否在当前角色的等级 <levelsBelowOrAbove> 可用。",
["RuleFunction_CharacterLevelRange_Example3"] = 'CharacterLevelRange(levelsBelow, levelsAbove)',
["RuleFunction_CharacterLevelRange_ExampleDescription3"] = "检查物品是否在当前角色的等级 <below> 到 <above> 之间可用。",

["RuleFunction_Count_GenericDescription"] = "检查堆叠中是否有指定数量的物品。",
["RuleFunction_Count_Example1"] = 'Count(number)',
["RuleFunction_Count_ExampleDescription1"] = "检查堆叠中是否有至少 <number> 个物品。",
["RuleFunction_Count_Example2"] = 'Count(min, max)',
["RuleFunction_Count_ExampleDescription2"] = "检查堆叠中是否有 <min> 到 <max> 个物品。",

["RuleFunction_EmptySlot_Example1"] = 'EmptySlot()',
["RuleFunction_EmptySlot_ExampleDescription1"] = "检查背包槽位中是否有物品。",

["RuleFunction_EquipLocation_GenericDescription"] = "检查物品是否可以装备在指定槽位。",
["RuleFunction_EquipLocation_ExampleDescription"] = "检查物品是否可以装备在 %s 槽位。",
["RuleFunction_EquipLocation_ExampleExtra1"] = 'EquipLocation()',
["RuleFunction_EquipLocation_ExampleDescriptionExtra1"] = "检查物品是否可装备。",
["RuleFunction_EquipLocation_ExampleExtra2"] = 'EquipLocation("Slot1", "Slot2", "SlotN")',
["RuleFunction_EquipLocation_ExampleDescriptionExtra2"] = "检查物品是否可以装备在任何指定槽位。",

["RuleFunction_Equipped_Example1"] = 'Equipped()',
["RuleFunction_Equipped_ExampleDescription1"] = "检查物品是否已装备（适用于匹配未绑定的装备）。" .. GRAY_FONT_COLOR_CODE .. BS_NEWLINE .. "你也可以传递与 EquipLocation() 相同的参数，以仅匹配特定的背包槽位。" .. FONT_COLOR_CODE_CLOSE,

["RuleFunction_Id_GenericDescription"] = '检查物品 ID 是否完全匹配。',
["RuleFunction_Id_Example1"] = 'Id(number)',
["RuleFunction_Id_ExampleDescription1"] = "检查物品 ID 是否完全匹配。",
["RuleFunction_Id_ExampleExtra1"] = 'Id(id1, id2, idN)',
["RuleFunction_Id_ExampleDescriptionExtra1"] = "检查物品 ID 是否匹配任何指定参数。",

["RuleFunction_ItemString_GenericDescription"] = "检查物品字符串是否匹配（用于匹配特定附魔或后缀 ID）。",
["RuleFunction_ItemString_Example1"] = 'ItemString(number)',
["RuleFunction_ItemString_ExampleDescription1"] = RED_FONT_COLOR_CODE .. "使用 Id(itemId) 代替。" .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. "检查物品字符串是否以 'item:<itemId>:' 开头",
["RuleFunction_ItemString_Example2"] = 'ItemString("item:number")',
["RuleFunction_ItemString_ExampleDescription2"] = RED_FONT_COLOR_CODE .. "使用 Id(itemId) 代替。" .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. "检查物品字符串是否以 'item:<itemId>:' 开头（item: 前缀是可选的）。",
["RuleFunction_ItemString_Example3"] = 'ItemString("item:number:number")',
["RuleFunction_ItemString_ExampleDescription3"] = "检查物品字符串是否以 'item:<itemId>:<enchantId>:' 开头（item: 前缀是可选的）。",
["RuleFunction_ItemString_Example4"] = 'ItemString("item:number:number:number")',
["RuleFunction_ItemString_ExampleDescription4"] = "检查物品字符串是否以 'item:<itemId>:<enchantId>:<suffixId>:' 开头（item: 前缀是可选的）。",
["RuleFunction_ItemString_ExampleExtra1"] = 'ItemString(param1, param2, paramN)',
["RuleFunction_ItemString_ExampleDescriptionExtra1"] = '检查物品字符串是否匹配任何指定参数。',

["RuleFunction_Location_GenericDescription"] = "检查物品是否存储在特定位置（背包、银行等）",
["RuleFunction_Location_ExampleDescription"] = "检查物品是否在你的 %s 中",
["RuleFunction_Location_ExampleExtra1"] = 'Location("loc1", "loc2", "locN")',
["RuleFunction_Location_ExampleDescriptionExtra1"] = "检查物品是否存储在任何指定位置。",

["RuleFunction_MinLevel_GenericDescription"] = "检查物品是否基于指定等级可用。",
["RuleFunction_MinLevel_Example1"] = 'MinLevel(level)',
["RuleFunction_MinLevel_ExampleDescription1"] = "检查物品是否在 <level> 或以上可用。",
["RuleFunction_MinLevel_Example2"] = 'MinLevel(min, max)',
["RuleFunction_MinLevel_ExampleDescription2"] = "检查物品是否在 <min> 到 <max> 等级之间可用。",

["RuleFunction_Name_GenericDescription"] = "检查物品名称是否包含指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Name_Example1"] = 'Name("string")',
["RuleFunction_Name_ExampleDescription1"] = "检查物品名称是否包含指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Name_ExampleExtra1"] = 'Name("string1", "string2", "stringN")',
["RuleFunction_Name_ExampleDescriptionExtra1"] = "检查物品名称是否包含任何指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",

["RuleFunction_NameExact_GenericDescription"] = "检查物品名称是否完全匹配指定字符串。",
["RuleFunction_NameExact_Example1"] = 'NameExact("string")',
["RuleFunction_NameExact_ExampleDescription1"] = "检查物品名称是否完全匹配指定字符串。",
["RuleFunction_NameExact_ExampleExtra1"] = 'NameExact("string1", "string2", "stringN")',
["RuleFunction_NameExact_ExampleDescriptionExtra1"] = "检查物品名称是否完全匹配任何指定字符串。",

["RuleFunction_Outfit_GenericDescription"] = "检查物品是否是 %s 中的套装的一部分。",
["RuleFunction_Outfit_Example1"] = 'Outfit()',
["RuleFunction_Outfit_ExampleDescription1"] = "检查物品是否是 %s 中的套装的一部分。",
["RuleFunction_Outfit_Example2"] = 'Outfit("Outfit Name")',
["RuleFunction_Outfit_ExampleDescription2"] = "检查物品是否是指定套装的一部分。",
["RuleFunction_Outfit_ExampleExtra1"] = 'Outfit("outfit1", "outfit2", "outfitN")',
["RuleFunction_Outfit_ExampleDescriptionExtra1"] = "检查物品是否是任何指定套装的一部分。",

["RuleFunction_PeriodicTable_GenericDescription"] = "检查物品是否属于规则表集合。!!RuleFunction_PT_CaseSensitiveParameters!!",
["RuleFunction_PeriodicTable_ExampleDescription"] = "检查物品是否属于 '%s' 规则表集合。!!RuleFunction_PT_CaseSensitiveParameters!!",
["RuleFunction_PeriodicTable_ExampleExtra1"] = 'PeriodicTable("set1", "set2", "setN")',
["RuleFunction_PeriodicTable_ExampleDescriptionExtra1"] = "检查物品是否属于任何指定的规则表集合。!!RuleFunction_PT_CaseSensitiveParameters!!",

["RuleFunction_ProfessionCraft_GenericDescription"] = "检查物品是否由当前角色的专业制作（仅限已学习配方）。",
["RuleFunction_ProfessionCraft_Example1"] = 'ProfessionCraft()',
["RuleFunction_ProfessionCraft_ExampleDescription1"] = "检查物品是否由当前角色的任何专业制作（仅限已学习配方）。",
["RuleFunction_ProfessionCraft_Example2"] = 'ProfessionCraft("Profession Name")',
["RuleFunction_ProfessionCraft_ExampleDescription2"] = "检查物品是否由当前角色的指定专业制作（仅限已学习配方）。",
["RuleFunction_ProfessionCraft_ExampleExtra1"] = 'ProfessionCraft("Profession1", "Profession2", "ProfessionN")',
["RuleFunction_ProfessionCraft_ExampleDescriptionExtra1"] = "检查物品是否由当前角色的任何指定专业制作（仅限已学习配方）。",

["RuleFunction_ProfessionReagent_GenericDescription"] = "检查物品是否是当前角色专业制作的材料（仅限已学习配方）。",
["RuleFunction_ProfessionReagent_Example1"] = 'ProfessionReagent()',
["RuleFunction_ProfessionReagent_ExampleDescription1"] = "检查物品是否是当前角色任何专业制作的材料（仅限已学习配方）。",
["RuleFunction_ProfessionReagent_Example2"] = 'ProfessionReagent("Profession Name")',
["RuleFunction_ProfessionReagent_ExampleDescription2"] = "检查物品是否是当前角色指定专业的材料（仅限已学习配方）。",
["RuleFunction_ProfessionReagent_ExampleExtra1"] = 'ProfessionReagent("Profession1", "Profession2", "ProfessionN")',
["RuleFunction_ProfessionReagent_ExampleDescriptionExtra1"] = "检查物品是否是当前角色任何指定专业的材料（仅限已学习配方）。",

["RuleFunction_Quality_GenericDescription"] = "检查物品是否具有指定品质。",
["RuleFunction_Quality_ExampleDescription"] = "检查物品是否具有 %s 品质。",
["RuleFunction_Quality_ExampleExtra1"] = 'Quality(qual1, qual2, qualN)',
["RuleFunction_Quality_ExampleDescriptionExtra1"] = "检查物品是否具有任何指定品质。",

["RuleFunction_RequiresClass_GenericDescription"] = "检查物品是否可由指定职业使用。",
["RuleFunction_RequiresClass_ExampleDescription"] = "检查物品是否可由 %s 职业使用。",
["RuleFunction_RequiresClass_ExampleExtra1"] = 'RequiresClass("class1", "class2", "classN")',
["RuleFunction_RequiresClass_ExampleDescriptionExtra1"] = "检查物品是否可由任何指定职业使用。",

["RuleFunction_Soulbound_Example1"] = 'Soulbound()',
["RuleFunction_Soulbound_ExampleDescription1"] = "检查物品是否已绑定。",

["RuleFunction_Stacks_Example1"] = 'Stacks()',
["RuleFunction_Stacks_ExampleDescription1"] = "检查物品是否可以堆叠。",

["RuleFunction_Subtype_GenericDescription"] = "检查物品是否具有指定子类型",
["RuleFunction_Subtype_ExampleDescription"] = "检查物品的子类型是否为 '%s'。",
["RuleFunction_Subtype_ExampleExtra1"] = 'Subtype("type1", "type2", "typeN")',
["RuleFunction_Subtype_ExampleDescriptionExtra1"] = "检查物品是否具有任何指定子类型。",

["RuleFunction_Tooltip_GenericDescription"] = "检查提示是否包含指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Tooltip_Example1"] = 'Tooltip("string")',
["RuleFunction_Tooltip_ExampleDescription1"] = "检查物品提示是否包含指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",
["RuleFunction_Tooltip_ExampleExtra1"] = 'Tooltip("string1", "string2", "stringN")',
["RuleFunction_Tooltip_ExampleDescriptionExtra1"] = "检查提示是否包含任何指定字符串。!!RuleFunction_LuaStringPatternsSupported!!",

["RuleFunction_Transmog_GenericDescription"] = "检查物品是否在你的幻化收藏中或是否有资格进行幻化。",
["RuleFunction_Transmog_Example1"] = 'Transmog()',
["RuleFunction_Transmog_ExampleDescription1"] = '检查物品是否在你的幻化收藏中。',
["RuleFunction_Transmog_Example2"] = 'Transmog(Eligible)',
["RuleFunction_Transmog_ExampleDescription2"] = '检查物品是否有资格进行幻化。',
["RuleFunction_Transmog_Example3"] = 'Transmog(Eligible) and not Transmog()',
["RuleFunction_Transmog_ExampleDescription3"] = '检查物品是否可幻化但尚未添加到你的收藏中。',

["RuleFunction_Type_GenericDescription"] = "检查物品是否具有指定类型。",
["RuleFunction_Type_ExampleDescription"] = "检查物品的类型是否为 '%s'。",
["RuleFunction_Type_ExampleExtra1"] = 'Type("type1", "type2", "typeN")',
["RuleFunction_Type_ExampleDescriptionExtra1"] = "检查物品是否具有任何指定类型。",

["RuleFunction_Usable_Example1"] = 'Usable()',
["RuleFunction_Usable_ExampleDescription1"] = "检查物品是否可由当前角色使用（基于等级、技能和专业）。",

["RuleFunction_Wishlist_Example1"] = 'Wishlist()',
["RuleFunction_Wishlist_ExampleDescription1"] = "检查物品是否在 %s 愿望清单上。",


-- ### Tips/Help ###
-- ### 提示/帮助 ###
["BagshuiTooltipIntro"] = "显示Bagshui信息提示",


-- ### Errors/Warnings ###
-- ### 错误/警告 ###

["Error"] = "错误",
["Error_AddonDependency_Generic"] = "需要额外的插件来启用此规则函数（请参阅 Bagshui wiki 上的规则页面）。",
["Error_AddonDependency_Generic_FunctionName"] = "需要额外的插件来启用 %s 的使用（请参阅 Bagshui wiki 上的规则页面）。",
["Error_AddonDependency"] = "%s 未安装或未启用。",
["Error_CategoryEvaluation"] = "%s：%s",  -- "<类别名称>: <错误消息>"
["Error_DuplicateName"] = "已经存在名为 %s 的 %s。",  -- "已经存在一个名为<名称>的<对象类型>。"
["Error_GroupNotFound"] = "未找到组ID %s。",
["Error_HearthstoneNotFound"] = "未找到炉石。",
["Error_ImportInvalidFormat"] = "导入失败：数据格式意外。",
["Error_ImportVersionTooNew"] = "导入失败：请升级到最新版本的Bagshui。",
["Error_ItemCategoryUnknown"] = "！未知！（这不应该发生）。",  -- 如果物品没有类别，则显示在提示中。
["Error_RestackFailed"] = "重新堆叠 %s 失败",
["Error_SaveFailed"] = "%s 无法保存：%s",
["Error_Suffix_Retrying"] = "%s；正在重试…",  -- 当操作失败但正在再次尝试时，附加到错误消息的末尾。

["Info_NoDelete"] = BS_NEWLINE .. GRAY_FONT_COLOR_CODE .. "不会删除类别。" .. FONT_COLOR_CODE_CLOSE,

["Warning_NoUndo"] = BS_NEWLINE .. RED_FONT_COLOR_CODE .. "这无法撤销！" .. FONT_COLOR_CODE_CLOSE,
["Warning_RuleFunctionOverwrite"] = "覆盖现有的规则环境函数 %s()",
["Warning_BuiltinRuleFunctionCollision"] = "未加载第三方规则函数/别名 %s()，因为它是内置Bagshui规则函数的名称/别名",

["Compat_ReloadUIPrompt"] = "需要重新加载UI。",
["Compat_pfUIBags"] = "强烈建议禁用pfUI背包模块以避免多个银行窗口。",
["Compat_pfUIBagsInfo"] = "如果你改变主意，可以在pfUI配置 > 组件 > 模块中管理pfUI背包模块。",
["Compat_tDFAllInOneBags"] = "如果你希望使用Bagshui作为默认背包，建议禁用tDF全能背包模块。",
["Compat_tDFAllInOneBagsInfo"] = "如果你改变主意，可以在tDF选项中管理tDF全能背包模块。",

-- Rule function errors.
-- 规则函数错误。
["Error_RuleFunctionInvalid"] = '«%s» 不是有效的规则函数 -- 如果打算作为参数，请确保像 Function("parameter") 这样引用它',
["Error_RuleVariablePropertyInvalid"] = "«%s» 不是有效的 %s 属性",
["Error_RuleExecution"] = "规则函数 %s 出错：%s",
["Error_RuleNoArguments"] = "至少需要一个参数，但未提供任何参数",
["Error_RuleNilArgument"] = "无效参数 %s：不允许为 nil",
["Error_RuleInvalidArgument"] = "无效参数 %s：«%s» 是 %s，预期为 %s",
["Error_RuleInvalidArgumentType"] = "%s 不是有效的参数类型；允许的参数类型为：%s",
["Error_RuleTooManyArguments"] = "规则函数限制为50个参数。要使用更多参数，请添加对 %s 的第二次调用，并用 'or' 分隔，例如：or %s(param1, param2, etc)",

["Error_Rule_ItemLevelStat"] = "经典旧世没有物品等级（ilvl），因此 ItemLevelStat() 不可用。",
["Error_Rule_ItemStat"] = "ItemStat() 和 ItemStatActive() 当前不受支持。尝试使用Tooltip() 来检查属性。",

-- ### Logging ###
-- ### 日志记录 ###

["LogWindowTitle"] = "Bagshui日志",
["ClearLog"] = "清除日志",
-- Log types.
-- 日志类型。
["Log_Info"] = "信息",
["Log_Warn"] = "警告",
["Log_Error"] = "错误",

-- Settings reset messages.
-- 设置重置消息。
["SettingReset_LogStart"] = "%s 已重置",
["SettingReset_InvalidValue"] = "无效值",
["SettingReset_Outdated"] = "过时",

["SettingReset_WindowPositionAuto"] = "窗口位置已重置，因为它位于屏幕外。",
["SettingReset_WindowPositionManual"] = "窗口位置已重置。",




-- ### Help/Misc ###
-- ### 帮助/杂项 ###

["BagshuiDataReset"] = "由于版本更改，配置已重置（之前：%s / 新：%s）。",
["HowToUrl"] = "WoW无法直接打开URL，因此请复制此URL（Ctrl+C）并在你的网页浏览器中查看。",


-- ### Settings: Tooltips, Scopes, Special ###
-- ### 设置：提示、作用域、特殊 ###

-- Automatically generated settings.
-- 自动生成的设置。
["Setting_HookBagTooltipTitle"] = "挂钩 %s",
["Setting_HookBagTooltipText"] = "接管切换 %s 的键绑定。",
-- Special settings stuff.
-- 特殊设置内容。
["SettingScope_Account"] = "适用于此账户上的所有角色。",
["SettingScope_Character"] = "适用于此角色的所有背包窗口。",
["Setting_DisabledBy_HideGroupLabels"] = "× 已禁用，因为活动结构已启用隐藏组标签。",
["Setting_EnabledBy_ColorblindMode"] = "√ 已启用，因为色盲模式已开启。",
["Setting_Profile_SetAllHint"] = "Shift+点击以用于所有配置文件类型。",
["Setting_Reset_TooltipText"] = "重置为默认值：Ctrl+Alt+Shift+点击。",
["Setting_Profile_Use"] = "将此设为活动的 %s %s 配置文件。",  -- 设为活动的背包设计配置文件。


-- ### Settings ###
-- ### 设置 ###
-- 键为settingName、settingName_TooltipTitle或settingName_TooltipText。
-- 有关更多信息，请参阅 `Settings:InitSettingsInfo()` 声明中的本地化说明。

["aboutBagshui_TooltipTitle"] = "关于Bagshui",

["colorblindMode"] = "色盲模式",
["colorblindMode_TooltipText"] = "无论设计设置如何，始终显示物品品质和不可用徽章。",

["createNewProfileDesign"] = "复制",
["createNewProfileDesign_TooltipTitle"] = "创建设计配置文件副本",
["createNewProfileDesign_TooltipText"] = "为新角色复制默认配置文件。",

["createNewProfileStructure"] = "复制",
["createNewProfileStructure_TooltipTitle"] = "创建结构配置文件副本",
["createNewProfileStructure_TooltipText"] = "为新角色复制默认配置文件。",

["defaultSortOrder"] = "排序顺序",
["defaultSortOrder_TooltipTitle"] = "默认排序顺序",
["defaultSortOrder_TooltipText"] = "当组没有指定排序顺序时，将如何排序。",

["defaultProfileDesign"] = "设计",
["defaultProfileDesign_TooltipTitle"] = "默认设计配置文件",
["defaultProfileDesign_TooltipText"] = "用于新角色的配置文件。",

["defaultProfileStructure"] = "结构",
["defaultProfileStructure_TooltipTitle"] = "默认结构配置文件",
["defaultProfileStructure_TooltipText"] = "用于新角色的配置文件。",

["disableAutomaticResort"] = "手动重组",
["disableAutomaticResort_TooltipText"] = "当背包窗口关闭并重新打开时，不自动分类和排序物品。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "这与将默认排序顺序设置为手动不同。" .. FONT_COLOR_CODE_CLOSE,

["windowDoubleClickActions"] = "双击",
["windowDoubleClickActions_TooltipText"] = "双击背包窗口的空白部分以显示/隐藏所有工具栏。" .. BS_NEWLINE .. "Alt+双击以切换位置锁定。",

["globalInfoTooltips"] = "无处不在",
["globalInfoTooltips_TooltipTitle"] = "挂钩所有物品提示",
["globalInfoTooltips_TooltipText"] = "当按住Alt时，在任何地方（即角色窗口、聊天链接等）显示Bagshui信息提示与目录计数。",

["groupBackgroundDefault"] = "背景",
["groupBackgroundDefault_TooltipTitle"] = "默认组背景颜色",
["groupBackgroundDefault_TooltipText"] = "当未设置组特定颜色时使用的背景颜色。",

["groupBorderDefault"] = "边框",
["groupBorderDefault_TooltipTitle"] = "默认组边框颜色",
["groupBorderDefault_TooltipText"] = "当未设置组特定颜色时使用的边框颜色。",

["groupLabelDefault"] = "标签",
["groupLabelDefault_TooltipTitle"] = "默认组标签颜色",
["groupLabelDefault_TooltipText"] = "当未设置组特定颜色时使用的标签颜色。",
["groupMargin"] = "边距",
["groupMargin_TooltipTitle"] = "组边距",
["groupMargin_TooltipText"] = "组之间的空间。",

["groupPadding"] = "填充",
["groupPadding_TooltipTitle"] = "组填充",
["groupPadding_TooltipText"] = "组边框与内部物品之间的空间。",

["groupUseSkinColors"] = "使用 %s 颜色",
["groupUseSkinColors_TooltipTitle"] = "%s 颜色用于组",
["groupUseSkinColors_TooltipText"] = "使用 %s 的颜色而不是 Bagshui 的设置。",

["hideGroupLabelsOverride"] = "隐藏组标签",
["hideGroupLabelsOverride_TooltipText"] = "即使启用了设计组标签设置，也抑制组标签的显示。",

["itemMargin"] = "边距",
["itemMargin_TooltipTitle"] = "物品边距",
["itemMargin_TooltipText"] = "物品之间的空间。",

["itemActiveQuestBadges"] = "活跃任务",
["itemActiveQuestBadges_TooltipTitle"] = "物品槽活跃任务徽章",
["itemActiveQuestBadges_TooltipText"] = "当物品是活跃任务的目标时，在顶部显示一个 ?。",

["itemQualityBadges"] = "!!Quality!!",
["itemQualityBadges_TooltipTitle"] = "物品品质徽章",
["itemQualityBadges_TooltipText"] = "在左下角显示物品稀有度等级的图标。",

["itemUsableBadges"] = "不可用",
["itemUsableBadges_TooltipTitle"] = "物品不可用徽章",
["itemUsableBadges_TooltipText"] = "在左上角显示不可用/已学习物品的图标。",

["itemUsableColors"] = "不可用",
["itemUsableColors_TooltipTitle"] = "物品不可用着色",
["itemUsableColors_TooltipText"] = "为不可用/已学习物品应用红色/绿色覆盖。",

["itemSize"] = "大小",
["itemSize_TooltipTitle"] = "物品大小",
["itemSize_TooltipText"] = "物品的高度和宽度。",

["itemStockBadges"] = "库存",
["itemStockBadges_TooltipTitle"] = "物品库存徽章",
["itemStockBadges_TooltipText"] = "指示物品何时为新增或数量增加/减少。",

["itemStockChangeClearOnInteract"] = "点击时清除",
["itemStockChangeClearOnInteract_TooltipTitle"] = "点击时清除物品库存徽章",
["itemStockChangeClearOnInteract_TooltipText"] = "在交互时立即重置物品库存更改状态（新增/增加/减少）。",

["itemStockChangeExpiration"] = "过期",
["itemStockChangeExpiration_TooltipTitle"] = "物品库存徽章更改过期",
["itemStockChangeExpiration_TooltipText"] = "在此时间过后，物品将不再被视为已更改（新增/增加/减少）。",

["itemStockBadgeFadeDuration"] = "淡出",
["itemStockBadgeFadeDuration_TooltipTitle"] = "物品库存徽章淡出持续时间",
["itemStockBadgeFadeDuration_TooltipText"] = "库存更改徽章（新增/增加/减少）将在过期设置之前开始淡出。",

["profileDesign"] = "配置文件",
["profileDesign_TooltipTitle"] = "设计配置文件",
["profileDesign_TooltipText"] = "用于设计（背包外观）的配置文件。",

["profileStructure"] = "配置文件",
["profileStructure_TooltipTitle"] = "结构配置文件",
["profileStructure_TooltipText"] = "用于结构（背包组织方式）的配置文件。",

["replaceBank"] = "替换银行",
["replaceBank_TooltipText"] = "使用 Bagshui 银行而不是暴雪银行。",

["resetStockState"] = "标记物品为未更改",
["resetStockState_TooltipText"] = "将此背包中的所有物品标记为不再新增、增加或减少。",

["showBagBar"] = "背包栏",
["showBagBar_TooltipText"] = "在左下角显示背包栏。",

["showFooter"] = "底部工具栏",
["showFooter_TooltipTitle"] = "底部工具栏",
["showFooter_TooltipText"] = "显示底部工具栏。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "隐藏此选项将隐藏物品下方的所有内容，包括背包栏和金钱显示。" .. FONT_COLOR_CODE_CLOSE,

["showGroupLabels"] = "标签",
["showGroupLabels_TooltipTitle"] = "组标签",
["showGroupLabels_TooltipText"] = "在组上方显示标签。",

["showHeader"] = "顶部工具栏",
["showHeader_TooltipTitle"] = "顶部工具栏",
["showHeader_TooltipText"] = "显示顶部工具栏。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "隐藏此选项将隐藏物品上方的所有内容，包括关闭按钮，因此你需要通过键绑定、动作栏按钮或宏来关闭。" .. FONT_COLOR_CODE_CLOSE,

["showHearthstone"] = "炉石按钮",
["showHearthstone_TooltipText"] = "显示炉石按钮。" .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. "仅适用于背包。" .. FONT_COLOR_CODE_CLOSE,

["showInfoTooltipsWithoutAlt"] = "无需 Alt 显示",
["showInfoTooltipsWithoutAlt_TooltipText"] = "始终显示 Bagshui 信息提示（按住 Shift 以暂时隐藏）。",

["showLogWindow_TooltipText"] = "打开 Bagshui 日志窗口。",

["showMoney"] = "金钱",
["showMoney_TooltipText"] = "在右下角显示金钱。",

["stackEmptySlots"] = "堆叠空槽",
["stackEmptySlots_TooltipTitle"] = "堆叠空槽",
["stackEmptySlots_TooltipText"] = "将空槽合并为单个堆叠，点击时可展开（专业背包将单独堆叠）。",

["toolbarButtonColor"] = "图标",
["toolbarButtonColor_TooltipTitle"] = "工具栏图标颜色",
["toolbarButtonColor_TooltipText"] = "用于此背包工具栏图标的颜色。",

["toggleBagsWithAuctionHouse"] = "拍卖行",
["toggleBagsWithAuctionHouse_TooltipTitle"] = "与拍卖行切换背包",
["toggleBagsWithAuctionHouse_TooltipText"] = "当你访问拍卖行时打开和关闭背包。",

["toggleBagsWithBankFrame"] = "银行",
["toggleBagsWithBankFrame_TooltipTitle"] = "与银行切换背包",
["toggleBagsWithBankFrame_TooltipText"] = "当你访问银行时打开和关闭背包。",

["toggleBagsWithMailFrame"] = "邮件",
["toggleBagsWithMailFrame_TooltipTitle"] = "与邮件切换背包",
["toggleBagsWithMailFrame_TooltipText"] = "当你使用邮箱时打开和关闭背包。",

["toggleBagsWithTradeFrame"] = "交易",
["toggleBagsWithTradeFrame_TooltipTitle"] = "与交易切换背包",
["toggleBagsWithTradeFrame_TooltipText"] = "当你与其他玩家交易时打开和关闭背包。",

["windowAnchorXPoint"] = "水平",
["windowAnchorXPoint_TooltipTitle"] = "水平锚点",
["windowAnchorXPoint_TooltipText"] = "窗口将从屏幕的此边缘水平增长。",

["windowAnchorYPoint"] = "垂直",
["windowAnchorYPoint_TooltipTitle"] = "垂直锚点",
["windowAnchorYPoint_TooltipText"] = "窗口将从屏幕的此边缘垂直增长。",

["windowBackground"] = "背景",
["windowBackground_TooltipTitle"] = "窗口背景颜色",
["windowBackground_TooltipText"] = "用于此背包窗口背景的颜色。",

["windowBorder"] = "边框",
["windowBorder_TooltipTitle"] = "窗口边框颜色",
["windowBorder_TooltipText"] = "用于此背包窗口边框的颜色。",

["windowLocked"] = "锁定位置",
["windowLocked_TooltipText"] = "不允许移动此窗口。",

["windowMaxColumns"] = "最大列数",
["windowMaxColumns_TooltipText"] = "窗口宽度限制为每行的物品数量。",

["windowScale"] = "缩放",
["windowScale_TooltipTitle"] = "窗口缩放",
["windowScale_TooltipText"] = "整个窗口的相对大小。",

["windowUseSkinColors"] = "使用 %s 颜色",
["windowUseSkinColors_TooltipTitle"] = "%s 颜色用于窗口",
["windowUseSkinColors_TooltipText"] = "使用 %s 的颜色而不是 Bagshui 的设置。",


})


end)