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
-- -- Animations.Alpha(ag, duration, ...)
-- -- Animations.Move(ag, duration, ...)
-- -- Animations.Rotate(ag, duration, ...)
-- -- Animations.Scale(ag, duration, ...)
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

if nil~=require then
	require "wow/Frame-Layout";
	require "wow/Frame-Animation";
	require "fritomod/Frames";
end

Animations={};

-- This function lets us define offsets using one number. It also lets
-- us omit offsets - this is something that Blizzard's animation can't do.
function Animations.Origin(animation, anchor, xOffset, yOffset)
	if xOffset==nil then
		xOffset=0;
	end;
	if yOffset==nil then
		xOffset, yOffset=Anchors.DiagonalGap(anchor, xOffset);
	end;
	animation:SetOrigin(anchor, xOffset, yOffset);
end;

local function Animator(animType, animator, ...)
	animator=Curry(animator, ...);

	local function DoAnimation(agOrFrame, duration, ...)
		assert(agOrFrame, "Frame must be provided");
		duration = Strings.GetTime(duration);
		if agOrFrame.CreateAnimationGroup then
			-- We were passed a frame, so do a one-shot animation.
			local frame  = agOrFrame;
			local ag = frame:CreateAnimationGroup();
			local anim = ag:CreateAnimation(animType);
			anim:SetDuration(duration);
			animator(anim, ...);
			ag:Play();
			return Seal(ag, "Stop");
		elseif agOrFrame.CreateAnimation then
			-- We were passed an animation group, so just create the animation.
			local anim = agOrFrame:CreateAnimation(animType);
			animator(anim, ...);
			return anim;
		else
			return DoAnimation(Frames.AsRegion(agOrFrame), duration, ...);
		end;
	end;
	return DoAnimation;
end;

local function CreateScale(scale, xscale, yscale)
	if yscale==nil then
	  yscale=xscale;
	end;
	scale:SetScale(xscale, yscale);
	return scale;
end;

Animations.Scale = Animator("Scale", CreateScale);
Animations.Shrink=Animations.Scale;
Animations.Grow=Animations.Scale;

Animations.ScaleTo = Animator("Scale", function(scale, duration, anchor, ...)
	scale = CreateScale(scale, ...);
	Animations.Origin(scale, Anchors.AnchorPair(anchor));
	return scale;
end);

Animations.HScaleTo = Animator("Scale", function(ag, anchor, magnitude)
	scale = CreateScale(scale, magnitude, 1);
	Animations.Origin(scale, Anchors.AnchorPair(anchor));
	return scale;
end);

Animations.VScaleTo = Animator("Scale", function(scale, anchor, magnitude)
	scale = CreateScale(scale, 1, magnitude);
	Animations.Origin(scale, Anchors.AnchorPair(anchor));
	return scale;
end);

Animations.Rotate = Animator("Rotation", "SetDegrees");
Animations.Rotation=Animations.Rotate;
Animations.Spin=Animations.Rotate;

Animations.Alpha = Animator("Alpha", "SetChange");
Animations.Opacity=Animations.Alpha;

function Animations.Show(agOrFrame, duration)
	assert(agOrFrame, "Animation must be passed a truthy value");
	duration = Strings.GetTime(duration);
	if agOrFrame.CreateAnimationGroup then
		-- We were passed a frame
		local frame = agOrFrame;
		local ag = agOrFrame:CreateAnimationGroup();
		local alpha = ag:CreateAnimation("Alpha");
		alpha:SetChange(1);
		alpha:SetDuration(duration);
		ag:Play();
		ag:SetScript("OnFinished", Seal(frame, "SetAlpha", 1));
		return Seal(ag, "Stop");
	elseif agOrFrame.CreateAnimation then
		local ag = agOrFrame;
		local alpha = ag:CreateAnimation("Alpha");
		alpha:SetChange(1);
		alpha:SetDuration(duration);
		return alpha;
	else
		return Animations.Show(Frames.AsRegion(agOrFrame), duration);
	end;
end;

function Animations.Hide(agOrFrame, duration)
	duration = Strings.GetTime(duration);
	if agOrFrame.CreateAnimationGroup then
		-- We were passed a frame
		local frame = agOrFrame;
		local ag = agOrFrame:CreateAnimationGroup();
		local alpha = ag:CreateAnimation("Alpha");
		alpha:SetChange(-1);
		alpha:SetDuration(duration);
		ag:Play();
		ag:SetScript("OnFinished", Seal(frame, "SetAlpha", 0));
		return Seal(ag, "Stop");
	elseif agOrFrame.CreateAnimation then
		local alpha = ag:CreateAnimation("Alpha");
		alpha:SetChange(-1);
		alpha:SetDuration(duration);
		return alpha;
	else
		return Animations.Hide(Frames.AsRegion(agOrFrame), duration);
	end;
end;

Animations.Translate = Animator("Translation", function(translation, xOffset, yOffset)
	if yOffset==nil then
	  yOffset=xOffset;
	end;
	translation:SetOffset(xOffset, yOffset);
end);
Animations.Translation=Animations.Translate;
Animations.Move=Animations.Translate;
