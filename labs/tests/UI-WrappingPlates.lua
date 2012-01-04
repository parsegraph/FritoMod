if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/Frames";
	require "labs/UI-ActionPlate"
end;
local Suite=CreateTestSuite("labs.UI-WrappingPlates");

function Suite:TestBasicWrapping()
	local wrapper = UI.WrappingPlates:New();
	local parent = CreateFrame("Frame");
	for i=1, 25 do
		wrapper:Add(UI.ActionPlate:New(parent));
	end;
end;
