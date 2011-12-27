local Suite=UnitTest("fritomod.StackTrace");
if nil ~= require then
	require "fritomod/Operator";
end;

function Suite:TestFilter()
	local stack=StackTrace:New();
	Assert.Equals(0, #stack:Filter(Operator.False));
end;
