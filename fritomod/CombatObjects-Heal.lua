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

local HealEvent = OOP.Class(CombatObjects.Amount);
CombatObjects.Heal = HealEvent;

function HealEvent:Constructor(...)
	self:Set(...);
end;

-- XXX I'm assuming the "absorbed" element in Blizzard's event is the
-- effect of a hostile shield (like that given by a Death Knight) rather
-- than a positive friendly effect.
function HealEvent:Set(amount, excess, reduction, isCritical)
	self.super.Set(self, "HEAL", amount, excess);
	self.reduction = reduction;
	self.isCritical = isCritical;
	return self;
end;

function HealEvent:Clone()
	return HealEvent:New(
		self:Amount(),
		self:Excess(),
		self:Absorbed(),
		self:IsCritical());
end;

function HealEvent:Reduction()
	return self.reduction or 0;
end;
HealEvent.Absorbed = HealEvent.Reduction;

function HealEvent:IsCritical()
	return Bool(self.isCritical);
end;

CombatObjects.AddSharedEvent("Heal");

CombatObjects.SimpleTypesHandler("HEAL", "Heal");

Callbacks.HealObjects = Curry(Callbacks.SuffixedCombatObjects, "_HEAL");
