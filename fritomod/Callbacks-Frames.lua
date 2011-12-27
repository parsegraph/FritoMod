if nil ~= require then
    require "wow/Frame-Events";

    require "fritomod/currying";
    require "fritomod/Functions";
end;

Callbacks=Callbacks or {};

-- Easy callback for registering OnFoo events, in a more FritoMod-esque fashion.
function Callbacks.Script(frame, event, callback, ...)
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
