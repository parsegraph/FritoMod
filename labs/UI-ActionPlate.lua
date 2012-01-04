if nil ~= require then
	require "wow/api/Frame";
	require "wow/Frame-Container";
	require "wow/Texture";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "labs/UI-PlayerFrame"
	require "labs/UI-Icon"
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
	
	self.bounds = parent:CreateTexture();
	Anchors.ShareOuterAll(self.bounds, self.actionIcon);
	Anchors.ShareOuter(self.bounds, self.sourceFrame, "left");
	Anchors.ShareOuter(self.bounds, self.targetFrame, "right");
end;

function ActionPlate:Set(source, target, action)
	self.sourceFrame:Set(source);
	self.targetFrame:Set(target);
	self.actionIcon:SetTexture(action:Icon());
end;

function ActionPlate:Anchor(anchor)
	Anchors.Clear(
		self.actionIcon,
		self.sourceFrame,
		self.targetFrame
	);
	if anchor == "CENTER" then
		Anchors.Flip(self.sourceFrame, self.actionIcon, "LEFT", sourceGap);
		Anchors.Flip(self.targetFrame, self.actionIcon, "RIGHT", targetGap);
		return self.actionIcon;
	else
		return Anchors.HJustifyFrom("right", 3,
			self.sourceFrame,
			self.actionIcon,
			self.targetFrame
		);
	end;
end;
