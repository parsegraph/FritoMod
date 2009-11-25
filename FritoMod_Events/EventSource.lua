if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_OOP/OOP-Class";
    
    require "FritoMod_Collections/Lists";
    require "FritoMod_Collections/Tables";
end;

-- EventSource automatically manages the lifecycle of events and their registered listeners.
EventSource = OOP.Class();
local EventSource = EventSource;

function EventSource:Constructor()
    self.registry = {};
    Metatables.ConstructedValue(self.registry, Tables.New);
end;

-- Registers the specified listener to receive events with the specified event name.
--
-- eventName:string
--     the name of the event for which the listener will expect events
-- listenerFunc, ...:function
--     receives events for the specified event 
-- returns:one-time function
--     a function that removes the specified listener
function EventSource:AddListener(eventName, listenerFunc, ...)
    assert(type(eventName) == "string", "eventName must be a string");
    listenerFunc = Curry(listenerFunc, ...);
    local listeners = self.registry[eventName];
    return Lists.Insert(listeners, listenerFunc);
end;

-- Dispatches an event to all listeners that are expecting that event.
--
-- eventName:string
--     the name of the dispatched event
-- ...:*
--     event parameters
function EventSource:Dispatch(eventName, ...)
    local listeners = self.registry[eventName];
    Lists.CallEach(listeners, ...);
end;
