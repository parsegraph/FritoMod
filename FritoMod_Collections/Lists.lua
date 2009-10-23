Lists = Metatables.Defensive();
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.Iteration(Lists, ipairs);

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
