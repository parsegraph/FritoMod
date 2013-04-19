if nil ~= require then
	require "wow/Frame";

	require "fritomod/basic";
	require "fritomod/Lists";
	require "fritomod/OOP-Class";
end;

local Frame = WoW.Frame;

WoW.Delegate(Frame, "mouse", {
    "EnableMouse"
});

local Delegate = OOP.Class();

if not WoW.GetFrameDelegate("Frame", "mouse") then
	WoW.SetFrameDelegate("Frame", "mouse", Delegate, "New");
end;

function Delegate:Constructor(frame)
    self.frame = frame;
    self.enabled = false;
end;

function Delegate:EnableMouse(enabled)
    self.enabled = enabled;
end;

if IsMouseButtonDown == nil then
    function IsMouseButtonDown(button)
        return false;
    end;
end;

if GetCursorPosition == nil then
    function GetCursorPosition()
        return 0, 0;
    end;
end;
