if nil ~= require then
    require "MappedTestSuite";
end;

-- Tests is the global registry for all named test suites. 
AllTests = MappedTestSuite:New();
