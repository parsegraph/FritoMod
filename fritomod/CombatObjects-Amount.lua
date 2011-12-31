if nil ~= require then
	require "fritomod/OOP-Class";
end;

CombatObjects=CombatObjects or {};

local AmountEvent = OOP.Class();
CombatObjects.Amount = AmountEvent;

function AmountEvent:Constructor(...)
	self:SetAmount(...);
end;

function AmountEvent:Set(amount, excess)
	self.amount = amount;
	self.excess = excess;
	return self;
end;

function AmountEvent:Clone()
	return AmountEvent:New(
		self:Amount(),
		self:Excess()
	);
end;

function AmountEvent:Amount()
	return self.amount;
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
