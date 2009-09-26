ReflectiveTestSuite = OOP.Class(TestSuite);
local ReflectiveTestSuite = ReflectiveTestSuite;

function ReflectiveTestSuite:GetTests()
    return Iterators.FilterKey(Iterators.VisibleFields(self), Strings.Matches, "^Test");
end;
