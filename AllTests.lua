if nil ~= require then
    require "FritoMod_Testing/MappedTestSuite";
end;

-- Tests is the global registry for all named test suites. 
AllTests = MappedTestSuite:New();
