-- Utility methods for callbacks.
--
-- There's no need to include this unless you're using one
-- of the methods here.
if nil ~= require then
	require "fritomod/currying";
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
	func=Curry(func, ...);
	local remover;
	return callback(function(...)
		if remover then
			remover(...);
			remover=nil;
		end;
		return function(...)
			remover = func(...);
		end;
	end);
end;

function Callbacks.ReversedCallback(callback)
	if type(callback) == "string" then
		callback = Callbacks[callback];
	end;
	assert(IsCallable(callback), "Callback must be callable. Given: "..tostring(callback));
	return Curry(Callbacks.Reversed, callback);
end;
