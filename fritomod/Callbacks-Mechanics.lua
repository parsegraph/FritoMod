if nil ~= require then
	-- TODO This requires WoW's UnitHealth, UnitPower, etc.
	require "wow/api/Units";
	require "fritomod/currying";
	require "fritomod/Events";
	require "fritomod/Math";
	require "fritomod/Timing";
end;

Callbacks = Callbacks or {};

function Callbacks.Percent(callback, listener, ...)
	listener = Curry(listener, ...);
	return callback(function(min, value, max)
		listener(Math.Percent(min, value, max));
	end);
end;

local function HealthCallback(event)
	return function(who, listener, ...)
		listener = Curry(listener, ...);
		who = tostring(who):lower();
		local function Fire()
			if not UnitExists(who) then
				trace("Health callback fired, but unit doesn't exist");
				return;
			end;
			local value = UnitHealth(who);
			local max = UnitHealthMax(who);
			if value ~= nil and max ~= nil then
				trace("Firing health callback: " .. value .. " " ..max);
				listener(0, value, max);
			end;
		end;
		Fire();
		local events = {
			event,
			"UNIT_MAXHEALTH",
			-- This event is really superfluous for some targets; we really
			-- should only listen for those events that are relevant to the
			-- target.
			"PLAYER_TARGET_CHANGED"
		};
		return Events[events](Fire);
	end;
end;

Callbacks.Health = HealthCallback("UNIT_HEALTH_FREQUENT");
Callbacks.FrequentHealth = Callbacks.Health;

Callbacks.ThrottledHealth = HealthCallback("UNIT_HEALTH");

function Callbacks.Power(who, power, listener, ...)
	listener = Curry(listener, ...);
	assert(who, "who must not be falsy");
	who = tostring(who):lower();
	if power then
		power = tostring(power):upper();
	end;
	local oldValue, oldMax;
	local function Fire()
		if not UnitExists(who) then
			return;
		end;
		local value = UnitPower(who, power);
		local max = UnitPowerMax(who, power);

		if oldValue ~= value or oldMax ~= max then
			oldValue = value;
			oldMax = max;
			listener(0, value, max);
		end;
	end;
	Fire();
	return Timing.Every(Fire);
end;

local function SpecificPower(what)
	Callbacks[what] = function(who, ...)
		return Callbacks.Power(who, what:upper(), ...);
	end;
end;

SpecificPower("Rage");
SpecificPower("Energy");
SpecificPower("Focus");
SpecificPower("Mana");

function Callbacks.ComboPoints(listener, ...)
	listener=Curry(listener, ...);
	local function Update()
		local value = GetComboPoints("player");
		assert(type(value) == "number", "GetComboPoints must return a number");
		listener(0, value, 5);
	end;
	local events = {
		"UNIT_COMBO_POINTS",
		"PLAYER_TARGET_CHANGED"
	};
	return Events[events](Update);
end;

-- vim: set noet :
