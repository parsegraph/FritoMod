EventDispatcher = AceLibrary("AceOO-2.0").Mixin{
    "TriggerEvent", "AddListener", 
    "AddEventConnector", "InitEventConnectors", "GetEventConnector"
};
local EventDispatcher = EventDispatcher;

function EventDispatcher.MixinStaticEventConnectors(prototype)
    local connectors = prototype.staticEventConnectors;
    if not connectors then
        connectors = {};
        prototype.staticEventConnectors = connectors;
    end;
    prototype["AddStaticEventConnector"] = function(eventName, unappliedFunc, ...)
        local unappliedFunc = Unapplied(unappliedFunc, ...);
        connectors[eventName] = unappliedFunc;
    end;
    prototype["ApplyStaticEventConnectors"] = function(self)
        for eventName, unappliedFunc in pairs(connectors) do
            self:AddConnector(unappliedFunc(self));
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Connector Methods
--
-------------------------------------------------------------------------------

function EventDispatcher:InitEventConnectors()
    self.prototype.class.ApplyStaticEventConnectors(self);
end;

function EventDispatcher:AddEventConnector(eventName, connectorFunc, ...)
    connectorFunc = ObjFunc(connectorFunc, ...);
    if not self.eventConnectors then 
        self.eventConnectors = {};
    end;
    self.eventConnectors[eventName] = connectorFunc;
end;

function EventDispatcher:GetEventConnector(eventName)
    if self.eventConnectors then
        return self.eventConnectors[eventName];
    end;
end;

-------------------------------------------------------------------------------
--
--  Listener Methods
--
-------------------------------------------------------------------------------

function EventDispatcher:TriggerEvent(eventName, ...)
    if not self.events then
        return;
    end;
    local eventList = self.events[eventName];
    if not eventList then
        return;
    end;
    for listener in eventList:Iter() do
        listener(eventName, ...);
    end;
end;

function EventDispatcher:AddListener(eventName, listenerFunc, ...)
	if not self.events then
		self.events = {};
	end;
    listenerFunc = ObjFunc(listenerFunc, ...);
    if type(eventName) == "table" then
        -- We're using the same listener for multiple events, so recurse and collect.
        removers = {}
        local eventList = eventName
        for i, eventName in ipairs(eventList) do
            table.insert(removers, self:AddListener(eventName, listenerFunc))
        end
        return function()
            for i, remover in ipairs(removers) do
                remover()
            end
        end;
    end;
    local eventList = self.events[eventName];
    if not eventList then
        eventList = List:new();
        self.events[eventName] = eventList;
    end;
    if eventList:Add(listenerFunc) then
        connectorFunc = self:GetEventConnector(eventName);
        if connectorFunc then
            listenerFunc(eventName, connectorFunc());
        end;
    end;
    return function()
        eventList:Remove(listenerFunc);
    end;
end;
