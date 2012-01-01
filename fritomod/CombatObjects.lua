-- Utility methods for CombatObjects
--
-- See Also:
-- Callbacks-CombatObjects.lua
if nil ~= require then
	require "fritomod/currying";
	require "fritomod/Functions";
	require "fritomod/CombatEvents";
end;

CombatObjects = CombatObjects or {};

do
	local eventTypes = {};
	local events = {};

	function CombatObjects.AddSharedEvent(name, eventType)
		eventType = eventType or name;
		eventTypes[name] = eventType;
	end;

	function CombatObjects.SetSharedEvent(name, ...)
		local event = events[name];
		if event then
			event:Set(...);
			return event;
		end;
		local eventType = eventTypes[name];
		assert(eventType, "No registered type for event name: "..name);
		event = CombatObjects[eventType]:New(...);
		events[name] = event;
		return event;
	end;
end;

do
	local handlers={};

	function CombatObjects.SpellTypesHandler(suffix, func, ...)
		if not func and select("#", ...) == 0 then
			func=Curry(CombatObjects.SetSharedEvent, suffix);
			suffix=suffix:upper();
		elseif type(func) == "string" and select("#", ...) == 0 then
			func=Curry(CombatObjects.SetSharedEvent, func);
		else
			func=Curry(func, ...);
		end;
		if type(suffix)=="table" then
			for i=1, #suffix do
				CombatObjects.SpellTypesHandler(suffix[i], func);
			end;
			return;
		end;
		CombatObjects.Handler("SPELL_"..suffix, func);
		CombatObjects.Handler("SPELL_PERIODIC_"..suffix, func);
		CombatObjects.Handler("SPELL_BUILDING_"..suffix, func);
	end;

	function CombatObjects.AllTypesHandler(suffix, func, ...)
		func=Curry(func, ...);
		if type(suffix)=="table" then
			for i=1, #suffix do
				CombatObjects.AllTypesHandler(suffix[i], func);
			end;
			return;
		end;
		CombatObjects.Handler("SWING_"..suffix, func);
		CombatObjects.Handler("RANGE_"..suffix, func);
		CombatObjects.Handler("ENVIRONMENTAL"..suffix, func);
		CombatObjects.SpellTypesHandler(suffix, func);
	end;

	function CombatObjects.SimpleSuffixHandler(suffix, func, ...)
		if not func and select("#", ...) == 0 then
			func=Curry(CombatObjects.SetSharedEvent, suffix);
			suffix=suffix:upper();
		elseif type(func) == "string" and select("#", ...) == 0 then
			func=Curry(CombatObjects.SetSharedEvent, func);
		else
			func=Curry(func, ...);
		end;
		if type(suffix)=="table" then
			for i=1, #suffix do
				CombatObjects.SimpleSuffixHandler(suffix[i], func);
			end;
			return;
		end;
		CombatObjects.AllTypesHandler(suffix, function(...)
			return CombatObjects.SetSharedEvent("SourceSpell", ...),
				func(select(4, ...));
		end);

		CombatObjects.Handler("SWING_"..suffix, function(...)
			-- XXX This uses WoW-specific functionality, but I don't know where
			-- the underlying code should belong.
			return CombatObjects.SetSharedEvent("SourceSpell", nil, "Melee Swing", SCHOOL_MASK_PHYSICAL),
				func(...);
		end);

		CombatObjects.Handler("ENVIRONMENTAL_"..suffix, function(envType, ...)
			return CombatObjects.SetSharedEvent("SourceSpell", nil, envType, SCHOOL_MASK_PHYSICAL),
				func(...);
		end);
	end;

	function CombatObjects.NakedSuffixHandler(suffix)
		if type(suffix)=="table" then
			for i=1, #suffix do
				CombatObjects.NakedSuffixHandler(suffix[i]);
			end;
			return;
		end;
		CombatObjects.SimpleSuffixHandler(suffix, Functions.Return);
	end;

	function CombatObjects.NakedHandler(name)
		if type(name)=="table" then
			for i=1, #name do
				CombatObjects.NakedHandler(name[i]);
			end;
			return;
		end;
		handlers[name] = Functions.Return;
	end;

	function CombatObjects.Handler(name, func, ...)
		func=Curry(func, ...);
		handlers[name] = func;
	end;

	function CombatObjects.AliasHandler(name, aliasedName)
		CombatObjects.Handler(
			name,
			assert(handlers[aliasedName], "No handler for name: "..aliasedName));
	end;

	function CombatObjects.Handle(event, ...)
		local handler = handlers[event];
		if handler then
			return handler(...);
		else
			trace("Unhandled event: %s", event);
			return ...
		end;
	end;
end;

CombatObjects.NakedSuffixHandler("EXTRA_ATTACKS");
CombatObjects.NakedSuffixHandler("CAST_START");
CombatObjects.NakedSuffixHandler("CAST_SUCCESS");
CombatObjects.NakedSuffixHandler("CAST_FAILED");
CombatObjects.NakedSuffixHandler("INSTAKILL");
CombatObjects.NakedSuffixHandler("DURABILITY_DAMAGE");
CombatObjects.NakedSuffixHandler("DURABILITY_DAMAGE_ALL");
CombatObjects.NakedSuffixHandler("CREATE");
CombatObjects.NakedSuffixHandler("SUMMON");
