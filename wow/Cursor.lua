if nil ~= require then
	require "fritomod/Functions";
	require "fritomod/OOP-Class"
end;

WoW=WoW or {};

WoW.Cursor=OOP.Class("WoW.Cursor");
local Cursor=WoW.Cursor;

function Cursor:Constructor()
end;

function Cursor:Enter(frame)
	if self.hoveredFrame == frame then
		return Noop;
	end;
	if self.hoveredFrame then
		self:Leave();
	end;
	self.hoveredFrame=frame;
	self.hoveredFrame:FireEvent("OnEnter");
	return Functions.OnlyOnce(self, "Leave", frame);
end;

function Cursor:Down(frame)
	self:Enter(frame);
	self.hoveredFrame:FireEvent("OnMouseDown");
	return Functions.OnlyOnce(
		self.hoveredFrame, "FireEvent", "OnMouseUp");
end;

function Cursor:Click(frame)
	self:Enter(frame);
	self.hoveredFrame:FireEvent("OnClick");
end;

function Cursor:Leave()
	if not self.hoveredFrame then
		return;
	end;
	local oldFrame=self.hoveredFrame;
	self.hoveredFrame=nil;
	oldFrame:FireEvent("OnLeave");
end;
