if nil ~= require then
    require "basic";
end;

Operator = setmetatable({
    -- Theoretically, these could operate over an arbitrary number of values. I
    -- haven't need to do so yet, so I'll leave this as-is until I do.
    Equals =             function(a, b) return a == b end,
    NotEquals =          function(a, b) return a ~= b end,
    LessThan =           function(a, b) return a <  b end,
    GreaterThan =        function(a, b) return a >  b end,
    LessThanOrEqual =    function(a, b) return a <= b end,
    GreaterThanOrEqual = function(a, b) return a >= b end,

	Compare = function(a,b)
		if a < b then
			return -1;
		end
		if a > b then
			return 1;
		end;
		return 0;
	end,

    InclusiveRange = function(min, max, num) return min <= num and num <= max end,
    ExclusiveRange = function(min, max, num) return min <  num and num <  max end,

    True =  function() return true end,
    False = function() return false end,

    Not = function(value) return not value end,
    Truth = function(value) return Bool(value) end

}, {
	__index = function(self, k,v)
		error("Operation not supported: " .. tostring(k));
	end
});
Operators=Operator;

-- These mathematical operations support working over many numbers. I made them
-- resilient in the face of nil values since they would otherwise require priming.
-- That is, you would have to check if a value was nil before using this function.
--
-- They also return a sensible value if no values are given. This is to ensure they
-- don't give themselves invalid data if reentered.
--
-- These aren't designed for speed, or for simplicity. If you need a simple math
-- function, my advice is to write it yourself. It should be noted that these will
-- all work as expected if only given two values.
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
Operator.Add=     Operation(function(a,b) return a+b end);
Operator.Subtract=Operation(function(a,b) return a-b end);
Operator.Multiply=Operation(function(a,b) return a*b end);
Operator.Divide=  Operation(function(a,b) return a/b end);
Operator.Modulo=  Operation(function(a,b) return a%b end);

-- I like aliases! Especially in a loosely typed language and in an environment where
-- we're not pressed for space, I prefer having lots of options rather than punishing
-- someone for not being me. Heck, even I use different names for the same operation.
Operator.Equal=Operator.Equals;
Operator.Is=Operator.Equals;

Operator.NotEqual=Operator.NotEquals;
Operator.Unequal=Operator.NotEquals;
Operator.IsNot=Operator.NotEquals;

Operator.LT=Operator.LessThan;
Operator.IsLess=Operator.LessThan;
Operator.IsLessThan=Operator.LessThan;

Operator.GT=Operator.GreaterThan;
Operator.IsGreater=Operator.GreaterThan;
Operator.IsGreaterThan=Operator.GreaterThan;

Operator.LTE=Operator.LessThanOrEqual;
Operator.LessThanEqual=Operator.LessThanOrEqual;
Operator.IsLessThanEqual=Operator.LessThanOrEqual;
Operator.LessThanEquals=Operator.LessThanOrEqual;
Operator.IsLessThanEquals=Operator.LessThanOrEqual;
Operator.LessThanOrEquals=Operator.LessThanOrEqual;
Operator.IsLessThanOrEquals=Operator.LessThanOrEqual;

Operator.GTE=Operator.GreaterThanOrEqual;
Operator.GreaterThanEqual=Operator.GreaterThanOrEqual;
Operator.IsGreaterThanEqual=Operator.GreaterThanOrEqual;
Operator.GreaterThanEquals=Operator.GreaterThanOrEqual;
Operator.IsGreaterThanEquals=Operator.GreaterThanOrEqual;
Operator.GreaterThanOrEquals=Operator.GreaterThanOrEqual;
Operator.IsGreaterThanOrEquals=Operator.GreaterThanOrEqual;

Operator.Plus=Operator.Add;
Operator.Addition=Operator.Add;

Operator.Less=Operator.Subtract;
Operator.Minus=Operator.Subtract;
Operator.Subtraction=Operator.Subtract;

Operator.Times=Operator.Multiply;
Operator.Multiplication=Operator.Multiply;

Operator.Division=Operator.Divide;

for k,v in pairs(Operator) do
    Operator[k:lower()]=v;
end;
