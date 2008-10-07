IterationManager = OOP.Class(EventDispatcher, ComponentSingleton);
local IterationManager = IterationManager;

IterationManager.events = {
    UPDATE = "update",
    PREPROCESS = "preprocess",
    POSTPROCESS = "postprocess"
};

IterationManager.FRAMERATE = .05;

function IterationManager:__Init()
    self.timers = {};
end;

-- Perform one complete iteration. These events should always be called together, in this order, and
-- only from this function.
function IterationManager:Iterate()
	self:DispatchEvent(IterationManager.events.PREPROCESS);
	self:DispatchEvent(IterationManager.events.UPDATE);
	self:DispatchEvent(IterationManager.events.POSTPROCESS);
end;

function IterationManager:CallPeriodically(granularity, periodicFunc, ...)
    -- Granularity is optional, though it does complicate this workflow to have to check
    -- if it was passed.
    if type(granularity) ~= "number" then
        periodicFunc = ObjFunc(granularity, periodicFunc, ...);
        granularity = nil;
    else
        periodicFunc = ObjFunc(periodicFunc, ...);
    end;
    -- Last and first iterations for the timer here will be set on the first iteration.
    local timer = {
        periodicFunc = periodicFunc,
        granularity = granularity or 0,
        lastIteration = 0,
        firstIteration = 0,
    };
    table.insert(self.timers, timer);
    -- Return the function used to remove this periodic function.
    return function()
        for i, candidate in ipairs(self.timers) do
            if candidate == timer then
                table.remove(self.timers, i);
                return;
            end;
        end;
    end;
end;

function IterationManager:IterateTimers()
    local currentTime = API:GetCurrentTime();
    for _, timer in pairs(self.timers) do
        if not timer.lastIteration then
            timer.lastIteration = currentTime;
            timer.firstIteration = currentTime;
        end
        if not timer.granularity or timer.lastIteration + timer.granularity < currentTime then
            timer.periodicFunc(
                currentTime - timer.firstIteration, 
                currentTime - timer.lastIteration
            );
            timer.lastIteration = currentTime;
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Convenience Attachment Methods
-- 
-------------------------------------------------------------------------------

Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    return API.Event:AddFrameListener(API.Frame.events.UPDATE, function()
        IterationManager:GetInstance():Iterate();
    end);
end);

-------------------------------------------------------------------------------
--
--  Convenience Methods: EventDispatcher
-- 
-------------------------------------------------------------------------------

function IterationManager:AddPreprocessor(listenerFunc, ...)
	return self:AddListener(IterationManager.events.PREPROCESS, listenerFunc, ...);
end;

function IterationManager:AddIterator(listenerFunc, ...)
	return self:AddListener(IterationManager.events.UPDATE, listenerFunc, ...);
end;

function IterationManager:AddPostprocessor(listenerFunc, ...)
	return self:AddListener(IterationManager.events.POSTPROCESS, listenerFunc, ...);
end;
