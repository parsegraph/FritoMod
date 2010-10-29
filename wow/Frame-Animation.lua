if nil ~= require then
	require "FritoMod_Functional/Metatables";

	require "WoW_UI/Frame";
end;

function WoW.Frame:CreateAnimationGroup()
	return WoW.AnimationGroup:New();
end;

WoW.Animation=OOP.Class();
function WoW.Animation:SetOrigin()
end;
function WoW.Animation:SetDuration()
end;
function WoW.Animation:SetScale()
end;

WoW.AnimationGroup=OOP.Class();
function WoW.AnimationGroup:CreateAnimation()
	return WoW.Animation:New();
end;

function WoW.AnimationGroup:Play()
end;
