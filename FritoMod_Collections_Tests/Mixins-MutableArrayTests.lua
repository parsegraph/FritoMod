if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Mixins";
end;

if Mixins == nil then
    Mixins = {};
end;

function Mixins.MutableArrayTests(Suite, library)
	local lib=library;
	Assert.Type("table", library, "Library must be a table");

    function Suite:TestDelete()
        local iterable = Suite:Array(2,3,4);
        local v = library.Delete(iterable, 1);
		Assert.Equals(2, v);
        Assert.Equals(2, library.Size(iterable), "Iterable's size decreases after removal");
		assert(library.Equals(Suite:Array(3,4), iterable), "Elements are shifted");
    end;

    function Suite:TestClear()
        local iterable = Suite:Array(2,3,4);
        library.Clear(iterable);
        assert(library.IsEmpty(iterable), "Iterable is empty");
        assert(library.Equals(iterable, Suite:Array()), "Iterable is equal to an empty iterable");
    end;

	function Suite:TestInsert()
		local a=Suite:Array(2,3,true);
		local r=library.Insert(a, true);
		assert(library.Equals(Suite:Array(2,3,true,true), a), "Element is inserted into the iterable");
		r();
		assert(library.Equals(Suite:Array(2,3,true), a), "Element is successfully removed");
		Assert.Success("Remover doesn't throw when called again", r);
		assert(library.Equals(Suite:Array(2,3,true), a), "Remover does nothing when redundantly called");
	end;

    function Suite:TestInsertFunction()
        local function Do(a, b)
			Assert.Type("number", a, "a must a number");
			Assert.Type("number", b, "b must a number");
            return a + b;
        end;
        local iterable = Suite:Array();
        local r = library.InsertFunction(iterable, Do, 1);
        Assert.Equals(1, library.Size(iterable), "One function was inserted into the iterable");
		local f=library.Get(iterable, 1);
		Assert.Type("function", f);
		Assert.Equals(3, f(2), "Curried function is used");
        r();
        assert(library.IsEmpty(iterable), "Remover removes inserted function");
    end;

	function Suite:TestShuffle()
		local a=Suite:Array(1,2,3,4,5,6,7,8,9);
		lib.Shuffle(a);
		Assert.NotEquals(Suite:Array(1,2,3,4,5,6,7,8,9), a, "Shuffle should practically never produce an identical list");
	end;

	function Suite:TestSwap()
		local arr=Suite:Array("A","B");
		library.Swap(arr,1,2);
		assert(library.Equals(Suite:Array("B","A"), arr));
	end;

	local function DoSort(...)
		local u=Suite:Array(...);
		lib.Sort(u);
		return lib.ToTable(u);
	end;

	function Suite:TestSort()
		Assert.Equals({2}, DoSort(2), "One-element sort is easy");
	end;

	function Suite:TestSortWithTwoElements()
		Assert.Equals({1,2}, DoSort(1,2), "Presorted two-element");
		Assert.Equals({1,2}, DoSort(2,1), "Unsorted two-element");
	end;

	function Suite:TestSortWithThreeElements()
		Assert.Equals({1,2,3}, DoSort(1,2,3), "Presorted three-element");
		Assert.Equals({1,2,3}, DoSort(3,2,1), "Reverse order three-element");
		Assert.Equals({1,2,3}, DoSort(1,3,2));
		Assert.Equals({1,2,3}, DoSort(3,1,2));
	end;

	function Suite:TestSortWithLotsOfElements()
		Assert.Equals({1,2,3,4,5,6,7,8,9}, DoSort(1, 4, 5, 6, 7, 9, 3, 8, 2));
	end;

	return Suite;
end;
