if nil ~= require then
    require "wow/Frame-Events";
    require "Frames";
end;
local Suite=CreateTestSuite("Callbacks-UI");

function Suite:TestEnterFrame()
    local world=WoW.World:New();
    local frame=WoW.Frame:New(world);
    local flag=Tests.Flag();
    Callbacks.EnterFrame(frame, flag.Raise);
    local r=world:GetCursor():Enter(frame);
    flag.Assert();
    r();
    flag.AssertUnset();
end;

function Suite:TestShow()
    local world=WoW.World:New();
    local frame=WoW.Frame:New(world);
    local flag=Tests.Flag();
    Callbacks.ShowFrame(frame, flag.Raise);
    frame:Hide();
    frame:Show();
    flag.Assert();
    frame:Hide();
    flag.AssertUnset();
end;

function Suite:TestMouseDown()
    local world=WoW.World:New();
    local frame=WoW.Frame:New(world);
    local flag=Tests.Flag();
    Callbacks.MouseDown(frame, flag.Raise);
    local r=world:GetCursor():Down(frame);
    flag.Assert();
    r();
    flag.AssertUnset();
end;

function Suite:TestMouseDown()
    local world=WoW.World:New();
    local frame=WoW.Frame:New(world);
    local flag=Tests.Flag();
    Callbacks.MouseUp(frame, flag.Raise);
    local r=world:GetCursor():Down(frame);
    r();
    flag.Assert();
end;
