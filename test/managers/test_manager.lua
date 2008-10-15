Environment:AddBootstrapper(Environment.runLevels.DEPLOY_CORE, function()
    local testManager = TestManager:GetInstance();
    local releaser = testManager:SetActiveTestGroup("managers.TestManager");

    testManager:AddConstantTest(true, function()
        return true;
    end);

    testManager:AddExceptionTest(
        "An exception is raised",
        function()
            error("An exception is raised");
        end
    );

    testManager:AddComplexTest(
        function(a, b, c)
            return a == "a" and b == "b" and c == "c";
        end,
        function()
            return "a", "b", "c";
        end
    );

    testManager:AddConstantTest(0, function(...)
        return select("#", ...);
    end);

    testManager:AddConstantTest("string",
        type, "This is a string."
    );

    releaser();

end);
