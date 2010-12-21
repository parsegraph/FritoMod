if nil ~= require then
    require "wow/Frame-Events";

    require "currying";
    require "Functions";
end;

Callbacks=Callbacks or {};

-- Easy callback for registering OnFoo events, in a more FritoMod-esque fashion.
function Callbacks.Script(frame, event, callback, ...)
    callback=Curry(callback, ...);
    frame:SetScript(event, function(frame, ...)
        callback(...);
    end);
    return Functions.OnlyOnce(function()
        frame:SetScript(event, nil);
    end);
end;
Callbacks.On=Callbacks.Script;

Callbacks.OnEvent=Headless(Callbacks.Script, "OnEvent");
Callbacks.OnUpdate=Headless(Callbacks.Script, "OnUpdate");
