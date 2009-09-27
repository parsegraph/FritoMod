Iterators = DefensiveTable();
local Iterators = Iterators;

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
        return index, list[index];
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
   return function(_, key)
      local nextKey, candidate = next(object, key);
      if nextKey ~= nil then
        return nextKey, candidate;
      end;
      local mt = getmetatable(object);
      if mt and type(mt.__index) == "table" and mt.__index ~= object then
         object = mt.__index;
         return Do();
      end;
      return nil;
   end;
end;

function Iterators.FilterKey(iterator, func, ...)
    iterator = Iterators.Iterate(iterator);
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(key) then
            return key, value;
        end;
    end;
end;

function Iterators.FilterPair(iterator, func, ...)
    iterator = Iterators.Iterate(iterator);
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(key, value) then
            return key, value;
        end;
    end;
end;

function Iterators.FilterValue(iterator, func, ...)
    iterator = Iterators.Iterate(iterator);
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(value) then
            return key, value;
        end;
    end;
end;

function Iterators.Flip(iterator)
    iterator = Iterators.Iterate(iterator);
    return function()
        local key, value = iterator();
        return value, key;
    end;
end;
