TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor(name)
    self.listener = CompositeTable();
    if name then
        AllTests[name] = self;
    end;
end;

function TestSuite:AddListener(listenerFunc, ...)
    return self.listener:Add(listenerFunc, ...);
end;

local function RunTest(self, test)
    if not test then
        return false, "Test is falsy";
    end;
    if IsCallable(test) then
        return pcall(test);
    end;
    if type(test) == "table" then
        return pcall(test.Run, test);
    end;
    if type(test) == "string" then
        local testfunc, err = loadstring(test);
        if testFunc then
            return RunTest(self, testFunc);
        end;
        return false, err;
    end;
    return false, "Test is not a callable, table, or string: " .. type(test);
end;

-- Runs tests from this test suite. Every test returned by GetTests() is invoked. Their
-- results are sent to this test suite's listeners.
--
-- Tests are called in protected mode, so failed tests do not stop execution of subsequent
-- tests.
--
-- ...
--     Optional. These arguments are forwarded to GetTests, so they may be used to configure
--     either the number of tests or the way tests are run. Semantics of these arguments
--     are defined by subclasses. If a suite does not have any filtering or customizing 
--     abilitiy, these arguments are silently ignored.
-- returns
--     true, if this suite executed all tests successfully
function TestSuite:Run(...)
    self.listener:StartAllTests(self);
    local tests = self:GetTests(...);
    if type(tests) == "function" then
        tests = Lists.Consume(tests);
    end;
    local successful = true;
    for test in ipairs(tests) do
        self.listener:TestStarted(self, test);
        local result, errorMessage = RunTest(self, test);
        if result then
            self.listener:TestSuccessful(self, test);
        else
            successful = false;
            self.listener:TestFailed(self, test, errorMessage);
        end;
    end;
    self.listener:FinishAllTests(self);
    return successful;
end;

-- Returns all tests that this test suite contains. A test may be one of the following:
--
-- * A function or callable table. The function is called with no arguments, and its 
-- returned value is ignored.
-- * A table with a Run function. The Run function is called like a regular function with
-- the proper self argument.
-- * A string that represents executable code. The code is compiled and executed.
--
-- ...
--     Optional. These arguments may be used to configure which tests are ran, or how they
--     are executed. Subclasses are expected to either define the semantics of these arguments
--     or silently ignore them.
-- returns
--     a list, or a function that iterates over a list, of tests to be executed
function TestSuite:GetTests(...)
    error("This method must be overridden by a subclass.");
end;
