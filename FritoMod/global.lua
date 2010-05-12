if nil ~= require then
	require "FritoMod/CreateTestSuite";
end;

old_print=print;
print=function(...)
	if Strings then
		Strings.__print=old_print;
		Strings.Print(...);
	else
		old_print(...);
	end;
end;
