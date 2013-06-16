-- A large number of iteration functions for iterable objects, like tables, arrays, and
-- so forth.
if nil ~= require then
	require "fritomod/basic";
	require "fritomod/currying";
	require "fritomod/Operator";
	require "fritomod/Mixins";
end;

if Mixins == nil then
	Mixins = {};
end;

-- Mixes in a large suite of iteration functions to the specified library. This
-- mixin will not override any functions that are already defined in library.
--
-- The library should provide, at minimum, an Iterator function that returns a function.
-- This function should provide single-use iteration over a given iterable. All other
-- methods are guaranteed to work provided the Iterator function works.
--
-- This mixin provides suitable, working implementations of every method. While these are
-- sufficient for immediate use, many iterables have characteristics that enable much more
-- efficient operations than those defined here. This mixin makes a best-effort to prefer
-- inherited methods over the provided defaults.
--
-- library:table
--	 the target of this mixin
-- returns
--	 library
-- see
--	 Mixins.MutableIteration for more iteration methods if your iterables can be modified
function Mixins.Iteration(library)
	library=library or {};

	if library._NewIterable == nil then
		function library._NewIterable()
			if rawget(library, "New") ~= nil then
				return library.New();
			end;
			return {};
		end;
	end;
	local NewIterable = CurryNamedFunction(library, "_NewIterable");

	if library._CloneIterable == nil then
		function library._CloneIterable(iterable)
			if rawget(library, "Clone") then
				return library.Clone(iterable);
			else
				local t=NewIterable();
				for v in library.ValueIterator(iterable) do
					InsertInto(t, v);
				end;
				return t;
			end;
		end;
	end;
	local CloneIterable = CurryNamedFunction(library, "_CloneIterable");

	if library._InsertInto == nil then
		function library._InsertInto(iterable, key, value)
			if library.Bias() == "table" then
				if library.InsertPair then
					return library.InsertPair(iterable, key, value);
				else
					iterable[key] = value;
					return;
				end;
			end;
			if type(key) ~= "number" then
				if rawget(library, "Set") ~= nil then
					return library.Set(iterable, key, value);
				end;
				assert(type(iterable) == "table", "Iterable is not a table");
				iterable[key] = value;
				return CurryNamedFunction(library, "Delete", iterable, key);
			end;
			if rawget(library, "Insert") ~= nil then
				return library.Insert(iterable, value);
			end;
			assert(type(iterable) == "table", "Iterable is not a table");
			table.insert(iterable, value);
			return CurryFunction(RemoveValueFromTable, iterable, value);
		end;
	end;
	local InsertInto = CurryNamedFunction(library, "_InsertInto");

	if library.Bias == nil then
		-- Returns the bias of the library - whether the iterable is expected to behave like
		-- an array or like a list. This will affect the behavior of some functions, so it's
		-- important to get this right. I think most libraries will be biased towards arrays.
		--
		-- Only use this function to disambiguate an otherwise unclear situation. For example,
		-- non-numeric keys cannot typically be used by arrays, so the iterable should be treated
		-- as a table, regardless of the bias. In other words, try to behave properly, instead
		-- of punishing designers choosing for the wrong bias.
		--
		-- returns
		--	 "table" or "array"
		function library.Bias()
			-- The other option is "table"
			return "array";
		end;
	end;

	--  Returns a function that tests for equality. The created function
	--  should expect -anything- and return true if and only if they are
	--  equal.
	--
	--  testFunc, ...
	--	  optional. a function of the signature testFunc(a, b) that
	--	  returns either a boolean value indicating whether the values are
	--	  equal, or a numeric value. Numeric values are interpreted as follows:
	--
	--	  * numericValue == 0 means the values given are equal
	--	  * numericValue < 0 means a is less than b
	--	  * numericValue > 0 means b is greater than b
	if nil == library.NewEqualsTest then
		function library.NewEqualsTest(testFunc, ...)
			if not testFunc then
				return Operator.Equals;
			end;
			testFunc = Curry(testFunc, ...);
			return function(...)
				local r=testFunc(...);
				if type(result) == "number" then
					return result == 0;
				end;
				return Bool(result);
			end;
		end;
	end;

	-- Returns a function that compares two elements. The returned function
	-- should behave as the testFunc described in NewEqualsTest
	if nil == library.NewComparator then
		function library.NewComparator(comparatorFunc, ...)
			if not comparatorFunc then
				return Operator.Compare;
			end;
			return Curry(comparatorFunc, ...);
		end;
	end;

	-- Returns an iterator that iterates over the pairs in iterable.
	--
	-- If your library does not support creating new iterables, this should also
	-- support iterating over an array. This lets functions that depend on subsets and
	-- created iterables to still work.
	--
	-- iterable
	--	 a value that is iterable using this function
	-- returns
	--	 a function that returns a pair in iterable each time it is called. When
	--	 it exhausts the pairs in iterable, it permanentlys returns nil.
	if library.Iterator == nil then
		-- This function must be explicitly implemented by clients.
	end;

	-- Retrieves the value for the specified key in the specified iterable.
	--
	-- This is an optional operation.
	--
	-- iterable
	--	 an iterable usable by this library
	-- key
	--	 the key that will be searched for in this library
	if library.Get == nil then
		-- This function must be explicitly implemented by clients.
	end;

	-- Returns whether this library supports random access.
	--
	-- Generally speaking, one-shot iterators do not, and
	-- table-backed iterators do.
	if library.SupportsGet == nil then
		function library.SupportsGet()
			return Bool(rawget(library, "Get"));
		end;
	end;

	if library.Next == nil then
		-- This optional function must be explicitly implemented by clients.
	end;

	if library.Previous == nil then
		-- This optional function must be explicitly implemented by clients.
	end;

	if library.Length == nil then
		-- This optional function must be explicitly implemented by clients.
	end;

	if nil == rawget(library, "Head") then
		function library.Head(iterable, count)
			if count >= 0 then
				local i=0;
				return library.FilterPairs(iterable, function()
					i=i+1;
					return i <= count;
				end);
			else
				local i=0;
				count=-count;
				return library.FilterPairs(iterable, function()
					i=i+1;
					return i > count;
				end);
			end;
		end;
	end;

	if nil == rawget(library, "Tail") then
		function library.Tail(iterable, count)
			local length=library.Size(iterable);
			if count >= 0 then
				local i=0;
				return library.FilterPairs(iterable, function()
					i=i+1;
					return i > length - count;
				end);
			else
				-- We add here because count is already negative.
				return library.Head(iterable, length+count);
			end;
		end;
	end;

	if nil == rawget(library, "Modulo") then
		function library.Modulo(iterable, index)
			local length=library.Size(iterable);
			
			if length == 0 then
				return nil;
			end;
			index = (index % length) + 1;
		end;
	end;

	-- Returns whether the two iterables contain the same elements, in the same order.
	--
	-- This option is applicable to keys or values.
	--
	-- iterable, otherIterable
	--	 the two values that are compared against
	-- testFunc, ...
	--	 optional. the function that performs the comparison, with the signature
	--	 testFunc(item, otherItem) where the items are the keys, values.
	--	 It should return a truthy value if the two values match. If it returns a numeric
	--	 value, then only zero indicates a match.
	-- returns
	--	 true if the iterables contain equal items in the same order, otherwise false
	Mixins.KeyValueOperation(library, "%ssEqual", function(iteratorFunc, iterable, otherIterable, testFunc, ...)
		testFunc = library.NewEqualsTest(testFunc, ...);
		local iterator = iteratorFunc(iterable);
		local otherIterator = iteratorFunc(otherIterable);
		while true do
			local item = iterator();
			local otherItem = otherIterator();
			if item == nil or otherItem == nil then
				return item == otherItem;
			end;
			if not testFunc(otherItem, item) then
				return false;
			end;
		end;
	end);


	-- Returns whether the two iterables contain the same pairs, in the same order.
	--
	-- iterable, otherIterable
	--	 the two values that are compared against
	-- testFunc, ...
	--	 optional. the function that performs the comparison, with the signature
	--	 testFunc(otherKey, otherValue, key, value) where the items are the keys,
	--	 values. It should return a truthy value if the two values match. If it
	--	 returns a numeric value, then only zero indicates a match.
	-- returns
	--	 true if the iterables contain equal pairs in the same order, otherwise false
	if nil == rawget(library, "PairsEqual") then
		function library.PairsEqual(iterable, otherIterable, testFunc, ...)
			if not testFunc and select("#", ...) == 0 then
				testFunc = function(otherKey, otherValue, key, value)
					return key == otherKey and value == otherValue;
				end;
			else
				testFunc = library.NewEqualsTest(testFunc, ...);
			end;
			local iterator = library.Iterator(iterable);
			local otherIterator = library.Iterator(otherIterable);
			while true do
				local key, value = iterator();
				local otherKey, otherValue = otherIterator();
				if key == nil or otherKey == nil then
					return key == otherKey;
				end;
				if not testFunc(otherKey, otherValue, key, value) then
					return false;
				end;
			end;
		end;
	end;

	if nil == rawget(library, "Equals") then
		library.Equals = CurryNamedFunction(library, "PairsEqual");
	end;

	if library.AssertEqual == nil then
		function library.AssertEqual(iterable, otherIterable)
			if library.Bias() == "table" then
				local i=library.Iterator(iterable);
				local j=library.Iterator(otherIterable);
				while true do
					local key = i();
					if key == nil then
						assert(j() == nil, "Tables do not have equal keys");
						return;
					end;
					assert(j() ~= nil, "Tables do not have equal keys");
					local v1 = library.Get(iterable, key);
					local v2 = library.Get(otherIterable, key);
					assert(v1==v2, "Values are not equal. v1: " .. tostring(v1) .. ", v2: " .. tostring(v2));
				end;
			else
				local i=library.Iterator(iterable);
				local j=library.Iterator(otherIterable);
				while true do
					local k1,v1=i();
					local k2,v2=j();
					assert(k1==k2, "Keys are not equal. k1: " .. tostring(k1) .. ", k2: " .. tostring(k2));
					assert(v1==v2, "Values are not equal. v1: " .. tostring(v1) .. ", v2: " .. tostring(v2));
					if k1 == nil then
						return;
					end;
				end;
			end;
		end;
	end;
	library.AssertEquals=CurryNamedFunction(library, "AssertEqual");

	if library.KeyIterator == nil then
		-- Returns an iterator that iterates over the keys in iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 an iterator that returns each key in iterable
		function library.KeyIterator(iterable)
			local iterator = library.Iterator(iterable);
			return function()
				local key = iterator();
				return key;
			end;
		end;
	end;

	if library.ValueIterator == nil then
		-- Returns an iterator that iterates over the values in iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 an iterator that returns each value in iterable
		function library.ValueIterator(iterable)
			local iterator = library.Iterator(iterable);
			return function()
				local _, value = iterator();
				return value;
			end;
		end;
	end;

	if library.PairIterator == nil then
		library.PairIterator = CurryNamedFunction(library, "Iterator");
	end;

	Mixins.KeyValuePairOperation(library, "Bidi%sIterator", function(chooser, iterable)
		local index = 0;
		local Get;
		local keys;
		if library.SupportsGet() then
			keys = library.Keys(iterable);
			Get = function()
				local key = keys[index];
				return key, library.Get(iterable, key);
			end;
		else
			local iterator = library.Iterator(iterable);
			local copy = {};
			keys = {};
			Get = function()
				local key, value;
				if index > #keys then
					key, value = iterator();
					if key == nil then
						return;
					end;
					table.insert(keys, key);
					copy[key] = value;
					return key, value;
				end;
				if index < 0 then
					index = 0;
					return;
				end;
				return keys[index], copy[keys[index]];
			end;
		end;
		local reachedEnd = false;
		local key, value;
		local iterator = {
			Next = function()
				if reachedEnd and index > #keys then
					return;
				end;
				index = index + 1;
				key, value = Get();
				if key == nil then
					reachedEnd = true;
					return;
				end;
				return chooser(key, value);
			end,
			Previous = function()
				if index == 0 then
					return;
				end;
				index = index - 1;
				reachedEnd=false;
				return chooser(Get());
			end,
			Key = function()
				return key;
			end,
			Value = function()
				return value;
			end
		};
		setmetatable(iterator, {
			__call = iterator.Next
		});
		return iterator;
	end);

	if library.BidiIterator == nil then
		library.BidiIterator = CurryNamedFunction(library, "BidiPairIterator");
	end;

	-- Returns an iterator that returns decorated items from the specified iterable. The
	-- items are decorated using the specified decorator function. This does not affect the
	-- underlying iterable.
	--
	-- This operation is applicable to keys, values, or pairs.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- decoratorFunc, ...
	--	 the function that modifies the given items, returning the modified items
	-- returns
	--	 an iterator that behaves as specified above
	Mixins.KeyValuePairOperation(library, "Decorate%sIterator", function(chooser, iterable, decoratorFunc, ...)
		decoratorFunc = Curry(decoratorFunc, ...);
		local iterator = library.Iterator(iterable);
		return function()
			local key, value = iterator();
			if key == nil then
				return nil;
			end;
			return decoratorFunc(chooser(key, value));
		end;
	end);

	if library.DecorateIterator == nil then
		library.DecorateIterator = CurryNamedFunction(library, "DecoratePairIterator");
	end;

	-- Returns an iterator that only returns results that are approved by the specified
	-- filter function. This does not affect the underlying iterable.
	--
	-- This operation is applicable to keys, values, or pairs.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- filterFunc, ...
	--	 the function that evaluates the given items, returning true if they should be included
	--	 in the specified iterator
	-- returns
	--	 an iterator that behaves as specified above
	Mixins.KeyValuePairOperation(library, "Filtered%sIterator", function(chooser, iterable, filterFunc, ...)
		filterFunc = Curry(filterFunc, ...);
		local iterator = library.Iterator(iterable);
		local function DoIteration()
			local key, value = iterator();
			if key == nil then
				return nil;
			end;
			if filterFunc(chooser(key, value)) then
				return chooser(key, value);
			end;
			return DoIteration();
		end;
		return DoIteration;
	end);

	if library.FilteredIterator == nil then
		library.FilteredIterator = CurryNamedFunction(library, "FilteredPairIterator");
	end;

	if library.ReverseIterator == nil then
		-- Returns an iterator that iterates over the pairs in the specified iterable, in reverse order.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 an iterator that returns each pair in iterable, in reverse
		function library.ReverseIterator(iterable)
			local copy = {};
			local keys = {};
			library.EachPair(iterable, function(key, value)
				copy[key] = value;
				table.insert(keys, 1, key);
			end);
			local index = 0;
			return function()
				if index == #keys then
					return;
				end;
				index = index + 1;
				local key = keys[index];
				return key, copy[key];
			end;
		end;
	end;

	if library.ReverseKeyIterator == nil then
		-- Returns an iterator that iterates over the keys in the specified iterable, in reverse order.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 an iterator that returns each key in iterable, in reverse
		function library.ReverseKeyIterator(iterable)
			local iterator = library.ReverseIterator(iterable);
			return function()
				local key, _ = iterator();
				return key;
			end;
		end;
	end;

	if library.ReverseValueIterator == nil then
		-- Returns an iterator that iterates over the values in the specified iterable, in reverse order.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 an iterator that returns each value in iterable, in reverse
		function library.ReverseValueIterator(iterable)
			local iterator = library.ReverseIterator(iterable);
			return function()
				local _, value = iterator();
				return value;
			end;
		end;
	end;

	-- Iterates over items in the specified iterable, sorted by the specified comparator.
	--
	-- This is different from a sort operation because no sorting operation is performed
	-- on the specified iterable. It also allows sorted iteration over iterables that
	-- may not otherwise support ordering, like keyed tables.
	Mixins.KeyValuePairOperation(library, "%sSortedIterator", function(chooser, iterable, compareFunc, ...)
		assert(library.SupportsGet(), "Library does not support random access");
		compareFunc=library.NewComparator(compareFunc, ...);
		local keys = library.Keys(iterable);
		local _, usePairs = chooser(true, true);
		if usePairs then
			table.sort(keys, function(a, b)
				return compareFunc(
					a, library.Get(iterable, a),
					b, library.Get(iterable, b)
				);
			end);
		else
			table.sort(keys, function(a, b)
				a = chooser(a, library.Get(iterable, a));
				b = chooser(b, library.Get(iterable, b));
				return compareFunc(a, b) < 0;
			end);
		end;
		local i = 0;
		return function()
			if i >= #keys then
				return;
			end;
			i = i + 1;
			return keys[i], library.Get(iterable, keys[i]);
		end;
    end);

	-- Iterates over all items in the specified iterable.
	--
	-- This operation is applicable for either keys, values, or pairs.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- func, ...
	--	 the function that is called for every item in the iterable
	Mixins.KeyValuePairOperation(library, "Each%s", function(chooser, iterable, func, ...)
		func = Curry(func, ...);
		for key, value in library.Iterator(iterable) do
			func(chooser(key, value));
		end;
	end);

	if library.Each == nil then
		library.Each = CurryNamedFunction(library, "EachValue");
	end;

	-- Iterates over all items in the specified iterable, collecting results
	-- in a returned object.
	--
	-- This operation creates and modifies a iterable. If the underlying library does not
	-- support mutable iterables, then a table is created and returned.
	--
	-- This operation is applicable for either keys, values, or pairs.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- func, ...
	--	 the function that is called for every pair in the iterable
	-- returns
	--	 a iterable of results from the specified func
	Mixins.KeyValuePairOperation(library, "Map%ss", function(chooser, iterable, func, ...)
		func = Curry(func, ...);
		local results = NewIterable();
		for key, value in library.Iterator(iterable) do
			local result = func(chooser(key, value));
			if result ~= nil then
				InsertInto(results, key, result);
			end;
		end;
		return results;
	end);

	if library.Map == nil then
		library.Map = CurryNamedFunction(library, "MapValues");
	end;

	if library.CallEach == nil then
		-- Calls every function in the specified iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- ...
		--	 arguments that are passed to each function in iterable
		-- throws
		--	 if any value in iterable is not callable
		function library.CallEach(iterable, ...)
			for func in library.ValueIterator(iterable) do
				assert(IsCallable(func), "func is not callable. Type: " .. type(func));
				func(...);
			end;
		end;
	end;

	if library.SafeCallEach == nil then
		-- Calls every function in the specified iterable. The iteration is done over a clone,
		-- rather than the original iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- ...
		--	 arguments that are passed to each function in iterable
		-- throws
		--	 if any value in iterable is not callable
		function library.SafeCallEach(iterable, ...)
			return library.CallEach(CloneIterable(iterable), ...);
		end;
	end;

	if library.ReverseCallEach == nil then
		-- Calls every function in the specified iterable in reverse.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- ...
		--	 arguments that are passed to each function in iterable
		-- throws
		--	 if any value in iterable is not callable
		function library.ReverseCallEach(iterable, ...)
			for func in library.ReverseValueIterator(iterable) do
				assert(IsCallable(func), "func is not callable. Type: " .. type(func));
				func(...);
			end;
		end;
	end;

	if library.MapCall == nil then
		-- Runs every function in the specified iterable, returning the results of each.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- ...
		--	 arguments that are passed to each function in iterable
		-- returns
		--	 all non-nil results from the called functions
		-- throws
		--	 if any value in iterable is not callable
		function library.MapCall(iterable, ...)
			local args = { ... };
			return library.MapValues(iterable, function(func)
				assert(IsCallable(func), "func is not callable. Type: " .. type(func));
				return func(unpack(args));
			end);
		end;
	end;

	if library.SafeMapCall == nil then
		-- Runs every function in the specified iterable, returning the results of each. The
		-- iterable used is a clone, so removals are safe.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- ...
		--	 arguments that are passed to each function in iterable
		-- returns
		--	 all non-nil results from the called functions
		-- throws
		--	 if any value in iterable is not callable
		function library.SafeMapCall(iterable, ...)
			return library.MapCall(CloneIterable(iterable), ...);
		end;
	end;

	-- Returns a subset of the specified iterable. Pairs are included if the specified
	-- func evaluates to true for the given item.
	--
	-- This operation creates and modifies a iterable. If the underlying library does not
	-- support mutable iterables, then a table is created and returned.
	--
	-- The subset should be in a form most appropriate for the library's iterable type. For
	-- example, a library that handles lists should not leave gaps between elements.
	--
	-- This operation is applicable for either keys, values, or pairs.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- func, ...
	--	 the function that is called for every pair in the iterable. A truthy value will
	--	 include the given pair in the returned subset
	-- returns
		--	 an iterable containing elements that evaluated to true, according to the specified func
	Mixins.KeyValuePairOperation(library, "Filter%ss", function(chooser, iterable, func, ...)
		local filtered = NewIterable();
		if not IsCallable(func) and select("#", ...)==0 and type(func) == "table" then
			for key, value in library.Iterator(iterable) do
				local doInsert=true;
				for _, filter in ipairs(func) do
					if not filter(chooser(key, value)) then
						doInsert=false;
						break
					end;
				end;
				if doInsert then
					InsertInto(filtered, key, value);
				end;
			end;
		else
			func = Curry(func, ...);
			for key, value in library.Iterator(iterable) do
				if func(chooser(key, value)) then
					InsertInto(filtered, key, value);
				end;
			end;
		end;
		return filtered;
	end);

	if library.Filter == nil then
		library.Filter = CurryNamedFunction(library, "FilterValues");
	end;

	if library.Slice == nil then
		-- Returns a copy of the original iterable, containing only the items that were between
		-- the first and last values, inclusive. This is useful for creating portions of an original
		-- iterable. Since a comparator is used, first and last do not need to be numeric; they may
		-- be any value that can be compared with any other value in the iterable.
		--
		-- This version of slice is more like Python slices than Java sublists. It does not
		-- support negative indices. It also clones the original, so changes to the slice do not
		-- affect the original iterable.
		--
		-- iterable
		--	 the iterable from which a slice is returned
		-- first
		--	 the first or minimum value that is included, inclusive. If nil, all values below last
		--	 are included.
		-- last
		--	 the last or maximum value that is included, inclusive. If nil, all values above first
		--	 are included.
		-- compareFunc, ...
		--	 the comparator that is called for every value to compare with the indices.
		function library.Slice(iterable, first, last, compareFunc, ...)
			compareFunc=library.NewComparator(compareFunc, ...);
			local pastFirst=false;
			local pastLast=false;
			if last==nil then
				-- If last isn't given, then we go from the start to last.
				last=first;
				first=nil;
			end;
			if first==nil then
				pastLast=true;
			end;
			return library.FilterPairs(iterable, function(k)
				if pastLast then
					-- We're dead, always return false.
					return false;
				end;
				if not pastFirst and compareFunc(k, first) >= 0 then
					pastFirst=true;
				end;
				if pastFirst and compareFunc(k, last) > 0 then
					pastLast=true;
				end;
				return pastFirst and not pastLast;
			end);
		end;
	end;
	if nil == rawget(library, "Sub") then
		library.Sub = CurryNamedFunction(library, "Slice");
	end;
	if nil == rawget(library, "Snippet") then
		library.Snippet = CurryNamedFunction(library, "Slice");
	end;

	if library.DefaultReduce == nil then
		-- A default reduce function that tries to do the right thing for various types.
		--
		-- aggregate
		--	 Optional. The starting aggregate value.
		-- value
		--	 the value that is added to the specified aggregate
		-- return
		--	 the new aggregate
		-- throws
		--	 if value is an unsupported type, or if the types of aggregate and value are
		--	 incompatible
		function library.DefaultReduce(aggregate, value, ...)
			assert(value ~= nil, "Value is nil");
			if type(value) == "boolean" then
				if aggregate == nil then
					aggregate = true;
				end;
				return aggregate and value;
			end;
			if type(value) == "number" then
				if aggregate == nil then
					aggregate = 0;
				end;
				return aggregate + value;
			end;
			if type(value) == "string" then
				if aggregate == nil then
					aggregate = "";
				end;
				return aggregate .. " " .. value;
			end;
			if type(value) == "table" then
				if aggregate == nil then
					aggregate = {};
				end;
				if #value then
					for i=1, #value do
						table.insert(aggregate, value[i]);
					end;
				else
					for key, newValue in pairs(value) do
						aggregate[key] = newValue;
					end;
				end;
				return aggregate;
			end;
			if type(value) == "function" then
				return value(aggregate);
			end;
			error("Unsupported value type. Type: " .. type(value));
		end;
	end;

	if library.ReducePairs == nil then
		-- Iterates over the specified iterable, aggregating the pairs.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- initialKey, initialValue
		--	 initial values
		-- func, ...
		--	 the function that is called for every pair in the iterable. It should expect the signature
		--	 func(aggregateKey, aggregateValue, key, value) and return a new aggregate key and aggregate
		--	 value.
		-- returns
		--	 the final aggregate key and value
		function library.ReducePairs(iterable, initialKey, initialValue, func, ...)
			func = Curry(func, ...);
			local aggregateKey, aggregateValue = initialKey, initialValue;
			for key, value in library.Iterator(iterable) do
				aggregateKey, aggregateValue = func(aggregateKey, aggregateValue, key, value);
			end;
			return aggregateKey, aggregateValue;
		end;
	end;

	-- Iterates over the specified iterable, aggregating the keys. If func is not provided, a default
	-- reduce function is used.
	--
	-- This operation is valid for either keys or values.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- initial
	--	 initial aggregate value
	-- func, ...
	--	 the function that is called for every item in the iterable. It should expect the signature
	--	 func(aggregate, item) and return a new aggregate value
	--	 value.
	-- returns
	--	 the final aggregate
	Mixins.KeyValueOperation(library, "Reduce%ss", function(iterator, iterable, initial, func, ...)
		if not func and select("#", ...) == 0 then
			func = library.DefaultReduce;
		end;
		func = Curry(func, ...);
		local aggregate = initial;
		for item in iterator(iterable) do
			aggregate = func(aggregate, item);
		end;
		return aggregate;
	end);

	if library.Reduce == nil then
		library.Reduce = CurryNamedFunction(library, "ReduceValues");
	end;

	-- "Marches" down an iterable, calling the given function with each pair of values.
	--
	-- For example, Lists.March({1,2,3,4}, func, ...) is equivalent to:
	-- func(1,2, ...)
	-- func(2,3, ...)
	-- func(3,4, ...)
	Mixins.Overridable(library, "March", function(iterable, func, ...)
		local iterator=library.ValueIterator(iterable);
		local a, b=iterator(), iterator();
		while b~=nil do
			func(a, b, ...);
			a=b;
			b=iterator();
		end;
		return a;
	end);

	-- func(4, 3, ...)
	-- func(3, 2, ...)
	-- func(2, 1, ...)
	Mixins.Overridable(library, "ReverseMarch", function(iterable, func, ...)
		local iterator=library.ReverseValueIterator(iterable);
		local a, b=iterator(), iterator();
		while b~=nil do
			func(a, b, ...);
			a=b;
			b=iterator();
		end;
		return a;
	end);

	if library.Build == nil then
		-- Constructs some value by chaining the result through each function.
		--
		-- This function is useful for allowing a process to be constructed dynamically. Since the process
		-- uses a plain iterable, it may be accessed freely. Since the initial value is passed in when this
		-- method is called, it may be used to construct many objects.
		--
		-- I believe the flexibility of this function makes it the preferred glue for builder functions,
		-- greatly surpassing the object in ease-of-use and extensibility.
		--
		-- iterable
		--	 an iterable of callables. Each callable will receive the current value. It should modify
		--	 the value, and return the new value. Most often, this will be the same value. If nil is
		--	 returned, the original value is returned.
		--
		--	 The iterable is not modified by this function
		-- value
		--	 the initial value
		-- returns
		--	 the constructed value
		-- see also
		--	 Reduce, Curry
		function library.Build(iterable, v)
			for fxn in library.ValueIterator(iterable) do
				local rv = fxn(v);
				if rv ~= nil then
					v=rv;
				end;
			end;
			return v;
		end;
	end;

	if library.Builder == nil then
		function library.Builder(iterable)
			return Curry(library.Build, iterable);
		end;
	end;

	if library.Keys == nil then
		-- Returns a list containing all keys in the specified iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 a list containing all the keys in iterable
		function library.Keys(iterable)
			local keys = {};
			library.EachKey(iterable, table.insert, keys);
			return keys;
		end;
	end;

	if library.Values == nil then
		-- Returns a list containing all values in the specified iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 a list containing all the values in iterable
		function library.Values(iterable)
			local values = {};
			library.EachValue(iterable, table.insert, values);
			return values;
		end;
	end;

	if library.Size == nil then
		-- Returns the number of pairs in the specified iterable.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 the number of pairs in the specified iterable
		function library.Size(iterable)
			local count = 0;
			library.Each(iterable, function()
				count = count + 1;
			end);
			return count;
		end;
	end;

	if library.IsEmpty == nil then
		-- Returns whether the specified iterable is empty.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- returns
		--	 true if the specified iterable is empty, otherwise false
		function library.IsEmpty(iterable)
			local iterator = library.Iterator(iterable);
			local key, value = iterator();
			return key == nil and value == nil;
		end;
	end;

	-- Returns whether the specified iterable contains the specified item.
	--
	-- This operation is applicable for either keys or values.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- target
	--	 the searched value
	-- testFunc, ...
	--	 optional. the function that performs the search, with the signature
	--	 testFunc(candidate, target). It should return a truthy value if the two
	--	 values match. If it returns a numeric value, then only zero indicates
	--	 a match.
	-- returns
	--	 true if the specified iterable contains the specified item, according to the
	--	 specified comparator
	Mixins.KeyValueOperation(library, "Contains%s", function(iterator, iterable, target, testFunc, ...)
		testFunc = library.NewEqualsTest(testFunc, ...);
		for candidate in iterator(iterable) do
			if testFunc(candidate, target) then
				return true;
			end;
		end;
		return false;
	end);

	if library.Contains == nil then
		library.Contains = CurryNamedFunction(library, "ContainsValue");
	end;

	if nil == rawget(library, "ContainsPair") then
		-- Returns whether the specified iterable contains the specified pair.
		--
		-- iterable
		--	 a value that is iterable using library.Iterator
		-- targetKey
		--	 the searched key
		-- targetValue
		--	 the corresponding value
		-- testFunc, ...
		--	 optional. the function that performs the search, with the signature
		--	 testFunc(candidateKey, candidateValue, targetKey, targetValue).
		--	 It should return a truthy value if, and only if, both the keys and the values
		--	 match. If the comparator returns a numeric value, then only zero indicates
		--	 a match.
		-- returns
		--	 true if the specified iterable contains the specified pair, according to the
		--	 specified comparator
		function library.ContainsPair(iterable, targetKey, targetValue, testFunc, ...)
			if testFunc == nil and select("#", ...) == 0 then
				testFunc = function(candidateKey, candidateValue, targetKey, targetValue)
					return candidateKey == targetKey and candidateValue == targetValue;
				end;
			else
				testFunc = library.NewEqualsTest(testFunc, ...);
			end;
			for candidateKey, candidateValue in library.Iterator(iterable) do
				if testFunc(candidateKey, candidateValue, targetKey, targetValue) then
					return true;
				end;
			end;
			return false;
		end;
	end;

	if library.KeyFor == nil then
		-- Returns the first key found for the specified value. Comparison is defined by the
		-- specified test
		--
		-- This is an optional operation.
		--
		-- iterable
		--	 a value that is iterable by this library
		-- targetValue
		--	 the value that is searched for
		-- testFunc, ...
		--	 optional. the function that performs the search, with the signature
		--	 testFunc(candidate, target). It should return a truthy value if the two
		--	 values match. If it returns a numeric value, then only zero indicates
		--	 a match.
		-- returns
		--	 the first key that corresponds to to a value that matches the specified value,
		--	 according to testFunc
		function library.KeyFor(iterable, value, testFunc, ...)
			if testFunc then
				testFunc = library.NewEqualsTest(testFunc, ...);
			end;
			for key, candidate in library.Iterator(iterable) do
				if testFunc ~= nil then
					if testFunc(candidate, value) then
						return key;
					end;
				else
					if candidate == value then
						return key;
					end;
				end;
			end;
		end;
	end;
	if library.IndexOf == nil then
		library.IndexOf = CurryNamedFunction(library, "KeyFor");
	end;
	if library.FirstIndexOf == nil then
		library.FirstIndexOf = CurryNamedFunction(library, "KeyFor");
	end;
	if library.FirstKeyFor == nil then
		library.FirstKeyFor = CurryNamedFunction(library, "KeyFor");
	end;

	if library.LastKeyFor == nil then
		-- Returns the last key for the specified value. Comparison is defined by the specified
		-- testFunc.
		--
		-- This is an optional operation.
		--
		-- iterable
		--	 a value that is iterable by this library
		-- targetValue
		--	 the value that is searched for
		-- testFunc, ...
		--	 optional. the function that performs the search, with the signature
		--	 testFunc(candidate, target). It should return a truthy value if the two
		--	 values match. If it returns a numeric value, then only zero indicates
		--	 a match.
		-- returns
		--	 the last key that corresponds to to a value that matches the specified value,
		--	 according to testFunc
		function library.LastKeyFor(iterable, targetValue, testFunc, ...)
			if testFunc then
				testFunc = library.NewEqualsTest(testFunc, ...);
			end;
			for key, candidate in library.ReverseIterator(iterable) do
				if testFunc ~= nil then
					if testFunc(candidate, value) then
						return key;
					end;
				else
					if candidate == value then
						return key;
					end;
				end;
			end;
		end;
	end;
	if library.LastIndexOf == nil then
		library.LastIndexOf = CurryNamedFunction(library, "LastKeyFor");
	end;

	if library.ContainsAllValues == nil then
		-- Returns whether the searched iterable contains all values in the control iterable. Equality
		-- is defined by the comparator func.
		--
		-- searchedIterable
		--	 the iterable that is searched for values
		-- controlIterable
		--	 the itearble that contains the values to search for
		-- testFunc, ...
		--	 the function that performs the search, with the signature
		--	 testFunc(candidate, target). It should return a truthy value if the two
		--	 values match. If it returns a numeric value, then only zero indicates
		--	 a match.
		-- returns
		--	 true if searchedIterable contains every value in the control iterable, otherwise false
		function library.ContainsAllValues(searchedIterable, controlIterable, testFunc, ...)
			for value in library.ValueIterator(controlIterable) do
				if not library.ContainsValue(searchedIterable, value, testFunc, ...) then
					return false;
				end;
			end;
			return true;
		end;
	end;

	if library.ContainsAll == nil then
		library.ContainsAll = CurryNamedFunction(library, "ContainsAllValues");
	end;

	if library.ContainsAllKeys == nil then
		-- Returns whether the searched iterable contains all keys in the control iterable. Equality
		-- is defined by the comparator func.
		--
		-- searchedIterable
		--	 the iterable that is searched for keys
		-- controlIterable
		--	 the itearble that contains the keys to search for
		-- testFunc, ...
		--	 the function that performs the search, with the signature
		--	 testFunc(candidate, target). It should return a truthy value if the two
		--	 values match. If it returns a numeric value, then only zero indicates
		--	 a match.
		-- returns
		--	 true if searchedIterable contains every value in the control iterable, otherwise false
		function library.ContainsAllKeys(searchedIterable, controlIterable, testFunc, ...)
			for key in library.KeyIterator(controlIterable) do
				if not library.ContainsKey(searchedIterable, key, testFunc, ...) then
					return false;
				end;
			end;
			return true;
		end;
	end;

	if library.ToTable == nil then
		function library.ToTable(iterable)
			if library.Bias() == "table" then
				local copy={};
				for k, v in library.PairIterator(iterable) do
					copy[k] = v;
				end;
				return copy;
			end;
			local arr={};
			for v in library.ValueIterator(iterable) do
				table.insert(arr, v);
			end;
			return arr;
		end;
	end;

	if library.RandomKey == nil then
		function library.RandomKey(iterable)
			assert(library.SupportsGet(),
				"Library does not support random access");
			assert(not library.IsEmpty(iterable), "iterable must have at least one element");
			local keys=library.Keys(iterable);
			return keys[math.ceil(math.random() * #keys)];
		end;
	end;

	if library.Random == nil then
		library.Random = CurryNamedFunction(library, "RandomKey");
	end;

	if library.RandomValue == nil then
		function library.RandomValue(iterable)
			assert(library.SupportsGet(),
				"Library does not support random access");
			local key = library.RandomKey(iterable);
			return library.Get(iterable, key);
		end;
	end;

	-- Returns a new iterable that contains any items that are contained in both iterable
	-- and otherIterable, according to the specified testFunc.
	--
	-- This operation creates and modifies a iterable. If the underlying library does not
	-- support mutable iterables, then a table is created and returned.
	--
	-- This operation is applicable for keys, values, or pairs.
	--
	-- iterable, otherIterable
	--	 the iterables that are used for comparison
	-- testFunc, ...
	--	 optional. the function that performs the search, with the signature
	--	 testFunc(candidate, otherCandidate). It should return a truthy value if the two
	--	 values match. If it returns a numeric value, then only zero indicates
	--	 a match.
	-- returns
	--	 a new iterable containing all items contained in both iterables
	Mixins.KeyValuePairOperationByName(library, "UnionBy%s", function(name, iterable, otherIterable, testFunc, ...)
		testFunc = library.NewEqualsTest(testFunc, ...);
		local union = NewIterable();
		local contains = library["Contains" .. name];
		for key, value in library.Iterator(iterable) do
			if contains(otherIterable, testFunc) then
				InsertInto(union, key, value);
			end;
		end;
		return union;
	end);

	if library.Union == nil then
		library.Union = CurryNamedFunction(library, "UnionByValue");
	end;

	-- Returns a new iterable that contains only items that are contained in one of the iterables,
	-- according to the specified testFunc.
	--
	-- This operation is applicable for keys, values, or pairs.
	--
	-- iterable, otherIterable
	--	 the iterables that are used for comparison
	-- testFunc, ...
	--	 optional. the function that performs the search, with the signature
	--	 testFunc(candidate, otherCandidate). It should return a truthy value if the two
	--	 values match. If it returns a numeric value, then only zero indicates
	--	 a match.
	-- returns
	--	 a new iterable containing all items contained in only one of the iterables
	Mixins.KeyValuePairOperationByName(library, "IntersectionBy%s", function(name, iterable, otherIterable, testFunc, ...)
		testFunc = library.NewEqualsTest(testFunc, ...);
		local intersection = NewIterable();
		local contains = library["Contains" .. name];
		for key, value in library.Iterator(iterable) do
			if not contains(otherIterable, testFunc) then
				InsertInto(intersection, key, value);
			end;
		end;
		for key, value in library.Iterator(otherIterable) do
			if not contains(iterable, testFunc) then
				InsertInto(intersection, key, value);
			end;
		end;
		return union;
	end);

	if library.Intersection == nil then
		library.Intersection = CurryNamedFunction(library, "IntersectionByValue");
	end;

	-- Returns the number of times the specified item occurs in the specified iterable.
	--
	-- This operation is applicable for both keys and values.
	--
	-- iterable
	--	 a value that is iterable using library.Iterator
	-- target
	--	 the searched item
	-- testFunc, ...
	--	 the function that performs the search, with the signature
	--	 testFunc(candidate, target). It should return a truthy value if the two
	--	 values match. If it returns a numeric value, then only zero indicates
	--	 a match.
	-- returns
	--	 the number of times the specified item was found, according to the specified
	--	 testFunc
	Mixins.KeyValueOperation(library, "%sFrequency", function(iterator, iterable, target, testFunc, ...)
		testFunc = library.NewEqualsTest(testFunc, ...);
		count = 0;
		for candidate in iterator(iterable) do
			if testFunc(candidate, target) then
				count = count + 1;
			end;
		end;
		return count;
	end);

	if library.Frequency == nil then
		library.Frequency = CurryNamedFunction(library, "ValueFrequency");
	end;

	Mixins.KeyValueOperation(library, "Sum%ss", function(iterator, iterable, convertFunc, ...)
		convertFunc = convertFunc or Functions.Return;
		local sum=0;
		for v in iterator(iterable) do
			v=convertFunc(v);
			local numeric=tonumber(v);
			if numeric~=nil then
				sum=sum+numeric;
			end;
		end;
		return sum;
	end);

	if library.Sum == nil then
		library.Sum = CurryNamedFunction(library, "SumValues");
	end;

	Mixins.KeyValueOperation(library, "Max%s", function(iterator, iterable, comparatorFunc, ...)
		comparatorFunc = library.NewComparator(comparatorFunc, ...);
		local largest = nil;
		for v in iterator(iterable) do
			if largest == nil or comparatorFunc(largest, v) < 0 then
				largest=v;
			end;
		end;
		return largest;
	end);

	if library.Max == nil then
		library.Max = CurryNamedFunction(library, "MaxValue");
	end;

	Mixins.KeyValueOperation(library, "Min%s", function(iterator, iterable, comparatorFunc, ...)
		comparatorFunc = library.NewComparator(comparatorFunc, ...);
		local smallest = nil;
		local iterated=false;
		for v in iterator(iterable) do
			iterated=true;
			if smallest == nil or comparatorFunc(smallest, v) > 0 then
				smallest=v;
			end;
		end;
		assert(iterated, "Iterable must not be empty");
		return smallest;
	end);

	if library.Min == nil then
		library.Min = CurryNamedFunction(library, "MinValue");
	end;

	Mixins.KeyValueOperation(library, "Average%s", function(iterator, iterable, convertFunc, ...)
		-- We don't use Sum since some iterables are only valid for one iteration, so we need to do everythin
		-- in one go.
		convertFunc = convertFunc or Functions.Return;
		local sum=0;
		local s=0;
		for v in iterator(iterable) do
			s=s+1;
			v=convertFunc(v);
			local numeric=tonumber(v);
			if numeric~=nil then
				sum=sum+numeric;
			end;
		end;
		assert(s>0, "Iterable must not be empty");
		return sum/s;
	end);

	if library.Average == nil then
		library.Average = CurryNamedFunction(library, "AverageValue");
	end;

	Mixins.KeyValuePairOperationByName(library, "Mean%s", function(name, ...)
		return library["Mean"..name](...);
	end);
	library.MeanPair=nil;

	if library.Mean == nil then
		library.Mean = CurryNamedFunction(library, "Average");
	end;

	return library;
end;

-- vim: set noet :
