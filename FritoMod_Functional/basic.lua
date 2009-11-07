-- A few primitive functions that are either used pervasively or are so low-level that it doesn't
-- make sense putting them in a higher-level project.

-- A function that intentionally does nothing.
function Noop()
    -- Do nothing.
end;

-- Converts the specified value to a boolean.
--
-- value
--     The value that is coerced to a boolean
-- returns
--     The boolean representation of the specified value
function Bool(value)
	return not not value;
end	

-- Returns whether the specified value is of the specified type.
--
-- requiredType
--     the type that is required. Values of this type yield truthy values
-- value
--     the tested value
-- returns
--     true if value's type is equal to the specified type, otherwise false
-- throws
--     if required type is not a string
function IsType(requiredType, value)
    assert(type(requiredType) == "string", "requiredType is not a string");
    return type(value) == requiredType;
end;

-- Returns whether the specified value is callable. A callable value is one that is
-- a function, or a table that implements __call.
--
-- value
--     The value that is tested by this method
-- returns
--     True if the specfied value is callable, otherwise false
function IsCallable(value)
    local valueType = type(value);
    if valueType == "function" then 
        return true;
    end;
    if valueType ~= "table" then 
        return false;
    end;
    local mt = getmetatable(value);
    return mt and IsCallable(mt.__call);
end;

-- Returns an unpacked table that contains all elements in the specified tables.
-- 
-- WARNING: While this function goes above and beyond when handling nil values, it
-- is VERY dangerous to be passing them around. You should minimize your use of them
-- when unpacking, as they can cause arguments to be lost. Use them at your own risk.
--
-- For example:
-- local a, b, c, d = UnpackAll({1,2}, {3}, {4, 5});
-- assert(a == 1 and b == 2 and c == 3 and d == 4);
--
-- ...
--     A list of lists. This method will not recurse.
-- returns
--     A list that represents a single list containing all entries in the specified
--     list of lists.
do 
    local tableCreators = {
        [1] = function() return {nil} end,
        [2] = function() return {nil,nil} end,
        [3] = function() return {nil,nil,nil} end,
        [4] = function() return {nil,nil,nil,nil} end,
        [5] = function() return {nil,nil,nil,nil,nil} end,
    };
    function UnpackAll(...)
        local tableCreators = {};
        local collectedValues = {};
        -- Collect values from all tables.
        local cumulative = 0;
        local isSparse = false;
        local lingeringArgs = false;
        for i=1, select('#', ...) do
            local argumentGroup = select(i, ...);
            if not argumentGroup then
                error("argumentGroup is falsy");
            end;
            if type(argumentGroup) ~= "table" then
                error("argumentGroup is not a table. Received type: %s", argumentGroup);
            end;
            for i=1, #argumentGroup do
                cumulative = cumulative + 1;
                local value = argumentGroup[i]; 
                lingeringArgs = lingeringArgs or (isSparse and value);
                isSparse = isSparse or value == nil;
                collectedValues[cumulative] = value;
            end
        end
        if lingeringArgs then
            -- We're in dangerous territory. Lua doesn't guarantee the length will be correct
            -- when the array is sparse like this. However, it seems to work consistently when
            -- we initialize an array of the same size as we want. 
            --
            -- In case anyone was wondering, this is a massive, massive hack. In Lua 5.2, we
            -- will use the __len metamethod to enforce length, and we won't have to deal in
            -- these barbaric terms.
            local nilValueString = ("nil, "):rep(cumulative);
            local creator = tableCreators[cumulative];
            if not creator then
                creator = loadstring(("return { %s };"):format(nilValueString));
                tableCreators[cumulative] = creator;
            end;
            local primedCollectedValues = creator();
            for i=1, cumulative do
                primedCollectedValues[i] = collectedValues[i];
            end;
            collectedValues = primedCollectedValues;
        end;
        return unpack(collectedValues);
    end
end;

function Reference(target)
    local str = nil;
    if type(target) == "table" then
        -- Temporarily detach the metatable so we can access the raw tostring function
        local metatable = getmetatable(target);
        setmetatable(target, nil);
        local str = tostring(target);
        setmetatable(target, metatable);
    elseif type(target) == "function" then
        str = tostring(target);
    else
        error("Type has no reference. Type: " .. type(target));
    end;
    local _, split = str:find(":[ ]+");
    return str:sub(split + 1);
end;

-- Populates a table with curried functions. The returned function will accept
-- a function or method, curry it and add it to the specified table. It will also
-- return a method that, when invoked, will remove the curried function from the
-- specified table.
--
-- populatedTable
--     the table that is populated
-- returns
--     a function that behaves as described above
function FunctionPopulator(populatedTable)
    assert(type(populatedTable) == "table", "populatedTable is not a table object. populatedTable: " .. type(populatedTable));
    return function(listener, ...)
        listener = Curry(listener, ...);
        table.insert(populatedTable, listener);
        -- XXX This uses a method in Collections. Move it to that project?
        if nil ~= require then
            require "FritoMod_Collections/Lists";
        end;
        return Curry(Lists.RemoveFirst, populatedTable, listener);
    end;
end;
