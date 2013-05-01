if nil ~= require then
	require "fritomod/CreateTestSuite";
end;

if not UIParent then
	require "wow/Frame";
    UIParent = WoW.CreateUIParent();
end;
