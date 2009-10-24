TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor(name)
    self.listener = Metatables.Multicast();
    self.name = name or "";
    if name then
        AllTests[name] = self;
    end;
end;

function TestSuite:GetName()
    if self.name == "" then
        return;
    end;
    return self.name;
end;

function TestSuite:ToString()
    local name = self:GetName();
    if not name then
        name = Tables.Reference(self);
    end;
    return format("TestSuite(%s)", name);
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

local function CoerceTest(test)
    assert(test, "Test is falsy");
    if IsCallable(test) then
        return test;
    end;
    if type(test) == "table" then
        return CurryMethod(test, test.Run);
    end;
    if type(test) == "string" then
        local testfunc, err = loadstring(test);
        if testFunc then
            return testFunc;
        end;
        error(err);
    end;
    error("Test is not a callable, table, or string: " .. type(test));
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
            test, testName = testName, testName;
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
    local failedTests = 0;
    local testGenerator = self:TestGenerator(...);
    repeat
        local test, testName = testGenerator();
        if not test then
            break;
        end;
        local success, result = pcall(CoerceTest, test);
        if success then
            local testRunner = result;
            self.listener:TestStarted(self, testName, testRunner);
            success, result, reason = pcall(testRunner);
            if success ~= true then
                failedTests = failedTests + 1;
                self.listener:TestErrored(self, testName, testRunner, tostring(result));
            elseif result == false then
                failedTests = failedTests + 1;
                self.listener:TestFailed(self, testName, testRunner, tostring(reason));
            else
                self.listener:TestSuccessful(self, testName, testRunner);
            end;
        else
            self.listener:InternalError(self, testName, result);
        end;
    until false;
    self.listener:FinishAllTests(self, failedTests == 0);
    if failedTests == 0 then
        return;
    end;
    return false, format("%d test(s) failed", failedTests);
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
