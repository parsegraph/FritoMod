if nil ~= require then
	require "fritomod/currying";
	require "fritomod/basic";
end;

Operator = setmetatable({

	Compare = function(a,b)
		if a < b then
			return -1;
		end
		if a > b then
			return 1;
		end;
		return 0;
	end,

	True =  function() return true end,
	False = function() return false end,

	Not = function(value) return not value end,
	Truth = function(value) return Bool(value) end,
}, {
	__index = function(self, k,v)
		error("Operation not supported: " .. tostring(k));
	end
});
Operators=Operator;
Op=Operator;

function Operator.Nil(...)
	for i=1, select("#", ...) do
        if select(i, ...) ~= nil then
            return false;
        end;
    end;
    return true;
end;

function Operator.NotNil(...)
    if select("#", ...) == 0 then
        return true;
    end;
	for i=1, select("#", ...) do
        if select(i, ...) == nil then
            return false;
        end;
    end;
    return true;
end;

function Operator.Multiple(constant, ...)
	for i=1, select("#", ...) do
		if select(i, ...) % constant ~= 0 then
			return false;
		end;
	end;
	return true;
end;

function Operator.NotMultiple(constant, ...)
	for i=1, select("#", ...) do
		if select(i, ...) % constant == 0 then
			return false;
		end;
	end;
	return true;
end;

Operator.Even=Curry(Operator.Multiple, 2);
Operator.Odd=Curry(Operator.NotMultiple, 2);

function Operator.InclusiveRange(min, max, ...)
	for i=1, select("#", ...) do
		local v=select(i, ...);
		if v < min or v > max then
			return false;
		end;
	end;
	return true;
end;

function Operator.ExclusiveRange(min, max, ...)
	for i=1, select("#", ...) do
		local v=select(i, ...);
		if v <= min or v >= max then
			return false;
		end;
	end;
	return true;
end;

-- These mathematical operations support working over many numbers. I made them
-- resilient in the face of nil values since they would otherwise require
-- priming.  That is, you would have to check if a value was nil before using
-- this function.
--
-- They also return a sensible value if no values are given. This is to ensure
-- they don't give themselves invalid data if reentered.
--
-- These aren't designed for speed, or for simplicity. If you need a simple
-- math function, my advice is to write the simple function yourself. It should
-- be noted that these will all work as expected if only given two values.
local function Operation(op)
	return function(...)
		local total;
		for i=1,select("#", ...) do
			local v=select(i, ...);
			if total==nil then
				total=v;
			elseif v ~= nil then
				total=op(total, v);
			end;
		end;
		return total;
	end;
end;
Operator.Add=	 Operation(function(a,b) return a+b end);
Operator.Subtract=Operation(function(a,b) return a-b end);
Operator.Multiply=Operation(function(a,b) return a*b end);
Operator.Divide=  Operation(function(a,b) return a/b end);
Operator.Modulo=  Operation(function(a,b) return a%b end);

local function ComparingOperation(op)
	return function(constant, ...)
		for i=1,select("#", ...) do
			local v=select(i, ...);
			if not op(constant, v) then
				return false;
			end;
		end;
		return true;
	end;
end;

Operator.Equals			 = ComparingOperation(function(a,b) return a == b end);
Operator.NotEquals		  = ComparingOperation(function(a,b) return a ~= b end);
Operator.GreaterThan		= ComparingOperation(function(a,b) return a <  b end);
Operator.GreaterThanOrEqual = ComparingOperation(function(a,b) return a <= b end);
Operator.LessThan		   = ComparingOperation(function(a,b) return a >  b end);
Operator.LessThanOrEqual	= ComparingOperation(function(a,b) return a >= b end);

-- I like aliases! Especially in a loosely typed language and in an environment where
-- we're not pressed for space, I prefer having lots of options rather than punishing
-- someone for not being me. Heck, even I use different names for the same operation.
Operator.Equal=Operator.Equals;
Operator.Is=Operator.Equals;
Operator.E=Operator.Equals;

Operator.NotEqual=Operator.NotEquals;
Operator.Unequal=Operator.NotEquals;
Operator.Not=Operator.NotEquals;
Operator.NE=Operator.NotEquals;

Operator.LT=Operator.LessThan;
Operator.Less=Operator.LessThan;

Operator.GT=Operator.GreaterThan;
Operator.Greater=Operator.GreaterThan;

Operator.LTE=Operator.LessThanOrEqual;
Operator.LessThanEqual=Operator.LessThanOrEqual;
Operator.LessThanEquals=Operator.LessThanOrEqual;
Operator.LessThanOrEquals=Operator.LessThanOrEqual;

Operator.GTE=Operator.GreaterThanOrEqual;
Operator.GreaterThanEqual=Operator.GreaterThanOrEqual;
Operator.GreaterThanEquals=Operator.GreaterThanOrEqual;
Operator.GreaterThanOrEquals=Operator.GreaterThanOrEqual;

Operator.Plus=Operator.Add;
Operator.Addition=Operator.Add;

Operator.Less=Operator.Subtract;
Operator.Minus=Operator.Subtract;
Operator.Subtraction=Operator.Subtract;

Operator.Times=Operator.Multiply;
Operator.Multiplication=Operator.Multiply;

Operator.Division=Operator.Divide;

for k,v in pairs(Operator) do
	Operator["Is"..k]=v;
	Operator[k:lower()]=v;
end;
