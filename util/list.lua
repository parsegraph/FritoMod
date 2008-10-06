ListUtil = {};
local ListUtil = ListUtil;

-------------------------------------------------------------------------------
--
--  ListUtil: Mapping Functions
--
-------------------------------------------------------------------------------

------------------------------------------
--  MapInPlace
------------------------------------------
-- 
-- Calls mapFunc(value, index, list) for every value in the list. This will replace
-- the original list with the values from mapFunc.
--
-- Notice that values are replaced only after all values have been passed through
-- mapFunc, since this leads to more intuitive behavior.
function ListUtil:MapInPlace(list, mapFunc, ...)
    local mapped, list = ListUtil:Map(list, mapFunc, ...);
    return ListUtil:Update(list, mapped);
end;

------------------------------------------
--  Map
------------------------------------------
-- 
-- For every value in list, call mapFunc(value, index, list). This will return
-- the returned values in a single table, along with the original list, in that
-- order.
--
-- This will preserve the original list.
function ListUtil:Map(list, mapFunc, ...)
    local mapped = {};
    mapFunc = ObjFunc(mapFunc, ...)
    for index, value in ipairs(list) do
        table.insert(mapped, mapFunc(value, index, list));
    end;
    return mapped, list;
end;

------------------------------------------
--  MapCall
------------------------------------------
-- 
-- For every function in list, call it with the arguments provided to MapCall.
-- This will return the return values of these functions in a single table.
function ListUtil:MapCall(list, ...)
    local results = {};
    for _, func in ipairs(list) do
        table.insert(results, func(...));
    end;
    return results, list;
end;

-------------------------------------------------------------------------------
--
--  ListUtil - The Filter Functions
--
-------------------------------------------------------------------------------
-- 
-- Filtering a list requires an original list and a function to filter with, which
-- is known here as the filterFunc. This function is called on every value in the list
-- with the signature, filterFunc(candidate, index, list).
--
-- A truthy value returned will keep that value in the filtered list, whereas a
-- falsy value is not retained. The specific filter method you use here will determine
-- what happens with unretained items.
--
-- The order is preserved in all cases.

------------------------------------------
--  FilterInPlace
------------------------------------------
--
-- Filters a list in place. The original list is not preserved. This method will return
-- the modified list and the removed values in a separate table.
--
-- Notice that item-removals are done after the filterFunc is called on all values,
-- rather than removing items immediately. This leads to a slightly bulkier in-place
-- filter, but leads to more intuitive results, since list[index] in the filterFunc
-- is always equal to candidate.
function ListUtil:FilterInPlace(list, filterFunc, ...)
    local filteredIndices = ListUtil:FilterIndex(list, filterFunc, ...)
    local i = #filteredIndices;
    local removed = {};
    while i > 0 do
        local removedItem = table.remove(list, i);
        table.insert(removed, removedItem);
        i = i - 1;
    end;
    return list, removed;
end;

------------------------------------------
--  Filter
------------------------------------------
--
-- Filters a list while preserving the original. This returns the filtered list, the
-- list of removed items, and the original list, in that order.
function ListUtil:Filter(list, filterFunc, ...)
    local filteredIndices, removedIndices = ListUtil:FilterIndex(list, filterFunc, ...)
    for i, key in ipairs(filteredIndices) do
        filteredIndices[i] = list[key]
    end;
    for i, key in ipairs(removedIndices) do
        removedIndices[i] = list[key]
    end;
    return filteredIndices, removedIndices, list;
end;

------------------------------------------
--  FilterIndex
------------------------------------------
--
-- Filters a list, returning two lists of indices: The first is filtered items, the second
-- is removed items.
--
-- Notice that if you wish you use this list of indices to remove a set of items, you must
-- adjust them yourself by the immediate number of removed items, like so:
--
-- filteredIndices, removedIndices, list = ListUtil:FilterIndex(list, someFunc);
-- for count, index in ipairs(removedIndices) do
--     table.remove(list, index - count - 1);
-- end;
function ListUtil:FilterIndex(list, filterFunc, ...)
    filterFunc = ObjFunc(filterFunc, ...)
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

-------------------------------------------------------------------------------
--
--  ListUtil: Removers
--
-------------------------------------------------------------------------------
--
-- Removes some occurrences of the given item from the given list. 
--
-- You may override the comparatorFunc used in these functions. Expect the
-- signature comparatorFunc(candidate, item). Any truthy result returned will cause
-- that candidate to be removed.

------------------------------------------
--  RemoveFirst
------------------------------------------
--
-- Removes the first occurrence, returning the original list along with the removed
-- item.
function ListUtil:RemoveFirst(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for index, candidate in ipairs(list) do
        if comparatorFunc(candidate, item) then
            table.remove(list, index);
            return list, candidate;
        end;
    end;
    return list, nil;
end;

------------------------------------------
--  RemoveLast
------------------------------------------
--
-- Removes the last occurrence, returning the original list along with the removed
-- item.
function ListUtil:RemoveFirst(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reversedIndex=1,#list do 
        -- Get the reverse order.
        local index = #list - reversedIndex + 1;
        local candidate = list[index];
        if comparatorFunc(candidate, item) then
            table.remove(list, index);
            return list, candidate;
        end;
    end;
    return list, nil;
end;

------------------------------------------
--  RemoveAll
------------------------------------------
--
-- Removes all occurrences, returning the list, along with a table of removed items.
function ListUtil:RemoveAll(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local filteredIndices = ListUtil:FilterIndex(list, function(candidate, key, list)
        return comparatorFunc(candidate, item);
    end);
    for count, index in ipairs(filteredIndices) do
        table.remove(list, index - count - 1);
    end;
    return list;
end;

-------------------------------------------------------------------------------
--
--  ListUtil: Order Manipulators
--
-------------------------------------------------------------------------------

------------------------------------------
--  Reverse
------------------------------------------
--
-- Returns a list that is the reverse of the original list, along with the original.
-- Notice that the original list is preserved.
function ListUtil:Reverse(originalList)
    local reversedList = {};
    for index=1, #originalList do
        table.insert(reversedList, originalList[#originalList - index + 1]);
    end;
    return reversedList, originalList;
end;

------------------------------------------
--  ReverseInPlace
------------------------------------------
--
-- Reverses the list in-place, returning the list.
function ListUtil:ReverseInPlace(list)
    local reversed = ListUtil:Reverse(list);
    ListUtil:Update(list, reversed);
    return list;
end;

-------------------------------------------------------------------------------
--
--  ListUtil: Set Operations
--
-------------------------------------------------------------------------------

------------------------------------------
--  Difference
------------------------------------------
--
-- Returns a list of items that are in the originalList but not in the 
-- subtractingList.
--
-- You can override the test used here through comparatorFunc. It should expect
-- the signature comparatorFunc(candidate, item).
function ListUtil:Difference(originalList, subtractingList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local difference = {};
    for _, item in ipairs(originalList) do
        if not ListUtil:GetIndex(subtractingList, item, comparatorFunc) then
            table.insert(difference, item);
        end;
    end;
    return difference;
end;

------------------------------------------
--  Union
------------------------------------------
--
-- Returns a list of items that are in both list and otherList. comparatorFunc
-- determines equality in this method, and can be overridden. Expect the sig-
-- nature comparatorFunc(candidate, item)
function ListUtil:Union(list, otherList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    local union = {};
    for _, item in ipairs(list) do
        if ListUtil:GetIndex(otherList, item, comparatorFunc) then
            table.insert(union, item);
        end;
    end;
    return union;
end;

-------------------------------------------------------------------------------
--
--  ListUtil: Querying Methods
--
-------------------------------------------------------------------------------

------------------------------------------
--  Equals
------------------------------------------
--
-- Compare two lists for equality. This test assumes that either the two lists
-- consist of unique elements, or that their non-uniqueness is irrelevant to
-- the state of their equality.
--
-- In other words, this test believes that {"A", "B", "B"} and {"A", "A", "B"} are
-- equal, since both lists contain all elements that are in the other.
function ListUtil:Equals(list, otherList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    if #list ~= #otherList then
        return false;
    end;
    for _, item in ipairs(list) do
        if ListUtil:GetIndex(otherList, item, comparatorFunc) then
            table.insert(union, item);
        end;
    end;
    return union;
end;

------------------------------------------
--  GetIndex
------------------------------------------
--
-- Returns the first index that comparatorFunc returns a truthy value on. If no
-- comparatorFunc is provided, then strict equality is used.
--
-- If no value is found, then 0 is returned.
function ListUtil:GetIndex(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for index, candidate in ipairs(list) do
        if comparatorFunc(candidate, item) then
            return index;
        end;
    end;
    return 0;
end;

------------------------------------------
--  GetLastIndex
------------------------------------------
--
-- Returns the last index that comparatorFunc returns a truthy value on. If no
-- comparatorFunc is provided, then strict equality is used.
--
-- If no value is found, then 0 is returned.
function ListUtil:GetLastIndex(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reverseIndex=1, #list do 
        local index = #list - reverseIndex + 1;
        local candidate = list[index];
        if comparatorFunc(candidate, item) then
            return index;
        end;
    end;
    return 0;
end;

-------------------------------------------------------------------------------
--
--  ListUtil: Miscellany
--
-------------------------------------------------------------------------------

------------------------------------------
--  Reduce
------------------------------------------
--
-- Calls reduceFunc(aggregate, item, index, list) for every item in the list. The
-- aggregate is primed by the initialValue, and the returned value from the 
-- reduceFunc becomes the new aggregate.
--
-- The final aggregate value is the one returned.
function ListUtil:Reduce(list, initialValue, reduceFunc, ...)
    reduceFunc = ObjFunc(reduceFunc, ...);
    local aggregate = initialValue;
    for index, item in ipairs(reduceFunc) do
        aggregate = reduceFunc(aggregate, item, index, list);
    end;
    return aggregate;
end;

------------------------------------------
--  Update
------------------------------------------
--
-- Updates the originalList with the values in the updatingList. By default, this
-- will simply copy every key/value pair from the updatingList to the originalList,
-- but you can change this behavior by providing your own updateFunc.
--
-- updateFunc is called with updateFunc(key, value, originalList, updatingList);
function ListUtil:Update(originalList, updatingList, updateFunc, ...)
    if not updateFunc then
        updateFunc = function(key, value, originalList, updatingList)
            originalList[key] = value;
        end;
    else
        updateFunc = ObjFunc(updateFunc, ...);
    end;
    for key, value in ipairs(updatingList) do
        updateFunc(key, value, originalList, updatingList);
    end;
    return originalList;
end;

------------------------------------------
--  Clone
------------------------------------------
--
-- Clones a list.
function ListUtil:Clone(originalList)
    return ListUtil:Update({}, originalList);
end;
