local MathTests = ReflectiveTestSuite:New("FritoMod_Functional.Math");

function MathTests:TestParseTime()
    local p = Math.Parse;
    Assert.Equals(1, p("one"));
    Assert.Equals(2, p("two"));
end;
