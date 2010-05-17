if nil ~= require then
	require "FritoMod_UI/Stage";
	require "FritoMod_UI/Button";
	
	require "FritoMod_UI_Tests/CreateUITestSuite";
end;

local Suite=CreateUITestSuite("FritoMod_UI/Button");
local s=Stage.GetInstance();

function Suite:TestButton()
	local button = Button:New();
	button:AddListener(print, "Clicked!");
	button:SetTexture("Interface/Icons/Ability_Ambush");
	s:AddChild(button);
	s:ValidateNow();
end;

