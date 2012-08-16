if nil ~= require then
	require "fritomod/Assert";
	require "fritomod/Tests";
	require "fritomod/Operator";
end;

Mixins=Mixins or {};

function Mixins.ArrayTests(Suite, library)
	local lib=library;
	assert(not rawget(Suite, "Table"), "ArrayTests is not compatible with TableTests");

	function Suite:ArrayCreator(...)
		return Curry(Suite, "Array", ...);
	end;

	function Suite:TestSuiteHasArray()
		Assert.Type("function", Suite.Array, "Suite has an 'Array' function");
		assert(Suite:Array(), "Array handles empty arguments");
		assert(Suite:Array(1,2,3), "Array returns a truthy value");
		assert(Suite:Array() ~= Suite:Array(), "Array returns unique iterables");
	end;

	function Suite:TestAssertEquals()
		local a=Suite:ArrayCreator("a","b");
		local b=Suite:ArrayCreator("a","b");
		library.AssertEqual(a(),b());
		Assert.Exception("B superset of A", library.AssertEqual, a(), Suite:Array("a","b","c"));
		Assert.Exception("A superset of B", library.AssertEqual, Suite:Array("a","b","c"), a());
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

	function Suite:TestToTable()
		local a=Suite:Array(2,3,4);
		Assert.Equals({2,3,4}, library.ToTable(a));
		assert(a ~= library.ToTable(a), "ToTable must return a copy, not the original");
	end;

	function Suite:TestRandom()
		local a=Suite:Array(true);
		Assert.Equals(1, lib.Random(a));
		local r=lib.Random(Suite:Array(true,true,true));
		assert(r>=1 and r<=3, "r is a valid, randomly chosen value");
		Assert.Exception("Random throws on empty array",lib.Random, Suite:Array());
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

	function Suite:TestReverseIteratorReturnsValuesBackwards()
		local a=Suite:Array(3,2,1);
		local i=library.ReverseIterator(a);
		Assert.Equals({3,1}, {i()});
		Assert.Equals({2,2}, {i()});
		Assert.Equals({1,3}, {i()});
		Assert.Equals({}, {i()});
	end;

	function Suite:TestBuildBuildsAnObject()
		local fxns = {
			Curry(Operator.Add, 1),
			Curry(Operator.Add, 2),
		};
		local a=Suite:Array(unpack(fxns));
		Assert.Equals(4, library.Build(a, 1));
	end;

	function Suite:TestFilterReturnsASubset()
		local a=Suite:Array(1,2,3,4,5);
		library.AssertEquals(Suite:Array(1,3,5), library.FilterValues(a, function(v)
			return v % 2 == 1;
		end));
	end;

	function Suite:TestFilterWithOperator()
		Assert.Equals({3}, Lists.Filter({1,2,3}, Operator.GreaterThan, 2));
	end;

	function Suite:TestFilterWithMultipleFilters()
		local a=Suite:Array(1,2,3,4,5);
		library.AssertEquals(Suite:Array(3,5), library.FilterValues(a, {
			function(v) return v % 2 == 1 end,
			Curry(Operator.GreaterThan, 2)
		}));
	end;

	function Suite:TestSliceReturnsAPortionOfTheOriginal()
		local a=Suite:Array("a","b","c","d");
		library.AssertEquals(Suite:Array("b","c"), library.Slice(a, 2, 3));
	end;

	function Suite:TestHead()
		library.AssertEquals(Suite:Array("a","b"), library.Head(Suite:Array("a","b","c","d"), 2));
		library.AssertEquals(Suite:Array("b","c","d"), library.Head(Suite:Array("a","b","c","d"), -1));
	end;

	function Suite:TestTail()
		library.AssertEquals(Suite:Array("c","d"), library.Tail(Suite:Array("a","b","c","d"), 2));
		library.AssertEquals(Suite:Array("a","b","c"), library.Tail(Suite:Array("a","b","c","d"), -1));
	end;

	function Suite:TestReduce()
		Assert.Equals(3, library.Reduce(Suite:Array(1,1,1), 0, Operator.Add));
	end;

	function Suite:TestMarch()
		local results={};
		local function Do(a, b)
			table.insert(results, a-b);
		end;
		library.March(Suite:Array(1,2,3,4), Do);
		Assert.Equals({-1,-1,-1}, results);
		results={};
		library.ReverseMarch(Suite:Array(1,2,3,4), Do);
		Assert.Equals({1,1,1}, results);
	end;

end;

-- vim: set noet :
