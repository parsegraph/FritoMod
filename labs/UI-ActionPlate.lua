if nil ~= require then
	require "wow/api/Frame";
	require "wow/Frame-Container";
	require "wow/Texture";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "labs/UI-PlayerFrame"
	require "fritomod/UI-Icon"
end;

UI = UI or {};

local ActionPlate = OOP.Class();
UI.ActionPlate = ActionPlate;

function ActionPlate:Constructor(parent)
	parent = Frames.AsRegion(parent);
	assert(parent, "Parent frame must be provided");
	assert(parent.CreateTexture, "Provided parent must be a real frame");

	self.actionIcon = UI.Icon:New(parent, 36);
	self.sourceFrame = UI.PlayerFrame:New(parent);
	self.targetFrame = UI.PlayerFrame:New(parent);
end;

function ActionPlate:Set(source, target, action)
	self.sourceFrame:Set(source);
	self.targetFrame:Set(target);
	self.actionIcon:SetTexture(action:Icon());
end;

function ActionPlate:Anchor(anchor)
	anchor = Frames.HorizontalComponent(anchor);
	trace("Anchoring ActionPlate to ".. anchor);
	return Anchors.HJustifyFrom(anchor, 3,
		self.sourceFrame,
		self.actionIcon,
		self.targetFrame
	);
end;

function ActionPlate:Bounds(anchor)
	local hcomp = Frames.HorizontalComponent(anchor);
	if hcomp == "CENTER" then
		return self.actionIcon;
	elseif hcomp == "LEFT" then
		return self.sourceFrame;
	else
		return self.targetFrame;
	end;
end;

function ActionPlate:Destroy()
	Frames.Destroy(
		self.sourceFrame,
		self.actionIcon,
		self.targetFrame
	);
end;
