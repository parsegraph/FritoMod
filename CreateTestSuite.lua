-- Creates a test suite, including the proper require's and corrects the path
-- if necessary. This is purely for convenience when writing tests.

function CreateTestSuite(name, path)
	if path == nil then
		path = name:gsub("[.]", "/");
	end;
	if nil ~= require then
		require "ReflectiveTestSuite";
		require "Assert";
		require "Tests";

		if path ~= false then
			require(path);
		end;
	end;
	return ReflectiveTestSuite:New(name);
end;
