if nil ~= require then
	require "wow/Frame";

	require "fritomod/basic";
	require "fritomod/Lists";
end;

local Frame=WoW.Frame;

Frame:AddConstructor(function(self)
    self.eventHandlers={};
end);

function Frame:HasScript(event)
    return true;
end;

function Frame:GetHandlers(event)
    if not self:HasScript(event) then
        return;
    end;
    local handlers=self.eventHandlers[event];
    if not handlers then
        handlers={
            hooks={}
        };
        self.eventHandlers[event]=handlers;
    end;
    return handlers;
end;

function Frame:GetScript(event)
    local handlers=self:GetHandlers(event);
    if handlers then
        return handlers.handler;
    end;
end;

function Frame:SetScript(event, handler)
    local handlers=self:GetHandlers(event);
    if handlers then
        handlers.handler=handler;
    end;
end;

function Frame:HookScript(event, handler)
    local handlers=self:GetHandlers(event);
    if handlers then
        table.insert(handlers.hooks, handler);
    end;
end;

function Frame:FireEvent(event, ...)
    local handlers=self:GetHandlers(event);
    if handlers then
        if handlers.handler then
            handlers.handler(self, event, ...);
        end;
        Lists.CallEach(handlers.hooks, self, event, ...);
    end;
end;

function Frame:EnableMouse(enabled)
    -- XXX What does this function do in-game?
end;

function Frame:IsEventRegistered(event)
    local handlers=self:GetHandlers(event);
    return handlers and handlers.registered;
end;

function Frame:RegisterEvent(event)
    local handlers=self:GetHandlers(event);
    if handlers then
        handlers.registered=true;
    end;
end;

function Frame:UnregisterEvent(event)
    local handlers=self:GetHandlers(event);
    if handlers then
        handlers.registered=false;
    end;
end;
