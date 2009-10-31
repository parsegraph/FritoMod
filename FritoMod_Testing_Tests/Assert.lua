local Suite = ReflectiveTestSuite:New("FritoMod_Testing.Assert");

function Suite:TestEquals()
    Assert.Equals("Foo", "Foo", "Foo is foo");
    Assert.Equals("", "", "Empty string is empty string");
    Assert.Equals({}, {}, "Empty table is empty table");
    assert(not pcall(Assert.Equals, nil, "Foo"), "nil is not Foo");
    assert(not pcall(Assert.Equals, "", {}), "Empty string is not empty list");
    assert(not pcall(Assert.Equals, Noop, nil), "Noop function is not nil");
end;
