if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Tables";

    require "FritoMod_Collections_Tests/Mixins-MutableIteration";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Tables");

Mixins.MutableIterationTests(Suite, Tables);

function Suite:NewIterable()
    return {
        A = 1, 
        BB = 2,
        CCC = 3,
    };
end;

function Suite:MinValue()
	return 1;
end;

function Suite:AverageValue()
	return 2;
end;

function Suite:MaxValue()
	return 3;
end;

function Suite:SumValue()
	return 1+2+3;
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
