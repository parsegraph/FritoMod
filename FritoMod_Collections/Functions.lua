if nil ~= require then
    require "FritoMod_Functional/currying";

    require "FritoMod_Collections/Lists";
end;

if nil == Functions then
    Functions = {};
end;
local Functions = Functions;

-- Populates a table with curried functions. The returned function will accept
-- a function or method, curry it and add it to the specified table. It will also
-- return a method that, when invoked, will remove the curried function from the
-- specified table.
--
-- populatedTable
--     the table that is populated
-- returns
--     a function that behaves as described above
function Functions.FunctionPopulator(populatedTable)
    assert(type(populatedTable) == "table", "populatedTable is not a table object. populatedTable: " .. type(populatedTable));
    return function(listener, ...)
        listener = Curry(listener, ...);
        return Lists.Insert(populatedTable, listener);
    end;
end;
