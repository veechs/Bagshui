-- Bagshui Menus Class Prototype
-- Exposes: Bagshui.prototypes.Menus
--
-- Makes WoW's native menus easier to use. To get around the 32-item limit, auto-split
-- menus can be set up, which will (as the name implies) automatically split their
-- contents into submenus once they go over the limit.
-- Fair warning: The auto-split menu code isn't the cleanest or the best-documented.


-- ======================================================
-- REFERENCE: Menu item attributes
--
-- ------------------------------------------------------
-- WoW native
-- ------------------------------------------------------
-- text = [STRING]  --  The text of the button
-- value = [ANYTHING]  --  The value that UIDROPDOWNMENU_MENU_VALUE is set to when the button is clicked
-- func = [function()]  --  The function that is called when you click the button
-- checked = [nil, 1]  --  Check the button
-- isTitle = [nil, 1]  --  If it's a title the button is disabled and the font color is set to yellow
-- disabled = [nil, 1]  --  Disable the button and show an invisible button that still traps the mouseover event so menu doesn't time out
-- hasArrow = [nil, 1]  --  Show the expand arrow for multilevel menus
-- hasColorSwatch = [nil, 1]  --  Show color swatch or not, for color selection
-- r = [1 - 255]  --  Red color value of the color swatch
-- g = [1 - 255]  --  Green color value of the color swatch
-- b = [1 - 255]  --  Blue color value of the color swatch
-- textR = [1 - 255]  --  Red color value of the button text
-- textG = [1 - 255]  --  Green color value of the button text
-- textB = [1 - 255]  --  Blue color value of the button text
-- swatchFunc = [function()]  --  Function called by the color picker on color change
-- hasOpacity = [nil, 1]  --  Show the opacity slider on the color picker frame
-- opacity = [0.0 - 1.0]  --  Percentage of the opacity, 1.0 is fully shown, 0 is transparent
-- opacityFunc = [function()]  --  Function called by the opacity slider when you change its value
-- cancelFunc = [function(previousValues)] -- Function called by the color picker when you click the cancel button (it takes the previous values as its argument)
-- notClickable = [nil, 1]  --  Disable the button and color the font white
-- notCheckable = [nil, 1]  --  Shrink the size of the buttons and don't display a check box
-- owner = [Frame]  --  Dropdown frame that "owns" the current dropdownlist
-- keepShownOnClick = [nil, 1]  --  Don't hide the dropdownlist after a button is clicked
-- tooltipTitle = [nil, STRING] -- Title of the tooltip shown on mouseover
-- tooltipText = [nil, STRING] -- Text of the tooltip shown on mouseover
-- justifyH = [nil, "CENTER"] -- Justify button text
-- arg1 = [ANYTHING] -- This is the first argument used by info.func
-- arg2 = [ANYTHING] -- This is the second argument used by info.func
-- textHeight = [NUMBER] -- font height for button text
-- icon = [STRING] - Texture to use for icon
-- tCoordLeft = [0.0, 1.0] -- Icon texture coordinates
-- tCoordRight = [0.0, 1.0]
-- tCoordTop = [0.0, 1.0]
-- tCoordBottom = [0.0, 1.0]
--
-- ------------------------------------------------------
-- Bagshui custom
-- ------------------------------------------------------
-- _bagshuiCheckedFunc -- function(): Return true/false to control value of `checked` property.
-- _bagshuiDisabledFunc -- function(): Return true/false to control value of `disabled` property.
-- _bagshuiFakeTitle -- boolean: Make the menu item *look* like a title but remain clickable.
-- _bagshuiHide -- boolean: Menu item will not be displayed if true.
-- _bagshuiHideFunc -- function(): Return true/false to control value of `_bagshuiHide` property.
-- _bagshuiSettingName -- string: Name of setting to generate menu item for.
-- _bagshuiTextureR -- number [1 - 255]: Red color value of `icon` texture.
-- _bagshuiTextureG -- number [1 - 255]: Blue color value of `icon` texture.
-- _bagshuiTextureB -- number [1 - 255]: Green color value of `icon` texture.
-- _bagshuiTextureA -- number [0.0 - 1.0]: Alpha opacity value of `icon` texture.
-- _bagshuiTextureSize ---@type number Alternate height/width for `icon` texture.
-- _bagshuiTextureXOffset - number: Alternate X offset for `icon` texture.



Bagshui:AddComponent(function()

-- Weird name to guarantee uniqueness within self.menuList.
local AUTO_SPLIT_MENU_LIST_TYPE = "***autoSplit***"

-- These are the auto-split menu properties that will be permitted. Anything else will generate an error.
-- 1 = required
-- 2 = optional
local AUTO_SPLIT_MENU_ALLOWED_PROPERTIES = {
	defaultIdList = 1, -- any[]: IDs to be used to populate the menu if idList isn't provided by the menu item's value table.
	sortFunc = 2,  -- function: Function that will accept an array of IDs and sort them by the text that will be returned by nameFunc.
	nameFunc = 2,  -- function(id): Return the text that should be displayed in the menu.
	tooltipTitleFunc = 2,  -- function(id): Return the string that should be displayed in the tooltip title.
	tooltipTextFunc = 2,  -- function(id): Return the string that should be displayed in the tooltip.
	parentMenuNameTrimFunc = 2,  -- function(menuName): Return the string that should be used for the parent menu item that opens a submenu.
	extraItems = 2,  -- table: Additional static menu items to add to the end of the menu.
	itemList = 2,  -- table[]: Actual list of objects potentially contained in the menu. Passed to omitFunc so object properties can be looked up.
}


local Menus = {

	-- Track the "value" parameters for the most recent menu levels that were opened.
	-- Consumed during Menus:Refresh().
	recentLevelValues = {},

	-- Normal menus.
	-- This needs to exist for the prototype because there will be an `AUTO_SPLIT_MENU_LIST_TYPE`
	-- key added during Init(). Menu class instances will also get their own menuList tables.
	menuList = {},

	-- Auto-Split menus.
	autoSplitMenuList = {},

	-- Reusable temp table for storing lists of IDs used to generate auto-split menus.
	autoSplitMenuItemIds = {},

}
Bagshui.prototypes.Menus = Menus



-- Initialize the Menus prototype.
function Menus:Init()

	-- Add the auto-split menu type to the base Menus class.
	self:AddMenu(AUTO_SPLIT_MENU_LIST_TYPE)

	-- This frame and text are used to wrestle UIDropDownMenu_Refresh into doing what we want, which is simply to 
	-- refresh the menu and put all check marks in the correct state. However, it insists on doing a SetText() call,
	-- so we need to give it a dummy frame and corresponding font string so it won't error.
	local autoSplitMenuRefreshHackFrameName = "autoSplitMenuRefreshHackFrame"
	self.autoSplitMenuRefreshHackFrame = _G.CreateFrame("Frame", autoSplitMenuRefreshHackFrameName)
	-- The FontString must be named `<FrameName>Text` for this to work.
	self.autoSplitMenuRefreshHackText = self.autoSplitMenuRefreshHackFrame:CreateFontString(autoSplitMenuRefreshHackFrameName.."Text", nil, "GameFontNormal")

	--- Auto-split menu OnClick function.
	--- Having a reusable function avoids generating hundreds of anonymous functions as we construct the menu tables.
	--- This is stored on the prototype because it needs to be available to `PopulateAutoSplitMenuItems()`.
	---@param params any arg1 from the menu `func()` call, set by `PrepareAutoSplitMenu()`.
	---@param itemId any arg2 from the menu `func()` call, set by `PrepareAutoSplitMenu()`.
	self._autoSplitMenuItem_Click = function(params, itemId)
		-- Safeguard.
		if not params then
			return
		end

		-- Call provided function.
		if type(params.func) == "function" then
			params.func(params.objectId, itemId)
		end

		-- Refresh or close menus depending on what was configured.
		if params.menuItem.keepShownOnClick then
			-- Record the value of the clicked menu item on our hack frame so that UIDropDownMenu_Refresh knows what to do.
			self.autoSplitMenuRefreshHackFrame.selectedValue = (not params.menuItem.notCheckable) and params.menuItem.value or nil
			-- Call UIDropDownMenu_Refresh on the next frame to put the check mark back if it was removed.
			Bagshui:QueueEvent(_G.UIDropDownMenu_Refresh, nil, true, self.autoSplitMenuRefreshHackFrame)
		else
			Bagshui:CloseMenus()
		end
	end


	--- Create an auto-split menu placeholder. (Used in multiple places in `Init()`).
	---@param menuTable table Table into which the placeholder should be inserted.
	local function addAutoSplitMenuItem(menuTable)
		table.insert(
			menuTable,
			{
				text = "",
				value = {
					menuType = AUTO_SPLIT_MENU_LIST_TYPE,
					value = "",
				},
				arg1 = {
					objectId = "",
					func = nil,  -- Will be added/removed during PrepareAutoSplitMenu().
					menuItem = nil,
				},
				hasArrow = false,
				_bagshuiHide = true,
				func = nil,  -- Will be added/removed during PrepareAutoSplitMenu().
			}
		)
	end

	-- Build out the auto-split menu with placeholders for level 1 and 2.
	for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
		-- First level.
		addAutoSplitMenuItem(self.menuList[AUTO_SPLIT_MENU_LIST_TYPE].levels[1])

		-- Second level.
		table.insert(self.menuList[AUTO_SPLIT_MENU_LIST_TYPE].levels[2], {})
		for j = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			-- j is "unused" here because we're doing table.insert() j number of times.
			addAutoSplitMenuItem(self.menuList[AUTO_SPLIT_MENU_LIST_TYPE].levels[2][i])
		end
	end

end



--- Create a new instance of the Menus class.
---@param inventoryClassInstance table? Inventory class, used to call GenerateSettingsMenuItem() when an item has a _bagshuiSettingName property.
---@return table menusClassInstance
function Menus:New(inventoryClassInstance)

	-- Prepare new class object.
	local menus = {
		_super = Menus,
		inventoryClassInstance = inventoryClassInstance,
		-- Normal menus that are specific to this class instance.
		menuList = {},
	}

	-- Set up the class object.
	setmetatable(menus, self)
	self.__index = self

	-- menuList also needs to be metatable'd so it can get AutoSplit menus from the prototype.
	setmetatable(menus.menuList, self.menuList)
	self.menuList.__index = self.menuList

	return menus
end



--- Register a standard menu.
---@param menuName string Unique identifier for this menu. Will become the key in self.menuList.
---@param level1 table[]? Array of menu item tables (see top of file for menu item attributes).
---@param level2 table<any,table[]>? Lists of `<value> = <Array of menu item tables>`. The value attribute from lower levels is used to link to the submenus on higher levels.
---@param level3 table<any,table[]>? Lists of `<value> = <Array of menu item tables>`. The value attribute from lower levels is used to link to the submenus on higher levels.
---@param openMenuFunc function? Function to be called in lieu of Menus:ShowMenu(). Will receive arg1 and arg2 from Menus:OpenMenu(). If openMenuFunc returns false, the normal call to ShowMenu() will be prevented, allowing full control of the menu opening process.
function Menus:AddMenu(menuName, level1, level2, level3, openMenuFunc)
	assert(menuName, "Menus:AddMenu(): menuName is required")

	self.menuList[menuName] = {
		levels = {
			type(level1) == "table" and level1 or {},
			type(level2) == "table" and level2 or {},
			type(level3) == "table" and level3 or {},
		},
		openFunc = openMenuFunc,
	}

	for i = 1, 3 do
		for _, submenu in pairs(self.menuList[menuName].levels[i]) do
			if type(submenu) == "table" and submenu._initializeEmptyMenu then
				self:InitializeEmptyMenu(submenu, submenu._initializeEmptyMenu)
				submenu._initializeEmptyMenu = nil
			end
		end
	end
end



--- Register a new auto-split menu.
---@param autoSplitMenuType BS_AUTO_SPLIT_MENU_TYPE|string Unique identifier for this auto-split menu.
---@param propsTable table<string,any> Menu properties -- see `AUTO_SPLIT_MENU_ALLOWED_PROPERTIES` declaration for details.
function Menus:AddAutoSplitMenu(autoSplitMenuType, propsTable)
	assert(type(autoSplitMenuType) == "string", "Menus:AddAutoSplitMenu(): autoSplitMenuType must be a string")
	-- Ensure all required properties are present.
	for prop, required in pairs(AUTO_SPLIT_MENU_ALLOWED_PROPERTIES) do
		assert(
			required ~= 1 or propsTable[prop],
			"Menus:AddAutoSplitMenu(" .. autoSplitMenuType .. "): " .. prop .. " is missing from propsTable"
		)
	end
	-- Reject any non-allowed properties.
	for prop, _ in pairs(propsTable) do
		assert(
			AUTO_SPLIT_MENU_ALLOWED_PROPERTIES[prop],
			"Menus:AddAutoSplitMenu(" .. autoSplitMenuType .. "): " .. prop .. " is not a valid property"
		)
	end

	self.autoSplitMenuList[autoSplitMenuType] = propsTable
end




--- Open a menu of the given type.
--- This is structured in two parts because Blizzard's `ToggleDropDownMenu()` closes any visible menus on the first call,
--- leading to an awkward need to click twice to open a different menu if one is already open. The workaround for this
--- is to close menus before calling `ToggleDropDownMenu()`, then on the next frame update, show the new menu.
---@param menuType string Identifier for a menu that has been registered via `AddMenu()`.
---@param arg1 any First parameter for the `openMenuFunc` callback set up in `AddMenu()`.
---@param arg2 any Second parameter for the `openMenuFunc` callback set up in `AddMenu()`.
---@param anchorFrame table Frame to which the menu should be anchored.
---@param xOffset number? X adjustment for menu anchoring.
---@param yOffset number? Y adjustment for menu anchoring.
---@param anchorPoint string? Point on the menu which should be attached to `anchorFrame`.
---@param anchorToPoint string? Point on `anchorFrame` to which the menu should be attached.
function Menus:OpenMenu(menuType, arg1, arg2, anchorFrame, xOffset, yOffset, anchorPoint, anchorToPoint)

	-- Store parameters for callback.
	self._openMenu_MenuType = menuType
	self._openMenu_Arg1 = arg1
	self._openMenu_Arg2 = arg2
	self._openMenu_AnchorFrame = anchorFrame
	self._openMenu_XOffset = xOffset
	self._openMenu_YOffset = yOffset
	self._openMenu_AnchorPoint = anchorPoint
	self._openMenu_AnchorToPoint = anchorToPoint

	-- Close all open menus
	Bagshui:CloseMenus(1, true)

	-- Callback will fire on next frame update and consume parameters
	Bagshui:QueueClassCallback(self, self.OpenMenuCallback)

	-- Clear historical parameters.
	self._openMenu_last_MenuType = nil
	self._openMenu_last_Arg1 = nil
	self._openMenu_last_Arg2 = nil
	self._openMenu_last_UIParentXOffset = nil
	self._openMenu_last_UIParentYOffset = nil

end



--- Helper function to open menus immediately after any currently visible menus are closed by OpenMenu
function Menus:OpenMenuCallback()

	local doShowMenu = true

	-- Invoke custom callback function if one exists
	-- This function can block the normal automatic call to ShowMenu() by returning false
	local openMenuFunc = self.menuList[self._openMenu_MenuType] and self.menuList[self._openMenu_MenuType].openFunc
	if
		type(openMenuFunc) == "function"
		and openMenuFunc(
			self.menuList[self._openMenu_MenuType],
			self._openMenu_Arg1,
			self._openMenu_Arg2
		) == false
	then
		doShowMenu = false
	end

	-- Automatically call ShowMenu(), if not stopped by openMenuFunc().
	if doShowMenu then
		self:ShowMenu(
			self._openMenu_MenuType,
			self._openMenu_AnchorFrame,
			self._openMenu_XOffset,
			self._openMenu_YOffset,
			self._openMenu_AnchorPoint,
			self._openMenu_AnchorToPoint
		)
	end

	-- Reset parameters.
	self._openMenu_MenuType = nil
	self._openMenu_Arg1 = nil
	self._openMenu_Arg2 = nil
	self._openMenu_AnchorFrame = nil
	self._openMenu_XOffset = nil
	self._openMenu_YOffset = nil
	self._openMenu_AnchorPoint = nil
	self._openMenu_AnchorToPoint = nil
end



--- Actually display a menu of the given type.
--- This should ONLY be called by OpenMenuCallback or an OpenMenu override function.
---@param menuType string Identifier for a menu that has been registered via `AddMenu()`.
---@param anchorFrame table|nil Frame to which the menu should be anchored.
---@param xOffset number? X adjustment for menu anchoring.
---@param yOffset number? Y adjustment for menu anchoring.
---@param anchorPoint string? Point on the menu which should be attached to `anchorFrame`.
---@param anchorToPoint string? Point on `anchorFrame` to which the menu should be attached.
function Menus:ShowMenu(menuType, anchorFrame, xOffset, yOffset, anchorPoint, anchorToPoint)
	-- Used by IsMenuOpen() when checking to see if an open menu is unique to this class instance.
	Bagshui.menuFrame.bagshuiData.lastMenuTypeLoaded = menuType .. tostring(self)

	-- Force re-initialization of menus to avoid the "Too many buttons in UIDropDownMenu:" error.
	_G.UIDROPDOWNMENU_OPEN_MENU = nil

	-- Reset menu properties to prevent spurious check marks from appearing (weird Blizzard issue).
	Bagshui.menuFrame.selectedID = nil
	Bagshui.menuFrame.selectedValue = nil
	Bagshui.menuFrame.selectedName = nil
	-- Hide any existing check marks; they'll be re-added automatically if needed.
	for i = 1, _G.UIDROPDOWNMENU_MAXLEVELS do
		for j = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			_G["DropDownList" .. i .. "Button" .. j]:UnlockHighlight()
			_G["DropDownList" .. i .. "Button" .. j .. "Check"]:Hide()
		end
	end

	-- Load the menu.
	_G.UIDropDownMenu_Initialize(
		Bagshui.menuFrame,
		function(level)
			self:LoadMenu(menuType, level)
		end,
		"MENU"
	)

	-- Adjust anchoring if requested.
	if anchorPoint then
		Bagshui.menuFrame.bagshuiData.xOffset = xOffset
		Bagshui.menuFrame.bagshuiData.yOffset = yOffset
		Bagshui.menuFrame.bagshuiData.anchorPoint = anchorPoint
		Bagshui.menuFrame.bagshuiData.anchorToFrame = anchorFrame
		Bagshui.menuFrame.bagshuiData.anchorToPoint = anchorToPoint
		_G.UIDropDownMenu_SetAnchor(
			xOffset,
			yOffset,
			Bagshui.menuFrame,
			anchorPoint,
			anchorFrame,
			anchorToPoint
		)

		-- Force ToggleDropDownMenu() to use the points set by UIDropDownMenu_SetAnchor().
		anchorFrame = nil
	else
		-- Reset everything so Bagshui:ToggleDropDownMenu() knows there's no special anchors.

		Bagshui.menuFrame.xOffset = nil
		Bagshui.menuFrame.yOffset = nil
		Bagshui.menuFrame.point = nil
		Bagshui.menuFrame.relativeTo = nil
		Bagshui.menuFrame.relativePoint = nil
		Bagshui.menuFrame.bagshuiData.xOffset = nil
		Bagshui.menuFrame.bagshuiData.yOffset = nil
		Bagshui.menuFrame.bagshuiData.anchorPoint = nil
		Bagshui.menuFrame.bagshuiData.anchorToFrame = nil
		Bagshui.menuFrame.bagshuiData.anchorToPoint = nil
	end

	-- Open the menu.
	_G.ToggleDropDownMenu(
		1,
		nil,
		Bagshui.menuFrame,
		anchorFrame,
		xOffset,
		yOffset
	)

	-- Record most recent parameters so level 1 menu can be reopened.
	self._openMenu_last_MenuType = menuType
	self._openMenu_last_Arg1 = self._openMenu_Arg1
	self._openMenu_last_Arg2 = self._openMenu_Arg2
	self._openMenu_last_UIParentXOffset = _G.DropDownList1:GetLeft()
	self._openMenu_last_UIParentYOffset = _G.DropDownList1:GetTop()

	_G.PlaySound("igMainMenuOption")
end



--- Load a menu of the given type and level from the `self.menuList` table.
--- Used as a callback from `UIDropDownMenu_Initialize()`.
---@param menuType string Identifier for a menu that has been registered via `AddMenu()`.
---@param level number Menu level, 1-3.
function Menus:LoadMenu(menuType, level)
	level = level or 1

	-- Figure out what menu items to load.
	local menuItems
	local menuValue = level > 1 and _G.UIDROPDOWNMENU_MENU_VALUE or nil
	-- The menu table index we need to pull from can change depending on the menu being loaded.
	local menuLevel = level

	-- Override menuValue if we're refreshing to ensure the correct items are loaded.
	if self.refresh then
		menuValue = self.recentLevelValues[level]
	end

	-- Level 1 auto-split menus.
	-- This replaces the ENTIRE level 1 menu with an auto-split menu.
	-- To use this, the level 1 table of the menu must be an associative list of auto-split
	-- menu parameters (including autoSplitMenuType) instead of of an array of tables.
	if level == 1 and self.menuList[menuType] and self.menuList[menuType].levels[1] and self.menuList[menuType].levels[1].autoSplitMenuType then
		self:PrepareAutoSplitMenu(self.menuList[menuType].levels[1])
		menuType = AUTO_SPLIT_MENU_LIST_TYPE
	end

	-- Menu type overrides and auto-split menu loading.
	-- If a menu item has a table as its value property and the table contains a
	-- menuType entry, that menu will be loaded in lieu of the menuType parameter.
	if type(menuValue) == "table" then
		if menuValue.menuType then
			-- Normal override.
			menuType = menuValue.menuType
		elseif menuValue.autoSplitMenuType then
			-- This is an auto-split menu.
			menuType = AUTO_SPLIT_MENU_LIST_TYPE
		end

		if menuType == AUTO_SPLIT_MENU_LIST_TYPE then
			-- Auto-split menus typically need to pull from one level higher, because
			-- they are most often loaded from a submenu, but that submenu usually
			-- needs the top-level entry from the auto-split menu. Hopefully that
			-- almost makes sense.
			menuLevel = menuValue.menuLevel or menuLevel - 1
			self:PrepareAutoSplitMenu(menuValue)
		end

		-- Pre-processing function (not currently used).
		if menuValue.preloadFunction then
			menuValue.preloadFunction(menuValue.preloadFunctionArg1, menuValue.preloadFunctionArg2)
		end

		menuValue = menuValue.value
	end

	-- Ensure menu is valid.
	assert(self.menuList[menuType], "'" .. menuType .. "' menu not found in self.menuList!")

	local menu = self.menuList[menuType]

	-- When the level is higher than 1, it's a submenu.
	-- Menu items that trigger submenus are expected to provide the key for their
	-- items as the value of the item that opens the submenu, which gets stuffed
	-- into UIDROPDOWNMENU_MENU_VALUE by ToggleDropDownMenu.
	if menuLevel > 1 then
		menuItems = menu.levels[menuLevel][menuValue]

	else
		-- Level 1.
		menuItems = menu.levels[menuLevel]
	end

	-- Final validity check.
	if not menuItems then
		Bagshui:PrintError("Menu not found for type " .. menuType .. " level " .. tostring(menuLevel) .. " value " .. tostring(menuValue))
		return
	end

	-- Add items to the menu.
	for i, menuItem in ipairs(menuItems) do

		-- Flag this as a Bagshui menu item.
		menuItem._bagshui = true

		-- Assume not checked (this probably isn't actually necessary?).
		if menuItem.checked == nil then
			menuItem.checked = false
		end

		-- Fake title formatting.
		if menuItem._bagshuiFakeTitle then
			menuItem.isTitle = false
			menuItem.notCheckable = true
			menuItem.textR = _G.NORMAL_FONT_COLOR.r
			menuItem.textG = _G.NORMAL_FONT_COLOR.g
			menuItem.textB = _G.NORMAL_FONT_COLOR.b
		end

		-- Ensure texCoords are present for icons to avoid weird scaling issues.
		-- Blizzard's code doesn't make a call to SetTexCoord unless tCoordLeft is present,
		-- so if the texCoords were changed by something else, they won't be reset by default.
		if menuItem.icon and not menuItem.tCoordLeft then
			menuItem.tCoordLeft   = 0.0
			menuItem.tCoordRight  = 1.0
			menuItem.tCoordTop    = 0.0
			menuItem.tCoordBottom = 1.0
		end

		-- Update static properties based on provided functions.
		if type(menuItem._bagshuiCheckedFunc) == "function" then
			menuItem.checked = menuItem._bagshuiCheckedFunc(menuItem.arg1)
		end
		if type(menuItem._bagshuiDisabledFunc) == "function" then
			menuItem.disabled = menuItem._bagshuiDisabledFunc(menuItem.arg1)
		end
		if type(menuItem._bagshuiHideFunc) == "function" then
			menuItem._bagshuiHide = menuItem._bagshuiHideFunc()
		end

		-- Ensure tooltip displays.
		if menuItem.tooltipText and not menuItem.tooltipTitle then
			menuItem.tooltipTitle = menuItem.text
		end

		-- Settings handling.
		-- Any update to settings just needs to set the new value in self.settings and the Settings class
		-- will take care of everything, including initiating a window update to reflect the change.
		if menuItem._bagshuiSettingName and self.inventoryClassInstance then
			self.inventoryClassInstance:GenerateSettingsMenuItem(menuItem, menu, menuLevel, i, menuType)
		end

		-- Put it on the the menu unless it's hidden.
		if not menuItem._bagshuiHide then
			_G.UIDropDownMenu_AddButton(menuItem, level)
		end

	end

	-- Store value for use during refresh.
	self.recentLevelValues[level] = menuValue
end



--- Wrapper for `Bagshui:IsMenuOpen()` to pass this class's specific identifiers.
---@param menuType string? Identifier for a menu that has been registered via `AddMenu()`.
---@return boolean
function Menus:IsMenuOpen(menuType)
	return Bagshui:IsMenuOpen((menuType and (menuType .. tostring(self))))
end



--- Wrapper for `Bagshui:BlockAutoMenuClose()` to pass this class's specific identifiers.
---@param startLevel number? Lowest level to keep open, inclusive (1-3).
---@param endLevel number? Highest level to keep open, inclusive (1-3).
---@param menuType string? If provided, only stop the countdown when this menu is open.
function Menus:BlockAutoMenuClose(startLevel, endLevel, menuType)
	Bagshui:BlockAutoMenuClose(startLevel, endLevel, (menuType and (menuType .. tostring(self))))
end



--- Redraw an open menu at the given level.
---@param level number Menu level to refresh.
---@param levelAdjustment number Add to _G.UIDROPDOWNMENU_MENU_LEVEL instead of passing a specific level.
function Menus:Refresh(level, levelAdjustment)
	level = (level or _G.UIDROPDOWNMENU_MENU_LEVEL) + (levelAdjustment or 0)

	-- Do refresh on next frame to ensure new values are picked up.
	if not self.refresh then
		Bagshui:QueueClassCallback(self, self.Refresh, nil, nil, level)

		-- Set flag so that we know the callback has been queued and LoadMenu()
		-- knows to pull from self.recentLevelValues.
		self.refresh = true
		return
	end

	-- Reset list properties.
	local dropDownlist = _G["DropDownList" .. level]
	if not dropDownlist then
		return
	end
	dropDownlist.numButtons = 0
	dropDownlist.maxWidth = 0

	-- Hide buttons.
	for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS, 1 do
		local button = _G["DropDownList" .. level .. "Button" .. i]
		if button then
			button:Hide()
		end
	end

	-- Reset frame and call initialization function to re-populate buttons.
	Bagshui.menuFrame:SetHeight(_G.UIDROPDOWNMENU_BUTTON_HEIGHT * 2)
	Bagshui.menuFrame.initialize(level)

	-- Reset flag.
	self.refresh = false
end



--- Set the given property to the given value for all menu items.
---@param menuTable table Menu item table on which the property should be set. Must be the parent table, not the menu level table.
---@param property string Property to set.
---@param value any Property value.
---@param level number? Only set values on this level.
function Menus:SetPropertyOnAllMenuItems(menuTable, property, value, level)

	if not level then
		-- Set all levels-
		for menuLevel = 1, 3 do
			self:SetPropertyOnAllMenuItems(menuTable, property, value, menuLevel)
		end

	elseif level > 0 then
		-- We have a level to set, so grab that level's table and recurse to do the actual setting.

		if level == 1 then
			-- Level 1 is just an array of menu items.
			self:SetPropertyOnAllMenuItems(menuTable.levels[1], property, value, 0)

		else
			-- Level 2/3 are `{ <value> = <array of menu items> }`.
			for _, menuEntries in pairs(menuTable.levels[level]) do
				self:SetPropertyOnAllMenuItems(menuEntries, property, value, 0)
			end
		end

	else
		-- Level is 0, so just set properties.
		for _, menuEntry in ipairs(menuTable) do
			menuEntry[property] = value
		end
	end
end



--- Fill a menu table with empty, hidden (by default) entries.
---@param menu table Level-specific menu table.
---@param properties table<string,any> Additional properties to set.
function Menus:InitializeEmptyMenu(menu, properties)
	for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
		local menuItem = {
			_bagshuiHide = true,
			value = i
		}
		for key, value in pairs(properties) do
			menuItem[key] = value
		end
		table.insert(menu, menuItem)
	end
end


--- Set _bagshuiHide = true on menu items from `startPos` to `endPos`, inclusive.
---@param menu table Level-specific menu table.
---@param startPos number? First menu item to hide.
---@param endPos number? Last menu item to hide.
function Menus:HideMenuItems(menu, startPos, endPos)
	for i = startPos or 1, (endPos or _G.UIDROPDOWNMENU_MAXBUTTONS) do
		if menu[i] then
			menu[i]._bagshuiHide = true
		end
	end
end



--- Prepare to display an auto-split menu.
--- This is used for long lists of items so they are automatically divided into submenus,
--- which is necessary due to Vanilla's 32-item-per-menu limit.
---@param menuValue table `value` property entry from the triggering menu item, which contains all properties necessary to configure the auto-split menu (see Auto-Split Menu Properties below).
function Menus:PrepareAutoSplitMenu(menuValue)
	assert(type(menuValue) == "table", "Menus:PrepareAutoSplitMenu(): menuValue must be a table")
	local autoSplitMenuType = menuValue.autoSplitMenuType
	assert(self.autoSplitMenuList[autoSplitMenuType], "Menus:PrepareAutoSplitMenu(): Auto-Split menu type '" .. tostring(autoSplitMenuType) .. "' not found")

	local autoSplitMenu = self.menuList[AUTO_SPLIT_MENU_LIST_TYPE]
	local autoSplitMenuParams = self.autoSplitMenuList[autoSplitMenuType]

	-- Auto-Split Menu Properties.

	---@type any Object or object ID **UPON WHICH** this auto-split menu is acting. Will be passed to functions as arg1.objectId.
	--- For example, this could be the ID of the group to which a new category needs to be added.
	local objectId = menuValue.objectId

	---@type any[]? Actual list of items potentially contained in the menu. Passed as the second parameter to omitFunc so item properties can be looked up.
	local itemList = menuValue.itemList or autoSplitMenuParams.itemList

	---@type any[] List of item IDs with which to populate the menu.
	local idList = menuValue.idList or autoSplitMenuParams.defaultIdList

	---@type any[]? List of item IDs which should be omitted from the menu.
	local idsToOmit = menuValue.idsToOmit

	---@type any[]? List of item IDs which should be disabled on the menu.
	local idsToDisable = menuValue.idsToDisable

	---@type any[]? List of item IDs which should be checked on the menu.
	local idsToCheck = menuValue.idsToCheck

	---@type function? Sort the given array of IDs in-place by the text that will be returned by nameFunc.
	---```
	--- ---@param idList table Array of item IDs
	--- ---sortFunc(idList)
	---```
	local sortFunc = menuValue.sortFunc or autoSplitMenuParams.sortFunc

	---@type function? Executed when the menu item is clicked. Invoked by `Menus._autoSplitMenuItem_Click()`.
	---```
	--- ---@param arg1 table This is the `arg1` table set up in `addAutoSplitMenuItem()` and updated by `PopulateAutoSplitMenuItems()`.
	--- ---@param arg2 any ID of the item the menu entry represents.
	--- ---clickFunc(arg1, arg2)
	---```
	local clickFunc = menuValue.func

	---@type function? Decide whether the menu entry for a given item should be checked.
	---```
	--- ---@param itemId any ID of the item the menu entry represents.
	--- ---@param menuItem table Actual menu table entry.
	--- ---@param triggeringMenuValue table The `value` property of the menu item that triggered the auto-split menu.
	--- ---@return boolean checked
	--- ---checkFunc(itemId, menuItem, triggeringMenuValue)
	---```
	local checkFunc = menuValue.checkFunc

	---@type function? Decide whether the menu entry for a given item should be disabled.
	---```
	--- ---@param itemId any ID of the item the menu entry represents.
	--- ---@param menuItem table Actual menu table entry.
	--- ---@param triggeringMenuValue table The `value` property of the menu item that triggered the auto-split menu.
	--- ---@return boolean disabled
	--- ---checkFunc(itemId, menuItem, triggeringMenuValue)
	---```
	local disableFunc = menuValue.disableFunc

	---@type function? Decide whether the menu entry for a given item should be omitted.
	--- NOT CALLED unless `itemList` is provided.
	---```
	--- ---@param itemId any ID of the item the menu entry represents.
	--- ---@param menuItem table? `itemList`, if available.
	--- ---@return boolean omit
	--- ---omitFunc(itemId, itemList)
	---```
	local omitFunc = menuValue.omitFunc

	---@type table? List of additional static menu items that should be added to the bottom of the menu.
	--- 1/2: This one comes from the original configuration of the auto-split menu.
	local baseExtraMenuitems = autoSplitMenuParams.extraItems

	---@type table? List of additional static menu items that should be added to the bottom of the menu.
	--- 2/2: This one comes from the triggering menu item's `value.autoSplitMenuExtraItems` property.
	local extraMenuitems = menuValue.autoSplitMenuExtraItems

	---@type number? When constructing the "N - Z" parent menu item, go back this number of items to determine the second entry (Z).
	--- This is used to ensure that extra menu items don't mess up alphabetic ranges (the Rule Function menu for the Categories UI needs it).
	local triggeringMenuEndRangeOmitIdCount = menuValue.triggeringMenuEndRangeOmitIdCount or 0


	-- Prepare to build the menu.

	local firstIndex, lastIndex, submenuLastItemIndex, submenuFirstItem, submenuLastItem, nextSubmenuFirstItem
	local menuStartText, menuEndText, nextMenuStartText, nextMenuStartTextMinLength, prevNextMenuStartText, displayStartText, displayEndText
	local menuItemNum = 1

	-- The number of available submenu entries will be decreased by the number of extra menu items.
	local numExtraItems =
		(type(baseExtraMenuitems) == "table" and table.getn(baseExtraMenuitems) or 0)
		+ (type(extraMenuitems) == "table" and table.getn(extraMenuitems) or 0)

	-- Reset reusable tables.
	BsUtil.TableClear(self.autoSplitMenuItemIds)
	local idListSorted = self.autoSplitMenuItemIds

	-- Add IDs not being skipped to the reusable storage table.
	for _, id in ipairs(idList) do
		if
			-- idsStoOmit is an array, not an associative table, so we need to check contents by looping.
			BsUtil.TableContainsValue(idsToOmit, id) == nil
			-- Call omitFunc() if present.
			and (
				(type(omitFunc) ~= "function" or type(itemList) ~= "table")
				or not omitFunc(id, itemList)
			)
		then
			table.insert(idListSorted, id)
		end
	end

	-- Ensure list is sorted correctly.
	if type(sortFunc) == "function" then
		sortFunc(idListSorted)
	end


	local idCount = table.getn(idListSorted)

	-- We need this many submenus. Count of extra items is subtracted because they
	-- are top-level and decrease the number of available buttons.
	local submenuCount = math.ceil(idCount / (_G.UIDROPDOWNMENU_MAXBUTTONS - numExtraItems))

	-- Decide whether to build submenus or toss everything at the first level.
	if submenuCount > 1 then
		-- We need submenus.

		lastIndex = 0
		for submenuNum = 1, submenuCount do

			if menuItemNum > _G.UIDROPDOWNMENU_MAXBUTTONS then
				break
			end

			firstIndex = lastIndex + 1
			lastIndex = math.min((firstIndex + _G.UIDROPDOWNMENU_MAXBUTTONS - 1), idCount)
			submenuLastItemIndex = lastIndex

			-- Once we reach the last item, adjust the index of the item we're going to use
			-- to determine the "Z" in "N - Z" (see `triggeringMenuEndRangeOmitIdCount` declaration).
			if submenuNum == submenuCount then
				submenuLastItemIndex = submenuLastItemIndex - triggeringMenuEndRangeOmitIdCount
			end

			-- Safeguard.
			if firstIndex > idCount then
				break
			end

			-- Figure out the triggering menu text by adding letters until they're different.

			-- First, do the items that start and end this submenu.
			submenuFirstItem = autoSplitMenuParams.nameFunc(idListSorted[firstIndex], menuValue)
			submenuLastItem = autoSplitMenuParams.nameFunc(idListSorted[submenuLastItemIndex], menuValue)
			menuStartText, menuEndText = self:BuildAutoSplitSubmenuRangeTexts(submenuFirstItem, submenuLastItem, prevNextMenuStartText, nil)

			-- Now we need to check the ending item against the first item of the next submenu to avoid having a situation like:
			-- A - C >
			-- C - N >
			-- when what we want is:
			-- A - Cl >
			-- Co - N >

			-- There's only a first item for the next submenu if we haven't run out of items.
			nextSubmenuFirstItem =
				(lastIndex + 1 <= idCount)
					and autoSplitMenuParams.nameFunc(idListSorted[lastIndex + 1], menuValue)
					or nil

			-- To decide whether any adjustment of the end text is necessary, grab the first
			-- `<length of this menu's end text>` letters of the next submenu's first item for comparison.
			-- `nextMenuStartText` is used during this loop and also captured into `prevNextMenuStartText`
			-- for use in the next loop's call to `BuildCategorySubmenuRangeTexts()`.
			nextMenuStartText = (nextSubmenuFirstItem ~= nil) and string.sub(nextSubmenuFirstItem, 1, string.len(menuEndText)) or ""

			-- Change the end text and/or the next menu's start text when the next
			-- start text would be the same, or if there is a matching prefix.
			nextMenuStartTextMinLength = 0
			if string.len(nextMenuStartText) > 0 then
				if nextMenuStartText == menuEndText then
					-- They're exactly the same, so keep adding characters.
					nextMenuStartTextMinLength = string.len(menuEndText)

				elseif string.sub(nextMenuStartText, 1, -2) == string.sub(menuEndText, 1, -2) then
					-- They have a shared prefix, so the next start text needs to be
					-- at least the same length as the current end text.
					nextMenuStartTextMinLength = string.len(menuEndText) - 1

				else
					nextMenuStartText = nil
				end

			end

			-- Make adjustments.			
			if nextMenuStartTextMinLength > 0 then
				menuEndText, nextMenuStartText = self:BuildAutoSplitSubmenuRangeTexts(
					submenuLastItem,
					nextSubmenuFirstItem,
					nil,nextMenuStartTextMinLength
				)
			else
				-- When the next menu's first item has different text from the current menu's
				-- last item, we won't need `prevNextMenuStartText`, so just nil this out here.
				nextMenuStartText = nil
			end


			-- Menu item that will trigger the submenu.
			local menuItem = autoSplitMenu.levels[1][menuItemNum]  -- This has to use menuItemNum, NOT submenuNum.

			displayStartText = menuStartText
			displayEndText = menuEndText
			if autoSplitMenuParams.parentMenuNameTrimFunc then
				displayStartText = autoSplitMenuParams.parentMenuNameTrimFunc(menuStartText)
				displayEndText = autoSplitMenuParams.parentMenuNameTrimFunc(menuEndText)
			end

			-- Base values.
			menuItem.text = displayStartText .. (displayEndText ~= displayStartText and (" - " .. displayEndText) or "")
			menuItem.isTitle = false
			menuItem.tooltipTitle = menuValue.tooltipTitle
			menuItem.tooltipText = menuValue.tooltipText
			menuItem.disabled = false
			menuItem.notCheckable = menuValue.notCheckable
			menuItem.value.value = submenuNum  -- This is the submenu to load.
			menuItem.arg2 = nil  -- self._autoSplitMenuItem_Click() will see arg2 is nil and not close the menu.
			menuItem.hasArrow = 1
			menuItem.func = nil
			menuItem._bagshuiHide = false

			-- These are needed to pass values through to the next level via LoadMenu().

			menuItem.value.autoSplitMenuType = autoSplitMenuType
			menuItem.value.autoSplitMenuExtraItems = extraMenuitems
			menuItem.value.objectId = objectId
			menuItem.value.itemList = itemList
			menuItem.value.idList = idList
			menuItem.value.idsToOmit = idsToOmit
			menuItem.value.idsToDisable = idsToDisable
			menuItem.value.idsToCheck = idsToCheck
			menuItem.value.checkFunc = checkFunc
			menuItem.value.disableFunc = disableFunc
			menuItem.value.omitFunc = omitFunc
			menuItem.value.func = clickFunc
			menuItem.value.keepShownOnClick = menuValue.keepShownOnClick
			menuItem.value.notCheckable = menuValue.notCheckable
			menuItem.value.tooltipTitleFunc = menuValue.tooltipTitleFunc
			menuItem.value.tooltipTextFunc = menuValue.tooltipTextFunc

			-- Fill the submenu and place a check mark next to the parent menu
			-- if any submenu items are checked.
			menuItem.checked = self:PopulateAutoSplitMenuItems(
				menuValue,
				autoSplitMenuParams,
				autoSplitMenu.levels[2][submenuNum],
				idListSorted,
				objectId,
				firstIndex,
				lastIndex,
				idsToCheck,
				idsToDisable,
				clickFunc,
				checkFunc,
				1
			)

			-- Prepare for the next loop.

			prevNextMenuStartText = nextMenuStartText
			menuItemNum = menuItemNum + 1

		end  -- Menu-building for loop.


	else
		-- Only one level; no submenus.
		self:PopulateAutoSplitMenuItems(
			menuValue,
			autoSplitMenuParams,
			autoSplitMenu.levels[1],
			idListSorted,
			objectId,
			menuItemNum,  -- firstIndex.
			nil,  -- lastIndex is nil to trigger use of the remaining list.
			idsToCheck,
			idsToDisable,
			clickFunc,
			checkFunc,
			menuItemNum
		)

		menuItemNum = menuItemNum + idCount

	end

	-- Add "extra" items to bottom of menu.
	if numExtraItems > 0 then
		if type(extraMenuitems) == "table" and table.getn(extraMenuitems) > 0 then
			self:PopulateAutoSplitMenuItems(
				menuValue,
				autoSplitMenuParams,
				autoSplitMenu.levels[1],
				extraMenuitems,
				objectId,
				1,
				numExtraItems,
				idsToCheck,
				idsToDisable,
				clickFunc,
				checkFunc,
				menuItemNum
			)
			menuItemNum = menuItemNum + table.getn(extraMenuitems)
		end
		if type(baseExtraMenuitems) == "table" and table.getn(baseExtraMenuitems) > 0 then
			self:PopulateAutoSplitMenuItems(
				menuValue,
				autoSplitMenuParams,
				autoSplitMenu.levels[1],
				baseExtraMenuitems,
				objectId,
				1,
				numExtraItems,
				idsToCheck,
				idsToDisable,
				clickFunc,
				checkFunc,
				menuItemNum
			)
			menuItemNum = menuItemNum + table.getn(baseExtraMenuitems)
		end
	end

	-- Menu was empty and nothing has been populated
	if menuItemNum == 1 then
		self:PopulateAutoSplitMenuItems(
			menuValue,
			autoSplitMenuParams,
			autoSplitMenu.levels[1],
			self.autoSplitMenuItemIds,  -- Just need a table whose getn is 0.
			objectId,
			nil, -- firstIndex and
			nil, -- lastIndex are nil to trigger use of the entire list.
			idsToCheck,
			idsToDisable,
			clickFunc,
			checkFunc,
			menuItemNum
		)
	end

	-- Hide any remaining buttons in the parent menu.
	self:HideMenuItems(autoSplitMenu.levels[1], menuItemNum)

end




--- Populate the given auto-split menu with items.
---
--- There is some inconsistency around how properties get picked up -- some come
--- from this function's arguments, others from `triggeringMenuValue`/`autoSplitMenuParams`.
--- That's not getting cleaned up at this point.
---@param triggeringMenuValue table<string,any> `value` property of the menu item that triggered this auto-split menu.
---@param autoSplitMenuParams table<string,any> Configuration of this auto-split menu.
---@param autoSplitMenu table<string,any>[] List of menu entries.
---@param idList any[] List of item IDs with which to populate the menu.
---@param objectId any Object or object ID **UPON WHICH** this auto-split menu is acting. Will be passed to functions as arg1.objectId.
---@param firstIndex number? Start position within `idList`, inclusive.
---@param lastIndex number? End position within `idList`, inclusive.
---@param idsToCheck any?[] List of item IDs which should be checked on the menu.
---@param idsToDisable any?[] List of item IDs which should be disabled on the menu.
---@param clickFunc function? Executed when the menu item is clicked. Invoked by `Menus._autoSplitMenuItem_Click()`. See declaration in `PrepareAutoSplitMenu()` for details.
---@param checkFunc function? Decide whether the menu entry for a given item should be checked. See declaration in `PrepareAutoSplitMenu()` for details.
---@param menuItemStartNum number? Starting point within `autoSplitMenu` for menu entries.
---@return boolean hasCheckedItems true if one or more menu items received a check mark.
function Menus:PopulateAutoSplitMenuItems(
	triggeringMenuValue,
	autoSplitMenuParams,
	autoSplitMenu,
	idList,
	objectId,
	firstIndex,
	lastIndex,
	idsToCheck,
	idsToDisable,
	clickFunc,
	checkFunc,
	menuItemStartNum
)
	-- Keep track of the count so we can hide unused menu items.
	local menuItemNum = menuItemStartNum or 1
	local menuItemCount = menuItemNum - 1

	-- Return value.
	local hasCheckedItems = false

	local itemId, itemName, menuItem, menuItemFunc
	local nameFunc = triggeringMenuValue.nameFunc or autoSplitMenuParams.nameFunc
	local disableFunc = triggeringMenuValue.disableFunc or autoSplitMenuParams.disableFunc
	local tooltipTitleFunc = triggeringMenuValue.tooltipTitleFunc or autoSplitMenuParams.tooltipTitleFunc
	local tooltipTextFunc = triggeringMenuValue.tooltipTextFunc or autoSplitMenuParams.tooltipTextFunc

	-- Iterate through idList using the given start/end points.
	for i = firstIndex or 1, lastIndex or table.getn(idList) do

		-- Safeguard - don't overfill the menu.
		if menuItemCount > _G.UIDROPDOWNMENU_MAXBUTTONS then
			break
		end

		menuItem = autoSplitMenu[menuItemNum]

		-- Reset/Set defaults.

		menuItem.arg1.objectId = objectId
		menuItem.arg1.menuItem = menuItem
		menuItem.isTitle = false
		menuItem.disabled = false
		menuItem.hasArrow = false
		menuItem.tooltipTitle = nil
		menuItem.tooltipText = nil
		menuItem.checked = false
		menuItem.keepShownOnClick = triggeringMenuValue.keepShownOnClick
		menuItem.notCheckable = triggeringMenuValue.notCheckable
		menuItem._bagshuiHide = false

		menuItemFunc = self._autoSplitMenuItem_Click

		if type(idList[i]) == "table" then

			-- When an item within the ID list is a table, assume it's an "extra" menu item.

			-- Transfer all properties to the live menu item.
			for menuItemKey, menuItemProperty in pairs(idList[i]) do

				-- Need special handling for auto-split menu parameters in the value table.

				if menuItemKey == "value" and type(menuItemProperty) == "table" then
					for valueKey, valueSetting in pairs(menuItemProperty) do
						-- value.func should be assigned to arg1.func so it passes through properly.
						if valueKey == "func" then
							menuItem.arg1.func = valueSetting

						elseif valueKey == "tooltipTextFunc" and type(valueSetting) == "function" then
							menuItem.tooltipText = valueSetting()
						end
					end

				elseif menuItemKey == "func" then
					-- Override _autoSplitMenuItem_Click() with a custom function.
					menuItemFunc = menuItemProperty

				else
					-- Normal property assignment.
					menuItem[menuItemKey] = menuItemProperty
				end
			end

		else
			itemId = idList[i]

			-- Populate the menu.

			-- Figure out the name, passing it through the revision function if one is available.
			itemName = type(nameFunc) == "function" and nameFunc(itemId, triggeringMenuValue) or itemId
			if type(triggeringMenuValue.nameRevisionFunc) == "function" then
				itemName = triggeringMenuValue.nameRevisionFunc(itemId, itemName, triggeringMenuValue)
			end
			menuItem.text = itemName

			menuItem.disabled = (BsUtil.TableContainsValue(idsToDisable, itemId) ~= nil)

			menuItem.tooltipTitle = itemName
			if type(autoSplitMenuParams.tooltipTitleFunc) == "function" then
				menuItem.tooltipTitle = autoSplitMenuParams.tooltipTitleFunc(itemId, menuItem.tooltipTitle) or itemName
			end
			if type(triggeringMenuValue.tooltipTitleFunc) == "function" then
				menuItem.tooltipTitle = triggeringMenuValue.tooltipTitleFunc(itemId, menuItem.tooltipTitle)
			end

			menuItem.tooltipText = nil
			if type(autoSplitMenuParams.tooltipTextFunc) == "function" then
				menuItem.tooltipText = autoSplitMenuParams.tooltipTextFunc(itemId, menuItem.tooltipText)
			end
			if type(triggeringMenuValue.tooltipTextFunc) == "function" then
				menuItem.tooltipText = triggeringMenuValue.tooltipTextFunc(itemId, menuItem.tooltipText)
			end

			menuItem.arg1.func = clickFunc

			menuItem.arg2 = itemId

			-- Put a check mark next to the item when its id is in idsToCheck or checkFunc() returns true.
			menuItem.checked =
				BsUtil.TableContainsValue(idsToCheck, itemId) ~= nil
				or
				(type(checkFunc) == "function" and checkFunc(itemId, menuItem, triggeringMenuValue))

			if menuItem.checked then
				hasCheckedItems = true
			end
		end

		-- Assign click function.
		menuItem.func = menuItemFunc

		-- Call disable function if available.
		if disableFunc then
			menuItem.disabled = disableFunc(itemId, menuItem, triggeringMenuValue)
		end

		-- Keep track of the count so we can hide extra menu items.
		menuItemCount = menuItemCount + 1
		menuItemNum = menuItemNum + 1
	end

	-- "(No Items Available)".
	if menuItemCount == 0 then
		menuItemNum = 1
		menuItem = autoSplitMenu[menuItemNum]
		menuItem.text = L.NoItemsAvailable
		menuItem.disabled = true
		menuItem.hasArrow = false
		menuItem._bagshuiHide = false
		menuItemNum = 2
	end

	-- Hide unused menu items.
	self:HideMenuItems(autoSplitMenu, menuItemNum)

	return hasCheckedItems
end



--- Determines the best naming for auto-split menu parent items by iterating until
--- the start and end texts are different. For example, given "Armor" and "Arrows",
--- "Arm" and "Arr" would be the return values.
---@param startItemName string Text of the first item in the submenu.
---@param endItemName string Text of the last item in the submenu.
---@param previousStartText string? Text of the last item in the *previous* submenu.
---@param textLengthStart number? Iteration for comparing `startItemName` to `endItemName` will begin at this length.
---@return string|unknown startText
---@return string|unknown endText
function Menus:BuildAutoSplitSubmenuRangeTexts(startItemName, endItemName, previousStartText, textLengthStart)
	local submenuTextCharCount = textLengthStart or 0
	local startText, endText
	local tries = 0

	repeat
		tries = tries + 1
		submenuTextCharCount = submenuTextCharCount + 1

		-- The first entry needs to take into account what we figured out during the previous loop to avoid
		-- incorrectly truncating it back to something smaller. Until the number of required characters for this
		-- loop exceeds the length of the previous loop's "next" start text, stick to what we found in the previous loop.
		startText =
			(previousStartText ~= nil and BsUtil.Utf8Len(previousStartText) >= submenuTextCharCount)
				and previousStartText
				or BsUtil.Utf8Sub(startItemName, 1, submenuTextCharCount)
		endText = BsUtil.Utf8Sub(endItemName, 1, submenuTextCharCount)

		-- Remove punctuation from ends of strings if it doesn't make them the same.
		if
			startText ~= endText
		then
			-- Don't strip punctuation if the string is ALL punctuation.
			local startWithoutTrailingPunctuation = not string.find(startText, "^%p+$") and string.gsub(startText, "%W+$", "") or startText
			local endWithoutTrailingPunctuation = not string.find(endText, "^%p+$") and string.gsub(endText, "%W+$", "") or endText
			if startWithoutTrailingPunctuation ~= endWithoutTrailingPunctuation then
				startText = startWithoutTrailingPunctuation
				endText = endWithoutTrailingPunctuation
			end
		end

	until (
		(
			startText ~= endText
			-- Ensure endText isn't just the beginning of startText
			and not string.find(startText, "^" .. string.gsub(endText, "(%W)", "%%%1"))
			-- Ensure items don't end with punctuation where possible
			and (string.find(startText, "[^%p]$") or string.find(startText, "^%p+$"))
			and (string.find(endText, "[^%p]$") or string.find(endText, "^%p+$"))
		)
		or
		(
			startText == startItemName
			and endText == endItemName
		)
		-- Safeguard: Prevent an infinite loop.
		or tries >= 500
	)
	return startText, endText
end



-- Perform initialization.
Menus:Init()


end)