local Suite=UnitTest("StackTrace");
if nil ~= require then
    require "Operator";
end;

function Suite:TestFilter()
    local stack=StackTrace:New();
    Assert.Equals(0, #stack:Filter(Operator.False));
end;
