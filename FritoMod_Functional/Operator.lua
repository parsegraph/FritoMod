if nil ~= require then
    require "FritoMod_Functional/basic";
end;

Operator = setmetatable({
    Equals = function(a, b) return a == b end,
    NotEquals = function(a, b) return a ~= b end,
    LessThan = function(a, b) return a < b end,
    GreaterThan = function(a, b) return a > b end,
    LessThanOrEqual = function(a, b) return a <= b end,
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
    ExclusiveRange = function(min, max, num) return min < num and num < max end,

    Add = function(a, b) return a + b end,
    Subtract = function(a, b) return a - b end,
    Multiply = function(a, b) return a * b end,
    Divide = function(a, b) return a / b end,

    True = function() return true end,
    False = function() return false end,

    Not = function(value) return not value end,
    Truth = function(value) return Bool(value) end
}, {
	__index = function(k,v)
		error("Operation not supported: " .. k);
	end
});
