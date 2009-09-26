TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor()
    self.listener = CompositeTable();
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

function TestSuite:Run()
    self.listener:StartAllTests(self);
    local tests = self:GetTests();
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

function TestSuite:GetTests()
    error("This method must be overridden by a subclass.");
end;
