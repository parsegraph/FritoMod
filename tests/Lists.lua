if nil ~= require then
    require "tests/Mixins-ArrayTests";
    require "tests/Mixins-MutableArrayTests";
    require "tests/Mixins-ComparableIteration";
end;

local Suite = CreateTestSuite("Lists");

function Suite:Array(...)
	return {...};
end;

Mixins.ComparableIterationTests(Suite, Lists);
Mixins.ArrayTests(Suite, Lists);
Mixins.MutableArrayTests(Suite, Lists);
