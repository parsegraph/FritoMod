if nil ~= require then
    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/DisplayObject";
end;

DisplayObjectContainer = OOP.Class(DisplayObject);
local DisplayObjectContainer = DisplayObjectContainer;

function DisplayObjectContainer:Constructor()
    DisplayObjectContainer.super.Constructor(self);
    self.children = {};
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

function DisplayObjectContainer:UpdateLayout()
    DisplayObjectContainer.super.UpdateLayout(self);
end;

function DisplayObjectContainer:DoAdd(child)
    child:SetParent(self);
    child:GetFrame():SetParent(self:GetParentFrame());
end;

function DisplayObjectContainer:DoRemove(child)
    child:SetParent(nil);
    child:GetFrame():SetParent(nil);
end;

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
