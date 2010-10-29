if nil~=require then
   require "wow/Frame-Layout";
   require "wow/Frame-Animation";
end

-- Animations contains functions for creating different kinds of animations. I personally
-- like Blizzard's API for animating, since I feel like it is well-designed. My only
-- complaint is that it is somewhat verbose. These functions remove a lot of that verbosity.
--
-- We don't cover up Blizzard's functions, and we operate on Blizzard's animation objects
-- directly, so you're free to mix and match this code and the official API.
--
-- -- We don't have helper functions for CreateFrame, since we haven't needed any.
-- local f=CreateFrame("Frame", nil, UIParent);
--
-- -- I like using my helper functions since I find them quick to write and easy to understand
-- -- but you're free to use Blizzard's stuff here.
-- Frames.Size(f, 200, 20);
-- Frames.Color(f, "red", .8);
-- f:SetPoint("center");
--
-- -- Once again, I don't like covering up constructors unless I have a really good reason. I
-- -- feel like having these exposed gives an assurance that there's no magic behind the scenes:
-- -- really are just plain ol' objects.
-- local ag=f:CreateAnimationGroup();
--
-- -- This creates an opacity change, all the way to transparent, in five seconds. All animation
-- -- constructors follow this pattern:
-- --
-- -- Animations.[Alpha|Move|Rotate|Scale](ag, duration, ...)
-- --
-- -- I find this convention to be convenient when trying to remember the signatures.
-- --
-- -- This returns both the animation and the animation group. We don't need either, so we ignore
-- -- them.
-- Animations.Alpha(ag, 5, -1);
--
-- -- Here, we create a scale animation as well. It's also a 5-second duration scale. The 0,1 are
-- -- multipliers we use for the scale. The 0 will reduce our frame to nothing on the horizontal axis.
-- -- The 1 will do nothing for our vertical axis. This will show our frame shrinking to the middle,
-- -- but remaining tall.
-- local scale=Animations.Scale(ag, 5, 0, 1);
--
-- -- We also can set the origin of the scale. This makes our frame shrink from right to left, with the
-- -- left side not moving. Blizzard provides a function to do this, but I like ours since we don't
-- -- have to always specify the offsets.
-- Animations.Origin(scale, "left");
--
-- -- Finally, play our animation. Once the animation is complete, it will reset to its original shape.
-- -- You can tweak this by setting the looping behavior, or by adding a handler for the OnFinished 
-- -- event.
-- ag:Play();
Animations={};

local function GetGroup(agOrFrame)
   if agOrFrame.CreateAnimationGroup then
      return agOrFrame:CreateAnimationGroup();
   end;
   return agOrFrame;
end;

-- This function lets us define offsets using one number. It also lets
-- us omit offsets - this is something that Blizzard's animation can't do.
function Animations.Origin(animation, anchor, xOffset, yOffset)
    if xOffset==nil then
        xOffset=0;
    end;
    if yOffset==nil then
        xOffset, yOffset=Anchors.ExpandGapValues(anchor, xOffset);
    end;
    animation:SetOrigin(anchor, xOffset, yOffset);
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
