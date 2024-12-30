-- Bagshui Skins Configuration
-- Exposes: Bagshui.config.Skins

Bagshui:LoadComponent(function()

local Ui = Bagshui.prototypes.Ui

Bagshui.config.Skins = {
	activeSkin = "Bagshui",

	Bagshui = {

		---@type table { number: r, number: g, number: b, number: a }: Window frame background color.
		frameBackgroundColor = { 0.1, 0.1, 0.1, 0.99 },
		---@type table { number: r, number: g, number: b, number: a }: Window frame border color.
		frameBorderColor = nil,

		-- When these have values, an additional item will appear in settings menus for colors
		-- to allow the selection of the skin's default colors.
		---@type table { number: r, number: g, number: b, number: a }
		skinBackgroundColor = nil,
		---@type table { number: r, number: g, number: b, number: a }
		skinBorderColor = nil,

		---@type string Frame default backdrop texture.
		frameDefaultBackdrop = "Interface\\BUTTONS\\WHITE8X8",
		---@type string|table Frame/window default border style. Can either be a key from BS_BORDER (string) or a table in the same format as the values of BS_BORDER. See `Ui:SetFrameBackdrop()` for defaults if nil.
		frameDefaultBorderStyle = nil,
		---@type number Frame/window edgeSize override for SetFrameBackdrop table.
		frameEdgeSize = nil,
		---@type number Frame/window insets override for SetFrameBackdrop table.
		frameBorderInsets = nil,

		---@type number Window padding.
		windowPadding = 10,
		---@type number Title bar height.
		windowTitleBarHeight = 20,
		---@type number Heder/footer height.
		windowHeaderFooterHeight = 22,
		---@type number Header/footer will be shifted up/down by this much relative to window padding.
		windowHeaderFooterYAdjustment = 4,
		---@type function Accepts a window frame as the only parameter and styles it.
		windowSkinFunc = nil,

		---@type number Space between toolbar buttons.
		toolbarSpacing = 8,
		---@type number Space between toolbar buttons that should be close together.
		toolbarTightSpacing = 2,
		---@type number Space between toolbar groups.
		toolbarGroupSpacing = 14,
		---@type number Space between toolbar and Close button.
		toolbarCloseButtonOffset = 11,

		---@type function Accepts that accepts a tooltip as the only parameter and styles it.
		tooltipSkinFunc = nil,
		---@type number Additional offset required by tooltip skinning to account for borders.
		tooltipExtraOffset = 0,

		---@type number When a submenu needs to be manually moved to the left, shift it by this X amount.
		menuShiftLeft = 7,
		---@type number For normal (right-positioned) submenus, shift it by this X amount.
		menuShiftRight = 0,
		---@type number When a submenu is already on the left, shift it by this X amount.
		menuShiftLeftFix = 3,

		---@type number Close button Height and width.
		closeButtonSize = 18,
		---@type number Close button X coordinate shift.
		closeButtonXOffsetAdjustment = 2,
		---@type number Close button X coordinate shift.
		closeButtonYOffsetAdjustment = 0,
		---@type number Close button hit rect inset adjustment.
		closeButtonHitRectInsets = 0,
		---@type function Function that accepts a close button or menu item table as the only parameter and styles it.
		closeButtonSkinFunc = function(buttonOrMenuItem)
			if buttonOrMenuItem.GetScript then
				-- Button.
				buttonOrMenuItem:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
				buttonOrMenuItem:GetNormalTexture():SetTexCoord(0.2, 0.75, 0.25, 0.75)
				buttonOrMenuItem:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
				buttonOrMenuItem:GetPushedTexture():SetTexCoord(0.2, 0.75, 0.25, 0.75)
				buttonOrMenuItem:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
				buttonOrMenuItem:GetHighlightTexture():SetBlendMode("ADD")
				buttonOrMenuItem:GetHighlightTexture():SetTexCoord(0.2, 0.75, 0.25, 0.75)
			else
				-- Menu item.
				buttonOrMenuItem.icon = "Interface\\Buttons\\UI-Panel-MinimizeButton-Up"
				buttonOrMenuItem.tCoordLeft = 0.2
				buttonOrMenuItem.tCoordRight = 0.75
				buttonOrMenuItem.tCoordTop = 0.25
				buttonOrMenuItem.tCoordBottom = 0.75
				buttonOrMenuItem._bagshuiTextureR = 1
				buttonOrMenuItem._bagshuiTextureG = 1
				buttonOrMenuItem._bagshuiTextureB = 1
			end
		end,
		---@type number Close button X coordinate shift for inventory windows only.
		closeButtonInventoryWindowXOffsetAdjustment = 0,

		---@type number Minimum inventory window width.
		inventoryWindowMinWidth = 400,
		---@type number Inventory window padding.
		inventoryWindowPadding = 6,
		---@type number Header/footer will be shifted up/down by this much relative to window padding.
		inventoryHeaderFooterYAdjustment = 2,
		---@type number Minimum height of the header/footer (footer height will increase when bag bar is visible). 
		inventoryHeaderFooterHeight = 22,
		---@type number Relative scale of docked inventory windows.
		inventoryDockedScale = 0.8,
		---@type number Outer margin for Edit Mode.
		inventoryEditModeMargin = 3,

		---@type table { left, right, top, bottom }: Item slot IconTexture SetTexCoord parameters.
		itemSlotIconTexCoord = nil,
		---@type number Item slot IconTexture anchor (positive = outset / negative = inset).
		itemSlotIconAnchor = nil,
		---@type table { left, right, top, bottom }: Item slot background SetTexCoord parameters.
		itemSlotBackgroundTexCoord = nil,
		---@type number Item slot size/scale fudge factor, which will make slots smaller if positive and larger if negative, relative to settings.itemSlotSize.
		itemSlotSizeFudge = 0,
		---@type number Item slot margin fudge factor, applied to settings.itemSlotMargin.
		itemSlotMarginFudge = 2,

		---@type number Item slot texture and bag bar opacity when offline.
		itemSlotTextureOfflineOpacity = 0.5,
		---@type number Item slot texture opacity in Edit Mode.
		itemSlotTextureEditModeOpacity = 0.5,
		---@type number Item slot texture opacity for items that don't match search terms or haven't changed in "highlight changes" mode.
		itemSlotTextureDimmedOpacity = 0.25,

		---@type string Item slot edgeFile override for SetFrameBackdrop table.
		itemSlotBorderTexture = "Interface\\Tooltips\\UI-Tooltip-Border",
		---@type number Item slot edgeSize override for SetFrameBackdrop table.
		itemSlotEdgeSize = 16,
		---@type number Item slot border insets override for SetFrameBackdrop table.
		itemSlotInset = 0,
		---@type number Item slot border anchor (positive = outset / negative = inset).
		itemSlotBorderAnchor = 3,
		---@type boolean If true, when scaling the item slot, inverse scale will be applied to the border (useful for keeping pixel borders the same width).
		itemSlotBorderInverseScale = false,
		---@type boolean If true, always display the item slot border, even when it's not of a special quality.
		itemSlotBorderAlwaysShow = false,
		---@type table { r = [number], r = [number], r = [number], a = [number] }: Default color for item slot border when no quality color is applied.
		itemSlotBorderDefaultColor = { r = 1, g = 1, b = 1, a = 1 },
		---@type number Item slot border default opacity.
		itemSlotBorderOpacity = 1,
		---@type number Item slot inner opacity for container mouseover highlight.
		itemSlotBorderContainerHighlightOpacity = 1,

		---@type string Replacement texture for item slot HighlightTexture.
		itemSlotHighlightTexture = nil,
		---@type number Item slot HighlightTexture anchor (positive = outset / negative = inset).
		itemSlotHighlightAnchor = nil,

		---@type string Replacement texture for item slot PushedTexture.
		itemSlotPushedTexture = nil,
		---@type number Item slot PushedTexture anchor (positive = outset / negative = inset).
		itemSlotPushedAnchor = nil,

		---@type string Texture for item slot inner glow.
		itemSlotInnerGlowTexture = "Interface\\Buttons\\UI-ActionButton-Border",
		---@type number Item slot inner glow anchor (positive = outset / negative = inset).
		itemSlotInnerGlowAnchor = 14,
		---@type number Item slot inner glow default opacity.
		itemSlotInnerGlowOpacity = 0.4,
		---@type number Item slot inner glow opacity for container mouseover highlight.
		itemSlotInnerGlowContainerHighlightOpacity = 0.5,

		---@type string Replacement texture for item slot NormalTexture.
		itemSlotNormalTexture = nil,

		---@type string Replacement texture for item slot CheckedTexture.
		itemSlotCheckedTexture = nil,

		---@type number Item slot "decoration" anchor (badges and count/stock text).
		itemSlotDecorationAnchor = 2,

		---@type string Item slot font override.
		itemSlotFont = nil,
		---@type number Item slot font size override.
		itemSlotFontSize = nil,
		---@type string Item slot font style override (default is OUTLINE).
		itemSlotFontStyle = nil,
		---@type number Group padding fudge factor, applied to settings.groupPadding.
		groupPaddingFudge = 2,
		---@type number Group margin fudge factor, applied to settings.groupMargin.
		groupMarginFudge = -4,

		---@type number Vertical padding for group labels.
		groupLabelMinPadding = 1,
		---@type number Padding above each group's label.
		groupLabelYPadding = 0,
		---@type number X offset between group and group label.
		groupLabelXOffset = 2,
		---@type number Y offset between group and group label.
		groupLabelYOffset = -2,
		---@type number Group label will have its width adjusted by this much relative to the group's width. 
		groupLabelRelativeWidth = -4,
		---@type number X offset between group and group label in Edit Mode.
		groupLabelEditModeXOffset = 7,
		---@type number Y offset between group and group label in Edit Mode.
		groupLabelEditModeYOffset = -5,

		---@type number Group move target X offset relative to the neighboring groups.
		groupMoveTargetAnchorOffset = 1,
		---@type number Width for vertical group move targets, height for horizontal.
		groupMoveTargetThinDimension = 3,
		---@type number Shrink the group move target relative to the neighboring groups' width/height by this much.
		groupMoveTargetLongDimensionSubtraction = 10,

		---@type number Space between bag bar buttons.
		bagBarSpacing = 7,
		---@type number Scale of bag bar buttons relative to item slot buttons.
		bagBarScale = 0.75,
		---@type number Opacity of NormalTexture when the container highlight is locked.
		bagBarButtonNormalTextureHighlightLockedOpacity = 0.8,

		---@type number Vertical offset when attaching the Bagshui info tooltip to the GameTooltip.
		infoTooltipYOffset = 4,

		---@type number Horizontal scroll bar padding.
		scrollBarXPadding = 2,
		---@type number Space around scroll bar buttons.
		scrollBarButtonMargin = 2,
		---@type table { number: r, number: g, number: b, number: a }: Background color for scroll bars.
		scrollBarBackgroundColor = { 0.1, 0.1, 0.1, 0.25 },

		---@type table { number: r, number: g, number: b, number: a }: Background color for edit boxes.
		editBoxBackgroundColor = { 0, 0, 0, 0.25 },
		---@type table { number: r, number: g, number: b, number: a }: Border color for edit boxes.
		editBoxBorderColor = { 0.5, 0.5, 0.5, 0.5 },

		---@type function? Function to use for skinning buttons.
		buttonSkinFunc = nil,
		---@type function? Function to use for skinning checkboxes ("CheckButtons" in Blizzard parlance).
		checkboxSkinFunc = nil,
		---@type function? Function to use for skinning dropdowns.
		dropdownSkinFunc = nil,
		---@type function? Function to use for skinning scrollbars.
		scrollbarSkinFunc = nil,
	},
}


-- The pfUI skin as currently implemented isn't a 1:1 match for pfUI's style due to
-- some FrameLevel issues that occur when using the pfUI CreateBackdrop() function
-- on Inventory windows (item slot badges display above the backdrops of other frames).
-- This is probably fixable but not high enough priority to address immediately.
-- So instead of calling CreateBackdrop(), we're directly adding the frame border
-- and coloring it appropriately.
if (pfUI and pfUI.api and pfUI.env and pfUI.env.C) then

	pfUI:RegisterSkin("Bagshui", "vanilla", function ()
		-- Nothing needs to happen here since we're literally just registering to
		-- get into the pfUI Config screen (Components > Skins > Bagshui).
		-- Skinning is handled as elements are created instead of retroactively.
	end)

	if pfUI.env.C.disabled and pfUI.env.C.disabled.skin_Bagshui ~= "1" then

		local pfUiAdditionalSettings
		local defaultSkin = Bagshui.config.Skins.Bagshui
		local _, defaultBorderSize = pfUI.api.GetBorderSize("default")
		local _, panelBorderSize = pfUI.api.GetBorderSize("panels")
		local _, bagBorderSize = pfUI.api.GetBorderSize("bags")

		-- Base pfUI skin settings.
		local pfUISkin = {

			frameBackgroundColor = { pfUI.api.GetStringColor(pfUI.env.C.appearance.border.background) },
			frameBorderColor = { pfUI.api.GetStringColor(pfUI.env.C.appearance.border.color) },

			skinBackgroundColor = { pfUI.api.GetStringColor(pfUI.env.C.appearance.border.background) },
			skinBorderColor = { pfUI.api.GetStringColor(pfUI.env.C.appearance.border.color) },

			frameDefaultBorderStyle = {
				edgeFile = pfUI.backdrop_blizz_border.edgeFile,
				edgeSize = pfUI.backdrop_blizz_border.edgeSize,
				insets = pfUI.backdrop_blizz_border.insets[1],
			},

			windowSkinFunc = pfUI.api.CreateBackdropShadow,

			tooltipSkinFunc = function(tooltip)
				pfUI.api.CreateBackdrop(tooltip, nil, nil, tonumber(pfUI.env.C.tooltip.alpha))
				pfUI.api.CreateBackdropShadow(tooltip)
			end,
			tooltipExtraOffset = panelBorderSize * 2,

			closeButtonSize = 12,
			closeButtonHitRectInsets = -2,
			closeButtonXOffsetAdjustment = -defaultBorderSize,
			closeButtonSkinFunc = function(buttonOrMenuItem)
				if buttonOrMenuItem.GetScript then
					-- Avoiding the use of SkinCloseButton because it does weird things to borders.
					pfUI.api.CreateBackdrop(buttonOrMenuItem)
					buttonOrMenuItem:SetHeight(10)
					buttonOrMenuItem:SetWidth(10)
					buttonOrMenuItem.texture = buttonOrMenuItem:CreateTexture("pfQuestionDialogCloseTex")
					buttonOrMenuItem.texture:SetTexture(pfUI.media["img:close"])
					buttonOrMenuItem.texture:ClearAllPoints()
					buttonOrMenuItem.texture:SetAllPoints(buttonOrMenuItem)
					buttonOrMenuItem.texture:SetVertexColor(1, 0.25, 0.25, 1)
					buttonOrMenuItem:SetScript("OnEnter", function()
						_G.this.backdrop:SetBackdropBorderColor(1, 0.25, 0.25, 1)
					end)
					buttonOrMenuItem:SetScript("OnLeave", function()
						pfUI.api.CreateBackdrop(_G.this)
					end)
				else
					-- Menu item.
					buttonOrMenuItem.icon = pfUI.media["img:close"]
					buttonOrMenuItem.tCoordLeft = -0.25
					buttonOrMenuItem.tCoordRight = 1.25
					buttonOrMenuItem.tCoordTop = -0.25
					buttonOrMenuItem.tCoordBottom = 1.25
					buttonOrMenuItem._bagshuiTextureR = 1
					buttonOrMenuItem._bagshuiTextureG = 0.25
					buttonOrMenuItem._bagshuiTextureB = 0.25
				end
			end,

			itemSlotFont = pfUI.font_unit,
			itemSlotFontSize = pfUI.env.C.global.font_unit_size,

			buttonSkinFunc = pfUI.api.SkinButton,

			-- checkboxSkinFunc = function(checkbox)
			-- 	pfUI.api.SkinCheckbox(checkbox)
			-- end,

			dropdownSkinFunc = function(dropDown)
				pfUI.api.SkinDropDown(dropDown)
				-- Bagshui alters the appearance of UIDropDownMenuTemplate so we need to override some pfUI assumptions.
				dropDown.backdrop:SetPoint("TOPLEFT", 0, 0)
				dropDown.backdrop:SetPoint("BOTTOMRIGHT", 0, 0)
				_G[dropDown:GetName() .. "Button"]:SetPoint("RIGHT", dropDown.backdrop, "RIGHT", 0, 0)
			end,

			scrollbarSkinFunc = function(scrollbar)
				pfUI.api.SkinScrollbar(scrollbar)
				-- Make the pfUI custom scroll thumb appear and disappear like the Blizzard one.
				local thumbTexture = _G[scrollbar:GetName().."ThumbTexture"]
				local oldOnUpdate = scrollbar:GetScript("OnUpdate")
				local lastUpdate = _G.GetTime()
				scrollbar:SetScript("OnUpdate", function()
					if oldOnUpdate then
						oldOnUpdate()
					end
					if _G.GetTime() - lastUpdate > 0.025 then
						if thumbTexture:IsShown() then
							scrollbar.thumb:Show()
						else
							scrollbar.thumb:Hide()
						end
						lastUpdate = _G.GetTime()
					end
				end)
			end,
		}

		-- pfUI's method of skinning checkboxes is to create a new backdrop frame
		-- that in most cases does a great job of staying behind the check texture.
		-- However, it seems that placing a checkbox as a child of a button breaks
		-- this (like in Bagshui's scrollable lists), and the check mark will
		-- render behind the backdrop. After a lot of messing around, I realized
		-- I could work around this by swapping the parentage of the checkbox and
		-- the backdrop, so that's what we're doing here.
		pfUISkin.checkboxSkinFunc = function(checkbox)
			local checkboxParent = checkbox:GetParent()
			local left, right, top, bottom = checkbox:GetHitRectInsets()

			pfUI.api.SkinCheckbox(checkbox)

			if checkbox.backdrop then
				checkbox:SetParent(_G.UIParent)
				checkbox.backdrop:SetParent(checkboxParent)
				checkbox:SetParent(checkbox.backdrop)
				-- pfUI messes with HitRectInsets so we need to restore them.
				checkbox:SetHitRectInsets(left - BsSkin.frameEdgeSize, right - BsSkin.frameEdgeSize, top - BsSkin.frameEdgeSize, bottom - BsSkin.frameEdgeSize)
			end

			-- It kind of sucks not having the hover highlight so we're going to restore it.
			checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
			checkbox:GetHighlightTexture():ClearAllPoints()
			-- Need to resize so it's square.
			checkbox:GetHighlightTexture():SetPoint("TOPLEFT", checkbox, "TOPLEFT", 0, 2)
			checkbox:GetHighlightTexture():SetPoint("BOTTOMRIGHT", checkbox, "BOTTOMRIGHT", 1, -3)
		end

		-- pfUI uses the same colors for widgets as the main frames.
		pfUISkin.editBoxBackgroundColor = pfUISkin.frameBackgroundColor
		pfUISkin.editBoxBorderColor = pfUISkin.frameBorderColor

		-- Use pfUI style square borders unless Blizzard borders are enabled in pfUI Config.
		if pfUI.env.C.appearance.border.force_blizz ~= "1" then

			local borderWidth = pfUI.pixel or 1

			pfUiAdditionalSettings = {
				frameEdgeSize = borderWidth,
				frameBorderInsets = -borderWidth,

				frameDefaultBorderStyle = "SOLID",

				closeButtonSize = 10,

				inventoryEditModeMargin = 0,

				-- Hide baked-in item and background borders.
				itemSlotIconTexCoord = { .08, .92, .08, .92 },
				itemSlotIconAnchor = 1,
				itemSlotBackgroundTexCoord = { .13, .87, .13, .87 },
				itemSlotSizeFudge = borderWidth * 2 + bagBorderSize,
				itemSlotMarginFudge = bagBorderSize * 2,

				itemSlotBorderTexture = "Interface\\BUTTONS\\WHITE8X8",
				itemSlotEdgeSize = borderWidth,
				itemSlotInset = 0,
				itemSlotBorderAnchor = bagBorderSize,
				itemSlotBorderInverseScale = true,
				itemSlotBorderAlwaysShow = true,
				itemSlotBorderDefaultColor = { r = 0.4, g = 0.4, b = 0.4, a = 0.5 },

				itemSlotHighlightTexture = "ItemSlot\\Flat-Highlight",
				itemSlotHighlightAnchor = 2,

				itemSlotPushedTexture = "ItemSlot\\Flat-Pushed",
				itemSlotPushedAnchor = 2,

				itemSlotInnerGlowTexture = "ItemSlot\\Flat-InnerGlow",
				itemSlotInnerGlowAnchor = defaultSkin.itemSlotInnerGlowAnchor + bagBorderSize + 4,

				itemSlotNormalTexture = "",  -- Intentionally an empty string so NormalTexture is removed.

				itemSlotCheckedTexture = "ItemSlot\\Flat-Checked",

				itemSlotDecorationAnchor = defaultSkin.itemSlotDecorationAnchor - bagBorderSize,

				groupSpacingInitialYOffset = -borderWidth,

				groupPaddingFudge = -(bagBorderSize + borderWidth),
				groupMarginFudge = -borderWidth,

				groupLabelYPadding = defaultSkin.groupLabelYPadding + borderWidth * 2,
				groupLabelXOffset = 0,
				groupLabelYOffset = 0,
				groupLabelWidthReduction = 0,
				groupLabelEditModeXOffset = defaultSkin.itemSlotDecorationAnchor + borderWidth,
				groupLabelEditModeYOffset = -(defaultSkin.itemSlotDecorationAnchor + borderWidth),

				groupMoveTargetAnchorOffset = -2,
				groupMoveTargetThinDimension = 10,
				groupMoveTargetLongDimensionSubtraction = 4,

				bagBarSpacing = 11,

				menuShiftLeftFix = 0,
				menuShiftLeft = 11 + defaultBorderSize,
				menuShiftRight = defaultBorderSize,

				infoTooltipYOffset = -(pfUISkin.tooltipExtraOffset + 1),
			}

		end

		-- Merge additional settings.
		if pfUiAdditionalSettings then
			for key, value in pairs(pfUiAdditionalSettings) do
				pfUISkin[key] = value
			end
		end

		Bagshui.config.Skins.pfUI = pfUISkin
		Bagshui.config.Skins.activeSkin = "pfUI"
	end
end


end)