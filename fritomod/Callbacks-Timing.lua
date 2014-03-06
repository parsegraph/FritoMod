-- Callbacks that deal with time.

if nil ~= require then
	require "fritomod/Lists";
	require "fritomod/currying";
	require "fritomod/Timing";
	require "fritomod/Log";
end;

Callbacks=Callbacks or {};
Timing = Timing or {};

local callbacks = ListenerList:New();

function Timing.Flush()
    if not callbacks:HasListeners() then
        return;
    end;
    if callbacks:IsFiring() then
        return;
    end;
    Log.Enter("Timing", "Calling deferred functions", "Calling", callbacks:Count(), "deferred functions(s)");

    callbacks:Fire();
    Log.Leave("Timing", nil, "Flush complete");
end;

callbacks:AddInstaller(Timing.OnUpdate, Timing.Flush);

-- Call the specified callback "later." This allows for functions to be called after
-- a OnUpdate event has fired, which may be necessary if changes to UI elements don't
-- propagate immediately.
--
function Callbacks.Later(func, ...)
    Log.Enter("Timing", "Deferring functions", "Deferring function");
    func = Curry(func, ...);
    local remover;
    remover = callbacks:Add(function()
        func();
        remover();
    end);
	Log.Leave();
	return remover;
end;
