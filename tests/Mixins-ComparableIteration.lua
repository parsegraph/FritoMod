if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Mixins";
end;

if Mixins == nil then
    Mixins = {};
end;

function Mixins.ComparableIterationTests(Suite, lib)
	function Suite:TestNewComparator()
		local cmp=lib.NewComparator();
		Assert.Equals(-1, cmp(1,2));
		Assert.Equals(1, cmp(2,1));
		Assert.Equals(0, cmp(1,1));
	end;
end;
