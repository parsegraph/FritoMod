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
--	 Frames.Color(myPowerText, color);
--	 myPowerText:SetText(UnitPower("player");
-- end);
--
-- -- Spam guild with "FAIL" five times, streaming every .1 seconds.
-- local out=Timing.Throttle(.1, Chat.g);
-- for i=1, 5 do
--	 Chatpic.fail(out);
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
	require "wow/api/Frame";
	require "wow/api/Timing"

	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/ListenerList";

	require "fritomod/Callbacks-Frames";
end;

Timing = Timing or {};

do
	local listeners = ListenerList:New();
    listeners:SetRemoveOnFail(true);
    listeners:SetID("Timing")

	listeners:AddInstaller(function()
        if IsCallable(Timing.delegate) then
            Timing.delegate = Timing.delegate();
        end;
        return Timing.delegate:Start();
	end);

    local Delegate = OOP.Class("Timing.Delegate(WoW)");

    function Delegate:Constructor()
        self.frame = CreateFrame("Frame");
    end;

    function Delegate:Start()
        return Callbacks.OnUpdate(self.frame, Timing.Tick);
    end;

    Timing.delegate = Seal(Delegate, "New");

    -- Iterate our timers.
    --
    -- There's never a need to directly call this function unless you're developing or
    -- testing this addon.
    function Timing.Tick(...)
        -- We don't use currying here to ensure we can override listeners
        -- during testing.
        listeners:Fire(...);
    end;

	-- Adds a function that is fired every update. This is the highest-precision timing
	-- function though its precision is dependent on framerate.
	--
	-- listener, ...
	--	 the function that is fired every update
	-- returns
	--	 a function that removes the specified listener
	function Timing.OnUpdate(func, ...)
		-- We don't use currying here to ensure we can override listeners
		-- during testing.
		return listeners:Add(func, ...);
	end;

	-- Replace our listener tables with new ones.
	--
	-- You'll never call this function unless you're developing this addon.
	function Timing._Mask(newListeners)
		local oldListeners = listeners;
		listeners=newListeners;
		return function()
			listeners=oldListeners;
		end;
	end;
end;

-- Helper function to construct timers. tickFuncs are called every update, and should
-- return what they want elapsed to be. This allows tickFuncs to reset or adjust their
-- timer.
local function Timer(tickFunc, ...)
	tickFunc=Curry(tickFunc, ...);
	return function(period, func, ...)
		period = Strings.GetTime(period);
        func = Curry(func, ...);
        local success, err = true, "";
        local function Receiver()
            success, err = xpcall(func, traceback);
        end;
		local elapsed=0;
		return Timing.OnUpdate(function(delta)
			elapsed=tickFunc(period, elapsed+delta, Receiver);
            if not success then
                -- Reset success
                success = true;
                error(err);
            end;
		end);
	end;
end;

-- Calls the specified function periodically. This timer doesn't try to keep rhythm,
-- so the actual time will slowly wander further from the scheduled time. For most uses,
-- though, this behavior is tolerable, if not expected.
--
-- period
--	 the length in between calls, in seconds
-- func, ...
--	 the function that is invoked periodically
-- returns
--	 a function that, when invoked, stops this timer.
Timing.Periodic = Timer(function(period, elapsed, func)
	if elapsed >= period then
		func();
		elapsed=0;
	end;
	return elapsed;
end);


function Timing.Every(first, ...)
	if type(first) == "string" then
		local time = Strings.GetTime(first);
		if time > 0 then
			first = time;
		end;
	end;
	if type(first)=="number" then
		return Timing.Periodic(first, ...);
	else
		return Timing.OnUpdate(first, ...);
	end;
end;

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

-- Count down from the specified value, in seconds. The specified function will be
-- called each second, starting with seconds - 1 until zero, inclusively.
--
-- The returned remover will immediately stop the countdown with no further function
-- invocations.
function Timing.Countdown(seconds, func, ...)
	seconds=assert(tonumber(seconds), "Seconds must be a number. Given: "..type(seconds));
	assert(seconds > 0, "seconds must be positive. Given: "..tostring(seconds));
	func=Curry(func, ...);
	local r;
	r=Timing.Rhythmic(1, function()
		seconds = seconds - 1;
		if seconds >= 0 then
			func(seconds);
		else
			r();
		end;
	end);
	return r;
end;
Timing.CountDown=Timing.Countdown;
Timing.Count=Timing.Countdown;

function Timing.Interpolate(duration, func, ...)
	func = Curry(func, ...);
	duration = Strings.GetTime(duration);
	local start = GetTime();
	return function()
		local elapsed = GetTime() - start;
		func(Math.Clamp(0, elapsed / duration, 1));
	end;
end;

-- Cycle between a series of values, based on when this function is called.
--
-- This function has no remover since it does not use a timer.
--
-- period
--	 the amount of time for which any given value will be returned.
-- value, ...
--	 the values that will, over time, be used
function Timing.CycleValues(period, value, ...)
	period = Strings.GetTime(period);
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
--	 the minimum amount of time between calls to the specified function
-- returns
--	 a function that throttles invocations of function
-- see
--	 Timing.Throttle
function Timing.Cooldown(cooldownTime, func, ...)
	cooldownTime = Strings.GetTime(cooldownTime);
	func = Curry(func, ...);
	local lastCall;
	return function(first, ...)
		if first==POISON and select("#", ...) == 0 then
		   lastCall=nil;
		   return;
		end;
		local current = GetTime();
		if lastCall and lastCall + cooldownTime > current then
			return;
		end;
		lastCall = current;
		func(first, ...);
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
--	 time to wait between invocations, in seconds
-- func, ...
--	 func that is eventually called
-- returns
--	 a function that receives invocations. The arguments passed to the returned function
--	 will eventually be passed to func.
-- see
--	 Timing.Cooldown
function Timing.Throttle(waitTime, func, ...)
	waitTime = Strings.GetTime(waitTime);
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
--	 the initial wait time, in seconds
-- func, ...
--	 the function that may be eventually called
-- returns
--	 a timer that responds to the values listed above
function Timing.After(wait, func, ...)
	wait=Strings.GetTime(wait);
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
