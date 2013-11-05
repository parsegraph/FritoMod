-- Provides an OOP approach to conditions and actions.

-- A Predicate manages two separate lists: conditions and actions.
-- The state of each condition is monitored, and if the predicate
-- determines that its conditions cumulatively evaluate to true, then
-- every action is fired. If the conditions change such that their
-- cumulative result is no longer true, then any actions are revoked.

-- Conditions are functions or other Predicates. By default, these functions
-- behave like callbacks: they should expect a listener to be passed, and they
-- should invoke it whenever their condition is true. They should expect the
-- listener to return a function that, when invoked, indicates the condition
-- is no longer true.

-- A condition may also be a value-based condition. In this case, they should pass
-- a value to the passed listener. Truthy values are considered active by the
-- predicate; falsy values are treated as a false condition.

-- Finally, a condition may be another predicate. In this case, if the inner
-- predicate is true, then it is considered a true condition by the outer predicate.

-- Actions are simple undoables. They may return a function that will be invoked
-- when the predicate is no longer active.

-- By default, the predicate is considered active if all conditions are true (if
-- no conditions are present, then the predicate is considered inactive). This
-- behavior may be changed by using Predicate:SetEvaluator. Some basic evaluators
-- are already provided: "all", "any", and "majority". These may be used by passing
-- the respective string to SetEvaluator.

if nil ~= require then
	require "fritomod/currying";
	require "fritomod/OOP-Class";
	require "fritomod/ImmediateToggleDispatcher";
end;

Predicate = OOP.Class("Predicate");

local evaluators = {};
function evaluators.any(conditions)
	local cumulativeResult = nil;
	for cond, result in pairs(conditions) do
		if result then
			cumulativeResult = true;
			break;
		end;
		cumulativeResult = false;
	end;
	-- If cumulativeResult is nil, then no
	-- conditions were registered.
	return cumulativeResult == true;
end;

function evaluators.all(conditions)
	local cumulativeResult = nil;
	for cond, result in pairs(conditions) do
		if not result then
			cumulativeResult = false;
			break;
		end;
		cumulativeResult = true;
	end;
	-- If cumulativeResult is nil, then no
	-- conditions were registered.
	return cumulativeResult == true;
end;

function evaluators.majority(conditions)
	local cumulativeResult = nil;
	for cond, result in pairs(conditions) do
		cumulativeResult = cumulativeResult or 0;
		if result then
			cumulativeResult = cumulativeResult + 1;
		else
			cumulativeResult = cumulativeResult - 1;
		end;
	end;
	-- Zero is truthy, so accept any positive result as
	-- active.
	return cumulativeResult and cumulativeResult > 0;
end;

function Predicate:Constructor(name)
	name=name or "";
	self.name = name;

	self.conditions = {};
	self.conditionRemovers = {};

	self.actions = ImmediateToggleDispatcher:New("Actions for predicate "..self.name);

	self.attached = true;

	self.evaluator = evaluators.all;
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

function Predicate:Detach()
	if not self:IsAttached() then
		return;
	end;
	for cond, _ in pairs(self.conditions) do
		self:DetachCondition(cond);
	end;
	self.attached = false;
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
	if select("#", ...) == 0 and OOP.InstanceOf(Predicate, cond) then
		return self:PredicateCondition(cond);
	end;
	trace("Adding condition to predicate %q", self.name);
	cond=Functions.Clone(Curry(cond, ...));
	self:AttachCondition(cond);
	self:Run();
	return Functions.OnlyOnce(function(self)
		self:DetachCondition(cond);
		self.conditions[cond] = nil;
		self:Run();
	end, self);
end;

-- Registers a conditions that determines the overall state of this predicate.

-- A value condition is a callback function that will send a value that determines
-- its state. A truthy value is considered as active for the predicate.
function Predicate:ValueCondition(cond, ...)
	trace("Adding value condition to predicate %q", self.name);
	cond=Curry(cond, ...);
	return self:Condition(function(listener)
		local active = false;
		local remover;
		return cond(function(value)
			if not active and value then
				remover = listener();
			elseif active and not value then
				remover();
				remover = nil;
			end;
		end);
	end);
end;

-- Registers the specified predicate as a condition for this predicate.
--
-- If the specified predicate is active, then it is considered true as
-- a condition for this predicate.
function Predicate:PredicateCondition(predicate)
	trace("Adding predicate condition to predicate %q", self.name);
	return self:Condition(function(listener)
		return predicate:Action(listener);
	end);
end;

function Predicate:ConstantCondition(value)
	if value then
		return self:Condition(function(listener)
			-- Always fire the listener, and ignore any revoker returned.
			listener();
		end);
	else
		-- A noop condition will never fire, so it will always evaluate
		-- to false.
		return self:Condition(Noop);
	end;
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
		local removed = false;
		local revoker = cond(function()
			if removed then
				return Noop;
			end;
			conditionSetter(true);
			return Functions.OnlyOnce(conditionSetter, false);
		end);
		self.conditionRemovers[cond] = function()
			removed = true;
			if IsCallable(revoker) then
				revoker();
				revoker = nil;
			end;
		end;
	end;
end;

function Predicate:DetachCondition(cond)
	assert(self.conditions[cond] ~= nil, "Condition must be registered in order to be removed");
	local revoker = self.conditionRemovers[cond];
	if revoker then
		revoker();
	end;
	self.conditions[cond] = false;
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
	self.conditions[cond] = state;
	self:Run();
end;

-- Runs this predicate, by evaluating its conditions and firing
-- actions if the predicate is active.
--
-- This method does not normally need to be called by clients.
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
	local result = self.evaluator(self.conditions);
	trace("Predicate %q has result: %q", self.name, tostring(result));
	return result;
end;

function Predicate:SetEvaluator(func, ...)
	if type(func) == "string" and select("#", ...) then
		func = assert(evaluators[func], "Invalid evaluator name: "..func);
	else
		func=Curry(func, ...);
	end;
	self.evaluator = func;
	self:Run();
end;
