function CreateTestSuite(name, path)
	if path == nil then
		path = name:gsub("[.]", "/");
	end;
	if nil ~= require then
		require "FritoMod_Testing/ReflectiveTestSuite";
		require "FritoMod_Testing/Assert";
		require "FritoMod_Testing/Tests";

		if path ~= false then
			require(path);
		end;
	end;
	return ReflectiveTestSuite:New(name);
end;
