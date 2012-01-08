if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Persistence";
	require "fritomod/Timing";
end;

local PERSISTENCE_KEY="FritoMod.SavedCooldowns";

DEBUG_TRACE_TIMING=false;

local function trace(...)
	if DEBUG_TRACE_TIMING then
		return trace(...);
	end;
end;

function Timing.SavedCooldown(name, cooldownTime, func, ...)
	cooldownTime = Strings.GetTime(cooldownTime);
	func = Curry(func, ...);
	return function(first, ...)
		if first==POISON and select("#", ...) == 0 then
		   return;
		end;
		if not Persistence.Loaded() then
			return;
		end;
		local current = time();
		if not Persistence[PERSISTENCE_KEY] then
			Persistence[PERSISTENCE_KEY] = {};
		end;
		local lastCall = Persistence[PERSISTENCE_KEY][name];
		if lastCall and lastCall + cooldownTime > current then
			trace("Cooldown %q invoked but not yet ready.", name);
			return;
		end;
		trace("Invoking cooldown %q", name);
		Persistence[PERSISTENCE_KEY][name] = current;
		func(first, ...);
	end;
end;

function Timing.DumpCooldown(name)
	if Persistence.Loaded() then
		if Persistence[PERSISTENCE_KEY] then
			print(name .. ": "..Persistence[PERSISTENCE_KEY][name]);
		else
			print(name .. ": No cooldown recorded");
		end;
	else
		print("Persistence not loaded");
	end;
end;
