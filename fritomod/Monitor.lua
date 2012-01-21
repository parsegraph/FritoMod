if nil ~= require then
	require "fritomod/Timing";
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ImmediateToggleDispatcher";
	require "fritomod/StateDispatcher";
end;

Monitor = OOP.Class(StateDispatcher);

function Monitor:Constructor(name)
	Monitor.super.Constructor(self, "Inactive", name or "Monitor");
end;

function Monitor:CurrentTime()
	return GetTime();
end;

function Monitor:SetWithDuration(duration, elapsed)
	duration = Strings.GetTime(duration);
	elapsed = Strings.GetTime(elapsed or 0);
	local start = self:CurrentTime() - elapsed;
	return self:SetWithBounds(start + duration, start);
end;

function Monitor:SetWithBounds(lastTime, startTime)
	lastTime = Strings.GetTime(lastTime);
	startTime = Strings.GetTime(startTime or self:CurrentTime());
	if self.startTime == startTime and self.lastTime == lastTime then
		return;
	end;
	self.startTime = startTime;
	self.lastTime = lastTime;
	if self.timer then
		self.timer(POISON);
		self.timer = nil;
	end;
	trace("Activating monitor %q", self.name);
	self:Fire("Active");
	if self:Completed() >= self:Duration() then
		trace("Firing completed event for monitor %q", self.name);
		self:Fire("Completed");
	else
		self.timer = Timing.After(self:Remaining(), self, "Fire", "Completed");
	end;
end;

function Monitor:SetCompleted()
	self:SetWithBounds(self:CurrentTime(), self:CurrentTime());
end;

function Monitor:SetValue(value)
	self.value = value;
	self:Refire();
end;

function Monitor:Value()
	return self.value;
end;

function Monitor:Delay(magnitude)
	magnitude = Strings.GetTime(magnitude);
	self:SetWithBounds(self:LastTime() + magnitude, self:StartTime());
end;

function Monitor:Reduce(magnitude)
	magnitude = Strings.GetTime(magnitude);
	self:SetWithBounds(self:LastTime() - magnitude, self:StartTime());
end;

function Monitor:Reset()
	self:SetWithBounds(self:Duration() + self:CurrentTime(), self:CurrentTime());
end;

function Monitor:IsActive()
	return self:State() == "Active";
end;

function Monitor:IsInactive()
	return self:State() == "Inactive";
end;

function Monitor:IsCompleted()
	return self:State() == "Completed";
end;

function Monitor:Duration()
	return self.lastTime - self.startTime;
end;

function Monitor:Completed()
	if self:IsActive() then
		return math.min(self:Duration(), self:CurrentTime() - self.startTime);
	elseif self:IsCompleted() then
		return self:Duration();
	elseif self:IsInactive() then
		return 0;
	end;
end;

function Monitor:Remaining()
	return math.max(0, self.lastTime - self:CurrentTime());
end;

function Monitor:PercentCompleted()
	return 1 - self:PercentRemaining();
end;

function Monitor:PercentRemaining()
	if self:Duration() and self:Remaining() then
		return self:Remaining() / self:Duration();
	end;
	return 1;
end;

function Monitor:Interpolate(first, last)
	if self:IsCompleted() then
		return last;
	end;
	if not self:IsActive() then
		return first;
	end;
	return first + ((last - first) * self:PercentCompleted());
end;

function Monitor:StartTime()
	return self.startTime;
end;

function Monitor:LastTime()
	return self.lastTime;
end;

function Monitor:Destroy(...)
	self.duration = nil;
	self.startTime = nil;
	self:SafeFire("Inactive");
end;
