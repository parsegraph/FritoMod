TestManager = OOP.Class(Log, OOP.Singleton);
local TestManager = TestManager;

function TestManager:__init(prefix)
    TestManager.__super.__init(self, prefix or "TestManager");
    self.groups = {};
end;

function TestManager:AddTest(testGroupName, testName, returnType, returnValue, testFunc, ...)
    self:InsertTestCase(testGroupName, TestCase(testName, returnType, returnValue, testFunc, ...));
end;

function TestManager:InsertTestCase(testGroupName, testCase)
    table.insert(self:GetTestGroup(testGroupName), testCase);
end;

function TestManager:GetTestGroup(testGroupName)
    local testGroup = self.groups[testGroupName];
    if not testGroup then
        testGroup = {};
        self.groups[testGroupName] = testGroup;
    end;
    return testGroup;
end;

function TestManager:Run(testGroupName)
    if not testGroupName then
        self:Log("Running all tests.");
        local totalFailed = 0;
        local totalTests = 0;
        for testGroupName, testGroup in pairs(self.groups) do
            totalFailed = totalFailed + self:Run(testGroupName);
            totalTests = totalTests + #testGroup;
        end;
        if totalFailed > 0 then
            self:LogError(totalFailed, "of", totalTests, "test(s) FAILED.");
        else
            self:Log("All", totalTests, "tests successful. :)");
        end;
        return totalFailed;
    end;
    local tests = self.groups[testGroupName];
    if not tests then
        error("Tests not found for testGroup: '" .. tostring(testGroupName) .. "'");
    end;
    self:Log("Running testGroup", testGroupName);
    local failed = 0;
    for _, test in pairs(tests) do
        --local releaser = test:SyndicateTo(self);
        local result = test:Execute();
        if not result then
            test:Print(nil, "debug");
            failed = failed + 1;
        end;
        --releaser();
    end;
    if failed > 0 then
        self:LogError(failed, "of", #tests, "test(s) FAILED in testGroup:", testGroupName);
    else
        self:Log("All", #tests, "tests successful for testGroup:", testGroupName);
    end;
    return failed;
end;
