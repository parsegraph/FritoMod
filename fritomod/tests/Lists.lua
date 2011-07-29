if nil ~= require then
    require "fritomod/tests/Mixins-ArrayTests";
    require "fritomod/tests/Mixins-MutableArrayTests";
    require "fritomod/tests/Mixins-ComparableIteration";
end;

local Suite = CreateTestSuite("fritomod.Lists");

function Suite:Array(...)
	return {...};
end;

Mixins.ComparableIterationTests(Suite, Lists);
Mixins.ArrayTests(Suite, Lists);
Mixins.MutableArrayTests(Suite, Lists);
