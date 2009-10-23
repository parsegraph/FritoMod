Iterators = Metatables.Defensive();
local Iterators = Iterators;

function Iterators.Flip(iterator)
    iterator = Iterators.Iterate(iterator);
    return function()
        local key, value = iterator();
        return value, key;
    end;
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

function Iterators.IterateString(str)
    assert(type(str) == "string", "str is not a string. Type: " .. type(str));
    local index = 0;
    return function()
        local value;
        index = index + 1;
        if index <= #str then
            return index, str:sub(index, index);
        end;
    end;
end;

function Iterators.IterateMap(map)
    assert(type(map) == "table", "map is not a table. Type: " .. type(list));
    local index = nil;
    return function()
        local value;
        index, value = next(map, index);
        return index, value;
    end;
end;

function Iterators.IterateList(list)
    assert(type(list) == "table", "list is not a table. Type: " .. type(list));
    local index = 0;
    return function()
        index = index + 1;
        local item = list[index];
        if item == nil then
            return;
        end;
        return index, item;
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

function Iterators.Count(startValue, endValue, step)
    if endValue == nil and step == nil then
        -- Intentionally make endValue the current startValue.
        startValue, endValue, step = 1, startValue, step;
    end;
    if step == nil then
        if startValue < endValue then
            step = 1;
        else
            step = -1;
        end;
    end;
    assert(step ~= 0, "Step is zero");
    assert((step > 0  and startValue < endValue) or (step < 0 and startValue > endValue), 
        format("Step is not valid for the range. Start: %d, End: %d, Step: %d", minValue, endValue, step)
    );
    local current = nil;
    return function()
        if current == nil then
            current = startValue
        else
            current = current + step;
        end
        if (step > 0 and current > endValue) or (step < 0 and current < endValue) then
            -- We've exceed our endValue, so return nil.
            return nil;
        end;
        return current;
    end;
end;

function Iterators.VisibleFields(object)
    local key;
    function DoIteration()
        local candidate;
        key, candidate = next(object, key);
        if key ~= nil then
            return key, candidate;
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

function Iterators.Map(iterator, func, ...)
    local results = {};
    func = Curry(func, ...);
    while true do
        local value = iterator();
        if value == nil then
            break;
        end;
        local result = func(value);
        if result ~= nil then
            Lists.Insert(results, result);
        end;
    end;
    return results;
end;

local function FilteredIterator(evaluator)
    return function(iterator, func, ...)
        iterator = Iterators.Iterate(iterator);
        func = Curry(func, ...);
        return function()
            while true do
                local key, value = iterator();
                if key == nil then 
                    break;
                end;
                if evaluator(func, key, value) then
                    return key, value;
                end;
            end;
        end;
    end;
end;

Iterators.FilterPair = FilteredIterator(function(func, key, value)
    return func(key, value);
end);

Iterators.FilterKey = FilteredIterator(function(func, key, value)
    return func(key);
end);

Iterators.FilterValue = FilteredIterator(function(func, key, value)
    return func(value);
end);
