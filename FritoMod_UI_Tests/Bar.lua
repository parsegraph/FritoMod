if nil ~= require then
	require "FritoMod_UI/Stage";
end;

local Suite=CreateTestSuite("FritoMod_UI/Bar");
local s=Stage:GetInstance();

function Suite:TestBar()
	local b=Bar:New();
	b:SetWidth(200);
	b:SetHeight(200);
	b:SetTexture("Interface/Icons/Ability_Ambush");
	s:AddChild(b);
	s:ValidateNow();
end;

