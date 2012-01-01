if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/Callbacks-CombatObjects";
end;

CombatObjects=CombatObjects or {};

local AmountEvent = OOP.Class();
CombatObjects.Amount = AmountEvent;

function AmountEvent:Constructor(...)
	self:SetAmount(...);
end;

function AmountEvent:Set(amountType, amount, excess)
	self.amountType = amountType;
	self.amount = amount;
	self.excess = excess;
end;

function AmountEvent:Clone()
	return AmountEvent:New(
		self:Type(),
		self:Amount(),
		self:Excess()
	);
end;

function AmountEvent:Type()
	return self.amountType or "(Unknown)";
end;

function AmountEvent:Amount()
	return self.amount or 0;
end;
AmountEvent.GrossAmount = Headless("Amount");

function AmountEvent:NetAmount()
	return self:GrossAmount() - self:Reduction();
end;

function AmountEvent:RealAmount()
	return self:NetAmount() - self:Excess();
end;

function AmountEvent:Excess()
	return self.excess or 0;
end;
-- I use Headless here to allow subclasses to override
-- Excess; without it, subclasses would need to override
-- every alias.
AmountEvent.Overage = Headless("Excess");
AmountEvent.Overkill = Headless("Excess");
AmountEvent.Overheal = Headless("Excess");
AmountEvent.Overhealing = Headless("Excess");

function AmountEvent:Reduction()
	return 0;
end;
AmountEvent.Reduced = Headless("Reduction");
AmountEvent.Mitigated = Headless("Reduction");
AmountEvent.Mitigation = Headless("Reduction");

CombatObjects.AddSharedEvent("Power", "Amount");
CombatObjects.AddSharedEvent("Leeched", "Amount");

CombatObjects.SimpleSuffixHandler("ENERGIZE", "Amount");

Callbacks.PowerObjects = Curry(Callbacks.SuffixedCombatObjects, {
	"_ENERGIZE",
	"_DRAIN",
	"_LEECH"});
