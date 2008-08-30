RangeDataProvider = AceLibrary("AceOO-2.0").Class(DataProvider);
local RangeDataProvider = RangeDataProvider;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function RangeDataProvider.prototype:init(tags, initialValue, minimum, maximum)
	RangeDataProvider.super.prototype.init(self, tags, initialValue);
  if minimum == 0 then
    minimum = min(0, initialValue);
  end;
	self:SetMinimum(minimum);
  if maximum == nil then
    maximum = initialValue;
  end;
	self:SetMaximum(maximum);
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

------------------------------------------
--  Value
------------------------------------------

function RangeDataProvider.prototype:SetValue(value)
  if type(value) ~= "number" then
    error("Value given to RangeDataProvider isn't numeric.");
  end;
  value = min(value, self:GetMaximum());
  value = max(value, self:GetMinimum());
  return RangeDataProvider.super.prototype.SetValue(self, value);
end;

------------------------------------------
--  Maximum
------------------------------------------

function RangeDataProvider.prototype:GetMaximum()
	return self.maximum;
end;

function RangeDataProvider.prototype:SetMaximum(maximum)
	if maximum == self:GetMaximum() then
		return;
	end;
	self.maximum = maximum;
	self:TriggerUpdate();
end;

------------------------------------------
--  Minimum
------------------------------------------

function RangeDataProvider.prototype:GetMinimum()
	return self.minimum;
end;

function RangeDataProvider.prototype:SetMinimum(minimum)
	if minimum == self:GetMinimum() then
		return;
	end;
	self.minimum = minimum;
	self:TriggerUpdate();
end;

------------------------------------------
--  Range
------------------------------------------

function RangeDataProvider.prototype:GetRange()
	return self:GetMaximum() - self:GetMinimum();
end;

------------------------------------------
--  Percentage
------------------------------------------

-- Returns the percentage. This is designed so that subclasses can adjust the percentage
-- in order to show a different kind of effect (That is, a non-linear progression)
function RangeDataProvider.prototype:GetPercentage()
	return self:GetRawPercentage();
end;

function RangeDataProvider.prototype:GetRawPercentage()
	local value = self:GetValue();
	
	-- Assert that our value isn't outside our bounds
	value = min(value, self:GetMaximum());
	value = max(value, self:GetMinimum());

	value = value - self:GetMinimum();
	value = value / self:GetRange();

	return value;
end;

