if nil ~= require then
	require "FritoMod_UI/Stage";
end;

local Suite=CreateTestSuite("FritoMod_UI/Button");
local s=Stage:GetInstance();

function Suite:TestButton()
	local button = Button:New();
	button:AddListener(print, "Clicked!");
	button:SetTexture("Interface/Icons/Ability_Ambush");
	s:AddChild(button);
	s:ValidateNow();
end;

