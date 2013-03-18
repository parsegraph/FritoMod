-- Represents human-readable information about something.
if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/ListenerList";
end;

Description = OOP.Class();

function Description:Constructor(defaults)
    self.listeners = ListenerList:New();
    self.values = {};
    self:SetDefaults(defaults);
    self:AddDestructor(self, "ClearDefaults");
    self:AddDestructor(self.listeners, "Destroy");
end;

function Description:SetDefaults(defaults)
    if self.defaults == defaults then
        return;
    end;
    self:ClearDefaults();
    self.defaultsRemover = self.defaults:OnUpdate(self, "Update");
    self.defaults = defaults;
    self:Update();
end;

function Description:Fetch(...)
    for i=1, select("#", ...) do
        local propName = select(i, ...);
        local value = self.values[propName];
        if value ~= nil then
            while IsCallable(value) do
                value = value();
            end;
            return value;
        end;
    end;
    if self.defaults then
        return self.defaults:Fetch(...);
    end;
end;

local function Property(propName, ...)
    local Getter = Curry("Fetch", propName, ...);
    Description["Get"..propName] = Getter;
    Description["Set"..propName] = function(self, newValue)
        local oldValue = Getter(self);
        self.values[propName] = newValue;
        if newValue ~= oldValue then
            self:Update();
        end;
    end;
end;

Property("Name");
Property("LongDescription",  "Description",     "ShortDescription", "Name");
Property("Description",      "LongDescription", "ShortDescription", "Name");
Property("ShortDescription", "Description",     "LongDescription",  "Name");
Property("Icon");
Property("Color");

function Description:Update()
    self.listeners:Fire();
end;

function Description:OnUpdate(listener, ...)
    return self.listeners:Add(listener, ...);
end;

function Description:ClearDefaults()
    if self.defaultsRemover then
        self.defaultsRemover();
        self.defaultsRemover = nil;
    end;
end;

-- vim: set et :

