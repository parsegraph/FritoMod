if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_Collections/Mixins-MutableIteration";
end;

Lists = {}; 
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.MutableIteration(Lists);
Metatables.Defensive(Lists);

function Lists.Iterator(iterable)
    assert(type(iterable) == "table", "iterable is not a table");
    local index = 0;
	if #iterable == 0 then
		return Noop;
	end;
    return function()
        index = index + 1;
        if index > #iterable then
            return;
        end;
        return index, iterable[index];
    end;
end;

function Lists.Get(iterable, key)
    return iterable[key];
end;

function Lists.Insert(iterable, value)
    table.insert(iterable, value);
    return Functions.OnlyOnce(Lists.Remove, iterable, value);
end;

function Lists.Delete(iterable, key)
    return table.remove(iterable, key);
end;

function Lists.Size(iterable)
    return #iterable;
end;
