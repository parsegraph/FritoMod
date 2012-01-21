if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/ListenerList";
	require "fritomod/ImmediateToggleDispatcher";
end;

StateDispatcher = OOP.Class();

function StateDispatcher:Constructor(initial, name)
	assert(initial, "Initial state must be provided");
	self.name = tostring(name or "StateDispatcher");

	self.installers = ImmediateToggleDispatcher:New("Installers for StateDispatcher "..self.name);

	local Install = Functions.Install(self.installers, "Fire");

	self.stateListeners = ListenerList:New();
	self.stateListeners:AddInstaller(Install);
	self.states = setmetatable({}, {
		__index = function(self, key)
			local dispatcher = ImmediateToggleDispatcher:New(key);
			dispatcher:AddInstaller(Install);
			rawset(self, key, dispatcher);
			return self[key];
		end
	});

	self:Fire(initial);
end;

function StateDispatcher:State()
	return self.currentState;
end;

function StateDispatcher:Fire(state, ...)
	if self.currentState then
		self.states[self.currentState]:Reset();
	end;
	local oldState = self.currentState;
	self.currentState = state;
	self.stateListeners:Fire(state, oldState, ...);
	self.states[state]:Fire(...);
end;

function StateDispatcher:SafeFire(state, ...)
	if self:State() == state then
		return;
	end;
	self:Fire(state, ...);
end;

function StateDispatcher:Refire(...)
	self:Fire(self:State(), ...);
end;

function StateDispatcher:AddInstaller(installer, ...)
	return self.installers:Add(installer, ...);
end;

function StateDispatcher:StateListener(listener, ...)
	return self.stateListeners:Add(listener, ...);
end;

function StateDispatcher:AddStateInstaller(state, installer, ...)
	return self.states[state]:AddInstaller(installer, ...);
end;

function StateDispatcher:OnTransition(newState, oldState, listener, ...)
	listener=Curry(listener, ...);
	return self:StateListener(function(self, thisNewState, thisOldState)
		if type(oldState) == "table" and #oldState and
				not Lists.Contains(oldState, thisOldState) then
			return;
		elseif oldState ~= thisOldState then
			return;
		end;
		if type(newState) == "table" and #newState and
				not Lists.Contains(newState, thisNewState) then
			return;
		elseif newState ~= thisNewState then
			return;
		end;
		local transitionRemover = listener();
		if transitionRemover then
			Callbacks.OnlyOnce(
				Curry(self, "OffState", thisNewState),
				transitionRemover);
		end;
	end, self);
end;

function StateDispatcher:OnState(state, activator, ...)
	if type(state) == "table" and #state then
		activator=Curry(activator, ...);
		local removers = {};
		for i=1, #state do
			table.insert(removers, self:OnActivate(state[i], activator));
		end;
		return Functions.OnlyOnce(Lists.CallEach, removers);
	end;
	return self.states[state]:Add(activator, ...);
end;

function StateDispatcher:OffState(state, deactivator, ...)
	return self:OnActivate(state,
		Functions.ReverseUndoable(deactivator, ...)
	);
end;
