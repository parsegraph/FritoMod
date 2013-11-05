-- A few low-level functions that are used pervasively throughout this addon. There are
-- also other functions that are so random that they haven't found a suitable home yet.

-- I don't like adding functions here, and I rarely do. Most functions should live in a
-- namespace like Functional, Callbacks, etc.

-- A function that intentionally does nothing. This is useful in those situations where
-- you always want a function, but don't care if it doesn't actually do anything.
if not Noop then
    function Noop()
        -- Do nothing.
    end;
end;

-- Converts the specified value to a boolean.
--
-- value
--	 The value that is coerced to a boolean
-- returns
--	 The boolean representation of the specified value
function Bool(value)
	return not not value;
end

-- A value that is used to signal the death of some operations. This is used where a remover
-- cannot easily be provided.
--
-- Never change or edit this value, or assign to any of its keys.
--
-- see
--	 Timing.Throttle, Timing.After
POISON=POISON or {};

-- Returns whether the specified value is of the specified type.
--
-- requiredType
--	 the type that is required. Values of this type yield truthy values
-- value
--	 the tested value
-- returns
--	 true if value's type is equal to the specified type, otherwise false
-- throws
--	 if required type is not a string
function IsType(requiredType, value)
	assert(type(requiredType) == "string", "requiredType is not a string");
	return type(value) == requiredType;
end;

-- Returns whether the specified value is callable. A callable value is one that is
-- a function, or a table that implements __call.
--
-- value
--	 The value that is tested by this method
-- returns
--	 True if the specfied value is callable, otherwise false
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

-- Returns whether the specified value is a boolean, string, or number. Nil values are
-- not primitive.
--
-- value
--	 any value
-- returns
--	 true if value is a boolean, string, or number
function IsPrimitive(value)
	local valueType = type(value);
	return valueType=="boolean" or valueType=="string" or valueType=="number";
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
--	 A list of lists. This method will not recurse.
-- returns
--	 A list that represents a single list containing all entries in the specified
--	 list of lists.
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
				if value == nil then
					local msg="";
					for j=1,#collectedValues do
						if msg~="" then
							msg=msg.."\n";
						end;
						msg=msg.."Argument #"..j..": "..tostring(collectedValues[j]);
					end;
					error(("Argument #%d is nil. Argument group: %d, index in group: %d\n"..msg):format(cumulative, groupIndex, i));
				end;
				collectedValues[cumulative] = value;
			end
		end
		return unpack(collectedValues);
	end
end;

-- Outputs the memory address for the given table or function. The memory address is shown whenever
-- you do things like print({}).
--
-- target
--	 a table or function value
function Reference(target)
	local str = nil;
	if type(target) == "table" then
		-- Temporarily detach the metatable so we can access the raw tostring function
		local metatable = getmetatable(target);
		setmetatable(target, nil);
		str = tostring(target);
		setmetatable(target, metatable);
	elseif type(target) == "function" or type(target) == "userdata" then
		str = tostring(target);
	else
		error("Type has no reference. Type: " .. type(target));
	end;
	local _, split = str:find(":[ ]+");
	return str:sub(split + 1);
end;

-- Removes a value from a table. This is for efficiency and dependency reasons. Now that FritoMod
-- is merged into one addon, we can probably kill this method.
function RemoveValueFromTable(t, v)
	for i=1,#t do
		if t[i] == v then
			table.remove(i);
			return;
		end;
	end;
end;

if not traceback then
    function traceback(msg)
        msg = msg or "";
        if msg:find("\nstack traceback:\n") ~= nil then
            return msg;
        end;
        if debug and debug.traceback then
            return debug.traceback(msg, 2);
        else
            return msg .. "\n" .. debugstack();
        end;
    end;
end;

if not printf then
    function printf(str, ...)
        print(str:format(...));
    end
end;

-- A boolean value that determines whether trace debug messages should be shown.
if DEBUG_TRACE == nil then
    DEBUG_TRACE=false;
end;

if not trace then
    function trace(str, ...)
        if DEBUG_TRACE then
            if select("#", ...) == 0 then
                return print(tostring(str));
            end;
            return printf(str, ...);
        end;
    end;
end;

if not tracef then
    function tracef(format, ...)
        return trace(format:format(...));
    end;
end;

if not platform then
    function platform()
        return "wow";
    end;
end;

local versions = {
    ["Lua 5.1"] = 50100,
    ["Lua 5.2"] = 50200
};

function luaversion(version)
    version = version or _VERSION;
    assert(versions[version], "Lua version is not supported");
    return versions[version];
end;
