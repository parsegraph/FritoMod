local Suite = CreateTestSuite("fritomod.Math");

function Suite:TestMean()
	Assert.Equals(3, Math.Mean({3,3,3}));
	Assert.Equals(3, Math.Mean(2,3,4));
end;

function Suite:TestClamp()
	Assert.Equals(3, Math.Clamp(0, 3, 5));
	Assert.Equals(5, Math.Clamp(0, 10, 5));
	Assert.Equals(0, Math.Clamp(0, -3, 5));

	Assert.Exception(Math.Clamp, nil, 3, 5);
	Assert.Exception(Math.Clamp, 0, nil, 5);
	Assert.Exception(Math.Clamp, 0, 3, nil);
end;

function Suite:TestModulo()
	Assert.Equals(3, Math.Modulo(0, 3, 5));
	Assert.Equals(0, Math.Modulo(0, 5, 5));
	Assert.Equals(1, Math.Modulo(0, 6, 5));
	Assert.Equals(4, Math.Modulo(0, -1, 5));

	Assert.Exception(Math.Modulo, nil, 3, 5);
	Assert.Exception(Math.Modulo, 0, nil, 5);
	Assert.Exception(Math.Modulo, 0, 3, nil);
end;

function Suite:TestPercent()
	Assert.Equals(.5, Math.Percent(0, 1, 2));
	Assert.Equals(.5, Math.Percent(0, Math.Interpolate(0, .5, 2), 2));
end;

function Suite:TestInterpolate()
	Assert.Equals(1, Math.Interpolate(0, .5, 2));
	Assert.Equals(1, Math.Interpolate(2, .5, 0));
end;

function Suite:TestDistance()
	-- I'm using a Pythagorean triple (3, 4, 5) here, for a readable
	-- distance value.
	Assert.Equals(5, Math.Distance(0, 0, 3, 4));
	Assert.Equals(0, Math.Distance(1, 1, 1, 1));
	Assert.Equals(5, Math.Distance({0, 0}, {3, 4}));
end;

function Suite:TestSignum()
	Assert.Equals(1, Math.Signum(5));
	Assert.Equals(-1, Math.Signum(-5));
	Assert.Equals(0, Math.Signum(0));
end;
