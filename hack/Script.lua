if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
    require "fritomod/LuaEnvironment";
    require "fritomod/Lists";
    require "hack/Assets";
end;

Hack = Hack or {};
Hack.Script = OOP.Class();
local Script = Hack.Script;

function Script:Constructor()
    self.connectors = {};
    self.content = "";
    self:AddDestructor(function()
        if self.environment then
            self.environment:Destroy();
            self.environment = nil;
        end;
    end);
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
    if self.environment then
        return;
    end;
    self.environment = LuaEnvironment:New();
    self.environment:Set("Undoer", Curry(self, "AddDestructor"));
    Lists.CallEach(self.connectors, self.environment);
    self.environment:Run(self.content);
end;

function Script:GetEnvironment()
    return self.environment;
end;
