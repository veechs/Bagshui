-- Bagshui UI Class: Window Frames

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui


--- Create a frame to be used as the basis of a window.  
--- Adding a title will automatically create a title bar with close button.
---@param name string Unique name for the window (will be passed to `Ui:CreateElementName()`).
---@param parent table? Parent frame (default: `UIParent`).
---@param height number? Default: 500.
---@param width number? Default: 500.
---@param title string? Text to display in the title bar.
---@param noCloseOnEscape boolean? Don't set this frame to be closed when the escape key is pressed.
---@return table window
function Ui:CreateWindowFrame(name, parent, height, width, title, noCloseOnEscape)
	local frameParent = parent or _G.UIParent

	local frame = _G.CreateFrame(
		"Frame",
		self:CreateElementName(name),
		frameParent
	)
	frame.bagshuiData = {
		isWindow = true,  -- Used in a couple of places to differentiate "window" frames from all other types.
	}

	-- Set required properties.
	frame:SetToplevel(true)  -- The frame won't come to the front when clicked without this.
	frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
	frame:SetWidth((height or 500))
    frame:SetHeight((width or 500))

	-- Make draggable.
	frame:SetScript("OnDragStart", function()
		if frame:IsMovable() then
			frame:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
	end)

	-- Open/Close events.
	frame:SetScript("OnShow", function()
		Bagshui:RaiseEvent("BAGSHUI_WINDOW_OPENED", false, frame)
	end)
	frame:SetScript("OnHide", function()
		Bagshui:RaiseEvent("BAGSHUI_WINDOW_CLOSED", false, frame)
	end)

	-- Set default style and color.
	self:SetFrameBackdrop(frame)
	frame:SetBackdropColor(
		BsSkin.frameBackgroundColor[1],
		BsSkin.frameBackgroundColor[2],
		BsSkin.frameBackgroundColor[3],
		BsSkin.frameBackgroundColor[4] or 1
	)
	if BsSkin.frameBorderColor then
		frame:SetBackdropBorderColor(
			BsSkin.frameBorderColor[1],
			BsSkin.frameBorderColor[2],
			BsSkin.frameBorderColor[3],
			BsSkin.frameBorderColor[4] or 1
		)
	end

	-- Add title bar and close button.
	if title then
		frame.bagshuiData.header, frame.bagshuiData.title, frame.bagshuiData.closeButton = self:CreateTitleBar(frame, title)
	end

	-- Shouldn't be visible by default.
	frame:Hide()

	-- Close when escape is pressed.
	if not noCloseOnEscape then
		Bagshui:RegisterFrameForCloseOnEscape(frame)
	end

	return frame
end



--- Create a frame whose only contents are a full-size scrollable edit box.
--- Always generates a title bar.
---@param name string Parameter for `Ui:CreateWindowFrame()`.
---@param parent table? Parameter for `Ui:CreateWindowFrame()`.
---@param height number? Parameter for `Ui:CreateWindowFrame()`.
---@param width number? Parameter for `Ui:CreateWindowFrame()`.
---@param title string? Parameter for `Ui:CreateWindowFrame()` (default: `Edit Window`).
---@param noCloseOnEscape boolean? Parameter for `Ui:CreateWindowFrame()`.
---@param fontObject string|table? Parameter for `Ui:CreateEditBox()`.
---@param selectAllOnFocus boolean? Parameter for `Ui:CreateEditBox()`.
---@return table window
---@return table scrollFrame
---@return table editBox
function Ui:CreateScrollableEditBoxWindow(name, parent, height, width, title, noCloseOnEscape, fontObject, selectAllOnFocus)

	local frame = self:CreateWindowFrame(name, parent, height, width, title, noCloseOnEscape)

	local scrollFrame, editBox = self:CreateScrollableEditBox(
		"EditScroll",
		frame,
		nil,  -- borderStyle
		nil,  -- editBoxInherits
		fontObject,
		selectAllOnFocus)
	if frame.bagshuiData.header then
		self:SetPoint(scrollFrame, "TOPLEFT", frame.bagshuiData.header, "BOTTOMLEFT", 0, -2)
	else
		self:SetPoint(scrollFrame, "TOPLEFT", frame, "TOPLEFT", BsSkin.windowPadding, -BsSkin.windowPadding)
	end
	self:SetPoint(scrollFrame, "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -BsSkin.windowPadding, BsSkin.windowPadding)
	-- Manually setting width so that the EditBox can be properly sized.
	self:SetWidth(scrollFrame, frame:GetWidth() - (BsSkin.windowPadding * 2))

	frame.bagshuiData.scrollFrame = scrollFrame
	frame.bagshuiData.editBox = editBox

	return frame, scrollFrame, editBox
end



--- Add a title bar (header frame, window title, and close button) to a window frame.
---@param windowFrame table Frame created by `Ui:CreateWindowFrame()`.
---@param windowTitleText string Parameter for `Ui:CreateWindowTitle()`. 
---@param closeFunction function? `clickFunction` parameter for `Ui:CreateWindowTitle()`.
---@return table header Frame
---@return table title FontString
---@return table closeButton Button
function Ui:CreateTitleBar(windowFrame, windowTitleText, closeFunction)

	local header = self:CreateHeaderFooter(
		"Header",
		windowFrame,
		"TOP",
		BsSkin.windowTitleBarHeight
	)

	local title = self:CreateWindowTitle(
		"Title",
		header,
		windowTitleText,
		"LEFT",
		0, 0
	)

	local closeButton = self:CreateCloseButton(
		"CloseButton",
		header,
		"RIGHT",
		0, 0,
		closeFunction
	)

	return header, title, closeButton
end



--- Create a header or footer frame for a window.
--- By default will create a header anchored to the top, but if `anchorTopBottom == "BOTTOM"` a footer will be created.
---@param name string Unique name for the element (will be passed to `Ui:CreateElementName()`).
---@param windowFrame table Parent frame.
---@param anchorTopBottom string? `"TOP"` (header) or `"BOTTOM"` (footer).
---@param height number? Defaults to `BsSkin.windowHeaderFooterHeight`.
---@param xOffset number? See code for default.
---@param yOffset number? See code for default.
---@return table headerOrFooter
function Ui:CreateHeaderFooter(name, windowFrame, anchorTopBottom, height, xOffset, yOffset)

	-- Figure out positioning.
	anchorTopBottom = (anchorTopBottom == "BOTTOM") and "BOTTOM" or "TOP"
	local invertY = (anchorTopBottom == "TOP") and -1 or 1
	xOffset = xOffset or BsSkin.windowPadding
	yOffset = yOffset or ((BsSkin.windowPadding - BsSkin.windowHeaderFooterYAdjustment) * invertY)

	-- Create header/footer.

	local headerFooter = _G.CreateFrame(
		"Frame",
		self:CreateElementName(name),
		windowFrame
	)
	headerFooter:SetHeight(height or BsSkin.windowHeaderFooterHeight)

	-- Set position.
	headerFooter:SetPoint(
		anchorTopBottom .."LEFT",
		windowFrame,
		xOffset,
		yOffset
	)
	headerFooter:SetPoint(
		anchorTopBottom .. "RIGHT",
		windowFrame,
		-xOffset,
		yOffset
	)

	return headerFooter
end



--- Add a window title to the given window frame.
---@param name string Unique name for the element (will be passed to `Ui:CreateElementName()`).
---@param windowFrame table Parent frame.
---@param text string Title text.
---@param anchor string? Default: `TOPLEFT`.
---@param xOffset number? Default: `BsSkin.windowPadding`.
---@param yOffset number? Default: `-BsSkin.windowPadding`.
---@return table titleText FontString
function Ui:CreateWindowTitle(name, windowFrame, text, anchor, xOffset, yOffset)
	local titleText = self:CreateShadowedFontString(windowFrame, self:CreateElementName(name), "GameFontNormal")
	titleText:SetPoint(
		anchor or "TOPLEFT",
		windowFrame,
		xOffset or BsSkin.windowPadding,
		yOffset or -(BsSkin.windowPadding)
	)
	titleText:SetJustifyH("LEFT")
	titleText:SetJustifyV("TOP")
	titleText:SetText(text)
	return titleText
end



--- Add a close button to the given window frame.
---@param name string Unique name for the element (will be passed to `Ui:CreateElementName()`).
---@param windowFrame table Parent frame.
---@param anchor string? Default: `TOPRIGHT`.
---@param xOffset number? Default: `BsSkin.windowPadding`. Always is adjusted by `BsSkin.closeButtonXOffsetAdjustment`.
---@param yOffset number? Default: `-BsSkin.windowPadding`. Always is adjusted by `BsSkin.closeButtonYOffsetAdjustment`.
---@param clickFunction function|boolean? OnClick event handler. If not provided, one will be created automatically. Pass `false` to not add a click handler at all.
---@return table closeButton Button.
function Ui:CreateCloseButton(name, windowFrame, anchor, xOffset, yOffset, clickFunction)

	local closeButton = _G.CreateFrame(
		"Button",
		self:CreateElementName(name),
		windowFrame
	)
	closeButton.bagshuiData = {}

	-- Add textures, set size and position.
	BsSkin.closeButtonSkinFunc(closeButton)
	closeButton:SetWidth(BsSkin.closeButtonSize)
	closeButton:SetHeight(BsSkin.closeButtonSize)
	closeButton:SetPoint(
		anchor or "TOPRIGHT",
		(xOffset or -BsSkin.windowPadding) + BsSkin.closeButtonXOffsetAdjustment,
		(yOffset or -BsSkin.windowPadding) + BsSkin.closeButtonYOffsetAdjustment
	)
	closeButton:SetHitRectInsets(BsSkin.closeButtonHitRectInsets, BsSkin.closeButtonHitRectInsets, BsSkin.closeButtonHitRectInsets, BsSkin.closeButtonHitRectInsets)


	-- Add close function.
	if clickFunction ~= false then

		-- When an explicit function isn't passed, we need to create the close function.
		if type(clickFunction) ~= "function" then
			clickFunction = nil
			local parentWindow = self:FindWindowFrame(windowFrame)

			if parentWindow then
				-- We found a window frame, so create the function to hide it.
				clickFunction = function()
					Bagshui:CloseMenus()
					parentWindow:Hide()
				end
			else
				Bagshui:PrintWarning("UI WARNING: No parent frame found for close button '" .. tostring(name) .. "' (child of frame " .. tostring(windowFrame:GetName()) .. ") -- frame may not be closable!")
			end
		end

		if clickFunction then
			closeButton:SetScript("OnClick", clickFunction)
		end
	end

	return closeButton
end



--- Obscure and disable the contents of a window frame so a modal dialog can be displayed on top.
---@param window table Bagshui window frame.
---@param shadeOn boolean Whether to show or hide the shade.
---@param text string? Text to display in the middle of the shade.
function Ui:SetWindowShade(window, shadeOn, text)
	if not window.bagshuiData and window.bagshuiData.isWindow then
		return
	end

	if shadeOn then
		if not window.bagshuiData.shadeFrame then
			window.bagshuiData.shadeFrame = _G.CreateFrame("Frame", nil, window)

			local inset =
				(type(BsSkin.frameDefaultBorderStyle) == "table" and BsSkin.frameDefaultBorderStyle.insets)
				or BsSkin.frameBorderInsets
				or BS_BORDER.CURVED.insets
			window.bagshuiData.shadeFrame:SetPoint("TOPLEFT", window, "TOPLEFT", inset, -inset)
			window.bagshuiData.shadeFrame:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -inset, inset)

			self:SetFrameBackdrop(window.bagshuiData.shadeFrame, BsSkin.frameDefaultBorderStyle)
			window.bagshuiData.shadeFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.65)
			window.bagshuiData.shadeFrame:SetBackdropBorderColor(0, 0, 0, 0.1)

			window.bagshuiData.shadeFrameText = self:CreateShadowedFontString(window.bagshuiData.shadeFrame)
			window.bagshuiData.shadeFrameText:SetPoint("CENTER", window.bagshuiData.shadeFrame)
			window.bagshuiData.shadeFrameText:SetJustifyH("CENTER")

			-- Need to keep the window's dragability.
			window.bagshuiData.shadeFrame:EnableMouse(true)
			window.bagshuiData.shadeFrame:RegisterForDrag("LeftButton")
			self:PassMouseEventsThrough(window.bagshuiData.shadeFrame, window)
		end

		if text then
			window.bagshuiData.shadeFrameText:SetText(tostring(text))
			window.bagshuiData.shadeFrameText:Show()
		else
			window.bagshuiData.shadeFrameText:Hide()
		end

		window.bagshuiData.shadeFrame:SetFrameLevel(window:GetFrameLevel() + 10)
		window.bagshuiData.shadeFrame:Show()

	else
		if window.bagshuiData.shadeFrame then
			window.bagshuiData.shadeFrame:Hide()
		end
	end

end


end)