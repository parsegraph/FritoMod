if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Math/Math";
end;

local MathTests = ReflectiveTestSuite:New("FritoMod_Math.Math");
