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
