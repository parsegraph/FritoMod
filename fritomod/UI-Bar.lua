if nil ~= require then
	require "wow/Frame-Container";
	require "fritomod/Frames";
	require "fritomod/UI-Icon";
	require "fritomod/OOP-Class";
	require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local Bar = OOP.Class();
UI.Bar = Bar;

local DEFAULT_STYLE = {
	-- Which direction is the "minimum"
	barAnchor = "left",

	-- The size of a full bar. This will be used even if the bar is "vertical"
	width = 100,

	-- The static height of the bar. This will be used even if the bar is "vertical"
	height = 30,

	-- Optional texture. This will override the bar color if provided.
	barTexture = nil,

	-- Color for the bar. This will modify the bar texture if provided.
	barColor = nil,

	-- Background texture, visible when the bar is depleted. Overrides background color
	backgroundTexture = nil,

	-- Background color. This will be the background's vertex color if provided.
	backgroundColor = nil,

	invert = false
};

function Bar:Constructor(parent, style)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsRegion(parent), "Parent frame must be provided. Got: "..tostring(parent));

	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);

	self.frame = CreateFrame("Frame", nil, parent);
	self.background = self.frame:CreateTexture(nil, "BACKGROUND");
	self.bar = self.frame:CreateTexture(nil, "ARTWORK");

	Anchors.ShareAll(self.background, self.frame);

	Frames.WH(self.frame, self.style.width, self.style.height);
	Frames.WH(self.bar, self.style.width, self.style.height);

	if self.style.barTexture then
		Frames.Texture(self.bar, self.style.barTexture);
		if self.style.barColor then
			self.bar:SetVertexColor(Media.color[self.style.barColor]);
		end;
	else
		Frames.Color(self.bar, self.style.barColor or "green");
	end;

	if self.style.backgroundTexture then
		Frames.Texture(self.background, self.style.backgroundTexture);
		if self.style.backgroundColor then
			self.bar:SetVertexColor(Media.color[self.style.backgroundColor]);
		end;
	else
		Frames.Color(self.background, self.style.backgroundColor or "red");
	end;
	
	Anchors.Share(self.bar, self.frame, self.style.barAnchor);
end;

function Bar:SetPercentCallback(callback, ...)
	callback=Curry(callback, ...);
	if self.callback then
		self.callback();
	end;
	self.callback = callback(self, "SetPercent");
end;

function Bar:SetPercent(percent)
	Frames.WH(self.bar, self.style.width * percent, self.style.height);
end;

function Bar:Destroy()
	if self.callback then
		self.callback();
		self.callback = nil;
	end;
	Frames.Destroy(self.bar, self.frame);
end;
