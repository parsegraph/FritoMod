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
-- listeners can be removed as the list is called; a plain table does not handle
-- removal during iteration in a predictable manner. Specifically, ListenerList
-- provides two guarantees beyond a plain table list:
--
-- 1. Iteration will operate predictably when listeners are removed, even if they
-- are removed during a firing operation.
-- 2. The order of functions is dependent only on the time they were inserted; the
-- returned remover will always remove the correct element, even if the removed
-- function has duplicates in the listener list.
--
-- If you need to provide an observer-like interface, you should use ListenerList.
-- It is too easy to violate the above guarantees when you roll your own.
--
-- ListenerList is designed to be extended by overriding Install and Uninstall.
-- If you need special behavior when a listener is removed, override
-- RemoveListener. In all cases, call ListenerList's method first before adding
-- your own behavior.

if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/Functions";
	require "fritomod/Lists";
	require "fritomod/Mixins-Log";
end;

ListenerList = OOP.Class("ListenerList", Mixins.Log);

ListenerList:AddConstructor(function(self)
	self.listeners = {};
	self:AddDestructor(self, "Uninstall", true);
end);

function ListenerList:Add(listener, ...)
	return self:AddDirectly(self:MakeUnique(listener, ...));
end;
ListenerList.AddListener = ListenerList.Add;
ListenerList.OnFire = ListenerList.Add;

function ListenerList:Each(...)
	if select("#", ...) == 0 then
		return self:InvokeListeners();
	end;
	return self:InvokeListeners(function(listener, ...)
		listener(...);
	end, ...);
end;
ListenerList.Fire = ListenerList.Each;

function ListenerList:Map(...)
	local results = {};
	self:InvokeListeners(function(listener, ...)
		local result = listener(...);
		if result ~= nil then
			table.insert(results);
		end;
	end, ...);
	return results;
end;

function ListenerList:FinalizeFire()
	self.firingIndex = nil;
	self.firingMax = nil;
	self.firing = false;
end;

ListenerList_DEBUG = false;

-- This method is rarely used, unless you need special behavior when
-- a listener is invoked.
function ListenerList:InvokeListeners(invoker, ...)
	if ListenerList_DEBUG then
		assert(not self:IsFiring(), tostring(self).. " is refusing to fire while firing");
	elseif self:IsFiring() then
		self:FinalizeFire();
	end;
	if #self.listeners == 0 then
		return;
	end;

	if ListenerList_DEBUG then
		self:logEntercf("Listener dispatches", "Firing all", self:GetListenerCount(), "listener(s)");
	end;

	self.firing = true;
	self.firingMax = #self.listeners;
	self.firingIndex = 1;

	while self.firingIndex <= self.firingMax do
		local listener = self.listeners[self.firingIndex];
		local target = listener;
		if invoker then
			--print("Needing to create invoker");
			target = Curry(invoker, listener, ...);
		end;
		if ListenerList_DEBUG then
			local succeeded, err = xpcall(target, traceback);
			if not succeeded then
				-- Clean up our firing variable, otherwise we'll be permanently
				-- stuck in "firing" mode.
				self:FinalizeFire();
				if self:GetRemoveOnFail() then
					self:RemoveListener(listener);
				end;
				self:logLeave();
				error(err);
			end;
		else
			target();
		end;
		if OOP.IsDestroyed(self) then
			break;
		end;
		self.firingIndex = self.firingIndex + 1;
	end;
	self:FinalizeFire();
	if ListenerList_DEBUG then
		self:logLeave();
	end;
end;

-- This method is not often used, unless you're writing a dispatcher.
function ListenerList:AddDirectly(listener)
	self:logEntercf("Listener additions and removals", "Adding a listener to me. I will now have", 1+self:GetListenerCount(),"listener(s)");
	if not self:HasListeners() then
		self:Install();
	end;
	table.insert(self.listeners, listener);
	self:logLeave();
	return Functions.OnlyOnce(self, "RemoveListener", listener);
end;

function ListenerList:MakeUnique(listener, ...)
	local original = listener;
	listener = Curry(listener, ...);
	if original == listener then
		-- Ensure that the functions in our list are always
		-- unique. This ensures the returned remover will remove exactly
		-- the expected function, instead of removing some potential
		-- duplicate.
		listener = Functions.Clone(listener);
	end;
	return listener;
end;

-- This method should be considered private.
function ListenerList:RemoveListener(listener)
	self:logEnter("Listener additions and removals", "Removing a listener from me. I will now have", self:GetListenerCount()-1, "listener(s)");
	local removedIndex = Lists.IndexOf(self.listeners, listener);
	if self:IsFiring() then
		if removedIndex == nil then
			-- Nothing found, so just return.
			self:logLeave();
			return;
		end;
		if removedIndex <= self.firingMax then
			self.firingMax = self.firingMax - 1;
		end;
		if removedIndex <= self.firingIndex then
			self.firingIndex = self.firingIndex - 1;
		end;
	end;
	table.remove(self.listeners, removedIndex);
	if not self:HasListeners() then
		self:Uninstall();
	end;
	self:logLeave();
end;

function ListenerList:AddInstaller(func, ...)
	self.installers=self.installers or {};
	return Lists.Insert(self.installers, Curry(func, ...));
end;
ListenerList.OnInstall = ListenerList.AddInstaller;

-- This method should be considered private.
function ListenerList:Install()
	assert(not self:HasListeners(), tostring(self).." is refusing to install a populated list %q", self);
	self:logEnter("Listener list installations", "Installing listener list");
	if self.installers then
		self.uninstallers=Lists.MapCall(self.installers);
	end;
	self:logLeave();
end;

-- This method should be considered private.
function ListenerList:Uninstall(force)
	assert(force or not self:HasListeners(), "Refusing to uninstall populated list");
	if self.uninstallers then
		self:logEnter("Listener list installations", "Uninstalling listener list");
		Lists.CallEach(self.uninstallers);
		self.uninstallers=nil;
		self:logLeave();
	end;
end;

function ListenerList:IsFiring()
	return self.firing;
end;

function ListenerList:DumpListeners()
	if #self.listeners == 0 then
		trace("No listeners in %q", self.name);
	end;
	trace("%d listener(s) in %q", #self.listeners, self.name);
	local i=#self.listeners;
	while i > 0 do
		trace("%d: %s", #self.listeners - i + 1, tostring(self.listeners[i]));
		i = i - 1;
	end;
end;

OOP.Property(ListenerList, "RemoveOnFail");

function ListenerList:GetListenerCount()
	return #self.listeners;
end;
ListenerList.Size = ListenerList.GetListenerCount;
ListenerList.Length = ListenerList.GetListenerCount;
ListenerList.Count = ListenerList.GetListenerCount;
ListenerList.ListenerCount = ListenerList.GetListenerCount;
ListenerList.GetNumListeners = ListenerList.GetListenerCount;
ListenerList.NumListeners = ListenerList.GetListenerCount;

function ListenerList:HasListeners()
	return self:GetListenerCount() > 0;
end;

-- vim: set noet :
