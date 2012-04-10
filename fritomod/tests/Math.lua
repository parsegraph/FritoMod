local Suite = CreateTestSuite("fritomod.Math");

function Suite:TestMean()
	Assert.Equals(3, Math.Mean({3,3,3}));
	Assert.Equals(3, Math.Mean(2,3,4));
end;
