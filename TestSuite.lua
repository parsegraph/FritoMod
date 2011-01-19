if nil ~= require then
    require "basic";
    require "currying";
    require "Metatables";
    require "Functions";
    require "OOP";
    require "OOP-Class";
    require "Metatables";
    require "Lists";
    require "Iterators";
    require "Tests";
end;

TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor(name)
    self.listener = Metatables.Multicast();
    self.name = name or "";
    if name then
        if require then
            require("AllTests");
        end;
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
    local name = self:GetName() or Reference(self);
    return ("TestSuite(%s)"):format(name);
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
        -- We don't use OOP.InstanceOf here because it's possible we'll encounter
        -- TestSuites that are from a different global environment than the one
        -- this TestSuite was created in. For example, if AllTests is created in a
        -- global environment, but we run our test suites in a pristine environment
        -- (with only a reference to AllTests), this will never be true since the
        -- children have different "TestSuite" classes.
        if type(test)=="table" and IsCallable(test.AddRecursiveListener) then
            Lists.Insert(removers, test:AddRecursiveListener(listener));
        end;
    end;
    return Curry(Lists.CallEach, removers);
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

local function WrapTestRunner(testRunner)
    return function()
        local result, reason = testRunner();
        assert(result ~= false, reason or "Test returned false");
    end;
end;

local function InterpretTestResult(stackTraces, testRanSuccessfully, result, extendedReason)
    if testRanSuccessfully and result ~= false then
        return "Successful";
    end;
    if result == false then
        return "Failed", tostring(extendedReason or "Test returned false");
    end;
    if #stackTraces > 0 then
        local stackTrace = table.remove(stackTraces);
        local file, num, reason = unpack(Strings.SplitByDelimiter(":", tostring(result), 3));
        return "Failed", ("Assertion failed: \"%s\"\n%s"):format(Strings.Trim(reason), stackTrace);
    end;
    return "Crashed", tostring(result);
end;

local function RunTest(self, test, testName)
    local success, result = pcall(CoerceTest, test);
    if not success then
        self.listener:InternalError(self, testName, result);
        return false;
    end;
    local testRunner = result;
    local stackTraces = {};
    self.listener:TestStarted(self, testName, testRunner);
    local unhookAssert = Functions.SpyGlobal("assert", function(expression, message, ...)
        if not expression then
            table.insert(stackTraces, Tests.FormattedPartialStackTrace(4, 10, 0));
        end;
    end);
    local unhookError = Functions.SpyGlobal("error", function()
        table.insert(stackTraces, Tests.FormattedPartialStackTrace(4, 10, 0));
    end);
    local testState, reason = InterpretTestResult(stackTraces, pcall(testRunner));
    unhookAssert();
    unhookError();
    testRunner = WrapTestRunner(testRunner);
    self.listener["Test" .. testState](self.listener, self, testName, testRunner, reason);
	self.listener:TestFinished(self, testName, testRunner, testState, reason);
    return testState;
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
--     false if this test suite failed
-- returns
--     a string describing the reason of the failure
function TestSuite:Run(...)
    self.listener:StartAllTests(self, ...);
    local testResults = {
        All = Tests.Counter(),
        Successful = Tests.Counter(),
        Failed = Tests.Counter(),
        Crashed = Tests.Counter()
    };
    for test, testName in self:TestGenerator(...) do
        testResults.All:Hit();
        local result = RunTest(self, test, testName);
        testResults[result].Hit();
    end;
    local successful = testResults.All:Get() == testResults.Successful:Get();
    local report;
    if successful then
        report = ("All %d tests ran successfully."):format(testResults.All:Get());
    else
        report = ("%d of %d tests ran successfully, %d failed, %d crashed"):format(
            testResults.Successful:Get(), 
            testResults.All:Get(),
            testResults.Failed:Get(),
            testResults.Crashed:Get());
    end;
    self.listener:FinishAllTests(self, successful, report);
    return successful, report;
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
