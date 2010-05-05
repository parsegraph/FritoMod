if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Testing.Tests");

function Suite:TestValue()
    local value = Tests.Value();
    Assert.Nil(value.Get(), "Value is initially nil");
    value.Set(true);
    Assert.Equals(true, value.Get(), "Value can be set with Set, and retrieved with Get");
    Assert.Exception("Value fails when asserted for unexpected value", value.Assert, false);
    Assert.Success("Value succeeds when asserted for expected value", value.Assert, true);
end;

function Suite:TestValueAcceptsInitialValue()
    local value = Tests.Value(true);
    Assert.Equals(true, value.Get(), "Value accepts initial values");
end;

function Suite:TestValueAllowsMethodCalls()
    local value = Tests.Value();
    value:Set(true);
    Assert.Equals(true, value:Get(), "Value allows method-style calls");
end;

function Suite:TestSimpleFlagMechanics()
    local flag = Tests.Flag();
    assert(not flag.IsSet(), "Flag starts unset");
    flag.Raise();
    assert(flag.IsSet(), "Flag raises");
end;

function Suite:TestFlagCanBeSetOnConstruction()
    local flag = Tests.Flag(true);
    assert(flag.IsSet(), "Flag can be set to raised");
end;

function Suite:TestCounterCanBeSetOnConstruction()
    local counter = Tests.Counter(2);
    Assert.Equals(2, counter.Count(), "Counter accepts an optional initial value");
    Assert.Exception("Counter rejects non-numeric initial values", Tests.Counter, true);
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

function Suite:TestFlagAssertUnset()
    local flag = Tests.Flag();
    Assert.Succeeds("Flag asserts unset on initial state", flag.AssertUnset);
    flag.Raise();
    Assert.Exception("Flag fails unset-assertion when flag is raised", flag.AssertUnset);
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

function Suite:TestFullStackTrace()
    if not debug then
        return;
    end;
    local stackTrace = Tests.FullStackTrace();
    assert(stackTrace[1].name:match("FullStackTrace"),
        "First stack level is FullStackTrace. Level was: " .. Strings.PrettyPrint(stackTrace[1].name));
end;

local TEST_FILE="FritoMod_Testing_Tests[/\\]Tests\.lua";

function Suite:TestPartialStackTrace()
    if not debug then
        return;
    end;
    local stackTrace = Tests.PartialStackTrace();
	assert(stackTrace[1].name:match(TEST_FILE),
		"First stack level is the site of the stack-trace call. Level was: " .. stackTrace[1].name);
end;

function Suite:TestFormattedPartialStackTraceIsEqualToDebugStack()
	if not debugstack then
		return;
	end;
	Assert.Equals(debugstack(), Tests.FormattedPartialStackTrace());
end;

function Suite:TestDebugStack()
	if not debugstack then
		return;
	end;
	local l=unpack(Strings.SplitByDelimiter("\n", debugstack(),2));
	assert(l:match(TEST_FILE), "debugstack's first level is the test case");
end;

function Suite:TestFormattedPartialStackTrace()
    local stackTrace = Tests.FormattedPartialStackTrace();
    local firstLine, _ = unpack(Strings.SplitByDelimiter("\n", stackTrace, 2));
    assert(firstLine:match(TEST_FILE),
        "First line of default stack trace refers to the site of the stack-trace call. Line was: " ..
        Strings.PrettyPrint(firstLine));
end;
