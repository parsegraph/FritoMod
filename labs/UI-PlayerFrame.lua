if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "fritomod/Media-Color";
	require "fritomod/Media-Texture";
	require "fritomod/Media-Font";
	require "fritomod/Media-Backdrop";
	require "fritomod/CombatObjects-Target";
	require "fritomod/UI-Icon"
end;

UI = UI or {};

local PlayerFrame = OOP.Class("UI.PlayerFrame");
UI.PlayerFrame = PlayerFrame;

function PlayerFrame:Constructor(parent, height)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsFrame(parent), "Parent frame must be provided");
	assert(parent.CreateTexture, "Provided parent must be a real frame");

	height = height or 30;
	self.icon = UI.Icon:New(parent);
	Frames.WH(self.icon, height);

	self.nameText = Frames.Text(parent, "default", 12, "outline");
	self.nameText:SetHeight(height);
end;

function PlayerFrame:Set(target)
	self.icon:SetTexture(target:Class());
	self.nameText:SetText(target:ShortName());
	if target:Class() then
		Frames.Color(self.nameText, target:Class());
	else
		Frames.Color(self.nameText, "white");
	end;
	Frames.BorderColor(self.icon, target:FactionColor());
end;

function PlayerFrame:Anchor(anchor)
	trace("Anchoring player frame: " ..anchor);
	Anchors.Clear(self.icon, self.nameText);
	return Anchors.HJustifyFrom(anchor, 2,
		self.icon,
		self.nameText
	);
end;

function PlayerFrame:Bounds(anchor)
	local hcomp = Frames.HorizontalComponent(anchor);
	if hcomp == "CENTER" then
		return self.nameText;
	elseif hcomp == "LEFT" then
		return self.icon;
	else
		return self.nameText;
	end;
end;

function PlayerFrame:Destroy()
	trace("Destroying player frame");
	Frames.Destroy(self.icon, self.nameText);
	PlayerFrame.super.Destroy(self);
end;

