if nil ~= require then
	require "wow/api/Frame";
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Anchors";
	require "fritomod/Lists";
	require "fritomod/Tables";
end;

UI = UI or {};

WrappingPlates = OOP.Class();
UI.WrappingPlates = WrappingPlates;

function WrappingPlates:Constructor()
	self.frame = CreateFrame("Frame");
	Frames.Size(self.frame, 10);
	self.children = {};
	self.currentFrame = 0;
end;

function WrappingPlates:Get(index)
	assert(#self.children > 0, "No children present!");
	return self.children[self:Index(index)];
end;

function WrappingPlates:Current()
	return self:Get(self.currentFrame);
end;

function WrappingPlates:Next()
	return self:Get(self.currentFrame + 1)
end;

function WrappingPlates:Previous()
	return self:Get(self.currentFrame - 1)
end;

function WrappingPlates:Index(index)
	index = index or self.currentFrame;
	return (index % #self.children) + 1;
end;

function WrappingPlates:Add(child)
	table.insert(self.children, child);
	local f = Frames.GetFrame(child);
	--f:Hide();
	f:SetParent(self.frame);
end;


function WrappingPlates:Set(...)
	self.currentFrame = 1 + self.currentFrame;
	local child = self:Get();
	assert(child, "Child is not present!");
	if self.anchor then
		if not Frames.IsVisible(child) then
			Frames.Show(child);
		else
			-- We wrapped so rearrange
			Anchors.Clear(self:Next(), self:Current());
			Anchors.Share(self:Next(), self, self.anchor);
			Anchors.VFlip(self:Current(), self:Previous(), self.anchor, 12);
		end;
	else
		trace("No anchor, just setting for now");
	end;
	
	child:Set(...);
end;

function WrappingPlates:Anchor(anchor)
	trace("Anchoring WrappingPlates to: "..anchor);
	self.anchor = anchor;
	Anchors.Clear(self.children);
	local orderedChildren = Tables.Clone(self.children);
	Lists.Rotate(orderedChildren, self:Index());
	local anchored = Anchors.VJustifyFrom(anchor, 10, orderedChildren);
	Anchors.Share(anchored, anchor, self);
end;

function WrappingPlates:Destroy()
	Lists.Each(self.children, Frames.Destroy);
end;
