local Suite=CreateTestSuite("wow/Frame-Events");

function Suite:TestSetScript()
	local flag=Tests.Flag();
	local frame=WoW.Frame:New("Frame");
	frame:SetScript("OnEvent", flag.Raise);
	WoW.FireFrameEvent(frame, "OnEvent");
	flag.Assert();
	flag.Reset();
	frame:SetScript("OnEvent", nil);
	WoW.FireFrameEvent(frame, "OnEvent");
	flag.AssertUnset();
end;
