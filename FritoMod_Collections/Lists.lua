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

function Lists.Next(iterable, i)
    if i==nil or i<1 then
        i=0;
    end;
    i=i+1;
    if iterable[i] then
        return i, iterable[i];
    end;
end;

function Lists.Previous(iterable, i)
    if i==nil or i<1 then
        i=0;
    end;
    i=i-1;
    if iterable[i] then
        return i, iterable[i];
    end;
end;

function Lists.Length(iterable)
    return #iterable;
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

function Lists.ContainsValue(iterable, target, testFunc, ...)
    if testFunc then
        testFunc=Curry(testFunc, ...);
    end;
    for i=1,#iterable do
        if testFunc then
            if testFunc(iterable[i], target) then
                return true;
            end;
        elseif target==iterable[i] then
            return true;
        end;
    end;
    return false;
end;

function Lists.ContainsKey(iterable, target, testFunc, ...)
    if not testFunc then
        return type(target)=="number" and target>=1 and target <=#iterable;
    end;
    testFunc=Curry(testFunc, ...);
    for i=1, #iterable do
        if testFunc(iterable[i], target) then
            return true;
        end;
    end;
    return false;
end;
