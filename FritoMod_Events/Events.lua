Events = {};
local Events = Events;

local eventListeners;
local initialize = Activator(Noop, function()
    local eventsFrame = CreateFrame("Frame");
    eventListeners = {};
    eventsFrame:SetScript("OnEvent", function(frame, event, ...)
        local listeners = eventListeners[event];
        if listeners then
            Lists.MapCall(listeners, ...);
        end;
    end);
    return function()
        eventsFrame:SetScript("OnEvent", nil);
        eventListeners = nil;
    end;
end);

setmetatable(Events, {
    __index = function(self, key)
        local listeners = {};
        self[key] = Activator(FunctionPopulator(listeners), function()
            local remover = initialize();
            eventListeners[key] = listeners;
            return function()
                eventListeners[key] = nil;
                Events[key] = nil;
                remover();
            end;
        end);
        return rawget(self, key);
    end
});
