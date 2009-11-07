-- Events is a registry of event listeners.
--
-- Events.EVENT_NAME(Mediums.Say, "Event!");
--
-- This prints out a message for up to five spell misses:
--
-- local count = 0;
-- local remover;
-- remover = Events["UNIT_SPELLMISS"](function(unitId, reason)
--     count = count + 1;
--     Mediums.Say(("%s missed. Reason: %s"):format(reason, UnitName(unitId)));
--     if count > 5 then 
--         remover();
--     end;
-- end);
--
-- The event listener passed will be called every time that event is emitted. A function is returned
-- that immediately removes the listener. You may pass additional arguments if you want a function or
-- method to be curried.
--
-- Only event arguments are passed to event listeners; the original frame reference and the event
-- name are stripped. The arguments are not changed or enhanced in any way.
--
-- Frame-specific and graphical events are not supported, so events like OnUpdate and mouse clicks are 
-- not emitted. Use Timing for update events.
--
-- The event registry is designed to be as lazy as possible, so please remove listeners when you're finished
-- listening with them so unused events can be cleaned up.

if nil ~= require then
    -- This file requires WoW-specific functionality.

    require "FritoMod_Functional/basic";

    require "FritoMod_Collections/Lists";
end;


Events = {};
local Events = Events;
local eventListeners;

-- Called to create the frame and register a listener to it. This is invoked every time the very first
-- event is registered. The removing function is called once all listeners have been removed.
local initialize = Activator(Noop, function()
    local eventsFrame = CreateFrame("Frame");
    eventListeners = {};
    -- Invoked on all registered events, calling all listeners for the event. Only event 
    -- arguments are passed; event names and the frame are omitted.
    eventsFrame:SetScript("OnEvent", function(frame, event, ...)
        local listeners = eventListeners[event];
        if listeners then
            Lists.CallEach(listeners, ...);
        end;
    end);
    return function()
        eventsFrame:SetScript("OnEvent", nil);
        eventListeners = nil;
    end;
end);

setmetatable(Events, {
    -- A metatable that allows the succinct Events.EVENT_NAME(eventListener) syntax. This creates new
    -- registries for new events on-demand. There are no errors emitted if an event name is not valid.
    __index = function(self, key)
        local listeners = {};
        self[key] = Activator(FunctionPopulator(listeners), function()
            local remover = initialize();
            eventListeners[key] = listeners;
            return function()
                eventListeners[key] = nil;
                Events[key] = nil;
                remover();
            end;
        end);
        return rawget(self, key);
    end
});
