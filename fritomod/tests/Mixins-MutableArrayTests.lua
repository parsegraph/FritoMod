if nil ~= require then
	require "fritomod/Assert";
	require "fritomod/Tests";
	require "fritomod/Operator";
end;

Mixins=Mixins or {};

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

	function Suite:TestInsertRemoval()
		local a=Suite:Array(2,2,2);
		local r=library.Insert(a, 2);
		assert(library.Equals(Suite:Array(2,2,2,2), a), "Element is inserted into the iterable");
		r();
		assert(library.Equals(Suite:Array(2,2,2), a), "Element is successfully removed");
        r();
		assert(library.Equals(Suite:Array(2,2,2), a), "Remover only removes once.");
	end;

	function Suite:TestInsertRemovalIsSealed()
		local a=Suite:Array(2,2,2);
		local r=library.Insert(a, 2);
        local flag = Tests.Flag();
		r(flag.Raise);
        flag.AssertUnraised("List insertion remover must not accept additional arguments.");
		assert(library.Equals(Suite:Array(2,2,2), a), "Element is successfully removed");
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

	function Suite:TestRotate()
		local a=Suite:Array(1, 2, 3);
		lib.RotateRight(a, 1);
		Assert.Equals(Suite:Array(3,1,2), a);
		lib.RotateLeft(a, 2);
		Assert.Equals(Suite:Array(2,3,1), a);
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

	function Suite:TestBuildUsesIdenticalIterable()
		local fxns = {
			Curry(Operator.Add, 1),
			Curry(Operator.Add, 2),
		};
		local a=Suite:Array(unpack(fxns));
		Assert.Equals(4, library.Build(a, 1));
		library.Insert(a, Curry(Operator.Multiply, 2));
		Assert.Equals(8, library.Build(a, 1));
	end;

	function Suite:TestRemoveRemovesOnlyTheFirstElement()
		local a=Suite:Array(2,3,4,2);
		Assert.Equals(2, library.Remove(a, 2));
		library.AssertEqual(Suite:Array(3,4,2), a);
	end;

	function Suite:TestRemoveAtRemovesAValueAtALocation()
		local a=Suite:Array(1,2,3);
		Assert.Equals(2, library.RemoveAt(a, 2));
		library.AssertEqual(Suite:Array(1,3), a);
	end;

	function Suite:TestShiftRemovesAFewElementsFromAnArray()
		local a=Suite:Array(1,2,3);
		library.AssertEqual(Suite:Array(1), library.Shift(a));
		library.AssertEqual(Suite:Array(2,3), library.Shift(a, 2));
		library.AssertEqual(Suite:Array(), library.Shift(a));
	end;

	function Suite:TestShiftTrimLimitsTheSizeOfAnArray()
		local a=Suite:Array(1,2,3);
		library.AssertEqual(Suite:Array(1), library.ShiftTrim(a, 2));
		library.AssertEqual(Suite:Array(2,3), a);
	end;

	function Suite:TestPopRemovesAFewElementsFromAnArray()
		local a=Suite:Array(1,2,3);
		library.AssertEqual(Suite:Array(3), library.Pop(a));
		library.AssertEqual(Suite:Array(2,1), library.Pop(a, 2));
		library.AssertEqual(Suite:Array(), library.Pop(a));
	end;

	function Suite:TestPopTrimLimitsTheSizeOfAnArray()
		local a=Suite:Array(1,2,3);
		library.AssertEqual(Suite:Array(3), library.PopTrim(a, 2));
		library.AssertEqual(Suite:Array(1,2), a);
	end;

	function Suite:TestChange()
		local a=Suite:Array(42);
		local r=library.Change(a, 1, 99);
		Assert.Equals(Suite:Array(99), a);
		r();
		Assert.Equals(Suite:Array(42), a);
	end;

	return Suite;
end;
