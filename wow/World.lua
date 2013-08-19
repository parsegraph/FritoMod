if nil ~= require then
	require "fritomod/OOP-Class"
	require "fritomod/Metatables";

	require "wow/Cursor";
end;

WoW=WoW or Metatables.Defensive();

WoW.World=OOP.Class("WoW.World");
local World=WoW.World;

function World:Constructor()
	self.cursor=WoW.Cursor:New(self);
end;

function World:GetCursor()
	return self.cursor;
end;
