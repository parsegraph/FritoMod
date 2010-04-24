if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Lists";

    require "FritoMod_Collections_Tests/Mixins-MutableIteration";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Lists");

Mixins.MutableIterationTests(Suite, Lists);

function Suite:NewIterable()
    return {5,4,6};
end;

function Suite:SortedIterable()
    return {4,5,6};
end;

function Suite:MinValue()
    return 4;
end;

function Suite:MaxValue()
    return 6;
end;

function Suite:AverageValue()
    return 5;
end;

function Suite:SumValue()
    return 4+5+6;
end;

function Suite:GetKeys()
    return {1, 2, 3};
end;

function Suite:GetValues()
    return {5,4,6};
end;

function Suite:FalsyIterable()
    return {false};
end;

function Suite:EmptyIterable()
    return {};
end;
