-- Bagshui Core: Events
-- Event registration, raising, queuing, and callbacks.
-- Raises: BAGSHUI_CORE_EVENT_FUNCTIONS_LOADED

Bagshui:LoadComponent(function()


--- Request to receive event notifications of the specified type. Supports both WoW and Bagshui events.
---@param event string Name of event (ADDON_LOADED, etc.).
---@param classObject table? Class that will consume the event (must have an `OnEvent()` function if `eventFunctionName` isn't specified).
---@param classEventFunctionName string? Class function to use instead of `OnEvent`.
function Bagshui:RegisterEvent(event, classObject, classEventFunctionName)
	assert(type(event) == "string", "Bagshui:RegisterEvent() - event is required and must be a string")

	-- The Bagshui class internally uses RegisterEvent, so bypass consumer registration when there isn't a classObject.
	if classObject then
		self:RegisterClassForEvents(classObject, classEventFunctionName)
		self.eventConsumers[classObject][event] = true
	end

	-- Don't try to register internal events with the game (doesn't seem to cause a problem but is also pointless).
	if string.find(event, "^BAGSHUI_") then
		return
	end

	-- This probably isn't a big deal, but let's avoid registering events multiple times.
	if not self.eventFrame.bagshuiData.registeredEvents[event] then
		self.eventFrame:RegisterEvent(event)
		self.eventFrame.bagshuiData.registeredEvents[event] = true
	end
end



--- Add a class to the `Bagshui.eventConsumers` table, populating the `_eventFunctionName` property.
---@param classObject table Class that will consume the event (must have an `OnEvent()` function if `eventFunctionName` isn't specified).
---@param eventFunctionName string? Class function to use instead of `OnEvent`.
function Bagshui:RegisterClassForEvents(classObject, eventFunctionName)
	-- Already registered.
	if self.eventConsumers[classObject] then
		return
	end

	eventFunctionName = eventFunctionName or "OnEvent"

	assert(classObject[eventFunctionName], "Bagshui:RegisterClassForEvents(): " .. tostring(eventFunctionName) .. " not found on classObject " .. tostring(classObject))

	self.eventConsumers[classObject] = {
		_eventFunctionName = eventFunctionName
	}
end



--- Stop receiving notifications for the specified event.
---@param event string Name of event (ADDON_LOADED, etc.).
---@param classObject table Class that consumes the event.
function Bagshui:UnregisterEvent(event, classObject)
	self.eventConsumers[classObject][event] = false
end



--- Add a custom event to the internal queue.
---@param event string|function Unique event identifier or function to call.
---@param delaySeconds number? Time after which the event should be triggered (next frame if not specified).
---@param noReset boolean? `true` if an already-queued event's delay should *not* be reset.
---@param arg1 any? First argument to pass when the event is raised.
---@param arg2 any? Second argument to pass when the event is raised.
---@param arg3 any? Third argument to pass when the event is raised.
---@param arg4 any? Fourth argument to pass when the event is raised.
---@return boolean queued Whether the event was queued.
function Bagshui:QueueEvent(event, delaySeconds, noReset, arg1, arg2, arg3, arg4)
	-- Add to queue if not currently queued or the delay should be reset.
	if not self.queuedEvents.events[event] or (self.queuedEvents.events[event] and not noReset) then
		self.queuedEvents.events[event] = _G.GetTime() + (delaySeconds or 0.00001)
		self.queuedEvents.arg1[event] = arg1
		self.queuedEvents.arg2[event] = arg2
		self.queuedEvents.arg3[event] = arg3
		self.queuedEvents.arg4[event] = arg4
		return true
	end
	return false
end



--- Call the given class function after a delay.
---@param classInstance table Class that owns the function.
---@param classFunction function Function to call.
---@param delaySeconds number? Parameter for `Bagshui:QueueEvent()`.
---@param noReset boolean? Parameter for `Bagshui:QueueEvent()`.
---@param arg1 any? Parameter for `Bagshui:QueueEvent()`.
---@param arg2 any? Parameter for `Bagshui:QueueEvent()`.
---@param arg3 any? Parameter for `Bagshui:QueueEvent()`.
---@param arg4 any? Parameter for `Bagshui:QueueEvent()`.
function Bagshui:QueueClassCallback(classInstance, classFunction, delaySeconds, noReset, arg1, arg2, arg3, arg4)
	-- Create a unique identifier for this event since it's not a predefined event string.
	local eventId = tostring(classInstance) .. ":" .. tostring(classFunction)
	if self:QueueEvent(eventId, delaySeconds, noReset, arg1, arg2, arg3, arg4) then
		-- When the event is successfully queued, store callback information so RaiseEvent()
		-- knows to handle this as a class callback, not a standard event.
		self.queuedEvents.class[eventId] = classInstance
		self.queuedEvents.classFunction[eventId] = classFunction
	end
end



--- Process the Bagshui event queue.
--- Declaring variables outside to make the Lua garbage collector happier since this is called from
--- OnUpdate() [per Blizzard comment in UIPanelTemplates.lua]. Can't really do anything about the
--- variables in the for loop though.
local processEventQueue_success, processEventQueue_errorMessage
function Bagshui:ProcessEventQueue()
	-- Loop through queued events and fire them if enough time has passed.
	for event, raiseAfter in pairs(self.queuedEvents.events) do
		if raiseAfter <= _G.GetTime() then

			-- Fire the event and capture the status
			-- We need to prevent RaiseEvent from erroring so we can remove the event from the queue, so we'll handle errors here
			processEventQueue_success, processEventQueue_errorMessage = self:RaiseEvent(
				event,
				true,
				self.queuedEvents.arg1[event],
				self.queuedEvents.arg2[event],
				self.queuedEvents.arg3[event],
				self.queuedEvents.arg4[event]
			)

			-- Only remove from queue if the delay hasn't changed (i.e. the event hasn't been re-queued)
			if raiseAfter == self.queuedEvents.events[event] then
				self.queuedEvents.events[event] = nil
				self.queuedEvents.arg1[event] = nil
				self.queuedEvents.arg2[event] = nil
				self.queuedEvents.arg3[event] = nil
				self.queuedEvents.arg4[event] = nil
				self.queuedEvents.class[event] = nil
				self.queuedEvents.classFunction[event] = nil
			end

			assert(processEventQueue_success, processEventQueue_errorMessage)
		end
	end
end



-- Declaring variables for RaiseEvent outside to make the Lua garbage collector happier
-- since this is called from OnUpdate() [per Blizzard comment in UIPanelTemplates.lua].
local raiseEvent_success, raiseEvent_errorMessage

--- There are several ways an event can be raised:
--- 1. Calling a class function (event was set up via `Bagshui:QueueClassCallback()`).
--- 2. Calling a potentially anonymous function (event was set up via `Bagshui:QueueEvent(<function>)`).
--- 3. Passing off to `Bagshui:OnEvent()`, which can then pass on to registered consumers (event was
---    registered via `Bagshui:RegisterEvent()` and may have been raised by WoW or a call to `Bagshui:RaiseEvent()`).
---@param event string|function Name of event (WoW or Bagshui).
---@param returnStatus boolean? If true, `returnValue` and `errorMessage` from the event call will be returned.
---@param arg1 any? First event argument, if any.
---@param arg2 any? Second event argument, if any.
---@param arg3 any? Third event argument, if any.
---@param arg4 any? Fourth event argument, if any.
---@return boolean? returnValue Value returned from the event call, if any, when `returnStatus` is true.
---@return string? errorMessage Error message returned from the event call, if any, when `returnStatus` is true.
function Bagshui:RaiseEvent(event, returnStatus, arg1, arg2, arg3, arg4)

	if self.queuedEvents.class[event] then
		assert(self.queuedEvents.classFunction[event], "Class does not have the provided function!")
		-- Call `<ClassInstance>:<Function>()` by calling `<ClassInstance>.<Function>(<ClassInstance>)`.
		raiseEvent_success, raiseEvent_errorMessage = pcall(
			self.queuedEvents.classFunction[event],
			self.queuedEvents.class[event],
			arg1,
			arg2,
			arg3
		)

	elseif type(event) == "function" then
		raiseEvent_success, raiseEvent_errorMessage = pcall(event, arg1, arg2, arg3, arg4)

	else
		raiseEvent_success, raiseEvent_errorMessage = pcall(self.OnEvent, self, event, arg1, arg2, arg3, arg4)

	end

	-- Error handling.
	if returnStatus then
		return raiseEvent_success, raiseEvent_errorMessage
	elseif not raiseEvent_success then
		assert(false, raiseEvent_errorMessage)
	end
end


end,
-- Event to raise. This will trigger Bagshui:Init().
"BAGSHUI_CORE_EVENT_FUNCTIONS_LOADED"
)