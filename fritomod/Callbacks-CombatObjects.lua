-- Provides combat events in a more object-oriented fashion
--[[

Callbacks.DamageEvents(function(when, event, source, target, spell, damage)
	if source:Name() ~= UnitName("player") then
		return;
	end;
	printf("%s damaged %s with %s for %d gross",
		source:Name(), 
		target:Name(),
		spell:Name(),
		damage:GrossAmount());
end);

]]

if nil ~= require then
	require "fritomod/Functions";
	require "fritomod/CombatEvents";
end;

Callbacks=Callbacks or {};

local function ReportDamage(self, amount, overkill, school, resisted, blocked, absorbed, isCritical, isGlancing, isCrushing)
	function self:Amount()
		return amount;
	end;
	self.GrossAmount = self.Amount;
	function self:Overkill()
		return overkill or 0;
	end;
	function self:Resisted()
		if resisted == nil then
			return 0;
		end;
		if resisted or resisted < 0 then
			-- TODO Handle vulnerability, which is reported as negative resistance,
			-- instead of ignoring it.
			return 0;
		end;
		return resisted or 0;
	end;
	function self:Blocked()
		return blocked or 0;
	end;
	function self:Absorbed()
		return absorbed or 0;
	end;
	function self:IsCritical()
		return Bool(isCritical);
	end;
	function self:IsGlancing()
		return Bool(isGlancing);
	end;
	function self:IsCrushing()
		return Bool(isCrushing);
	end;
	function self:Mitigated()
		return self:Resisted() + self:Blocked() + self:Absorbed();
	end;
	function self:NetAmount()
		return self:GrossAmount() - self:Mitigated();
	end;
	function self:RealAmount()
		return self:NetAmount() - self:Overkill();
	end;
	return self;
end;

local function ReportDamagingSpell(self, spellId, spellName, spellSchool)
	function self:Id()
		return spellId or 0;
	end;
	function self:Name()
		return spellName or "(Unknown)";
	end;
	function self:School()
		return spellSchool or 0;
	end;
	function self:SchoolName()
		return CombatLog_String_SchoolString(spellSchool);
	end;
	return self;
end;

local function ReportTarget(self, guid, name, flags, raidFlags)
	function self:GUID()
		return guid or 0;
	end;
	function self:Name()
		return name or "(Unknown)";
	end;
	function self:Flags()
		return flags;
	end;
	function self:RaidFlags()
		return raidFlags;
	end;
	return self;
end;

local handlers={};

function handlers.SPELL_DAMAGE(...)
	return ReportDamagingSpell({}, ...),
			ReportDamage({}, select(4, ...));
end;
handlers.RANGE_DAMAGE=handlers.SPELL_DAMAGE;
handlers.SPELL_PERIODIC_DAMAGE=handlers.SPELL_DAMAGE;
handlers.SPELL_BUILDING_DAMAGE=handlers.SPELL_DAMAGE;

function handlers.SWING_DAMAGE(...)
	local school = select(3, ...);
	return ReportDamagingSpell({}, nil, "SWING", school),
			ReportDamage({}, ...);
end;

function handlers.ENVIRONMENTAL_DAMAGE(envType, ...)
	local school = select(3, ...);
	return ReportDamagingSpell({}, nil, envType, school),
		ReportDamage({}, ...);
end;

function Callbacks.CombatObjects(func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
		local source = ReportTarget({},
			sourceGUID,
			sourceName,
			sourceFlags,
			sourceRaidFlags);
		local target= ReportTarget({},
			destGUID,
			destName,
			destFlags,
			destRaidFlags);
		local handler = handlers[event] or Functions.Return;
		func(timestamp, event, source, target, handler(...));
	end);
end;

function Callbacks.DamageEvents(func, ...)
	func=Curry(func, ...);
	return Callbacks.CombatObjects(function(timestamp, event, ...)
		if not Strings.EndsWith(event, "_DAMAGE") then
			return;
		end;
		func(timestamp, event, ...);
	end);
end;
