-- Events is a registry of event listeners.
--
-- Events.EVENT_NAME(Chat.Say, "Something happened!")
--
-- This prints out a message for up to five spell misses:
--
-- local count = 0;
-- local remover;
-- remover = Events.UNIT_SPELLMISS(function(unitId, reason)
--	 count = count + 1;
--	 Chatf.s("%s missed. Reason: %s", reason, UnitName(unitId));
--	 if count > 5 then
--		 remover();
--	 end;
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
	require "wow/Frame-Events";
	require "wow/api/Frame";

	require "fritomod/basic";
	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/ListenerList";

	require "fritomod/Mixins-Log";
end;

local log = Logger:New("Events");

Events = {};
local eventListeners = {};
Events._eventListeners = eventListeners;

function Events.Dispatch(event, ...)
	local listeners = eventListeners[event];
	if listeners then
        if select("#", ...) > 0 then
            log:logEntercf("Event dispatches", "Dispatching", event, "event with arguments", ...);
        else
            log:logEntercf("Event dispatches", "Dispatching", event, "event with no arguments");
        end;
        listeners:Fire(...);
        log:logLeave();
	end;
end;

local Delegate = OOP.Class();

function Delegate:Constructor()
    self.eventsFrame = CreateFrame("Frame");

    self.eventsFrame:SetScript("OnEvent", function(frame, event, ...)
        Events.Dispatch(event, ...);
    end);
end;

function Delegate:RegisterEvent(event)
    self.eventsFrame:RegisterEvent(event);
end;

function Delegate:UnregisterEvent(event)
    self.eventsFrame:UnregisterEvent(event);
end;

Events.delegate = Seal(Delegate, "New");

setmetatable(Events, {
	-- A metatable that allows the succinct Events.EVENT_NAME(eventListener) syntax. This creates new
	-- registries for new events on-demand. There are no errors emitted if an event name is not valid.
	__index = function(self, key)
		if type(key)=="table" and #key>0 then
			return function(func, ...)
				func=Curry(func, ...);
				local removers={};
				for _, v in ipairs(key) do
					table.insert(removers, Events[v](func));
				end;
				return Functions.OnlyOnce(Lists.CallEach, removers);
			end;
		end;
		eventListeners[key] = ListenerList:New();
		eventListeners[key]:SetID("Events."..key);

		eventListeners[key]:AddInstaller(function()
            local delegate = rawget(self, "delegate");
            assert(delegate, "Events has no event delegate");
            if type(delegate) == "function" then
                delegate = delegate();
                rawset(self, "delegate", delegate);
            end;
            log:logEntercf("Event registrations", "Registering event", key);
			delegate:RegisterEvent(key);
            log:logLeave();
			return function()
                log:logEntercf("Event registrations", "Unregistering event", key);
				delegate:UnregisterEvent(key);
                log:logLeave();
			end;
		end);
		self[key] = function(func, ...)
			return eventListeners[key]:Add(func, ...);
		end;
		return rawget(self, key);
	end
});
