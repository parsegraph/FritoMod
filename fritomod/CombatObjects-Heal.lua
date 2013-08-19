-- Combat log object for all heal events.
--[[

Callbacks.HealObjects(function(when, event, source, target, spell, amount)
	printf("%s healed %s for %d hit points. (%d excess)",
		source:Name(),
		target:Name(),
		amount:RealAmount(),
		amount:Excess()
	);
end);

--]]
if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/CombatObjects-Amount";
	require "fritomod/Callbacks-CombatObjects";
end;

CombatObjects=CombatObjects or {};

local HealEvent = OOP.Class("CombatObjects.HealEvent", CombatObjects.Amount);
CombatObjects.Heal = HealEvent;

function HealEvent:Constructor(...)
	self:Set(...);
end;

-- The "absorbed" element in Blizzard's event is the effect of a hostile shield
-- (like that given by a Death Knight) rather than a positive friendly effect.
function HealEvent:Set(amount, overheal, reduction, isCritical)
	HealEvent.super.Set(self, "HEAL");
	self.amount = amount;
	self.overheal = overheal;
	self.reduction = reduction;
	self.isCritical = isCritical;
end;

function HealEvent:Clone()
	return HealEvent:New(
		self:Amount(),
		self:Excess(),
		self:Absorbed(),
		self:IsCritical());
end;

function HealEvent:RealAmount()
	return self.amount or 0;
end;

function HealEvent:Reduction()
	return self.reduction or 0;
end;
HealEvent.Absorbed = HealEvent.Reduction;

function HealEvent:Excess()
	return self.overheal or 0;
end;
HealEvent.Overheal = Headless("Excess");
HealEvent.Overhealing = Headless("Excess");

function HealEvent:IsCritical()
	return Bool(self.isCritical);
end;

CombatObjects.AddSharedEvent("Heal");

CombatObjects.SimpleSuffixHandler("Heal");

Callbacks.HealObjects = Curry(Callbacks.SuffixedCombatObjects, "_HEAL");
