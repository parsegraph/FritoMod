local TestingTests = ReflectiveTestSuite:New("com.dafrito.testing");

function TestingTests:TestSuiteErrorsWhenNotOverridden()
    local suite = TestSuite:New();
    assert(not pcall(suite.Run, suite), "Suite requires GetTests to be overridden");
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
    assert(suite:Run(), "Suite ignores returned arguments except false");
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
    assert(not suite:Run(), "Suite fails on false elements");
end;

function TestingTests:TestSuiteDefaultsToSucceeding()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {};
    end;
    assert(suite:Run(), "Suite defaults to success");
end;
