if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Functions";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Functions");
