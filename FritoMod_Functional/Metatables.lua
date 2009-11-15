-- Functions that deal with metatables.

if nil ~= require then
    require "FritoMod_Functional/currying";
end;

if Metatables == nil then
    Metatables = {};
end;
local Metatables = Metatables;

-- Ensures a target is either already a table or a nil value.
--
-- returns
--     target or a new table
-- throws
--     if target is non-nil and not a table
local function AssertTable(target)
    if target == nil then
        target = {};
    end;
    assert(type(target) == "table", "table is not a table object");
    return target;
end;

-- Returns a function that attaches the specified metatable to all given tables.
--
-- metatable
--     the metatble to attach to given tables
-- returns
--     a function that attaches the specified metatable to classes
local function MetatableAttacher(metatable)
    if type(metatable) == "function" then
        metatable = { __index = metatable };
    end;
    assert(type(metatable) == "table", "metatable is not a table object");
    -- Attaches a metatable to the specified table.
    --
    -- target
    --     the table that will act as the target for this operation. If nil, a new table is created.
    -- returns
    --     table
    return function(target)
        target = AssertTable(target);
        setmetatable(target, metatable);
        return target;
    end;
end;

function Metatables.FocusedTable(target, func, ...)
    target = AssertTable(target);
    func = Curry(func, ...);
    setmetatable(target, {
        __index = function(self, key)
            return function(maybeSelf, ...)
                if maybeSelf == self then
                    return func(maybeSelf, key, ...);
                end;
                return func(key, maybeSelf, ...);
            end;
        end
    });
    return target;
end;

-- Augments a table such that every non-existent key defaults to Noop. This is useful if you're
-- creating an observer or class but are only interested in part of the functionality provided.
Metatables.Noop = MetatableAttacher(function(self, key)
    return Noop;
end);

-- Augments a table such that every non-existent key causes an error. This is useful if you wish
-- to explicitly avoid this class of potential programming problems.
Metatables.Defensive = MetatableAttacher(function(self, key)
    error("key not found: " .. key);
end);

local function ForcedMetatable(forceFunc)
    return function(target)
        target = AssertTable(target);
        for key, value in pairs(target) do
            if type(value) == "function" then
                target[key] = forceFunc(target, value);
            end;
        end;
        setmetatable(target, {
            __newindex = function(self, key, value)
                if type(value) == "function" then
                    value = forceFunc(self, value);
                end;
                rawset(self, key, value);
            end
        });
        return target;
    end;
end;

Metatables.ForceFunctions = ForcedMetatable(ForcedFunction);
Metatables.ForceMethods = ForcedMetatable(ForcedMethod);

-- Adds a metatable to the specified target that returns the specified default value for any
-- non-existent key. The default value is never assigned to the specified table.
--
-- target
--     the table that is the target of this operation. Its metatable will be overridden by
--     this operation's created metatable
-- defaultValue
--     the value that is returned for non-existent keys
-- throws
--     if target is nil
--     if defaultValue is nil
Metatables.DefaultValue = function(target, defaultValue)
    assert(type(target) == "table", "target is not a table. Type: " .. type(target));
    assert(defaultValue ~= nil, "Nil defaultValue does not make sense");
    setmetatable(target, {
        __index = function(self, key)
            return defaultValue;
        end
    });
end;

-- Adds a metatable to the specified target that handles the creation of default values for that
-- table. The specified constructor is used to create a new default value, and that value is
-- assigned as the new value for the given key.
--
-- target
--     the table that is the target of this operation. Its metatable will be overridden by
--     this operation's created metatable
-- constructorFunc, ...
--     the function that constructs new values for a given key. It should expect the signature
--     constructorFunc(key). It will be invoked whenever a new key needs to be created.
-- throws
--     if target is nil
--     if constructorFunc is not a function
Metatables.ConstructedValue = function(target, constructorFunc, ...)
    assert(type(target) == "table", "target is not a table. Type: " .. type(target));
    constructorFunc = Curry(constructorFunc, ...);
    setmetatable(target, {
        __index = function(self, key)
            local value = constructorFunc(key);
            rawset(self, key, value);
            return value;
        end
    });
end;
