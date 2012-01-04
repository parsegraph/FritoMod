if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "fritomod/Media-Color";
	require "fritomod/Media-Texture";
	require "fritomod/Media-Backdrop";
	require "labs/UI-Icon"
end;

UI = UI or {};

local PlayerFrame = OOP.Class();
UI.PlayerFrame = PlayerFrame;

function PlayerFrame:Constructor(parent, orient)
	self.frame = CreateFrame("Frame", nil, parent);
	local height=30;
	Frames.WidthHeight(self.frame, 10, height);
	self.icon = Icon:New(self.frame, height);
	
	self.nameText = Frames.Text(self, "default", 10);
	self.nameText:SetHeight(height);
	
	self.bounds = CreateFrame("Frame", nil, self.frame);
	Anchors.ShareAll(self.bounds, self.icon);
	Anchors.Share(self.bounds, self.nameText, "right");
end;

function PlayerFrame:Set(target)
	self.icon:SetTexture(target:Class());
	self.nameText:SetText(target:Name());
	if target:Class() then
		Frames.Color(self.nameText, target:Class());
	else
		Frames.Color(self.nameText, "white");
	end;
end;

function PlayerFrame:Anchor(anchor)
	trace("Anchoring player frame: " ..anchor);
	Anchors.Clear(self.icon, self.nameText);
	local anchored = Anchors.HJustifyFrom(anchor, 2,
		self.icon,
		self.nameText
	);
	Anchors.Share(anchored, anchor, self.frame);
end;

