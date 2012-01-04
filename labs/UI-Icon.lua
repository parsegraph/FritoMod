if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Media-Texture";
	require "fritomod/Media-Backdrop";
end;

UI = UI or {};

local Icon = OOP.Class();
UI.Icon = Icon;

function Icon:Constructor(parent, size)
	self.frame=CreateFrame("Frame", nil, parent);
	Frames.Size(self.frame, size);
	Frames.Backdrop(self.frame);
end;

function Icon:SetTexture(texture)
	if self.texture then
		Frames.Texture(self.texture, texture);
	else
		self.texture = Frames.Texture(self.frame, texture);
	end;
end;

function Icon:SetPortraitTexture(target)
	if self.texture then
		Frames.PortraitTexture(self.texture, target:Name());
	else
		self.texture = Frames.PortraitTexture(self.frame, target:Name());
	end;
end;
