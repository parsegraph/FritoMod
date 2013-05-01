if nil ~= require then
    require "fritomod/currying";
    require "fritomod/OOP-Class";
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

    self:AddConnector(Connectors.Global("Undoer", Assets.Undoer()));
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

function Script:Execute(env, ...)
    assert(env, "Environment must not be falsy");
    Lists.CallEach(self.connectors, env);
    return env:Run(self.content, ...);
end;

function Script:OnChange(func, ...)
    return self.listeners:Add(func, ...);
end;

function Script:FireUpdate()
    if not self.listeners:IsFiring() then
        self.listeners:Fire();
    end;
end;
