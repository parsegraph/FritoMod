TableUtil = {};
local TableUtil = TableUtil;

-------------------------------------------------------------------------------
--
--  TableUtil: Functional Utility Methods
--
-------------------------------------------------------------------------------

------------------------------------------
--  Update
------------------------------------------
--
-- Updates the originalTable with the values in the updatingTable. By default, this
-- will simply copy every key/value pair from the updatingTable to the originalTable,
-- but you can change this behavior by providing your own updateFunc.
--
-- updateFunc is called with updateFunc(key, value, originalTable, updatingTable);
function TableUtil:Update(originalTable, updatingTable, updateFunc, ...)
    if not updateFunc then
        updateFunc = function(key, value, originalTable, updatingTable)
            originalTable[key] = value;
        end;
    else
        updateFunc = ObjFunc(updateFunc, ...);
    end;
    for key, value in pairs(updatingTable) do
        updateFunc(key, value, originalTable, updatingTable);
    end;
    return originalTable;
end;

------------------------------------------
--  Clone
------------------------------------------
--
-- Clones a table.
function TableUtil:Clone(originalTable)
    return TableUtil:Update({}, originalTable);
end;

-------------------------------------------------------------------------------
--
--  TableUtil: Querying Methods
--
-------------------------------------------------------------------------------

-- Searches for a value in originalTable, returning the first key where 
-- comparatorFunc returned a truthy value. 
--
-- When using this method, be sure that originalTable will never contain "falsy"
-- keys. If it does, always test explicitly against nil.
function TableUtil:LookupValue(originalTable, value, comparatorFunc, ...)
    comparatorFunc = MakeEqualityComparator(comparatorFunc, ...);
    for key, candidate  in pairs(originalTable) do
        if comparatorFunc(candidate, value) then
            return key;
        end;
    end;
end;

-- Returns a function that tests for equality between objects. 
local function MakeEqualityComparator(comparatorFunc, ...)
    if not comparatorFunc then
        return Operator.Equals;
    end;
    return ObjFunc(comparatorFunc, ...);
end;

-------------------------------------------------------------------------------
--
--  TableUtil: Metatable Methods
--
-------------------------------------------------------------------------------

------------------------------------------
--  DecorateMetatable
------------------------------------------
--
-- Inserts the given metatable in between the given table and its original
-- metatable, such that table --> metatable --> oldMetatable.
--
-- Returns a function that reverses this decoration, and restores the table
-- to its original state.
function TableUtil:DecorateMetatable(originalTable, metatable)
    local oldMetatable = getmetatable(originalTable);
    setmetatable(metatable, oldMetatable);
    setmetatable(originalTable, metatable);
    return function()
        setmetatable(originalTable, oldMetatable);
    end;
end;

------------------------------------------
--  LazyInitialize
------------------------------------------
--
-- Adds a metatable to the given table such that before the table is used, the 
-- initializerFunc provided will be called. Once this is done, the oldMetatable
-- of the given table is restored.
--
-- The table is returned.
function TableUtil:LazyInitialize(originalTable, initializerFunc, ...)
    initializerFunc = ObjFunc(initializerFunc, ...);
    local initialize;
    local undecorator = TableUtil:DecorateMetatable(originalTable, {
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
