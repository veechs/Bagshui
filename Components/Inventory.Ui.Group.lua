-- Bagshui Inventory Prototype: Groups

Bagshui:AddComponent(function()
local Inventory = Bagshui.prototypes.Inventory
local InventoryUi = Bagshui.prototypes.InventoryUi


--#region Groups

--- Trigger Edit Mode colors and tooltips.
--- This is part of the Inventory class instead of a local function like the other
--- group script functions so that it's available to call from Inventory:ItemSlotAndGroupMouseOverCheck().
---@param group table Group UI frame.
function Inventory:Group_OnEnter(group)
	local this = group or _G.this
	local ui = this.bagshuiData.ui
	local inventory = ui.inventory

	-- It feels weird to have colors flashing under the cursor and tooltips appearing when menus are open.
	-- (The IsMouseEnabled() check is just a safeguard.)
	if inventory.menus:IsMenuOpen() or not this:IsMouseEnabled() then
		return
	end

	-- Actual mouseover status tracking, since MouseIsOver() returns true even
	-- when other frames are in front of this one.
	this.bagshuiData.mouseIsOver = true

	-- Update colors and borders for mouseover.
	ui:SetGroupColors(this, false)

	-- Show tooltip in Edit Mode when the user hasn't picked up an object.
	if inventory.editMode and not inventory:EditModeCursorHasItem() then
		local groupId = this.bagshuiData.groupId
		local groupName =
			string.len(inventory.groups[groupId].name or "") > 0
			and inventory.groups[groupId].name
			or L.UnnamedGroup

		-- Prepare tooltips.
		_G.GameTooltip:SetOwner(this, "ANCHOR_" .. BsUtil.FlipAnchorPoint(inventory.settings.windowAnchorXPoint))

		-- Format the group name.
		_G.GameTooltip:AddLine(Bagshui:FormatTooltipLine(groupName, string.format(L.Symbol_Colon, L.Group), true))

		-- Build bulleted category list.
		_G.GameTooltip:AddLine(string.format(L.Symbol_Colon, L.Categories), nil, nil, nil, true) -- "Categories:"
		local categoryList = inventory.groups[groupId] and inventory.groups[groupId].categories
		if type(categoryList) == "table" and table.getn(categoryList) > 0 then
			-- Need to smash them all into one line to circumvent the 30 line tooltip limit.
			local categories = ""
			BsCategories:SortIdList(categoryList)
			for _, categoryId in ipairs(categoryList) do
				if BsCategories.list[categoryId] then
					categories = categories
						.. GRAY_FONT_COLOR_CODE .. "• " .. FONT_COLOR_CODE_CLOSE
						.. HIGHLIGHT_FONT_COLOR_CODE .. (BsCategories:GetName(categoryId) or tostring(categoryId)) .. FONT_COLOR_CODE_CLOSE
						.. BS_NEWLINE
				end
			end
			_G.GameTooltip:AddLine(BsUtil.Trim(categories), nil, nil, nil, true)

		else
			-- No categories assigned.
			_G.GameTooltip:AddLine(GRAY_FONT_COLOR_CODE .. L.NoneAssigned .. FONT_COLOR_CODE_CLOSE, nil, nil, nil, true)
		end

		-- Put instructions in Bagshui info tooltip.
		Bagshui:SetInfoTooltipPosition(this, true, true)
		inventory:AddBagshuiInfoTooltipLine(L.Click, string.format(L.Symbol_Colon, string.format(L.Prefix_Move, L.Group)))
		inventory:AddBagshuiInfoTooltipLine(L.RightClick, string.format(L.Symbol_Colon, string.format(L.Suffix_Menu, L.Group)))

		_G.GameTooltip:Show()
		Bagshui:ShowInfoTooltip()
	end
end


--- Reset colors, hide tooltips.
local function Group_OnLeave()
	local this = _G.this
	local ui = this.bagshuiData.ui

	this.bagshuiData.mouseIsOver = false
	Bagshui:HideTooltips()
	if not this:IsMouseEnabled() then
		return
	end
	ui:SetGroupColors(this, false)
end


--- Edit Mode interactions for groups.
local function Group_OnClick()
	local this = _G.this
	local ui = this.bagshuiData.ui
	local inventory = ui.inventory

	-- This isn't really necessary because group interactivity is disabled outside Edit Mode, but let's have a safeguard.
	if not inventory.editMode then
		return
	end

	-- Left/Right click.
	if _G.arg1 == "LeftButton" or inventory:EditModeCursorHasItem() then
		-- When a menu is open, just close it and don't do anything else.
		-- Without this, you can accidentally pick up a group when trying to close a menu.
		if inventory.menus:IsMenuOpen() then
			Bagshui:CloseMenus()
			this:GetScript("OnEnter")()
			-- Tooltips and highlighting may need to reappear.
			inventory:ItemSlotAndGroupMouseOverCheck()
			return
		end

		-- Something is on the cursor, so let's take it off.
		if inventory:EditModeCursorHasItem() then
			if inventory.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.GROUP then
				inventory:AssignGroupToLayout(
					inventory.editState.cursorItem,
					BS_INVENTORY_OBJECT_TYPE.GROUP,
					BS_INVENTORY_LAYOUT_DIRECTION.COLUMN,
					this.bagshuiData.rowNum,
					this.bagshuiData.columnNum
				)

			elseif inventory.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.CATEGORY then
				inventory:AssignCategoryToGroup(
					inventory.editState.cursorItem,
					this.bagshuiData.groupId
				)

			elseif inventory.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.ITEM then
				inventory:ShowItemCategoryAssignmentMenuForGroup(
					inventory.editState.cursorItem,
					this
				)

			else
				-- Failsafe
				inventory:ClearEditModeCursor()
			end
			_G.PlaySound("INTERFACESOUND_CURSORDROPOBJECT")


		else
			-- Nothing on the cursor - pick up the group.
			-- _G.PlaySound is handled by PickUpGroup().
			this:GetScript("OnLeave")()
			inventory:EditModePickUpGroup(this.bagshuiData.groupId)
			ui:SetGroupColors(this, false)
		end


	elseif _G.arg1 == "RightButton" then
		inventory.menus:OpenMenu("Group", this, nil, "cursor")
	end
end


--- Highlight group when the mouse button is pressed to indicate that it will be dragged.
local function Group_OnMouseDown()
	if not _G.this:IsEnabled() then
		return
	end
	_G.this.bagshuiData.ui:SetGroupColors(_G.this, true)
end


--- Remove group highlight.
local function Group_OnMouseUp()
	_G.this.bagshuiData.ui:SetGroupColors(_G.this, false)
end


--- Pick up the group.
local function Group_OnDragStart()
	_G.this:Click()
end



---Create a new group frame that holds item slot buttons.
---@param groupNum number? When provided, only create the group if it doesn't exist.
function InventoryUi:CreateGroup(groupNum)
	local ui = self

	-- Declare reusable group creation function.
	if not ui.CreateGroupIfNotExists then

		-- Wrapper function.
		local function Group_OnEnter()
			ui.inventory:Group_OnEnter()
		end

		function ui.CreateGroupIfNotExists(elementNum)
			-- Group frame is actually a button so it can have an OnClick event.
			ui.frames.groups[elementNum] = _G.CreateFrame(
				"Button",
				ui:CreateElementName("Group" .. elementNum),
				ui.frames.main
			)
			local group = ui.frames.groups[elementNum]
			group.bagshuiData = {
				type = BS_INVENTORY_OBJECT_TYPE.GROUP,
				text = nil,
				mouseIsOver = false,
				groupId = nil,
				rowNum = nil,
				ColumNum = nil,
				ui = ui,
			}

			-- It feels better when the group is a little bigger than the visual would indicate.
			group:SetHitRectInsets(2, 2, 2, 2)

			-- Set default appearance.
			ui:SetFrameBackdrop(group)

			-- Add label text in top left corner.
			-- This has to be in a frame so the full label can be revealed on mouseover.
			group.bagshuiData.labelFrame, group.bagshuiData.text = ui:CreateLabel(group, ui.frames.main)

			-- Add group behaviors
			group:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			group:RegisterForDrag("LeftButton")
			group:SetScript("OnEnter", Group_OnEnter)
			group:SetScript("OnLeave", Group_OnLeave)
			group:SetScript("OnClick", Group_OnClick)
			group:SetScript("OnMouseDown", Group_OnMouseDown)
			group:SetScript("OnMouseUp", Group_OnMouseUp)
			group:SetScript("OnDragStart", Group_OnDragStart)
		end
	end

	-- Perform group creation.
	ui:CreateIfNotExists(
		groupNum,
		ui.frames.groups,
		ui.CreateGroupIfNotExists
	)

	-- Create a corresponding group move target.
	-- We'll need at least `<number of groups> + 2` to complete
	-- the layout, but UpdateWindow() will take care of that.
	ui:CreateGroupMoveTarget(groupNum)
end



--- Set the colors of a group / group move target.
---@param uiGroup table Group or group move target frame (type will be determined via `uiGroup.bagshuiData.type`).
---@param mouseDown boolean? Control whether the extra highlighting to indicate mouse button press should be applied.
function InventoryUi:SetGroupColors(uiGroup, mouseDown)
	local inventory = self.inventory

	-- Default values.

	local backdropOpacity = 0.1
	local backdropColor = BS_COLOR.WHITE
	local borderOpacity = 0.5
	local borderColor = BS_COLOR.GRAY
	local textOpacity = 0.5  -- This will be the base opacity in Edit Mode.
	local textColor = BS_COLOR.WHITE

	-- Track whether this Group has been picked up.
	local groupIsOnCursor = false
	local highlightThisGroup = false

	-- These are only applicable to groups, not group move targets.
	if uiGroup.bagshuiData.type == BS_INVENTORY_OBJECT_TYPE.GROUP then
		local groupId = uiGroup.bagshuiData.groupId

		-- Group color priority:
		-- 1. Per-group setting.
		-- 2. Skin colors, if groupUseSkinColors is enabled and applicable for the setting.
		-- 3. Default colors.

		backdropColor = inventory.groups[groupId] and inventory.groups[groupId].background
						or inventory.settings.groupUseSkinColors and BsSkin.skinBackgroundColor
		                or inventory.settings.groupBackgroundDefault
		backdropOpacity = backdropColor[4]

		borderColor = inventory.groups[groupId] and inventory.groups[groupId].border
					  or inventory.settings.groupUseSkinColors and BsSkin.skinBorderColor
		              or inventory.settings.groupBorderDefault
		borderOpacity = borderColor[4]

		-- Outline the group in yellow if it's on the cursor or highlighting is requested.
		groupIsOnCursor = inventory.editState.cursorItem == groupId
		highlightThisGroup = inventory.editModeGroupHighlight == groupId

		textColor = inventory.groups[groupId] and inventory.groups[groupId].label
		            or inventory.settings.groupLabelDefault

		-- Use configured label opacity outside Edit Mode.
		if not inventory.editMode then
			textOpacity = textColor[4]
		end
	end

	-- Highlight the group.
	if
		-- In Edit Mode when the cursor has an item and one of the following is true:
		-- - This is a group move target.
		-- - This group is on the cursor.
		-- - There is another group on the cursor and this group mis moused over.
		(
			inventory:EditModeCursorHasItem()
			and (
				uiGroup.bagshuiData.type == BS_INVENTORY_OBJECT_TYPE.GROUP_MOVE_TARGET
				or groupIsOnCursor
				or (inventory.editState.cursorItemType == BS_INVENTORY_OBJECT_TYPE.GROUP and uiGroup.bagshuiData.mouseIsOver)
			)
		)
		-- When this group is being targeted in Edit Mode via self.editModeGroupHighlight.
		or highlightThisGroup
	then
		borderOpacity = (groupIsOnCursor or highlightThisGroup) and 0.8 or 0.6
		borderColor = BS_COLOR.YELLOW
		textOpacity = 0.8
		textColor = BS_COLOR.YELLOW
	end

	-- Apply mouse button down/mouseover opacity changes.
	if mouseDown then
		backdropOpacity = math.max(backdropOpacity, 0.3)
		borderOpacity = math.max(borderOpacity, 1)
		textOpacity = 1

	elseif uiGroup.bagshuiData.mouseIsOver then
		backdropOpacity = math.max(backdropOpacity, 0.2)
		borderOpacity = math.max(borderOpacity, 0.9)
		textOpacity = 0.9
	end

	-- Apply special backdrop color for highlighted group.
	if highlightThisGroup or groupIsOnCursor then
		backdropColor = BS_COLOR.YELLOW
		backdropOpacity = 0.25
	end

	-- Set colors.
	uiGroup:SetBackdropColor(backdropColor[1], backdropColor[2], backdropColor[3], backdropOpacity)
	uiGroup:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderOpacity)
	if uiGroup.bagshuiData.text then
		uiGroup.bagshuiData.text:SetTextColor(textColor[1], textColor[2], textColor[3], textOpacity)
	end
end



--- Control whether a group has interactivity enabled. Used when entering/exiting Edit Mode.
---@param uiGroup table Group frame.
---@param enabled boolean Whether the group should receive mouse events.
function InventoryUi:SetGroupInteractivityEnabled(uiGroup, enabled)
	uiGroup:EnableMouse(enabled)
end


--#endregion Groups



--#region Groups Move Targets

--- Trigger color changes and tooltips.
local function GroupMoveTarget_OnEnter()
	local this = _G.this
	local ui = this.bagshuiData.ui
	local inventory = ui.inventory

	-- It feels weird to have colors flashing under the cursor and tooltips appearing when menus are open.
	if inventory.menus:IsMenuOpen() then
		return
	end

	this.bagshuiData.mouseIsOver = true
	ui:SetGroupColors(this, false)

	-- Don't show tooltip if there's an item held on the Edit Mode cursor.
	if inventory:EditModeCursorHasItem() then
		return
	end

	-- Place tooltip in bottom right of the screen.
	_G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, this)
	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetText(string.format(L.Prefix_New, L.Group))  -- "Add Group"
	_G.GameTooltip:Show()
end


--- Hide tooltips and reset colors.
local function GroupMoveTarget_OnLeave()
	local this = _G.this
	local ui = this.bagshuiData.ui

	this.bagshuiData.mouseIsOver = false
	ui:SetGroupColors(this, false)
	Bagshui:HideTooltips()
end


--- Create a new group and move the object on the cursor into it if applicable.
local function GroupMoveTarget_OnClick()
	local this = _G.this
	local inventory = this.bagshuiData.ui.inventory

	this.bagshuiData.ui.inventory:AssignGroupToLayout(
		inventory.editState.cursorItem,
		inventory.editState.cursorItemType,
		this.bagshuiData.insert,
		this.bagshuiData.rowNum,
		this.bagshuiData.columnNum
	)
end


--- Highlight.
local function GroupMoveTarget_OnMouseDown()
	_G.this.bagshuiData.ui:SetGroupColors(_G.this, true)
end


--- Un-highlight.
local function GroupMoveTarget_OnMouseUp()
	_G.this.bagshuiData.ui:SetGroupColors(_G.this, false)
end


---Create a new UI group move target button.
---@param groupMoveTargetNum number? When provided, only create the group move target if it doesn't exist.
function InventoryUi:CreateGroupMoveTarget(groupMoveTargetNum)
	local ui = self
	local inventory = self.inventory

	-- Declare reusable group move target creation function.
	if not ui.CreateGroupMoveTargetIfNotExists then
		function ui.CreateGroupMoveTargetIfNotExists(elementNum)
			ui.frames.groupMoveTargets[elementNum] = _G.CreateFrame(
				"Frame",
				ui:CreateElementName("GroupMoveTarget" .. elementNum),
				ui.frames.main
			)

			local button = _G.CreateFrame(
				"Button",
				ui:CreateElementName("GroupMoveTarget" .. elementNum),
				ui.frames.groupMoveTargets[elementNum]
			)

			-- Share Bagshui table between outer frame and actual button
			ui.frames.groupMoveTargets[elementNum].bagshuiData = {
				type = BS_INVENTORY_OBJECT_TYPE.GROUP_MOVE_TARGET,
				button = button,
				mouseIsOver = false,
				insert = nil,
				rowNum = nil,
				columnNum = nil,
				ui = ui,
			}
			button.bagshuiData = ui.frames.groupMoveTargets[elementNum].bagshuiData

			button:EnableMouse(true)
			button:SetHitRectInsets(-4, -4, -4, -4)

			ui:SetFrameBackdrop(
				button,
				"SOLID", -- borderStyle
				nil, -- bgFile
				nil, -- edgeFile
				nil, -- tileSize
				nil, -- edgeSize
				0  -- insets
			)

			local text = button:CreateFontString(nil, nil, "GameFontNormal")
			button.bagshuiData.text = text
			text:SetJustifyH("CENTER")
			text:SetJustifyV("MIDDLE")
			text:SetPoint("TOPLEFT", button, -10, 10)
			text:SetPoint("BOTTOMRIGHT", button, 10, -12)
			text:SetShadowColor(0, 0, 0, 0)
			text:SetShadowOffset(0, 0)
			text:SetFont(text:GetFont(), 13, "THICKOUTLINE, MONOCHROME")
			text:SetText("+")

			-- Set initial colors.
			ui:SetGroupColors(button, false)

			-- Assign behaviors.
			button:SetScript("OnEnter", GroupMoveTarget_OnEnter)
			button:SetScript("OnLeave", GroupMoveTarget_OnLeave)
			button:SetScript("OnClick", GroupMoveTarget_OnClick)
			button:SetScript("OnMouseDown", GroupMoveTarget_OnMouseDown)
			button:SetScript("OnMouseUp", GroupMoveTarget_OnMouseUp)
		end
	end

	-- Perform group move target creation.
	ui:CreateIfNotExists(
		groupMoveTargetNum,
		ui.frames.groupMoveTargets,
		ui.CreateGroupMoveTargetIfNotExists
	)
end

--#endregion Group Move Targets


end)