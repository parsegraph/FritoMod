Lists = {}; 
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.MutableIteration(Lists, function(iterable)
    assert(type(iterable) == "table", "iterable is not a table");
    local index = 0;
    return function()
        index = index + 1;
        if index > #iterable then
            return;
        end;
        return index, iterable[index];
    end;
end);
Metatables.Defensive(Lists);

function Lists.Insert(iterable, value)
    table.insert(iterable, value);
    return Curry(Lists.Remove, iterable, value);
end;

