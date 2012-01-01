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
TargetEvent.ID= TargetEvent.GUID;
TargetEvent.Id= TargetEvent.GUID;

function TargetEvent:Name()
	if not self.name then
		self.name = GetPlayerInfoByGUID(6, self:GUID());
	end;
	return self.name or "Unknown";
end;

function TargetEvent:Flags()
	return self.flags;
end;

function TargetEvent:RaidFlags()
	return self.raidFlags;
end;

local function PlayerInfo(num)
	return function(self)
		local value = select(num, GetPlayerInfoByGUID(self:GUID()));
		return value;
	end;
end;

TargetEvent.Class = PlayerInfo(2);
TargetEvent.ClassName = PlayerInfo(1);
TargetEvent.Race = PlayerInfo(4);
TargetEvent.RaceName = PlayerInfo(3);
TargetEvent.Gender = PlayerInfo(5);
TargetEvent.Realm = PlayerInfo(7);

function TargetEvent:ClassColor()
	return Media.color[self:Class()];
end;

CombatObjects.AddSharedEvent("Source", "Target");
CombatObjects.AddSharedEvent("Target");
