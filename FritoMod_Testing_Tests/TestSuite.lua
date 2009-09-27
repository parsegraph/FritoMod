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
                return false;
            end,
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
    assert(suite:Run(), "Suite ignores returned arguments");
end;

function TestingTests:TestSuiteDefaultsToSucceeding()
    local suite = TestSuite:New();
    function suite:GetTests()
        return {};
    end;
    assert(suite:Run(), "Suite defaults to success");
end;
