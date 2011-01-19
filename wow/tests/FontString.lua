local Suite=CreateTestSuite("wow/FontString");

function Suite:TestCreateFontString()
	local f=WoW.Frame:New("Frame");
	assert(f:CreateFontString(), "CreateFontString must return a value");
end;
