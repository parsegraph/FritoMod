local ParsersTests = ReflectiveTestSuite:New("FritoMod_Strings.Parsers");

function ParsersTests:TestParseTime()
    local p = Parsers.Time;
    Assert.Equals(1, p("one"));
    Assert.Equals(2, p("two"));
end;
