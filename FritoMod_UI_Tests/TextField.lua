if nil ~= require then
	require "FritoMod_UI/Stage";
end;

local Suite = CreateTestSuite("FritoMod_UI/TextField");
local s=Stage:GetInstance();

function Suite:TestTextField()
	s:AddChild(TextField:New("Basekateer"));
	s:ValidateNow();
end;
