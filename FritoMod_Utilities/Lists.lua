Lists = DefensiveTable();
local Lists = Lists;

function Lists.Insert(list, value)
    list[#list + 1] = value;
    return Curry(Lists.RemoveFirst, list, value);
end;

function Lists.InsertAll(list, ...)
    local removers = Lists.Map({...}, Lists.Insert, list);
    return Curry(Lists.MapCall, removers);
end;

function Lists.InsertAt(list, index, value)
    assert(type(index) == "number", "index is not a number. Type: " .. type(index));
    table.insert(list, value, index);
    return Curry(Lists.RemoveFirst, list, value);
end;

function Lists.InsertAllAt(list, index, ...)
    assert(type(index) == "number", "index is not a number. Type: " .. type(index));
    local removers = {};
    for i=1, select("#", ...) do
        local value = select(i, ...);
        table.insert(removers, List.InsertAt(list, index + i - 1, value));
    end;
    return Curry(Lists.MapCall, removers);
end;

function Lists.Clear(list)
    repeat
        table.remove(list);
    until #list == 0;
end;

-- Consumes an iterator and populates a table with its results.
--
-- generator
--     the function that generates results. Once exhausted, the generator
--     should return nil
-- returns
--     a table that contains all generated values
function Lists.Consume(generator, ...)
    generator = Curry(generator, ...);
    local list = {};
    repeat
        local created = generator();
        if created ~= nil then
            table.insert(list, created);
        end;
    until created == nil;
    return list;
end;

-- Joins all items using the specified join handler. This is essentially a special case
-- of reduce, where the first value is used as the initial value, and never invoked on the
-- join handler.
--
-- Empty lists are not allowed since their behavior is undefined.
--
-- list
--     the list of items
-- joinHandler
--     a function that joins items together. It is called as joinHandler(whole, part) where
--     "whole" is the working value, and "part" is the current value.
-- ...
--     any arguments that should be curried using joinHandler
--  returns
--     the joined value
--  throws
--      if list is empty
function Lists.Join(list, joinHandler, ...)
    assert(getn(list) > 0, "list is empty");
    joinHandler = Curry(joinHandler);
    local joined = list[1];
    for i=2, len do 
        joined = joinHandler(joined, list[i]);
    end;
    return joined;
end;

-- Returns a function that tests for equality between objects. 
local function MakeEqualityComparator(comparatorFunc, ...)
    if not comparatorFunc then
        return Operator.Equals;
    end;
    return Curry(comparatorFunc, ...);
end;

local function IsEqual(value)
    return value and (type(value) ~= "number" or value == 0);
end;

-- Calls mapFunc(value, index, list) for every value in the list. This will replace
-- the original list with the values from mapFunc.
--
-- Notice that values are replaced only after all values have been passed through
-- mapFunc, since this leads to more intuitive behavior.
function Lists.MapInPlace(list, mapFunc, ...)
    local mapped, list = Lists.Map(list, mapFunc, ...);
    return Lists.Update(list, mapped);
end;

-- For every value in list, call mapFunc(value, index, list). This will return
-- the returned values in a single table, along with the original list, in that
-- order.
--
-- This will preserve the original list.
function Lists.Map(list, mapFunc, ...)
    local mapped = {};
    mapFunc = Curry(mapFunc, ...)
    for index, value in ipairs(list) do
        table.insert(mapped, mapFunc(value, index, list));
    end;
    return mapped, list;
end;

-- For every function in list, call it with the arguments provided to MapCall.
-- This will return the return values of these functions in a single table.
function Lists.MapCall(list, ...)
    assert(type(list) == "table", "list is not a table object. List: " .. tostring(list));
    local results = {};
    for _, func in ipairs(list) do
        local result = func(...);
        if result ~= nil then
            table.insert(results, result);
        end;
    end;
    return results, list;
end;

-- Filtering a list requires an original list and a function to filter with, which
-- is known here as the filterFunc. This function is called on every value in the list
-- with the signature, filterFunc(candidate, index, list).
--
-- A truthy value returned will keep that value in the filtered list, whereas a
-- falsy value is not retained. The specific filter method you use here will determine
-- what happens with unretained items.
--
-- The order is preserved in all cases.

-- Filters a list in place. The original list is not preserved. This method will return
-- the modified list and the removed values in a separate table.
--
-- Notice that item-removals are done after the filterFunc is called on all values,
-- rather than removing items immediately. This leads to a slightly bulkier in-place
-- filter, but leads to more intuitive results, since list[index] in the filterFunc
-- is always equal to candidate.
function Lists.FilterInPlace(list, filterFunc, ...)
    local filteredIndices = Lists.FilterIndex(list, filterFunc, ...)
    local i = #filteredIndices;
    local removed = {};
    while i > 0 do
        local removedItem = table.remove(list, i);
        table.insert(removed, removedItem);
        i = i - 1;
    end;
    return list, removed;
end;

-- Filters a list while preserving the original. This returns the filtered list, the
-- list of removed items, and the original list, in that order.
function Lists.Filter(list, filterFunc, ...)
    local filteredIndices, removedIndices = Lists.FilterIndex(list, filterFunc, ...)
    for i, key in ipairs(filteredIndices) do
        filteredIndices[i] = list[key]
    end;
    for i, key in ipairs(removedIndices) do
        removedIndices[i] = list[key]
    end;
    return filteredIndices, removedIndices, list;
end;

-- Filters a list, returning two lists of indices: The first is filtered items, the second
-- is removed items.
--
-- Notice that if you wish you use this list of indices to remove a set of items, you must
-- adjust them yourself by the immediate number of removed items, like so:
--
-- filteredIndices, removedIndices, list = Lists.FilterIndex(list, someFunc);
-- for count, index in ipairs(removedIndices) do
--     table.remove(list, index - count - 1);
-- end;
function Lists.FilterIndex(list, filterFunc, ...)
    filterFunc = Curry(filterFunc, ...)
    local filteredIndices, removedIndices = {}, {};
    for index, candidate in ipairs(list) do
        if filterFunc(candidate, index, list) then
            table.insert(filteredIndices, index)
        else
            table.insert(removedIndices, index)
        end;
    end;
    return filteredIndices, removedIndices, list;
end;

-- Removes some occurrences of the given item from the given list. 
--
-- You may override the comparatorFunc used in these functions. Expect the
-- signature comparatorFunc(candidate, item). Any truthy result returned will cause
-- that candidate to be removed.

-- Removes the first occurrence, returning the original list along with the removed
-- item.
function Lists.RemoveFirst(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for index, candidate in ipairs(list) do
        if IsEqual(comparatorFunc(candidate, item)) then
            table.remove(list, index);
            return list, candidate;
        end;
    end;
    return list, nil;
end;

-- Removes the last occurrence, returning the original list along with the removed
-- item.
function Lists.RemoveFirst(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reversedIndex=1,#list do 
        -- Get the reverse order.
        local index = #list - reversedIndex + 1;
        local candidate = list[index];
        if IsEqual(comparatorFunc(candidate, item)) then
            table.remove(list, index);
            return list, candidate;
        end;
    end;
end;

-- Removes all occurrences, returning the list.
function Lists.RemoveAll(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local filteredIndices = Lists.FilterIndex(list, function(candidate, key, list)
        return IsEqual(comparatorFunc(candidate, item));
    end);
    for count, index in ipairs(filteredIndices) do
        table.remove(list, index - count - 1);
    end;
end;

-- Returns a list that is the reverse of the original list, along with the original.
-- Notice that the original list is preserved.
function Lists.Reverse(originalList)
    local reversedList = {};
    for index=1, #originalList do
        table.insert(reversedList, originalList[#originalList - index + 1]);
    end;
    return reversedList;
end;

-- Reverses the list in-place, returning the list.
function Lists.ReverseInPlace(list)
    local reversed = Lists.Reverse(list);
    Lists.Update(list, reversed);
    return list;
end;

-- Returns a list of items that are in the originalList but not in the 
-- subtractingList.
--
-- You can override the test used here through comparatorFunc. It should expect
-- the signature comparatorFunc(candidate, item).
function Lists.Difference(originalList, subtractingList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local difference = {};
    for _, item in ipairs(originalList) do
        if not Lists.IndexOf(subtractingList, item, comparatorFunc) then
            table.insert(difference, item);
        end;
    end;
    return difference;
end;

-- Returns a list of items that are in both list and otherList. comparatorFunc
-- determines equality in this method, and can be overridden. Expect the sig-
-- nature comparatorFunc(candidate, item)
function Lists.Union(list, otherList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local union = {};
    for _, item in ipairs(list) do
        if Lists.IndexOf(otherList, item, comparatorFunc) then
            table.insert(union, item);
        end;
    end;
    return union;
end;

-- Compare two lists for equality. This test assumes that either the two lists
-- consist of unique elements, or that their non-uniqueness is irrelevant to
-- the state of their equality.
--
-- In other words, this test believes that {"A", "B", "B"} and {"A", "A", "B"} are
-- equal, since both lists contain all elements that are in the other.
function Lists.Equals(list, otherList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    if #list ~= #otherList then
        return false;
    end;
    for _, item in ipairs(list) do
        if Lists.IndexOf(otherList, item, comparatorFunc) then
            table.insert(union, item);
        end;
    end;
    return union;
end;

-- Returns the first index that comparatorFunc returns a truthy value on. If no
-- comparatorFunc is provided, then strict equality is used.
--
-- If no value is found, then 0 is returned.
function Lists.IndexOf(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for index, candidate in ipairs(list) do
        if IsEqual(comparatorFunc(candidate, item)) then
            return index;
        end;
    end;
    return 0;
end;

-- Returns the last index that comparatorFunc returns a truthy value on. If no
-- comparatorFunc is provided, then strict equality is used.
--
-- If no value is found, then 0 is returned.
function Lists.LastIndexOf(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reverseIndex=1, #list do 
        local index = #list - reverseIndex + 1;
        local candidate = list[index];
        if IsEqual(comparatorFunc(candidate, item)) then
            return index;
        end;
    end;
    return 0;
end;

-- A default reduce function that tries to do the right thing for various types.
local function DefaultReduce(aggregate, value, ...)
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
            Lists.InsertAll(aggregate, unpack(value));
        else
            Tables.Update(aggregate, value);
        end;
        return aggregate;
    end;
    if type(value) == "function" then
        return value(aggregate);
    end;
    error("Unsupported value type. Type: " .. type(value));
end

-- Calls reduceFunc(aggregate, item, index, list) for every item in the list. The
-- aggregate is primed by the initialValue, and the returned value from the 
-- reduceFunc becomes the new aggregate.
--
-- The final aggregate value is the one returned.
function Lists.Reduce(list, initialValue, reduceFunc, ...)
    if not reduceFunc and select("#", ...) == 0 then
        reduceFunc = DefaultReduce;
    else
        reduceFunc = Curry(reduceFunc, ...);
    end;
    local aggregate = initialValue;
    for index, item in ipairs(list) do
        aggregate = reduceFunc(aggregate, item, index, list);
    end;
    return aggregate;
end;

-- Updates the originalList with the values in the updatingList. By default, this
-- will simply copy every key/value pair from the updatingList to the originalList,
-- but you can change this behavior by providing your own updateFunc.
--
-- updateFunc is called with updateFunc(key, value, originalList, updatingList);
function Lists.Update(originalList, updatingList, updateFunc, ...)
    if not updateFunc then
        updateFunc = function(key, value, originalList, updatingList)
            originalList[key] = value;
        end;
    else
        updateFunc = Curry(updateFunc, ...);
    end;
    for key, value in ipairs(updatingList) do
        updateFunc(key, value, originalList, updatingList);
    end;
    return originalList;
end;

-- Clones a list.
function Lists.Clone(originalList)
    return Lists.Update({}, originalList);
end;
