EventDispatcher = setmetatable({}, {
    __call = function(class)
        local staticConnectors = {};
        local staticInitializers = {};
        
        -- Static event connectors are added to every instance of the class
        -- on construction. These are useful if you want class-wide event connectors,
        -- which is usually the case.
        class.AddStaticEventConnector = function(eventName, unappliedFunc, ...)
            unappliedFunc = Unapplied(unappliedFunc, ...);
            eventConnectors = staticConnectors[eventName];
            if not eventConnectors then
                eventConnectors = {};
                staticConnectors[eventName] = eventConnectors;
            end;
            table.insert(eventConnectors, unappliedFunc);
        end;

        -- Static event initializers are added to event instance of the class on
        -- construction. These are useful if you want class-wide event initializers, which
        -- is usually the case.
        class.SetStaticEventInitializer = function(eventName, unappliedFunc, ...)
            unappliedFunc = Unapplied(unappliedFunc, ...);
            staticInitializers[eventName] = unappliedFunc;
        end;

        -- Return the constructor.
        return function(instance, class)
            local initializers = setmetatable({}, {__index = staticInitializers});
            local sanitizers = {};
            local connectorTable = {};
            local listenerTable = {};

            -- When we construct an object, we need to apply all our Unapplied's that we've created
            -- from the staticConnectors. This means that every connector will have self passed as
            -- the first argument.
            for eventName, unappliedConnectors in pairs(staticConnectors) do
                connectors[eventName] = ListUtil:Map(unappliedConnectors, {}, function(unappliedFunc)
                    return unappliedFunc(instance);
                end);
            end;

            -- Event initializers are fired when an event is first registered with this object. For example,
            -- any function that is "forwarding" an event from another source will need to register with that
            -- source, but only needs to do so on demand. An initializer would be used in that case. There may
            -- only be one initializer per event. If no initializer is found, then a default initializer is used
            -- (and may be registered with the eventName of the boolean value true.
            --
            -- Initializers are called with the signature initializer(eventName)
            function instance:SetEventInitializer(eventName, initializerFunc, ...)
                initializers[eventName] = ObjFunc(initializerFunc, ...);
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

            -- Dispatches a event, notifying all listeners registered with it. Every listener is called with
            -- the signature listener(eventName, ...). All return values are ignored, and if a listener
            -- throws, no cleanup is attempted, and the event will not be fired on any remaining listeners.
            function instance:DispatchEvent(eventName, ...)
                local listeners = listenerTable[eventName];
                if not listeners then 
                    return;
                end;
                for _, listener in ipairs(listeners) do
                    listener(eventName, ...);
                end;
            end;

            -- Add a listener for the given eventName. If eventName is a table, this function recurses, using
            -- each element an eventName. listenerFunc should expect the signature listenerFunc(eventName, ...)
            -- where ... is the arguments passed to DispatchEvent. This can also fire when the listener is added
            -- if connectors are available for the given event - these are meant to 'initialize' the listener
            -- immediately, rather than when the event is fired next.
            function instance:AddListener(eventName, listenerFunc, ...)
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
                if #listeners == 0 and initializers[eventName] then
                    local sanitizer = initializers[eventName](self, eventName);
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
                        connector(eventName, listenerFunc);
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
    end
});
