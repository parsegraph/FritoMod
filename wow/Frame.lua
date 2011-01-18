if nil ~= require then
	require "Metatables";
	require "OOP-Class";
end;

WoW=WoW or Metatables.Defensive();
WoW.Frame=OOP.Class();
