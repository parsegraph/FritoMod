TestManager = OOP.Class(Log, Mixins.Singleton);
local TestManager = TestManager;

function TestManager:Constructor(prefix)
    TestManager.super.Constructor(self, prefix or "TestManager");
    self.groups = {};
end;

-------------------------------------------------------------------------------
--
--  Convenience Test-Case Functions
--
-------------------------------------------------------------------------------

-- The active test-group lets you add test-cases without explicitly passing in
-- a test group. This method returns a way to undo your setting.
function TestManager:SetActiveTestGroup(testGroup)
    if not testGroup or testGroup == "" then
        error("testGroup is falsy");
    end;
    local oldTestGroup = self:GetActiveTestGroup();
    self.activeTestGroup = testGroup;
    return CurryMethod(self, "SetActiveTestGroup", oldTestGroup);
end;

function TestManager:GetActiveTestGroup()
    if not self.activeTestGroup then
        return "global";
    end;
    return self.activeTestGroup;
end;


-- Helper method for registering test methods with a test group. This sets the 
-- active test group to the specified test group, calls "registeringFunc", 
-- then releases the active test group.
function TestManager:WithActiveTestGroup(testGroup, registeringFunc)
    local releaser = self:SetActiveTestGroup(testGroup);
    registeringFunc(self);
    releaser();
end;

function TestManager:AddConstantTest(expectedConstant, testFunc, ...)
    self:InsertTestCase(self:GetActiveTestGroup(), TestCase(
        TestCase.returnTypes.CONSTANT, expectedConstant,
        testFunc, ...
    ));
end;

function TestManager:AddListTest(expectedList, testFunc, ...)
    self:InsertTestCase(self:GetActiveTestGroup(), TestCase(
        TestCase.returnTypes.COMPLEX, 
        function(list)
            if not list or type(list) ~= "table" then
                return false;
            end;
            if #expectedList ~= #list then
                return false;
            end;
            for i=1, #list do
                if list[i] ~= expectedList[i] then
                    return false;
                end;
            end;
            return true;
        end,
        testFunc, ...
    ));
end;

function TestManager:AddExceptionTest(expectedException, testFunc, ...)
    self:InsertTestCase(self:GetActiveTestGroup(), TestCase(
        TestCase.returnTypes.EXCEPTION, expectedException,
        testFunc, ...
    ));
end;

function TestManager:AddComplexTest(validatorFunc, testFunc, ...)
    self:InsertTestCase(self:GetActiveTestGroup(), TestCase(
        TestCase.returnTypes.COMPLEX, validatorFunc,
        testFunc, ...
    ));
end;

-------------------------------------------------------------------------------
--
--  Workhorse Test-Case Methods
--
-------------------------------------------------------------------------------

function TestManager:InsertTestCase(testGroupName, testCase)
    table.insert(self:GetTestGroup(testGroupName), testCase);
end;

function TestManager:GetTestGroup(testGroupName)
    testGroupName = testGroupName or "Global Tests";
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
