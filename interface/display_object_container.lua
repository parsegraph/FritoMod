DisplayObjectContainer = FritoLib.OOP.Class(DisplayObject);
local DisplayObjectContainer = DisplayObjectContainer;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DisplayObjectContainer.prototype:init()
	DisplayObjectContainer.super.prototype.init(self);
	self.children = List:new();
	local this = self;
	self.children.DoAdd = function(list, child)
		this:DoAdd(child);
	end;
	self.children.DoRemove = function(list, child)
		this:DoRemove(child);
	end;
end;

function DisplayObjectContainer:ToString()
	return "DisplayObjectContainer";
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: DisplayObject
--
-------------------------------------------------------------------------------

function DisplayObjectContainer.prototype:UpdateLayout(width, height)
	DisplayObjectContainer.super.prototype.UpdateLayout(self, width, height);
	for child in self:Iter() do
		child:UpdateLayout(min(child:GetWidth(), width), min(child:GetHeight(), height));
	end;
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: List 
--
-------------------------------------------------------------------------------

function DisplayObjectContainer.prototype:DoAdd(child)
	child:SetParent(self);
	child:GetFrame():SetParent(self:GetParentFrame());
end;

function DisplayObjectContainer.prototype:DoRemove(child)
	child:SetParent(nil);
	child:GetFrame():SetParent(nil);
end;

-------------------------------------------------------------------------------
--
--  Dummy Forwarders: List
--
-------------------------------------------------------------------------------

function DisplayObjectContainer.prototype:AddChild(child)
	return self.children:Add(child);
end;

function DisplayObjectContainer.prototype:RemoveChild(child)
	return self.children:Remove(child);
end;

function DisplayObjectContainer.prototype:GetChildIndex(child)
	return self.children:GetIndex(child);
end;

function DisplayObjectContainer.prototype:Contains(child)
	return self.children:Contains(child);
end;

function DisplayObjectContainer.prototype:Iter()
	return self.children:Iter();
end;

function DisplayObjectContainer.prototype:GetChildren()
	return self.children;
end;

function DisplayObjectContainer.prototype:GetNumChildren()
	return self:GetChildren():GetLength();
end;
