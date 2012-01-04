if nil ~= require then
	require "fritomod/OOP-Class";
	require "wow/Frame";
end;

local FrameContainer = OOP.Class();

WoW.Frame:AddConstructor(FrameContainer, "New");

function FrameContainer:Constructor(frame)
	self.frame = frame;
	WoW.AssertFrame(frame);

	self.children = {};

	WoW.Inject(frame, self, {
		"GetNumChildren",
		"GetChildren",
		"GetNumRegions",
		"GetRegions"
	});
end;

function FrameContainer:GetNumChildren(...)
end;

function FrameContainer:GetChildren(...)
end;

function FrameContainer:GetNumRegions(...)
end;
function FrameContainer:GetRegions(...)
end;
