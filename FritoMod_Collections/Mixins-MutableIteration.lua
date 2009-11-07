if nil ~= require then
    require "FritoMod_Functional/methods";
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Operator";

    require "FritoMod_Collections/Mixins";
    require "FritoMod_Collections/Mixins-Iteration";
end;

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
-- mixin allow you to interact with various iterable types with a healthy baseline
-- of functionality.
--
-- Specifically, this mixin adds a set of generic accessors and modifiers, insertion
-- and removal functions, cloning, updating, and reversing.
--
-- The specified library must provide an Iterator function, as required by 
-- Mixins.Iteration. Other methods should be provided for various parts of this mixin:
--
-- * New - used for cloning, reversing
-- * Set - used in Update
-- * Delete - will default to Set(iterable, key, nil);
-- * Insert - required for Insert* functions
--
-- These functions, except for Insert, have defaults, but these assume a table-like 
-- iterable.
--
-- library
--     a table that provides an Iterator function
-- iteratorFunc
--     optional. A function that creates an iterator usable for this library
-- returns
--     library
-- see
--     Mixins.Iteration. This mixin is also used on the specified library
function Mixins.MutableIteration(library, iteratorFunc)

    Mixins.Iteration(library, iteratorFunc);

    if library.New == nil then
        -- Returns a new, empty iterable that is usable by this library.
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
    if library.Insert ~= nil then
        -- This function must be explicitly implemented by clients.
    end;

    -- Inserts the specified pair into the specified iterable.
    --
    -- This is an optional operation.
    --
    -- The key may or may not be used by this operation.
    --
    -- iterable
    --     an iterable usable by this library
    -- key 
    --     the key that will be inserted into this library. It may be discarded.
    -- value
    --     the value that will be inserted into this library
    -- returns
    --     a function that, when invoked, removes the specified value
    -- throws
    --     if this library does not support this operation
    if library.InsertPair ~= nil then
        function library.InsertPair(iterable, key, value)
            return libray.Insert(iterable, value);
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
            assert(type(library.Insert) == "function", "Insert is not implemented by this library");
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
            assert(type(library.Insert) == "function", "Insert is not implemented by this library");
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
            assert(type(library.Insert) == "function", "Insert is not implemented by this library");
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
                    return library.Delete(iterable, key);
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
                library.InsertPair(cloned, key, value);
            end;
            return cloned;
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
        -- iterable
        --     the iterable that is reversed
        -- returns
        --     a new iterable that contains every element
        -- throws
        --     if this library does not support this operation
        function library.Reverse(iterable)
            local reversed = library.New();
            for value in library.ReverseValueIterator(iterable) do
                library.InsertPair(reversed, key, value);
            end;
            return reversed;
        end;
    end;

end;
