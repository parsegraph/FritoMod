-- Functions that deal with metatables.

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
    -- table
    --     the table that will act as the target for this operation. If nil, a new table is created.
    -- returns
    --     table
    return function(table)
        if table == nil then
            table = {};
        end;
        assert(type(table) == "table", "table is not a table object");
        setmetatable(table, metatable);
        return table;
    end;
end;

-- Adds the specified observer to self. Used for composite tables.
local function Add(self, observer)
    if not observer then
        error("observer is falsy");
    end;
    assert(type(observer) == "table", "observer is not a table. Type: ".. type(observer));
    table.insert(self, observer);
    return Curry(Lists.RemoveFirst, self, observer);
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
-- function foo:Dispatch()
--     self:Bar();
-- end;
--
-- When this is done, listener:Bar() is invoked.
--
-- table
--     the table that is the target of this operation. If nil, a new table is created.
-- returns
--     table
CompositeTable = MetatableAttacher({
    __index = function(self, key)
        if key == "Add" then
            return Add;
        end;
        return function(self, ...)
            for i=1, #self do
                local observer = self[i];
                observer[key](observer, ...);
            end;
        end;
    end
});

-- Augments a table such that every non-existent key defaults to Noop. This is useful if you're
-- creating an observer or class but are only interested in part of the functionality provided.
NoopTable = MetatableAttacher({
    __index = function(self, key)
        return Noop;
    end
});

-- Augments a table such that every non-existent key causes an error. This is useful if you wish
-- to explicitly avoid this class of potential programming problems.
DefensiveTable = MetatableAttacher({
    __index = function(self, key)
        error("key not found: " .. key);
    end
});
