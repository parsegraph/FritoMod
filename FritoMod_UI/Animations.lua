if nil~=require then
   require "WoW_UI/Frame-Layout";
   require "WoW_UI/Frame-Animation";
end

Animations={};

local function GetGroup(agOrFrame)
   if agOrFrame.CreateAnimationGroup then
      return agOrFrame:CreateAnimationGroup();
   end;
   return agOrFrame;
end;

function Animations.Scale(ag, duration, xscale, yscale)
   ag=GetGroup(ag);
   local scale=ag:CreateAnimation("scale");
   scale:SetDuration(duration);
   if yscale==nil then
      yscale=xscale;
   end;
   scale:SetScale(xscale, yscale);
   return scale, ag;
end;
Animations.Shrink=Animations.Scale;
Animations.Grow=Animations.Scale;

function Animations.Rotate(ag, duration, degrees)
   ag=GetGroup(ag);
   local rotate=ag:CreateAnimation("rotation");
   rotate:SetDuration(duration);
   rotate:SetDegrees(degrees);
   return rotate, ag;
end;
Animations.Rotation=Animations.Rotate;
Animations.Spin=Animations.Rotate;

function Animations.Alpha(ag, duration, change)
   ag=GetGroup(ag);
   local alpha=ag:CreateAnimation("alpha");
   alpha:SetDuration(duration);
   alpha:SetChange(change);
   return alpha, ag;
end;
Animations.Opacity=Animations.Alpha;

function Animations.Translate(ag, duration, xOffset, yOffset)
   if yOffset==nil then
      yOffset=xOffset;
   end;
   ag=GetGroup(ag);
   local translation=ag:CreateAnimation("translation");
   translation:SetDuration(duration);
   translation:SetOffset(xOffset, yOffset);
   return translation, ag;
end;
Animations.Translation=Animations.Translate;
Animations.Move=Animations.Translate;
