if nil ~= require then
    require "fritomod/Assert";
    require "fritomod/Tests";
end;

Mixins=Mixins or {};

function Mixins.ComparableIterationTests(Suite, lib)
	function Suite:TestNewComparator()
		local cmp=lib.NewComparator();
		Assert.Equals(-1, cmp(1,2));
		Assert.Equals(1, cmp(2,1));
		Assert.Equals(0, cmp(1,1));
	end;
end;
