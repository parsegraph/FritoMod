if nil ~= require then
	require "fritomod/Amount";
end;

Amounts = Amounts or {};

function Amounts.ComboPoints()
	local amount = Mechanics.Amount:New("Combo Points");
	amount:AddInstaller(Callbacks.ComboPoints, amount, "SetAll");
	return amount;
end;

function Amounts.Health(who)
	local amount = Mechanics.Amount:New("Health for "..who);
	amount:AddInstaller(Callbacks.Health, who, amount, "SetAll");
	return amount;
end;

function Amounts.Power(who, what)
	local amount = Mechanics.Amount:New("Power");
	amount:AddInstaller(Callbacks.Power, who, what, amount, "SetAll");
	return amount;
end;

local function SpecificPower(name)
	Amounts[name] = function(who, ...)
		return Amounts.Power(who, name:upper(), ...);
	end;
end;

SpecificPower("Rage");
SpecificPower("Energy");
SpecificPower("Focus");
SpecificPower("Mana");
