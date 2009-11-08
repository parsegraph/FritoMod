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
        for groupIndex=1, select('#', ...) do
            local argumentGroup = select(groupIndex, ...);
            if not argumentGroup then
                error("argumentGroup is falsy");
            end;
            if type(argumentGroup) ~= "table" then
                error("argumentGroup is not a table. Received type: %s", argumentGroup);
            end;
            for i=1, #argumentGroup do
                cumulative = cumulative + 1;
                local value = argumentGroup[i]; 
                assert(value ~= nil, ("Value is nil at index %d in table %d"):format(i, groupIndex));
                collectedValues[cumulative] = value;
            end
        end
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
