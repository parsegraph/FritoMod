local Suite=CreateTestSuite("wow/FontString");

function Suite:TestCreateFontString()
	local f=CreateFrame("Frame");
	assert(f:CreateFontString(), "CreateFontString must return a value");
end;
