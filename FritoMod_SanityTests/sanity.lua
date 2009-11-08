-- Tests that assert some non-intuitive or plain ambiguous behavior. These tests only assert
-- lua-specific functionality, so test failures indicate an incompatible lua version.

if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_SanityTests.sanity");
