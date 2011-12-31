if nil ~= require then
	require "fritomod/OOP-Class";
end;

CombatObjects=CombatObjects or {};

local DamageEvent = OOP.Class();
CombatObjects.DamageEvent= DamageEvent;

function DamageEvent:Constructor(...)
	self:SetDamage(...);
end;

function DamageEvent:SetDamage(amount, overkill, school, resisted, blocked, absorbed, isCritical, isGlancing, isCrushing)
	self.amount = amount;
	self.overkill = overkill;
	self.resisted = resisted;
	self.blocked = blocked;
	self.absorbed = absorbed;
	self.isCritical = isCritical;
	self.isGlancing = isGlancing;
	self.isCrushing = isCrushing;
end;

function DamageEvent:Mitigated()
	return self:Resisted() + self:Blocked() + self:Absorbed();
end;

function DamageEvent:Amount()
	return self.amount;
end;
DamageEvent.GrossAmount = DamageEvent.Amount;

function DamageEvent:NetAmount()
	return self:GrossAmount() - self:Mitigated();
end;

function DamageEvent:RealAmount()
	return self:NetAmount() - self:Overkill();
end;


function DamageEvent:Overkill()
	return self.overkill or 0;
end;

function DamageEvent:Resisted()
	if self.resisted == nil then
		return 0;
	end;
	if self.resisted or self.resisted < 0 then
		-- TODO Handle vulnerability, which is reported as negative resistance,
		-- instead of ignoring it.
		return 0;
	end;
	return self.resisted or 0;
end;

function DamageEvent:Blocked()
	return self.blocked or 0;
end;

function DamageEvent:Absorbed()
	return self.absorbed or 0;
end;

function DamageEvent:IsCritical()
	return Bool(self.isCritical);
end;

function DamageEvent:IsGlancing()
	return Bool(self.isGlancing);
end;

function DamageEvent:IsCrushing()
	return Bool(self.isCrushing);
end;
