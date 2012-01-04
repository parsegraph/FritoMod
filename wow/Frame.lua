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

function Frame:Constructor(world)
	self.world=world;
end;

function Frame:GetObjectType()
	return "Frame";
end;

function Frame:GetWorld()
	return self.world;
end;
