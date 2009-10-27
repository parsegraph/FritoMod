local Suite = ReflectiveTestSuite:New("FritoMod_Functional.currying");

function Suite:TestForcedFunctionOnNoop()
    local foo = {};
    foo.bar = ForcedFunction(foo, function(value)
        Assert.Equals(1, value, "Value was passed appropriately");
    end);
    foo.bar(1);
end;

function Suite:TestForcedFunction()
    local foo = {};
    foo.bar = ForcedFunction(foo, function(value)
        Assert.Equals(1, value, "Value was passed appropriately");
    end);
    foo:bar(1);
end;

function Suite:TestForcedMethodOnNoop()
    local foo = {};
    foo.bar = ForcedMethod(foo, function(self, value)
        Assert.Equals(foo, self, "Self argument was passed appropriately");
        Assert.Equals(1, value, "Value was passed appropriately");
    end);
    foo:bar(1);
end;

function Suite:TestForcedMethod()
    local foo = {};
    foo.bar = ForcedMethod(foo, function(self, value)
        Assert.Equals(foo, self, "Self argument was passed appropriately");
        Assert.Equals(1, value, "Value was passed appropriately");
    end);
    foo.bar(1);
end;
