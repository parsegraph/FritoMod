TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor(name)
    self.listener = CompositeTable();
    if name then
        self.name = name;
        AllTests[name] = self;
    end;
end;

function TestSuite:AddListener(listener)
    return self.listener:Add(listener);
end;

function TestSuite:AddRecursiveListener(listener, ...)
    local removers = {};
    Lists.Insert(removers, self:AddListener(listener));
    local testGenerator = self:GetTests(...);
    while true do
        local test = testGenerator();
        if not test then
            break;
        end;
        if OOP.InstanceOf(TestSuite, test) then
            Lists.Insert(removers, test:AddRecursiveListener(listener));
        end;
    end;
    return Curry(Lists.MapCall, removers);
end;

function TestSuite:ToString()
    local name = self.name;
    if not name then
    end;
    return format("TestSuite(%s)", name);
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
    self.listener:StartAllTests(self, ...);
    local testGenerator = self:GetTests(...);
    if type(testGenerator) ~= "function" then
        testGenerator = Iterator.IterateMap(tests);
    end;
    local successful = true;
    repeat
        local testName, test = testGenerator();
        if testName == nil then
            break;
        end;
        if not test and testName then
            test, testName = testName, tostring(testName);
        end;
        testName = tostring(testName);
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
