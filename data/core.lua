Data = {};
local Data = Data;

function Data:MixinScalar(class, properName, lowerName, upperName)
    lowerName = lowerName or string.lower(properName);
    upperName = upperName or string.upper(properName);
    local eventName = upperName .. "_UPDATE";
    class["Get" .. properName] = function(self)
        return self[lowerName];
    end;
    class["Set" .. properName] = function(self, value)
        if self[lowerName] == value then
            return;
        end;
        self[lowerName] = value;
        self:DispatchEvent(eventName, value);
    end;
    class:AddStaticEventConnector(eventName, function(self, eventName, listenerFunc)
        listenerFunc(eventName, self["Get" .. properName](self));
    end);
end;

function Data:MixinRange(class, properName, lowerName, upperName)
    if not lowerName then
        lowerName = string.lower(properName);
    end;
    if not upperName then
        upperName = string.upper(properName);
    end;
    local currentValue, minValue, maxValue, eventName = 
        "current" .. properName, 
        "min" .. properName, 
        "max" .. properName,
        upperName .. "_UPDATE";
    class["Get" .. properName] = function(self)
        return self["GetCurrent" .. properName](self),
            self["GetMin" .. properName](self),
            self["GetMax" .. properName](self);
    end;
    class["GetCurrent" .. properName] = function(self)
        return self[currentValue];
    end;
    class["GetMin" .. properName] = function(self)
        return self[minValue];
    end;
    class["GetMax" .. properName] = function(self)
        return self[maxValue];
    end;
    class["Set" .. properName] = function(self, current, max, min)
        local oldCurrent, oldMin, oldMax = self["Get" .. properName](self);
        if oldCurrent == current and oldMin == min and oldMax == max then
            return;
        end;
        self[currentValue] = current;
        self[minValue] = min;
        self[maxValue] = max;
        self:DispatchEvent(eventName, current, max, min);
    end;
    class["SetCurrent" .. properName] = function(self, current)
        return self["Set" .. properName](self, 
            current, 
            self["GetMin" .. properName](self), 
            self["GetMax" .. properName](self)
        );
    end;
    class["SetMin" .. properName] = function(self, min)
        return self["Set" .. properName](self, 
            self["GetCurrent" .. properName](self), 
            min,
            self["GetMax" .. properName](self)
        );
    end;
    class["SetCurrent" .. properName] = function(self, max)
        return self["Set" .. properName](self, 
            self["GetCurrent" .. properName](self), 
            self["GetMin" .. properName](self), 
            max
        );
    end;
    class:AddStaticEventConnector(eventName, function(self, eventName, listenerFunc)
        listenerFunc(eventName, self["Get" .. properName](self));
    end);
end;
