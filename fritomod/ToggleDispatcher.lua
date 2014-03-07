-- Manages undoable listeners
--[[

local dispatcher = ToggleDispatcher:New("My dispatcher");

-- PLAYER_REGEN_DISABLED is fired when we enter combat
dispatcher:AddInstaller(Events.PLAYER_REGEN_DISABLED, dispatcher, "Fire");

-- PLAYER_REGEN_ENABLED is fired when we exit combat
dispatcher:AddInstaller(Events.PLAYER_REGEN_ENABLED, dispatcher, "Reset");

local remover=dispatcher:Add(function()
	print("We're in combat!");
	return Curry(print, "We're out of combat!");
end);

--]]
--
-- ToggleDispatcher manages a transition between a fired and a unfired state. When
-- it enters either state, it will fire all registered listeners for that state.

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/Mixins-Log";
end;

ToggleDispatcher = OOP.Class("ToggleDispatcher", Mixins.Log);

ToggleDispatcher:AddConstructor(function(self)
	self.listeners = ListenerList:New();
	self:AddDestructor(self.listeners);
	self.listeners:SetID("Listeners", self);

	self.resetters = ListenerList:New();
	self:AddDestructor(self.resetters);
	self.resetters:SetID("Resetters", self);

	self:AddDestructor(self, "Reset");

	self.oneShotResetters = {};
end);

local function FireListener(listener, self, ...)
	local resetter = listener(...);
	if not IsCallable(resetter) then
		return;
	end;
	local removeResetter;
	removeResetter = self:OnReset(function()
		removeResetter();
		self.oneShotResetters[listener] = nil;
		resetter();
	end);
	self.oneShotResetters[listener] = removeResetter;
end;

function ToggleDispatcher:Fire(...)
	if self:HasFired() then
		self:log("Listener dispatches", "Fire requested, but I have already fired.");
		return;
	end;

	self:logEnter("Listener dispatches", "Firing dispatcher");
	self.fired = {...};
	self.listeners:InvokeListeners(FireListener, self, ...);
	self:logLeave();

	return Curry(self, "Reset");
end;
ToggleDispatcher.Each = ToggleDispatcher.Fire;

function ToggleDispatcher:Reset(...)
	if not self:HasFired() then
		self:log("Listener dispatches", "Reset requested, but I have not fired.");
		return;
	end;

	self:logEnter("Listener dispatches", "Resetting dispatcher");
	self.fired = nil;
	self.resetters:Fire(...);
	self:logLeave();
end;

function ToggleDispatcher:Add(listener, ...)
	listener = self.listeners:MakeUnique(listener, ...);

	local remover = self.listeners:AddDirectly(listener);
	if self:IsImmediate() and self:HasFired() then
		FireListener(listener, self, unpack(self.fired));
	end;
	return Functions.OnlyOnce(function()
		if self.oneShotResetters[listener] then
			self.oneShotResetters[listener]();
			self.oneShotResetters[listener] = nil;
		end;
		remover();
	end);
end;
ToggleDispatcher.AddListener = ToggleDispatcher.Add;
ToggleDispatcher.OnFire = ToggleDispatcher.Add;

-- Add a resetter to this dispatcher. It will be invoked whenever this
-- dispatcher is transitioning from a fired state to an unfired state.
--
-- Arguments to Reset() will be passed to each resetter, and its return
-- value is ignored.
--
-- Reset() must always be able to be called without any arguments, so
-- your resetters should anticipate this possibility.
--
-- Immediate-mode does not affect resetters.
function ToggleDispatcher:AddResetter(resetter, ...)
	return self.resetters:Add(resetter, ...);
end;
ToggleDispatcher.OnReset = ToggleDispatcher.AddResetter;

function ToggleDispatcher:AddInstaller(installer, ...)
	return self.listeners:AddInstaller(installer, ...);
end;
ToggleDispatcher.OnInstall = ToggleDispatcher.AddInstaller;

function ToggleDispatcher:Toggle(...)
	if self:HasFired() then
		self:Reset(...);
	else
		self:Fire(...);
	end;
end;

function ToggleDispatcher:HasFired()
	return Bool(self.fired);
end;
ToggleDispatcher.Fired = ToggleDispatcher.HasFired;

function ToggleDispatcher:IsFiring()
	return self.listeners:IsFiring();
end;
ToggleDispatcher.Firing = ToggleDispatcher.IsFiring;

function ToggleDispatcher:IsResetting()
	return self.resetters:IsFiring();
end;
ToggleDispatcher.Resetting = ToggleDispatcher.IsResetting;

OOP.Property(ToggleDispatcher, "Immediate");
ToggleDispatcher.IsImmediate = Headless("GetImmediate");


-- vim: set noet :
