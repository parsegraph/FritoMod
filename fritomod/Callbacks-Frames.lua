if nil ~= require then
	require "wow/Frame-Events";

	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/Frames";
end;

Callbacks=Callbacks or {};

-- Easy callback for registering OnFoo events, in a more FritoMod-esque fashion.
function Callbacks.Script(frame, event, callback, ...)
	frame = Frames.AsRegion(frame);
	assert(IsCallable(frame.SetScript), "Frame does not support SetScript");
	callback=Curry(callback, ...);
	trace("Registering script event %q", event);
	frame:SetScript(event, function(frame, ...)
		callback(...);
	end);
	return Functions.OnlyOnce(function()
		trace("Releasing script event %q", event);
		frame:SetScript(event, nil);
	end);
end;
Callbacks.On=Callbacks.Script;

Callbacks.OnEvent=Headless(Callbacks.Script, "OnEvent");
Callbacks.OnUpdate=Headless(Callbacks.Script, "OnUpdate");

-- Easy callback for registering OnFoo events, in a more FritoMod-esque fashion.
function Callbacks.HookScript(frame, event, callback, ...)
	assert(IsCallable(frame.HookScript), "Frame does not support HookScript");
	frame = Frames.AsRegion(frame);
	callback=Curry(callback, ...);
	frame:HookScript(event, function(frame, ...)
		if callback then
			callback(...);
		end;
	end);
	return Functions.OnlyOnce(function()
		callback=nil;
	end);
end;
Callbacks.HookedScript=Callbacks.HookScript;
Callbacks.ScriptHook=Callbacks.HookScript;
