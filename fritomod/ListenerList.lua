-- A list of functions that safely handles listener removal
--[[

local list = ListenerList:New();

local sum=0;
local r;
r=list:Add(function(num)
	sum = sum + num;
	if sum > 10 then
		r();
	end;
end);

-- TODO Come up with a less contrived example: Perhaps using a "damage done" event?
for i=1, 100 do
	list:Fire(i);
end;
--]]
--
-- ListenerList is a list of functions that can be called. Its benefit is that
-- listeners can be removed as the list is called. 

if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Functions";
	require "fritomod/Lists";
end;

ListenerList=OOP.Class();

function ListenerList:Constructor(name)
	self.name = name or tostring(self);
end;

function ListenerList:Install()
	assert(not self:HasListeners(), "Refusing to install to a non-empty list");
	self.listeners = {};
end;

function ListenerList:GetListenerCount()
	if not self.listeners then
		return 0;
	end;
	if not self.deadListeners then
		return #self.listeners;
	end;
	assert(#self.deadListeners <= #self.listeners,
		("Dead listeners should never exceed live listeners (dead: %d, live: %d)"):format(
		#self.deadListeners,
		#self.listeners));
	for i=1, #self.deadListeners do
		assert(Lists.Contains(self.listeners, self.deadListeners[i]),
			"deadListeners must not contain listeners that have already been reclaimed");
	end;
	return #self.listeners - #self.deadListeners;
end;

function ListenerList:HasListeners()
	return self:GetListenerCount() > 0;
end;

function ListenerList:Add(listener, ...)
	listener=Curry(listener, ...);
	trace("Adding listener to list %q. %d live and %d dead listener(s)",
		self.name,
		self:ImmediateListenerCount(),
		self:DeadListenerCount());
	if not self:HasListeners() then
		self:Install();
	end;
	table.insert(self.listeners, listener);
	return Functions.OnlyOnce(function()
		self:RemoveListener(listener);
		if not self:IsFiring() and not self:HasListeners() then
			self:Uninstall();
		end;
	end);
end;

function ListenerList:Fire(...)
	self:CleanUp();
	self.firing=true;
	trace("Firing all listeners on list %q", self.name);
	for i=1, self:ImmediateListenerCount() do
		if self.deadListeners and Lists.Contains(self.deadListeners, listener) then
			return;
		end;
		self:FireListener(self.listeners[i], ...);
	end;
	self.firing=false;
	self:CleanUp();
end;

function ListenerList:FireListener(listener, ...)
	return listener(...);
end;

function ListenerList:RemoveListener(listener)
	if not self.listeners then
		return;
	end;
	if not self:IsFiring() then
		Lists.Remove(self.listeners, listener);
	else
		if not self.deadListeners then
			self.deadListeners = {};
		end;
		table.insert(self.deadListeners, listener);
	end;
end;

function ListenerList:CleanUp()
	assert(not self.firing, "Refusing to clean list while firing");
	trace("Cleaning up list %q", self.name);
	if self.deadListeners then
		Lists.Map(self.deadListeners, self, "RemoveListener");
		self.deadListeners=nil;
		if not self:HasListeners() then
			self:Uninstall();
		end;
	end;
	trace("%d listener(s) remaining on list %q",
		self:ImmediateListenerCount(),
		self.name);
end;

function ListenerList:Uninstall()
	assert(not self:HasListeners(), "Refusing to uninstall a non-empty list");
	self.listeners = nil;
	self.deadListeners = nil;
end;

function ListenerList:IsFiring()
	return self.firing;
end;

function ListenerList:IsAlive(func)
	return self.listeners and Lists.Contains(self.listeners, func) and
		(not self.deadListeners or
		not Lists.Contains(self.deadListeners, func));
end;

function ListenerList:ImmediateListenerCount()
	if not self.listeners then
		return 0;
	end;
	return #self.listeners;
end;

function ListenerList:DeadListenerCount()
	if not self.deadListeners then
		return 0;
	end;
	return #self.deadListeners;
end;
