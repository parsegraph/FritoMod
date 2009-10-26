local Suite = ReflectiveTestSuite:New("FritoMod_Testing.Tests");

function Suite:TestSimpleFlagMechanics()
    local flag = Tests.Flag();
    assert(not flag.IsSet(), "Flag starts unset");
    flag.Raise();
    assert(flag.IsSet(), "Flag raises");
end;

function Suite:TestFlagIgnoresSpuriousRaiseCalls()
    local flag = Tests.Flag();
    flag.Raise();
    assert(flag.IsSet(), "Flag raises");
    flag.Raise();
    assert(flag.IsSet(), "Flag remains raised");
end;

function Suite:TestFlagClears()
    local flag = Tests.Flag();
    flag.Raise();
    assert(flag.IsSet(), "Flag raises");
    flag.Clear();
    assert(not flag.IsSet(), "Flag clears");
end;

function Suite:TestFlagClearsWithMethodCalls()
    local flag = Tests.Flag();
    flag:Raise();
    assert(flag:IsSet(), "Flag raises");
    flag:Clear();
    assert(not flag:IsSet(), "Flag clears");
end;

function Suite:TestFlagAsserts()
    local flag = Tests.Flag();
    flag.Raise();
    assert(flag.IsSet(), "Flag raises");
    flag.Assert();
end;

function Suite:TestFlagAssertCanFail()
    local flag = Tests.Flag();
    assert(not pcall(flag.Assert), "Assert fails on unset flag");
end;

function Suite:TestSimpleCounter()
    local counter = Tests.Counter();
    Assert.Equals(0, counter:Count(), "Counter starts at zero");
    counter:Hit();
    Assert.Equals(1, counter:Count(), "Counter increments to one");
end;

function Suite:TestCounterAsserts()
    local counter = Tests.Counter();
    Assert.Equals(0, counter:Count(), "Counter starts at zero");
    counter:Hit();
    counter:Assert(1, "Counter asserts that it's at one");
end;
