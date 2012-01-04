if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "labs/UI-PlayerFrame"
	require "labs/UI-Icon"
end;

UI = UI or {};

ActionPlate = OOP.Class();
UI.ActionPlate = ActionPlate;

function ActionPlate:Constructor(anchored)
	self.frame = CreateFrame("Frame");
	Frames.Size(self.frame, 10);
	
	self.actionIcon = Icon:New(self.frame, 36);
	
	self.sourceFrame = PlayerFrame:New(self.frame, "right");
	
	self.targetFrame = PlayerFrame:New(self.frame);
	
	self.bounds = CreateFrame("Frame", nil, self.frame);
	Anchors.ShareAll(self.bounds, self.actionIcon);
	Anchors.Share(self.bounds, self.sourceFrame, "left");
	Anchors.Share(self.bounds, self.targetFrame, "right");
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
		Anchors.Center(self.actionIcon, self.frame);
		Anchors.Flip(self.sourceFrame, self.actionIcon, "LEFT", sourceGap);
		Anchors.Flip(self.targetFrame, self.actionIcon, "RIGHT", targetGap);
	else
		local anchored = Anchors.HJustifyFrom("right", 3,
			self.sourceFrame,
			self.actionIcon,
			self.targetFrame
		);
		assert(anchored);
		Anchors.Share(anchored, anchor, self.frame);
	end;
end;
