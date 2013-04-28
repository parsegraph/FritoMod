-- Callbacks that deal with time.

if nil ~= require then
	require "fritomod/Lists";
	require "fritomod/currying";
	require "fritomod/Timing";
end;

Callbacks=Callbacks or {};
Timing = Timing or {};

local callbacks = {};

function Timing.Flush()
    while #callbacks > 0 do
        local cb = Lists.ShiftOne(callbacks);
        cb();
    end;
end;

-- Call the specified callback "later." This allows for functions to be called after
-- a OnUpdate event has fired, which may be necessary if changes to UI elements don't
-- propagate immediately.
--
function Callbacks.Later(func, ...)
    table.insert(callbacks, Curry(func, ...));
	local remover;
	remover=Timing.OnUpdate(function()
        Timing.Flush();
		remover();
	end);
	return remover;
end;
