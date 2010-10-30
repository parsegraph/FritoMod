local Suite=CreateTestSuite("Strings-Transform");

function Suite:TestTransformAString()
    Assert.Equals("bcd", Strings.Transform({a="b", b="c", c="d"}, "abc"));
end;
