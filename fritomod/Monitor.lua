if nil ~= require then
	require "fritomod/Timing";
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ImmediateToggleDispatcher";
end;

Monitor = OOP.Class();

function Monitor:Constructor(name)
	self.name = name or "Monitor";
	self.listeners = ListenerList:New(self.name);

	self.activators = ImmediateToggleDispatcher:New(self.name);

	self.activators:AddInstaller(function(self)
		return self.listeners:Add(function(self, state)
			if state == "Active" then
				trace("Firing activators for monitor %q", self.name);
				self.activators:Fire();
			elseif state == "Complete" or state == "Inactive" then
				trace("Firing resetters for monitor %q", self.name);
				self.activators:Reset();
			end;
		end, self);
	end, self);

	self.isActive = false;
end;

function Monitor:AddInstaller(installer, ...)
	return self.listeners:AddInstaller(installer, ...);
end;

function Monitor:StateListener(listener, ...)
	return self.listeners:Add(listener, ...);
end;

function Monitor:OnActivate(listener, ...)
	return self.activators:Add(listener, ...);
end;

function Monitor:OnDeactivate(listener, ...)
	return self:OnActivate(Functions.ReverseUndoable(listener, ...));
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
	if not self:IsActive() then
		self.isActive = true;
		trace("Activating monitor %q", self.name);
		self:Fire("Active");
	else
		trace("Firing changed event for monitor %q", self.name);
		self:Fire("Changed");
	end;
	if self:IsComplete() then
		trace("Firing complete event for monitor %q", self.name);
		self:Fire("Complete");
	else
		self.timer = Timing.After(self:Remaining(), self, "Fire", "Complete");
	end;
end;

function Monitor:SetValue(value)
	self.value = value;
	self:Fire("Changed");
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
	return self.isActive;
end;

function Monitor:IsInactive()
	return not self:IsActive();
end;

function Monitor:IsComplete()
	return self:CurrentTime() >= self.lastTime;
end;

function Monitor:Duration()
	return self.lastTime - self.startTime;
end;

function Monitor:Remaining()
	return math.max(0, self.lastTime - self:CurrentTime());
end;

function Monitor:PercentComplete()
	return 1 - self:PercentRemaining();
end;

function Monitor:PercentRemaining()
	if self:Duration() and self:Remaining() then
		return self:Remaining() / self:Duration();
	end;
	return 1;
end;

function Monitor:Interpolate(first, last)
	if self:IsComplete() then
		return last;
	end;
	if not self:IsActive() then
		return first;
	end;
	return first + ((last - first) * self:PercentComplete());
end;

function Monitor:StartTime()
	return self.startTime;
end;

function Monitor:LastTime()
	return self.lastTime;
end;

function Monitor:Fire(state)
	self.listeners:Fire(state);
end;

function Monitor:Destroy(...)
	if self:IsActive() then
		self.isActive = false;
		self.duration = nil;
		self.startTime = nil;
		self:Fire("Inactive");
	end;
end;
