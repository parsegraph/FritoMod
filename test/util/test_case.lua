TestManager:AddTest("util.TestCase", "Successful Test Result: Constant",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            return true;
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "False Test Result: Constant expected, but different type returned",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            error("Exception");
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "False Test Result: Constant returned, but wrong value",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.CONSTANT, true, function()
            return false;
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "Successful Test Result: Exception",
    TestCase.returnTypes.CONSTANT, true,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Exception");
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "False Test Result: Exception expected, but value returned",
    TestCase.returnTypes.CONSTANT, false,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            return;
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "False Test Result: Exception returned, but wrong value",
    TestCase.returnTypes.CONSTANT, false,
    function()
        local testCase = TestCase:new("Test", TestCase.returnTypes.EXCEPTION, "Exception", function()
            error("Different exception");
        end)
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "Successful Test Result: Complex test",
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
        return testCase:Execute();
    end
);

TestManager:AddTest("util.TestCase", "Failed Test Result: Complex test result gets exception",
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
        return testCase:Execute();
    end
);
