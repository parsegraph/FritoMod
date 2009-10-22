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

local function MixinKeyValueOperation(library, name, operation)
    if library[format(name, "Key")] == nil then
        library[format(name, "Key")] = Curry(operation, library.KeyIterator);
    end;
    if library[format(name, "Value")] == nil then
        library[format(name, "Value")] = Curry(operation, library.ValueIterator);
    end;
end;

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
            return Curry(library.RemoveValue, iterable, value);
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
            return Curry(library.RemoveValue, iterable, value);
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

    if library.ReverseIterator == nil then
        -- Returns an iterator that iterates over the pairs in the specified iterable, in reverse order.
        --
        -- iterable
        --     a value that is iterable using library.Iterator
        -- returns
        --     an iterator that returns each pair in iterable, in reverse
        function library.ReverseIterator(iterable)
            local keys = {};
            for key in library.EachKey(iterable) do
                table.insert(keys, 1, key);
            end;
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
            for func in library.Iterator(iterable) do
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
            return library.MapPairs(iterable, function(func)
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
    --     the function that performs the search, with the signature 
    --     comparatorFunc(candidate, target). It should return a truthy value if the two 
    --     values match. If it returns a numeric value, then only zero indicates 
    --     a match.
    -- returns
    --     true if the specified iterable contains the specified item, according to the
    --     specified comparator
    MixinKeyValueOperation(library, "Contains%s", function(iterator, iterable, target, comparatorFunc, ...)
        comparatorFunc = MakeEqualityComparator(comparatorFunc);
        for candidate in library.KeyIterator(iterable) do
            if IsEqual(comparatorFunc(candidate, target)) then
                return true;
            end;
        end;
        return false;
    end);

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

end;
