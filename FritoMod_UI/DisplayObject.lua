if nil ~= require then
    require "wowbench/api";
    require "wowbench/widgets";

    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/StyleClient";
    require "FritoMod_UI/Invalidating";
end;

DisplayObject = OOP.Class(StyleClient, Invalidating);
local DisplayObject = DisplayObject;
DO = DisplayObject;

DisplayObject.defaults = {
	Width = 200,
	Height = 200,
	Alpha = 1.0,
	Visibility = true,
	Texture = false
};

function DisplayObject:Constructor()
	if not DisplayObject[self.class] then
		DisplayObject[self.class] = {};
	end;
	table.insert(DisplayObject[self.class], self);
	self:ConstructChildren();
end;

function DisplayObject:ConstructChildren()
	self.frame = CreateFrame("Frame");
end;

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

StyleClient.AddComputedValue(DisplayObject, "Height", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject, "Width", StyleClient.CHANGE_SIZE);
StyleClient.AddComputedValue(DisplayObject, "Alpha", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject, "Visibility", StyleClient.CHANGE_LAYOUT);
StyleClient.AddComputedValue(DisplayObject, "Texture", StyleClient.CHANGE_LAYOUT);

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

function DisplayObject:GetParentFrame()
	if self:GetParent() then
		return self:GetParent():GetFrame();
	end;
end;

function DisplayObject:GetFrame()
	return self.frame;
end;

function DisplayObject:Hide()
	self:SetExplicitVisibility(false);
end;

function DisplayObject:Show()
	self:SetExplicitVisibility(true);
end;

function DisplayObject:ComputeValue(valueName)
	if valueName == "Width" then
		return self.measuredWidth;
	end;
	if valueName == "Height" then
		return self.measuredHeight;
	end;
end;

function DisplayObject:FetchDefaultFromTable(valueName)
	return DisplayObject.defaults[valueName];
end;

function DisplayObject:GetMediaKeyName(valueName)
	return nil;
end;
