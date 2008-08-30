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

function DisplayObjectContainer.prototype:UpdateLayout()
    DisplayObjectContainer.super.prototype.UpdateLayout(self);
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
    local success = self.children:Add(child);
    if success then
        self:InvalidateSize()
    end;
    return success
end;

function DisplayObjectContainer.prototype:RemoveChild(child)
    success = self.children:Remove(child);
    if success then 
        self:InvalidateSize()
    end;
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
