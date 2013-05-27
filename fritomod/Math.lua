if nil ~= require then
	require "fritomod/Lists";
end;

Math = Math or {};

function Math.IsReal(value)
	-- This odd-looking boolean will return false for
	-- non-real values, such as 1/0 and 0/0 (which will
	-- return false for any numeric comparision, including
	-- 0/0 == 0/0.
	return value < 0 or value > 0 or value == 0;
end;

function Math.Round(value)
    local fractional = value % 1;
    if fractional >= .5 then
        return math.ceil(value)
    end;
    return math.floor(value);
end;

local function CheckRange(min, value, max)
	assert(type(min) == "number", "min must be a number");
	assert(type(value) == "number", "value must be a number");
	assert(type(max) == "number", "value must be a number");
	assert(min <= max, "min must be less than max");
end;

function Math.Clamp(min, value, max)
	CheckRange(min, value, max);
	if value < min then
		value = min;
	end;
	if value > max then
		value = max;
	end
	return value;
end;

function Math.Modulo(min, value, max)
	CheckRange(min, value, max);
	value = value - min;
	local range = max - min;
	return min + value % range;
end;

function Math.Percent(min, value, max)
	CheckRange(min, value, max);
	value = value - min;
	local range = max - min;
	return value / range;
end;

function Math.Interpolate(min, value, max)
	assert(type(min) == "number", "min must be a number");
	assert(type(value) == "number", "value must be a number");
	assert(type(max) == "number", "value must be a number");
	local range = max - min;
	return min + (range * value);
end;

function Math.Distance(...)
	local x1, y1, x2, y2 = ...;
	if select("#", ...) == 2 then
		local point, otherPoint = select(1, ...), select(2, ...);
		x1, y1 = unpack(point);
		x2, y2 = unpack(otherPoint);
	end;
	return Math.Hypotenuse(x2 - x1, y2 - y1);
end;

function Math.Hypotenuse(a, b)
	return math.sqrt(math.pow(a, 2) + math.pow(b, 2));
end;

function Math.Mean(values, ...)
	if select("#", ...) ~= 0 or type(values) ~= "table" then
		return Math.Mean({values, ...});
	end;
	local sum = Lists.Reduce(values, 0, Operator.Add);
	return sum / #values;
end;
Math.Average = Math.Mean;

function Math.Signum(number)
	if number > 0 then
		return 1;
	end;
	if number < 0 then
		return -1;
	end;
	return 0;
end;
