-- AllTests is the global registry for all named test suites. This
-- lets us run every test suite that we have:
--
-- AllTests:Run(); -- run all tests
--
-- Most of the magic is in MappedTestSuite, so look there for how
-- this works.

if nil ~= require then
    require "fritomod/MappedTestSuite";
end;

-- Be pessimistic when it comes to creating AllTests, since tests
-- often create their own environments, and we don't want to overwrite
-- their copy of AllTests.
AllTests = AllTests or MappedTestSuite:New();
