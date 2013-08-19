if nil ~= require then
	require "wow/Frame";
end;

function WoW.Frame:CreateAnimationGroup()
	return WoW.AnimationGroup:New();
end;

WoW.Animation=OOP.Class("WoW.Animation");
function WoW.Animation:SetOrigin()
end;
function WoW.Animation:SetDuration()
end;
function WoW.Animation:SetScale()
end;

WoW.AnimationGroup=OOP.Class("WoW.AnimationGroup");
function WoW.AnimationGroup:CreateAnimation()
	return WoW.Animation:New();
end;

function WoW.AnimationGroup:Play()
end;
