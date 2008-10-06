Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    local testManager = TestManager:GetInstance();

    testManager:InsertTestCase("managers.testManager", TestCase("InsertTestCase",
        TestCase.returnTypes.CONSTANT, true,
        function()
            return true;
        end
    ));

    testManager:AddTest("managers.TestManager", "Sanity Check - Constant Test", 
        TestCase.returnTypes.CONSTANT, true, 
        function()
            return true;
        end
    );

    testManager:AddTest("managers.TestManager", "Sanity Check - Exception Test", 
        TestCase.returnTypes.EXCEPTION, "An exception is raised",
        function()
            error("An exception is raised");
        end
    );

    testManager:AddTest("managers.TestManager", "Sanity Check - Complex Test",
        TestCase.returnTypes.COMPLEX,
        function(a, b, c)
            return a == "a" and b == "b" and c == "c";
        end,
        function()
            return "a", "b", "c";
        end
    );

    testManager:AddTest("managers.TestManager", "Sanity Check - Clean function call in test cases",
        TestCase.returnTypes.CONSTANT, 0, 
        function(...)
            return select("#", ...);
        end
    );

    testManager:AddTest("managers.TestManager", "Sanity Check - Partial'd function test case",
        TestCase.returnTypes.CONSTANT, "string",
        type, "This is a string."
    );
end);
