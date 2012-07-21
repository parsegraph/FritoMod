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
	-- Mapping of conventional names (like "Source" or "Spell") to the underlying
	-- shared object.
	local sharedObjects = {};

	-- Register a combat object, referred to by eventType, as a shared object.
	-- Shared objects are used by combat event handlers to minimize the creation
	-- of short-lived objects.
	--
	-- Name should refer to the purpose of the combat object, like "Source" or
	-- "Target". If eventType is unspecified, then name will be used.
	function CombatObjects.AddSharedEvent(name, eventType)
		eventType = eventType or name;
		assert(sharedObjects[name] == nil or sharedObjects[name] == eventType,
			"Refusing to overwrite the shared object with name: "..name);
		sharedObjects[name] = eventType;
	end;

	-- Use a shared combat object by passing the specified arguments to it. The
	-- shared object will then be returned.
	--
	-- It's important that client do not retain access to thse objects, since they
	-- will be modified as other combat events are recorded.
	function CombatObjects.SetSharedEvent(name, ...)
		local sharedObject = sharedObjects[name];
		if type(sharedObject) == "string" then
			sharedObject = CombatObjects[sharedObject]:New(...);
			sharedObjects[name] = sharedObject;
			return sharedObject;
		elseif sharedObject ~= nil then
			sharedObject:Set(...);
			return sharedObject;
		else
			error("No registered object for name: "..name);
		end;
	end;
end;

do
	-- Internal registry of combat event handlers
	local handlers={};

	-- Register the specified function as a combat event handler for
	-- spell-related combat events that contain the specified suffix.
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

	-- Register the specified function as a combat event handler for all
	-- combat events that contain the specified suffix.
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

	-- Registers the specified function as a handler for all combat events
	-- that contain the specified suffix.
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

	-- A combat event handler that returns the passed arguments verbatim for all
	-- combat events that contain the specified suffix.
	function CombatObjects.NakedSuffixHandler(suffix)
		if type(suffix)=="table" then
			for i=1, #suffix do
				CombatObjects.NakedSuffixHandler(suffix[i]);
			end;
			return;
		end;
		CombatObjects.SimpleSuffixHandler(suffix, Functions.Return);
	end;

	-- A combat event handler that returns the passed arguments verbatim.
	function CombatObjects.NakedHandler(name)
		if type(name)=="table" then
			for i=1, #name do
				CombatObjects.NakedHandler(name[i]);
			end;
			return;
		end;
		handlers[name] = Functions.Return;
	end;

	-- Register the specified function as a handler for the
	-- specified combat event name.
	--
	-- Handlers take the combat event arguments, as given to us from Blizzard, and
	-- return the converted arguments. We prefer an OOPish style, so conversion typically
	-- means passing arguments into objects.
	function CombatObjects.Handler(name, func, ...)
		func=Curry(func, ...);
		handlers[name] = func;
	end;

	function CombatObjects.AliasHandler(name, aliasedName)
		CombatObjects.Handler(
			name,
			assert(handlers[aliasedName], "No handler for name: "..aliasedName));
	end;

	-- Handle the specific COMBAT_LOG_EVENT event. The handler
	-- used will be determined by the event name, which was
	-- previously registered.
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
