if nil ~= require then
	require "fritomod/tests/Mixins-ArrayTests";
	require "fritomod/tests/Mixins-MutableArrayTests";
	require "fritomod/tests/Mixins-ComparableIteration";
end;

local Suite = CreateTestSuite("fritomod.Lists");

function Suite:Array(...)
	return {...};
end;

function Suite:TestListsContainsValue()
	local buttons={"LeftButton1", "RightButton"};
	assert(Lists.ContainsValue(buttons, "LeftButton", Strings.StartsWith));
end;

Mixins.ComparableIterationTests(Suite, Lists);
Mixins.ArrayTests(Suite, Lists);
Mixins.MutableArrayTests(Suite, Lists);
