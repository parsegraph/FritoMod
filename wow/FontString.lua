if nil ~= require then
	require "wow/Frame";

	require "fritomod/OOP-Class";
end;

local FontString=OOP.Class(WoW.Frame);
WoW.FontString = FontString;

WoW.RegisterFrameType("FontString", FontString);

local Frame = WoW.Frame;

function Frame:CreateFontString()
	return FontString:New(self);
end;

function FontString:SetFontObject()
    trace("STUB FontString:SetFontObject");
end;

function FontString:SetJustifyH()

end;

function FontString:SetJustifyV()

end;

WoW.Delegate(FontString, "text", {
	"GetText",
	"SetText",

    "GetFont",
    "SetFont",

    "GetTextColor",
    "SetTextColor",

    "GetStringHeight",
    "GetStringWidth",
    "GetWrappedWidth"
});

local TestingTextDelegate = OOP.Class();

if not WoW.GetFrameDelegate("FontString", "text") then
    WoW.SetFrameDelegate("FontString", "text", TestingTextDelegate, "New");
end;

function TestingTextDelegate:Constructor(frame)
    self.frame = frame;
    self.text = "";
    self.color = {1, 1, 1, 1};
    self.font = {};
end;

function TestingTextDelegate:GetText()
    return self.text;
end;

function TestingTextDelegate:SetText(text)
    self.text = tostring(text);
end;

function TestingTextDelegate:GetFont()
    return unpack(self.font);
end;

function TestingTextDelegate:SetFont(font, size, ...)
    self.font = {font, size};
end;

function TestingTextDelegate:GetTextColor()
    return unpack(self.color);
end;

function TestingTextDelegate:SetTextColor(r, g, b, a)
    self.color = {r, g, b, a};
end;

function TestingTextDelegate:GetStringWidth()
    return 0;
end;

function TestingTextDelegate:GetStringHeight()
    return 0;
end;

function TestingTextDelegate:GetWrappedWidth()
    return 0;
end;
