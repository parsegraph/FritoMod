Stage = AceLibrary("AceOO-2.0").Class(DisplayObjectContainer);
local Stage = Stage;

function Stage:GetStage()
	if not Stage.stage then
		Stage.stage = Stage:new();
	end;
	_stage = Stage.stage;
	return Stage.stage;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Stage.prototype:init()
	Stage.super.prototype.init(self);
	if Stage.stage then
		error("Cannot have multiple instances of the Stage.");
	end;
end;

function Stage:ToString()
	return "Stage";
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: DisplayObject
--
-------------------------------------------------------------------------------

function Stage.prototype:GetParentFrame()
	return UIParent;
end;

function Stage.prototype:ConstructChildren()
	Stage.super.prototype.ConstructChildren(self);
	self:GetFrame():SetPoint("CENTER", 0, 0);
end;

function Stage.prototype:ComputeValue(valueName)
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

function Stage.prototype:DoAdd(child)
	Stage.super.prototype.DoAdd(self, child);
	local childFrame = child:GetFrame();
	if childFrame:GetNumPoints() == 0 then
		-- No points, so this child would be 'invisible.' To prevent this behavior,
		-- we add one arbitrarily. This only applies to DisplayObjects added to the
		-- stage.
		childFrame:SetPoint("CENTER", 0, 0);
	end;
end;

function Stage.prototype:DoRemove(child)
	Stage.super.prototype.DoRemove(self, child);
	child:GetFrame():ClearAllPoints();
end;

-------------------------------------------------------------------------------
--
--  Nullified Methods: DisplayObject
--
-------------------------------------------------------------------------------

function Stage.prototype:SetParent(parent)
	error("The Stage cannot have a parent.");
end;
