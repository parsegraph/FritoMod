if nil ~= require then
    require "OOP-Class"
    require "Metatables";

    require "wow/Cursor";
end;

WoW=WoW or Metatables.Defensive();

WoW.World=OOP.Class();
local World=WoW.World;

function World:Constructor()
    self.cursor=WoW.Cursor:New(self);
end;

function World:GetCursor()
    return self.cursor;
end;
