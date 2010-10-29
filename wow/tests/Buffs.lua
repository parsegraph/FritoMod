local Suite=CreateTestSuite("WoW_Spells/Buffs");

function Suite:TestBuff()
	Assert.Succeed(UnitBuff, "Unit buff must succeed");
end;
