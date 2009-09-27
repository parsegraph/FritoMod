MappedTestSuite = OOP.Class(TestSuite);

function MappedTestSuite:GetTests(matcher, ...)
    if select("#", ...) > 0 or IsCallable(matcher) then
       matcher = Curry(matcher, ...);
    elseif not matcher then
        matcher = Operator.True;
    else
        name = tostring(name);
        matcher = CurryFunction(Strings.Matches, name);
    end;
    return Iterators.FilterKey(self, function(key)
        return not MappedTestSuite[key] and matcher(key);
    end)
end;
