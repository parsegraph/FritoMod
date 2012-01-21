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
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/OOP-Class";
	require "fritomod/Lists";
	require "fritomod/ListenerList";
end;

ToggleDispatcher=OOP.Class(ListenerList);

function ToggleDispatcher:Constructor(name)
	self.name=name or tostring(self);
	self.resetters={};
end;

function ToggleDispatcher:Fire(...)
	if self.fired then
		return;
	end;
	ToggleDispatcher.super.Fire(self, ...);
	self.fired=true;
	return Seal(self, "Reset");
end;

function ToggleDispatcher:FireListener(listener, ...)
	local resetter=listener(...);
	if resetter then
		self.resetters=self.resetters or {};
		table.insert(self.resetters, resetter);
		self.resetters[listener]=resetter;
		self.resetters[resetter]=resetter;
	end;
end;

function ToggleDispatcher:RemoveListener(listener)
	ToggleDispatcher.super.RemoveListener(self, listener);
	if self.resetters then
		local resetter=self.resetters[listener];
		if resetter then
			self.resetters[resetter]=nil;
			self.resetters[listener]=nil;
		end;
	end;
end;

function ToggleDispatcher:Reset(...)
	if not self.fired then
		return;
	end;
	trace("Resetting dispatcher %q", self.name);
	if self.resetters and #self.resetters > 0 then
		for _, resetter in ipairs(self.resetters) do
			if self.resetters[resetter] then
				resetter(...);
			end;
		end;
		self.resetters=nil;
	end;
	self.fired=false;
end;

function ToggleDispatcher:Toggle(...)
	if self.fired then
		self:Reset(...);
	else
		self:Fire(...);
	end;
end;
