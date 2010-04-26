-- Allows access to combat log events in a style similar to Events.

CombatEvents = {};
local eventListeners = {}; 
CombatEvents._eventListeners = eventListeners;

CombatEvents._call = function(timestamp, event, ...)
	local listeners = eventListeners[event];
	if listeners then
		Lists.CallEach(listeners, timestamp, ...);
	end;
end;
local setUp = Functions.Install(Events.COMBAT_LOG_EVENT_UNFILTERED, CombatEvents._call);

setmetatable(CombatEvents, {
	__index = function(self, key)
		eventListeners[key] = {};
		self[key] = Functions.Spy(
			function(func, ...)
				return Lists.Insert(eventListeners[key], Curry(func, ...));
			end,
			setUp
		);
        return rawget(self, key);
	end
});
