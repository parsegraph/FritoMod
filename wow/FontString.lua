if nil ~= require then
	require "wow/Frame";

	require "fritomod/OOP-Class";
end;

local FontString=OOP.Class(WoW.Frame);
WoW.FontString = FontString;

function WoW.Frame:CreateFontString()
	return WoW.FontString:New(self);
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

function WoW.FontString:SetJustifyH()

end;

function WoW.FontString:SetJustifyV()

end;
