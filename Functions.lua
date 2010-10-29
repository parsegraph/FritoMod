-- A library of operations that provide useful functional idioms.
if nil ~= require then
    require "basic";
    require "currying";
end;

if nil == Functions then
    Functions = {};
end;
local Functions = Functions;

local function GetCombinedRV(firstRV, secondRV)
	if IsCallable(firstRV) and IsCallable(secondRV) then
		-- Both are undoables, so group them
		return Functions.OnlyOnce(function()
			secondRV();
			firstRV();
		end);
	end;
	if firstRV == nil and IsCallable(secondRV) then
		return secondRV;
	end;
	if secondRV == nil and IsCallable(firstRV) then
		return firstRV;
	end;
	if firstRV == nil and secondRV == nil then
		return nil;
	end;
	error("Ambiguous return values: " .. type(firstRV) .. ", " .. type(secondRV));
end;

-- Blindly returns the given arguments. This implements a very primitive operation and
-- is ideal to be used in currying situations.
--
-- ...:*
--     arguments that should be returned by this operation
-- returns:*
--     ...
function Functions.Return(...)
    return ...;
end;

-- Returns a function that returns the specified values as-is.
--
-- ...:*
--     values that should be returned when the returned function is called
-- returns
--     a function that returns the given values
-- throws
--     if no values are given. Use Noop if you want a function that returns nothing
--     if any value is nil
function Functions.Values(...)
    local numArgs = select("#", ...);
    assert(numArgs > 0, "Return must be passed at least one argument");
    for i=1, numArgs do
        assert(select(i, ...) ~= nil, "Return must not be given nil arguments");
    end;
    return ForcedSeal(unpack, {...});
end;

-- Chains the specified wrapped function to the specified receiver function, emulating
-- the following idiom:
--
-- receiver(wrapped());
--
-- This enables the receiver to modify the returned values of the wrapped function.
--
-- wrapped:callable
--     the function that is called first, given the arguments passed into the returned
--     function
-- receiverFunc, ...
--     receives the returned values from wrapped. Its returned values are returned to
--     the caller of the returned function
-- returns:function
--     a function that should be passed arguments that the wrapped function expects, and
--     will return the values returned by the receiver function
function Functions.Chain(wrapped, receiverFunc, ...)
    assert(IsCallable(wrapped), "wrapped must be a callable. Type: " .. type(wrapped));
    receiverFunc = Curry(receiverFunc, ...);
    return function(...)
        return receiverFunc(wrapped(...));
    end;
end;

-- Cycles between the specified functions. Each invocation of the returned function
-- will invoke the next function. The cycle will loop once the last function is invoked.
--
-- ...
--     the functions that will be invoked, in the specified order
-- returns
--     a function that will invoke the next specified function in order
function Functions.Cycle(...)
    local functions = {...};
    local cycle = -1;
    return function(...)
        cycle = (cycle + 1) % #functions;
        return functions[cycle + 1](...);
    end;
end;
Functions.Rotate=Functions.Cycle;

-- Toggles between calling the specified function and the function returned by it (henceforth referred
-- to as the second function). The first function's returned value always replaces the second function.
-- The second function's return values, however, are ignored. 
--
-- Typically, the second function should undo some action performed by the specified first function, though 
-- this is not required.
--
-- func, ...
--     the function that is the undoable operation for this function. It must return a callable that,
--     when invoked, will "undo" the original operation
-- returns
--     a function that performs, or undoes, the specified function's operation
function Functions.Toggle(func, ...)
    func = Curry(func, ...);
    local second;
    return function(...)
        if nil == second then
            second = func(...);
            assert(IsCallable(second), "Returned value is not a callable. Value: " .. tostring(second));
        else
            second(...);
            second = nil;
        end;
    end;
end;

-- Group two functions together. When called, the returned function will call both functions.
-- 
-- Return values are ignored, unless both return values are callable. If they are callable, they are
-- called in reverse-order.
--
-- This function is fairly primitive. It's useful for simplifying areas where undoables need to be
-- grouped. It's similar
function Functions.Group(firstFunc, secondFunc, ...)
	firstFunc = Curry(firstFunc, ...);
	secondFunc = Curry(secondFunc, ...);
	return function(...)
		return GetCombinedRV(firstFunc(...), secondFunc(...));
	end;
end;

-- Hooks the global function with the specified name, calling the specified function before the global
-- is called. The hook function should return the arguments passed to it, as these arguments will then
-- be passed to the original global, like the following:
--     return originalGlobal(hookFunc(...));
--
-- name:*
--     the global name of the function that is hooked
-- hookFunc, ...
--     the function that is called before the hooked global is called. It should expect the arguments that
--     the hooked global would expect, and should return those arguments. The returned arguments are then
--     passed to the hooked global
-- returns
--     a remover function that, when invoked, restores the global to its value before the global was
--     hooked. The remover will throw if the global has been changed since this function was called.
function Functions.HookGlobal(name, hookFunc, ...)
    hookFunc = Curry(hookFunc, ...);
    local hookedGlobal = _G[name];
    assert(IsCallable(hookedGlobal), "Global function is not callable. Name: " .. name);
    local function Hook(...)
        return hookedGlobal(hookFunc(...));
    end;
    _G[name] = Hook;
    return function()
        assert(_G[name] == Hook, "Global has been modified, so hook cannot be safely removed. Name: " .. name);
        _G[name] = hookedGlobal;
    end;
end;

-- Combines the two specified functions, creating an undoable. The performer should do something, and the 
-- undoFunc should undo that action. 
--
-- Both functions receive the varargs passed here. This is different than most other operations.
--
-- performer:function
--     performs some action. It is given the arguments passed into Undoable, as well as arguments passed 
--     to the returned function. Its return value is ignored.
-- undoFunc:function
--     undoes the action performed by performer. It is given the arguments passed into Undoable, as well 
--     as arguments passed to the returned function. Its return value is ignored.
-- ...:*
--     arguments that are curried to both the performer and the undoFunc
-- returns:undoable function
--     a function that, when called, invokes performer. It returns a function that, when invoked, will
--     call undoFunc.
function Functions.Undoable(performer, undoFunc, ...)
    performer = Curry(performer, ...);
    undoFunc = Curry(undoFunc, ...);
    return function(...)
        performer(...);
        return Functions.OnlyOnce(undoFunc);
    end;
end;

-- Decorates the global function of the specified name, calling the specified function whenever the
-- global is called. The spy function merely observes calls to the global; it does not affect them.
--
-- name:*
--     the name of the global function
-- spyFunc, ...
--     the function that should be called before any invocation of the global. It should expect the
--     same arguments as the spied global. Its returned values are ignored
-- returns
--     a remover function that, when invoked, restores the global to its value before the global was
--     hooked. The remover will throw if the global has been changed since this function was called.
function Functions.SpyGlobal(name, spyFunc, ...)
	spyFunc = Curry(spyFunc, ...);
	return Functions.HookGlobal(name, function(...)
		spyFunc(...);
		return ...;
	end);
end;

-- Overrides the return value of the hooked function. hook will receive the new value and is
-- responsible for returning the new return value.
--
-- This is one of those functions that isn't very useful on its own, but it can greatly
-- enhance the readability if hooked and hook are themselves higher order functions.
--
-- see
--    Functions.ReturnSpy
function Functions.ReturnHook(hooked, hook, ...)
   hook=Curry(hook, ...);
   return function(...)
      return hook(hooked(...));
   end;
end;
Functions.HookReturn=Functions.ReturnHook;
Functions.HookedReturn=Functions.ReturnHook;
Functions.ReturnHooked=Functions.ReturnHook;

-- Ensures that the specified function is only called once, despite multiple invocations of the
-- returned function.
--
-- func, ...
--     a function that is called. It will be called up to once by the returned function
-- returns:function
--     a function that calls the specified function up to once. Subsequent calls do nothing and
--     return nothing
function Functions.OnlyOnce(func, ...)
    func = Curry(func, ...);
    return function(...)
        if not func then
            return;
        end;
        -- Assign func to a temporary variable to let it fall out of scope.
        local called = func;
        func = nil;
        return called(...);
    end;
end;

-- Spies on the specified function, observing it without affecting its behavior.
--
-- This function is very similar to Group, but Spy is more specialized in how its functions should behave. 
-- Spy also always uses the observed function's return values, instead of ignoring them.
--
-- If the spy and the observed function are undoables, the spy's undoable will be called after the observed's.
--
-- observedFunc:callable
--     the original function that is the target of this function.
-- spy, ...
--	   a callable that observes invocations to the original function. It should not affect the behavior
--	   of the observed function. 
--	   
--	   If its return value is a callable, it will be treated as an undoable. Otherwise, the return value will be 
--	   ignored.
-- returns:function
--     a function that wraps the observed function, invoking the observer first.
function Functions.Spy(observedFunc, spy, ...)
	observedFunc = Curry(observedFunc, ...);
    spy = Curry(spy, ...);
    return function(...)
        local spyRV = spy(...);
        local observedRV = observedFunc(...);
		if spyRV == nil and observedRV ~= nil then
			-- This special case ensures we don't crash if the spy is silent, which will be the case if spy
            -- is not an undoable.
			return observedRV;
		end;
		return GetCombinedRV(spyRV, observedRV);
    end;
end;

-- Spies on the observed function's return value. This doesn't support undoable-like behavior, mainly because I
-- can't think of a viable use-case. If one comes up, this function should behave similar to Functions.Spy.
function Functions.ReturnSpy(observedFunc, spy, ...)
	observedFunc = Curry(observedFunc, ...);
    spy = Curry(spy, ...);
    return function(...)
        local observedRV = observedFunc(...);
        spy(observedRV);
		return observedRV;
    end;
end;
Functions.SpyReturn=Functions.ReturnSpy;

-- Manages invocation of one-time setup and tear-down functionality. The setup function is called during the 
-- first invocation of the returned function, returning a function that tears down any initialization. 
--
-- The activator's returned function should undo any action performed by the activator. This function is 
-- called when all tear-down functions have been called.
--
-- The benefit is that this operation keeps track of how many set-up and tear-down invocations have been made. The
-- activator is called on the first set-up call, but subsequent set-up calls do nothing. Tear-down calls also do
-- nothing until the final tear-down call is made. At this point, the returned deactivator is called and the 
-- activator should return to its initial state.
--
-- setUp, ...
--     a callable that, when invokes, performs some one-time initialization or set-up. It must return a function
--     that tears down any initialization previously performed.
-- returns:function
--     a function that, when called, could perform set-up functionality. It returns a function that, 
--     when called, could perform tear-down functionality. What action is actually performed is determined by 
--     the specified activator.
function Functions.Install(setUp, ...)
    setUp = Curry(setUp, ...);
    local tearDown = nil;
    local count = 0;
    return function()
        if count == 0 then
            tearDown = setUp();
        end;
        count = count + 1;
        return Functions.OnlyOnce(function()
            count = count - 1;
            if count == 0 then
                tearDown();
            end;
        end);
    end;
end;
