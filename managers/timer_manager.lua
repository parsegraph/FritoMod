TimerManager = {
  timers = {},
};
local TimerManager = TimerManager;

function TimerManager:GetCurrentTime()
  return GetTime();
end;

function TimerManager:RegisterTimer(timerFunc)
  self.timers[timerFunc] = GetTime();
  if not self.lastIteration then
    self.lastIteration = self:GetCurrentTime();
  end;
end;

function TimerManager:UnregisterTimer(timerFunc)
  table.remove(self.timers, timerFunc);
end;

function TimerManager:OnUpdate()
  local currentTime = self:GetCurrentTime();
  for timerFunc, startTime in ipairs(self.timers) do
    timerFunc(currentTime - startTime, currentTime - self.lastIteration);
  end;
  self.lastIteration = currentTime;
end;
