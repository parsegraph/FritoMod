if nil ~= require then
	require "fritomod/OOP-Class";

	require "wow/Frame";
end;

WoW = WoW or {};

WoW.EditBox=OOP.Class("WoW.EditBox", WoW.Frame);
local EditBox = WoW.EditBox;

WoW.RegisterFrameType("EditBox", WoW.EditBox, "New");

function EditBox:SetFont()

end;
