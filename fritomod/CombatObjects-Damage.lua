-- Combat log object for all spell, ranged, melee, and environmental damage events
--[[

Callbacks.DamageObjects(function(when, event, source, target, spell, damage)
	printf("%s damaged %s with %s for %s.",
		Colors.ColorMessage(source:ClassColor(), source:Name()),
		Colors.ColorMessage(target:ClassColor(), target:Name()),
		spell:Link(),
		Colors.ColorMessage(damage:TypeColor(), ("%s %s"):format(damage:Amount(), damage:TypeName()))
	);
end);

--]]

if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/CombatObjects-Amount";
	require "fritomod/CombatObjects-Spell";
	require "fritomod/Callbacks-CombatObjects";
end;

CombatObjects=CombatObjects or {};

local DamageEvent = OOP.Class(CombatObjects.Amount);
CombatObjects.Damage = DamageEvent;

function DamageEvent:Constructor(...)
	self:Set(...);
end;

function DamageEvent:Set(amount, excess, school, resisted, blocked, absorbed, isCritical, isGlancing, isCrushing)
	DamageEvent.super.Set(self, school, amount, excess);
	self.resisted = resisted;
	self.blocked = blocked;
	self.absorbed = absorbed;
	self.isCritical = isCritical;
	self.isGlancing = isGlancing;
	self.isCrushing = isCrushing;
end;

function DamageEvent:Reduction()
	return self:Resisted() + self:Blocked() + self:Absorbed();
end;
DamageEvent.Mitigated = Headless("Reduction");
DamageEvent.Mitigation = Headless("Reduction");

DamageEvent.Overkill = DamageEvent.Excess;

function DamageEvent:IsKillingBlow()
	return self:Overkill() > 0;
end;

function DamageEvent:TypeName()
	return CombatLog_String_SchoolString(self:Type());
end;

function DamageEvent:TypeColor()
	return Media.color[self:TypeName()];
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

CombatObjects.AddSharedEvent("Damage");

CombatObjects.SimpleSuffixHandler("Damage");

CombatObjects.AliasHandler("DAMAGE_SHIELD", "SPELL_DAMAGE");
CombatObjects.AliasHandler("DAMAGE_SPLIT", "SPELL_DAMAGE");

Callbacks.DamageObjects = Curry(Callbacks.SuffixedCombatObjects, {
	"_DAMAGE",
	"DAMAGE_SHIELD",
	"DAMAGE_SHIELD_MISSED",
	"DAMAGE_SPLIT"});
