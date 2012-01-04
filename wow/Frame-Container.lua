if nil ~= require then
	require "fritomod/OOP-Class";
	require "wow/Frame";
end;

local Frame = WoW.Frame;

Frame:AddConstructor(function(self, world, parent)
	self.children = {};
	self.parent = parent;
end);

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
end;

function Frame:GetParent()
	return self.parent;
end;
