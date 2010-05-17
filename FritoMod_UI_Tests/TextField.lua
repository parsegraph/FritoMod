if nil ~= require then
	require "FritoMod_UI/Stage";

	require "FritoMod_UI_Tests/CreateUITestSuite";
end;

local Suite = CreateUITestSuite("FritoMod_UI/TextField");
local s=Stage.GetInstance();

function Suite:TestTextField()
	s:AddChild(TextField:New("Basekateer"));
	s:ValidateNow();
end;
