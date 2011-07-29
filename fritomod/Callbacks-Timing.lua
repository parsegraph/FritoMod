-- Callbacks that deal with time.

if nil ~= require then
    require "fritomod/Timing";
end;

Callbacks=Callbacks or {};

-- Call the specified callback "later." This allows for functions to be called after
-- a OnUpdate event has fired, which may be necessary if changes to UI elements don't
-- propagate immediately.
--
function Callbacks.Later(func, ...)
    func=Curry(func, ...);
    local remover;
    remover=Timing.OnUpdate(function()
        func();
        remover();
    end);
    return remover;
end;
