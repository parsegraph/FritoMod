-- AllTests is the global registry for all named test suites. This
-- lets us run every test suite that we have:
--
-- AllTests:Run(); -- run all tests
--
-- Most of the magic is in MappedTestSuite, so look there for how
-- this works.

if nil ~= require then
    require "MappedTestSuite";
end;

AllTests = MappedTestSuite:New();
