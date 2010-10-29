if nil ~= require then
	require "FritoMod_OOP/OOP-Class";

	require "WoW_UI/Frame";
end;

WoW.Button=OOP.Class(WoW.Frame);
WoW.FrameTypes.button=WoW.Button;

function WoW.Button:SetHighlightTexture()
end;

function WoW.Button:SetPushedTexture()
end;
