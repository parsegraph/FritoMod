if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Tables";

    require "FritoMod_Collections_Tests/Mixins-TableTests";
    require "FritoMod_Collections_Tests/Mixins-MutableTableTests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Tables");

Mixins.TableTests(Suite, Tables);
Mixins.MutableTableTests(Suite, Tables);

function Suite:Table(t)
	if t == nil then
		return {};
	end;
	return t;
end;

