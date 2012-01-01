if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects";
	require "fritomod/CombatObjects-Spell";
end;

CombatObjects=CombatObjects or {};

local BuffEvent = OOP.Class(CombatObjects.Spell);
CombatObjects.Buff = BuffEvent;

function BuffEvent:Constructor(...)
	self:Set(...);
end;

function BuffEvent:Set(id, name, school, auraType)
	self.super.Set(self, id, name, school);
	self.auraType = auraType;
end;

function BuffEvent:Clone()
	return BuffEvent:New(
		self:Id(),
		self:Name(),
		self:School(),
		self:AuraType());
end;

function BuffEvent:AuraType()
	return self.auraType;
end;

function BuffEvent:IsBuff()
	return self.auraType == "BUFF";
end;

function BuffEvent:IsDebuff()
	return self.auraType == "DEBUFF";
end;

CombatObjects.AddSharedEvent("Buff");

CombatObjects.SimpleSuffixHandler({
	"DISPEL",
	"DISPEL_FAILED",
	"STOLEN",
	"AURA_BROKEN_SPELL"},
	"Buff");

CombatObjects.SpellTypesHandler({
	"AURA_APPLIED",
	"AURA_REMOVED",
	"AURA_REFRESH",
	"AURA_BROKEN"},
	"Buff");

CombatObjects.SpellTypesHandler({
	"AURA_APPLIED_DOSE",
	"AURA_REMOVED_DOSE"},
	function(...)
		return CombatObjects.SetSharedEvent("Buff", ...),
			select(5, ...);
	end);

Callbacks.BuffObjects = Curry(
	Callbacks.SuffixedCombatObjects, {
	"_DISPEL",
	"_DISPEL_FAILED",
	"_STOLEN"});
