Stage = OOP.Class(DisplayObjectContainer);
local Stage = Stage;

function Stage:GetStage()
	if not Stage.stage then
		Stage.stage = Stage();
	end;
	return Stage.stage;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Stage:__Init()
	Stage.__super.__Init(self);
	if Stage.stage then
		error("Cannot have multiple instances of the Stage.");
	end;
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: DisplayObject
--
-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------
--
--  Overridden Methods: DisplayObjectContainer
--
-------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------
--
--  Nullified Methods: DisplayObject
--
-------------------------------------------------------------------------------

function Stage:SetParent(parent)
	error("The Stage cannot have a parent.");
end;
