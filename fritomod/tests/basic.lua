local Suite = CreateTestSuite("fritomod.basic");

function Suite:TestUnpackAll()
    local a, b, c = UnpackAll({1,2,3});
    Assert.Equals(1, a, "A value");
    Assert.Equals(2, b, "B value");
    Assert.Equals(3, c, "C value");
end;

function Suite:TestUnpackAllRejectsNilValues()
    Assert.Exception("UnpackAll rejects nil values", UnpackAll, {1,nil,3});
end;
