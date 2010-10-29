-- In this tutorial, I explain arrays, maps, and for-loops. I use a built-in function
-- called assert to prove my points:
if nil ~= require then
	require "Assert";
	require "Tests";
	require "ReflectiveTestSuite";
end;

local Suite=ReflectiveTestSuite:New("tutorial");

function Suite:TestAssert()
	-- assert takes a boolean value, and that boolean is false, throws an error. Because 
	-- of this, I can "assert" things to be true.
	assert(true);
end;

function Suite:TestBasicArrays()
	-- Arrays are tables. You make them like so.
	local array = {10,20,30};

	-- Arrays have a size.
	assert(#array == 3);

	-- They have values at indices
	assert(array[1] == 10);
	assert(array[2] == 20);

	-- You can use arbitrary code to access indices.
	assert(array[1 + 1] == 20);

	-- Values that are missing are nil
	assert(array[4] == nil);
	assert(array.foo == nil);

	-- You can reassign values as well.
	array[1] = 5;
	Assert.Equals({5,20,30}, array);

	-- You can add items as well
	table.insert(array, "No Time");
	Assert.Equals({5,20,30, "No Time"}, array);

	-- Adding at arbitrary positions is also easy. The old first element will be moved, not replaced.
	table.insert(array, 1, "First");
	Assert.Equals({"First",5,20,30, "No Time"}, array);

	-- You don't have to use table.insert. You can assign values directly.
	array[5] = "Last";
	Assert.Equals({"First",5,20,30, "Last"}, array);
	assert(array[5] == "Last");

	-- This length updates automatically.
	assert(#array == 5);

	-- You can remove values as well using table.remove. The removed value
	-- is returned:
	local removedValue = table.remove(array);
	assert(removedValue == "Last");
	assert(#array == 4);

	-- You can also remove table values directly.
	array[4] = nil;
	Assert.Equals({"First",5,20}, array);
	assert(#array == 3);

	-- Directly removing elements doesn't cause a shift
	array[1]=nil;
	Assert.Equals({nil,5,20}, array);
end;

function Suite:TestForLoop()
	local array={"A","B","C"};
	-- Iteration can be done using C-style for loops
	local s="";
	for index=1, #array do 
		s=s..array[index];
	end;
	Assert.Equals("ABC",s);

	local sum = 0;
	-- This for-loop is pretty powerful. You don't have to iterate over arrays.
	for index=1, 3 do
		sum = sum + index;
	end;
	assert(sum == 6);

	local c=Tests.Counter();
	for index=1, 3 do
		-- You can reassign the index, but it doesn't affect iteration. This loop
		-- executes three times.
		index = 1;
		c.Tick();
	end;
	c.Assert(3);

	sum = 0;
	-- The third value is the "step" It defaults to 1, but you can use any value.
	for index=1,3,2 do
		sum = sum + index;
	end;
	assert(sum == 4);

	sum = 0;
	-- Values that exceed the end boundary are not trimmed. This for-loop
	-- iterates only once.
	for index=1,3,100 do
	   sum = sum + index;
	end;
	assert(sum == 1);

	-- You can iterate backwards, too, using -1 as the step.
	local str ="";
	for index=3,1,-1 do
	   str = str .. tostring(index);
	end;
	assert(str == "321");
end;

function Suite:TestGenericFor()
	local array = {10,20,30};
	s="";
	for index, value in ipairs(array) do
		s=s.."("..index..":"..value..")";
	end;
	Assert.Equals("(1:10)(2:20)(3:30)",s);
end;

function Suite:TestMap()
	-- Tables also can have named values. The name is called a key; this is how 
	-- you refer to that value.
	local map = {
	   a = 2,
	   b = 3,
	   c = 4,
	   foo = "No Time"
	};
	assert(map.a == 2);
	assert(map.b == 3);

	-- You can use brackets to refer to named values.
	assert(map["a"] == 2);

	-- Brackets allow the values of variables to be used as keys.
	local key = "b";
	assert(map[key] == 3);

	-- But you can't use them using dot-notation. This refers to the value at the
	-- key of "key", not the variable.
	assert(map.key == nil);

	-- Brackets actually allow arbitrary code, not just variables
	assert(map["fo" .. "o"] == "No Time");

	-- Missing keys return nil
	assert(map.d == nil);

	-- Maps are tables, and all tables have a length. The length only refers to
	-- numbered values, so our map appears "empty"
	assert(#map == 0);

	-- Assignment is simple
	map.a = 10;

	-- Brackets work exactly the same with assignment
	map["fo" .. "o"] = "bar";
end;

function Suite:TestMapIteration()
	local map={
		a=1,
		b=2,
		c=3
	};
	local c={};
	-- "pairs" allows you to iterate over the values in a map. The keys are in an
	-- undefined order.
	for key, value in pairs(map) do
		c[key]=value;
	end;
end;

function Suite:TestMapsAreJustArrays()
	local map={
		a=1,
		b=2,
		c=3
	};
	-- Maps can also be used as arrays:
	table.insert(map, "Foo");
	assert(#map == 1);
	assert(map[1] == "Foo");
end;

function Suite:TestPairsIteratesEverything()
	local map={
		a=1,
		b=2,
		c=3
	};
	table.insert(map, true);
	-- However, pairs does not distinguish between named and numeric values
	local c={};
	for key, value in pairs(map) do
		c[key]=value;
	end;
	Assert.Equals(c,map);
end;

function Suite:TestIpairsIsDiscriminating()
	local map={
		a=1,
		b=2,
		c=3
	};
	table.insert(map, true);
	-- Only ipairs discriminates to *only* numeric values
	for key, value in ipairs(map) do
		assert(key==1);
		assert(value==true);
	end;
end;

function Suite:TestArraysCanBeMaps()
	-- Arrays can also be used as maps:
	local array = {10, 20, 30};
	array.foo = "bar";

	-- Named values never affect size ...
	assert(#array == 3);

	-- ... and insertions/removals never affect named values.
	table.insert(array, "No Time");
	table.remove(array);

	-- You can actually combine ordered values and named values
	-- when you make your table.
	local crazyBase = {10, 20, a = "Foo", b = "Bar", 30};

	-- It works. Really, in lua, there are no "arrays" or "maps", just
	-- tables that can act as both.
	assert(#crazyBase == 3);
	assert(crazyBase.a == "Foo");
	Assert.Equals({
		[1]=10,
		[2]=20,
		[3]=30,
		a="Foo",
		b="Bar"
	},crazyBase);
end;
