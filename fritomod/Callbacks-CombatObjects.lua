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

function Callbacks.SuffixedCombatObjects(suffix, func, ...)
	func=Curry(func, ...);
	return CombatEvents(function(timestamp, event, ...)
		if not Strings.EndsWith(event, suffix) then
			return;
		end;
		func(Serializers.WriteCombatObjects(timestamp, event, ...));
	end);
end;
