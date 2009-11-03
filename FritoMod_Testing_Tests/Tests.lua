if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";
end;

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

function Suite:TestFullStackTrace()
    if not debug then
        return;
    end;
    local stackTrace = Tests.FullStackTrace();
    assert(stackTrace[1].name:match("^<[.a-zA-Z_/\\]+[/\\]FritoMod_Testing_Tests[/\\]Tests\.lua:[0-9]+>$"),
        "First stack level is invoked function. Level was: " .. Strings.PrettyPrint(stackTrace[1].name));
end;

function Suite:TestFormattedStackTrace()
    if not debug then
        return;
    end;
    local stackTrace = Tests.FormattedStackTrace();
    local firstLine, _ = unpack(Strings.SplitByDelimiter("\n", stackTrace, 2));
    assert(firstLine:match("FritoMod_Testing_Tests[/\\]Tests\.lua:[0-9]+: in [a-zA-Z]+ " ..
        "<[.a-zA-Z_/\\]+[/\\]FritoMod_Testing_Tests[/\\]Tests\.lua"),
        "First line of default stack trace refers to the site of the stack-trace call. Line was: " ..
        Strings.PrettyPrint(firstLine));
end;

function Suite:TestFormattedPartialStackTrace()
    local stackTrace = Tests.FormattedPartialStackTrace();
    local firstLine, _ = unpack(Strings.SplitByDelimiter("\n", stackTrace, 2));
    assert(firstLine:match("FritoMod_Testing_Tests[/\\]Tests\.lua:[0-9]+: in [a-zA-Z]+ " ..
        "<[.a-zA-Z_/\\]+[/\\]FritoMod_Testing_Tests[/\\]Tests\.lua"),
        "First line of default stack trace refers to the site of the stack-trace call. Line was: " ..
        Strings.PrettyPrint(firstLine));
end;
