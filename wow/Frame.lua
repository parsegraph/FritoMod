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

do
	local frameTypes = {};
	function WoW:RegisterFrameType(name, creator, ...)
		name = tostring(name):lower();
		creator = Curry(creator, ...);
		frameTypes[name] = creator;
	end;

	function WoW:NewFrame(name, ...)
		name = tostring(name):lower();
		local creator = frameTypes[name];
		assert(creator, "No creator for frametype: "..name);
		return creator(...);
	end;
end;

WoW:RegisterFrameType("Frame", WoW.Frame, "New");

function Frame:GetObjectType()
	return "Frame";
end;

function Frame:SetFrameStrata()

end;
