EventDispatcher = OOP.Mixin(
    function(class)
        OOP.IntegrateLibrary(EventDispatcher, class);
        local connectors = {};
        class.AddStaticEventConnector = function(eventName, unappliedFunc, ...)
            unappliedFunc = Unapplied(unappliedFunc, ...);
            eventConnectors = connectors[eventName];
            if not eventConnectors then
                eventConnectors = {};
                connectors[eventName] = eventConnectors;
            end;
            table.insert(eventConnectors, unappliedFunc);
        end;
        return function(self, class)
            for eventName, unappliedConnectors in pairs(connectors) do
                for _, unappliedFunc in ipairs(unappliedConnectors) do
                    self:AddEventConnector(eventName, unappliedFunc(self));
                end;
            end;
        end;
    end
);
local EventDispatcher = EventDispatcher;

-------------------------------------------------------------------------------
--
--  EventConnector Methods
--  These methods are used to initialize a event listener when it's first connected.
--  A "event connector" should be some function used to retrieve the value of that
--  event, in the form that the event listener would expect.
--
--  A related example is with ActionScript's data-binding, where on the first connection,
--  the data is bound.
-------------------------------------------------------------------------------

function EventDispatcher:AddEventConnector(eventName, connectorFunc, ...)
    connectorFunc = ObjFunc(connectorFunc, ...);
    if not self.eventConnectors then 
        self.eventConnectors = {};
    end;
    local connectors = self.eventConnectors[eventName];
    if not connectors then
        connectors = { connectorFunc };
        self.eventConnectors = connectors;
    else
        table.insert(connectors, connectorFunc);
    end;
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
        eventList = List();
        self.events[eventName] = eventList;
    end;
    if eventList:Add(listenerFunc) then
        local connectors = self:GetEventConnector(eventName);
        if connectors then
            for _, connector in ipairs(connectors) do
                connector(eventName, listenerFunc);
            end;
        end;
    end;
    return function()
        eventList:Remove(listenerFunc);
    end;
end;
