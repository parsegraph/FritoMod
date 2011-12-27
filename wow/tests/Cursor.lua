if nil ~= require then
	require "wow/Frame-Events";
	require "wow/World";
end;
local Suite=UnitTest("wow.Cursor");

function Suite:TestCursor()
	local world=WoW.World:New();
	local frame=WoW.Frame:New(world);

	local flag=Tests.Flag();
	frame:SetScript("OnEnter", flag.Raise);
	frame:SetScript("OnLeave", flag.Lower);
	local r=world:GetCursor():Enter(frame);
	flag.Assert()
	r();
	flag.AssertUnset()
end;
