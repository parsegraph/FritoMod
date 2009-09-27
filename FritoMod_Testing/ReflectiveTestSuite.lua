ReflectiveTestSuite = OOP.Class(TestSuite);
local ReflectiveTestSuite = ReflectiveTestSuite;

local EMPTY_SUITE;

function ReflectiveTestSuite:GetTests()
    return Iterators.FilterKey(Iterators.VisibleFields(self), function(key)
        if not EMPTY_SUITE then
            EMPTY_SUITE = ReflectiveTestSuite:New();
        end;
        return not EMPTY_SUITE[key];
    end);
end;
