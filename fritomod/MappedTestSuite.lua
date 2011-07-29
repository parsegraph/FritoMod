if nil ~= require then
    require "fritomod/basic";
    require "fritomod/currying";
    require "fritomod/Operator";
    require "fritomod/Iterators";
    require "fritomod/Strings";
    require "fritomod/OOP-Class";
    require "fritomod/TestSuite";
end;

MappedTestSuite = OOP.Class(TestSuite);

local EMPTY_SUITE;

function MappedTestSuite:GetTests(matcher, ...)
    if not EMPTY_SUITE then
        EMPTY_SUITE = MappedTestSuite:New();
    end;
    if select("#", ...) > 0 or IsCallable(matcher) then
       matcher = Curry(matcher, ...);
    elseif not matcher then
        matcher = Operator.True;
    else
        matcher = CurryFunction(Strings.Matches, tostring(matcher));
    end;
    local name = self:GetName();
    local iterator = Iterators.IterateVisibleFields(self);
    iterator = Iterators.FilteredIterator(iterator, function(key, value)
        return not EMPTY_SUITE[key] and matcher(key);
    end);
    iterator = Iterators.DecorateIterator(iterator, function(key, value)
        if name then
            return ("%s.%s"):format(name, key), value;
        end;
        return key, value;
    end);
    return iterator;
end;
