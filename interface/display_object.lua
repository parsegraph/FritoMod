DisplayObject = FritoLib.OOP.Class(EventDispatcher, StyleClient, Invalidating);
local DisplayObject = DisplayObject;

DisplayObject.defaultValues = {
	Width = 200,
	Height = 200,
	Alpha = 1.0,
	Visibility = true,
	Texture = false
};

DisplayObject.mediaKeyNames = {};

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DisplayObject.prototype:init()
	DisplayObject.super.prototype.init(self);
	self:ConstructChildren();
end;

function DisplayObject:ToString()
	return "DisplayObject";
end;

-------------------------------------------------------------------------------
--
--  Overridable Methods: DisplayObject
--
-------------------------------------------------------------------------------

function DisplayObject.prototype:ConstructChildren()
	self.frame = CreateFrame("Frame");
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: Invalidating
--
-------------------------------------------------------------------------------

function DisplayObject.prototype:Measure()
	self.measuredHeight = 0;
	self.measuredWidth = 0;
end;

function DisplayObject.prototype:UpdateLayout()
	local frame = self.frame;

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

StyleClient.AddComputedValue(DisplayObject.prototype, "Height", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject.prototype, "Width", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject.prototype, "Alpha", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject.prototype, "Visibility", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject.prototype, "Texture", StyleClient.CHANGE_LAYOUT);

------------------------------------------
--  Parent
------------------------------------------

function DisplayObject.prototype:GetParent()
	return self.parent;
end;

function DisplayObject.prototype:SetParent(parent)
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

function DisplayObject.prototype:GetParentFrame()
	if self:GetParent() then
		return self:GetParent():GetFrame();
	end;
end;

------------------------------------------
--  Frame
------------------------------------------

function DisplayObject.prototype:GetFrame()
	return self.frame;
end;

-------------------------------------------------------------------------------
--
--  Layout Convenience Functions
--
-------------------------------------------------------------------------------

function DisplayObject.prototype:Hide()
	self:SetExplicitVisibility(false);
end;

function DisplayObject.prototype:Show()
	self:SetExplicitVisibility(true);
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: StyleClient
--
-------------------------------------------------------------------------------

function DisplayObject.prototype:ComputeValue(valueName)
	if valueName == "Width" then
		return self.measuredWidth;
	end;
	if valueName == "Height" then
		return self.measuredHeight;
	end;
end;

function DisplayObject.prototype:FetchDefaultFromTable(valueName)
	return DisplayObject.defaultValues[valueName];
end;

function DisplayObject.prototype:GetMediaKeyName(valueName)
	return DisplayObject.mediaKeyNames[valueName];
end;
