if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/Events";
	require "fritomod/basic";
end;

-- TODO Should this live in Objects.GuildMember, perhaps? I hate cluttering
-- the global namespace for no good reason.


-- Use weak keys so our members can be dropped from this table.
local members = setmetatable({}, {
	__mode = "k"
});

local watchingGuildUpdates;
local function RegisterInstance(instance)
	members[instance] = true;
	if watchingGuildUpdates then
		-- We're already watching, so no need to set anything up.
		return;
	end;
	watchingGuildUpdates = Events.GUILD_ROSTER_UPDATE(function()
		local hasMembers;
		for member, _ in pairs(members) do
			hasMembers = true;
			member:UpdateIndex();
		end;
		if not hasMembers then
			-- No members are currently alive, so stop watching for
			-- updates.
			trace("No more guild member instances alive, so stop watching for updates");
			watchingGuildUpdates();
			watchingGuildUpdates=nil;
		end;
	end);
end;


GuildMember = OOP.Class();

function GuildMember:Constructor(...)
	RegisterInstance(self);
	self:Set(...);
end;

function GuildMember:Set(name)
	if tonumber(name) then
		self.index = name;
		-- We prefer the name instead of the index since the index can
		-- change for trivial reasons.
		self.name = GetGuildRosterInfo(name);
	else
		self.name = name;
		self.index = nil;
	end;
end;

function GuildMember:Clone()
	return GuildMember:New(self.name);
end;

function GuildMember:UpdateIndex()
	self.index=nil;
	self.name = self.name:upper();
	for i=1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i):upper() == self.name then
			self.index = i;
			break;
		end;
	end;
	assert(type(self.index)=="number", "No guild member with name: "..self.name);
end;

function GuildMember:Index()
	if self.index == nil then
		self:UpdateIndex();
	end;
	return self.index;
end;

local function RosterInfo(argNum)
	return function(self)
		local value = select(argNum, GetGuildRosterInfo(self:Index()))
		return value;
	end;
end;

GuildMember.Name = RosterInfo(1);
GuildMember.Rank = RosterInfo(2);
GuildMember.RankIndex = RosterInfo(3);
GuildMember.Level = RosterInfo(4);
GuildMember.ClassName = RosterInfo(5);
GuildMember.Zone = RosterInfo(6);
GuildMember.Note = RosterInfo(7);
GuildMember.OfficerNote = RosterInfo(8);
GuildMember.Status = RosterInfo(10);
GuildMember.Class = RosterInfo(11);
GuildMember.AchievementPoints = RosterInfo(12);
GuildMember.AchievementRank = RosterInfo(13);
GuildMember.IsMobile = RosterInfo(14);

function GuildMember:IsOnline()
	return Bool(select(9, GetGuildRosterInfo(self:Index())));
end;

-- XXX These methods were stolen from CombatObjects-Target.
-- I'm not sure where they should ultimately live, but I'm
-- thinking a mixin is the best bet.

function GuildMember:ClassColor()
	return Media.color[self:Class()];
end;

function GuildMember:ClassIcon()
	return Media.texture[self:Class()];
end;
GuildMember.ClassTexture = GuildMember.ClassIcon;
