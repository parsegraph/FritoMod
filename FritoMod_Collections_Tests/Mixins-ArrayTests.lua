if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Mixins";
end;

if Mixins == nil then
    Mixins = {};
end;

function Mixins.ArrayTests(Suite, library)
	assert(not rawget(Suite, "Table"), "ArrayTests is not compatible with TableTests");

	function Suite:ArrayCreator(...)
		return Curry(Suite, "Array", {...});
	end;

    function Suite:TestSuiteHasArray()
		Assert.Type("function", Suite.Array, "Suite has an 'Array' function");
		assert(Suite:Array(), "Array handles empty arguments");
		assert(Suite:Array(1,2,3), "Array returns a truthy value");
		assert(Suite:Array() ~= Suite:Array(), "Array returns unique iterables");
	end;

	function Suite:TestKeyIterator()
        local i = library.KeyIterator(Suite:Array("a","b","c"));
		Assert.Equals(1, i(), "Iterator finds first key");
		Assert.Equals(2, i(), "Iterator finds last key");
		Assert.Equals(3, i(), "Iterator finds last key");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
		Assert.Equals(nil, i(), "Iterator is idempotent");
	end;

	function Suite:TestValueIteratorHandlesFalsyKeys()
        local i = library.ValueIterator(Suite:Array(false));
		Assert.Equals(false, i());
	end;

	function Suite:TestIteratorHandlesEmptyIterable()
        local i = library.KeyIterator(Suite:Array());
		Assert.Equals(nil, i());
	end;

	function Suite:TestValueIterator()
        local i = library.ValueIterator(Suite:Array("a","b"));
		Assert.Equals("a", i(), "Iterator finds first key");
		Assert.Equals("b", i(), "Iterator finds last key");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
		Assert.Equals(nil, i(), "Iterator is idempotent");
	end;

	function Suite:TestValueIteratorHandlesRepeatedElements()
        local i = library.ValueIterator(Suite:Array(true,true));
		Assert.Equals(true, i(), "Iterator finds first element");
		Assert.Equals(true, i(), "Iterator finds second, repeated element");
		Assert.Equals(nil, i(), "Iterator returns nil beyond last key");
	end;

	function Suite:TestValueIteratorHandlesFalsyKey()
        local i=library.ValueIterator(Suite:Array(false));
		Assert.Equals(false, i());
	end;

	function Suite:TestValueIteratorHandlesEmptyIterable()
        local i = library.ValueIterator(Suite:Array());
		Assert.Equals(nil, i());
	end;

    function Suite:TestEquals()
		assert(library.Equals(Suite:Array(), Suite:Array()), 
			"Equals returns true for empty iterables");
		assert(library.Equals(Suite:Array(1,2,3), Suite:Array(1,2,3)), 
			"Equals returns true for equal iterables");
		assert(not library.Equals(Suite:Array(1,2,3), Suite:Array(1,2,2)), 
			"Equals returns false for equal iterables");
		assert(not library.Equals(Suite:Array(1,2,3), Suite:Array(1)),
			"Equals returns false for unequally sized iterables");
	end;

    function Suite:TestSize()
        Assert.Equals(0, library.Size(Suite:Array()), "Size reports zero for empty iterable");
        Assert.Equals(3, library.Size(Suite:Array(1,2,3)), "Size reports three for three-element iterable");
        Assert.Equals(1, library.Size(Suite:Array(false)), "Size reports one for iterable with one false element");
    end;

	function Suite:TestSum()
        Assert.Equals(2+4+6, library.Sum(Suite:Array(2,4,6)), "Sum returns correct value");
        Assert.Equals(0, library.Sum(Suite:Array()), "Sum returns 0 for empty array");
	end;

	function Suite:TestSumWithCustomConverter()
        Assert.Equals(-(2+4+6), library.Sum(Suite:Array(2,4,6), function(v)
			return -v;
		end));
	end;

	function Suite:TestMin()
        Assert.Equals(2, library.Min(Suite:Array(2,4,6)), "Min returns correct value");
	end;

	function Suite:TestMinThrowsOnEmptyArray()
		Assert.Exception("Min throws on empty array", library.Min, Suite:Array());
	end;

	function Suite:TestMax()
        Assert.Equals(6, library.Max(Suite:Array(2,4,6)), "Max returns correct value");
	end;

	function Suite:TestAverage()
        Assert.Equals(4, library.Average(Suite:Array(2,4,6)), "Average returns correct value");
	end;

    function Suite:TestBidiIteratorBehavesLikeIterator()
        local t = Suite:Array("a","b","c");
		local bi = library.BidiValueIterator(t);
		Assert.Equals("a", bi());
		Assert.Equals("b", bi());
		Assert.Equals("c", bi());
		Assert.Equals(nil, bi());
    end;

    function Suite:TestBidiIteratorCanGoBackwards()
        local t = Suite:Array("a","b","c");
		local i = library.BidiValueIterator(t);
		i();
		i();
		Assert.Equals("a", i:Previous());
	end;

	function Suite:TestBidiIteratorIsSafeOnBadPrevious()
		local t=Suite:Array("a");
		local i=library.BidiKeyIterator(t);
		Assert.Equals(nil, i:Previous());
    end;

	function Suite:TestBidiIteratorIgnoresRedundantNextCalls()
		local t=Suite:Array("a");
		local i=library.BidiValueIterator(t);
		Assert.Equals("a", i());
		Assert.Equals(nil, i());
		Assert.Equals(nil, i(), "BidiIterator is idempotent");
		Assert.Equals("a", i:Previous(), "BidiIterator ignores redundant calls and keeps it place");
    end;

	function Suite:TestBidiIteratorIgnoresRedundantPreviousCalls()
		local t=Suite:Array("a");
		local i=library.BidiValueIterator(t);
		Assert.Equals(nil, i:Previous());
		Assert.Equals(nil, i:Previous(), "BidiIterator is idempotent");
		Assert.Equals("a", i(), "BidiIterator ignores redundant calls and keeps it place");
    end;

end;
