local Suite=CreateTestSuite("wow/Buffs");

function Suite:TestBuff()
	Assert.Succeed(UnitBuff, "Unit buff must succeed");
end;
