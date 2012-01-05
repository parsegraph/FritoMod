if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/Frames";
	require "fritomod/Serializers-Point";
end;

PersistentAnchor=OOP.Class();

function PersistentAnchor:Constructor(parentFrame)
	local f=CreateFrame("Frame", nil, parentFrame)
	f:Hide();
	self.frame=f;
	Frames.Square(f, 10);
	local bg=Frames.Color(f, "black");
	bg:SetDrawLayer("BACKGROUND");

	local white=f:CreateTexture(nil, "BORDER");
	Frames.Color(white, "white");
	white:SetPoint("center");
	Frames.Square(white, 8);
end;

function PersistentAnchor:Show()
	if self.frame:GetNumPoints()==0 then
		self.frame:SetPoint("center");
	end;
	self.frame:Show();
	if self.draggable then
		self.draggable();
	end;
	self.draggable=Frames.Draggable(self.frame);
	return Functions.OnlyOnce(self, "Hide");
end;

function PersistentAnchor:Hide()
	self.frame:Hide();
	self.draggable();
	self.draggable=nil;
end;

function PersistentAnchor:Load(location)
	self.frame:ClearAllPoints();
	Serializers.LoadPoint(location, self.frame);
end;

function PersistentAnchor:Save()
	return Serializers.SavePoint(self.frame, 1);
end;

function PersistentAnchor:Reset()
	self.frame:ClearAllPoints();
	self.frame:SetPoint("center");
	self:Save();
end;
