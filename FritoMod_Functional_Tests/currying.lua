local Suite = ReflectiveTestSuite:New("FritoMod_Functional.currying");

function Suite:TestCurryAcceptsNilValues()
    local function Sum(a,b,c,d,e)
       a = a or 0;
       b = b or 0;
       c = c or 0;
       return a + b + c;
    end;
    local curried = Curry(Sum, 1, nil, 1);
    Assert.Equals(2, curried());
end;

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
