if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
    require "fritomod/ListenerList";
    require "fritomod/Lists";
    require "hack/Assets";
    require "hack/Connectors";
end;

Hack = Hack or {};
Hack.Script = OOP.Class();
local Script = Hack.Script;
local Assets = Hack.Assets;
local Connectors = Hack.Connectors;

function Script:Constructor()
    self.connectors = {};
    self.content = "";
    self.listeners = ListenerList:New();

    self.commands = {};
    self.commandRemovers = {};

    self:AddDestructor(self, "Reset");
    self:AddConnector(Connectors.Global("Undoer", Assets.Undoer()));
end;

function Script:SetCommandParser(parser, ...)
    self.parser = Curry(parser, ...);
end;

function Script:AddCommand(command)
    if Lists.ContainsValue(self.commands, command) then
        return;
    end;
    self.commandRemovers[command] = self.parser(self, command);
    table.insert(self.commands, command);
    self:FireUpdate();
    return Functions.OnlyOnce(self, "RemoveCommand", command);
end;

function Script:RemoveCommand(command)
    local r = self.commandRemovers[command];
    if r then
        r();
        self.commandRemovers[command] = nil;
    end;
    self:FireUpdate();
    Lists.Remove(self.commands, command);
end;

function Script:GetCommands()
    return self.commands;
end;

function Script:SetContent(content)
    if self.content == content then
        return;
    end;
    self.content = content;
    self:FireUpdate();
end;

function Script:GetContent()
    return self.content;
end;

function Script:AddConnector(connector, ...)
    connector = Curry(connector, ...);
    local rv = Lists.Insert(self.connectors, connector);
    self:FireUpdate();
    return rv;
end;

function Script:Execute(...)
    self:Reset();
    self.environment = LuaEnvironment:New();
    Lists.CallEach(self.connectors, self.environment);
    return self.environment:Run(self.content, ...);
end;

function Script:Reset()
    if not self.environment then
        return;
    end;
    self.environment:Destroy();
    self.environment = nil;
end;

function Script:GetEnvironment()
    return self.environment;
end;

function Script:OnChange(func, ...)
    return self.listeners:Add(func, ...);
end;

function Script:FireUpdate()
    if not self.listeners:IsFiring() then
        self.listeners:Fire();
    end;
end;
