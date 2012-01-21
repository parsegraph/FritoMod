-- Utility methods for callbacks.
--
-- There's no need to include this unless you're using one
-- of the methods here.
if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
end;

Callbacks = Callbacks or {};

function Callbacks.Reversed(callback, func, ...)
	if type(callback) == "string" then
		callback = Callbacks[callback];
	end;
	assert(
		IsCallable(callback),
		"Callback must be callable. Given: "..tostring(callback)
	);
	return callback(Functions.ReverseUndoable(func, ...));
end;

function Callbacks.ReversedCallback(callback)
	if type(callback) == "string" then
		callback = Callbacks[callback];
	end;
	assert(IsCallable(callback), "Callback must be callable. Given: "..tostring(callback));
	return Curry(Callbacks.Reversed, callback);
end;
Callbacks.ReverseCallback = Callbacks.ReversedCallback;

function Callbacks.OnlyOnce(callback, listener, ...)
	listener=Curry(listener, ...);
	local remover;
	remover = callback(function(...)
		listener(...);
		remover();
	end);
end;
