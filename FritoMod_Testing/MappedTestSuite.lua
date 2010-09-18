if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Operator";

    require "FritoMod_Collections/Iterators";

    require "FritoMod_Strings/Strings";

    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_Testing/TestSuite";
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
