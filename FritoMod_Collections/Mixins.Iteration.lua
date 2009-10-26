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

-- Adds an operation for keys and values to the specified library. The operation
-- is given the appropriate iterator function for the item type.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect a iterator function for its first argument
local function MixinKeyValueOperation(library, name, operation)
    if library[format(name, "Key")] == nil then
        library[format(name, "Key")] = Curry(operation, library.KeyIterator);
    end;
    if library[format(name, "Value")] == nil then
        library[format(name, "Value")] = Curry(operation, library.ValueIterator);
    end;
end;

-- Adds an operation for keys, values, and pairs to the specified library. The operation
-- is given a chooser function that selects the appropriate item for the item type.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Pair", "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect a chooser function for the first argument.
--     The chooser has the signature chooser(key, value) and returns the appropriate item for
--     the item type.
local function MixinKeyValuePairOperation(library, name, operation)
    if library[format(name, "Pair")] == nil then
        library[format(name, "Pair")] = Curry(operation, function(key, value)
            return key, value;
        end);
    end;
    if library[format(name, "Key")] == nil then
        library[format(name, "Key")] = Curry(operation, function(key, value)
            return key;
        end);
    end;
    if library[format(name, "Value")] == nil then
        library[format(name, "Value")] = Curry(operation, function(key, value)
            return value;
        end);
    end;
end;

-- Adds an operation for keys, values, and pairs to the specified library.
--
-- library
--     the library that is the target of this mixin
-- name
--     the name format. "Pair", "Key", or "Value" will be interpolated
-- operation
--     the function that is mixed in. It should expect the item type as the first
--     argument.
local function MixinKeyValuePairOperationByName(library, name, operation)
    if library[format(name, "Pair")] == nil then
        library[format(name, "Pair")] = Curry(operation, "Pair");
    end;
    if library[format(name, "Key")] == nil then
        library[format(name, "Key")] = Curry(operation, "Key");
    end;
    if library[format(name, "Value")] == nil then
        library[format(name, "Value")] = Curry(operation, "Value");
    end;
end;

-- Mixes in a large suite of iteration functions to the specified library. This
-- mixin will not override any functions that are already defined in library.
--
-- The library should provide a small set of core functions, described in the function
-- below. These provide the bare minimum of abstract functionality. If these functions
-- are implemented properly, you are guaranteed to benefit from the full suite of
-- functions provided here.
--
-- Users of this mixin are encouraged to provide more efficient implementations of these
-- methods, as long as they adhere to the contracts defined here. This function does the
-- grunt work of ensuring subclass methods are preferred over the defaults given here.
--
-- library
--     a table that provides an Iterator method, as described above
-- iteratorFunc
--     a function that creates an iterator usable for this library
-- returns
--     library
function Mixins.Iteration(library, iteratorFunc)

    if library.Iterator == nil then
        -- Returns an iterator that iterates over the pairs in iterable.
        --
        -- iterable
        --     a value that is iterable using this function
        -- returns
        --     a function that returns a pair in iterable each time it is called. When
        --     it exhausts the pairs in iterable, it permanentlys returns nil.
        library.Iterator = iteratorFunc;
    end;

    assert(type(library.Iterator) == "function", "Library does not implement Iterator");

    if library.New == nil then
        -- Returns a new, empty iterable that is usable by this library.
        --
        -- This is an optional operation.
        --
        -- returns
        --     a new iterable usable by this library
        -- throws
        --     if this library does not support this operation
        function library.New()
            return {};
        end;
    end;

    if library.Set == nil then
        -- Sets the specified pair to the specified iterable, overriding any existing
        -- values for the specified key.
        --
        -- This function may default to using library.Insert if that function is more
        -- appropriate for the specified library's iterable type. For example, lists
        -- may ignore the key provided by this function.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- key
        --     the key that will be inserted into this iterable
        -- value
        --     the value that will be inserted into this iterable
        -- returns
        --     the old value
        -- throws
        --     if this library does not support this operation
        function library.Set(iterable, key, value)
            assert(type(iterable) == "table", "Iterable is not a table");
            local oldValue = iterable[key];
            iterable[key] = value;
            return oldValue;
        end;
    end;

    if library.Delete == nil then
        -- Deletes the specified key from the specified iterable.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- key
        --     the key that will be deleted from this iterable
        -- returns
        --     the value that was at the specified key
        -- throws
        --     if this library does not support this operation
        function library.Delete(iterable, key)
            return library.Set(iterable, key, nil);
        end;
    end;

    if library.Get == nil then
        -- Retrieves the value for the specified key in the specified iterable.
        --
        -- iterable
        --     an iterable usable by this library
        -- key
        --     the key that will be searched for in this library
        function library.Get(iterable, key)
            assert(type(iterable) == "table", "Iterable is not a table");
            return iterable[key];
        end;
    end;

    if library.Insert == nil then
        -- Inserts the specified value to the specified iterable.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- value
        --     the value that will be inserted into this library
        -- returns
        --     a function that, when invoked, removes the specified value
        -- throws
        --     if this library does not support this operation
        function library.Insert(iterable, value)
            assert(type(iterable) == "table", "Iterable is not a table");
            table.insert(iterable, value);
            return Curry(library.Remove, iterable, value);
        end;
    end;

    if library.InsertAll == nil then
        -- Inserts all specified values into the specified iterable.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- ...
        --     the value that will be inserted into this library
        -- returns
        --     a function that, when invoked, removes the specified values
        -- throws
        --     if this library does not support this operation
        function library.InsertAll(iterable, ...)
            local removers = {};
            for i=1, select("#", ...) do
                local value = select(i, ...);
                table.insert(removers, library.Insert(iterable, value));
            end;
            return function()
                for i=1, #removers do
                    removers[i]();
                end;
                removers = {};
            end;
        end;
    end;

    if library.InsertAt == nil then
        -- Inserts the specified value into the specified iterable.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- index
        --     the location of the inserted item
        -- value
        --     the value that will be inserted into this iterable
        -- returns
        --     a function that, when invoked, removes the specified value
        -- throws
        --     if this library does not support this operation
        function library.InsertAt(list, index, value)
            assert(type(index) == "number", "index is not a number. Type: " .. type(index));
            table.insert(list, index, value);
            return Curry(library.Remove, iterable, value);
        end;
    end;

    if library.InsertAllAt == nil then
        -- Inserts all of the specified values into the specified iterable.
        --
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library
        -- index
        --     the starting location where items are inserted
        -- ...
        --     the values that will be inserted into this iterable
        -- returns
        --     a function that, when invoked, removes all specified values
        -- throws
        --     if this library does not support this operation
        function library.InsertAllAt(list, index, ...)
            assert(type(index) == "number", "index is not a number. Type: " .. type(index));
            local removers = {};
            for i=1, select("#", ...) do
                local value = select(i, ...);
                table.insert(removers, index, library.Insert(iterable, value));
                index = index + 1;
            end;
            return function()
                for i=1, #removers do
                    removers[i]();
                end;
                removers = {};
            end;
        end;
    end;

    if library.Remove == nil then
        -- Removes the first matching value from the specified iterable, according to the specified
        -- comparator and specified target value.
        -- 
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library.
        -- targetValue
        --     the searched value
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the removed key, or nil if no value was removed
        function library.Remove(iterable, targetValue, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            for key, candidate in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetValue)) then
                    library.Delete(iterable, key);
                    return key;
                end;
            end;
        end;
    end;

    if library.RemoveValue == nil then
        library.RemoveValue = CurryNamedFunction(library, "Remove");
    end;

    if library.RemoveFirst == nil then
        library.RemoveFirst = CurryNamedFunction(library, "Remove");
    end;

    if library.RemoveAll == nil then
        -- Removes all matching values from the specified iterable, according to the specified
        -- comparator and specified value.
        --
        -- This function does not modify the iterable until every item has been iterated. While
        -- this minimizes the chance of corrupted iteration, it is also potentially more 
        -- inefficient than a safe, iterable-specific solution.
        -- 
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library.
        -- targetValue
        --     the searched value
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the number of removed elements
        function library.RemoveAll(iterable, targetValue, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            local removedKeys = {};
            for key, candidate in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetValue)) then
                    table.insert(removedKeys, key);
                end;
            end;
            for i=#removedKeys, 1, -1 do
                library.Delete(iterable, removedKeys[i]);
            end;
            return #removedKeys;
        end;
    end;

    if library.RemoveLast == nil then
        -- Removes the last matching value from the specified iterable, according to the specified
        -- comparator and specified value.
        -- 
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library.
        -- targetValue
        --     the searched value
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the removed key, or nil if no value was removed
        function library.RemoveLast(iterable, targetValue, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            for key, candidate in library.ReverseIterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetValue)) then
                    library.Delete(iterable, key);
                    return key;
                end;
            end;
        end;
    end;

    if library.RemoveAt == nil then
        -- Removes the first matching key from the specified iterable, according to the specified
        -- comparator and specified target key.
        -- 
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library.
        -- targetKey
        --     the searched key
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the removed value, or nil if no key was removed
        function library.RemoveAt(iterable, targetKey, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            for candidate, value in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetKey)) then
                    library.Delete(iterable, key);
                    return value;
                end;
            end;
        end;
    end;

    if library.RemoveAllAt == nil then
        -- Removes all matching keys from the specified iterable, according to the specified
        -- comparator and specified target key.
        --
        -- This function does not modify the iterable until every item has been iterated. While
        -- this minimizes the chance of corrupted iteration, it is also potentially more 
        -- inefficient than a safe, iterable-specific solution.
        -- 
        -- This is an optional operation.
        --
        -- iterable
        --     an iterable usable by this library.
        -- targetKey
        --     the searched key
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the number of removed elements
        function library.RemoveAllAt(iterable, targetKey, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            local removedKeys = {};
            for candidate, value in library.Iterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetKey)) then
                    table.insert(removedKeys, key);
                end;
            end;
            for i=#removedKeys, 1, -1 do
                library.Delete(iterable, removedKeys[i]);
            end;
            return #removedKeys;
        end;
    end;

    if library.RemoveLastAt == nil then
        -- Removes the last matching key from the specified iterable, according to the specified
        -- comparator and specified target key.
        -- 
        -- iterable
        --     an iterable usable by this library.
        -- targetKey
        --     the searched key
        -- comparatorFunc, ...
        --     optional. The comparator that performs the search for the specified value
        -- returns
        --     the removed value, or nil if no key was removed
        function library.RemoveAt(iterable, targetKey, comparatorFunc, ...)
            comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
            for candidate, value in library.ReverseIterator(iterable) do
                if IsEqual(comparatorFunc(candidate, targetKey)) then
                    library.Delete(iterable, key);
                    return value;
                end;
            end;
        end;
    end;

    if library.Clear == nil then
        -- Removes every element from the specified iterable.
        --
        -- iterable
        --     the iterable that is modified by this operation
        function library.Clear(iterable)
            local keys = library.Keys(iterable);
            for i=#keys, 1, -1 do
                library.Delete(iterable, keys[i]);
            end;
        end;
    end;

    -- Returns whether the two iterables contain the same elements, in the same order.
    --
    -- This option is applicable to keys, values, or pairs.
    --
    -- iterable, otherIterable
    --     the two values that are compared against
    -- comparatorFunc, ...
    --     optional. the function that performs the comparison, with the signature 
    --     comparatorFunc(item, otherItem) where the items are the keys, values, or pairs.
    --     It should return a truthy value if the two values match. If it returns a numeric 
    --     value, then only zero indicates a match.
    -- 
    MixinKeyValuePairOperation(library, "%ssEqual", function(chooser, iterable, otherIterable, comparatorFunc, ...)
        local iterator = library.Iterator(iterable);
        local otherIterator = library.Iterator(otherIterator);
        local key, value = iterator();
        local otherKey, otherValue = otherIterator();
        while key ~= nil and otherKey ~= nil do
            if not IsEqual(comparatorFunc(chooser(key, value), chooser(otherKey, otherValue))) then
                return false;
            end;
            key, value = iterator();
            otherKey, otherValue = otherIterator();
        end;
        return key == nil and otherKey == nil;
    end);

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
    MixinKeyValuePairOperation(library, "Decorate%sIterator", function(chooser, iterable, decoratorFunc, ...)
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
    MixinKeyValuePairOperation(library, "Filtered%sIterator", function(chooser, iterable, filterFunc, ...)
        filterFunc = Curry(filterFunc, ...);
        local iterator = library.Iterator(iterable);
        function DoIteration()
            local key, value = iterator();
            if key == nil then
                return nil;
            end;
            if filterFunc(chooser(key, value)) then
                return chooser(key, value);
            end;
            return DoIteration();
        end;
        return DoIteration
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
            local keys = {};
            library.EachKey(iterable, table.insert, keys, 1);
            local index = 0;
            return function()
                index = index + 1;
                if index > #keys then
                    return nil, nil;
                end;
                local key = keys[index];
                return key, library.Get(iterable, key);
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
    MixinKeyValuePairOperation(library, "Each%s", function(chooser, iterable, func, ...)
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
    -- Values are collected in an iterable, as created by library.New. Values
    -- are added using library.Insert.
    --
    -- This operation is applicable for either keys, values, or pairs.
    --
    -- iterable
    --     a value that is iterable using library.Iterator
    -- func, ...
    --     the function that is called for every pair in the iterable
    -- returns
    --     a iterable of results from the specified func
    MixinKeyValuePairOperation(library, "Map%ss", function(chooser, iterable, func, ...)
        func = Curry(func, ...);
        local results = library.New();
        for key, value in library.Iterator(iterable) do
            local result = func(chooser(key, value));
            if result ~= nil then
                library.Insert(results, result);
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
    -- Values are collected in an iterable, as created by library.New. Values
    -- are set using library.Set.
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
    MixinKeyValuePairOperation(library, "Filter%ss", function(chooser, iterable, func, ...)
        local filtered = library.New();
        func = Curry(func, ...);
        for key, value in library.Iterator(iterable) do
            if func(chooser(key, value)) then
                library.Set(filtered, key, value);
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
    MixinKeyValueOperation(library, "Reduce%ss", function(iterator, iterable, initial, func, ...)
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

    if library.Clone == nil then
        -- Returns an iterable that is the clone of the specified iterable.
        --
        -- iterable
        --     a value that is iterable using library.Iterator
        -- returns
        --     a clone of the specified iterable
        function library.Clone(iterable)
            local cloned = library.New();
            for key, value in library.Iterator(iterable) do
                library.Set(cloned, key, value);
            end;
            return cloned;
        end;
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
            local iterator = library.Iterator(iterator);
            return not Bool(iterator());
        end;
    end;

    if library.Update == nil then
        -- Updates targetIterable such that updatingIterable is copied over it.
        --
        -- targetIterable
        --     the target iterable that is affected by this operation
        -- updatingIterable
        --     the unmodified iterable that is the source of updates to targetIterable
        -- func, ...
        --     the function that performs the update.
        function library.Update(targetIterable, updatingIterable, func, ...)
            if not func and select("#", ...) == 0 then
                func = library.Set;
            end;
            for key, value in library.Iterator(updatingIterable) do
                func(targetIterable, key, value);
            end;
        end;
    end;

    if library.Reverse == nil then
        -- Returns a new iterable that is the reverse of the specified iterable
        --
        -- This is an optional operation.
        --
        -- iterable
        --     the iterable that is reversed
        -- returns
        --     a new iterable that contains every element
        -- throws
        --     if this library does not support this operation
        function library.Reverse(iterable)
            local reversed = library.New();
            for value in library.ReverseValueIterator(iterable) do
                library.Set(reversed, key, value);
            end;
            return reversed;
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
    MixinKeyValueOperation(library, "Contains%s", function(iterator, iterable, target, comparatorFunc, ...)
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

    if library.KeyFor == nil then
        -- Returns the first key found for the specified value. Comparison is defined by the 
        -- specified comparatorFunc.
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
    -- This operation is applicable for keys, values, or pairs.
    --
    -- This is an optional operation.
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
    MixinKeyValuePairOperationByName(library, "UnionBy%s", function(name, iterable, otherIterable, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
        local union = library.New();
        local contains = library["Contains" .. name];
        for key, value in library.Iterator(iterable) do
            if contains(otherIterable, comparatorFunc) then
                library.Set(union, key, value);
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
    -- This is an optional operation.
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
    MixinKeyValuePairOperationByName(library, "IntersectionBy%s", function(name, iterable, otherIterable, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
        local difference = library.New();
        local contains = library["Contains" .. name];
        for key, value in library.Iterator(iterable) do
            if not contains(otherIterable, comparatorFunc) then
                library.Set(union, key, value);
            end;
        end;
        for key, value in library.Iterator(otherIterable) do
            if not contains(iterable, comparatorFunc) then
                library.Set(union, key, value);
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
    MixinKeyValueOperation(library, "%sFrequency", function(iterator, iterable, target, comparatorFunc, ...)
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
