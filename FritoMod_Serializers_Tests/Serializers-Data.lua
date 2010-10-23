local Suite=CreateTestSuite("FritoMod_Serializers/Serializers-Data");

local function Check(...)
    Assert.Equals({...}, {Serializers.ReadData(Serializers.WriteData(...))});
end

function Suite:TestSerializeABoolean()
    Check(true, false);
end;
