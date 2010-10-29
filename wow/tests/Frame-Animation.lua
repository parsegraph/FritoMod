local Suite=CreateTestSuite("WoW_UI/Frame-Animation");

function Suite:TestAnimation()
	local f=CreateFrame("Frame");
	assert(f:CreateAnimationGroup(), "CreateAnimationGroup returns a value");
end;
