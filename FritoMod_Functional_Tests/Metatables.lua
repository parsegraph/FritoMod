local Suite = ReflectiveTestSuite:New("FritoMod_Functional.Metatables");

function Suite:TestDefensive()
    local defensive = Metatables.Defensive();

    Assert.Exception("DefensiveTable throws on missing method calls", function()
        defensive:MissingMethod();
    end);

    Assert.Exception("DefensiveTable throws on missing field accesses", function()
        local _ = defensive.MissingField;
    end);
end;

function Suite:TestForcedFunctions()
    local foo = Metatables.ForceFunctions();
    function foo:Bar(first)
        Assert.Equals(1, first, "Self argument was ignored");
    end;
    foo:Bar(1);
    foo.Bar(1);
end;

function Suite:TestForcedFunctionsCleansPreexistingArguments()
    local foo = {};
    function foo.Bar(first)
        assert(first == 1, "Self argument was ignored");
    end;
    Metatables.ForceFunctions(foo);
    foo:Bar(1);
    foo.Bar(1);
end;

function Suite:TestForcedMethods()
    local foo = Metatables.ForceMethods();
    function foo.Bar(self, first)
        assert(self == foo, "Self argument is included");
        assert(first == 1, "First argument is one");
    end;
    foo:Bar(1);
    foo.Bar(1);
end;

function Suite:TestForcedMethodsCleansPreexistingArguments()
    local foo = {}
    function foo.Bar(self, first)
        assert(self == foo, "Self argument is included");
        assert(first == 1, "First argument is one");
    end;
    Metatables.ForceMethods(foo);
    foo:Bar(1);
    foo.Bar(1);
end;
