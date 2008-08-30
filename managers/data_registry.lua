DataRegistry = {
    listeners     = List:new(),
    dataProviders = List:new(),
};
local DataRegistry = DataRegistry;

DataRegistry.listeners.DoRemove = function(listener)
    listener:DetachAll();
end;

-------------------------------------------------------------------------------
--
--  Data Provider Methods
-- 
-------------------------------------------------------------------------------

local function AttemptDataProviderConnection(dataProvider, listener)
    for tagName, tagValue in listener:IterTags() do
        if dataProvider:GetTag(tagName) ~= tagValue then
            return;
        end;
    end;
    listener:Attach(dataProvider);
end

local function ConnectDataProvider(self, dataProvider)
    for listener in self:IterListeners() do
        AttemptDataProviderConnection(dataProvider, listener);
    end;
end;

-- function DataRegistry:RegisterDataProvider(dataProvider)
-- Adds a DataProvider to the registry. Once added, any listeners will be 
-- notified via a registered listener. 
--
-- Whether a listener is notified is conditional on how it was registered.
--
-- This function is idempotent.

function DataRegistry:RegisterDataProvider(dataProvider)
    for tagName, _ in dataProvider:IterTags() do
        local providers = self.dataProviders[tagName];
        if not providers then
            providers = List:new();
            self.dataProviders[tagName] = providers;
        end;
        if providers:Add(dataProvider) then
            -- It was successfully added, so connect it to all registered listeners who will
            -- accept it. Also add a listener so that when its END event is fired, it is automatically
            -- unregistered.
            ConnectDataProvider(self, dataProvider);
            dataProvider:AddListener(DataProvider.events.END, "UnregisterDataProvider", self);
        end;
    end;
end;

-- function DataRegistry:UnregisterDataProvider(dataProvider)
-- Removes a DataProvider from our registry, assuming one is found.
-- This will not remove any listeners that have been added to it.
function DataRegistry:UnregisterDataProvider(dataProvider)
    for tagName in dataProvider:IterTags() do
        local providers = self.dataProviders[tagName];
        if providers then
            providers:Remove(dataProvider);
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Data Listener Methods
-- 
-------------------------------------------------------------------------------

-- Creates and adds a DataListener to the DataRegistry, attaching all acceptable
-- DataProviders to it that are currently registered, and are registered in the future until
-- the DataListener is removed.
--
-- This function is NOT idempotent, so be sure to call it only when you want to add
-- a function and are positive it does not already exist.
function DataRegistry:AddListener(tags, listenerFunc, listenerSelf)
    listener = DataListener:new(tags, listenerFunc, listenerSelf)
    self.listeners:Add(listener);
    local index = self.listeners:Length();
    -- A listener was added, so send it all the DataProviders it would like to listen to.
    local candidates;
    for tagName, tagValue in listener:IterTags() do
        if not candidates then
            local providers = self.dataProviders[tagName];
            if providers then
                candidates = List:new();
                candidates:AddAll(providers:GetValues());
            end;
        else
            debug(candidates:Length(), tagName);
            -- Remove any candidate DataProviders whose tagValue doesnt match ours.
            candidates:Filter(function(dataProvider) 
                return dataProvider:GetTag(tagName) == tagValue;
            end);
        end;
    end;
    if candidates then
        for dataProvider in candidates:Iter() do
            listener:Attach(dataProvider);
        end;
    end;
    -- Returns a function to remove this listener.
    return function()
        DataRegistry.listeners:RemoveAt(index);
    end;
end;

function DataRegistry:IterListeners()
    return self.listeners:Iter();
end;
