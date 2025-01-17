-- Bagshui Default Sort Orders
-- Exposes: Bagshui.config.SortOrders

Bagshui:AddComponent(function()

-- Array of tables that defines non-editable built-in sort orders.
-- Table properties can be anything in `BS_SORT_ORDER_SKELETON` (see Components\SortOrders.lua),
-- but each one *must* have a unique `id` property that will become its object ID.
---@type table<string, any>[]
Bagshui.config.SortOrders = {
	version = 1,

	defaults = {
		-- Initially selected default sort order.
		{
			id    = "Default",
			name  = L.SortOrder_Default,
			fields = {
				{ field = "emptySlot",                 direction = "desc", },
				{ field = "uncategorized",             direction = "asc",  },
				{ lookup = "Category", field = "name", direction = "asc",  },
				{ field = "type",                      direction = "asc",  },
				{ field = "subtype",                   direction = "asc",  },
				{ field = "quality",                   direction = "desc", },
				{ field = "name",                      direction = "asc",  },
				{ field = "count",                     direction = "desc", },
				{ field = "charges",                   direction = "desc", },
				{ field = "bagNum",                    direction = "asc",  },
				{ field = "slotNum",                   direction = "asc",  },
			},
		},

		-- Same as default, but with reversed name sorting.
		{
			id    = "NameRev",
			name  = L.SortOrder_Default_NameRev,
			fields = {
				{ field = "emptySlot",                 direction = "desc", },
				{ field = "uncategorized",             direction = "asc",  },
				{ lookup = "Category", field = "name", direction = "asc",  },
				{ field = "type",                      direction = "asc",  },
				{ field = "subtype",                   direction = "asc",  },
				{ field = "quality",                   direction = "desc", },
				{ field = "name",                      direction = "asc",  reverseWords = true, },
				{ field = "count",                     direction = "desc", },
				{ field = "charges",                   direction = "desc", },
				{ field = "bagNum",                    direction = "asc",  },
				{ field = "slotNum",                   direction = "asc",  },
			},
		},

		-- Same as Default, but with descending MinLevel.
		{
			id    = "MinLevel",
			name  = L.SortOrder_Default_MinLevel,
			fields = {
				{ field = "emptySlot",                 direction = "desc", },
				{ field = "uncategorized",             direction = "asc",  },
				{ lookup = "Category", field = "name", direction = "asc",  },
				{ field = "type",                      direction = "asc",  },
				{ field = "subtype",                   direction = "asc",  },
				{ field = "minLevel",                  direction = "desc", },
				{ field = "quality",                   direction = "desc", },
				{ field = "name",                      direction = "asc",  },
				{ field = "count",                     direction = "desc", },
				{ field = "charges",                   direction = "desc", },
				{ field = "bagNum",                    direction = "desc",  },
				{ field = "slotNum",                   direction = "desc",  },
			},
		},

		-- Same as DefaultNameRev but with descending MinLevel.
		{
			id    = "MinLevelNameRev",
			name  = L.SortOrder_Default_MinLevelNameRev,
			fields = {
				{ field = "emptySlot",                 direction = "desc", },
				{ field = "uncategorized",             direction = "asc",  },
				{ lookup = "Category", field = "name", direction = "asc",  },
				{ field = "type",                      direction = "asc",  },
				{ field = "subtype",                   direction = "asc",  },
				{ field = "minLevel",                  direction = "desc", },
				{ field = "quality",                   direction = "desc", },
				{ field = "name",                      direction = "asc",  reverseWords = true, },
				{ field = "count",                     direction = "desc", },
				{ field = "charges",                   direction = "desc", },
				{ field = "bagNum",                    direction = "desc",  },
				{ field = "slotNum",                   direction = "desc",  },
			},
		},

		-- Provide a manual option.
		{
			id    = "Manual",
			name  = L.SortOrder_Manual,
			fields = {
				{ field = "bagNum",    direction = "desc",  },
				{ field = "slotNum",   direction = "desc",  },
			},
		},
	},


	-- Currently no need for migration.
	migrate = nil,
}


end)