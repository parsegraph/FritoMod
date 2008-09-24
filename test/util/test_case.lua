local testManager = TestManager:GetInstance();

testManager:AddTest("util.TestCase", "Assertion",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            return true;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Crash test - Wrong type",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            error("Exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Crash test - Wrong value",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            return false;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Assertion",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Crash test - Wrong type",
    TestCase.returnTypes.CONSTANT, false,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            return;
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Crash test - Wrong value",
    TestCase.returnTypes.CONSTANT, false,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Different exception");
        end)
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Assertion",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.COMPLEX, 
            function(a, b)
                return a == "a" and b == "b";
            end,
            function()
                return "a", "b"
            end
        )
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);

testManager:AddTest("util.TestCase", "Crash test - Wrong type",
    TestCase.returnTypes.CONSTANT, false,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.COMPLEX, 
            function(a, b)
                return a == "a" and b == "b";
            end,
            function()
                error("a", "b");
            end
        )
        testCase:DetachMasterLog();
        return testCase:Execute();
    end
);
