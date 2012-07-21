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
	require "fritomod/CombatObjects";
	require "fritomod/CombatObjects-Target";
end;

Callbacks=Callbacks or {};
Serializers=Serializers or {};

-- Convert an event, received from the COMBAT_LOG_EVENT_UNFILTERED event,
-- to an OOP-centric one.
--
-- See CombatObjects.Handle for more information about how
-- specific events are handled.
function Serializers.WriteCombatObjects(timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	return timestamp, event,
		CombatObjects.SetSharedEvent("Source",
			sourceGUID,
			sourceName,
			sourceFlags,
			sourceRaidFlags),
		CombatObjects.SetSharedEvent("Target",
			destGUID,
			destName,
			destFlags,
			destRaidFlags),
		CombatObjects.Handle(event, ...);
end;

function Callbacks.CombatObjects(func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(...)
		return func(Serializers.WriteCombatObjects(...));
	end);
end;

function Callbacks.CombatObjectEvent(targetEvent, func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, ...)
		if type(targetEvent) == "table" then
			for i=1, #targetEvent do
				if event == targetEvent[i] then
					func(Serializers.WriteCombatObjects(
						timestamp,
						event,
						...));
					return;
				end;
			end;
			return;
		elseif targetEvent == event then
			func(Serializers.WriteCombatObjects(timestamp, event, ...));
		end;
	end);
end;

-- Listens for combat log events with the specified suffix.
function Callbacks.SuffixedCombatObjects(suffix, func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, ...)
		if not Strings.EndsWith(event, suffix) then
			return;
		end;
		-- Pass along to WriteCombatObjects, which does the real work
		-- of translating a combat event into a OOPish event.
		func(Serializers.WriteCombatObjects(timestamp, event, ...));
	end);
end;

CombatObjects.NakedSuffixHandler("EXTRA_ATTACKS");

CombatObjects.NakedSuffixHandler("RESURRECT");
Callbacks.ResurrectObjects = Curry(
	Callbacks.SuffixedCombatObjects,
	"RESURRECT");

CombatObjects.NakedSuffixHandler("CREATE");
CombatObjects.NakedSuffixHandler("SUMMON");

Callbacks.SummonObjects = Curry(
	Callbacks.SuffixedCombatObjects, {
		"CREATE",
		"SUMMON"});

CombatObjects.NakedSuffixHandler({
	"INSTAKILL",
	"DISSIPATES"});
CombatObjects.NakedHandler({
	"UNIT_DIED",
	"UNIT_DESTROYED",
	"PARTY_KILL"});

Callbacks.DeathObjects = Curry(
	Callbacks.SuffixedCombatObjects, {
		"UNIT_DIED",
		"UNIT_DESTROYED",
		"PARTY_KILL",
		"INSTAKILL",
		"DISSIPATES"
	});

local castObjects = {
	"CAST_START",
	"CAST_SUCCESS",
	"CAST_FAILED"
};
CombatObjects.NakedSuffixHandler(castObjects);

Callbacks.CastObjects = Curry(
	Callbacks.SuffixedCombatObjects,
	castObjects);

local durabilityObjects = {
	"DURABILITY_DAMAGE",
	"DURABILITY_DAMAGE_ALL",
};
CombatObjects.NakedSuffixHandler(durabilityObjects);

Callbacks.DurabilityObjects = Curry(
	Callbacks.SuffixedCombatObjects,
	durabilityObjects);

