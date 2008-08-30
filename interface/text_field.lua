TextField = FritoLib.OOP.Class(DisplayObject);
local TextField = TextField;

TextField.defaultValues = {
	FontSize = 11,
	FontColor = "Warlock"
};

TextField.mediaKeyNames = {
	FontColor = "Color",
	Font = "Font",
};

function TextField.CreateFontFrame()
	return Stage.GetStage():GetFrame():CreateFontString(nil, "OVERLAY");
end;

function TextField.GetScratchFont()
	if not TextField.scratchFrame then
		TextField.scratchFrame = TextField.CreateFontFrame();
	end;
	return TextField.scratchFrame;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function TextField.prototype:init(text)
	TextField.super.prototype.init(self);
	self:SetText(text);
end;

function TextField.prototype:ToString()
	return "TextField (text:'" .. self:GetText() .. "')";
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

StyleClient.AddComputedValue(TextField.prototype, "FontSize", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(TextField.prototype, "Font", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(TextField.prototype, "FontColor", StyleClient.CHANGE_LAYOUT);

------------------------------------------
--  Data
------------------------------------------

function TextField.prototype:GetData()
	return self:GetText()
end;

function TextField.prototype:SetData(data)
    return self:SetText(self.text)
end;

------------------------------------------
--  Text
------------------------------------------

function TextField.prototype:GetText()
	return self.text;
end;

function TextField.prototype:SetText(text)
    if self.text == text then
        return
    end;
	self.text = text;
	self:InvalidateSize();
	self:InvalidateLayout();
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: DisplayObject
--
-------------------------------------------------------------------------------

function TextField.prototype:ConstructChildren()
	self.frame = TextField.CreateFontFrame();
end;

function TextField.prototype:UpdateLayout()
	TextField.super.prototype.UpdateLayout(self)
	self:SetupFont();
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function TextField.prototype:ComputeValue(valueName)
	if valueName ~= "Height" and valueName ~= "Width" then
		return TextField.super.prototype.ComputeValue(self, valueName);
	end;
	local scratch = TextField.GetScratchFont();
	self:SetupFont(scratch);
	if self:GetExplicitHeight() then
		scratch:SetHeight(self:GetExplicitHeight());
	end;
	if self:GetExplicitWidth() then
		scratch:SetWidth(self:GetExplicitWidth());
	end;
	return scratch["GetString" .. valueName](scratch);
end;

function TextField.prototype:FetchDefaultFromTable(valueName)
	return TextField.defaultValues[valueName] or
		TextField.super.prototype.FetchDefaultFromTable(self, valueName);
end;

function TextField.prototype:GetMediaKeyName(valueName)
	return TextField.mediaKeyNames[valueName] or 
		TextField.super.prototype.GetMediaKeyName(self, valueName);
end;

-------------------------------------------------------------------------------
--
--  Layout Utility Methods
--
-------------------------------------------------------------------------------

function TextField.prototype:SetupFont(frame)
	frame = frame or self:GetFrame();
	frame:SetFontObject(GameFontNormal);
	frame:SetFont(self:GetFont(), self:GetFontSize());
	frame:SetTextColor(unpack(self:GetFontColor()));
	
	frame:SetText(self:GetText());
end;
