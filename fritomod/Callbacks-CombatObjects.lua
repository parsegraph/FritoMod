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
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/CombatEvents";
	require "fritomod/CombatObjects-Target";
	require "fritomod/CombatObjects-Spell";
	require "fritomod/CombatObjects-Damage";
end;

Callbacks=Callbacks or {};

local function Reporter(eventName)
	local event;
	return function(...)
		if event then
			event:Set(...);
		else
			event=CombatObjects[eventName]:New(...);
		end;
		return event;
	end;
end;

local ReportDamage = Reporter("Damage");
local ReportActivatingSpell = Reporter("Spell");
local ReportSourceTarget = Reporter("Target");
local ReportDestTarget = Reporter("Target");
local ReportMiss = Reporter("Miss");
local ReportHeal = Reporter("Heal");

local handlers={};

local function MagicTypesHandler(suffix, func, ...)
	func=Curry(func, ...);
	handlers["RANGE_"..suffix] = func;
	handlers["SPELL_"..suffix] = func;
	handlers["SPELL_PERIODIC_"..suffix] = func;
	handlers["SPELL_BUILDING_"..suffix] = func;
	handlers["ENVIRONMENTAL_"..suffix] = func;
end;

local function AllTypesHandler(suffix, func, ...)
	func=Curry(func, ...);
	handlers["SWING_"..suffix] = func;
	MagicTypesHandler(suffix, func);
end;

AllTypesHandler("DAMAGE", function(...)
	return ReportActivatingSpell(...),
			ReportDamage(select(4, ...));
end);

function handlers.SWING_DAMAGE(...)
	local school = select(3, ...);
	return ReportActivatingSpell(nil, "SWING", school),
			ReportDamage(...);
end;

function handlers.ENVIRONMENTAL_DAMAGE(envType, ...)
	local school = select(3, ...);
	return ReportActivatingSpell(nil, envType, school),
		ReportDamage(...);
end;

AllTypesHandler("MISSED", function(...)
	return ReportActivatingSpell(...),
			ReportMiss(select(4, ...));
end);

function handlers.SWING_MISSED(...)
	-- XXX This uses WoW-specific functionality, but I don't know where
	-- the underlying code should belong.
	return ReportActivatingSpell(nil, "SWING", SCHOOL_MASK_PHYSICAL),
			ReportMiss(...);
end;

function handlers.ENVIRONMENTAL_MISSED(envType, ...)
	return ReportActivatingSpell(nil, envType, SCHOOL_MASK_PHYSICAL),
			ReportMiss(...);
end;

AllTypesHandler("HEAL", function(...)
	return ReportActivatingSpell(...),
			ReportHeal(select(4, ...));
end);

function handlers.SWING_HEAL(...)
	-- XXX Not sure if this ever fires. Do weapon healing procs count
	-- as SWING_HEAL?
	return ReportActivatingSpell(nil, "SWING", SCHOOL_MASK_PHYSICAL),
			ReportHeal(...);
end;

function handlers.ENVIRONMENTAL_HEAL(envType, ...)
	-- XXX Not sure if this ever fires. Do "Entering the arena" heals
	-- count as ENVIRONMENTAL_HEAL?
	return ReportActivatingSpell(nil, envType, SCHOOL_MASK_PHYSICAL),
			ReportHeal(...);
end;

Serializers=Serializers or {};
function Serializers.WriteCombatObjects(timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
		local source = ReportSourceTarget(
			sourceGUID,
			sourceName,
			sourceFlags,
			sourceRaidFlags);
		local target= ReportDestTarget(
			destGUID,
			destName,
			destFlags,
			destRaidFlags);
		local handler = handlers[event];
		if handler then
			return timestamp, event, source, target, handler(...);
		else
			trace("Unhandled event: %s", event);
			return timestamp, event, source, target, ...;
		end;
end;

function Callbacks.CombatObjects(func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(...)
		return func(Serializers.WriteCombatObjects(...));
	end);
end;

function Callbacks.DamageObjects(func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, ...)
		if not Strings.EndsWith(event, "_DAMAGE") then
			return;
		end;
		func(Serializers.WriteCombatObjects(timestamp, event, ...));
	end);
end;
Callbacks.DamageObject = Callbacks.DamageObjects;

function Callbacks.HealObjects(func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, ...)
		if not Strings.EndsWith(event, "_HEAL") then
			return;
		end;
		func(Serializers.WriteCombatObjects(timestamp, event, ...));
	end);
end;
Callbacks.HealObject = Callbacks.HealObjects;
