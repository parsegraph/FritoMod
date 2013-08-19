-- A combat object that represents an amount. This is typically
-- inherited by more specialized amounts, like damage or heals.
--
-- See CombatObjects-Damage
-- See CombatObjects-Heal

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/Callbacks-CombatObjects";
end;

CombatObjects=CombatObjects or {};

local AmountEvent = OOP.Class("CombatObjects.AmountEvent");
CombatObjects.Amount = AmountEvent;

function AmountEvent:Constructor(...)
	self:SetAmount(...);
end;

function AmountEvent:Set(amountType)
	self.amountType = amountType;
end;

function AmountEvent:Clone()
	return AmountEvent:New(self:Type());
end;

function AmountEvent:Type()
	return self.amountType or "(Unknown)";
end;

-- Returns the unmodified amount, before any reductions have taken place.
-- Overages are also included in this total.
--
-- Generally speaking, this will return the biggest number of the three
-- *Amount methods.
function AmountEvent:GrossAmount()
	return self:NetAmount() + self:Reduction() + self:Excess();
end;

-- Returns the amount that the spell or damage hit for in-game. Excess
-- quantities like overheals or overkills will be included in this total,
-- though mitigation like absorptions and blocks will not.
function AmountEvent:RealAmount()
	return self:GrossAmount() - self:Reduction();
end;
AmountEvent.Amount = Headless("RealAmount");

-- Returns the "useful" amount of the spell or damage. Both excess
-- quantities and reductions are included in this total.
--
-- Generally speaking, this will return the smallest number of the three
-- *Amount methods.
function AmountEvent:NetAmount()
	return self:RealAmount() - self:Excess();
end;

-- Returns the "excess" amount. Excess amounts are those that
-- were not necessary to achieve some effect, like overheals or
-- overkills.
--
-- This should always be a positive number.
function AmountEvent:Excess()
	return 0;
end;
AmountEvent.Overage = Headless("Excess");

-- Returns the "reduced" amount. Reductions are things like
-- blocked damage and absorptions that have reduced the real
-- impact of this amount.
--
-- This should always be a positive number.
function AmountEvent:Reduction()
	return 0;
end;
AmountEvent.Reduced = Headless("Reduction");

CombatObjects.AddSharedEvent("Power", "Amount");
CombatObjects.AddSharedEvent("Leeched", "Amount");

CombatObjects.SimpleSuffixHandler("ENERGIZE", function(gainedAmount, powerType, alternatePowerType)
	if powerType == SPELL_POWER_ALTERNATE_POWER then
		powerType = select(12, GetAlternatePowerInfoByID(alternatePowerType));
	end;
	CombatObjects.SetSharedEvent("Power", powerType, gainedAmount);
end);

CombatObjects.SimpleSuffixHandler({
	"DRAIN",
	"LEECH"},
	function(drainedAmount, drainType, leechedAmount, alternateType)
		-- I'm assuming the leeched amount is described in the leechedAmount variable.
		return CombatObjects.SetSharedEvent("Power", drainType, drainedAmount),
			CombatObjects.SetSharedEvent("Leeched", drainType, leechedAmount);
	end);

Callbacks.PowerObjects = Curry(Callbacks.SuffixedCombatObjects, {
	"_ENERGIZE",
	"_DRAIN",
	"_LEECH"});
