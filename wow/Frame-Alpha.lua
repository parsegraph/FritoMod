if nil ~= require then
	require "fritomod/OOP-Class";
	require "wow/Frame";
	require "wow/Frame-Events";
end;

local FrameAlpha = OOP.Class();

WoW.Frame:AddConstructor(FrameAlpha, "New");

function FrameAlpha:Constructor(frame)
	self.frame = frame;
	WoW.AssertFrame(frame);

	self.shown = true;

	WoW.Inject(frame, self, {
		"Show",
		"Hide",
		"IsShown",
		"IsVisible"
	});
end;

function FrameAlpha:Show()
	if not self.shown then
		self.shown=true;
		WoW.FireFrameEvent(self.frame, "OnShow");
	end;
end;

function FrameAlpha:Hide()
	if self.shown then
		self.shown=false;
		WoW.FireFrameEvent(self.frame, "OnHide");
	end;
end;

function FrameAlpha:IsShown()
	return self.shown;
end;

function FrameAlpha:IsVisible()
	return self.shown;
end;
