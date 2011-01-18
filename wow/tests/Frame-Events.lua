local Suite=CreateTestSuite("wow/Frame-Events");

function Suite:TestSetScript()
    local flag=Tests.Flag();
	local frame=CreateFrame("Frame");
	frame:SetScript("OnEvent", flag.Raise);
    frame:FireEvent("OnEvent");
    flag.Assert();
    flag.Reset();
    frame:SetScript("OnEvent", nil);
    frame:FireEvent("OnEvent");
    flag.AssertUnset();
end;
