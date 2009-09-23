TestSuite = OOP.Class();
local TestSuite = TestSuite;

function TestSuite:Constructor()
    self.listener = CompositeFunction();
end;

function TestSuite:AddListener(listenerFunc, ...)
    return self.listener:Add(listenerFunc, ...);
end;

function TestSuite:Run()
    self.listener:StartAllTests(self);
    local tests = self:GetTests();
    for test in tests do
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
