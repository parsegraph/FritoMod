-- Tests that assert that non-standard functionality is available to FritoMod. Test failure
-- indicates that the environment is lacking some required, albeit non-standard, components.

if nil ~= require then
	require "fritomod/ReflectiveTestSuite";
	require "fritomod/Assert";
	require "fritomod/Tests";
end;

local Suite = ReflectiveTestSuite:New("portability");

function Suite:TestStackTraceAccessors()
	if debugstack then
		Assert.Type("function", debugstack, "debugstack is a function");
		local stack = debugstack();
		Assert.Type("string", stack, "debugstack returns a string");
	else
		Assert.Type("function", debug.getinfo, "debug.getinfo is a function");
		local level = debug.getinfo(1);
		Assert.Type("table", level, "getinfo returns a stack level");
	end;
end;
