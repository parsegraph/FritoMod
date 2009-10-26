-- Functions that deal with metatables.
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
Metatables.Noop = MetatableAttacher({
    __index = function(self, key)
        return Noop;
    end
});

-- Augments a table such that every non-existent key causes an error. This is useful if you wish
-- to explicitly avoid this class of potential programming problems.
Metatables.Defensive = MetatableAttacher({
    __index = function(self, key)
        error("key not found: " .. key);
    end
});

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
