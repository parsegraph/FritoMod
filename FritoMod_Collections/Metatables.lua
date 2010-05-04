if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_Collections/Lists";
end;

if Metatables == nil then
    Metatables = {};
end;

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

function Metatables.OrderedMap(target)
    target = AssertTable(target);

    local insertionOrder = {};
    local values = {};

    setmetatable(target, {
        __newindex = function(self, key, value)
            if values[key] ~= nil then
                if value == nil then
                    Lists.Remove(insertionOrder, key);
                end;
            elseif key ~= "Iterator" then
                Lists.Insert(insertionOrder, key);
            end;
            values[key] = value;
        end,

        __index = values
    });

    function target:Iterator()
        return Lists.DecorateValueIterator(insertionOrder, function(mappedKey)
            return mappedKey, values[mappedKey];
        end);
    end;

    return target;
end;

