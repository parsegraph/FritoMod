if nil ~= require then
	require "fritomod/Metatables";

	require "wow/Frame";
	require "wow/Button";
end;

WoW = WoW or {};

function CreateFrame(frameType, name, parent, inherited)
	local frame = WoW.NewFrame(frameType, parent, inherited);
	if name then
		_G[name] = frame;
	end;
	return frame;
end;

-- vim: noet :
