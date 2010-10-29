-- Functions that deal with metatables.

if nil ~= require then
    require "currying";
end;

Metatables=Metatables or {};

-- Ensures a target is either already a table or a nil value.
--
-- returns
--     target or a new table
-- throws
--     if target is non-nil and not a table
function Metatables._AssertTable(target)
    if target == nil then
        target = {};
    end;
    assert(type(target) == "table", "table is not a table object");
    return target;
end;
local AssertTable=Metatables._AssertTable;

-- Returns a function that attaches the specified metatable to all given tables.
--
-- metatable
--     the metatble to attach to given tables
-- returns
--     a function that attaches the specified metatable to classes
function Metatables.Attacher(metatable)
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
local MetatableAttacher=Metatables.Attacher;

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
    error(type(key).." key not found: " .. tostring(key));
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
Metatables.ForceFunction = ForcedMetatable(ForcedFunction);
Metatables.ForcedFunctions = ForcedMetatable(ForcedFunction);
Metatables.ForcedFunction = ForcedMetatable(ForcedFunction);

Metatables.ForceMethods = ForcedMetatable(ForcedMethod);
Metatables.ForcedMethods = ForcedMetatable(ForcedMethod);
Metatables.ForcedMethod = ForcedMetatable(ForcedMethod);
Metatables.ForceMethod = ForcedMetatable(ForcedMethod);

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
Metatables.Default = function(target, defaultValue)
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

Metatables.Headless=MetatableAttacher({
    __newindex=function(self,k,v)
        self[k]=v;
    end,
    __index=function(self,k)
        return function(...)
            return Headless(self[k], ...);
        end
    end
});

do
    -- Adds the specified observer to self. Used with Metatables.Multicast
    local function Add(self, observer)
        if not observer then
            error("observer is falsy");
        end;
        assert(type(observer) == "table", "observer is not a table. Type: ".. type(observer));
        table.insert(self, observer);
        return Curry(Lists.Remove, self, observer);
    end;

    -- Creates a "composite" table. The returned table forwards all method calls
    -- to all of its registered observers. This allows for very clean event dispatching,
    -- and for adaptability in the future, since one, regular table acts almost identical 
    -- to the composite table created here. 
    --
    -- For example, assume we want to receive Bar events from an object "foo". To accomplish
    -- this, we write:
    --
    -- foo:Add(listener);
    -- 
    -- Now, in foo, when we wish to dispatch Bar events, we simply call "Bar":
    --
    -- foo:Bar();
    --
    -- When this is done, listener:Bar() is invoked.
    --
    -- table
    --     the table that is the target of this operation. If nil, a new table is created.
    -- returns
    --     table
    Metatables.Multicast = MetatableAttacher({
        __index = function(self, key)
            if key == "Add" then
                return Add;
            end;
            return function(self, ...)
                for i=1, #self do
                    local observer = self[i];
                    local f = observer[key];
                    if f then
                        f(observer, ...);
                    end;
                end;
            end;
        end
    });
end;
