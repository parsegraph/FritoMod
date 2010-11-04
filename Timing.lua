-- Timing is a namespace of functions dealing with time. Timing.OnUpdate is likely to be
-- the most familiar timer for any newbies.
--
-- local r=Timing.OnUpdate(print, "This is printed every frame!");
-- r() -- Remove the timer
--
-- Timing also lets you call a function periodically. All periods in Timing are specified 
-- in seconds:
--
-- Timing.Every(1, print, "Print every 1 second");
--
-- Invocations are dependent on framerate, so a slow or inconsistent framerate can cause
-- issues. There's a few different strategies for compensating for this problem, and Timing
-- provides them as separate timing functions:
--
-- * Periodic - Call function one period after now. Invocations can be lost, and the actual
-- time will drift from the scheduled time. However, time between invocations will stay fairly
-- constant.
-- * Rhythmic - Compensate for drift, so delayed invocations will not delay subsequent 
-- invocations. Invocations can be lost. Time between individual invocations will vary.
-- * Burst - Compensate for delays. Invocations are never lost, but time between invocations
-- can be extremely inconsistent.
--
-- If you have a good framerate, there will be very little difference between these functions.
-- Periodic and Rhythmic are only subtly different from one another. You must use Burst if
-- you're depending on a function to be called a certain number of times.
--
-- There's also some other neat functions here that aren't timers:
--
-- -- Cycle a myPowerText between purple and orange
-- local color=Timing.CycleValues(1, "purple", "orange");
-- Timing.Every(.2, function()
--     Frames.Color(myPowerText, color);
--     myPowerText:SetText(UnitPower("player");
-- end);
--
-- -- Spam guild with "FAIL" five times, streaming every .1 seconds.
-- local out=Timing.Throttle(.1, Chat.g);
-- for i=1, 5 do
--     Chatpic.fail(out);
-- end;

-- I don't try to have FritoMod cover every possible case. If your timing strategy is sufficiently
-- complicated, you'll have to write it yourself.
--
-- I might eventually write a scheduler that would balance timer invocations and framerate. This
-- would take some of the guesswork out of deciding period magnitude. Until then, use your best
-- judgement.
--
-- Prefer callbacks over timers, as callbacks will only fire on changes. These saved frames add up.

if nil ~= require then
    require "wow/Frame-Events";
    require "wow/Timing"

    require "basic";
    require "currying";
    require "Functions";
    require "Lists";
    require "Callbacks-Events";
end;

Timing = {};
local Timing = Timing;

do
    local updateListeners = {};
    local deadListeners = {};
    local timingFrame = CreateFrame("Frame", nil, UIParent);

    -- Replace our listener tables with new ones.
    --
    -- You'll never call this function unless you're developing this addon.
    Timing._Mask = function(newUpdate, newDead)
        local oldUpdate, oldDead=updateListeners, deadListeners;
        updateListeners=newUpdate;
        deadListeners=newDead;
        return function()
            updateListeners=oldUpdate;
            deadListeners=oldDead;
        end;
    end;

    -- Iterate our timers.
    --
    -- You'll never call this function unless you're developing this addon.
    Timing._Tick = function(elapsed)
        for i=1, #updateListeners do
            local listener=updateListeners[i];
            if not Lists.Contains(deadListeners, listener) then
                listener(elapsed);
            end;
        end;
        while #deadListeners > 0 do
            Lists.Remove(updateListeners, table.remove(deadListeners));
        end;
    end;

    -- Adds a function that is fired every update. This is the highest-precision timing
    -- function though its precision is dependent on framerate.
    --
    -- listener, ...
    --     the function that is fired every update
    -- returns
    --     a function that removes the specified listener
    Timing.OnUpdate = Functions.Spy(
        function(func, ...)
            -- We can't just remove a listener at any given time because we may be 
            -- iterating over our list. Instead, any listeners that are removed must be
            -- saved, so they can be removed at a safe time later on.
            func=Curry(func, ...);
            table.insert(updateListeners, func);
            return Functions.OnlyOnce(function()
                table.insert(deadListeners, func);
            end);
        end,
        Functions.Install(Callbacks.OnUpdate, timingFrame, function(_, elapsed) 
            Timing._Tick(elapsed);
        end)
    );
end;

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
--
-- This rhythm is local to this function. You'll have to do synchronizing on your own to
-- maintain a global rhythm.
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
		c=c-1;
	end;
	return elapsed % period;
end);

-- Cycle between a series of values, based on when this function is called.
--
-- This function has no remover since it does not use a timer.
--
-- period
--     the amount of time for which any given value will be returned.
-- value, ...
--     the values that will, over time, be used
function Timing.CycleValues(period, value, ...)
    local values={value, ...};
    local time=GetTime();
    return function()
        -- First, get the total elapsed time. 
        --
        -- Imagine a 2 second period with 3 values and our elapsed time is 9 seconds.
        local elapsed=GetTime()-time;
        -- Then, use modulus to get our elapsed time in the scope of a single period.
        --
        -- elapsed is now 3, due to 9 % ( 3 * 2)
        elapsed=elapsed % (#values * period);
        -- Since elapsed is now in the range [0,#values * period), we can use it to
        -- find which value to return.
        --
        -- math.ceil(3 / 2) == math.ceil(1.5) == 2
        elapsed=math.ceil(elapsed / period);
        return values[math.min(math.max(1, elapsed), #values)];
    end;
end;

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
-- see
--     Timing.Throttle
function Timing.Cooldown(cooldownTime, func, ...)
    func = Curry(func, ...);
    local lastCall;
    return function(...)
        local current = GetTime();
        if lastCall and lastCall + cooldownTime > current then
            return;
        end;
        lastCall = current;
        return func(...);
    end;
end;

-- Saves invocations so that func is only called periodically. Excess invocations are
-- saved, so you can use this function to "slow down" a stream of data. This function
-- is similar to Timing.Cooldown, but cooldown ignores excess invocations instead of
-- postponing them.
--
-- This function is not undoable, but it can be poisoned.
-- 
-- waitTime
--     time to wait between invocations, in seconds
-- func, ...
--     func that is eventually called
-- returns
--     a function that receives invocations. The arguments passed to the returned function
--     will eventually be passed to func.
-- see
--     Timing.Cooldown
function Timing.Throttle(waitTime, func, ...)
    func=Curry(func, ...);
    local invocations={};
    local r;
    return function(p, ...)
        if p == POISON then
            if r then
                r();
                r=nil;
            end;
            invocations={};
            return;
        end;
        table.insert(invocations, {p,...});
        if not r then
            r=Timing.Rhythmic(waitTime, function()
                if #invocations > 0 then
                    func(unpack(table.remove(invocations, 1)));
                end;
                if #invocations==0 then
                    r();
                    r=nil;
                end;
            end);
        end;
    end;
end;

-- Return a timer that, after `wait` seconds, will call `func`.
--
-- The timer can be delayed by calling it with special values:
-- * If the timer is called with a number, the call to `func`
-- will be delayed by that amount. There is no maximum delay, so
-- you can delay `func` by a value that's greater than the initial
-- `wait`.
-- * If the timer is called with POISON, the timer will be
-- irrecoverably killed.
-- * If the timer is called with nil, this timer will wait
-- at least `wait` seconds before calling `func`.
--
-- wait
--     the initial wait time, in seconds
-- func, ...
--     the function that may be eventually called
-- returns
--     a timer that responds to the values listed above
function Timing.After(wait, func, ...)
	func=Curry(func,...);
	local elapsed=0;
	local r;
	r=Timing.OnUpdate(function(delta)
		elapsed=elapsed+delta;
		if elapsed >= wait then
			r();
            r=nil;
			func();
		end;
	end);
	return function(delay)
        if not r then
            return;
        end
        if delay==POISON then
            r();
            r=nil;
        elseif delay==nil then
            elapsed=math.min(0, elapsed);
        else
            elapsed=elapsed-delay;
        end;
    end;
end;
