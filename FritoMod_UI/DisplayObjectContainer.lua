if nil ~= require then
    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/DisplayObject";
end;

DisplayObjectContainer = OOP.Class(DisplayObject);
local DisplayObjectContainer = DisplayObjectContainer;

function DisplayObjectContainer:Constructor()
    DisplayObjectContainer.super.Constructor(self);
    self.children = {};
end;

function DisplayObjectContainer:ToString()
    return "DisplayObjectContainer";
end;

function DisplayObjectContainer:UpdateLayout()
    DisplayObjectContainer.super.UpdateLayout(self);
end;

function DisplayObjectContainer:DoAdd(child)
    child:SetParent(self);
    child:GetFrame():SetParent(self:GetFrame());
end;

function DisplayObjectContainer:DoRemove(child)
    child:SetParent(nil);
    child:GetFrame():SetParent(nil);
end;

function DisplayObjectContainer:AddChild(child)
	if Lists.Contains(self.children, child) then
		return;
	end;
	local remover = Lists.Insert(self.children, child);
	self:DoAdd(child);
	self:InvalidateSize()
	return Functions.OnlyOnce(function()
		self:DoRemove(child);
		remover();
        self:InvalidateSize()
	end);
end;

function DisplayObjectContainer:GetChildIndex(child)
    return Lists.KeyFor(child);
end;

function DisplayObjectContainer:Contains(child)
    return Lists.Contains(child);
end;

function DisplayObjectContainer:Iter()
    return Lists.ValueIterator(self.children);
end;

function DisplayObjectContainer:GetChildren()
    return self.children;
end;

function DisplayObjectContainer:GetNumChildren()
    return #self.children;
end;
