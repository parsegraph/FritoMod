if nil ~= require then
    -- This file uses WoW-specific functionality

    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";

    require "FritoMod_Collections/Lists";
    require "FritoMod_Collections/Functions";

    require "FritoMod_Strings/Parsers";
end;

Timing = {};
local Timing = Timing;

local updateListeners = {};
local timingFrame = CreateFrame("Frame", nil, UIParent);

-- Adds a function that is fired every update. This is the highest-precision timing
-- function though its precision is dependent on framerate.
--
-- listener, ...
--     the function that is fired every update
-- returns
--     a function that removes the specified listener
Timing.OnUpdate = Functions.Spy(
	function(func, ...)
		return Lists.Insert(updateListeners, Curry(func, ...));
	end,
	Functions.Install(function()
		timingFrame:SetScript("OnUpdate", function(frame, elapsed) 
			for i=1, #updateListeners do
				updateListeners[i](elapsed);
			end;
		end);
		return function()
			timingFrame:SetScript("OnUpdate", nil);
		end;
	end)
);

-- Helper function to construct timers. tickFuncs are called every update, and should
-- return what they want elapsed to be. This allows tickFuncs to reset or adjust their
-- timer.
local function Timer(tickFunc, ...)
	tickFunc=Curry(tickFunc, ...);
	return function(period, func, ...)
		func=Curry(func,...);
		local elapsed=0;
		return Timing.OnUpdate(function(delta)
			elapsed=tickFunc(period, elapsed+delta, func);
		end);
	end;
end;

-- Calls the specified function periodically. This timer doesn't try to keep rhythm,
-- so the actual time will slowly wander further from the scheduled time. For most uses,
-- though, this behavior is tolerable, if not expected.
--
-- period
--     the length in between calls, in seconds
-- func, ...
--     the function that is invoked periodically
-- returns
--     a function that, when invoked, stops this timer.
Timing.Periodic = Timer(function(period, elapsed, func)
	if elapsed >= period then
		func();
		elapsed=0;
	end;
	return elapsed;
end);
Timing.Every=Timing.Periodic;

-- Calls the specified function rhythmically. This timer will maintain a rhythm; actual 
-- times will stay close to scheduled times, but distances between individual iterations 
-- will vary.
Timing.Rhythmic = Timer(function(period, elapsed, func)
	if elapsed >= period then
		func();
		elapsed=elapsed % period;
	end;
	return elapsed;
end);
Timing.Beat=Timing.Rhythmic;
Timing.OnBeat=Timing.Rhythmic;

-- Calls the specified function periodically. This timer will ensure that the function
-- is called for every elapsed period. This is similar to Timing.Rhythmic, but where
-- the rhymthic timer could "miss" beats, burst will fire the function as many times as
-- necessary to account for them.
Timing.Burst = Timer(function(period, elapsed, func)
	local c=math.floor(elapsed / period);
	while c > 0 do
		func();
		t=t-period;
	end;
	return elapsed % period;
end);

-- Throttles invocations for the specified function. Multiple calls to this function
-- will only yield one invocation of the specified function. Subsequent calls will be
-- ignored until the cooldown time has passed.
--
-- This is not a timer; the function is always invoked directly and never as a result 
-- of an event. If the returned function is never called, the specified function will 
-- never be invoked.
--
-- cooldownTime
--     the minimum amount of time between calls to the specified function
-- returns
--     a function that throttles invocations of function
function Timing.Throttle(cooldownTime, func, ...)
    func = Curry(func, ...);
    local lastCall = 0;
    return function(...)
        local current = GetTime();
        if lastCall + cooldownTime > current then
            return;
        end;
        lastCall = current;
        return func(...);
    end;
end;
