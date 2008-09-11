TestManager = {
    groups = {}
};
TestManager.log = Log:new(TestManager, "TestManager");
MixinLog(TestManager);
local TestManager = TestManager;

function TestManager:AddTest(testGroupName, testName, returnType, returnValue, testFunc, ...)
    self:InsertTestCase(testGroupName, TestCase:new(testName, returnType, returnValue, testFunc, ...));
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
        self.log:Log("Running all tests.");
        local totalFailed = 0;
        for testGroupName, testGroup in pairs(self.groups) do
            totalFailed = totalFailed + self:Run(testGroupName);
        end;
        if totalFailed > 0 then
            self.log:Log(totalFailed, "test(s) FAILED during all-testGroup run.");
        else
            self.log:Log("All tests successful for all testGroups. :)");
        end;
        return totalFailed;
    end;
    local tests = self.groups[testGroupName];
    if not tests then
        error("Tests not found for testGroup: '" .. tostring(testGroupName) .. "'");
    end;
    self.log:Log("Running testGroup", testGroupName);
    local failed = 0;
    for _, test in pairs(tests) do
        local result = test:Execute();
        if not result then
            test:Print();
            failed = failed + 1;
        end;
    end;
    if failed > 0 then
        self.log:Log(failed, "test(s) FAILED in testGroup:", testGroupName);
    else
        self.log:Log("All tests successful for testGroup:", testGroupName);
    end;
    return failed;
end;


