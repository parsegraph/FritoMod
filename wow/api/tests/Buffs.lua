local Suite=CreateTestSuite("wow.api.Buffs");

function Suite:TestBuff()
	Assert.Succeed(UnitBuff, "Unit buff must succeed");
end;
