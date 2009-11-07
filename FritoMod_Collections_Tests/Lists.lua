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
    return {"A", "BB", "CCC"};
end;

function Suite:GetKeys()
    return {1, 2, 3};
end;

function Suite:GetValues()
    return {"A", "BB", "CCC"};
end;

function Suite:FalsyIterable()
    return {false};
end;

function Suite:EmptyIterable()
    return {};
end;
