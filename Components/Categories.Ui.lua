-- Bagshui Category Management UI

Bagshui:AddComponent(function()

local Categories = BsCategories


-- Pull the list of valid player class category fields from the Category object skeleton.
local CLASS_CATEGORY_FIELDS = {}
for fieldName, _ in pairs(BS_CATEGORY_SKELETON.classes[BsGameInfo.characterClasses]) do
	table.insert(CLASS_CATEGORY_FIELDS, fieldName)
end


--- Subclass override for InitUI() to handle class-specific details.
function Categories:InitUi()
	-- ObjectList:InitUi() has the same check, but let's avoid doing any unnecessary work
	-- since the superclass function isn't called immediately.
	if self.objectManager then
		return
	end

	local categories = self

	-- Custom menus.
	self.menus = Bagshui.prototypes.Menus:New()

	-- New Category menu.
	self.menus:AddMenu(
		"NewCategory",
		-- Level 1 contains entries for a blank category and creating from a template.
		{
			{
				text = L.Category,
				func = function()
					self.objectManager:NewObject()
				end,
				notCheckable = true,
			},
			{
				text = L.ClassCategory,
				func = function()
					self.objectManager:NewObject(BS_NEW_CLASS_CATEGORY_TEMPLATE)
				end,
				notCheckable = true,
			},
		},
		-- Nothing for level 2/3.
		nil, nil
	)


	-- Character Class dropdown menu.

	--- Helper function for player class dropdown to prevent UIDropDownMenu_Refresh from adding a check mark.
	---@param dropDown table Dropdown menu WoW UI object.
	local function clearDropDownCheckMarks(dropDown)
		dropDown.selectedID = nil
		dropDown.selectedValue = nil
		dropDown.selectedName = nil
		-- Removing any existing check marks.
		for i = 1, _G.UIDROPDOWNMENU_MAXBUTTONS do
			_G["DropDownList1Button" .. i]:UnlockHighlight()
			_G["DropDownList1Button" .. i .. "Check"]:Hide()
		end
	end

	--- Helper function for player class dropdown to update the selection when an item is clicked.
	---@param dropDown table Dropdown menu WoW UI object.
	---@param value any Value of the item that was clicked.
	local function dropDownMenuSetSelectedValue(dropDown, value)
		dropDown.bagshuiData.selectedValue = value
		_G.UIDropDownMenu_SetSelectedValue(dropDown, value)
		clearDropDownCheckMarks(dropDown)
	end

	--- Callback function for clicking an item in the player class menu.
	---@param arg1 table Will always be classMenuArg1 as defined below.
	local function classMenuFunc(arg1)
		dropDownMenuSetSelectedValue(arg1.dropDown, _G.this.value)
		arg1.editor:SetClass(_G.this.value)
	end

	local classMenu = BsUtil.TableCopy(BsGameInfo.characterClassMenu)
	-- Reusable table for passing values through to the callback function.
	local classMenuArg1 = {}

	-- Generate the menu items and add the menu.
	for _, menuItem in ipairs(classMenu) do
		menuItem.arg1 = classMenuArg1
		menuItem.notCheckable = true
		menuItem.func = classMenuFunc
	end

	self.menus:AddMenu(
		"Classes",
		classMenu,
		-- Nothing for level 2/3.
		nil, nil,
		-- OpenMenu callback.
		function(menu, dropDown, editor)
			clearDropDownCheckMarks(dropDown)
			classMenuArg1.dropDown = dropDown
			classMenuArg1.editor = editor
		end
	)


	-- Prepare the list of available bags.
	-- It would be nice to do this in Config\RuleFunctionTemplates.lua,
	-- but that's not  happening without a lot of refactoring.
	BsUtil.TableClear(BsRules.ruleFunctionTemplates.Bag)
	for _, inventoryType in ipairs(BS_INVENTORY_TYPE_UI_ORDER) do
		local inventory = Bagshui.components[inventoryType]
		local sequentialBagSlotNum = 1
		for _, containerId in ipairs(inventory.containerIds) do
			local ruleFunctionCode = string.format("Bag(%s)", containerId)
			table.insert(
				BsRules.ruleFunctionTemplates.Bag,
				{
					-- Example: "Bank: Bag(10)"
					text = string.format("%s%s:%s %s", NORMAL_FONT_COLOR_CODE, inventory.inventoryTypeLocalized, FONT_COLOR_CODE_CLOSE, ruleFunctionCode),
					code = ruleFunctionCode,
					description = string.format(L.RuleFunction_Bag_ExampleDescription, containerId, sequentialBagSlotNum, inventory.inventoryTypeLocalized)
				}
			)
			sequentialBagSlotNum = sequentialBagSlotNum + 1
		end
	end
	-- Need to pick up the multi-bag example and add that too.
	if L_nil["RuleFunction_Bag_ExampleMulti"] then
		table.insert(
			BsRules.ruleFunctionTemplates.Bag,
			{
				code = L_nil["RuleFunction_Bag_ExampleMulti"],
				description = L_nil["RuleFunction_Bag_ExampleDescriptionMulti"],
			}
		)
	end



	-- Construct the Rule Function menu for the category editor.
	-- There's some dumb hackery going on here because I didn't feel like refactoring the auto-split menu code.


	--- Callback function for the Rule Function menu.
	--- arg1 and arg2 change depending on whether it's called from a normal menu item or an auto-split menu.
	--- ```none
	--- Normal:
	--- 	arg1 = editBox
	--- 	arg2 = code to insert
	--- Auto-split:
	--- 	arg1 = {
	--- 		templateList = list of templates where arg2 can be found
	--- 		editBox = editBox
	--- 	}
	--- 	arg2 = template Id
	--- ```
	---@param arg1 any See above.
	---@param arg2 any See above.
	local function insertRuleFunctionTemplate(arg1, arg2)
		local codeToInsert, editBox
		if arg1.templateList then
			-- Extra item hack.
			if type(arg2) == "table" and arg2.extra then
				codeToInsert = arg2.code
			else
				codeToInsert =  arg1.code or arg1.templateList[arg2].code
			end
			editBox = arg1.editBox
		else
			codeToInsert = arg2
			editBox = arg1
		end
		if type(editBox) ~= "table" or not codeToInsert then
			return
		end
		if not editBox.GetText then
			Bagshui:PrintError("Couldn't find edit box (this shouldn't happen!)")
			return
		end
		local editBoxContent = (editBox:GetText() or "")
		-- Separate functions with " or " unless there's already an and/or present.
		if string.len(editBoxContent) > 0 then
			if not (
				string.find(editBoxContent, "%s+or%s*$")
				or string.find(editBoxContent, "%s+and%s*$")
			) then
				editBoxContent = editBoxContent .. " or"
			end
			if not string.find(editBoxContent, "%s$") then
				editBoxContent = editBoxContent .. " "
			end
		end

		editBoxContent = editBoxContent .. codeToInsert
		editBox:SetText(editBoxContent)
	end


	--- Using the given list of Rule Function templates, create a menu table.
	--- This is broken out into a function because there used to be separate
	--- buttons for builtin and 3rd party rule functions. That was changed because
	--- it didn't seem like a necessary distinction. It wasn't worth removing this
	--- function though.
	---@param sortedRuleFunctionTemplateNames string[] Ordered array of rule function template names.
	---@param ruleFunctionTemplates table<string, table> List of `{ <function name> = { { template 1 }, { template N } }`.
	---@param ruleFunctionTemplateExtraEntries table<string, table>? List of `{ <function name> = { { template 1 }, { template N } }` that will be added to the bottom of the template menu.
	---@param ruleFunctionTemplateGenericDescriptions table<string, string> List of `{ <function name> = "Description"] }` Tooltip for the rule function's parent menu item.
	local function buildRuleFunctionMenu(ruleFunctionMenus, sortedRuleFunctionTemplateNames, ruleFunctionTemplates, ruleFunctionTemplateExtraEntries, ruleFunctionTemplateGenericDescriptions)
		BsUtil.TableClear(ruleFunctionMenus)
		local ruleFunctionMenu

		for _, functionName in ipairs(sortedRuleFunctionTemplateNames) do
			local templates = ruleFunctionTemplates[functionName]
			if templates then

				-- Whenever the menu gets filled up, roll over to a new one.
				if not ruleFunctionMenu or table.getn(ruleFunctionMenu) >= _G.UIDROPDOWNMENU_MAXBUTTONS then
					table.insert(ruleFunctionMenus, {})
					ruleFunctionMenu = ruleFunctionMenus[table.getn(ruleFunctionMenus)]
				end

				if table.getn(templates) == 1 then
					-- When there's only one template, no submenu is needed.
					table.insert(
						ruleFunctionMenu,
						{
							text = templates[1].text or templates[1].code,
							tooltipTitle = templates[1].tooltipTitle or templates[1].text or templates[1].code,
							tooltipText = templates[1].description,
							func = insertRuleFunctionTemplate,
							notCheckable = true,
							arg2 = templates[1].code,
						}
					)

				else
					-- Create a bespoke auto-split menu for each rule function's templates.
					-- With some auto-split menu refactoring this could be cleaner, but it's not a priority.

					-- Prepare the "extra" examples (usually multi-parameter) as extra menu items
					-- that will be added to the bottom of the menu. When there are enough templates
					-- to force the creation of multiple menus, these will appear at the bottom of each.
					local extraMenuItems = {}
					if type(ruleFunctionTemplateExtraEntries) == "table" and ruleFunctionTemplateExtraEntries[functionName] then
						for i, template in ipairs(ruleFunctionTemplateExtraEntries[functionName]) do
							table.insert(extraMenuItems, {
								text = template.text or template.code,
								tooltipTitle = template.tooltipTitle or template.text or template.code,
								tooltipText = template.description,
								notCheckable = true,
								value = {
									func = insertRuleFunctionTemplate,
									objectId = {
										editBox = nil,
									},
								},
								-- Stupid hack to get the data we need across to `insertRuleFunctionTemplate()`.
								arg2 = {
									extra = true,
									code = template.code
								},
							})
						end
					end
					-- Need the extra count so we know how much to limit the maximum
					-- entries per menu by.
					local extraMenuItemCount = table.getn(extraMenuItems)

					local templateNum = 0
					local listNum = 0
					-- We're going to keep looping until we've created enough menus
					-- to account for all the templates. This is usually only necessary
					-- for PeriodicTable when AtlasLoot is loaded.
					repeat

						-- Need to re-check the menu on every loop.
						if table.getn(ruleFunctionMenu) >= _G.UIDROPDOWNMENU_MAXBUTTONS then
							Bagshui:PrintError("Too many rule functions for editor menu")
							break
						end

						listNum = listNum + 1
						local autoSplitMenuType = "RuleFunction:" .. functionName .. listNum
						local templateList = templates  -- Upvalue for nameFunc.
						local ruleFunctionName = functionName  -- Upvalue for parentMenuNameTrimFunc.
						local autoSplitMenuIdList = {}

						-- Populate this menu up to the maximum number of entries we can fit.
						for i = 1, ((_G.UIDROPDOWNMENU_MAXBUTTONS - extraMenuItemCount) * _G.UIDROPDOWNMENU_MAXBUTTONS) do
							templateNum = templateNum + 1
							if not templates[templateNum] then
								break
							end
							table.insert(autoSplitMenuIdList, templateNum)
						end

						-- Auto-split submenu.
						Bagshui.prototypes.Menus:AddAutoSplitMenu(
							autoSplitMenuType,
							{
								defaultIdList = autoSplitMenuIdList,
								parentMenuNameTrimFunc = function(menuName)
									-- Remove FunctionName( from the beginning of the string.
									return string.gsub(menuName, ruleFunctionName .. "%([\"']", "")
								end,
								nameFunc = function(id)
									return templateList[id].text or templateList[id].code
								end,
								tooltipTitleFunc = function(id)
									return templateList[id].tooltipTitle or templateList[id].text or templateList[id].code
								end,
								tooltipTextFunc = function(id)
									return templateList[id].description
								end,
								extraItems = extraMenuItems,
							}
						)

						-- Parent menu item.
						table.insert(ruleFunctionMenu, {
							text = functionName .. "(...)",
							tooltipTitle = functionName .. "(...)",
							tooltipText = (ruleFunctionTemplateGenericDescriptions[functionName] or "") .. (templates.aliasTooltipAddendum or ""),
							hasArrow = true,
							notCheckable = true,
							value = {
								autoSplitMenuType = autoSplitMenuType,
								func = insertRuleFunctionTemplate,
								notCheckable = true,
								objectId = {
									templateList = templateList,
									editBox = nil,
								},
							}
						})

					until not templates[templateNum]

				end
			end
		end
	end


	-- Create the Rule Function menus.

	local ruleFunctionMenus = {}

	buildRuleFunctionMenu(
		ruleFunctionMenus,
		BsRules.sortedRuleFunctionTemplateNames,
		BsRules.ruleFunctionTemplates,
		BsRules.ruleFunctionTemplatesExtra,
		BsRules.ruleFunctionTemplateGenericDescriptions
	)

	for i, ruleFunctionMenu in ipairs(ruleFunctionMenus) do
		self.menus:AddMenu(
			"RuleFunctionTemplates" .. i,
			ruleFunctionMenu,
			nil, nil,
			-- The pre-open callback handles getting information across to the func callback.
			function(menu, editBox, _)
				for _, menuItem in pairs(menu.levels[1]) do
					if type(menuItem.value) == "table" then
						-- Auto-split menus pass arg1 via value.objectId.
						menuItem.value.objectId.editBox = editBox
					else
						-- Normal menus pass editBox through to func as the first argument.
						menuItem.arg1 = editBox
					end
				end
			end
		)
	end


	-- Custom object editor for Categories.
	local categoryEditor = {}

	-- Calls ObjectList:InitUi().
	self._super.InitUi(self,
		nil,  -- No custom Object Manager needed.
		categoryEditor,  -- This is our custom Object Editor.
		-- All the overrides.
		{
			-- Basic Object Manager settings.

			managerWidth = 475,
			managerHeight = 600,

			managerColumns = {
				{
					field = "name",
					title = L.ObjectManager_Column_Name,
					widthPercent = "65",
					currentSortOrder = "ASC",
					lastSortOrder = "ASC",
				},
				{
					field = "sequence",
					title = L.ObjectManager_Column_Sequence,
					align = "RIGHT",
					widthPercent = "10",
					lastSortOrder = "ASC",
				},
				{
					field = "builtin",
					title = L.ObjectManager_Column_Source,
					widthPercent = "16",
					lastSortOrder = "ASC",
				},
				{
					field = "inUse",
					title = L.ObjectManager_Column_InUse,
					widthPercent = "9",
					lastSortOrder = "ASC",
				},
			},


			-- Add error indicator to category name.
			managerColumnTextFunc = function(fieldName, categoryId, category, preliminaryDisplayValue)
				if fieldName == "name" and categories.errors[categoryId] then
					return preliminaryDisplayValue .. BS_FONT_COLOR.UI_ORANGE .. " <!>" .. FONT_COLOR_CODE_CLOSE
				end
				return preliminaryDisplayValue
			end,

			-- Category Manager Add button shows a menu instead of just creating a new category.
			managerAddButtonOnClick = function()
				self.menus:OpenMenu("NewCategory", _G.this, nil, _G.this, 0, 0, "TOPLEFT", "BOTTOMLEFT")
			end,


			-- Basic Object Editor settings.

			editorWidth  = 550,
			editorHeight = 550,

			-- Order of fields in editor UI.
			editorFields = {
				"name",
				"nameSort",
				"sequence",
				"rule",
				"list",
			},

			-- Configuration for editor fields.
			editorFieldProperties = {
				name = {
					required = true,
				},
				sequence = {
					required = true,
				},
				rule = {
					widgetType = "ScrollableEditBox",
					widgetHeight = 150,
					monospace = true,
				},
				list = {
					widgetType = "ItemList",
					widgetWidth = 260,
					widgetHeight = 250,
					multiSelect = true,
				},
			},


		}
	)



	---comment Override NewEditor so we can modify the interface.
	---@return table objectEditorInstance
	function self.objectManager:NewEditor()
		-- Create the ObjectEditor instance.
		local editor = self._super.NewEditor(self)
		local ui = editor.ui

		-- Assume it's not a class category.
		editor.isClassCategory = false

		-- Trigger rule validation when the EditBox loses focus
		editor.editBoxes.rule:SetScript("OnEditFocusLost", function()
			editor:UpdateState(true)
		end)

		-- Place the Rule Function template menu buttons under the Rule label, to the left of the code box.
		local nextAnchorToFrame = editor.labelWidgetPairs.rule.bagshuiData.labelFrame
		local nextButtonSpacing = -BsSkin.toolbarSpacing
		local i = 0
		local menuName
		repeat
			i = i + 1
			menuName = "RuleFunctionTemplates" .. i
			if
				categories.menus.menuList[menuName]
				and table.getn(categories.menus.menuList[menuName].levels[1]) > 0
			then
				local menuToOpen = menuName  -- Upvalue for onClick.
				editor.buttons["ruleFunction" .. i] = ui:CreateIconButton({
					name = editor.nameAndNumber .. "AddRuleFunction" .. i,
					parentFrame = editor.content,
					texture = i == 1 and "RuleFunction" or "Ellipsis",
					anchorPoint = "TOPRIGHT",
					anchorToFrame = nextAnchorToFrame,
					anchorToPoint = "BOTTOMRIGHT",
					xOffset = 0,
					yOffset = nextButtonSpacing,
					tooltipAnchor = "ANCHOR_PRESERVE",
					tooltipAnchorPoint = "TOPRIGHT",
					tooltipAnchorToPoint = "TOPLEFT",
					tooltipTitle = L.CategoryEditor_AddRuleFunction,

					onClick = function()
						categories.menus:OpenMenu(
							menuToOpen,  -- Menu name.
							editor.labelWidgetPairs.rule.bagshuiData.widget.bagshuiData.editBox,  -- callback arg1.
							nil,  -- callback arg2.
							_G.this,  -- anchorFrame.
							0, 0,  -- offsets.
							"TOPRIGHT", "BOTTOMLEFT"  -- anchor points.
						)
					end
				})
				nextAnchorToFrame = editor.buttons["ruleFunction" .. i]
				nextButtonSpacing = -BsSkin.toolbarTightSpacing
			end
		until not categories.menus.menuList[menuName]

		-- Help button goes below the Rule Function buttons.
		ui:CreateIconButton({
			name = editor.nameAndNumber .. "Help",
			parentFrame = editor.content,
			texture = "Question",
			anchorPoint = "TOPRIGHT",
			anchorToFrame = nextAnchorToFrame,
			anchorToPoint = "BOTTOMRIGHT",
			xOffset = 0,
			yOffset = -BsSkin.toolbarGroupSpacing,
			tooltipAnchor = "ANCHOR_PRESERVE",
			tooltipAnchorPoint = "TOPRIGHT",
			tooltipAnchorToPoint = "TOPLEFT",
			tooltipTitle = L["CategoryEditor_RuleFunctionWiki"],

			onClick = function()
				ui:ShowUrl(BS_WIKI_URL .. BS_WIKI_PAGES.Rules)
			end
		})


		-- Validation button / status indicator will be positioned at the bottom left of the code box.
		editor.buttons.ruleValidation = ui:CreateIconButton({
			name = editor.nameAndNumber .. "RuleValidation",
			parentFrame = editor.content,
			texture = "Compile",
			anchorPoint = "RIGHT",
			anchorToFrame = editor.labelWidgetPairs.rule.bagshuiData.label,
			anchorToPoint = "RIGHT",
			xOffset = 0,
			yOffset = 0,
			tooltipTitle = L.CategoryEditor_RuleValidation_Validate,
			tooltipAnchor = "ANCHOR_PRESERVE",
			tooltipAnchorPoint = "BOTTOMRIGHT",
			tooltipAnchorToPoint = "BOTTOMLEFT",
			tooltipXOffset = -5,
			tooltipYOffset = -6,
			noTooltipDelay = true,
			noTooltipTextDelay = true,

			onClick = function()
				if _G.arg1 == "LeftButton" then
					if editor.ruleInvalid then
						BsLogWindow:Open()
					else
						editor:UpdateState(true)
						_G.this:GetScript("OnEnter")()
					end
				elseif _G.arg1 == "RightButton" then
					BsLogWindow:Open()
				end
			end
		})
		editor.buttons.ruleValidation:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		editor.buttons.ruleValidation:Disable()
		-- Set the second anchor point for the rule validation button so that it ends up at the bottom left of the edit box
		editor.buttons.ruleValidation:SetPoint(
			"BOTTOM",
			editor.labelWidgetPairs.rule.bagshuiData.widget,
			"BOTTOM",
			0, BsSkin.toolbarTightSpacing
		)


		-- Character class selector for class categories (hidden by default).
		local classSelectorWidth = 85
		local classSelector = ui:CreateDropDownMenuButton(
			editor.nameAndNumber .. "ClassSelector",
			editor.content,
			classSelectorWidth,
			categories.menus,
			"Classes",
			editor  -- Pass through to the OpenMenu callback as arg2, which will pass through to func as arg2, which will call editor:SetClass().
		)
		editor.labelWidgetPairs.class = ui:CreateLabeledWidget(
			editor.content,  -- Parent.
			string.format(L.Symbol_Colon, L.CategoryEditor_Field_class),  -- Label text.
			editor.labelWidth,  -- This property is added by InitUi().
			classSelector,  -- Widget.
			classSelectorWidth,  -- Widget width.
			editor.manager.editorDimensions.widgetHeight,
			editor.labelWidgetPairs.sequence,  -- Anchor to frame.
			"BOTTOMLEFT"   -- Anchor to point.
		)
		editor.labelWidgetPairs.class:Hide()


		-- Store the editor frame height so it can be adjusted up and down based on whether it's a class category
		editor.uiFrame.bagshuiData.originalHeight = editor.uiFrame:GetHeight()


		return editor
	end


	--- Change the Editor interface based on whether it's a class category.
	function categoryEditor:UpdateUiForClassCategories()
		-- Only class categories have a classes property.
		self.isClassCategory = self.referenceObject.classes ~= nil

		local editorHeight = self.uiFrame.bagshuiData.originalHeight

		-- Show/hide the player class selector.
		if self.isClassCategory then
			self.labelWidgetPairs.class:Show()
			self.labelWidgetPairs.class.bagshuiData.widget:Show()  -- Widgets aren't parented to the holding frame so we need to show/hide them separately.
			self.labelWidgetPairs.rule:SetPoint("TOPLEFT", self.labelWidgetPairs.class, "BOTTOMLEFT", 0, -10)
			editorHeight = editorHeight + self.labelWidgetPairs.class:GetHeight() + 10

		else
			self.labelWidgetPairs.class:Hide()
			self.labelWidgetPairs.class.bagshuiData.widget:Hide()  -- Widgets aren't parented to the holding frame so we need to show/hide them separately.
			self.labelWidgetPairs.rule:SetPoint("TOPLEFT", self.labelWidgetPairs.sequence, "BOTTOMLEFT", 0, -10)
		end

		self.uiFrame:SetHeight(editorHeight)

	end


	--- For class categories, Update the editor field storage redirect table to point
	--- to the storage for the selected player class.
	---@param class string Player class 
	function categoryEditor:SetClass(class)
		if not self.isClassCategory or not class then
			return
		end

		if not self.updatedObject.classes[class] then
			self.updatedObject.classes[class] = {}
		end

		-- Redirect all changes to point to this player class storage.
		for _, field in ipairs(CLASS_CATEGORY_FIELDS) do
			self.fieldStorageRedirect[field] = self.updatedObject.classes[class]
			self:PopulateField(field, self.updatedObject.classes[class])
		end
	end



	--- Category-specific work for loading an object into the editor.
	---@param objectId string|number? See ObjectEditor:Load() definition.
	---@param duplicate boolean? See ObjectEditor:Load() definition.
	---@param template table? See ObjectEditor:Load() definition.
	---@param refresh boolean? See ObjectEditor:Load() definition.
	---@param onFirstSave function? See ObjectEditor:Load() definition.
	---@return string|number # See ObjectEditor:Load() definition.
	function categoryEditor:Load(objectId, duplicate, template, refresh, onFirstSave)
		-- When loading a new category, reset isClassCategory first because the loading
		-- process ends up calling UpdateState(), which needs to know whether it's actually a class category
		if not refresh then
			self.isClassCategory = false
		end

		local newObjectId = self._super.Load(self, objectId, duplicate, template, refresh, onFirstSave)


		local classDropDown = self.labelWidgetPairs.class.bagshuiData.widget

		if refresh then
			-- On refresh, need to update field redirects because tables can change on save
			self:SetClass(classDropDown.bagshuiData.selectedValue)

		else
			-- Do initial adjustments for standard/Class categories
			self:UpdateUiForClassCategories()

			-- Set the initially selected class to that of the current character
			if self.isClassCategory then
				dropDownMenuSetSelectedValue(classDropDown, Bagshui.currentCharacterInfo.class)
				self:SetClass(Bagshui.currentCharacterInfo.class)
			end
		end

		return newObjectId
	end



	--- Special handling is needed for the Category editor UI state because we
	--- have to keep track of whether the rule function code validates.
	---@param forceRuleValidation boolean Run the rule function code through validation even if it hasn't changed.
	function categoryEditor:UpdateState(forceRuleValidation)
		self._super.UpdateState(self)

		-- Set supplemental button state based whether the object is read-only.
		local buttonNum = 0
		for i = 1, 10 do
			local button = self.buttons["ruleFunction" .. i]
			if not button then
				break
			end
			button[(self.originalObject.readOnly and "Disable" or "Enable")](button)
		end

		local ruleEditBox = self.editBoxes.rule
		local ruleValidationButton = self.buttons.ruleValidation

		-- Prepare some defaults.
		local rule = BsUtil.Trim(ruleEditBox:GetText() or "")
		local ruleValidationButtonEnabled = string.len(rule) > 0  -- Rule can't be validated unless there's code.
		local ruleValidationButtonTexture = "Compile"
		local ruleValidationButtonColor = BS_COLOR.YELLOW
		local ruleValidationButtonTooltipTitle = L.CategoryEditor_RuleValidation_Validate
		local ruleValidationButtonTooltipText

		-- Rule validation button should only be enabled when there's rule text.
		ruleValidationButton[(ruleValidationButtonEnabled and "Enable" or "Disable")](ruleValidationButton)

		local ruleValid, errorMessage

		-- Determine whether the rule code is valid.
		if
			-- Automatically validate the rule if it's not being edited.
			(ruleValidationButtonEnabled and not ruleEditBox.bagshuiData.hasFocus)
			-- Also need to validate if the button was clicked.
			or forceRuleValidation
		then
			ruleValid, errorMessage = BsRules:Validate(rule)

		elseif
			ruleEditBox.bagshuiData.hasFocus
			and not self.dirtyFields.rule
		then
			-- Revert to last saved validation state if the rule hasn't been edited.
			ruleValid = not self.originalObject.ruleError
			errorMessage = self.originalObject.ruleError
		end

		-- Only change the validation icon if validation state is known.
		self.ruleInvalid = false
		if ruleValidationButtonEnabled and ruleValid ~= nil then
			if ruleValid then
				ruleValidationButtonTexture = "Check"
				ruleValidationButtonColor = BS_COLOR.UI_GREEN
				ruleValidationButtonTooltipTitle = L.CategoryEditor_RuleValidation_Valid
			else
				self.ruleInvalid = true
				ruleValidationButtonTexture = "Exclamation"
				ruleValidationButtonColor = BS_COLOR.UI_ORANGE
				ruleValidationButtonTooltipTitle = L.CategoryEditor_RuleValidation_Invalid
				ruleValidationButtonTooltipText = errorMessage
				Bagshui:Log(
					Categories:FormatErrorMessage(
						errorMessage,
						self.objectId,
						self.updatedObject.name
					),
					L.CategoryEditor,
					BS_LOG_MESSAGE_TYPE.ERROR
				)
			end
		end

		-- Update the validation button.
		self.ui:SetIconButtonTexture(ruleValidationButton, "Icons\\" .. ruleValidationButtonTexture, ruleValidationButtonColor)
		ruleValidationButton.bagshuiData.tooltipTitle = ruleValidationButtonTooltipTitle
		ruleValidationButton.bagshuiData.tooltipText = ruleValidationButtonTooltipText

	end


	--- Helper function for categoryEditor:IsDirty() to determine when a class
	--- category doesn't contain any player class-specific data.
	---@param classObject table Category object to check.
	---@return boolean isPlayerClassDataEmpty
	local function classCategoryObjectIsEmpty(classObject)
		-- A player class object being nil is the same thing as it existing and having empty rule and list properties.
		return
			(classObject == nil)
			or (
				string.len(classObject.rule or "") == 0
				and table.getn(classObject.list) == 0
			)
	end


	--- In addition to the normal dirty checks, class categories require additional checks.
	---@return boolean
	function categoryEditor:IsDirty()
		local dirty = self._super.IsDirty(self)

		-- Additional checks for class categories.
		if self.isClassCategory then

			for class, _ in pairs(BsGameInfo.characterClasses) do
				local originalClassObject = self.originalObject.classes and self.originalObject.classes[class]
				local updatedClassObject = self.updatedObject.classes[class]

				if originalClassObject or updatedClassObject then
					-- When something has changed, we need to know whether it's significant.
					if self:IsObjectDirty(originalClassObject, updatedClassObject) then
						-- Changes can only be meaningful if both the player class object
						-- for both original and updated objects isn't empty.
						if not (classCategoryObjectIsEmpty(originalClassObject) and classCategoryObjectIsEmpty(updatedClassObject)) then
							-- Do deep inspection of each class category field to see if there
							-- are real differences. This is basically the same thing that happens
							-- at the top level, but we need to only do the comparison if the other
							-- checks have been satisfied to avoid false positives.
							for _, fieldName in ipairs(CLASS_CATEGORY_FIELDS) do
								if self:IsObjectDirty(
									(originalClassObject and originalClassObject[fieldName] or nil),
									(updatedClassObject and updatedClassObject[fieldName] or nil)
								) then
									dirty = true
									self.dirtyFields[fieldName] = _G.GetTime()
								else
									self.dirtyFields[fieldName] = nil
								end
							end
						end
					end
				end
			end

		end

		return dirty
	end

end



end)