if nil ~= require then
	require "wow/FontString";
	require "wow/Frame-Container";
	require "fritomod/Frames";
	require "fritomod/UI-Icon";
	require "fritomod/OOP-Class";
	require "fritomod/Metatables-StyleClient";
end;

UI = UI or {};

local MonitorIcon = OOP.Class("UI.MonitorIcon", UI.Icon);
UI.MonitorIcon = MonitorIcon;

-- These style settings are in addition to those in UI.Icon.
local DEFAULT_STYLE = {

	-- Font for cooldown text
	font = "friz",

	-- Font size for cooldown text. If nil, defaults to 1/2 of size
	fontSize = nil,

	-- Font color for cooldown text
	fontColor = "white",

	-- Font ouline for cooldown text
	fontOutline = "",

	-- Function called to format the cooldown time
	fontFormat = Strings.FormatShortTime,

	-- Shrink the font until it fits without wrapping
	fontShrinkToFit = true,

	-- Texture alpha when monitor is inactive
	inactiveAlpha = 1,

	-- Texture alpha when monitor is active
	activeAlpha = 1,

	-- Update frequency, in seconds
	frequency = .2,

	-- Use completed time instead of remaining time
	useComplete = false
};

function MonitorIcon:Constructor(parent, style)
	self.style = Metatables.StyleClient(style);
	self.style:Inherits(DEFAULT_STYLE);
	MonitorIcon.super.Constructor(self, parent, self.style);

	if not self.style.fontSize then
		self.style.fontSize = self.style.size / 2;
	end;

	self.text = Frames.Text(
		self,
		self.style.font,
		self.style.fontSize,
		self.style.fontColor,
		self.style.fontOutline
	);
	Anchors.ShareAll(self.text);
	self.text:SetJustifyH("center");
	self.text:SetJustifyV("middle");
end;

function MonitorIcon:SetMonitor(monitor)
	if self.remover then
		self.remover();
		self.remover=nil;
	end;
	self.monitor = monitor;
	if not self.monitor then
		return;
	end;
	self.remover = Curry(Lists.CallEach, {
		self.monitor:OnState("Active", Timing.Every, self.style.frequency, function(self)
			local num = monitor:Remaining();
			if self.style.useComplete then
				num = monitor:Complete();
			end;
			self.text:SetText(self.style.fontFormat(num));
			if self.style.fontShrinkToFit then
				Frames.ShrinkFontToFit(self.text, self.style.fontSize);
			end;
		end, self),
		self.monitor:OnState("Active", function(self)
			Frames.Alpha(self, self.style.activeAlpha);
			self:SetTexture(self.monitor:Value());
			return Seal(Frames.Alpha, self, self.style.inactiveAlpha);
		end, self)
	});
	if not self.monitor:IsActive() then
		Frames.Alpha(self, self.style.inactiveAlpha);
	end;
end;

function MonitorIcon:Monitor()
	return self.monitor;
end;

function MonitorIcon:Destroy()
	if self.remover then
		self.remover();
	end;
	self.monitor = nil;
	UI.MonitorIcon.super.Destroy(self);
end;
