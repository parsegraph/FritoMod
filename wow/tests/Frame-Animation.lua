local Suite=CreateTestSuite("wow/Frame-Animation");

function Suite:TestAnimation()
	local f=CreateFrame("Frame");
	assert(f:CreateAnimationGroup(), "CreateAnimationGroup returns a value");
end;
