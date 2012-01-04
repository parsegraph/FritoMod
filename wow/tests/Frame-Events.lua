local Suite=CreateTestSuite("wow/Frame-Events");

function Suite:TestSetScript()
	local flag=Tests.Flag();
	local frame=WoW.Frame:New("Frame");
	frame:SetScript("OnEvent", flag.Raise);
	frame:_FireEvent("OnEvent");
	flag.Assert();
	flag.Reset();
	frame:SetScript("OnEvent", nil);
	frame:_FireEvent("OnEvent");
	flag.AssertUnset();
end;
