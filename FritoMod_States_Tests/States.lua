if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_States/States";
end;

local StatesTests = ReflectiveTestSuite:New("FritoMod_States.States");
