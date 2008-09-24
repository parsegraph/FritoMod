DisplayObjectContainer = OOP.Class(DisplayObject);
local DisplayObjectContainer = DisplayObjectContainer;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function DisplayObjectContainer:__init()
    DisplayObjectContainer.__super.__init(self);
    self.children = List();
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

function DisplayObjectContainer:UpdateLayout()
    DisplayObjectContainer.super.UpdateLayout(self);
end;

-------------------------------------------------------------------------------
--
--  Overridden Methods: List 
--
-------------------------------------------------------------------------------

function DisplayObjectContainer:DoAdd(child)
    child:SetParent(self);
    child:GetFrame():SetParent(self:GetParentFrame());
end;

function DisplayObjectContainer:DoRemove(child)
    child:SetParent(nil);
    child:GetFrame():SetParent(nil);
end;

-------------------------------------------------------------------------------
--
--  Dummy Forwarders: List
--
-------------------------------------------------------------------------------

function DisplayObjectContainer:AddChild(child)
    local success = self.children:Add(child);
    if success then
        self:InvalidateSize()
    end;
    return success
end;

function DisplayObjectContainer:RemoveChild(child)
    success = self.children:Remove(child);
    if success then 
        self:InvalidateSize()
    end;
end;

function DisplayObjectContainer:GetChildIndex(child)
    return self.children:GetIndex(child);
end;

function DisplayObjectContainer:Contains(child)
    return self.children:Contains(child);
end;

function DisplayObjectContainer:Iter()
    return self.children:Iter();
end;

function DisplayObjectContainer:GetChildren()
    return self.children;
end;

function DisplayObjectContainer:GetNumChildren()
    return self:GetChildren():GetLength();
end;
