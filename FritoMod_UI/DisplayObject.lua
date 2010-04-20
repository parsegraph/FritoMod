if nil ~= require then
    -- This file uses WoW-specific functionality

    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/StyleClient";
    require "FritoMod_UI/Invalidating";
end;

DisplayObject = OOP.Class(StyleClient, Invalidating);
local DisplayObject = DisplayObject;

DisplayObject.defaultValues = {
	Width = 200,
	Height = 200,
	Alpha = 1.0,
	Visibility = true,
	Texture = false
};

DisplayObject.mediaKeyNames = {};

function DisplayObject:Constructor()
	self:ConstructChildren();
end;

-------------------------------------------------------------------------------
--
--  Overridable Methods: DisplayObject
--
-------------------------------------------------------------------------------

function DisplayObject:ConstructChildren()
	self.frame = CreateFrame("Frame");
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: Invalidating
--
-------------------------------------------------------------------------------

function DisplayObject:Measure()
	self.measuredHeight = 0;
	self.measuredWidth = 0;
end;

function DisplayObject:UpdateLayout()
	local frame = self.frame;

	assert(self:GetParentFrame() ~= nil, "Parent frame must not be nil");
	frame:SetParent(self:GetParentFrame());

    frame:SetHeight(self:GetHeight());
    frame:SetWidth(self:GetWidth());
	if self:GetAlpha() == nil or type(self:GetAlpha()) ~= "number" then
		error("DisplayObject: Alpha is not a number: " .. tostring(self));
	end;
	frame:SetAlpha(self:GetAlpha());

	if self:GetVisibility() == true then
		frame:Show();
	else
		frame:Hide();
	end;

	local texture = self:GetTexture();
	if texture then
		texture:ApplyTo(self);
	end;
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

StyleClient.AddComputedValue(DisplayObject, "Height", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject, "Width", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject, "Alpha", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject, "Visibility", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject, "Texture", StyleClient.CHANGE_LAYOUT);

------------------------------------------
--  Parent
------------------------------------------

function DisplayObject:GetParent()
	return self.parent;
end;

function DisplayObject:SetParent(parent)
	if parent == self.parent then
		return;
	end;
	local oldParent = self.parent;
	if oldParent then
		self.parent = nil;
		oldParent:RemoveChild(self);
	end;
	self.parent = parent;
	if self.parent then
		self.parent:AddChild(self);
	end;
	self:InvalidateSize();
end;

------------------------------------------
--  Parent Frame
------------------------------------------

function DisplayObject:GetParentFrame()
	if self:GetParent() then
		return self:GetParent():GetFrame();
	end;
end;

------------------------------------------
--  Frame
------------------------------------------

function DisplayObject:GetFrame()
	return self.frame;
end;

-------------------------------------------------------------------------------
--
--  Layout Convenience Functions
--
-------------------------------------------------------------------------------

function DisplayObject:Hide()
	self:SetExplicitVisibility(false);
end;

function DisplayObject:Show()
	self:SetExplicitVisibility(true);
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function DisplayObject:ComputeValue(valueName)
	if valueName == "Width" then
		return self.measuredWidth;
	end;
	if valueName == "Height" then
		return self.measuredHeight;
	end;
end;

function DisplayObject:FetchDefaultFromTable(valueName)
	return DisplayObject.defaultValues[valueName];
end;

function DisplayObject:GetMediaKeyName(valueName)
	return DisplayObject.mediaKeyNames[valueName];
end;
