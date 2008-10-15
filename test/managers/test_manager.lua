-------------------------------------------------------------------------------
--
--  Test Cases: How-To
--
-------------------------------------------------------------------------------
--
-- Setting up a test-suite involves creating and adding test-cases. You can do
-- this using AddTest for the given TestManager instance.
--
-- AddTest(testGroupName, testCaseName, expectedReturnType, expectedReturnValue, testFunc, ...)
-- 
-- These are following returnTypes available:
-- TestCase.returnTypes = {
--     CONSTANT = "constant",
--     COMPLEX = "complex",
--     EXCEPTION = "exception",
-- };
--
-- A constant means you should give the exact value you expect.
-- An exception means you should give the exact exception you expect thrown.
-- A complex value means you should give a function that will be given the results. Notice
-- that complex values cannot be given exceptions.
--
-- The common idiom is to register this at DEPLOY_CORE stage with the Environment.
-- When in doubt, just use this as a template. Be sure to retain these instructions
-- so you can dessiminate this process!)
--
-- If you decide to use the convenience function, pass in either a TestCase, or the exact 
-- arguments used to make one. These mirror those used in AddTest:
--
-- TestCase(testName, returnType, returnValue, testFunc, ...);

Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    local testManager = TestManager:GetInstance();
    local testGroup = "managers.testManager";

    -- Utility method to add cases.
    function Add(testCaseOrName, ...)
        local testCase = testCaseOrName;
        if type(testCaseOrName) ~= "table" then
            testCase = TestCase(testCaseOrName, ...);
        end;
        testManager:InsertTestCase(testGroup, testCase);
    end;

    Add("InsertTestCase", 
        TestCase.returnTypes.CONSTANT, true,
        function()
            return true;
        end
    );

    Add("Sanity Check - Constant Test", 
        TestCase.returnTypes.CONSTANT, true, 
        function()
            return true;
        end
    );

    Add("Sanity Check - Exception Test", 
        TestCase.returnTypes.EXCEPTION, "An exception is raised",
        function()
            error("An exception is raised");
        end
    );

    Add("Sanity Check - Complex Test",
        TestCase.returnTypes.COMPLEX,
        function(a, b, c)
            return a == "a" and b == "b" and c == "c";
        end,
        function()
            return "a", "b", "c";
        end
    );

    Add("Sanity Check - Clean function call in test cases",
        TestCase.returnTypes.CONSTANT, 0, 
        function(...)
            return select("#", ...);
        end
    );

    Add("Sanity Check - Partial'd function test case",
        TestCase.returnTypes.CONSTANT, "string",
        type, "This is a string."
    );

end);
