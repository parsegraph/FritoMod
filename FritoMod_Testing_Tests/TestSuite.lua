local TestingTests = ReflectiveTestSuite:New("FritoMod_Testing.TestSuite");

function TestingTests:TestSuiteErrorsWhenNotOverridden()
    local suite = TestSuite:New();
    Assert.Exception("Suite requires GetTests to be overridden", suite.Run, suite);
end;

function TestingTests:TestListenersDuringSuccess()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {Noop};
    end;
    local order = {};
    suite:AddListener(Metatables.FocusedTable({}, function(self, eventName, ...)
        Lists.Insert(order, eventName);
    end));
    local expected = {
        "StartAllTests", 
        "TestStarted",
        "TestSuccessful",
        "FinishAllTests"
    };
    suite:Run();
    Assert.Equals(expected, order, "One successful test emits proper events");
end;

function TestingTests:TestListenersDuringFailure()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {Operator.False};
    end;
    local order = {};
    suite:AddListener(Metatables.FocusedTable({}, function(self, eventName, ...)
        Lists.Insert(order, eventName);
    end));
    local expected = {
        "StartAllTests", 
        "TestStarted",
        "TestFailed",
        "FinishAllTests"
    };
    suite:Run();
    Assert.Equals(expected, order, "One failed test emits proper events");
end;

function TestingTests:TestSuiteIgnoresReturnedArguments()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {
            function()
                return true;
            end,
            function()
                return nil;
            end,
            function()
                return 0
            end
        };
    end;
    assert(false ~= suite:Run(), "Suite ignores returned arguments except false");
end;

function TestingTests:TestSuiteFailsOnFalse()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {
            function()
                return false;
            end,
        };
    end;
    Assert.Equals(false, suite:Run(), "Suite fails on false elements");
end;

function TestingTests:TestSuiteDefaultsToSucceeding()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {};
    end;
    assert(false ~= suite:Run(), "Suite defaults to success");
end;
