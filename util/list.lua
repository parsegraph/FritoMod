List = AceLibrary("AceOO-2.0").Class();
local List = List;

ListUtil = {}
local ListUtil = ListUtil

function ListUtil:Filter(list, filterFunc, ...)
    local filtered = ListUtil:FilterIndex(list, filterFunc, ...)
    for i, key in ipairs(filtered) do
        filtered[i] = list[key]
    end;
    return filtered
end;

function ListUtil:Reduce(list, initial, reduceFunc, ...)
    reduceFunc = ObjFunc(reduceFunc, ...);
    local aggregate = initial;
    for i, item in ipairs(reduceFunc) do
        aggregate = reduceFunc(aggregate, item);
    end;
    return aggregate;
end;

function ListUtil:FilterIndex(list, filterFunc, ...)
    filterFunc = ObjFunc(filterFunc, ...)
    local filtered = {};
    for i, item in ipairs(list) do
        if filterFunc(item) then
            table.insert(filtered, i)
        end
    end;
    return filtered
end;

function ListUtil:RemoveItem(list, item)
    return ListUtil:Filter(list, Operator.NotEquals, item)
end;

function ListUtil:Map(sourceList, destList, mapFunc, ...)
    mapFunc = ObjFunc(mapFunc, ...);
    for i, item in ipairs(sourceList) do
        destList[i] = mapFunc(item);
    end;
    return destList;
end;

function ListUtil:Reverse(sourceList, destList)
    if not destList then
        destList = {};
    end;
    if sourceList == destList then
        sourceList = ListUtil:Clone(sourceList);
    end;
    local len = #sourceList;
    for i, item in ipairs(sourceList) do
        destList[len - i + 1] = item;
    end;
    return destList;
end;

function ListUtil:Clone(sourceList, destList)
    if not destList then
        destList = {};
    end;
    for i, item in ipairs(sourceList) do
        destList[i] = item;
    end;
    return destList;
end;

function ListUtil:GetIndex(list, item, comparator, ...)
    if not comparator then
        comparator = ObjFunc(Operator.equals, item);
    end;
    for i, item in ipairs(list) do
        if comparator(item) then
            return i
        end;
    end;
end;

function ListUtil:Contains(list, item, comparator, ...)
    return tobool(ListUtil:GetIndex(list, item, comparator, ...));
end;

function ListUtil:DiffSets(list, otherList, comparator, ...)
    comparator = ObjFunc(comparator, ...);
    if #list < #otherList then
        -- Guarantee the biggest list is used, so we don't get a false positive from a subset.
        local swp = list;
        list = otherList;
        otherList = swp;
    end;
    local misses = 0;
    for i, item in ipairs(list) do
        if not ListUtil:Contains(otherList, item, comparator) then
            misses = misses + 1;
        end;
    end;
    return misses;
end;

function ListUtil:CompareSets(list, otherList, comparator, ...)
    return ListUtil:DiffSets(list, otherList, comparator, ...) == 0;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function List.prototype:init(allowDuplicates)
    List.super.prototype.init(self);
    self.allowDuplicates = allowDuplicates;
end;

function List.prototype:ToString()
    return "List (size:" .. #self .. ")";
end;

-------------------------------------------------------------------------------
--
--  Value Manipulation Methods
--
-------------------------------------------------------------------------------

function List.prototype:Add(value)
    if not self.allowDuplicates and self:Contains(value) then
        return false;
    end;
    table.insert(self, value);
    self:DoAdd(value);
    return true;
end;

function List.prototype:AddAll(values)
    local addedAll = true;
    for _, value in ipairs(values) do
        local success = self:Add(value);
        if addedAll and not success then
            addedAll = false;
        end
    end;
    return addedAll;
end;

function List.prototype:Remove(value)
    for index, candidate in ipairs(self:GetValues()) do
        if candidate == value then
            self:RemoveAt(index);
            if self.allowDuplicates then
                self:Remove(value);
                return true;
            end;
        end;
    end;
    return false;
end;

function List.prototype:RemoveAt(index)
    table.remove(self, index);
    self:DoRemove(value);
end;

function List.prototype:Clear()
    local values = self:GetValues();
    for index, value in ipairs(values) do
        self:DoRemove(value);
    end;
    while #values do
        table.remove(values);
    end;
end;

function List.prototype:DoAdd(value)
    -- Pass for now.
end;

function List.prototype:DoRemove(value)
    -- Pass for now.
end;

function List.prototype:Filter(filterFunc)
    local removingIndices;
    local removedList;
    for index, item in ipairs(self:GetValues()) do
        if not filterFunc(item, index, list) then
            if not removingIndices then
                removingIndices = {};
                removedList = {};
            end;
            table.insert(removingIndices, index);
            table.insert(removedList, item);
        end;
    end;
    local offset = 0;
    if removingIndices then
        for _, index in ipairs(removingIndices) do
            self:RemoveAt(index - offset);
            offset = offset + 1;
        end;
    end;
    return removedList;
end;

-------------------------------------------------------------------------------
--
--  Value Introspection Methods
--
-------------------------------------------------------------------------------

function List.prototype:Get(index)
    return self:GetValues()[index];
end;

function List.prototype:IsEmpty()
    for value in self:Iter() do 
        return true;
    end;
    return false;
end;

function List.prototype:Length()
  return #self;
end;

function List.prototype:GetValues()
    return self;
end;

function List.prototype:Iter()
    local index = 0;
    local entries = #(self);
    return function()
        index = index + 1;
        if index <= entries then
            return self[index];
        end;
    end;
end;

function List.prototype:GetIndex(value)
    for index, candidate in ipairs(self:GetValues()) do
        if candidate == value then
            return index;
        end;
    end;
end;

function List.prototype:Contains(value)
    return tobool(self:GetIndex(value));
end;

function List.prototype:GetLength()
    return #self:GetValues();
end;
