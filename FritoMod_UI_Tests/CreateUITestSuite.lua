if nil ~= require then
	require "WoW_UI/Frame";
	require "WoW_UI/UIParent";

	require "FritoMod_UI/Stage";
	require "FritoMod_Testing/Tests";
end;

function CreateUITestSuite(name)
	local suite=CreateTestSuite(name);
	local old;
	suite:AddListener({
		TestStarted=function()
			old=Stage.GetInstance().frame;
			Stage.GetInstance().frame=CreateFrame("Frame",nil,UIParent);
		end,
		TestFinished=function()
			Stage.GetInstance().frame:SetParent(nil);
			Stage.GetInstance().frame=old;
			old=nil;
		end,
	});
	return suite;
end
