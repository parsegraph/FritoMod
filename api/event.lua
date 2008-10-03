API.Event = LazyMaskInitialize(
    EventDispatcher(), 
    function(self)
        local masterFrame = API.Frame();
        self:SetEventInitializer(true, function(self, eventName)
            if not masterFrame then
                error("There is no master frame for API.Event to register with!");
            end;
            masterFrame:RegisterEvent(eventName);
            return ObjFunc(masterFrame, "UnregisterEvent", eventName);
        end);
    end
);
local Event = API.Event;
