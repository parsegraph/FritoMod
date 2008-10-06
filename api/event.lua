API.Event = TableUtil:LazyInitialize(
    EventDispatcher(), 
    function(self)
        local masterFrame = API.Frame();
        self:SetEventInitializer(true, function(self, eventName)
            if not masterFrame then
                error("AssertionError: There is no master frame for API.Event to register with.");
            end;
            masterFrame:GetFrame():RegisterEvent(eventName);
            return ObjFunc(masterFrame, "UnregisterEvent", eventName);
        end);
        masterFrame:AddForwarder(self, "DispatchEvent");

        function self:AddFrameListener(widgetEvent, listenerFunc, ...)
            return masterFrame:AddListener(widgetEvent, listenerFunc, ...);
        end;
    end
);
local Event = API.Event;
