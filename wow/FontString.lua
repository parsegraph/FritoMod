if nil ~= require then
	require "wow/Frame";

	require "fritomod/OOP-Class";
end;

local FontString=OOP.Class("WoW.FontString", WoW.Frame);
WoW.FontString = FontString;

if not WoW.GetFrameType("FontString") then
    WoW.RegisterFrameType("FontString", WoW.FontString);
end;

function WoW.Frame:CreateFontString()
	return FontString:New(self);
end;

function FontString:Constructor()
    FontString.super.Constructor(self);
    self.text = "";
    self.color = {1, 1, 1, 1};
    self.font = {};
end;

function FontString:SetFontObject()
    trace("STUB FontString:SetFontObject");
end;

function FontString:SetJustifyH()

end;

function FontString:SetJustifyV()

end;

function FontString:GetText()
    return self.text;
end;

function FontString:SetText(text)
    self.text = tostring(text);
end;

function FontString:GetFont()
    return unpack(self.font);
end;

function FontString:SetFont(font, size, ...)
    self.font = {font, size};
end;

function FontString:GetTextColor()
    return unpack(self.color);
end;

function FontString:SetTextColor(r, g, b, a)
    self.color = {r, g, b, a};
end;

function FontString:GetStringWidth()
    return 0;
end;

function FontString:GetStringHeight()
    return 0;
end;

function FontString:GetWrappedWidth()
    return 0;
end;
