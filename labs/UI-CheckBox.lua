if nil ~= require then
	require "wow/FontString";
	require "wow/Frame-Container";
	require "fritomod/Frames";
	require "fritomod/UI-Icon";
	require "fritomod/OOP-Class";
	require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local CheckBox = OOP.Class(UI.Icon);
UI.CheckBox = CheckBox;
UI.Checkbox = UI.CheckBox;

local DEFAULT_STYLE = {

	-- Height of the checkbox and the text
	height = 16,

	-- Gap between the checkbox and the text
	gap = 4,

	-- Font for checkbox text
	font = "default",

	-- Explicit font size. Optional.
	fontSize = nil,
	
	-- Where the icon is positioned relative to the text.
	-- Either "LEFT" or "RIGHT"
	iconPosition = nil,
};

function CheckBox:Constructor(parent, style, text)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsFrame(parent), "Parent frame must be provided");
	assert(parent.CreateTexture, "Provided parent must be a real frame");
	assert(parent.CreateFontString, "Provided parent must be a real frame");

	self.hitbox = CreateFrame("Frame", nil, parent);

	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);

	if not self.style.size then
		self.style.size = self.style.height;
	end;

	self.style.backdrop = "none";

	-- This should ideally use something like PrefixedStyleClient
	local iconStyle = Metatables.StyleClient({}, self.style);
	iconStyle.blendMode = "ADD";
	iconStyle.drawLayer = "ADD";

	self.icon = UI.Icon:New(parent, self.style);
	self.icon:Set("checkbox");

	self.mark = Frames.AsRegion(self.icon):CreateTexture(nil, "OVERLAY");
	Frames.Texture(self.mark, "checkmark");
	Anchors.ShareAll(self.mark, self.icon);
	self.mark:Hide();

	self.highlight = Frames.AsRegion(self.icon):CreateTexture(nil, "OVERLAY");
	self.highlight:SetBlendMode("ADD");
	Frames.Texture(self.highlight, "check highlight");
	Anchors.ShareAll(self.highlight, self.icon);
	self.highlight:Hide();

	if not self.style.fontSize then
		self.style.fontSize = self.style.height;
	end;

	if self.style.iconPosition then
		self.style.iconPosition = self.style.iconPosition:upper();
	else
		self.style.iconPosition = "LEFT"
	end;
	assert(
		   self.style.iconPosition == "LEFT"
		or self.style.iconPosition == "RIGHT",
		"Invalid icon position: " .. self.style.iconPosition);

	self.text = Frames.Text(parent, self.style.font, self.style.height);
	self.text:SetHeight(self.style.height);

	self.listeners = ListenerList:New();

	self.callbacks = {
		Callbacks.Click(self.hitbox, self, "Toggle"),
		Callbacks.EnterFrame(self.hitbox, Frames.Show, self.highlight)
	};

	self.listeners:Add(function(self, value)
		if value then
			self.mark:Show();
		else
			self.mark:Hide();
		end;
	end, self);

	self.state = false;
end;

function CheckBox:OnChange(listener, ...)
	return self.listeners:Add(listener, ...);
end;

function CheckBox:Set(value)
	value = Bool(value);
	if value == self.state then
		return;
	end;

	self.state = value;
	self.listeners:Fire(self.state);
end;

function CheckBox:IsChecked()
	return Bool(self.state);
end;
CheckBox.IsSet=CheckBox.IsChecked;

function CheckBox:Toggle()
	self:Set(not self:IsChecked());
end;

function CheckBox:SetText(text)
	self.text:SetText(text);
end;

function CheckBox:Anchor(anchor)
	trace("Anchoring checkbox to " ..anchor);
	Anchors.Clear(self.icon, self.text, self.hitbox);
	local first, second = self.icon, self.text;
	if self.iconPosition == "RIGHT" then
		first, second = self.text, self.icon;
	end;
	Anchors.ShareOuter(self.hitbox, first, "LEFT");
	Anchors.ShareOuter(self.hitbox, second, "RIGHT");
	Anchors.ShareVertical(self.hitbox, self.icon);
	anchor = Frames.HComp(anchor);
	if anchor == "CENTER" then
		anchor = "LEFT";
	end;
	return Anchors.HJustify(anchor, self.style.gap, first, second);
end;

function CheckBox:Bounds(anchor)
	local hcomp = Frames.HorizontalComponent(anchor);
	-- Return the text only if it's really necessary. By default, we
	-- prefer returning the icon.
	--
	-- It's important not to return the hitbox here. It can be quite buggy
	-- to return a frame with complicated bounding rules like the hitbox has.
	if     self.style.iconPosition == "LEFT"  and hcomp == "RIGHT"
		or self.style.iconPosition == "RIGHT" and hcomp == "LEFT" then
		return self.text;
	else
		return self.icon;
	end;
end;

function CheckBox:Destroy()
	trace("Destroying check box");
	if self.callbacks then
		Lists.CallEach(self.callbacks);
		self.callbacks = nil;
	end;
	Frames.Destroy(self.icon, self.text, self.mark, self.highlight, self.hitbox);
end;
