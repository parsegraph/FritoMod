if nil ~= require then
    require "FritoMod_Functional/Callbacks";
    require "FritoMod_Timing/Timing";
end;

Callbacks=Callbacks or {};

function Callbacks.Later(func, ...)
    func=Curry(func, ...);
    local remover;
    remover=Timing.OnUpdate(function()
        func();
        remover();
    end);
end;
