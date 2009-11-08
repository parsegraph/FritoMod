if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Functional/currying";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Functional.currying");

function Suite:TestCurry()
    local function Do(x, y)
        return x + y;
    end;
    Assert.Equals(3, Curry(Do, 1, 2)(), "Curry adds both arguments to the function");
    Assert.Equals(3, Curry(Do)(1, 2), "Curry handles no arguments properly");
    Assert.Equals(3, Curry(Do, 1)(2), "Curry handles split arguments properly");
end;

function Suite:TestCurryDoesntCurryPlainFunctions()
    local function Do(x, y)
        return x + y;
    end;
    Assert.Equals(Do, Curry(Do), "Curry doesn't needlessly curry functions");
end;

local function Sum(...)
    local sum = 0;
    for i=1, select("#", ...) do
        sum = sum + (select(i, ...) or 0);
    end;
    return sum;
end;

function Suite:TestCurryAcceptsNilValues()
    Assert.Equals(4, Curry(Sum, 1, 1, 1, 1)(), "Four one's");
    Assert.Equals(3, Curry(Sum, nil, 1, 1, 1)(), "X111 Test");
    Assert.Equals(3, Curry(Sum, 1, nil, 1, 1)(), "1X11 Test");
    Assert.Equals(3, Curry(Sum, 1, 1, nil, 1)(), "11X1 Test");
    Assert.Equals(3, Curry(Sum, 1, 1, 1, nil)(), "111X Test");
    Assert.Equals(2, Curry(Sum, nil, 1, 1, nil)(), "X11 Test");
    Assert.Equals(1, Curry(Sum, nil, 1)(), "X1 Test");
    Assert.Equals(2, Curry(Sum, 1, nil, 1)(), "1X1 Test");
    Assert.Equals(1, Curry(Sum, nil, nil, 1)(), "XX1 Test");
end;

function Suite:TestCurryAcceptsNilValuesWhenTheRealValuesAreFarApart()
    Assert.Equals(2, Curry(Sum, nil,1,nil,nil,nil,nil,nil,nil,nil,1)(), "Boss Nil-Value Curry Test");
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
