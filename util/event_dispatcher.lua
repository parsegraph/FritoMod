EventDispatcher = function(class)
    local staticConnectors, staticInitializers;

    function Constructor(instance, class)
        local initializers = setmetatable({}, {__index = staticInitializers});
        local sanitizers = {};
        local connectorTable = {};
        local listenerTable = {};
        local forwarders = {};

        if staticConnectors then
            for eventName, connectors in pairs(staticConnectors) do
                connectorTable[eventName] = ListUtil:Clone(connectors);
            end;
        end;

        -- Event initializers are fired when an event is first registered with this object. For example,
        -- any function that is "forwarding" an event from another source will need to register with that
        -- source, but only needs to do so on demand. An initializer would be used in that case. There may
        -- only be one initializer per event. If no initializer is found, then a default initializer is used
        -- (and may be registered with the eventName of the boolean value true.
        --
        -- Initializers are called with the signature initializer(self, eventName)
        function instance:SetEventInitializer(eventName, initializerFunc, ...)
            initializers[eventName] = ObjFunc(initializerFunc, ...);
        end;

        function instance:GetEventInitializer(eventName, excludeDefault)
            local initializerFunc = initializers[eventName];
            if not initializerFunc and not excludeDefault then
                initializerFunc = initializers[true];
            end;
            return initializerFunc;
        end;

        -- Adds a event connector. All connectors are fired when a listener is added to a given
        -- dispatcher. Connectors should expect a signature of connector(self, eventName, listenerFunc)
        -- Notice that the listenerFunc has already been ObjFunc'd, so no extra arguments will be given.
        function instance:AddEventConnector(eventName, connectorFunc, ...)
            local connectors = connectorTable[eventName];
            if not connectors then
                connectors = {};
                connectorTable[eventName] = connectors;
            end;
            table.insert(connectors, ObjFunc(connectorFunc, ...));
        end;

        -- Forwards any event dispatched from this instance to the given function, calling the forwarderFunc
        -- as though it was another event listener.
        function instance:AddForwarder(forwarderFunc, ...)
            forwarderFunc = ObjFunc(forwarderFunc, ...);
            table.insert(forwarders, forwarderFunc);
        end;

        -- Dispatches a event, notifying all listeners registered with it. Every listener is called with
        -- the signature listener(eventName, ...). All return values are ignored, and if a listener
        -- throws, no cleanup is attempted, and the event will not be fired on any remaining listeners.
        function instance:DispatchEvent(eventName, ...)
            local listeners = listenerTable[eventName];
            if listeners then 
                for _, listener in ipairs(listeners) do
                    listener(eventName, ...);
                end;
            end;
            for _, forwarder in ipairs(forwarders) do
                forwarder(eventName, ...);
            end;
        end;

        -- Add a listener for the given eventName. If eventName is a table, this function recurses, using
        -- each element an eventName. listenerFunc should expect the signature listenerFunc(eventName, ...)
        -- where ... is the arguments passed to DispatchEvent. This can also fire when the listener is added
        -- if connectors are available for the given event - these are meant to 'initialize' the listener
        -- immediately, rather than when the event is fired next.
        function instance:AddListener(eventName, listenerFunc, ...)
            if not eventName then
                error("eventName is falsy!");
            end;
            local listenerFunc = ObjFunc(listenerFunc, ...);

            -- If we're batch-adding a listener, recurse and collect all removers.
            if type(eventName) == "table" then
                removers = {}
                local eventList = eventName;
                for _, eventName in ipairs(eventList) do
                    table.insert(removers, self:AddListener(eventName, listenerFunc))
                end
                return function()
                    for i, remover in ipairs(removers) do
                        remover()
                    end
                end;
            end;

            local listeners = listenerTable[eventName];
            if not listeners then
                listeners = {};
                listenerTable[eventName] = listeners;
            end;

            -- If this is the first listener attached to this event, we call any initializer
            -- that's available.
            local initializer = self:GetEventInitializer(eventName);
            if #listeners == 0 and initializer then
                local sanitizer = initializer(self, eventName);
                if sanitizer then
                    sanitizers[eventName] = sanitizer;
                end;
            end;

            -- Actually add the listener into the list of listeners.
            table.insert(listeners, listenerFunc);

            -- Finally, call any connectors we have so that an initial value can be established
            -- for this listener.
            local connectors = connectorTable[eventName];
            if connectors then
                for _, connector in ipairs(connectors) do
                    connector(self, eventName, listenerFunc);
                end;
            end;

            local removed = false;
            -- Return a function that, when called, removes this listener from the list.
            return function()
                -- Allow this function to be safely called multiple times to no effect.
                if removed then
                    return;
                end;
                removed = true;
                -- Remove the listener from our list of listeners.
                for i, candidate in ipairs(listeners) do
                    if candidate == listenerFunc then
                        table.remove(listeners, i);
                        break;
                    end;
                end;
                -- Call the sanitizer if we can safely disconnect this event.
                local sanitizer = sanitizers[eventName];
                if sanitizer and #listeners == 0 then
                    sanitizer();
                end;
            end;
        end;
    end;

    if class then
        staticInitializers = {};
        staticConnectors = {};

        -- Static event connectors are added to every instance of the class
        -- on construction. These are useful if you want class-wide event connectors,
        -- which is usually the case.
        class.AddStaticEventConnector = function(eventName, connectorFunc, ...)
            connectorFunc = ObjFunc(connectorFunc, ...);
            eventConnectors = staticConnectors[eventName];
            if not eventConnectors then
                eventConnectors = {};
                staticConnectors[eventName] = eventConnectors;
            end;
            table.insert(eventConnectors, connectorFunc);
        end;

        -- Static event initializers are added to event instance of the class on
        -- construction. These are useful if you want class-wide event initializers, which
        -- is usually the case.
        class.SetStaticEventInitializer = function(eventName, initializerFunc, ...)
            initializerFunc = ObjFunc(initializerFunc, ...);
            staticInitializers[eventName] = initializerFunc;
        end;
        return Constructor;
    else
        -- We're creating an EventDispatcher independently of any class.
        local instance = {};
        Constructor(instance);
        return instance;
    end;
end;
