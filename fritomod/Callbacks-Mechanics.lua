if nil ~= require then
	-- TODO This requires WoW's UnitHealth, UnitPower, etc.
	require "fritomod/currying";
	require "fritomod/Events";
end;

Callbacks = Callbacks or {};

local function HealthCallback(event)
	return function(who, listener, ...)
		listener = Curry(listener, ...);
		who = tostring(who):lower();
		local function Fire()
			listener(UnitHealth(who));
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

function Callbacks.HealthPercent(who, listener, ...)
	listener=Curry(listener, ...);
	return Callbacks.Health(who, function(amount)
		if amount ~= nil then
			listener(amount / UnitHealthMax(who));
		else
			listener(nil);
		end;
	end);
end;

local function PowerCallback(event)
	return function(who, power, listener, ...)
		listener = Curry(listener, ...);
		who = tostring(who):lower();
		power = tostring(power):upper();
		local function Fire()
			listener(UnitPower(who, power));
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

function Callbacks.PowerPercent(who, powerType, listener, ...)
	listener=Curry(listener, ...);
	return Callbacks.Power(who, powerType, function(amount)
		if amount ~= nil then
			listener(amount / UnitPowerMax(who, powerType));
		else
			listener(nil);
		end;
	end);
end;
