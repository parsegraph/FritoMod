if Mixins == nil then
    Mixins = {};
end;

-- Returns a function that tests for equality between objects. 
local function MakeEqualityComparator(comparatorFunc, ...)
    if not comparatorFunc then
        return Operator.Equals;
    end;
    return Curry(comparatorFunc, ...);
end;

-- Returns whether a value is truthy for purposes of comparison.
local function IsEqual(value)
    return value and (type(value) ~= "number" or value == 0);
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
-- library
--     a table that provides an Iterator function
-- returns
--     library
-- see
--     Mixins.MutableIteration for more iteration methods if your iterables can be modified
function Mixins.Iteration(library)

    local function NewIterable()
        if rawget(library, "New") ~= nil then
            return library.New();
        end;
        return {};
    end;

    local function InsertInto(iterable, key, value)
        if rawget(library, "InsertPair") ~= nil then
            return library.InsertPair(iterable, key, value);
        end;
        if type(key) ~= "number" then
            if rawget(library, "Set") ~= nil then
                return library.Set(iterable, key, value);
            end;
            assert(type(iterable) == "table", "Iterable is not a table");
            local oldValue = iterable[key];
            iterable[key] = value;
            return CurryNamedFunction(library, "Delete", iterable, key);
        end;
        if rawget(library, "Insert") ~= nil then
            return library.Insert(iterable, key, value);
        end;
        assert(type(iterable) == "table", "Iterable is not a table");
        table.insert(iterable, value);
        return CurryNamedFunction(library, "Remove", iterable, oldValue);
    end;

    -- Returns an iterator that iterates over the pairs in iterable.
    --
    -- iterable
    --     a value that is iterable using this function
    -- returns
    --     a function that returns a pair in iterable each time it is called. When
    --     it exhausts the pairs in iterable, it permanentlys returns nil.
    if library.Iterator == nil then
        -- This function must be explicitly implemented by clients.
    end;

    -- Retrieves the value for the specified key in the specified iterable.
    --
    -- This is an optional operation.
    --
    -- iterable
    --     an iterable usable by this library
    -- key
    --     the key that will be searched for in this library
    if library.Get == nil then
        -- This function must be explicitly implemented by clients.
    end;

    -- Returns whether the two iterables contain the same elements, in the same order.
    --
    -- This option is applicable to keys or values.
    --
    -- iterable, otherIterable
    --     the two values that are compared against
    -- comparatorFunc, ...
    --     optional. the function that performs the comparison, with the signature 
    --     comparatorFunc(item, otherItem) where the items are the keys, values.
    --     It should return a truthy value if the two values match. If it returns a numeric 
    --     value, then only zero indicates a match.
    -- returns
    --     true if the iterables contain equal items in the same order, otherwise false
    Mixins.KeyValueOperation(library, "%ssEqual", function(iteratorFunc, iterable, otherIterable, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc);
        local iterator = iteratorFunc(iterable);
        local otherIterator = iteratorFunc(otherIterable);
        while true do
            local item = iterator();
            local otherItem = otherIterator();
            if item == nil or otherItem == nil then
                return item == otherItem;
            end;
            if not IsEqual(comparatorFunc(otherItem, item)) then
                return false;
            end;
        end;
    end);


    -- Returns whether the two iterables contain the same pairs, in the same order.
    --
    -- iterable, otherIterable
    --     the two values that are compared against
    -- comparatorFunc, ...
    --     optional. the function that performs the comparison, with the signature 
    --     comparatorFunc(otherKey, otherValue, key, value) where the items are the keys, 
    --     values. It should return a truthy value if the two values match. If it 
    --     returns a numeric value, then only zero indicates a match.
    -- returns
    --     true if the iterables contain equal pairs in the same order, otherwise false
    if nil == rawget(library, "PairsEqual") then
        function library.PairsEqual(iterable, otherIterable, comparatorFunc, ...)
            if not comparatorFunc and select("#", ...) == 0 then
                comparatorFunc = function(otherKey, otherValue, key, value)
                    return key == otherKey and value == otherValue;
                end;
            end;
            comparatorFunc = MakeEqualityComparator(comparatorFunc);
            local iterator = library.Iterator(iterable);
            local otherIterator = library.Iterator(otherIterable);
            while true do
                local key, value = iterator();
                local otherKey, otherValue = otherIterator();
                if key == nil or otherKey == nil then
                    return key == otherKey;
                end;
                if not IsEqual(comparatorFunc(otherKey, otherValue, key, value)) then
                    return false;
                end;
            end;
        end;
    end;

    if nil == rawget(library, "Equals") then
        library.Equals = CurryNamedFunction(library, "PairsEqual");
    end;

    if library.KeyIterator == nil then
        -- Returns an iterator that iterates over the keys in iterable.
        --
        -- iterable
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each key in iterable
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each value in iterable
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
        if rawget(library, "Get") ~= nil then
            local keys = library.Keys(iterable);
            Get = function()
                local key = keys[index];
                return chooser(key, library.Get(iterable, key));
            end;
        else
            local iterator = library.Iterator(iterable);
            local copy = {};
            local keys = {};
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
        local iterator = {
            Next = function()
                if reachedEnd and index > #keys then
                    return;
                end;
                index = index + 1;
                local key, value = Get();
                if key == nil then
                    reachedEnd = false;
                    return;
                end;
                return chooser(key, value);
            end,
            Previous = function()
                if index == 0 then
                    return;
                end;
                index = index - 1;
                return chooser(Get());
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
    --     a value that is iterable using library.Iterator
    -- decoratorFunc, ...
    --     the function that modifies the given items, returning the modified items
    -- returns
    --     an iterator that behaves as specified above
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
    --     a value that is iterable using library.Iterator
    -- filterFunc, ...
    --     the function that evaluates the given items, returning true if they should be included
    --     in the specified iterator
    -- returns
    --     an iterator that behaves as specified above
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each pair in iterable, in reverse
        function library.ReverseIterator(iterable)
            local copy = {};
            local keys = {};
            library.Each(copy, function(key, value)
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each key in iterable, in reverse
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each value in iterable, in reverse
        function library.ReverseValueIterator(iterable)
            local iterator = library.ReverseIterator(iterable);
            return function()
                local _, value = iterator();
                return value;
            end;
        end;
    end;

    -- Iterates over all items in the specified iterable.
    --
    -- This operation is applicable for either keys, values, or pairs.
    --
    -- iterable
    --     a value that is iterable using library.Iterator
    -- func, ...
    --     the function that is called for every item in the iterable
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
    --     a value that is iterable using library.Iterator
    -- func, ...
    --     the function that is called for every pair in the iterable
    -- returns
    --     a iterable of results from the specified func
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
        --     a value that is iterable using library.Iterator
        -- ...
        --     arguments that are passed to each function in iterable
        -- throws
        --     if any value in iterable is not callable
        function library.CallEach(iterable, ...)
            for func in library.ValueIterator(iterable) do
                assert(IsCallable(func), "func is not callable. Type: " .. type(func));
                func(...);
            end;
        end;
    end;

    if library.MapCall == nil then
        -- Runs every function in the specified iterable, returning the results of each.
        -- 
        -- iterable
        --     a value that is iterable using library.Iterator
        -- ...
        --     arguments that are passed to each function in iterable
        -- returns
        --     all non-nil results from the called functions
        -- throws
        --     if any value in iterable is not callable
        function library.MapCall(iterable, ...)
            local args = { ... };
            return library.MapValues(iterable, function(func)
                assert(IsCallable(func), "func is not callable. Type: " .. type(func));
                return func(unpack(args));
            end);
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
    --     a value that is iterable using library.Iterator
    -- func, ...
    --     the function that is called for every pair in the iterable. A truthy value will
    --     include the given pair in the returned subset
    -- returns
        --     an iterable containing elements that evaluated to true, according to the specified func
    Mixins.KeyValuePairOperation(library, "Filter%ss", function(chooser, iterable, func, ...)
        local filtered = NewIterable();
        func = Curry(func, ...);
        for key, value in library.Iterator(iterable) do
            if func(chooser(key, value)) then
                InsertInto(filtered, key, value);
            end;
        end;
        return filtered;
    end);

    if library.Filter == nil then
        library.Filter = CurryNamedFunction(library, "FilterValue");
    end;

    if library.DefaultReduce == nil then
        -- A default reduce function that tries to do the right thing for various types.
        --
        -- aggregate
        --     Optional. The starting aggregate value.
        -- value
        --     the value that is added to the specified aggregate
        -- return 
        --     the new aggregate
        -- throws
        --     if value is an unsupported type, or if the types of aggregate and value are 
        --     incompatible
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
        --     a value that is iterable using library.Iterator
        -- initialKey, initialValue
        --     initial values
        -- func, ...
        --     the function that is called for every pair in the iterable. It should expect the signature
        --     func(aggregateKey, aggregateValue, key, value) and return a new aggregate key and aggregate
        --     value.
        -- returns
        --     the final aggregate key and value
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
    --     a value that is iterable using library.Iterator
    -- initial
    --     initial aggregate value
    -- func, ...
    --     the function that is called for every item in the iterable. It should expect the signature
    --     func(aggregate, item) and return a new aggregate value
    --     value.
    -- returns
    --     the final aggregate
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

    if library.Keys == nil then
        -- Returns a list containing all keys in the specified iterable.
        --
        -- iterable
        --     a value that is iterable using library.Iterator
        -- returns
        --     a list containing all the keys in iterable
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     a list containing all the values in iterable
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     the number of pairs in the specified iterable
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
        --     a value that is iterable using library.Iterator
        -- returns
        --     true if the specified iterable is empty, otherwise false
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
    --     a value that is iterable using library.Iterator
    -- target
    --     the searched value
    -- comparatorFunc, ...
    --     optional. the function that performs the search, with the signature 
    --     comparatorFunc(candidate, target). It should return a truthy value if the two 
    --     values match. If it returns a numeric value, then only zero indicates 
    --     a match.
    -- returns
    --     true if the specified iterable contains the specified item, according to the
    --     specified comparator
    Mixins.KeyValueOperation(library, "Contains%s", function(iterator, iterable, target, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc);
        for candidate in iterator(iterable) do
            if IsEqual(comparatorFunc(candidate, target)) then
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
        --     a value that is iterable using library.Iterator
        -- targetKey
        --     the searched key
        -- targetValue
        --     the corresponding value
        -- comparatorFunc, ...
        --     optional. the function that performs the search, with the signature 
        --     comparatorFunc(candidateKey, candidateValue, targetKey, targetValue). 
        --     It should return a truthy value if, and only if, both the keys and the values
        --     match. If the comparator returns a numeric value, then only zero indicates 
        --     a match.
        -- returns
        --     true if the specified iterable contains the specified pair, according to the
        --     specified comparator
        function library.ContainsPair(iterable, targetKey, targetValue, comparatorFunc, ...)
            if comparatorFunc == nil and select("#", ...) == 0 then
                comparatorFunc = function(candidateKey, candidateValue, targetKey, targetValue)
                    return candidateKey == targetKey and candidateValue == targetValue;
                end;
            end;
            for candidateKey, candidateValue in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidateKey, candidateValue, targetKey, targetValue)) then
                    return true;
                end;
            end;
            return false;
        end;
    end;

    if library.KeyFor == nil then
        -- Returns the first key found for the specified value. Comparison is defined by the 
        -- specified comparatorFunc.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     a value that is iterable by this library
        -- targetValue
        --     the value that is searched for
        -- comparatorFunc, ...
        --     optional. the function that performs the search, with the signature 
        --     comparatorFunc(candidate, target). It should return a truthy value if the two 
        --     values match. If it returns a numeric value, then only zero indicates 
        --     a match.
        -- returns
        --     the first key that corresponds to to a value that matches the specified value, 
        --     according to comparatorFunc
        function library.KeyFor(iterable, value, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc);
            for key, candidate in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidate, value)) then
                    return key;
                end;
            end;
        end;
    end;

    if library.LastKeyFor == nil then
        -- Returns the last key for the specified value. Comparison is defined by the specified 
        -- comparatorFunc.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     a value that is iterable by this library
        -- targetValue
        --     the value that is searched for
        -- comparatorFunc, ...
        --     optional. the function that performs the search, with the signature 
        --     comparatorFunc(candidate, target). It should return a truthy value if the two 
        --     values match. If it returns a numeric value, then only zero indicates 
        --     a match.
        -- returns
        --     the last key that corresponds to to a value that matches the specified value, 
        --     according to comparatorFunc
        function library.LastKeyFor(iterable, targetValue, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc);
            for key, candidate in library.ReverseIterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetValue)) then
                    return key;
                end;
            end;
        end;
    end;

    if library.ContainsAllValues == nil then
        -- Returns whether the searched iterable contains all values in the control iterable. Equality
        -- is defined by the comparator func.
        --
        -- searchedIterable
        --     the iterable that is searched for values
        -- controlIterable
        --     the itearble that contains the values to search for
        -- comparatorFunc, ...
        --     the function that performs the search, with the signature 
        --     comparatorFunc(candidate, target). It should return a truthy value if the two 
        --     values match. If it returns a numeric value, then only zero indicates 
        --     a match.
        -- returns
        --     true if searchedIterable contains every value in the control iterable, otherwise false
        function library.ContainsAllValues(searchedIterable, controlIterable, comparatorFunc, ...)
            for value in library.ValueIterator(controlIterable) do
                if not library.ContainsValue(searchedIterable, value, comparatorFunc, ...) then
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
        --     the iterable that is searched for keys
        -- controlIterable
        --     the itearble that contains the keys to search for
        -- comparatorFunc, ...
        --     the function that performs the search, with the signature 
        --     comparatorFunc(candidate, target). It should return a truthy value if the two 
        --     values match. If it returns a numeric value, then only zero indicates 
        --     a match.
        -- returns
        --     true if searchedIterable contains every value in the control iterable, otherwise false
        function library.ContainsAllKeys(searchedIterable, controlIterable, comparatorFunc, ...)
            for key in library.KeyIterator(controlIterable) do
                if not library.ContainsKey(searchedIterable, key, comparatorFunc, ...) then
                    return false;
                end;
            end;
            return true;
        end;
    end;

    -- Returns a new iterable that contains any items that are contained in both iterable
    -- and otherIterable, according to the specified comparatorFunc.
    --
    -- This operation creates and modifies a iterable. If the underlying library does not
    -- support mutable iterables, then a table is created and returned.
    --
    -- This operation is applicable for keys, values, or pairs.
    --
    -- iterable, otherIterable
    --     the iterables that are used for comparison
    -- comparatorFunc, ...
    --     optional. the function that performs the search, with the signature 
    --     comparatorFunc(candidate, otherCandidate). It should return a truthy value if the two 
    --     values match. If it returns a numeric value, then only zero indicates 
    --     a match.
    -- returns
    --     a new iterable containing all items contained in both iterables
    Mixins.KeyValuePairOperationByName(library, "UnionBy%s", function(name, iterable, otherIterable, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
        local union = NewIterable();
        local contains = library["Contains" .. name];
        for key, value in library.Iterator(iterable) do
            if contains(otherIterable, comparatorFunc) then
                InsertInto(union, key, value);
            end;
        end;
        return union;
    end);

    if library.Union == nil then
        library.Union = CurryNamedFunction(library, "UnionByValue");
    end;

    -- Returns a new iterable that contains only items that are contained in one of the iterables,
    -- according to the specified comparatorFunc.
    --
    -- This operation is applicable for keys, values, or pairs.
    --
    -- iterable, otherIterable
    --     the iterables that are used for comparison
    -- comparatorFunc, ...
    --     optional. the function that performs the search, with the signature 
    --     comparatorFunc(candidate, otherCandidate). It should return a truthy value if the two 
    --     values match. If it returns a numeric value, then only zero indicates 
    --     a match.
    -- returns
    --     a new iterable containing all items contained in only one of the iterables
    Mixins.KeyValuePairOperationByName(library, "IntersectionBy%s", function(name, iterable, otherIterable, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
        local intersection = NewIterable();
        local contains = library["Contains" .. name];
        for key, value in library.Iterator(iterable) do
            if not contains(otherIterable, comparatorFunc) then
                InsertInto(intersection, key, value);
            end;
        end;
        for key, value in library.Iterator(otherIterable) do
            if not contains(iterable, comparatorFunc) then
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
    --     a value that is iterable using library.Iterator
    -- target
    --     the searched item
    -- comparatorFunc, ...
    --     the function that performs the search, with the signature 
    --     comparatorFunc(candidate, target). It should return a truthy value if the two 
    --     values match. If it returns a numeric value, then only zero indicates 
    --     a match.
    -- returns
    --     the number of times the specified item was found, according to the specified
    --     comparatorFunc
    Mixins.KeyValueOperation(library, "%sFrequency", function(iterator, iterable, target, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc);
        count = 0;
        for candidate in iterator(iterable) do
            if IsEqual(comparatorFunc(candidate, target)) then
                count = count + 1;
            end;
        end;
        return count;
    end);

    if library.Frequency == nil then
        library.Frequency = CurryNamedFunction(library, "ValueFrequency");
    end;

end;
