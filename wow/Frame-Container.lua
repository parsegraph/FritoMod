if nil ~= require then
	require "fritomod/OOP-Class";
	require "wow/Frame";
end;

local Frame = WoW.Frame;

Frame:AddConstructor(function(self)
	self.children = {};
    self:AddDestructor(function()
        self:SetParent(nil);
    end);
end);

function Frame:Constructor(parent)
    self:SetParent(parent);
end;

function Frame:GetNumChildren(...)
end;

function Frame:GetChildren(...)
end;

function Frame:GetNumRegions(...)
end;
function Frame:GetRegions(...)
end;

function Frame:SetParent(parent)
	self.parent = parent;
    if self._parentDestructor then
        self._parentDestructor();
        self._parentDestructor = nil;
    end;
    if self.parent then
        self._parentDestructor = self.parent:AddDestructor(self, "Destroy");
    end;
    self:FireEvent("PARENT", parent);
end;

function Frame:GetParent()
	return self.parent;
end;
