TimerManager = {
  timers = {},
};
local TimerManager = TimerManager;

function TimerManager:GetCurrentTime()
  return GetTime();
end;

function TimerManager:RegisterTimer(timerFunc, granularity)
    if not granularity then
        granularity = 0
    end
    self.timers[timerFunc] = {
        func = timerFunc,
        granularity = granularity,
        firstIteration = nil,
        lastIteration = nil,
    }
end;

function TimerManager:UnregisterTimer(timerFunc)
    table.remove(self.timers, timerFunc);
end;

function TimerManager:OnUpdate()
    local currentTime = self:GetCurrentTime();
    for i, timer in ipairs(self.timers) do
        if not timer.lastIteration then
            timer.lastIteration = currentTime
            timer.firstIteration = currentTime
        end
        if not timer.granularity or timer.lastIteration + timer.granularity >= currentTime then
            timer.func(currentTime - timer.firstIteration, currentTime - timer.lastIteration)
            timer.lastIteration = currentTime
        end;
    end;
end;
