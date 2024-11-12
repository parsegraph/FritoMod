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
	assert(type(min) == "number", "Range min must be a number");
	assert(type(value) == "number", "Range value must be a number");
	assert(type(max) == "number", "Range max must be a number");
    if min > max then
        error("Range minimum (" .. tostring(min) .. ") must be less than its"
        .. "maximum (" .. tostring(max) .. ")");
    end;
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
    if min == max then
        error("Minimum value (" .. tostring(min) .. ") must not be equal to its maximum value (" .. tostring(max) .. ")");
    end;
	value = value - min;
	local range = max - min;
	return value / range;
end;
Math.Percentage = Math.Percent;

function Math.Interpolate(min, pct, max)
    if type(min) == "table" and type(max) == "table" then
        local interpolated = {};
        for i=1, math.max(#max, #min) do
            interpolated[i] = Math.Interpolate(
                min[i] or max[i],
                pct,
                max[i] or min[i]
            );
        end;
        return interpolated;
    end;
	assert(type(min) == "number", "min must be a number");
	assert(type(pct) == "number", "pct must be a number");
	assert(type(max) == "number", "value must be a number");
	local range = max - min;
	return min + (range * pct);
end;

function Math.Mix(min, max, lerp)
    return Math.Interpolate(min, lerp, max);
end;
Math.mix = Math.Mix;

function Math.Distance(...)
	local x1, y1, x2, y2 = ...;
	if select("#", ...) == 2 then
		local point, otherPoint = select(1, ...), select(2, ...);
		x1, y1 = unpack(point);
		x2, y2 = unpack(otherPoint);
	end;
	return Math.Hypotenuse(x2 - x1, y2 - y1);
end;

if pcall(load, "return 2^2") then
    Math.Hypotenuse = load("return function(a, b) return math.sqrt(a ^ 2 + b ^ 2); end")();
else
    Math.Hypotenuse = function(a, b)
        return math.sqrt(math.pow(a, 2) + math.pow(b, 2));
    end;
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

Math.max = math.max;
Math.Max = math.max;

Math.min = math.min;
Math.Min = math.min;
