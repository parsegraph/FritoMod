Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    -- Convenient return-types and a testManager.
    local CONSTANT = TestCase.returnTypes.CONSTANT;
    local EXCEPTION = TestCase.returnTypes.EXCEPTION;
    local COMPLEX = TestCase.returnTypes.COMPLEX;
    local testManager = TestManager:GetInstance();

    -- Name of your testGroup.
    local testGroup = "TestGroup";

    -- Utility method to add cases.
    function Add(testCaseOrName, ...)
        local testCase = testCaseOrName;
        if type(testCaseOrName) ~= "table" then
            -- TestCase(testName, returnType, returnValue, testFunc, ...);
            testCase = TestCase(testCaseOrName, ...);
        end;
        testManager:InsertTestCase(testGroup, testCase);
    end;

    Add("InsertTestCase", 
        CONSTANT, true,
        function()
            return true;
        end
    );

    Add("Sanity Check - Constant Test", 
        CONSTANT, true, 
        function()
            return true;
        end
    );

    Add("Sanity Check - Exception Test", 
        EXCEPTION, "An exception is raised",
        function()
            error("An exception is raised");
        end
    );

    Add("Sanity Check - Complex Test",
        COMPLEX, function(a, b, c)
            return a == "a" and b == "b" and c == "c";
        end,
        function()
            return "a", "b", "c";
        end
    );

    Add("Sanity Check - Clean function call in test cases",
        CONSTANT, 0, 
        function(...)
            return select("#", ...);
        end
    );

    Add("Sanity Check - Partial'd function test case",
        CONSTANT, "string",
        type, "This is a string."
    );

end);
