Tables = DefensiveTable();
local Tables = Tables;

function Tables.Get(targetTable, key)
    return targetTable[key];
end;

function Tables.Set(targetTable, key, value)
    assert(key, "key is falsy");
    local oldValue = targetTable[key];
    targetTable[key] = value;
    return oldValue;
end;

function Tables.Reference(target)
    -- Temporarily detach the metatable so we can access the raw tostring function
    local metatable = getmetatable(target);
    setmetatable(target, nil);
    local str = tostring(target);
    setmetatable(target, metatable);
    local _, split = str:find(":[ ]+");
    return str:sub(split + 1);
end;

function Tables.Keys(map)
    assert(map, "map is falsy");
    local keys = {};
    for key, _ in pairs(map) do
        Lists.Insert(key);
    end;
    return keys;
end;

function Tables.Values(map)
    assert(map, "map is falsy");
    local values = {};
    for _, value in pairs(map) do
        Lists.Insert(value);
    end;
    return values;
end;

function Tables.MapPairs(map, func, ...)
    assert(map, "map is falsy");
    func = Curry(func, ...);
    local results = {};
    for key, value in pairs(map) do
        local result = func(key, value);
        if result ~= nil then
            Lists.Insert(results, result);
        end;
    end;
    return results;
end;

function Tables.MapKeys(map, func, ...)
    func = Curry(func, ...);
    return Tables.MapPairs(map, function(key, value)
        return func(key);
    end);
end;

function Tables.MapValues(map, func, ...)
    func = Curry(func, ...);
    return Tables.MapPairs(map, function(key, value)
        return func(value);
    end);
end;

function Tables.FilterPairs(map, func, ...)
    assert(map, "map is falsy");
    func = Curry(func, ...);
    local filtered = {};
    for key, value in pairs(map) do
        local result = func(key, value);
        if result then
            filtered[key] = value;
        end;
    end;
    return filtered;
end;

function Tables.FilterKeys(map, func, ...)
    func = Curry(func, ...);
    return Tables.FilterPairs(map, function(key, value)
        return func(key);
    end);
end;

function Tables.FilterValues(map, func, ...)
    func = Curry(func, ...);
    return Tables.FilterPairs(map, function(key, value)
        return func(value);
    end);
end;

-- Updates the originalTable with the values in the updatingTable. By default, this
-- will simply copy every key/value pair from the updatingTable to the originalTable,
-- but you can change this behavior by providing your own updateFunc.
--
-- updateFunc is called with updateFunc(key, value, originalTable, updatingTable);
function Tables.Update(originalTable, updatingTable, updateFunc, ...)
    if not updateFunc then
        updateFunc = function(key, value, originalTable, updatingTable)
            originalTable[key] = value;
        end;
    else
        updateFunc = Curry(updateFunc, ...);
    end;
    for key, value in pairs(updatingTable) do
        updateFunc(key, value, originalTable, updatingTable);
    end;
    return originalTable;
end;

-- Expands the keys in the specified table. Any key that is a table will be iterated,
-- and its children will be used as new keys in the specified table. Their values will
-- be that of the original table-key. The original table-keys will be removed.
--
-- local myTable = {
--     [{"f","fo","foo"}] = "bar"
-- };
--
-- Tables.Expand(myTable);
-- assert(myTable.f == "bar");
-- assert(myTable.foo == "bar");
--
-- targetTable
--     the table that is modified
-- returns
--     targetTable
function Tables.Expand(targetTable)
    local removed = {};
    local updating = {};
    for k,v in pairs(targetTable) do
        if type(k) == "table" then
            table.insert(removed, k);
            for _, alias in ipairs(k) do
                updating[alias] = v;
            end;
        end;
    end;
    Tables.Update(targetTable, updating);
    for _, removedKey in ipairs(removed) do
        targetTable[removedKey] = nil;
    end;
    return targetTable;
end;

function Tables.Clear(targetTable)
    local keys = {};
    for key, _ in pairs(targetTable) do
        table.insert(keys, key);
    end;
    for _, key in ipairs(keys) do
        targetTable[key] = nil;
    end;
end;

-- Clones a table.
function Tables.Clone(originalTable)
    return Tables.Update({}, originalTable);
end;

-- Returns a function that tests for equality between objects. 
local function MakeEqualityComparator(comparatorFunc, ...)
    if not comparatorFunc and select("#", ...) == 0 then
        return Operator.Equals;
    end;
    return Curry(comparatorFunc, ...);
end;

local function IsEqual(value)
    return value and (type(value) ~= "number" or value == 0);
end;

-- Searches for a value in originalTable, returning the first key where 
-- comparatorFunc returned a truthy value. 
--
-- When using this method, be sure that originalTable will never contain "falsy"
-- keys. If it does, always test explicitly against nil.
function Tables.LookupValue(originalTable, value, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for key, candidate in pairs(originalTable) do
        if IsEqual(comparatorFunc(candidate)) then
            return key;
        end;
    end;
end;

function Tables.ContainsKey(originalTable, key, comparatorFunc, ...)
    if not comparatorFunc and select("#", ...) == 0 then
        -- Short-circuit on this trivial case.
        return originalTable[key] ~= nil;
    end;
    comparatorFunc = Curry(comparatorFunc, ...);
    for candidate, _ in pairs(originalTable) do
        local value = comparatorFunc(candidate);
        if IsEqual(comparatorFunc(candidate)) then
            return true;
        end;
    end;
    return false;
end;

function Tables.ContainsValue(originalTable, key, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for _, candidate in pairs(originalTable) do
        if IsEqual(comparatorFunc(candidate)) then
            return true;
        end;
    end;
    return false;
end;

-- Inserts the given metatable in between the given table and its original
-- metatable, such that table --> metatable --> oldMetatable.
--
-- Returns a function that reverses this decoration, and restores the table
-- to its original state.
function Tables.DecorateMetatable(originalTable, metatable)
    local oldMetatable = getmetatable(originalTable);
    setmetatable(metatable, oldMetatable);
    setmetatable(originalTable, metatable);
    return function()
        setmetatable(originalTable, oldMetatable);
    end;
end;

-- Adds a metatable to the given table such that before the table is used, the 
-- initializerFunc provided will be called. Once this is done, the oldMetatable
-- of the given table is restored.
--
-- The table is returned.
function Tables.LazyInitialize(originalTable, initializerFunc, ...)
    initializerFunc = Curry(initializerFunc, ...);
    local initialize;
    local undecorator = Tables.DecorateMetatable(originalTable, {
        __index = function(self, key)
            initialize();
            return self[key];
        end,
        __call = function(self, ...)
            initialize();
            return self(...);
        end,
    });
    initialize = function()
        undecorator();
        initializerFunc(originalTable);
    end;
    return originalTable;
end;
