TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor()
    self.listener = CompositeTable();
end;

function TestSuite:AddListener(listenerFunc, ...)
    return self.listener:Add(listenerFunc, ...);
end;

function TestSuite:Run()
    self.listener:StartAllTests(self);
    local tests = self:GetTests();
    if type(tests) == "function" then
        tests = Lists.Consume(tests);
    end;
    for test in ipairs(tests) do
        self.listener:TestStarted(self, test);
        if pcall(test) then
            self.listener:TestSuccessful(self, test);
        else
            self.listener:TestFailed(self, test);
        end;
    end;
    self.listener:FinishAllTests(self);
end;

function TestSuite:GetTests()
    error("This method must be overridden by a subclass.");
end;
