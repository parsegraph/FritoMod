local Suite=CreateTestSuite("wow/Frame-Events");

function Suite:TestSetScript()
	local f=CreateFrame("Frame");
	f:SetScript("OnEvent", function()
	end);
end;
