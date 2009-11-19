-- A library of operations that provide useful functional idioms.
if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
end;

if nil == Functions then
    Functions = {};
end;
local Functions = Functions;

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

-- Combines the two specified functions. The performer should do something, and the undoFunc should undo
-- that action. 
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
    local spiedGlobal = _G[name];
    local function Spy(...)
        spyFunc(...);
        if spiedGlobal then
            return spiedGlobal(...);
        end;
    end;
    _G[name] = Spy; 
    return function()
        assert(_G[name] == Spy, "Global has been modified, so spy cannot be safely removed. Name: " .. name);
        _G[name] = spiedGlobal;
    end;
end;

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

-- Allows the specified observer to spectate calls to wrapped, without affecting wrapped.
--
-- This returns a function that, when called, will invoke the observer with the given arguments, 
-- and then call the observed function.
--
-- observedFunc:callable
--     the actual function that is called after the observer.
-- observer, ...
--     the observer that receives arguments that will be passed to the observedFunc. The observer
--     cannot affect primitive values, though it has access to the arguments so non-primitive values
--     may be affected by the observer.
-- returns:function
--     a function that wraps the observed function, invoking the observer first.
function Functions.Observe(observedFunc, observer, ...)
    assert(IsCallable(observedFunc), "observedFunc function is not callable. Type: " .. type(observedFunc));
    observer = Curry(observer, ...);
    return function(...)
        observer(...);
        return observedFunc(...);
    end;
end;

-- Observes the specified undoable function. A function is returned that, when called, invokes the spy before
-- invoking the specified undoable. The undoable's remover is wrapped such that the spy's remover is also called.
-- In this way, the undoable is observed at both stages of its lifecycle.
--
-- undoable:undoable callable
--     the observed function
-- spyFunc, ... :undoable callable
--     the spy that observes the undoable. It should return a remover function, but is not given any arguments
--     to its performer or its remover.
-- returns:undoable callable
--     mimics the behavior performed by the specified undoable, but also invokes the spy whenenver the undoable
--     would be invoked.
function Functions.ObserveUndoable(undoable, spyFunc, ...)
    assert(IsCallable(undoable), "undoable function is not callable. Type: " .. type(wrapped));
    undoable = Curry(undoable, ...);
    spyFunc = Curry(spyFunc, ...);
    return function(...)
        local spyFuncRemover = spyFunc(...) or Noop;
        local undoableRemover = undoable(...) or Noop;
        return Functions.OnlyOnce(function()
            undoableRemover();
            spyFuncRemover();
        end);
    end;
end;

-- Returns a function that wraps the specified function. Before the specified function is
-- invoked, the activator is called. Subsequent calls to the returned function will directly
-- call the specified function.
--
-- A practical example of this function is a event listener. Whenever a event listener is 
-- attached, it must be first registered with the frame. Typically, this means that RegisterEvent
-- must be called greedily and is typically never relinquished. For short-lived event listeners,
-- this is problematic. However, with this utility, writing a lazy event registry is trivial:
--
-- local listeners = {};
-- local inserter = Curry(Lists.Insert, listeners);
-- local activator = function()
--     frame:RegisterEvent("SOMETHING");
--     return Curry(frame, "UnregisterEvent", "SOMETHING");
-- end;
-- local AddListener = Functions.Lazy(inserter, activator);
--
-- wrapped
--     the internal function that is called for every invocation of the returned method
-- activator, ...
--     the function that is invoked before every "new" series of invocations of the wrapped method.
--     In practice
function Functions.Lazy(wrapped, activator, ...)
    assert(IsCallable(wrapped), "wrapped function is not callable. Type: " .. type(wrapped));
    activator = Curry(activator, ...);
    local deactivator = nil;
    local count = 0;
    return function(...)
        if count == 0 then
            deactivator = activator() or Noop;
        end;
        count = count + 1;
        local sanitizer = wrapped(...) or Noop;
        return function()
            if not sanitizer then
                return;
            end;
            sanitizer();
            sanitizer = nil;
            count = count - 1;
            if count == 0 then
                deactivator();
            end;
        end;
    end;
end;

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
