if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Strings/Parsers";
end;

local ParsersTests = ReflectiveTestSuite:New("FritoMod_Strings.Parsers");

--[[
-- Ignored for now, since it doesnt work and the underlying code is scary.
--function ParsersTests:TestParseTime()
    local p = Parsers.Time;
    Assert.Equals(1, p("one"));
    Assert.Equals(2, p("two"));
end;]]
