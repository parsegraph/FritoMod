if nil ~= require then
	require "fritomod/OOP-Class";
	require "fritomod/StateDispatcher";
	require "fritomod/ListenerList";
	require "fritomod/Math";
end;

Mechanics = Mechanics or {};

local Amount = OOP.Class();
Mechanics.Amount = Amount;

function Amount:Constructor(name)
	self.name = name or "Amount";

	self.listeners = ListenerList:New();
	self:SetBoundsPolicy("none");
end;

function Amount:AddInstaller(installer, ...)
	return self.listeners:AddInstaller(installer, ...);
end;

function Amount:Min()
	assert(type(self.min) == "number", "Amount has no minimum value");
	return self.min;
end;
Amount.GetMin     = Amount.Min;
Amount.GetMinimum = Amount.Min;

function Amount:SetMin(min)
	self:SetBounds(min, self:Max());
end;
Amount.SetMinimum = Amount.SetMin;

function Amount:Max()
	assert(type(self.max) == "number", "Amount has no maximum value");
	return self.max;
end;
Amount.GetMax     = Amount.Max;
Amount.GetMaximum = Amount.Max;

function Amount:SetMax(max)
	self:SetBounds(self:Min(), max);
end;
Amount.SetMaximum = Amount.SetMax;

function Amount:SetBounds(min, max)
	if self:InternalSetBounds(min, max) then
		self:Fire();
	end;
end;

function Amount:InternalSetBounds(min, max)
	assert(type(min) == "number", "min passed must be a number. Got: "..type(min));
	assert(type(max) == "number", "max passed must be a number. Got: "..type(max));
	assert(min <= max, "min must be less than max");
	-- Not sure if this should defer to the individual functions,
	-- or vice-versa. Right now, they defer to here.
	if self.max == max and self.min == min then
		return false;
	end;
	self.min = min;
	self.max = max;
	return true;
end;

function Amount:Range()
	return self:Max() - self:Min();
end;

function Amount:Value()
	assert(type(self.value) == "number", "Amount has no current value");
	return self.value;
end;
Amount.GetValue = Amount.Value;
Amount.Get      = Amount.Value;

function Amount:RawValue()
	return self.rawValue;
end;

function Amount:Percent()
	return Math.Percent(
		self:Min(),
		self:Value(),
		self:Max()
	);
end;

function Amount:SetValue(rawValue)
	if self:InternalSetValue(rawValue) then
		self:Fire();
	end;
end;
Amount.Set = Amount.SetValue;

function Amount:InternalSetValue(rawValue)
	assert(type(rawValue) == "number", "Value passed must be a number. Got: "..type(rawValue));
	-- We use a raw value to ensure that changing the bounds policy won't
	-- be lossy.
	self.rawValue = rawValue;
	local value = self.boundsPolicy(self:Min(), self.rawValue, self:Max());
	if self.value == value then
		return false;
	end;
	self.value = value;
	return true;
end;

function Amount:SetAll(min, value, max)
	-- We don't use the method accessors here since they're throw if there's
	-- no old value.
	local oldMin, oldMax, oldValue, oldRawValue
		= self.min, self.max, self.value, self.rawValue;
	local bchanged = self:InternalSetBounds(min, max);
	local vchanged = self:InternalSetValue(value);
	if bchanged or vchanged then
		self:Fire();
		return;
	end;
	self.min = oldMin;
	self.max = oldMax;
	self.rawValue = oldRawValue;
	self.value = oldValue;
end;

function Amount:Fire()
	self.listeners:Fire(self:Min(), self:Value(), self:Max());
end;

do
	local policies = {};
	policies.clamp = Math.Clamp;

	function policies.noop(min, value, max)
		return value;
	end;
	policies.none = policies.noop;

	policies.loop = Math.Modulo;
	policies.mod = policies.loop;
	policies.modulo = policies.loop;
	policies.modulus = policies.loop;

	function Amount:SetBoundsPolicy(policy, ...)
		if select("#", ...) == 0 and type(policy) == "string" then
			policy = string.lower(policy);
			policy = policies[policy];
		end;
		policy = Curry(policy, ...);
		self.boundsPolicy = policy;
		-- Be sure to use the raw value, so we don't lose values when
		-- changing between policies.
		if self:RawValue() ~= nil then
			self:SetValue(self:RawValue());
		end;
	end;
end;

function Amount:OnChange(listener, ...)
	return self.listeners:Add(listener, ...);
end;
Amount.OnChanged = Amount.OnChange;

function Amount:OnMinChanged(listener, ...)
	listener=Curry(listener, ...);
	local oldMin = self:Min();
	return self:OnChange(function(min, value, max)
		if oldMin ~= min then
			oldMin = min;
			return listener(min);
		end;
	end);
end;
Amount.OnMinChange = Amount.OnMinChanged;

function Amount:OnValueChanged(listener, ...)
	listener=Curry(listener, ...);
	local old = self:Value();
	return self:OnChange(function(min, value, max)
		if old ~= value then
			old = value;
			return listener(value);
		end;
	end);
end;
Amount.OnValueChange = Amount.OnValueChanged;

function Amount:OnMaxChanged(listener, ...)
	listener=Curry(listener, ...);
	local old = self:Max();
	return self:OnChange(function(min, value, max)
		if old ~= max then
			old = max;
			return listener(max);
		end;
	end);
end;
Amount.OnMaxChange = Amount.OnMaxChanged;
