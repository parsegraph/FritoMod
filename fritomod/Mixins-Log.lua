if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/log";
end;

Mixins = Mixins or {};

function Mixins.Log(obj)
    obj.debugging = false;

    function obj:setdebug(debugging)
        self.debugging = debugging;
    end;

    function obj:log(...)
        if select("#", ...) == 1 then
            return self:logf(...);
        end;
        return self:logcf(...);
    end;
    obj.logc = obj.log;

    function obj:logf(...)
        self:logcf(nil, ...);
    end;

    function obj:logcf(...)
        Log.Log(self, ...);
    end;

    function obj:logEnter(...)
        if select("#", ...) == 1 then
            return self:logEnterf(...);
        end;
        return self:logEntercf(...);
    end;
    obj.logEnterc = obj.logEnter;

    function obj:logEnterf(...)
        Log.Enter(self, nil, ...);
    end;

    function obj:logEntercf(...)
        Log.Enter(self, ...);
    end;

    function obj:logLeave(...)
        if select("#", ...) > 0 then
            self:log(...);
        end;
        Log.Leave();
    end;

    function obj:logLeavef(...)
        if select("#", ...) > 0 then
            self:logf(...);
        end;
        Log.Leave();
    end;

    function obj:logLeavecf(...)
        if select("#", ...) > 0 then
            self:logcf(...);
        end;
        Log.Leave();
    end;
end;

Logger = OOP.Class("Logger", Mixins.Log);

function Logger:Constructor(name)
    if name then
        function self:ToString()
            return name;
        end;
    end;
end;
