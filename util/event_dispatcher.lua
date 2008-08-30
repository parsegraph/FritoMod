EventDispatcher = AceLibrary("AceOO-2.0").Mixin{"TriggerEvent", "AddListener"};
local EventDispatcher = EventDispatcher;

-------------------------------------------------------------------------------
--
--  Listener Methods
--
-------------------------------------------------------------------------------

function EventDispatcher:TriggerEvent(eventName, ...)
    if not self.events then
        return;
    end;
    local eventList = self.events[eventName];
    if not eventList then
        return;
    end;
    for listener in eventList:Iter() do
        listener(eventName, ...);
    end;
end;

function EventDispatcher:AddListener(eventName, listenerFunc, listenerSelf, ...)
	if not self.events then
		self.events = {};
	end;
    local listener = ObjFunc(listenerFunc, listenerSelf, ...);
    if type(eventName) == "table" then
        -- We're using the same listener for multiple events, so recurse and collect.
        removers = {}
        local eventList = eventName
        for i, eventName in ipairs(eventList) do
            table.insert(removers, self:AddListener(eventName, listener))
        end
        return function()
            for i, remover in ipairs(removers) do
                remover()
            end
        end;
    end;
    local eventList = self.events[eventName];
    if not eventList then
        eventList = List:new();
        self.events[eventName] = eventList;
    end;
    eventList:Add(listener);
    return function()
        eventList:Remove(listener);
    end;
end;
