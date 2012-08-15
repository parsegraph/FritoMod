if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
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
    self:AddDestructor(self, "Reset");
    self:AddConnector(Connectors.Global("Undoer", Assets.Undoer()));
end;

function Script:SetContent(content)
    self.content = content;
end;

function Script:GetContent()
    return self.content;
end;

function Script:AddConnector(connector, ...)
    connector = Curry(connector, ...);
    return Lists.Insert(self.connectors, connector);
end;

function Script:Execute()
    self:Reset();
    self.environment = LuaEnvironment:New();
    Lists.CallEach(self.connectors, self.environment);
    self.environment:Run(self.content);
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
