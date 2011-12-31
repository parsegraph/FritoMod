if nil ~= require then
	require "fritomod/OOP-Class";
end;

CombatObjects=CombatObjects or {};

local SpellEvent = OOP.Class();
CombatObjects.Spell = SpellEvent;

function SpellEvent:Constructor(...)
	self:Set(...);
end;

function SpellEvent:Set(id, name, school)
	self.id = id;
	self.name = name;
	self.school = school;
	return self;
end;

function SpellEvent:Clone()
	return SpellEvent:New(
		self:Id(),
		self:Name(),
		self:School());
end;

function SpellEvent:Id()
	return self.id or 0;
end;

function SpellEvent:Name()
	return self.name or "(Unknown)";
end;

function SpellEvent:School()
	return self.school or 0;
end;

function SpellEvent:SchoolName()
	return CombatLog_String_SchoolString(self:School());
end;
