local Suite=CreateTestSuite("fritomod.Predicate");

function Suite:TestPredicateFiresActionWhenConditionIsTrue()
	local pred = Predicate:New("Test");

	local cond = Objects.Value();
	pred:Condition(cond);

	cond.AssertSet("Condition is immediately registered");

	Assert.Callable(cond.Get(), "Condition is passed a callable function");

	local flag = Tests.Flag();
	pred:Action(flag.Raise);
	flag.AssertUnset("Action is invoked only if conditions are met");

	-- Invoke conditional
	local revoker = cond.Get()();

	flag.Assert("Action is immediately fired if conditions are met");

	-- Revoke conditional
	revoker();

	flag.AssertUnset("Action is undone if conditions become false");
end;

function Suite:TestPredicateWithValueCondition()
	local pred = Predicate:New("Test");

	local cond = Objects.Value();
	pred:ValueCondition(cond);

	local flag = Tests.Flag();
	pred:Action(flag.Raise);

	cond.Get()(false);
	flag.AssertUnset("False is interpreted as an unmet condition");

	cond.Get()(nil);
	flag.AssertUnset("Nil is interpreted as an unmet condition");

	cond.Get()(true);
	flag.AssertSet("True is interpreted as a met condition");
end;

function Suite:TestPredicateWithInnerPredicate()
	local outer = Predicate:New("Outer");
	local flag = Tests.Flag();
	outer:Action(flag.Raise);

	local inner = Predicate:New("Inner");
	outer:Condition(inner);

	local cond = Objects.Value();
	inner:Condition(cond);

	-- Invoke the innermost condition.
	local revoker = cond.Get()();

	flag.Assert("Outer predicate is active if inner predicate is active");

	revoker();

	flag.AssertUnset("Outer predicate is no longer active if inner active is inactive");
end;
