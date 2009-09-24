Iterators = DefensiveTable();
local Iterators = Iterators;

function Iterators.VisibleFields(object)
   return function Do(_, key)
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
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(key) then
            return key, value;
        end;
    end;
end;

function Iterators.FilterPair(iterator, func, ...)
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(key, value) then
            return key, value;
        end;
    end;
end;

function Iterators.FilterValue(iterator, func, ...)
    func = Curry(func, ...);
    return function()
        local key, value = iterator();
        if key ~= nil and func(value) then
            return key, value;
        end;
    end;
end;

function Iterators.Flip(iterator)
    return function()
        local key, value = iterator();
        return value, key;
    end;
end;
