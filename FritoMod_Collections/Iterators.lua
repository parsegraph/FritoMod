if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_Collections/Mixins-Iteration";
end;

-- A collection of functions dealing with iterators. Iterators are functions that accept no arguments and
-- return the "next" value in a collection when called. When they reach the end of their collection,
-- they return nil.
Iterators = {};
local Iterators = Iterators;

-- Mixes in iteration functionality for iterators
Mixins.Iteration(Iterators);
Metatables.Defensive(Iterators);

-- Iterate over a function, repeatedly calling it until it returns nil. The iterator does not need to return
-- keys; they will be provided automatically.
function Iterators.Iterator(iterator)
    if type(iterator) == "table" and not IsCallable(iterator) then
        return Iterators.IterateMap(iterator);
    end;
    assert(IsCallable(iterator), "Iterator is not callable. Type: " .. type(iterator));
    local c=0;
    return function()
        local k,v=iterator()
        if k ~= nil and v == nil then
            c=c+1;
            return c,k;
        else
            return k,v;
        end;
    end
end;

function Iterators.Iterate(value, ...)
    assert(value, "value is falsy");
    if IsCallable(value) then
        return Curry(value, ...);
    end;
    if type(value) == "table" then
        if #value > 0 then
            return Iterators.IterateList(value);
        end;
        return Iterators.IterateMap(value);
    end;
    if type(value) == "string" then
        return Iterators.IterateString(value);
    end;
    if type(value) == "number" then
        return Iterators.IterateValue(value, ...);
    end;
    error("value is not a valid type. Type: " .. type(value));
end;

function Iterators.IterateValues(...)
    return Iterators.IterateList({...});
end;

function Iterators.IterateString(str)
    assert(type(str) == "string", "str is not a string. Type: " .. type(str));
    local index = 0;
    return function()
        if index == #str then
            return;
        end;
        index = index + 1;
        local value;
        if index > #str then
            index = #str;
        end;
        return index, str:sub(index, index);
    end;
end;

function Iterators.IterateMap(map)
    assert(type(map) == "table", "map is not a table. Type: " .. type(map));
    local index = nil;
    return function()
		if map == nil then
			-- This iterable is dead, so return nothing.
			return;
		end;
        local value;
        index, value = next(map, index);
		if index == nil then
			-- Kill this iterable.
			map = nil;
		end;
        return index, value;
    end;
end;

function Iterators.IterateList(list)
    assert(type(list) == "table", "list is not a table. Type: " .. type(list));
    local index = 0;
    return function()
        if index == #list then
            return;
        end;
        index = index + 1;
        local item = list[index];
        if item == nil then
            return;
        end;
        return index, item;
    end;
end;

function Iterators.Flip(iterator)
    iterator = Iterators.Iterate(iterator);
    return function()
        local key, value = iterator();
        return value, key;
    end;
end;

function Iterators.Repeat(...)
    local args = { ... };
    local iterator = nil;
    return function()
        local value = iterator();
        if value == nil then
            iterator = Iterators.Iterate(unpack(args));
            value = iterator();
            assert(value ~= nil, "Cannot repeat over an empty iterable");
        end;
        return value;
    end;
end;

-- Iterates using each provided iterator, starting with the first iterator. Once
-- an iterator is exhausted, the next iterator is used until all iterators have been
-- expended.
--
-- I wrote this because I originally was only able to iterate over one bag at a time.
-- I wanted to iterate over multiple bags, so this function let me chain those iterators
-- together. I ended up rewriting how I did bag iteration, but I still like this function.
function Iterators.Chain(...)
    local iterators={...};
    return function()
        local k,v;
        while #iterators>0 and k==nil do
            k,v=iterators[1]();
            if k==nil then
                table.remove(iterators, 1);
            end;
        end;
        return k,v;
    end;
end;

-- Consumes an iterator, returning a list of its elements.
--
-- iterator, ...
--     the iterator that returns results
-- returns
--     a list of all results 
function Iterators.Consume(iterator, ...)
    iterator = Curry(iterator, ...);
    local items = {};
    for value in iterator do
        table.insert(items, value);
    end;
    return items;
end;

function Iterators.Counter(startValue, endValue, step)
    if endValue == nil and step == nil then
        -- Intentionally make endValue the current startValue.
        startValue, endValue, step = 1, startValue, step;
    end;
    if step == nil then
        if endValue == nil or startValue < endValue then
            step = 1;
        else
            step = -1;
        end;
    end;
    assert(step ~= 0, "A step of zero does not make sense");
    if endValue ~= nil then
        assert((step > 0 and startValue < endValue) or (step < 0 and startValue > endValue), 
            ("Step is not valid for the range. Start: %d, End: %d, Step: %d"):format(startValue, endValue, step)
        );
    end;
    local current = nil;
    return function()
        if current == nil then
            current = startValue
        else
            current = current + step;
        end
        if endValue ~= nil and (step > 0 and current > endValue) or (step < 0 and current < endValue) then
            -- We've exceed our endValue, so return nil.
            return nil;
        end;
        return current;
    end;
end;

function Iterators.IterateVisibleFields(object)
    local key;
    local maskedKeys = {};
    local function DoIteration()
        local value;
        key, value = next(object, key);
        if key ~= nil then
            if maskedKeys[key] then
                return DoIteration();
            end;
            maskedKeys[key] = true;
            return key, value;
        end;
        key = nil;
        local mt = getmetatable(object);
        if mt and type(mt.__index) == "table" and mt.__index ~= object then
            object = mt.__index;
            return DoIteration();
        end;
        return nil;
    end;
    return DoIteration;
end;

-- It's a Fibonacci sequence, starting at zero.
-- 0,1,1,2,3,5,8
function Iterators.Fibonacci()
    local a,b;
    return function()
        if b~=nil then
            a,b=b,a+b;
            return b;
        elseif a~=nil then
            b=1;
            return 1;
        else
            a=0;
            return 0;
        end;
    end;
end;
Iterators.Fibbonaci =Iterators.Fibonacci;
Iterators.Fibbonacci=Iterators.Fibonacci;
Iterators.Fibonaci  =Iterators.Fibonacci;
