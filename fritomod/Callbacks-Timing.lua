-- Callbacks that deal with time.

if nil ~= require then
	require "fritomod/Lists";
	require "fritomod/currying";
	require "fritomod/Timing";
	require "fritomod/log";
end;

Callbacks=Callbacks or {};
Timing = Timing or {};

local callbacks = {};

function Timing.Flush()
    if #callbacks == 0 then
        return;
    end;
    Log.Enter("Timing", "Calling deferred functions", "Calling", #callbacks, "deferred functions(s)");

    local runningCallbacks = callbacks;
    callbacks = {};
    for i=1, #runningCallbacks do
        runningCallbacks[i]();
    end;
    Log.Leave();
end;

-- Call the specified callback "later." This allows for functions to be called after
-- a OnUpdate event has fired, which may be necessary if changes to UI elements don't
-- propagate immediately.
--
function Callbacks.Later(func, ...)
    Log.Enter("Timing", "Deferring functions", "Deferring function");
    table.insert(callbacks, Curry(func, ...));
	local remover;
	remover=Timing.OnUpdate(function()
        Timing.Flush();
		remover();
	end);
    Log.Leave();
	return remover;
end;
