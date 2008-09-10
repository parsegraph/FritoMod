Data = {};
local Data = Data;

function Data:MixinScalar(prototype, name, lowerName, upperName)
    if not lowerName then
        lowerName = string.lower(name);
    end;
    if not upperName then
        upperName = string.upper(name);
    end;
    local eventName = upperName .. "_UPDATE";
    prototype["Get" .. name] = function(self)
        return self[lowerName];
    end;
    prototype["Set" .. name] = function(self, value)
        if self[lowerName] == value then
            return;
        end;
        self[lowerName] = value;
        self:TriggerEvent(eventName, value);
    end;
    prototype:AddStaticEventConnector(eventName, "Get" .. name);
end;

function Data:MixinRange(prototype, name, lowerName, upperName)
    if not lowerName then
        lowerName = string.lower(name);
    end;
    if not upperName then
        upperName = string.upper(name);
    end;
    local currentValue, minValue, maxValue, eventName = 
        "current" .. name, 
        "min" .. name, 
        "max" .. name,
        upperName .. "_UPDATE";
    prototype["Get" .. name] = function(self)
        return self["GetCurrent" .. name](self),
            self["GetMin" .. name](self),
            self["GetMax" .. name](self);
    end;
    prototype["GetCurrent" .. name] = function(self)
        return self[currentValue];
    end;
    prototype["GetMin" .. name] = function(self)
        return self[minValue];
    end;
    prototype["GetMax" .. name] = function(self)
        return self[maxValue];
    end;
    prototype["Set" .. name] = function(self, current, max, min)
        local oldCurrent, oldMin, oldMax = self["Get" .. name](self);
        if oldCurrent == current and oldMin == min and oldMax == max then
            return;
        end;
        self[currentValue] = current;
        self[minValue] = min;
        self[maxValue] = max;
        self:TriggerEvent(eventName, current, max, min);
    end;
    prototype["SetCurrent" .. name] = function(self, current)
        return self["Set" .. name](self, 
            current, 
            self["GetMin" .. name](self), 
            self["GetMax" .. name](self)
        );
    end;
    prototype["SetMin" .. name] = function(self, min)
        return self["Set" .. name](self, 
            self["GetCurrent" .. name](self), 
            min,
            self["GetMax" .. name](self)
        );
    end;
    prototype["SetCurrent" .. name] = function(self, max)
        return self["Set" .. name](self, 
            self["GetCurrent" .. name](self), 
            self["GetMin" .. name](self), 
            max
        );
    end;
    prototype:AddStaticEventConnector(eventName, "Get" .. name);
end;
