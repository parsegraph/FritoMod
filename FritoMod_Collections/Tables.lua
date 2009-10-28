Tables = {}
local Tables = Tables;

-- Mixes in iteration functionality for tables
Mixins.MutableIteration(Tables);
Metatables.Defensive(Tables);

function Tables.Iterator(iterable)
    assert(type(iterable) == "table", "iterable is not a table. Iterable: " .. tostring(iterable));
    local key = nil;
    return function()
        local value;
        key, value = next(iterable, key);
        return key, value;
    end;
end;

function Tables.Get(iterable, key)
    return iterable[key];
end;

function Tables.Delete(targetTable, key)
    local oldValue = targetTable[key];
    targetTable[key] = nil;
    return oldValue;
end;

function Tables.InsertPair(targetTable, key, value)
    targetTable[key] = value;
    return CurryNamedFunction(Tables, "Delete", key);
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
