local Suite=CreateTestSuite("Strings-Transform");

function Suite:TestTransformAString()
    Assert.Equals("bcd", Strings.Transform("abc", {a="b", b="c", c="d"}));
end;
