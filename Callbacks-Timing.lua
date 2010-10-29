if nil ~= require then
    require "Callbacks";
    require "Timing";
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
