if nil ~= require then
	require "wow/Frame";

	require "OOP-Class";
end;

WoW.FontString=OOP.Class(WoW.Frame);

function WoW.Frame:CreateFontString()
	return WoW.FontString:New();
end;

function WoW.FontString:SetFontObject()
end;

function WoW.FontString:SetFont()
end;

function WoW.FontString:SetTextColor()
end;

function WoW.FontString:SetText()
end;

function WoW.FontString:GetStringWidth()
	return 0
end;

function WoW.FontString:GetStringHeight()
	return 0;
end;
