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

