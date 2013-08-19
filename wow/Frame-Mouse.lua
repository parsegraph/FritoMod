if nil ~= require then
	require "wow/Frame";

	require "fritomod/basic";
	require "fritomod/Lists";
end;

local Frame = WoW.Frame;

Frame:AddConstructor(function(self)
    self.enabled = false;
end);

function Frame:EnableMouse(enabled)
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
