if nil ~= require then
    require "WoW_UI/UIParent";

    require "FritoMod_OOP/Mixins";
    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/DisplayObjectContainer";
end;

Stage = OOP.Class(DisplayObjectContainer, Mixins.Singleton);
local Stage = Stage;

function Stage:GetParentFrame()
	return UIParent;
end;

function Stage:ConstructChildren()
	Stage.super.ConstructChildren(self);
	self:GetFrame():SetPoint("CENTER", 0, 0);
end;

function Stage:ComputeValue(valueName)
	if valueName == "Width" then
		return self:GetParentFrame():GetWidth();
	end;
	if valueName == "Height" then
		return self:GetParentFrame():GetHeight();
	end;
end;

function Stage:DoAdd(child)
	Stage.super.DoAdd(self, child);
	local childFrame = child:GetFrame();
	if childFrame:GetNumPoints() == 0 then
		-- No points, so this child would be 'invisible.' To prevent this behavior,
		-- we add one arbitrarily. This only applies to DisplayObjects added to the
		-- stage.
		childFrame:SetPoint("CENTER", 0, 0);
	end;
end;

function Stage:DoRemove(child)
	Stage.super.DoRemove(self, child);
	child:GetFrame():ClearAllPoints();
end;

function Stage:SetParent(parent)
	error("The Stage cannot have a parent.");
end;
