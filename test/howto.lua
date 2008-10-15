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

    -- Here's an example test. Feel free to remove it:
    Add("TestGroupName",
        CONSTANT, "ExpectedValue",
        function()
            -- Your logic should go here.
            return "ExpectedValue";
        end
    );

    -- TODO: Add your tests here.

end);
