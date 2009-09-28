TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor(name)
    self.listener = CompositeTable();
    if name then
        AllTests[name] = self;
    end;
    function self:ToString()
        if not name then
            name = Tables.Reference(self);
        end;
        return format("TestSuite(%s)", name);
    end;
end;

function TestSuite:AddListener(listener)
    return self.listener:Add(listener);
end;

function TestSuite:AddRecursiveListener(listener, ...)
    local removers = {};
    Lists.Insert(removers, self:AddListener(listener));
    local testGenerator = self:TestGenerator(...);
    while true do
        local test, testName = testGenerator();
        if not test then
            break;
        end;
        if OOP.InstanceOf(TestSuite, test) then
            Lists.Insert(removers, test:AddRecursiveListener(listener));
        end;
    end;
    return Curry(Lists.MapCall, removers);
end;

local function RunTest(self, test)
    if not test then
        return false, "Test is falsy";
    end;
    if IsCallable(test) then
        local ranSuccessfully, result = pcall(test);
        if ranSuccessfully then
            return result ~= false;
        end;
        return false, result;
    end;
    if type(test) == "table" then
        return RunTest(self, CurryMethod(test, test.Run));
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

function TestSuite:TestGenerator(...)
    local testGenerator = self:GetTests(...);
    if type(testGenerator) ~= "function" then
        testGenerator = Iterators.IterateMap(testGenerator);
    end;
    return function()
        local testName, test = testGenerator();
        if testName == nil then
            return;
        end;
        if not test and testName then
            test, testName = testName, tostring(testName);
        end;
        return test, tostring(testName);
    end;
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
    self.listener:StartAllTests(self, ...);
    local successful = true;
    local testGenerator = self:TestGenerator(...);
    repeat
        local test, testName = testGenerator();
        if not test then
            break;
        end;
        self.listener:TestStarted(self, testName);
        local result, errorMessage = RunTest(self, test);
        if result then
            self.listener:TestSuccessful(self, testName);
        else
            successful = false;
            self.listener:TestFailed(self, testName, errorMessage);
        end;
    until false;
    self.listener:FinishAllTests(self, successful);
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
-- The returned list is expected to be a map or list. The map's keys will be used as test names,
-- and their values will be the runnable tests.
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
