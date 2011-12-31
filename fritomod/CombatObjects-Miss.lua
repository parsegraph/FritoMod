if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/CombatObjects-Amount";
end;

CombatObjects=CombatObjects or {};

local MissEvent = OOP.Class(CombatObjects.Amount);
CombatObjects.Miss = MissEvent;

function MissEvent:Constructor(...)
	self:Set(...);
end;

function MissEvent:Set(missType, isOffHand, amount)
	self.super.Set(self, amount, 0);
	self.missType = missType;
	self.isOffHand = isOffHand;
	return self;
end;

function MissEvent:Clone()
	return MissEvent:New(
		self:Type(),
		self:IsOffHand(),
		self:Amount());
end;

function MissEvent:Type()
	-- I named this missType to not get confused with
	-- the builtin 'type'
	return self.missType;
end;

function MissEvent:IsOffHand()
	return Bool(self.isOffHand);
end;
