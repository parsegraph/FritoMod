if nil ~= require then
	require "fritomod/OOP-Class";

	require "wow/Frame";
end;

WoW.Button=OOP.Class(WoW.Frame);

WoW:RegisterFrameType("Button", WoW.Button, "New");

function WoW.Button:SetHighlightTexture()
end;

function WoW.Button:SetPushedTexture()
end;
