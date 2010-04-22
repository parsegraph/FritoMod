if nil ~= require then
    -- This file uses WoW-specific functionality

    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/DisplayObject";
    require "FritoMod_UI/StyleClient";
    require "FritoMod_UI/Stage";
end;

TextField = OOP.Class(DisplayObject);
local TextField = TextField;

TextField.defaultValues = {
	FontSize = 30,
	FontColor = "Hunter"
};

TextField.mediaKeyNames = {
	FontColor = "Color",
	Font = "Font",
};

function TextField.CreateFontFrame()
	return UIParent:CreateFontString(nil, "OVERLAY");
end;

function TextField.GetScratchFont()
	if not TextField.scratchFrame then
		TextField.scratchFrame = TextField.CreateFontFrame();
	end;
	return TextField.scratchFrame;
end;

function TextField:Constructor(text)
	TextField.super.Constructor(self);
	self:SetText(text);
end;

function TextField:ToString()
	return "TextField (text:'" .. self:GetText() .. "')";
end;

StyleClient.AddComputedValue(TextField, "FontSize", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(TextField, "Font", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(TextField, "FontColor", StyleClient.CHANGE_LAYOUT);

function TextField:GetData()
	return self:GetText()
end;

function TextField:SetData(data)
    return self:SetText(self.text)
end;

function TextField:GetText()
	return self.text;
end;

function TextField:SetText(text)
    if self.text == text then
        return
    end;
	self.text = text;
	self:InvalidateSize();
	self:InvalidateLayout();
end;

function TextField:ConstructChildren()
	self.frame = TextField.CreateFontFrame();
end;

function TextField:Measure()
	TextField.super.Measure(self)
	local scratch = TextField.GetScratchFont();
	self:SetupFont(scratch);
	if self:GetExplicitHeight() then
		scratch:SetHeight(self:GetExplicitHeight());
	end;
	if self:GetExplicitWidth() then
		scratch:SetWidth(self:GetExplicitWidth());
	end;
    self.measuredHeight = scratch:GetStringHeight()
    self.measuredWidth = scratch:GetStringWidth() +1 
end;

function TextField:UpdateLayout()
	TextField.super.UpdateLayout(self)
	self:SetupFont();
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function TextField:FetchDefaultFromTable(valueName)
	return TextField.defaultValues[valueName] or
		TextField.super.FetchDefaultFromTable(self, valueName);
end;

function TextField:GetMediaKeyName(valueName)
	return TextField.mediaKeyNames[valueName] or 
		TextField.super.GetMediaKeyName(self, valueName);
end;

-------------------------------------------------------------------------------
--
--  Layout Utility Methods
--
-------------------------------------------------------------------------------

function TextField:SetupFont(frame)
	frame = frame or self:GetFrame();
	frame:SetFontObject(GameFontNormal);
	frame:SetFont(self:GetFont(), self:GetFontSize());
	local a,r,g,b = unpack(self:GetFontColor());
	frame:SetTextColor(r,g,b);
	frame:SetText(self:GetText());
end;
