MappedTestSuite = OOP.Class(TestSuite);

local EMPTY_SUITE;

function MappedTestSuite:GetTests(matcher, ...)
    if select("#", ...) > 0 or IsCallable(matcher) then
       matcher = Curry(matcher, ...);
    elseif not matcher then
        matcher = Operator.True;
    else
        name = tostring(name);
        matcher = CurryFunction(Strings.Matches, name);
    end;
    return Tables.FilterKeys(self, function(key)
        if not EMPTY_SUITE then
            EMPTY_SUITE = MappedTestSuite:New();
        end;
        return not EMPTY_SUITE[key] and matcher(key);
    end);
end;
