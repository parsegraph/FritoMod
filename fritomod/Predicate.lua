if nil ~= require then
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/ImmediateToggleDispatcher";
end;

Predicate = OOP.Class();

function Predicate:Constructor(name)
	name=name or "";
	self.name = name;

	self.conditions = {};
	self.conditionRemovers = {};

	self.actions = ImmediateToggleDispatcher:New("Actions for predicate "..self.name);

	self.attached = true;

	self.Detach = ForcedMethod(self, function(self)
		if not self:IsAttached() then
			return;
		end;
		for cond, _ in pairs(self.conditions) do
			self:DetachCondition(cond);
		end;
		self.attached = false;
	end);
end;

-- Attaches this predicate, registering itself as a listener for each of its
-- conditions.
--
-- This method is a noop if this predicate is already attached.
function Predicate:Attach()
	if self:IsAttached() then
		return;
	end;
	self.attached = true;
	for cond, _ in pairs(self.conditions) do
		self:AttachCondition(cond);
	end;
	self:Run();
end;

-- Returns whether this predicate is attached. An attached predicate is registered
-- as a listener for each of its conditions.
function Predicate:IsAttached()
	return self.attached;
end;

-- Register a condition that determines the overall state of this predicate.

-- A condition is a two-state callback. It should fire a given listener once
-- when it is "active".  The given listener will return a function that the
-- specified condition should fire when the condition is no longer true.
function Predicate:Condition(cond, ...)
	trace("Adding condition to predicate %q", self.name);
	cond=Curry(cond, ...);
	self:AttachCondition(cond);
	self:Run();
	return Functions.OnlyOnce(self, "RemoveCondition", cond);
end;

-- Register an action that will fire when this predicate evaluates to true.
-- Actions may be undoable; their revoking function will be called when
-- the predicate's state changes from true to false.
function Predicate:Action(action, ...)
	-- Actions will fire immediately if we're evaluating to true.
	trace("Adding action to predicate %q", self.name);
	return self.actions:Add(action, ...);
end;

-- Register a single condition for this predicate.

-- This is an internal method used by Predicate:Attach(), so you'll never need
-- to call it yourself.
function Predicate:AttachCondition(cond)
	self.conditions[cond] = false;
	if self:IsAttached() then
		local conditionSetter = Curry(self, "SetConditionState", cond);
		local revoker = cond(function()
			conditionSetter(true);
			return Functions.OnlyOnce(conditionSetter, false);
		end);
		if IsCallable(revoker) then
			self.conditionRemovers[cond] = revoker;
		end;
	end;
end;

function Predicate:DetachCondition(cond)
	assert(self.conditions[cond], "Condition must be registered in order to be removed");
	self.conditions[cond] = false;
	local revoker = self.conditionRemovers[cond];
	if revoker then
		revoker();
		self.conditionRemovers[cond] = nil;
	end;
end;

-- Sets the active/inactive state for the specified condition.
--
-- You shouldn't need to call this method normally. Predicate uses it internally
-- when it registers conditions.
function Predicate:SetConditionState(cond, state)
	assert(self.conditions[cond] ~= nil,
		"Refusing to set the state of an unregistered condition");
	trace("Setting condition state to %s for condition %s",
		tostring(state),
		tostring(cond));
	self.conditions[cond] = Bool(state);
	self:Run();
end;

-- Runs this predicate, by evaluating its conditions and firing
-- actions if the predicate is active.
function Predicate:Run()
	if not self:IsAttached() then
		return;
	end;
	self:FireActions(self:Evaluate(self.conditions));
end;

-- Override the conditions and force the predicate to evaluate with the given
-- result.
--
-- This is useful if you want to reset your actions even though your
-- conditions are evaluating to true. In this case, detaching the predicate will
-- not call reset. This mimics the behavior of callbacks in that they only call
-- removers when their condition has actually reset. This is usually what you want,
-- but for the cases where detaching should also reset the state of actions, you
-- should use Override.
--
-- The overridden state will be ignored if it matches the current state: a fired
-- predicate will not re-fire its actions. Future evaluation will continue as normal:
-- condition state is not modified by override.
function Predicate:Override(result)
	result=Bool(result);
	trace("Overriding predicate with result: "..tostring(result));
	self:FireActions(result)
end;

-- Forces the execution of this predicate's actions.
function Predicate:ForceFire()
	return self:Override(true);
end;

-- Forces the execution of this predicate's reset actions.
function Predicate:ForceReset()
	return self:Override(false);
end;

function Predicate:FireActions(result)
	-- Actions is idempotent, so we can invoke Fire and Reset without need to keep
	-- track of its previous state.
	if result then
		trace("Firing predicate %q actions", self.name);
		self.actions:Fire();
	else
		trace("Resetting predicate %q actions", self.name);
		self.actions:Reset();
	end;
end;

-- Determines the cumulative state of this predicate. Clients are free to override
-- this method to implement their own evaluation logic.
function Predicate:Evaluate()
	trace("Evaluating predicate %q", self.name);
	local result = nil;
	for cond, condResult in pairs(self.conditions) do
		if condResult == false then
			-- False conditional, so everything's false.
			result=false;
			break;
		end;
		result=true;
		trace("Predicate %q condition %s has result %s",
			self.name,
			tostring(cond),
			tostring(condResult));
	end;
	if result == nil then
		-- There were no conditions present, so return false.
		result=false;
	end;
	trace("Predicate %q has result: %q", self.name, tostring(result));
	return result;
end;

function Predicate:Destroy()
	self:Detach();
	self:ForceReset();
end;
