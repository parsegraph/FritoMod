if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_OOP/OOP-Class";
    
    require "FritoMod_Collections/Lists";
    require "FritoMod_Collections/Tables";
end;

-- EventRegistry automatically manages the lifecycle of events and their registered listeners.
EventRegistry = OOP.Class();
local EventRegistry = EventRegistry;

function EventRegistry:Constructor()
    self.driver = Metatables.Multicast();
    self.registry = {};
    Metatables.ConstructedValue(self.registry, Tables.New);
end;

function EventRegistry:AddDriver(driver, ...)
    return self.driver:Add(driver, ...);
end;

-- Registers the specified listener to receive events with the specified event name.
--
-- eventName:string
--     the name of the event for which the listener will expect events
-- listenerFunc, ...:function
--     receives events for the specified event 
-- returns:one-time function
--     a function that removes the specified listener
function EventRegistry:AddListener(eventName, listenerFunc, ...)
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
function EventRegistry:Dispatch(eventName, ...)
    local listeners = self.registry[eventName];
    Lists.CallEach(listeners, ...);
end;
