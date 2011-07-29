local Suite = CreateTestSuite("fritomod.ReflectiveTestSuite");

function Suite:TestReflectiveTestSuiteIgnoresNonTestFunctions()
    local suite = ReflectiveTestSuite:New();

    function suite:TestSomething()
        return 2 + 2 == 4;
    end;

    function suite:NotATestFunction()
        error("Crash!");
    end;

    assert(suite:Run(), "Suite ignores non-test functions");
end;
