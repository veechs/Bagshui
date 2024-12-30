-- Bagshui Active Quest Item Manager
-- Exposes: Bagshui.components.ActiveQuestItemManager
-- Raises: BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE
--
-- Contains code based on QuestItem: https://github.com/wow-vanilla-addons/QuestItem/blob/master/QuestItem/QuestItem.lua
--
-- Keeps Bagshui.activeQuestItems updated with the NAMES of items which are objectives of current quests.
-- (We can't get item IDs due to Vanilla limitations).
--
-- Raises BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE when changes to Bagshui.activeQuestItems occur.
--
-- This works by receiving QUEST_LOG_UPDATE events, which tend to come in fast and furious. To avoid constantly
-- rebuilding the list of active quest items, we're using an event queue:
-- 1. QUEST_LOG_UPDATE event comes in and BAGSHUI_QUEST_LOG_UPDATE event is queued to fire 1 second later.
--    If another QUEST_LOG_UPDATE event arrives before that 1 second is up, the timer is reset.
-- 2. BAGSHUI_QUEST_LOG_UPDATE event fires and triggers the actual parsing of the quest log.
--    After that is complete, BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE event is fired immediately.
-- 3. Other components that have registered to received BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE are now notified
--    and can trigger recategorization and resorting.

Bagshui:AddComponent(function()


-- Key in _G.BagshuiData where active quest items will be stored.
local ACTIVE_QUEST_ITEMS_DATA_STORAGE_KEY = "activeQuestItems"


-- Initialization (happens when this component is loaded during `ADDON_LOADED`)
if not Bagshui.currentCharacterData[ACTIVE_QUEST_ITEMS_DATA_STORAGE_KEY] then
	Bagshui.currentCharacterData[ACTIVE_QUEST_ITEMS_DATA_STORAGE_KEY] = {}
end


local ActiveQuestItemManager = {

	-- List of active quest items by item name.
	--
	-- Items must be stored in SavedVariables to to prevent inventory items from
	-- jumping around during UI reload, because there is a delay before the quest
	-- log can be read. The list is when QUEST_LOG_UPDATE fires for the first time.
	-- ```
	-- {
	-- 	["Item Name"] = {
	-- 		questName = "Quest Name",
	-- 		needed = #,
	-- 		obtained = #,
	-- 	}
	-- }
	-- 
	-- ```
	---@type table<string, { questName: string, needed: number, obtained: number }>
	items = Bagshui.currentCharacterData[ACTIVE_QUEST_ITEMS_DATA_STORAGE_KEY],
}



--- Event handling.
---@param event string Event name.
---@param arg1 any Event argument.
function ActiveQuestItemManager:OnEvent(event, arg1)

	-- WoW says "Something has happened with the quest log!" (it says this a lot).
	-- Queue an event so that we only do our update after all the events have finished firing
	-- This will be the most common event received, by far, so it goes first.
	if event == "QUEST_LOG_UPDATE" then
		Bagshui:QueueEvent("BAGSHUI_QUEST_LOG_UPDATE", 1)
		return
	end

	-- Enough time has elapsed since the last QUEST_LOG_UPDATE event to actually do our update.
	if event == "BAGSHUI_QUEST_LOG_UPDATE" then
		self:Update()
		Bagshui:RaiseEvent("BAGSHUI_ACTIVE_QUEST_ITEM_UPDATE")
		return
	end

end



--- Parse the quest log to find the names of items that are quest objectives.
function ActiveQuestItemManager:Update()

	-- In theory we could keep a list of the items we've actually seen and remove the ones
	-- we don't see, but erasing its is easier. (Can always change if it causes problems).
	BsUtil.TableClear(self.items)

	local questName, isHeader, objectiveText, itemType, itemName, numNeeded, numObtained

	for questNum = 1, _G.GetNumQuestLogEntries(), 1 do

		-- Only need a couple pieces of information from GetQuestLogTitle.
		questName, _, _, isHeader, _, _ = _G.GetQuestLogTitle(questNum)

		if not isHeader then

			itemName = nil
			numNeeded = 1
			numObtained = 0

			-- All subsequent function calls depend on selecting the quest log entry.
			_G.SelectQuestLogEntry(questNum)

			-- If description and quest objective text is ever needed, here's how to get it:
			-- local questionDescription, questObjectiveText = _G.GetQuestLogQuestText()

			-- Quest objectives are in the "Leader Boards".
			for i = 1, _G.GetNumQuestLeaderBoards() do

				objectiveText, itemType = _G.GetQuestLogLeaderBoard(i)

				-- We only care if type is item/object (not monster, event, etc.).
				if itemType ~= nil and (itemType == "item" or itemType == "object")  then

					-- Parse and store the item information from the objective text, which is formatted as:
					-- `<Item Name>: <Number Obtained>/<Total Needed>`
					_, _, itemName, numObtained, numNeeded = string.find(objectiveText, "(.+): (%d+)/(%d+)")
					self.items[itemName] = {
						questName = questName,
						needed = numNeeded,
						obtained = numObtained,
					}
				end
			end
		end
	end
end



-- Exports and registration.
Bagshui.components.ActiveQuestItemManager = ActiveQuestItemManager
Bagshui.activeQuestItems = ActiveQuestItemManager.items
Bagshui:RegisterEvent("QUEST_LOG_UPDATE", ActiveQuestItemManager)  -- Quest log changes.
Bagshui:RegisterEvent("BAGSHUI_QUEST_LOG_UPDATE", ActiveQuestItemManager)  -- Our custom trigger to parse the quest log.


end)