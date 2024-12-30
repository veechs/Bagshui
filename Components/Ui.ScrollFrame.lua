-- Bagshui UI Class: ScrollFrames

Bagshui:AddComponent(function()

local Ui = Bagshui.prototypes.Ui


--- Create a scroll frame to hold another element
--- Note:
--- - The ScrollFrame must be sized and placed using `Ui:SetWidth()` and `Ui:SetPoint()`.
--- - If `<ScrollFrame>.bagshuiData.scrollChild` exists, the ScrollChild's width will
---   automatically be updated when the owning ScrollFrame's changes.
---   `Ui:CreateScrollableContent()` takes care of this, but when `Ui:CreateScrollFrame()`
---   is called directly,  the `bagshuiData.scrollChild` property should be set manually.
---@param name string Unique name for the frame (will be passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param borderStyle table|string `borderStyle` parameter for `Ui:SetFrameBackdrop()`.
---@return table scrollFrame
function Ui:CreateScrollFrame(name, parent, borderStyle)
	assert(name, "Ui:CreateScrolLFrame(): name is required to create a ScrollFrame")

	-- Create the scroll frame.

	local scrollFrameName = self:CreateElementName(name)

	local scrollFrame = _G.CreateFrame(
		"ScrollFrame",
		scrollFrameName,
		parent,
		"UIPanelScrollFrameTemplate"
	)


	-- Make scroll bar adjustments.

	local scrollBar = _G[scrollFrameName .. "ScrollBar"]
	local scrollUpButton = _G[scrollFrameName .. "ScrollBarScrollUpButton"]
	local scrollBarOffset = scrollBar:GetWidth() + BsSkin.scrollBarXPadding
	local scrollButtonOffset = scrollUpButton:GetHeight() + BsSkin.scrollBarButtonMargin

	-- Move the scrollbar just outside the ScrollFrame and give it a background.
	scrollBar:ClearAllPoints()
	scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", BsSkin.scrollBarXPadding, -scrollButtonOffset)
	scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", BsSkin.scrollBarXPadding, scrollButtonOffset)
	local scrollBarBackground = _G.CreateFrame("Frame", nil, scrollFrame)
	self:SetFrameBackdrop(scrollBarBackground, "NONE")  -- White background, no borders.
	scrollBarBackground:SetBackdropColor(
		BsSkin.scrollBarBackgroundColor[1],
		BsSkin.scrollBarBackgroundColor[2],
		BsSkin.scrollBarBackgroundColor[3],
		BsSkin.scrollBarBackgroundColor[4]
	)
	scrollBarBackground:SetPoint("TOPLEFT", scrollBar, 0, scrollButtonOffset - BsSkin.scrollBarButtonMargin)
	scrollBarBackground:SetPoint("BOTTOMRIGHT", scrollBar, 0, -(scrollButtonOffset - BsSkin.scrollBarButtonMargin))

	-- Disappear the thumb when no scrolling is allowed.
	scrollBar.bagshuiData = {
		scrollDownButton = _G[scrollFrameName .. "ScrollBarScrollDownButton"],
		scrollUpButton = scrollUpButton,
		thumbTexture = _G[scrollFrameName .. "ScrollBarThumbTexture"],
	}
	local lastUpdate = _G.GetTime()
	scrollBar:SetScript("OnUpdate", function()
		if _G.GetTime() - lastUpdate > 0.025 then
			-- Bagshui:PrintDebug(scrollBar.bagshuiData.scrollDownButton:IsEnabled())
			-- Bagshui:PrintDebug(scrollBar.bagshuiData.scrollUpButton:IsEnabled())
			if
				scrollBar.bagshuiData.scrollDownButton:IsEnabled() == 1
				or scrollBar.bagshuiData.scrollUpButton:IsEnabled() == 1
			then
				-- Bagshui:PrintDebug("need to show")
				scrollBar.bagshuiData.thumbTexture:Show()
			else
				-- Bagshui:PrintDebug("need to hide")
				scrollBar.bagshuiData.thumbTexture:Hide()
			end
			lastUpdate = _G.GetTime()
		end
	end)


	-- Create background.
	-- It has to be separate from the ScrollFrame so that content doesn't appear to scroll over the borders.

	local background = _G.CreateFrame("Frame", nil, parent)
	background.bagshuiData = {
		noSkin = true
	}
	self:SetFrameBackdropAndBorderForEditWidgets(background, borderStyle)
	local backdropEdgeInsets = background:GetBackdrop()["insets"]
	background:SetPoint(
		"TOPLEFT",
		scrollFrame,
		"TOPLEFT",
		-math.abs(backdropEdgeInsets.left),
		math.abs(backdropEdgeInsets.top)
	)
	background:SetPoint(
		"BOTTOMRIGHT",
		scrollFrame,
		"BOTTOMRIGHT",
		(math.abs(backdropEdgeInsets.right) + scrollBarOffset + BsSkin.scrollBarXPadding),
		-math.abs(backdropEdgeInsets.bottom)
	)

	if type(BsSkin.scrollbarSkinFunc) == "function" then
		BsSkin.scrollbarSkinFunc(scrollBar)
	end

	-- Ensure ScrollChild width is kept in sync.
	scrollFrame:SetScript("OnSizeChanged", function()
		self:SetScrollChildWidth(_G.this)
	end)
	scrollFrame:SetScript("OnShow", function()
		self:SetScrollChildWidth(_G.this)
	end)

	-- Allow clicking the ScrollFrame to close menus and de-focus fields.
	scrollFrame:EnableMouse(true)
	scrollFrame:SetScript("OnMouseDown", function()
		self:CloseMenusAndClearFocuses()
	end)

	-- Store elements on frame for later use.
	scrollFrame.bagshuiData = {
		background = background,
		headerHeight = 0,
		scrollBar = scrollBar,
		scrollBarBackground = scrollBarBackground,
		scrollBarWidth = scrollBarOffset + BsSkin.scrollBarXPadding,
	}

	return scrollFrame
end



--- Create a ScrollFrame and scrollable content area.
---  
--- The `contentFrame` (3rd return value) is where the elements you want to make scrollable should go.
--- 
--- Just like `Ui:CreateScrollFrame()`:
--- - The ScrollFrame should be sized and placed using Ui:SetWidth() and Ui:SetPoint()
--- - The ScrollChild's width will be matched to the ScrollFrame's automatically.
--- **Important:** Set height on the ScrollChild, NOT the ContentFrame.
---  
--- Heavily based on https://www.wowinterface.com/forums/showpost.php?p=274216
---@param namePrefix string Unique name prefix for the elements (will be suffixed for each and passed to `Ui:CreateElementName()`).
---@param parent table Parent frame.
---@param contentFrameInherits string `inherits` parameter to use when calling `CreateFrame()` for the contentFrame`.
---@param borderStyle table|string `borderStyle` parameter for `Ui:CreateScrollFrame()`.
---@return table scrollFrame
---@return table scrollChild
---@return table contentFrame
function Ui:CreateScrollableContent(namePrefix, parent, contentFrameInherits, borderStyle)

	-- Create the ScrollFrame  and ScrollChild elements.

	local scrollFrame = self:CreateScrollFrame(namePrefix .. "ScrollFrame", parent, borderStyle)
	local scrollChild = _G.CreateFrame("Frame", namePrefix .. "ScrollChild", scrollFrame)  -- This MUST be parented to the scrollFrame or elements created inside it won't be interactive.

	-- Set the scrollChild as the ScrollFrame's scrollChild.
	-- IT IS IMPORTANT TO ENSURE THAT YOU SET THE SCROLLCHILD'S SIZE AFTER REGISTERING IT AS A SCROLLCHILD.
	-- Width is handled by the OnShow and OnSizeChanged handlers of the ScrollFrame.
	-- Height must be done manually.
	scrollFrame:SetScrollChild(scrollChild)

	-- Automatically update the ScrollFrame's ScrollChildRect when the ScrollChild's size changes.
	scrollChild:SetScript("OnSizeChanged", function()
		scrollFrame:UpdateScrollChildRect()
	end)

	-- Clicking ScrollChild should clean up the state of UI objects.
	scrollChild:EnableMouse(true)
	scrollChild:SetScript("OnMouseDown", function()
		self:CloseMenusAndClearFocuses()
	end)

	-- "Content" is the frame which will actually be seen within the ScrollFrame
	-- where all content will be parented to. It is parented to the scrollChild
	-- and automatically resizes with it.
	-- (Original note: "I like to think of scrollChild as a sort of 'pin-board' that you can 'pin' a piece of paper to (or take it back off)")
	local contentFrame = _G.CreateFrame("Frame", nil, scrollChild, contentFrameInherits)
	contentFrame:SetAllPoints(scrollChild)

	-- Clicking ContentFrame should clean up the state of UI objects
	contentFrame:EnableMouse(true)
	contentFrame:SetScript("OnMouseDown", function()
		self:CloseMenusAndClearFocuses()
	end)

	-- Update Bagshui info tables to have cross-references to everything for ease of access.
	-- `Ui:CreateScrollFrame()` already adds a bagshuiData table, so just add the properties.
	scrollFrame.bagshuiData.scrollChild = scrollChild  -- Allow Ui:SetScrollChildWidth() to work automatically.
	scrollFrame.bagshuiData.content = contentFrame
	scrollChild.bagshuiData = {
		scrollFrame = scrollFrame,
		content = contentFrame,
	}
	contentFrame.bagshuiData = {
		scrollFrame = scrollFrame,
		scrollChild = scrollChild,
	}

	return scrollFrame, scrollChild, contentFrame
end



-- Automatically set the ScrollChild width to match the ScrollFrame.
---@param scrollFrame table Return value from `CreateScrolLFrame()`.
---@param scrollChild table? WoW frame that is being scrolled by `scrollFrame`. Will attempt to use the `scrollFrame`'s `bagshuiData.scrollChild` property if not provided.
function Ui:SetScrollChildWidth(scrollFrame, scrollChild)
	scrollFrame = scrollFrame or _G.this
	-- Grab the Bagshui ScrollChild if one wasn't provided.
	scrollChild = scrollChild or (scrollFrame.bagshuiData and scrollFrame.bagshuiData.scrollChild)
	if not scrollChild then
		return
	end
	scrollChild:SetWidth(scrollFrame:GetWidth())
end


end)