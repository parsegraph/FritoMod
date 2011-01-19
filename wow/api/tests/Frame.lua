local Suite=CreateTestSuite("wow/api/Frame");

function Suite:TestCreateFrame()
	assert(CreateFrame("Frame"), "CreateFrame must return a value for valid frame types");
	Assert.Exception("CreateFrame must throw on zero-args", CreateFrame);
	Assert.Exception("CreateFrame must throw on unknown type", CreateFrame, "unknown");
	Assert.Succeeds("CreateFrame's type is case-insensitive", CreateFrame, "FrAMe");
end;
