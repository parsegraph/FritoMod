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
Hack.Toolbox = OOP.Class();
local Toolbox = Hack.Toolbox;

function Toolbox:Constructor()
    self.scripts = {};
    self.listeners = ListenerList:New();
end;

function Toolbox:AddScript(name, script)
    self.scripts[name] = script;
    self:Fire();
    return Functions.OnlyOnce(self, "RemoveScript", name);
end;

function Toolbox:RenameScript(name, newName)
    if name == newName then
        return;
    end;
    self.scripts[newName] = self.scripts[name];
    self.scripts[name] = nil;
    self:Fire();
    print(unpack(Tables.Keys(self.scripts)));
end;

function Toolbox:RemoveScript(name)
    self.scripts[name] = nil;
    self:Fire();
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

function Toolbox:Fire(...)
    self.listeners:Fire(...);
end;

function Toolbox:OnChange(func, ...)
    return self.listeners:Add(func, ...);
end;
