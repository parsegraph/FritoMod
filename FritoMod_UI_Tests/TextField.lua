if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_UI/TextField";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_UI.TextField");

Suite:AddListener(Metatables.Noop({
	TestFinished = function(self, suite)
	end
}));

function Suite:TestTextField()
	local s = Stage:GetInstance();
	local tf = TextField:New("Base");
	s:AddChild(tf);
	s:ValidateNow();
end;
