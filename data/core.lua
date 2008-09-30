Data = {};
local Data = Data;

function Data:MixinScalar(class, name, lowerName, upperName)
    if not lowerName then
        lowerName = string.lower(name);
    end;
    if not upperName then
        upperName = string.upper(name);
    end;
    local eventName = upperName .. "_UPDATE";
    class["Get" .. name] = function(self)
        return self[lowerName];
    end;
    class["Set" .. name] = function(self, value)
        if self[lowerName] == value then
            return;
        end;
        self[lowerName] = value;
        self:TriggerEvent(eventName, value);
    end;
    -- These event connectors are Unapplied, since they have no current
    -- 'self' they can immediately refer to.
    class:AddStaticEventConnector(eventName, function(self, eventName, listenerFunc)
        listenerFunc(self["Get" .. name](self));
    end);
end;

function Data:MixinRange(class, name, lowerName, upperName)
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
    class["Get" .. name] = function(self)
        return self["GetCurrent" .. name](self),
            self["GetMin" .. name](self),
            self["GetMax" .. name](self);
    end;
    class["GetCurrent" .. name] = function(self)
        return self[currentValue];
    end;
    class["GetMin" .. name] = function(self)
        return self[minValue];
    end;
    class["GetMax" .. name] = function(self)
        return self[maxValue];
    end;
    class["Set" .. name] = function(self, current, max, min)
        local oldCurrent, oldMin, oldMax = self["Get" .. name](self);
        if oldCurrent == current and oldMin == min and oldMax == max then
            return;
        end;
        self[currentValue] = current;
        self[minValue] = min;
        self[maxValue] = max;
        self:TriggerEvent(eventName, current, max, min);
    end;
    class["SetCurrent" .. name] = function(self, current)
        return self["Set" .. name](self, 
            current, 
            self["GetMin" .. name](self), 
            self["GetMax" .. name](self)
        );
    end;
    class["SetMin" .. name] = function(self, min)
        return self["Set" .. name](self, 
            self["GetCurrent" .. name](self), 
            min,
            self["GetMax" .. name](self)
        );
    end;
    class["SetCurrent" .. name] = function(self, max)
        return self["Set" .. name](self, 
            self["GetCurrent" .. name](self), 
            self["GetMin" .. name](self), 
            max
        );
    end;
    class:AddStaticEventConnector(eventName, function(self, eventName, listenerFunc)
        listenerFunc(self["Get" .. name](self));
    end);
end;
