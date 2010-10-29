if nil ~= require then
    require "tests/Mixins-TableTests";
    require "tests/Mixins-MutableTableTests";
    require "tests/Mixins-ComparableIteration";
end;

local Suite = CreateTestSuite("Tables");

Mixins.TableTests(Suite, Tables);
Mixins.MutableTableTests(Suite, Tables);

function Suite:Table(t)
	if t == nil then
		return {};
	end;
	return t;
end;

