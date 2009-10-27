local Suite = ReflectiveTestSuite:New("FritoMod_Functional.methods");

function Suite:TestUnpackAll()
    local a, b, c = UnpackAll({1,2,3});
    Assert.Equals(1, a, "A value");
    Assert.Equals(2, b, "B value");
    Assert.Equals(3, c, "C value");
end;

function Suite:TestUnpackAllWithNilValues()
    local a, b, c = UnpackAll({1,nil,3});
    Assert.Equals(1, a, "A value");
    Assert.Equals(nil, b, "B value");
    Assert.Equals(3, c, "C value");
end;
