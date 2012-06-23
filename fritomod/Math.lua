if nil ~= require then
	require "fritomod/Lists";
end;

Math = Math or {};

function Math.Distance(...)
	local x1, y1, x2, y2 = ...;
	if select("#", ...) == 2 then
		local point, otherPoint = select(1, ...), select(2, ...);
		x1, y1 = unpack(point);
		x2, y2 = unpack(otherPoint);
	end;
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
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
