local Suite=CreateTestSuite("WoW_UI/FontString");

function Suite:TestCreateFontString()
	local f=CreateFrame("Frame");
	assert(f:CreateFontString(), "CreateFontString must return a value");
end;
