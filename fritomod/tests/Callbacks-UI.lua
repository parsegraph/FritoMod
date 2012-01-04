if nil ~= require then
	require "wow/Frame-Events";
	require "fritomod/Frames";
end;
local Suite=CreateTestSuite("fritomod.Callbacks-UI");

function Suite:ShouldIgnore()
	return not WoW;
end;

function Suite:TestEnterFrame()
	if self:ShouldIgnore() then
		return;
	end;
	local frame=WoW.Frame:New();
	local cursor = WoW.Cursor:New();
	local flag=Tests.Flag();
	Callbacks.EnterFrame(frame, flag.Raise);
	local r=cursor:Enter(frame);
	flag.Assert();
	r();
	flag.AssertUnset();
end;

function Suite:TestShow()
	if self:ShouldIgnore() then
		return;
	end;
	local frame=WoW.Frame:New();
	local flag=Tests.Flag();
	Callbacks.ShowFrame(frame, flag.Raise);
	frame:Hide();
	frame:Show();
	flag.Assert();
	frame:Hide();
	flag.AssertUnset();
end;

function Suite:TestMouseDown()
	if self:ShouldIgnore() then
		return;
	end;
	local frame=WoW.Frame:New();
	local cursor = WoW.Cursor:New();
	local flag=Tests.Flag();
	Callbacks.MouseDown(frame, flag.Raise);
	local r=cursor:Down(frame);
	flag.Assert();
	r();
	flag.AssertUnset();
end;

function Suite:TestMouseDown()
	if self:ShouldIgnore() then
		return;
	end;
	local frame=WoW.Frame:New();
	local cursor = WoW.Cursor:New();
	local flag=Tests.Flag();
	Callbacks.MouseUp(frame, flag.Raise);
	local r=cursor:Down(frame);
	r();
	flag.Assert();
end;
