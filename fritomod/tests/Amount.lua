local Suite = CreateTestSuite("fritomod.Amount");

function Suite:TestAmount()
	local a = Mechanics.Amount:New();
	a:SetAll(1, 5, 10);
	Assert.Equals(5, a:Get(), "Amount takes a value");
end;

function Suite:TestAmountRespectsBounds()
	local a = Mechanics.Amount:New();
	a:SetAll(1, 5, 10);
	a:SetBounds(1, 3);
	a:SetBoundsPolicy("clamp");
	Assert.Equals(3, a:Get(), "Amount is clamped");
end;

