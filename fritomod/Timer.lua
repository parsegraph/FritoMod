if nil ~= require then
	require "fritomod/Timing";
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
end;

Timer = OOP.Class();

function Timer:Constructor(name)
	self.name = name or "Timer";
	self.listeners = ListenerList:New(self.name);
	self.isActive = false;
end;

function Timer:AddListener(listener, ...)
	return self.listeners:Add(listener, ...);
end;

function Timer:CurrentTime()
	return GetTime();
end;

function Timer:SetWithDuration(duration, elapsed)
	duration = Strings.GetTime(duration);
	elapsed = Strings.GetTime(elapsed or 0);
	local start = self:CurrentTime() - elapsed;
	return self:SetWithBounds(start + duration, start);
end;

function Timer:SetWithBounds(lastTime, startTime)
	self.startTime = Strings.GetTime(startTime or self:CurrentTime());
	self.lastTime = Strings.GetTime(lastTime);
	if self.timer then
		self.timer(POISON);
		self.timer = nil;
	end;
	if not self:IsActive() then
		self.isActive = true;
		self:Fire("Active");
	else
		self:Fire("Changed");
	end;
	if self:IsComplete() then
		self:Fire("Complete");
	else
		self.timer = Timing.After(self:Remaining(), self, "Fire", "Complete");
	end;
end;

function Timer:IsActive()
	return self.isActive;
end;

function Timer:IsInactive()
	return not self:IsActive();
end;

function Timer:IsComplete()
	return self:CurrentTime() >= self.lastTime;
end;

function Timer:Duration()
	return self.lastTime - self.startTime;
end;

function Timer:Remaining()
	return self.lastTime - self:CurrentTime();
end;

function Timer:StartTime()
	return self.startTime;
end;

function Timer:LastTime()
	return self.lastTime;
end;

function Timer:Fire(state)
	self.listeners:Fire(state);
end;

function Timer:Destroy(...)
	if self:IsActive() then
		self.isActive = false;
		self.duration = nil;
		self.startTime = nil;
		self:Fire("Inactive");
	end;
end;
