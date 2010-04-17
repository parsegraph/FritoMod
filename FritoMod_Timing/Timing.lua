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
Timing.AddUpdateListener = Functions.Lazy(Functions.FunctionPopulator(updateListeners), function()
    timingFrame:SetScript("OnUpdate", function(frame, elapsed) 
       Lists.CallEach(updateListeners, elapsed);
    end);
    return Curry(timingFrame, "SetScript", "OnUpdate", nil);
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
    cooldownTime = Parsers.Time(cooldownTime);
    func = Curry(func, ...);
    local lastCall = 0;
    return function(...)
        local current = time();
        if lastCall + cooldownTime > current then
            return;
        end;
        lastCall = current;
        return func(...);
    end;
end;

-- Calls the specified function periodically. This function makes no attempt to correct
-- for inconsistencies in when it is invoked.
--
-- period
--     the length in between calls, in milliseconds
-- func, ...
--     the function that is invoked periodically
-- returns
--     a function that, when invoked, stops this timer.
function Timing.Periodic(period, func, ...)
    period = Parsers.Time(period);
    func = Curry(func, ...);
    local totalElapsed = 0;
    return Timing.AddUpdateListener(function(elapsedSinceLastIteration)
        totalElapsed = totalElapsed + elapsedSinceLastIteration;
        if totalElapsed >= period then
            func();
            totalElapsed = 0;
        end;
    end);
end;

function Timing.Rhythmic(period, func, ...)
    period = Parsers.Time(period);
    func = Curry(func, ...);
    local totalElapsed = 0;
    return Timing.AddUpdateListener(function(elapsedSinceLastIteration)
        totalElapsed = totalElapsed + elapsedSinceLastIteration;
        if totalElapsed >= period then
            func();
            totalElapsed = totalElapsed % period;
        end;
    end);
end;

function Timing.Burst(period, func, ...)
    period = Parsers.Time(period);
    func = Curry(func, ...);
    local totalElapsed = 0;
    return Timing.AddUpdateListener(function(elapsedSinceLastIteration)
        totalElapsed = totalElapsed + elapsedSinceLastIteration;
        if totalElapsed >= period then
            func();
            totalElapsed = totalElapsed % period;
        end;
    end);
end;
