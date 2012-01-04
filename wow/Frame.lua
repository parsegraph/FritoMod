if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/OOP-Class";

	require "wow/World";
end;

WoW=WoW or Metatables.Defensive();
WoW.Frame=OOP.Class();
local Frame=WoW.Frame;

function WoW.AssertFrame(frame)
	assert(frame, "Frame must not be falsy");
	assert(
		OOP.InstanceOf(WoW.Frame, frame),
		"Provided argument is not a frame. Given: "..type(frame)
	);
end;

function Frame:Constructor(parent)
end;

function Frame:GetObjectType()
	return "Frame";
end;

function Frame:SetAlpha()

end;

function Frame:SetFrameStrata()

end;

function Frame:SetBackdrop()

end;

function Frame:SetBackdropBorderColor()

end;

function Frame:SetHeight()

end;

function Frame:GetHeight()

end;

function Frame:SetWidth()

end;

function Frame:GetWidth()

end;
