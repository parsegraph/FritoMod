if nil ~= require then
	-- TODO This requires WoW's UnitHealth, UnitPower, etc.
	require "fritomod/currying";
	require "fritomod/Events";
	require "fritomod/Math";
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
			local value = UnitHealth(who);
			local max = UnitHealthMax(who);
			if value ~= nil and max ~= nil then
				listener(0, value, max);
			end;
		end;
		Fire();
		return Events[event](function(target)
			if target == who then
				Fire();
			end;
		end);
	end;
end;

Callbacks.Health = HealthCallback("UNIT_HEALTH_FREQUENT");
Callbacks.FrequentHealth = Callbacks.Health;

Callbacks.ThrottledHealth = HealthCallback("UNIT_HEALTH");

local function PowerCallback(event)
	return function(who, power, listener, ...)
		listener = Curry(listener, ...);
		who = tostring(who):lower();
		power = tostring(power):upper();
		local function Fire()
			local value = UnitPower(who, power);
			local max = UnitPowerMax(who, power);
			if value ~= nil and max ~= nil then
				listener(0, value, max);
			end;
		end;
		Fire();
		return Events[event](function(target, targetPower)
			if target == who and targetPower == power then
				Fire();
			end;
		end);
	end;
end;

Callbacks.Power = PowerCallback("UNIT_POWER_FREQUENT");
Callbacks.FrequentPower = Callbacks.Power;

Callbacks.ThrottledPower = PowerCallback("UNIT_POWER");

function Callbacks.ComboPoints(listener, ...)
	listener=Curry(listener, ...);
	local function Fire()
		local value = GetComboPoints("player");
		if value ~= nil then
			listener(0, value, 5);
		end;
	end;
	return Events.UNIT_COMBO_POINTS(function()
		Fire();
	end);
end;
