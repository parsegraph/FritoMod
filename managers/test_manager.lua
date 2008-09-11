TestManager = {
    groups = {}
};
TestManager.log = Log:new(TestManager, "TestManager");
MixinLog(TestManager);
local TestManager = TestManager;

function TestManager:AddTest(testGroupName, testName, returnType, returnValue, testFunc, ...)
    self:InsertTest(testGroupName, TestCase:new(testName, returnType, returnValue, testFunc, ...));
end;

function TestManager:InsertTestCase(testGroup, testCase)
    table.insert(self.groups[testGroup], testCase);
end;

function TestManager:GetTestGroup(testGroupName)
    local testGroup = self.groups[testGroupName];
    if not testGroup then
        testGroup = {};
        self.groups[testGroupName] = testGroup;
    end;
    return testGroup;
end;

function TestManager:Run(testGroup)
    if not testGroup then
        self.log:Log("Running all tests.");
        local totalFailed = 0;
        for _, testGroup in pairs(self.groups) do
            totalFailed = totalFailed + self:Run(testGroup);
        end;
        if totalFailed > 0 then
            self.log:Log(totalFailed, "test(s) FAILED during all-testGroup run.");
        else
            self.log:Log("All tests successful for all testGroups. :)");
        end;
        return totalFailed;
    end;
    local tests = self.groups[testGroup];
    if not tests then
        error("Tests not found for testGroup: '" .. testGroup .. "'");
    end;
    self.log:Log("Running testGroup", testGroup);
    local failed = 0;
    for _, test in pairs(tests) do
        local result = test:Execute();
        if not result then
            test:Print();
            failed = failed + 1;
        end;
    end;
    if failed > 0 then
        self.log:Log(failed, "test(s) FAILED in testGroup:", testGroup);
    else
        self.log:Log("All tests successful for testGroup:", testGroup);
    end;
    return failed;
end;


