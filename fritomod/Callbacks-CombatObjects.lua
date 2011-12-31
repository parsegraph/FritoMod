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
	require "fritomod/CombatObjects-Target";
	require "fritomod/CombatObjects-Spell";
	require "fritomod/CombatObjects-Damage";
end;

Callbacks=Callbacks or {};

local function Reporter(baseName)
	local event;
	local setName = "Set"..baseName;
	local eventName = baseName.."Event";
	return function(...)
		if event then
			event[setName](event, ...);
		else
			event=CombatObjects[eventName]:New(...);
		end;
		return event;
	end;
end;

local ReportDamage = Reporter("Damage");
local ReportDamagingSpell = Reporter("Spell");
local ReportSourceTarget = Reporter("Target");
local ReportDestTarget = Reporter("Target");

local handlers={};

function handlers.SPELL_DAMAGE(...)
	return ReportDamagingSpell(...),
			ReportDamage(select(4, ...));
end;
handlers.RANGE_DAMAGE=handlers.SPELL_DAMAGE;
handlers.SPELL_PERIODIC_DAMAGE=handlers.SPELL_DAMAGE;
handlers.SPELL_BUILDING_DAMAGE=handlers.SPELL_DAMAGE;

function handlers.SWING_DAMAGE(...)
	local school = select(3, ...);
	return ReportDamagingSpell(nil, "SWING", school),
			ReportDamage(...);
end;

function handlers.ENVIRONMENTAL_DAMAGE(envType, ...)
	local school = select(3, ...);
	return ReportDamagingSpell(nil, envType, school),
		ReportDamage(...);
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
		local handler = handlers[event] or Functions.Return;
		return timestamp, event, source, target, handler(...);
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
