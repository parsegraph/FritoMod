-- Creates a test suite, including the proper require's and corrects the path
-- if necessary. This is purely for convenience when writing tests.

function CreateTestSuite(name, path)
	if path == nil then
		path = name:gsub("[.]", "/");
	end;
	if nil ~= require then
		require "fritomod/ReflectiveTestSuite";
		require "fritomod/Assert";
		require "fritomod/Tests";

		if path ~= false then
			require(path);
		end;
	end;
	return ReflectiveTestSuite:New(name);
end;
UnitTest=CreateTestSuite;

function IntegrationTest(name)
	if nil ~= require then
		require "fritomod/ReflectiveTestSuite";
		require "fritomod/Assert";
		require "fritomod/Tests";
	end;
	return ReflectiveTestSuite:New("Integration."..name);
end;
