local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Tables");

Mixins.MutableIterationTests(Suite, Tables);

function Suite:NewIterable()
    return {
        A = 1, 
        BB = 2,
        CCC = 3,
    };
end;

function Suite:GetKeys()
    return {"A", "BB", "CCC"};
end;

function Suite:GetValues()
    return {1, 2, 3};
end;

function Suite:FalsyIterable()
    return { [false] = false };
end;

function Suite:EmptyIterable()
    return {};
end;
