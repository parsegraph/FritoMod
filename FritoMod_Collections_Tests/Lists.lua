if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Lists";

    require "FritoMod_Collections_Tests/Mixins-ArrayTests";
    require "FritoMod_Collections_Tests/Mixins-MutableArrayTests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Lists");

function Suite:Array(...)
	return {...};
end;

Mixins.ArrayTests(Suite, Lists);
Mixins.MutableArrayTests(Suite, Lists);
