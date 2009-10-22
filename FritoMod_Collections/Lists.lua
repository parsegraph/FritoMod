Lists = Metatables.Defensive();
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.Iteration(Lists, ipairs);

function Lists.Clear(list)
    repeat
        table.remove(list);
    until #list == 0;
end;

-- Removes some occurrences of the given item from the given list. 
--
-- You may override the comparatorFunc used in these functions. Expect the
-- signature comparatorFunc(candidate, item). Any truthy result returned will cause
-- that candidate to be removed.
--
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
function Lists.RemoveLast(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reversedIndex=#list,1,-1 do 
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
function Lists.ContainsAll(list, otherList, comparatorFunc, ...)
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

function Lists.Equals(list, otherList, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    if #list ~= #otherList then
        return false;
    end;
    for i=1, #list do
        local item = list[i];
        if not IsEqual(comparatorFunc(otherList[i], list[i])) then
            return false;
        end;
    end;
    return true;
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
end;

-- Returns the last index that comparatorFunc returns a truthy value on. If no
-- comparatorFunc is provided, then strict equality is used.
--
-- If no value is found, then 0 is returned.
function Lists.LastIndexOf(list, item, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for reverseIndex=#list, 1, -1 do
        local candidate = list[reverseIndex];
        if IsEqual(comparatorFunc(candidate, item)) then
            return index;
        end;
    end;
end;
