Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    local testManager = TestManager:GetInstance();
    local releaser = testManager:SetActiveTestGroup("util.TestCase");

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.CONSTANT, true, function()
            return true;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.CONSTANT, true, function()
            error("Exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.CONSTANT, true, function()
            return false;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.EXCEPTION, "Exception", function()
            return;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Different exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.COMPLEX,
            function(a, b)
                return a == "a" and b == "b";
            end,
            function()
                return "a", "b"
            end
        )
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    testManager:AddConstantTest(true, function()
        local testCase = TestCase(TestCase.returnTypes.COMPLEX,
            function(a, b)
                return a == "a" and b == "b";
            end,
            function()
                error("a", "b");
            end
        )
        testCase:DetachMasterLog();
        return testCase:Execute();
    end);

    releaser();

end);
