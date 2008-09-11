TestManager:InsertTestCase("managers.TestManager", TestCase:new("InsertTestCase",
    TestCase.returnTypes.CONSTANT, true,
    function()
        return true;
    end
));

TestManager:AddTest("managers.TestManager", "Sanity Check: Constant", 
    TestCase.returnTypes.CONSTANT, true, 
    function()
        return true;
    end
);

TestManager:AddTest("managers.TestManager", "Sanity Check: Exception", 
    TestCase.returnTypes.EXCEPTION, "An exception is raised",
    function()
        error("An exception is raised");
    end
);

TestManager:AddTest("managers.TestManager", "Sanity Check: Complex",
    TestCase.returnTypes.COMPLEX,
    function(a, b, c)
        return a == "a" and b == "b" and c == "c";
    end,
    function()
        return "a", "b", "c";
    end
);

TestManager:AddTest("managers.TestManager", "Clean function call for test cases",
    TestCase.returnTypes.CONSTANT, 0, 
    function(...)
        return select("#", ...);
    end
);

TestManager:AddTest("managers.TestManager", "Partial'd function test case",
    TestCase.returnTypes.CONSTANT, "string",
    type, "This is a string."
);
