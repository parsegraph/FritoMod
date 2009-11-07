-- A library of operations that provide useful functional idioms.
if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
end;

if nil == Functions then
    Functions = {};
end;
local Functions = Functions;

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

-- Provides undo/redo functionality for the specified function that supports it. When first
-- invoked, the returned function will call the specified function. The specified function
-- is expected to return a callable that, when invoked, will "undo" the specified function's
-- operation. The next invocation will invoke that "undo" function.
--
-- This function is essentially a special kind of Cycle: it cycles between performing an operation,
-- and undoing that operation. It may be also used for more complicated schemes that don't
-- necessarily "undo" anything, but rather progress through some dynamic chain of functions.
--
-- func, ...
--     the function that is the undoable operation for this function. It must return a callable that,
--     when invoked, will "undo" the original operation
-- returns
--     a function that performs, or undoes, the specified function's operation
function Functions.Undoable(func, ...)
    func = Curry(func, ...);
    local remover = nil;
    return function(...)
        if remover then
            remover(...);
        end;
        remover = func(...);
        assert(IsCallable(remover), "remover is not a callable");
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

