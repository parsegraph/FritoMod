API.Event = LazyMaskInitialize(
    EventDispatcher(), 
    function(self)
        local masterFrame = API.Frame();
        self:SetEventInitializer(true, function(self, eventName)
            if not masterFrame then
                error("There is no master frame for API.Event to register with!");
            end;
            masterFrame:GetFrame():RegisterEvent(eventName);
            return ObjFunc(masterFrame, "UnregisterEvent", eventName);
        end);
        masterFrame:AddForwarder(self, "DispatchEvent");
    end
);
local Event = API.Event;
