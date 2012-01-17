if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/Tables";
end;

CombatObjects=CombatObjects or {};

local TargetEvent = OOP.Class();
CombatObjects.Target = TargetEvent;

function TargetEvent:Constructor(...)
	self:Set(...);
end;

function TargetEvent:Set(guid, name, flags, raidFlags)
	self.guid = guid;
	self:SetName(name);
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
	-- By default, return a GUID of an anonymous
	-- world object.
	return self.guid or "0x0010000000000000";
end;
TargetEvent.Guid = TargetEvent.GUID;
TargetEvent.ID= TargetEvent.GUID;
TargetEvent.Id= TargetEvent.GUID;

function TargetEvent:SetName(name)
	assert(self:GUID(), "GUID must be present, but was: "..tostring(self:GUID()));
	name = name or select(6, GetPlayerInfoByGUID(self:GUID()));
	if name then
		self.name = Strings.Trim(Strings.Split("-", name, 2)[1]);
	else
		self.name = "Unknown";
	end;
end;

function TargetEvent:FullName()
	return ("%s - %s"):format(self:Name(), self:Realm());
end;

function TargetEvent:Name()
	return self.name;
end;
TargetEvent.ShortName = TargetEvent.Name;

function TargetEvent:IsSelf()
	local name = self:Name();
	if name then
		return UnitIsUnit(self:Name(), "player");
	end;
end;
TargetEvent.IsMe = TargetEvent.IsSelf;
TargetEvent.IsMyself = TargetEvent.IsSelf;

do
	local unitTypes = {
		["0"] = "PLAYER",
		["1"] = "OBJECT",
		["3"] = "NPC",
		["4"] = "PET",
		["5"] = "VEHICLE"
	};

	function TargetEvent:UnitType()
		return unitTypes[Strings.CharAt(self:GUID(), 5)];
	end;

	local function IsUnitType(unitType)
		return function(self)
			return self:UnitType() == unitType;
		end;
	end;

	TargetEvent.IsPlayer = IsUnitType("PLAYER");
	TargetEvent.IsNPC = IsUnitType("NPC");
	TargetEvent.IsObject = IsUnitType("OBJECT");
	TargetEvent.IsPet = IsUnitType("PET");
	TargetEvent.IsVehicle = IsUnitType("VEHICLE");
end;

function TargetEvent:Flags()
	return self.flags;
end;

function TargetEvent:RaidFlags()
	return self.raidFlags;
end;

local function PlayerInfo(num)
	return function(self)
		-- Use a variable so we only return one value.
		local value = select(num, GetPlayerInfoByGUID(self:GUID()));
		return value;
	end;
end;

TargetEvent.Class = PlayerInfo(2);
TargetEvent.ClassName = PlayerInfo(1);
TargetEvent.Race = PlayerInfo(4);
TargetEvent.RaceName = PlayerInfo(3);
TargetEvent.Gender = PlayerInfo(5);

function TargetEvent:Realm()
	local realm = select(7, GetPlayerInfoByGUID(self:GUID()));
	if not realm or realm == "" then
		return GetRealmName();
	end;
end;

function TargetEvent:ClassColor()
	local class = self:Class();
	if class then
		return Media.color[class];
	end;
end;

function TargetEvent:ClassIcon()
	local class = self:Class();
	if class then
		return Media.texture[self:Class()];
	end;
end;
TargetEvent.ClassTexture = TargetEvent.ClassIcon;

function TargetEvent:Classification()
	local name = self:ShortName();
	if name then
		return UnitClassification(name);
	end;
end;

do
	local raceToFactions = {
		[{	"Dwarf",
			"NightElf",
			"Human",
			"Gnome",
			"Draenei",
			"Worgen"}] = "Alliance",
		[{	"BloodElf",
			"Goblin",
			"Orc",
			"Tauren",
			"Troll",
			"Scourge"}] = "Horde"
	};
	Tables.Expand(raceToFactions);

	function TargetEvent:Faction()
		local faction;
		local name = self:ShortName();
		if name then
			faction = UnitFactionGroup(name);
		end;
		if not faction and self:IsPlayer() then
			local race = self:Race();
			if race then
				faction = raceToFactions[race];
			end;
		end;
		return faction;
	end;
end;

function TargetEvent:FactionIcon()
	local faction = self:Faction();
	if faction then
		return Media.texture[faction];
	end;
	return Media.texture.unknown;
end;

function TargetEvent:FactionColor()
	local faction = self:Faction();
	if faction then
		return Media.color[faction];
	end;
	return Media.color.white;
end;

CombatObjects.AddSharedEvent("Source", "Target");
CombatObjects.AddSharedEvent("Target");
