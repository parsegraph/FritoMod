if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
end;

CombatObjects=CombatObjects or {};

local TargetEvent = OOP.Class();
CombatObjects.Target = TargetEvent;

function TargetEvent:Constructor(...)
	self:Set(...);
end;

function TargetEvent:Set(guid, name, flags, raidFlags)
	self.guid = guid;
	self.name = name;
	self.flags = flags;
	self.raidFlags = raidFlags;
	return self;
end;

function TargetEvent:Clone()
	return TargetEvent:New(
		self:GUID(),
		self:Name(),
		self:Flags(),
		self:RaidFlags());
end;

function TargetEvent:GUID()
	return self.guid or 0;
end;
TargetEvent.Guid = TargetEvent.GUID;

function TargetEvent:Name()
	return self.name or "(Unknown)";
end;

function TargetEvent:Flags()
	return self.flags;
end;

function TargetEvent:RaidFlags()
	return self.raidFlags;
end;

CombatObjects.AddSharedEvent("Source", "Target");
CombatObjects.AddSharedEvent("Target");
