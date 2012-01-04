if nil ~= require then
	require "wow/Frame";

	require "fritomod/OOP-Class";
end;

local Texture = OOP.Class(WoW.Frame);

WoW.Texture = Texture;

function WoW.Frame:CreateTexture(...)
	return Texture:New(...);
end;

function Texture:SetTexture(...)

end;

function Texture:GetTexture(...)

end;
