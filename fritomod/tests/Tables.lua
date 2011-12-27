if nil ~= require then
	require "fritomod/tests/Mixins-TableTests";
	require "fritomod/tests/Mixins-MutableTableTests";
	require "fritomod/tests/Mixins-ComparableIteration";
end;

local Suite = CreateTestSuite("fritomod.Tables");

Mixins.TableTests(Suite, Tables);
Mixins.MutableTableTests(Suite, Tables);

function Suite:Table(t)
	if t == nil then
		return {};
	end;
	return t;
end;

