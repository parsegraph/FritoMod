if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
    require "fritomod/ListenerList";
    require "fritomod/Lists";
    require "fritomod/Tables";
    require "hack/Assets";
    require "hack/Connectors";
end;

Hack = Hack or {};
Hack.Toolbox = OOP.Class("Hack.Toolbox");
local Toolbox = Hack.Toolbox;

function Toolbox:Constructor()
    self.scripts = {};
    self.listeners = ListenerList:New();
end;

function Toolbox:AddScript(name, script)
    self.scripts[name] = script;
    self:FireUpdate();
    return Functions.OnlyOnce(self, "RemoveScript", name);
end;

function Toolbox:RenameScript(name, newName)
    if name == newName then
        return;
    end;
    assert(not self.scripts[newName],
        "Destination name '" .. tostring(newName) .. "' must not be in use"
    );
    self.scripts[newName] = self.scripts[name];
    self.scripts[name] = nil;
    self:FireUpdate();
    print(unpack(Tables.Keys(self.scripts)));
end;

function Toolbox:RemoveScript(name)
    self.scripts[name] = nil;
    self:FireUpdate();
end;

function Toolbox:GetScripts()
    return self.scripts;
end;

function Toolbox:GetScript(name)
    return self.scripts[name];
end;

function Toolbox:NameFor(script)
    return Tables.KeyFor(self.scripts, script);
end;

function Toolbox:FireUpdate(...)
    self.listeners:Fire(...);
end;

function Toolbox:OnUpdate(func, ...)
    return self.listeners:Add(func, ...);
end;
