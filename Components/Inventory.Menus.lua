-- Bagshui Inventory Prototype: Menus
--
-- Most non-Settings menu-related things for Inventory classes are here, except for
-- the calls to open menus - those are in OnClick functions.

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory

-- Group menu for removing categories should not allow removing the default category (Uncategorized).
local GROUP_CATEGORY_REMOVE_MENU_IDS_TO_DISABLE = { BS_DEFAULT_CATEGORY_ID }



--- Prepare the per-Inventory-class-instance Menus class instance.
--- This includes building all the menus.
function Inventory:InitMenus()

	-- Passing self to set the Menus class' inventoryClassInstance property so that
	-- it will call Inventory:GenerateSettingsMenuItem() from Menus:LoadMenu() when
	-- the menu item has a _bagshuiSettingName property.
	self.menus = Bagshui.prototypes.Menus:New(self)


	--- All Category menu entries should display which group they're assigned to.
	--- Attaching this function to the `tooltipTextFunc` property of the `value`
	--- table of the initiating menu item makes that happen.
	---@param categoryId any Category ID.
	---@return string tooltipText
	self._autoSplitMenuItem_Categories_TooltipTextFunc = function(categoryId)
		-- If assigned, return `Category is active in <Inventory Type> group '<Group Name>'`.
		-- If unassigned, `Category is not currently in a group`.
		local tooltipText = L.EditMode_CategoryNotInGroup
		if self.categoriesToGroups[categoryId] and self.groups[self.categoriesToGroups[categoryId]] then
			local row, column = self:GroupIdToRowColumn(self.categoriesToGroups[categoryId])
			local rowColumnString = string.format(
				GRAY_FONT_COLOR_CODE .. " [%s %s, %s %s]" .. FONT_COLOR_CODE_CLOSE,
				L.Row, row,
				L.Column, column
			)
			tooltipText = string.format(L.EditMode_CategoryInGroup, self.groups[self.categoriesToGroups[categoryId]].name or L.Unnamed) .. rowColumnString
		end
		return tooltipText
	end


	-- Character menu.
	-- This MUST happen before the main menu is generated because the `generateMenuValueFunc`
	-- property of the Character entry on the menu references it.
	self.menus:AddMenu(
		"Character",
		-- Level 1 is an auto-split Characters menu full replacement.
		{
			autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CHARACTERS,
			func = function(_, character)
				self:SetCharacter(character)
			end,
			-- `self._characterMenuActiveCharacter` is managed by `Inventory:SetCharacter()` instead
			-- of the `OpenMenu()` callback so that it's always up to date for both the toolbar
			-- and the main menu.
			idsToCheck = self._characterMenuActiveCharacter,
		}
	)


	-- Main Menu.

	self.menus:AddMenu(
		"Main",
		-- 1
		{

			-- Bagshui [Inventory Type]
			{
				text = BS_FONT_COLOR.BAGSHUI .. "Bagshui " .. self.inventoryTypeLocalized .. FONT_COLOR_CODE_CLOSE,
				isTitle = true,
				checked = false,
				notCheckable = true,
			},
			{
				text = L.EditMode,
				tooltipText = L.Menu_Main_EditMode_TooltipText,
				icon = BsUtil.GetFullTexturePath("Icons\\Edit"),
				_bagshuiCheckedFunc = function()
					return self.editMode
				end,
				func = function()
					self:ToggleEditMode()
				end,
			},
			{
				text = string.format(L.Symbol_Ellipsis, L.Settings),
				tooltipTitle = L.Settings,
				tooltipText = L.Menu_Main_Settings_TooltipText,
				value = "Settings",
				checked = false,
				icon = BsUtil.GetFullTexturePath("Icons\\Settings"),
				func = function()
					self.menus:OpenMenu("Settings")
				end
			},

			-- Actions (built out below from self.toolbarAndMainMenuItems).
			{
				text = L.Actions,
				isTitle = true,
				notCheckable = true,
				checked = false,
			},

			-- Manage
			{
				text = L.Manage,
				isTitle = true,
				notCheckable = true,
				checked = false,
			},
			{
				text = string.format(L.Symbol_Ellipsis, L.Categories),
				tooltipTitle = L.Categories,
				tooltipText = L.Menu_Main_ManageCategories_TooltipText,
				checked = false,
				func = function()
					BsCategories:Open()
				end,
				icon = BsUtil.GetFullTexturePath("Icons\\Category"),
			},
			{
				text = string.format(L.Symbol_Ellipsis, L.SortOrders),
				tooltipTitle = L.SortOrders,
				tooltipText = L.Menu_Main_ManageSortOrders_TooltipText,
				checked = false,
				func = function()
					BsSortOrders:Open()
				end,
				icon = BsUtil.GetFullTexturePath("Icons\\SortOrder"),
			},
			{
				text = string.format(L.Symbol_Ellipsis, L.Profiles),
				tooltipTitle = L.Profiles,
				tooltipText = L.Menu_Main_ManageProfiles_TooltipText,
				checked = false,
				func = function()
					BsProfiles:Open()
				end,
				icon = BsUtil.GetFullTexturePath("Icons\\Characters"),
			},

			-- Toggle (built out below).
			{
				text = L.Toggle,
				isTitle = true,
				notCheckable = true,
			},

		}
	)


	-- Add toolbar buttons as menu items.
	-- Find insertion point.
	local toolbarInsertPoint
	for i, entry in ipairs(self.menus.menuList.Main.levels[1]) do
		if entry.text == L.Actions then
			toolbarInsertPoint = i + 1
			break
		end
	end
	-- Add to menu.
	if toolbarInsertPoint then
		for i = table.getn(self.toolbarAndMainMenuItems), 1, -1 do
			local toolbarItem = self.toolbarAndMainMenuItems[i]

			local menuItem = {
				text = toolbarItem.tooltipTitle,
				tooltipText = toolbarItem.tooltipText,
				checked = false,
				icon = toolbarItem.texture,
				hasArrow = toolbarItem.menuHasArrow,
				_bagshuiHideArrow = toolbarItem.menuHideArrow,
				_bagshuiDisabledFunc = toolbarItem._bagshuiDisabledFunc or function()
					return (self.ui.buttons.toolbar[toolbarItem.id]:IsEnabled() == 0)
				end,
				_bagshuiCheckedFunc = toolbarItem._bagshuiCheckedFunc,
			}

			if not toolbarItem.menuIgnoreOnClick then
				menuItem.func = toolbarItem.func or function()
					self.ui.buttons.toolbar[toolbarItem.id]:GetScript("OnClick")()
				end
			end

			if toolbarItem.getMenuValueProp then
				menuItem.value = toolbarItem.getMenuValueProp()
			end


			table.insert(
				self.menus.menuList.Main.levels[1],
				toolbarInsertPoint,
				menuItem
			)
		end
	else
		self:PrintWarning("Failed to find main menu insertion point for actions")
	end


	-- Add Toggle entries for inventory all types.
	-- If anything is ever added below the Toggle menu section, this will need to
	-- be modified to find the insertion point like the toolbar buttons above.
	for inventoryType, inventoryTypeLocalized in self:OtherInventoryTypesInToolbarIconOrder(false, true) do
		local inventoryClass = Bagshui.components[inventoryType]
		table.insert(
			self.menus.menuList.Main.levels[1],
			{
				text = inventoryTypeLocalized,
				tooltipText = string.format(L.Menu_Main_Toggle_TooltipText, inventoryTypeLocalized),
				_bagshuiHideFunc = function()
					-- Hide the entry for the current inventory type unless the top toolbar is hidden.
					return (
						inventoryClass == self
						and self.settings.showHeader
					)
				end,
				_bagshuiCheckedFunc = function()
					return inventoryClass:Visible()
				end,
				func = function()
					inventoryClass:Toggle(true)
				end,
				icon = BsUtil.GetFullTexturePath("Icons\\" .. inventoryType),
			}
		)
	end
	-- Catalog.
	table.insert(
		self.menus.menuList.Main.levels[1],
		{
			text = L.Catalog,
			tooltipTitle = L.Toolbar_Catalog_TooltipTitle,
			tooltipText = L.Toolbar_Catalog_TooltipText,
			_bagshuiCheckedFunc = function()
				return BsCatalog:Visible()
			end,
			func = function()
				BsCatalog:Toggle(true)
			end,
			icon = BsUtil.GetFullTexturePath("Icons\\Catalog"),
		}
	)


	-- Settings Menu.

	-- Start with an empty menu since it'll be populated by BuildSettingsMenuFromConfig().
	self.menus:AddMenu("Settings", nil, nil, nil,
		--- Settings OpenMenu callback.
		---@param menu table Menu table.
		function(menu)
			self:OpenSettingsMenu(menu)
			-- Prevent a second call to ShowMenu() from Menus:OpenMenuCallback().
			return false
		end
	)

	-- Populate the Settings menu.
	self:BuildSettingsMenuFromConfig(
		Bagshui.config.Settings[BS_SETTING_APPLICABILITY.INVENTORY],
		self.menus.menuList.Settings,
		1
	)


	-- Group Menu.
	local groupDefaults = Bagshui.config.Settings[BS_SETTING_APPLICABILITY.GROUP]
	local groupMenuFakeItem = BsUtil.TableCopy(BS_ITEM_SKELETON)
	groupMenuFakeItem._bagshuiCategoryConfigTrigger = true

	-- The Group menu can only be opened when Edit Mode is active, so it makes
	-- sense to use the Edit Mode window update function when a Group setting
	-- is changed instead of directly calling the Inventory:Update() function. 
	local editModeWindowUpdate = function()
		self:EditModeWindowUpdate(false)
	end

	self.menus:AddMenu(
		"Group",
		-- 1
		{
			-- Group (first item is updated to the group name by the OpenMenu callback).
			{
				_bagshuiMenuItemId = "GroupNameTitle",
				text = L.Group,
				icon = BsUtil.GetFullTexturePath("Icons\\Group"),
				isTitle = true,
				notCheckable = true,
			},
			{
				text = L.Settings,
				tooltipTitle = L.Menu_Group_Settings_TooltipTitle,
				tooltipText = L.Menu_Group_Settings_TooltipText,
				value = "Options",
				hasArrow = true,
			},
			{
				text = L.Rename,
				tooltipTitle = L.Menu_Group_Rename_TooltipTitle,
				tooltipText = L.Menu_Group_Rename_TooltipText,
				func = function(groupId)
					self:RenameGroup(groupId, false)
				end,
			},
			{
				text = L.Move,
				tooltipTitle = L.Menu_Group_Move_TooltipTitle,
				tooltipText = L.Menu_Group_Move_TooltipText,
				func = function(groupId)
					self:EditModePickUpGroup(groupId)
				end,
			},
			{
				text = L.Delete,
				tooltipTitle = L.Menu_Group_Delete_TooltipTitle,
				tooltipText = L.Menu_Group_Delete_TooltipText,
				func = function(groupId)
					self:DeleteGroup(groupId)
				end,
			},

			-- Categories indented sub-header.
			{
				text = BS_MENU_SUBTITLE_INDENT .. L.Categories,
				icon = BsUtil.GetFullTexturePath("Icons\\Category"),
				isTitle = true,
				notCheckable = true,
			},
			{
				-- The Add/Remove menu is the Categories auto-split menu with nothing hidden.
				_bagshuiMenuItemId = "CategoryAddRemove",
				text = L.AddSlashRemove,
				tooltipTitle = string.format(L.Prefix_Add, L.Category),
				tooltipText = L.Menu_Group_Add_Category_TooltipText,
				value = {
					-- Categories auto-split menu trigger and parameters.
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
					func = function(groupId, categoryId)
						self:ToggleCategoryGroupAssignment(categoryId, groupId, true)
					end,
					tooltipTextFunc = self._autoSplitMenuItem_Categories_TooltipTextFunc,

					-- Disable categories (currently just Uncategorized) when they're checked to prevent removal from the layout.
					disableFunc = function(categoryId, menuItem, triggeringMenuValue)
						if menuItem.checked and BsUtil.TableContainsValue(GROUP_CATEGORY_REMOVE_MENU_IDS_TO_DISABLE, categoryId) ~= nil then
							return true
						end
						return false
					end,

					-- New...
					autoSplitMenuExtraItems = {
						{
							text = string.format(L.Symbol_Ellipsis, L.New),
							tooltipTitle = L.Menu_Group_New_Category_TooltipTitle,
							tooltipText = L.Menu_Group_New_Category_TooltipText,
							checked = false,
							value = {
								func = function(groupId, _)
									local template = BsUtil.TableCopy(BS_NEW_CATEGORY_TEMPLATE)
									BsCategories:NewObject(
										template,
										-- onFirstSave function
										function(categoryId)
											if string.len(categoryId or "") > 0 and string.len(groupId or "") > 0 then
												self:AssignCategoryToGroup(categoryId, groupId, true)
											end
										end
									)

								end,
							},
						},
					},
				},
				hasArrow = true,
			},
			{
				-- The Move menu is the Categories auto-split menu with only the assigned categories visible.
				_bagshuiMenuItemId = "CategoryMove",
				text = L.Move,
				tooltipTitle = string.format(L.Prefix_Move, L.Category),
				tooltipText = L.Menu_Group_Move_Category_TooltipText,
				value = {
					-- Categories auto-split menu trigger and parameters.
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
					func = function(_, categoryId)
						self:EditModePickUpCategory(categoryId, true)
					end,
					tooltipTextFunc = self._autoSplitMenuItem_Categories_TooltipTextFunc,
				},
				hasArrow = true,
			},
			{
				-- The Configure menu is the Categories auto-split menu with only the assigned categories visible.
				_bagshuiMenuItemId = "CategoryConfig",
				text = L.Menu,
				tooltipTitle = string.format(L.Prefix_OpenMenuFor, L.Category),
				tooltipText = L.Menu_Group_Configure_Category_TooltipText,
				value = {
					-- Categories auto-split menu trigger and parameters.
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
					func = function(_, categoryId)
						groupMenuFakeItem.bagshuiCategoryId = categoryId
						self.menus:OpenMenu("Item", groupMenuFakeItem, nil, _G.UIParent, _G.DropDownList1:GetLeft(), _G.DropDownList1:GetTop())
					end,
					tooltipTextFunc = self._autoSplitMenuItem_Categories_TooltipTextFunc,
				},
				hasArrow = true,
			},

			-- Sorting indented sub-header.
			{
				text = BS_MENU_SUBTITLE_INDENT .. L.Sorting,
				icon = BsUtil.GetFullTexturePath("Icons\\SortOrder"),
				isTitle = true,
				notCheckable = true,
			},
			{
				-- The Sort Order menu is the Sort Order auto-split menu with the active sort order checked.
				text = L.SortOrder,
				tooltipTitle = L.Menu_Group_SortOrder_TooltipTitle,
				tooltipText = L.Menu_Group_SortOrder_TooltipText,
				value = {
					-- Sort Order auto-split menu trigger and parameters.
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.SORT_ORDERS,
					func = function(groupId, sortOrderId)
						self:AssignSortOrderToGroup(sortOrderId, groupId)
					end,
					-- Add [Structure Default] to the end of the default sort order's name.
					nameRevisionFunc = function(itemId, itemName)
						return (itemId == self.settings.defaultSortOrder) and string.format(L.Suffix_Default, itemName) or itemName
					end,
					-- Add a (Use Default) item that will be checked by the OpenMenu callback
					-- if this group doesn't have a defined sort order.
					autoSplitMenuExtraItems = {
						{
							text = "(" .. L.UseDefault .. ")",
							tooltipTitle = L.Menu_Group_DefaultSortOrder_TooltipTitle,
							checked = false,
							value = {
								func = function(groupId, _)
									self:AssignSortOrderToGroup(nil, groupId)
								end,
								tooltipTextFunc = function()
									return string.format(
										L.Menu_Group_DefaultSortOrder_TooltipText,
										LIGHTYELLOW_FONT_COLOR_CODE .. BsSortOrders.list[self.settings.defaultSortOrder].name .. FONT_COLOR_CODE_CLOSE
									)
								end,
							},
						},
					}
				},
				hasArrow = true,
			},
		},

		-- 2
		{
			-- Per-group settings.
			Options = {

				{
					text = L.Menu_Settings_View,
					isTitle = true,
					notCheckable = true,
					keepShownOnClick = true,
				},
				{
					text = L.Menu_Group_HideGroup,
					tooltipText = L.Menu_Group_HideGroup_TooltipText,
					_bagshuiCheckedFunc = function(groupId)
						return (self.groups[groupId] and self.groups[groupId].hide) or not self.groups[groupId]
					end,
					func = function(groupId)
						if not self.groups[groupId] then
							return
						end
						self.groups[groupId].hide = not self.groups[groupId].hide
						self:EditModeWindowUpdate(false)
					end,
				},
				{
					text = L.Menu_Group_HideStockBadge,
					tooltipText = L.Menu_Group_HideStockBadge_TooltipText,
					_bagshuiSettingName = "hideStockBadge",
					_bagshuiSettingInfo = groupDefaults.hideStockBadge,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},

				{
					text = L.Background,
					isTitle = true,
					notCheckable = true,
					keepShownOnClick = true,
				},
				{
					text = L.UseDefault,
					tooltipTitle = string.format(L.Menu_Group_DefaultColor_TooltipTitle, L.Background),
					tooltipText = string.format(L.Menu_Group_DefaultColor_TooltipText, string.lower(L.Background)),
					_bagshuiCheckedFunc = function(groupId)
						return (self.groups[groupId] and self.groups[groupId].background == nil) or not self.groups[groupId]
					end,
					func = function(groupId)
						if not self.groups[groupId] then
							return
						end
						self.groups[groupId].background = nil
						self:EditModeWindowUpdate(false)
					end
				},
				{
					text = L.Color,
					tooltipTitle = string.format(L.Menu_Group_Color_TooltipTitle, L.Background),
					tooltipText = string.format(L.Menu_Group_Color_TooltipText, string.lower(L.Background)),
					_bagshuiSettingName = "background",
					_bagshuiSettingInfo = groupDefaults.background,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},

				{
					text = L.Border,
					isTitle = true,
					notCheckable = true,
					keepShownOnClick = true,
				},
				{
					text = L.UseDefault,
					tooltipTitle = string.format(L.Menu_Group_DefaultColor_TooltipTitle, L.Border),
					tooltipText = string.format(L.Menu_Group_DefaultColor_TooltipText, string.lower(L.Border)),
					_bagshuiCheckedFunc = function(groupId)
						return (self.groups[groupId] and self.groups[groupId].border == nil) or not self.groups[groupId]
					end,
					func = function(groupId)
						if not self.groups[groupId] then
							return
						end
						self.groups[groupId].border = nil
						self:EditModeWindowUpdate(false)
					end
				},
				{
					text = L.Color,
					tooltipTitle = string.format(L.Menu_Group_Color_TooltipTitle, L.Border),
					tooltipText = string.format(L.Menu_Group_Color_TooltipText, string.lower(L.Border)),
					_bagshuiSettingName = "border",
					_bagshuiSettingInfo = groupDefaults.border,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},

				{
					text = L.Label,
					isTitle = true,
					notCheckable = true,
					keepShownOnClick = true,
				},
				{
					text = L.UseDefault,
					tooltipTitle = string.format(L.Menu_Group_DefaultColor_TooltipTitle, L.Label),
					tooltipText = string.format(L.Menu_Group_DefaultColor_TooltipText, string.lower(L.Label)),
					_bagshuiCheckedFunc = function(groupId)
						return (self.groups[groupId] and self.groups[groupId].label == nil) or not self.groups[groupId]
					end,
					func = function(groupId)
						if not self.groups[groupId] then
							return
						end
						self.groups[groupId].label = nil
						self:EditModeWindowUpdate(false)
					end
				},
				{
					text = L.Color,
					tooltipTitle = string.format(L.Menu_Group_Color_TooltipTitle, L.Label),
					tooltipText = string.format(L.Menu_Group_Color_TooltipText, string.lower(L.Label)),
					_bagshuiSettingName = "label",
					_bagshuiSettingInfo = groupDefaults.label,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				}
			},
		},

		-- 3
		{
			-- Color history menu entries.
			-- This is normally done automatically in BuildSettingsMenuFromConfig(),
			-- but since the group settings menu is manually constructed, we need
			-- to manually create these as well.
			background = {
				_initializeEmptyMenu = {
					_bagshuiSettingName = "background",
					_bagshuiSettingInfo = groupDefaults.background,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},
			},
			border = {
				_initializeEmptyMenu = {
					_bagshuiSettingName = "border",
					_bagshuiSettingInfo = groupDefaults.border,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},
			},
			label = {
				_initializeEmptyMenu = {
					_bagshuiSettingName = "border",
					_bagshuiSettingInfo = groupDefaults.label,
					_bagshuiSettingUpdateFunction = editModeWindowUpdate,
				},
			},
		},

		--- Group OpenMenu callback.
		---@param menu table Menu table.
		---@param uiGroup table Group user interface object.
		function(menu, uiGroup)
			local groupId = uiGroup.bagshuiData.groupId
			local group = self.groups[groupId]
			local groupMenu = menu

			for _, menuItem in ipairs(groupMenu.levels[1]) do

				if menuItem._bagshuiMenuItemId == "GroupNameTitle" then
					-- Update the menu title to the group name.
					menuItem.text =
						string.len(group.name or "") > 0
						and (string.format(L.Symbol_Colon, L.Group) .. " " .. LIGHTYELLOW_FONT_COLOR_CODE .. BsUtil.TruncateString(group.name, 45) .. FONT_COLOR_CODE_CLOSE)
						or L.Group

				elseif type(menuItem.value) == "table" and menuItem.value.autoSplitMenuType then
					-- Category/SortOrder auto-split submenu updates.

					-- Auto-split menus pass arg1 via value.objectId.
					menuItem.value.objectId = groupId

					if menuItem.value.autoSplitMenuType == BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES then

						if menuItem._bagshuiMenuItemId == "CategoryAddRemove" then
							-- "Add" needs the full category list with already assigned categories checked.
							menuItem.value.idsToCheck = group.categories

						elseif
							menuItem._bagshuiMenuItemId == "CategoryMove"
							or menuItem._bagshuiMenuItemId == "CategoryConfig"
						then
							-- "Remove" needs only the already assigned categories (if any).
							if group.categories and table.getn(group.categories) > 0 then
								menuItem.disabled = false
								menuItem.hasArrow = true
								menuItem.value.idList = group.categories

							else
								-- This will be hit when there are no assigned categories, disabling these options.
								menuItem.disabled = true
								menuItem.hasArrow = false
							end
						end


					elseif menuItem.value.autoSplitMenuType == BS_AUTO_SPLIT_MENU_TYPE.SORT_ORDERS then

						-- Control whether "(Use Default)" is checked.
						menuItem.value.autoSplitMenuExtraItems[1].checked = (group.sortOrder == nil)

						-- Check the currently selected item.
						if group.sortOrder then
							menuItem.value.idsToCheck = { group.sortOrder }
						else
							menuItem.value.idsToCheck = nil
						end

					end
				end
			end

			-- Add properties to all menu items (this is fine to do for all of them even if it is a little brute force-y).
			self.menus:SetPropertyOnAllMenuItems(groupMenu, "arg1", groupId)
			self.menus:SetPropertyOnAllMenuItems(groupMenu, "_bagshuiSettingsStorage", group)
		end
	)


	-- Item Menu.

	-- Shared OnClick function for itemInfo submenu to display the itemInfo window.
	local function showItemInfo(item)
		Bagshui:CloseMenus()
		BsItemInfo:Open(item)
	end

	-- Reusable tables for item/category relationships.
	self._itemMenuDirectCategoryAssignmentList = {}
	self._itemMenuMatchedCategoryList = {}
	self._itemMenuAssignedCategoryList = { "Uncategorized" }

	self.menus:AddMenu(
		"Item",
		-- 1
		{
			-- Category title (will be renamed by the OpenMenu callback.)
			{
				_bagshuiMenuItemId = "CategoryTitle",
				_bagshuiItemMenuCategoryEntry = true,
				text = L.Category,
				isTitle = true,
				notCheckable = true,
				icon = BsUtil.GetFullTexturePath("Icons\\Category"),
				_bagshuiTextureSize = 12,
				_bagshuiTextureXOffset = -12,
			},
			-- arg1 and arg2 are assigned by the OpenMenu callback
			{
				_bagshuiItemMenuCategoryEntry = true,
				text = L.Move,
				tooltipTitle = string.format(L.Prefix_Move, L.Category),
				tooltipText = L.Menu_Category_Move_TooltipText,
				func = function(_, categoryId)
					self:EditModePickUpCategory(categoryId, true)
				end,
			},
			{
				_bagshuiItemMenuCategoryEntry = true,
				text = L.Remove,
				tooltipTitle = string.format(L.Prefix_Remove, L.Category),
				tooltipText = L.Menu_Category_Remove_TooltipText,
				func = function(groupId, categoryId)
					self:RemoveCategoryFromGroup(categoryId, groupId)
					self:EditModeWindowUpdate(true)
				end,
			},
			{
				_bagshuiItemMenuCategoryEntry = true,
				text = string.format(L.Symbol_Ellipsis, L.Edit),
				tooltipTitle = string.format(L.Prefix_Edit, L.Category),
				tooltipText = L.Menu_Category_Edit_TooltipText,
				func = function(_, categoryId)
					BsCategories:EditObject(categoryId)
					self:CloseMenusAndClearFocuses()
				end,
			},
			{
				_bagshuiItemMenuCategoryEntry = true,
				text = string.format(L.Symbol_Ellipsis, L.Manage),
				tooltipTitle = string.format(L.Prefix_Manage, L.Categories),
				tooltipText = L.Menu_Main_ManageCategories_TooltipText,
				func = function()
					BsCategories:Open()
					self:CloseMenusAndClearFocuses()
				end,
			},

			-- Item title (will be renamed by the OpenMenu callback.)
			{
				_bagshuiMenuItemId = "ItemNameTitle",
				text = L.Item,
				isTitle = true,
				notCheckable = true,
				_bagshuiTextureR = 1,
				_bagshuiTextureG = 1,
				_bagshuiTextureB = 1,
			},
			{
				text = L.Information,
				tooltipTitle = L.Menu_Item_Information_TooltipTitle,
				tooltipText = L.Menu_Item_Information_TooltipText,
				hasArrow = true,
				value = {
					value = "itemInfo",
				},
			},
			{
				text = L.Manage,
				tooltipTitle = L.Menu_Item_Manage_TooltipTitle,
				tooltipText = L.Menu_Item_Manage_TooltipText,
				hasArrow = true,
				value = {
					value = "manage",
				},
			},
			{
				text = L.Move,
				tooltipTitle = string.format(L.Prefix_Move, L.Item),
				tooltipText = L.Menu_Item_Move_TooltipText,
				_bagshuiMenuItemId = "ItemMove",
				func = function(item)
					self:EditModePickUpItem(item)
				end,
			},

			-- Indented subheader for item categories menu.
			{
				text = BS_MENU_SUBTITLE_INDENT .. L.Categories,
				isTitle = true,
				notCheckable = true,
			},
			-- Matched Categories is a Categories auto-spilt menu that only contains the list of
			-- categories that this item could potentially match, as produced by
			-- Categories:GetAllMatchingCategoriesForItem(). The category that the item has
			-- actually matched and is currently in will be checked. These updates are made
			-- in the OpenMenu callback function.
			{
				text = L.Menu_Item_MatchedCategories,
				tooltipTitle = L.Menu_Item_MatchedCategories_TooltipTitle,
				tooltipText = L.Menu_Item_MatchedCategories_TooltipText,
				value = {
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
					func = function(itemId, categoryId)
						BsCategories:EditObject(categoryId)
					end,
					sortFunc = function(categoryIds)
						BsCategories:SortIdList(categoryIds, nil, "sequence")
					end,
					nameFunc = function(categoryId)
						-- Prefix the category name with the sequence number.
						-- Gray out the category name if it's not assigned to the current layout.
						local fontColor = ""

						if not (self.categoriesToGroups[categoryId] and self.groups[self.categoriesToGroups[categoryId]]) then
							fontColor = GRAY_FONT_COLOR_CODE
						elseif categoryId == self._itemMenuAssignedCategoryList[1] then
							fontColor = NORMAL_FONT_COLOR_CODE
						end

						return
							fontColor
							.. string.format(L.Symbol_Colon, BsCategories.list[categoryId].sequence)
							.. " " .. (BsCategories:GetName(categoryId, false, GRAY_FONT_COLOR_CODE) or tostring(categoryId))
							.. ((fontColor ~= "") and FONT_COLOR_CODE_CLOSE or "")
					end,
					tooltipTextFunc = function(categoryId)
						local layoutLocation = LIGHTYELLOW_FONT_COLOR_CODE .. self._autoSplitMenuItem_Categories_TooltipTextFunc(categoryId) .. FONT_COLOR_CODE_CLOSE
						return NORMAL_FONT_COLOR_CODE .. L.Menu_Item_MatchedCategory_TooltipText .. FONT_COLOR_CODE_CLOSE .. BS_NEWLINE .. layoutLocation
					end,
					-- These tables are updated by the OpenMenu callback.
					idList = self._itemMenuMatchedCategoryList,
					idsToCheck = self._itemMenuAssignedCategoryList,
					-- Never show the default category (Uncategorized) since every item matches it.
					idsToOmit = { BS_DEFAULT_CATEGORY_ID },
				},
				hasArrow = true,
			},
			-- Direct Assignment is a Categories auto-split menu that contains all
			-- editable (custom) NON-CLASS categories. Any categories the item is directly
			-- assigned to will be checked. These updates are performed by the
			-- OpenMenu callback function.
			{
				_bagshuiMenuItemId = "ItemDirectCategoryAssignment",
				text = L.Menu_Item_AssignToCategory,
				tooltipTitle = L.Menu_Item_AssignToCategory_TooltipTitle,
				tooltipText = L.Menu_Item_AssignToCategory_TooltipText .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. L.Menu_Item_AssignToCategory_Hint_CustomOnly .. FONT_COLOR_CODE_CLOSE,
				value = {
					autoSplitMenuType = BS_AUTO_SPLIT_MENU_TYPE.CATEGORIES,
					func = function(itemAndGroupId, categoryId)
						if BsCategories.list[categoryId].classes then
							self.menus:OpenMenu("DirectAssignmentClasses", itemAndGroupId, categoryId, "cursor")
						else
							BsCategories:ToggleItemCategoryAssignment(categoryId, itemAndGroupId.item.id)
							self:EditModeWindowUpdate(true)
						end
					end,
					nameFunc = function(categoryId)
						-- Need to override nameFunc to turn off duplicate suffix since we're only showing custom categories.
						return BsCategories:GetName(categoryId, true) or tostring(categoryId)
					end,
					tooltipTextFunc = self._autoSplitMenuItem_Categories_TooltipTextFunc,
					idsToCheck = self._itemMenuDirectCategoryAssignmentList,
					idList = BsCategories.filteredIdLists.custom,

					-- This will be passed as arg1 to the auto-split menu func()s.
					objectId = {
						item = nil,
						groupId = nil,
					},

					autoSplitMenuExtraItems = {
						{
							text = string.format(L.Symbol_Ellipsis, L.New),
							tooltipText = L.Menu_Item_AssignToCategory_CreateNew_TooltipText .. BS_NEWLINE .. LIGHTYELLOW_FONT_COLOR_CODE .. L.Menu_Item_AssignToCategory_Hint_CustomOnly .. FONT_COLOR_CODE_CLOSE,
							checked = false,
							value = {
								func = function(itemAndGroupId, _)
									local template = BsUtil.TableCopy(BS_NEW_CATEGORY_TEMPLATE)
									table.insert(template.list, itemAndGroupId.item.id)
									BsCategories:NewObject(
										template,
										-- onFirstSave callback.
										function(categoryId)
											if string.len(categoryId or "") > 0 and string.len(itemAndGroupId.groupId or "") > 0 then
												self:AssignCategoryToGroup(categoryId, itemAndGroupId.groupId, true)
											end
										end
									)

								end,
							},
						},
					}
				},
				hasArrow = true,
			},
		},

		-- 2
		{
			-- Populated by the OpenMenu callback function.
			itemInfo = {},

			manage = {
				-- Remove from worn gear list.
				{
					_bagshuiMenuItemId = "ItemRemoveFromWorn",
					text = L.Menu_Item_RemoveFromEquippedGear,
					tooltipText = L.Menu_Item_RemoveFromEquippedGear_TooltipText,
					disabled = true,
					keepShownOnClick = false,
					func = function(item)
						BsCharacter:RemoveFromEquippedGear(item.itemString)
						self:CloseMenusAndClearFocuses()
					end,
				},
				-- Reset item stock state. 
				{
					_bagshuiMenuItemId = "ItemResetStockState",
					text = L.Menu_Item_ResetStockState,
					tooltipText = L.Menu_Item_ResetStockState_TooltipText,
					disabled = true,
					keepShownOnClick = false,
					func = function(item)
						item.bagshuiDate = 0
						item.bagshuiStockState = BS_ITEM_STOCK_STATE.NO_CHANGE
						self:ForceUpdateWindow()
					end,
				},
			}
		},

		-- 3
		nil,

		--- Item OpenMenu callback.
		---@param menu table Menu table.
		---@param item table Bagshui item table.
		---@param groupId string Group to which the item is being assigned. When present, all other menu items will be suppressed and only the direct category assignment submenu will be available.
		function(menu, item, groupId)
			local itemMenu = menu
			local directAssignmentOnlyMode = (groupId ~= nil)
			local directAssignmentCategoryIds = (groupId and self.groups[groupId] and self.groups[groupId].categories) or nil
			local isMeaningfulItemId = ((item.id or 0) > 0)

			-- Get list of categories to which this item is manually assigned.
			-- This table is assigned to the idsToCheck property of the
			-- Direct Assignment auto-split submenu. It's also used to decide
			-- whether the parent Direct Assignment item should be checked.
			BsCategories:GetDirectCategoryAssignmentsForItem(item.id, self._itemMenuDirectCategoryAssignmentList, directAssignmentCategoryIds)

			-- Update menu titles and values.
			for _, menuItem in pairs(itemMenu.levels[1]) do
				menuItem._bagshuiHide = false

				-- Category: Move/Remove/Edit/Configure need values to pass through to their func()s.
				if menuItem._bagshuiItemMenuCategoryEntry then
					menuItem.arg1 = self.categoriesToGroups[item.bagshuiCategoryId]
					menuItem.arg2 = item.bagshuiCategoryId
					if not self.editMode then
						menuItem._bagshuiHide = true
					end

				elseif item._bagshuiCategoryConfigTrigger then
					menuItem._bagshuiHide = true
				end


				if menuItem._bagshuiMenuItemId == "CategoryTitle" then
					-- Category: Set category name.
					menuItem.text = string.format(L.Symbol_Colon, L.Category) .. " " .. LIGHTYELLOW_FONT_COLOR_CODE .. (BsCategories:GetName(item.bagshuiCategoryId) or L.Error_ItemCategoryUnknown) .. FONT_COLOR_CODE_CLOSE

				elseif menuItem._bagshuiMenuItemId == "ItemNameTitle" then
					-- Item: Set item name and texture.
					menuItem.text = string.format(L.Symbol_Colon, L.Item) .. " " .. LIGHTYELLOW_FONT_COLOR_CODE .. BsUtil.TruncateString(item.name, 45) .. FONT_COLOR_CODE_CLOSE
					menuItem.icon = item.texture
					if BsSkin.itemSlotIconTexCoord then
						menuItem.tCoordLeft = BsSkin.itemSlotIconTexCoord[1]
						menuItem.tCoordRight = BsSkin.itemSlotIconTexCoord[2]
						menuItem.tCoordTop = BsSkin.itemSlotIconTexCoord[3]
						menuItem.tCoordBottom = BsSkin.itemSlotIconTexCoord[4]
					end

				elseif menuItem._bagshuiMenuItemId == "ItemMove" then
					-- Item: Disable the Move menu for empty slots since they can't be directly assigned to a category, only via a rule function.
					menuItem.disabled = not isMeaningfulItemId
					menuItem.arg1 = item
					menuItem._bagshuiHide = not self.editMode

				elseif menuItem._bagshuiMenuItemId == "ItemDirectCategoryAssignment" then
					-- Item: Disable the Direct Assignment menu for empty slots since they can't be directly assigned to a category, only via a rule function.
					menuItem.disabled = not isMeaningfulItemId
					menuItem.value.objectId.item = item
					menuItem.value.objectId.groupId = groupId or self.categoriesToGroups[item.bagshuiCategoryId]
					-- Check it if any categories are manually assigned.
					menuItem.checked = table.getn(self._itemMenuDirectCategoryAssignmentList) > 0
					menuItem.value.idList = directAssignmentCategoryIds or BsCategories.filteredIdLists.custom
					menuItem.value.idsToOmit = directAssignmentCategoryIds and BsCategories.filteredIdLists.builtin or nil
				end

				-- Item: Hide everything other than Direct Assignment
				-- when an item is picked up in Edit Mode and dropped on a group.
				if
					menuItem._bagshuiHide == false  -- Don't force anything to be shown that is already hidden.
					and menuItem._bagshuiMenuItemId ~= "ItemNameTitle"
					and menuItem._bagshuiMenuItemId ~= "ItemDirectCategoryAssignment"
					and not item._bagshuiCategoryConfigTrigger
				then
					menuItem._bagshuiHide = (directAssignmentCategoryIds ~= nil)
				end

			end

			-- Item: These submenus only need to be updated on a normal right-click,
			-- not when an item has been  dropped on a group in Edit Mode.
			if not directAssignmentOnlyMode then

				-- Update Manage submenu.
				for _, menuItem in pairs(itemMenu.levels[2].manage) do
					menuItem.arg1 = item
					if menuItem._bagshuiMenuItemId == "ItemRemoveFromWorn" then
						menuItem.disabled = not BsCharacter.equippedHistory[item.itemString]
					elseif menuItem._bagshuiMenuItemId == "ItemResetStockState" then
						menuItem.disabled = item.bagshuiStockState == BS_ITEM_STOCK_STATE.NO_CHANGE
					end
				end

				-- Add items to Information submenu.
				local infoMenu = itemMenu.levels[2].itemInfo
				local infoMenuItemCount = 0
				for _, itemPropertyFriendly, _, itemPropertyDisplay in BsItemInfo:ItemPropertyValuesForDisplay(item) do
					infoMenuItemCount = infoMenuItemCount + 1
					infoMenu[infoMenuItemCount]._bagshuiHide = false
					infoMenu[infoMenuItemCount].text = string.format(L.Symbol_Colon, itemPropertyFriendly) .. " " .. itemPropertyDisplay
					infoMenu[infoMenuItemCount].tooltipText = LIGHTYELLOW_FONT_COLOR_CODE .. L.Menu_Item_Information_Submenu_TooltipText .. FONT_COLOR_CODE_CLOSE
					infoMenu[infoMenuItemCount].arg1 = item
				end
				-- Hide unused menu items.
				self.menus:HideMenuItems(infoMenu, infoMenuItemCount + 1)

				-- Update Matched Categories submenu.
				BsCategories:GetAllMatchingCategoriesForItem(item, nil, self._itemMenuMatchedCategoryList)
				self._itemMenuAssignedCategoryList[1] = item.bagshuiCategoryId
			end

			-- Hide tooltips that sometimes get stuck.
			Bagshui:HideTooltips(nil, true)
		end
	)

	-- Fill the item info level 2 menus with placeholder entries that will be
	-- updated by the OpenMenu callback.
	self.menus:InitializeEmptyMenu(
		self.menus.menuList.Item.levels[2].itemInfo,
		{
			text = "",
			arg1 = "",
			func = showItemInfo,
		}
	)


	-- Direct Assignment Class Selection Menu.
	-- Triggered when a Class Category is chosen from the Direct Assignment menu.

	local function toggleClassCategoryDirectAssignment(arg1)
		BsCategories:ToggleItemCategoryAssignment(arg1.categoryId, arg1.itemId, _G.this.value)
	end

	local classMenu = BsUtil.TableCopy(BsGameInfo.characterClassMenu)
	-- Reusable table for passing values through to the callback function.
	local classMenuArg1 = {}

	for _, menuItem in ipairs(classMenu) do
		menuItem.arg1 = classMenuArg1
		menuItem.func = toggleClassCategoryDirectAssignment
	end
	table.insert(
		classMenu, 1,
		{
			text = "Item placeholder",
			isTitle = true,
			notCheckable = true,
		}
	)
	table.insert(
		classMenu, 2,
		{
			text = LIGHTYELLOW_FONT_COLOR_CODE .. L.Menu_Item_AssignToClassCategory .. FONT_COLOR_CODE_CLOSE,
			isTitle = true,
			notCheckable = true,
		}
	)
	table.insert(
		classMenu, 3,
		{
			text = LIGHTYELLOW_FONT_COLOR_CODE .. L.ClassCategory .. FONT_COLOR_CODE_CLOSE,
			isTitle = true,
			notCheckable = true,
		}
	)
	table.insert(
		classMenu, 4,
		{
			text = "Category placeholder",
			isTitle = true,
			notCheckable = true,
		}
	)

	self.menus:AddMenu(
		"DirectAssignmentClasses",
		classMenu,
		-- Nothing for level 2/3.
		nil, nil,
		-- OpenMenu callback.
		function(menu, itemAndGroupId, categoryId)
			classMenuArg1.itemId = itemAndGroupId.item.id
			classMenuArg1.categoryId = categoryId

			menu.levels[1][1].text = itemAndGroupId.item.name
			menu.levels[1][1].icon = itemAndGroupId.item.texture
			menu.levels[1][1]._bagshuiTextureR = 1
			menu.levels[1][1]._bagshuiTextureG = 1
			menu.levels[1][1]._bagshuiTextureB = 1
			if BsSkin.itemSlotIconTexCoord then
				menu.levels[1][1].tCoordLeft = BsSkin.itemSlotIconTexCoord[1]
				menu.levels[1][1].tCoordRight = BsSkin.itemSlotIconTexCoord[2]
				menu.levels[1][1].tCoordTop = BsSkin.itemSlotIconTexCoord[3]
				menu.levels[1][1].tCoordBottom = BsSkin.itemSlotIconTexCoord[4]
			end

			menu.levels[1][4].text = BsCategories:GetName(categoryId, true) or tostring(categoryId)

			for i = 5, table.getn(menu.levels[1]) do
				local menuItem = menu.levels[1][i]
				menuItem.checked = BsCategories:ItemInDirectAssignmentList(
					nil,
					categoryId,
					itemAndGroupId.item.id,
					nil,
					nil,
					menuItem.value
				)
			end
		end
	)

end


end)