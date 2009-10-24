Lists = {}; 
local Lists = Lists;

-- Mixes in iteration functionality for lists.
Mixins.Iteration(Lists, function(iterable)
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
