-- Bagshui UI Class
-- Exposes:
-- - Bagshui.prototypes.Ui
-- - Bagshui.components.UiTooltips (and BsUiTooltips) - this is just a shortcut to the Ui._tooltips property.

-- To extend this class, create an instance via :New() and add extra functions.
-- Behavior of some UI components will change based on whether :SetInventoryClass(classInstance) is called.

Bagshui:LoadComponent(function()


Bagshui:AddConstants({

	-- Item slot buttons and bag buttons share a lot of code, but there are enough
	-- differences that they need to be tagged.
	-- KEY = "VALUE"
	BS_UI_ITEM_BUTTON_TYPE = {
		ITEM = "ITEM",
		BAG = "BAG",
	},

	-- Different kinds of scrollable lists.
	-- KEY = "value"
	---@enum BS_UI_SCROLLABLE_LIST_TYPE
	BS_UI_SCROLLABLE_LIST_TYPE = {
		TEXT = "text",
		ITEM = "item",
		CUSTOM = "custom",
	},

	-- Buttons that can be created and associated with a scrollable list.
	-- Actual button configuration is in `Ui:CreateScrollableList()` due to localization.
	-- KEY = "value"
	BS_UI_SCROLLABLE_LIST_BUTTON_NAME = {
		ADD = "add",
		DELETE = "delete",
		DOWN = "down",
		DUPLICATE = "duplicate",
		EDIT = "edit",
		IMPORT = "import",
		NEW = "new",
		REMOVE = "remove",
		REPLACE = "replace",
		SHARE = "copy",
		UP = "up",
	},

	-- List of button textures for easy looping when changes need to be made to all of them.
	BS_UI_BUTTON_TEXTURES = {
		"Normal",
		"Highlight",
		"Pushed",
		"Disabled",
	},

})



local Ui = {
	-- Reference to the owning Inventory class instance, added during :New().
	inventory = nil,

	-- "Private" object storage (obviously not really private, just prefixed so
	-- that other classes can store whatever they want under their Ui instances
	-- with impunity).
	_reusableListFrames = {},  -- See Ui:GetAvailableScrollableListEntryFrame() (Ui.ScrollableList.lua).
	_tooltips = {},  -- Initialized in Ui:InitTooltips() (Ui.Tooltips.lua).
}
Bagshui.prototypes.Ui = Ui
Bagshui.components.UiTooltips = Ui._tooltips
Bagshui.environment.BsUiTooltips = Ui._tooltips



--- Create a new instance of the Ui class.
---@param inventoryClassOrNamePrefix string|table? Either the inventory class instance creating this Ui class instance, or the name prefix that should be used when creating elements.
---@param owningClass table? When `inventoryClassOrNamePrefix` is a string, this should be the class that is creating the Ui class instance.
---@return table uiClassInstance
function Ui:New(inventoryClassOrNamePrefix, owningClass)

	-- Prepare new class object
	local ui = {
		_super = Ui,
	}

	-- Determine whether to store an inventory class reference or name prefix.
	if type(inventoryClassOrNamePrefix) == "table" and inventoryClassOrNamePrefix.inventoryType then
		ui.inventory = inventoryClassOrNamePrefix
		ui.owningClass = inventoryClassOrNamePrefix
	elseif type(inventoryClassOrNamePrefix) == "string" then
		ui.namePrefix = inventoryClassOrNamePrefix
		ui.owningClass = owningClass
	end

	-- Set up the class object.
	setmetatable(ui, self)
	self.__index = self

	return ui
end


end)