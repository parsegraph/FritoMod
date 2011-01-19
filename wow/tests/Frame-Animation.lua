local Suite=CreateTestSuite("wow/Frame-Animation");

function Suite:TestAnimation()
	local f=WoW.Frame:New("Frame");
	assert(f:CreateAnimationGroup(), "CreateAnimationGroup returns a value");
end;
