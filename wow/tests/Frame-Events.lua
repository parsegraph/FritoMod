local Suite=CreateTestSuite("WoW_UI/Frame-Events");

function Suite:TestSetScript()
	local f=CreateFrame("Frame");
	f:SetScript("OnEvent", function()
	end);
end;
