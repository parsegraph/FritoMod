API.Event = LazyMaskInitialize(
    EventDispatcher(), 
    function(self)
        self.masterFrame = API.Frame();
        self:SetEventInitializer(true, function(self, eventName)
            self.masterFrame:RegisterEvent(eventName);
            return ObjFunc(self.masterFrame, "UnregisterEvent", eventName);
        end);
    end
);
local Event = API.Event;
