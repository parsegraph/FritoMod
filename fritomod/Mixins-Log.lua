if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/Log";
end;

Mixins = Mixins or {};

function Mixins.Log(self)
    if OOP.IsClass(self) then
        Log.Entercf(self, "Log mixin constructions", "Adding logging mixin to class.");
    else
        Log.Entercf(self, "Log mixin constructions", "Adding logging mixin to instance.");
    end;

    function self:log(...)
        if select("#", ...) == 1 then
            return self:logf(...);
        end;
        return self:logcf(...);
    end;
    self.logc = self.log;

    function self:logf(...)
        self:logcf(nil, ...);
    end;

    function self:logcf(...)
        Log.Log(self, ...);
    end;

    function self:logEnter(...)
        if select("#", ...) == 1 then
            return self:logEnterf(...);
        end;
        return self:logEntercf(...);
    end;
    self.logEnterc = self.logEnter;

    function self:logEnterf(...)
        Log.Enter(self, nil, ...);
    end;

    function self:logEntercf(...)
        Log.Enter(self, ...);
    end;

    function self:logLeave(...)
        if select("#", ...) > 0 then
            self:log(...);
        end;
        Log.Leave();
    end;

    function self:logLeavef(...)
        if select("#", ...) > 0 then
            self:logf(...);
        end;
        Log.Leave();
    end;

    function self:logLeavecf(...)
        if select("#", ...) > 0 then
            self:logcf(...);
        end;
        Log.Leave();
    end;

    Log.Leave();
end;

Logger = OOP.Class("Logger", Mixins.Log);

function Logger:Constructor(name)
    if name then
        function self:ToString()
            return name;
        end;
    end;
end;
