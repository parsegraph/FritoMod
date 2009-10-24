-- Some general functional idioms, such as packing/unpacking methods, coercion methods, and
-- some more complicated functional concepts, like composite functions and metatable creation.

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
    return valueType == "function" or (valueType == "table" and IsCallable(getmetatable(value).__call));
end;

-- Returns an unpacked table that contains all elements in the specified tables.
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
function UnpackAll(...)
    local collectedValues = {}
    -- Collect values from all tables.
    local cumulative = 0;
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
            collectedValues[cumulative] = argumentGroup[i];
        end
    end
    collectedValues.n = cumulative;
    return unpack(collectedValues);
end

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


-- Returns a function that wraps the specified function. Before the specified function is
-- invoked, the activator is called. Subsequent calls to the returned function will directly
-- call the specified function.
--
-- A practical example of this function is a event listener. Whenever a event listener is 
-- attached, it must be first registered with the frame. Typically, this means that RegisterEvent
-- must be called greedily and is typically never relinquished. For short-lived event listeners,
-- this is problematic. However, with this utility, writing a lazy event registry is trivial:
--
-- local listeners = {};
-- local inserter = Curry(Lists.Insert, listeners);
-- local activator = function()
--     frame:RegisterEvent("SOMETHING");
--     return Curry(frame, "UnregisterEvent", "SOMETHING");
-- end;
-- local AddListener = Activator(inserter, activator);
--
-- wrapped
--     the internal function that is called for every invocation of the returned method
-- activator, ...
--     the function that is invoked before every "new" series of invocations of the wrapped method.
--     In practice
function Activator(wrapped, activator, ...)
    wrapped = wrapped or Noop;
    activator = Curry(activator, ...);
    local deactivator = nil;
    local count = 0;
    return function(...)
        if count == 0 then
            deactivator = activator() or Noop;
        end;
        count = count + 1;
        local sanitizer = wrapped(...) or Noop;
        return function()
            if not sanitizer then
                return;
            end;
            sanitizer();
            sanitizer = nil;
            count = count - 1;
            if count == 0 then
                deactivator();
            end;
        end;
    end;
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
        return Curry(Lists.RemoveFirst, populatedTable, listener);
    end;
end;

-- Cycles between the specified functions. Each invocation of the returned function
-- will invoke the next function. The cycle will loop once the last function is invoked.
--
-- ...
--     the functions that will be invoked, in the specified order
-- returns
--     a function that will invoke the next specified function in order
function Cycle(...)
    local functions = {...};
    local cycle = -1;
    return function(...)
        cycle = (cycle + 1) % #functions;
        return functions[cycle + 1](...);
    end;
end;

-- Provides undo/redo functionality for the specified function that supports it. When first
-- invoked, the returned function will call the specified function. The specified function
-- is expected to return a callable that, when invoked, will "undo" the specified function's
-- operation. The next invocation will invoke that "undo" function.
--
-- This function is essentially a special kind of Cycle: it cycles between performing an operation,
-- and undoing that operation. It may be also used for more complicated schemes that don't
-- necessarily "undo" anything, but rather progress through some dynamic chain of functions.
--
-- func, ...
--     the function that is the undoable operation for this function. It must return a callable that,
--     when invoked, will "undo" the original operation
-- returns
--     a function that performs, or undoes, the specified function's operation
function Undoable(func, ...)
    func = Curry(func, ...);
    local remover = nil;
    return function(...)
        if remover then
            remover(...);
        end;
        remover = func(...);
        assert(IsCallable(remover), "remover is not a callable");
    end;
end;

