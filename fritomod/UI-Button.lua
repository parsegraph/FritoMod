if nil ~= require then
	require "wow/FontString";
	require "wow/Frame-Container";
	require "fritomod/Frames";
	require "fritomod/UI-Icon";
	require "fritomod/OOP-Class";
	require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local Button = OOP.Class("UI.Button", UI.Icon);
UI.Button = Button;
UI.Button = UI.Button;

local DEFAULT_STYLE = {

	-- Texture to show when button is enabled.
	normal = "default",

	-- Texture to show when the button is pushed. Optional.
	pushed = nil,

	-- Texture to overlay when the button is moused over. Optional.
	highlight = "highlight",

	-- Texture to use when the button is disabled. By default, the
	-- normal texture is desaturated
	disabled = nil,

	-- Family from Media-Button, used to quickly setup a button. If
	-- specified, these will act as default textures.
	buttonFamily = nil
};

function Button:Constructor(parent, style)
	parent = Frames.AsRegion(parent);
	assert(Frames.IsFrame(parent), "Parent frame must be provided");
	assert(parent.CreateTexture, "Provided parent must be a real frame");
	assert(parent.CreateFontString, "Provided parent must be a real frame");

	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);
	if self.style.buttonFamily then
		self.style:Inherits(Media.button[self.style.buttonFamily]);
	end;

	Button.super.Constructor(self, parent, style);

	self.highlight = Frames.AsRegion(self):CreateTexture(nil, "OVERLAY");
	self.highlight:SetBlendMode("ADD");
	if self.style.highlight then
		trace("Adding highlight to button");
		Frames.Texture(self.highlight, self.style.highlight);
	end;
	Anchors.ShareAll(self.highlight);
	self.highlight:Hide();

	self.clickListeners = ListenerList:New();

	self.enabled = false;

	self:Enable();
end;

function Button:Enable()
	if self:IsEnabled() then
		return;
	end;

	trace("Enabling button");
	self.enabled = true;

	self:SetTexture(self.style.normal);
	Frames.Saturate(self:GetInternalTexture());

	self.callbacks = {
		Callbacks.MouseDown(self, function(self)
			if self.style.pushed then
				trace("Using 'pushed' texture");
				self:SetTexture(self.style.pushed);
			end;
			return function()
				-- Don't curry this in case the normalTexture is
				-- changed.
				self:SetTexture(self.style.normal);
			end
		end, self),
		Callbacks.EnterFrame(self, Frames.Show, self.highlight),
		Callbacks.Click(self, self, "Click"),
		function()
			-- Show the disabled texture, if one is available. Otherwise,
			-- just desaturate the normal texture.
			if self.style.disabled then
				self:SetTexture(self.style.disabled);
			else
				Frames.Desaturate(self:GetInternalTexture());
			end;
		end
	};
end;

function Button:IsEnabled()
	return Bool(self.enabled);
end;
Button.Enabled = Button.IsEnabled;

function Button:OnClick(listener, ...)
	return self.clickListeners:Add(listener, ...);
end;

function Button:Click(...)
	if self.enabled then
		trace("Clicking button");
		self.clickListeners:Fire(...);
	end;
end;

function Button:Disable()
	if not self:IsEnabled() then
		return;
	end;

	trace("Disabling button");
	self.enabled = false;

	Lists.CallEach(self.callbacks);
	self.callbacks = nil;
end;

function Button:IsDisabled()
	return not Bool(self.enabled);
end;
Button.Disabled = Button.IsDisabled;

function Button:SetEnabled(enabled)
	enabled = Bool(enabled);
	if enabled then
		self:Enable();
	else
		self:Disable();
	end;
end;
