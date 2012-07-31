if nil ~= require then
	require "wow/api/Frame";
	require "wow/Texture";
	require "wow/Frame-Layer";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Media-Texture";
	require "fritomod/Media-Backdrop";
	require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local Icon = OOP.Class();
UI.Icon = Icon;

local DEFAULT_STYLE = {
	-- The unscaled icon size
	size = 50,

	-- The backdrop and border of the icon
	backdrop = "default",

	-- The blend mode of the texture
	blendMode = "DISABLE",

	-- The draw layer for the texture
	-- TODO Support sublayer
	drawLayer = "ARTWORK"
};

function Icon:Constructor(parent, style)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsRegion(parent), "Parent frame must be provided. Got: "..tostring(parent));
	assert(parent.GetChildren, "Provided parent must be a real frame");
	self.frame=CreateFrame("Frame", nil, parent);
	if tonumber(style) then
		style = {size = style};
	end;
	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);

	Frames.Size(self.frame, self.style.size);
	self.texture = self.frame:CreateTexture();
	self.texture:SetDrawLayer(self.style.drawLayer);
	self.texture:SetBlendMode(self.style.blendMode);
	assert(self.texture:GetParent());
	Anchors.ShareAll(self.texture);

	if self.style.backdrop and self.style.backdrop ~= "none" then
		Frames.Backdrop(self.frame, self.style.backdrop);
	end;
end;

function Icon:SetTexture(texture)
	Frames.Texture(self.texture, texture);
end;
Icon.Set = Icon.SetTexture;

function Icon:GetInternalTexture()
	return self.texture;
end;

function Icon:SetPortraitTexture(target)
	if self.texture then
		Frames.PortraitTexture(self.texture, target:Name());
	else
		self.texture = Frames.PortraitTexture(self.frame, target:Name());
	end;
end;
