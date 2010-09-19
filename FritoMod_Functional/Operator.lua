if nil ~= require then
    require "FritoMod_Functional/basic";
end;

Operator = setmetatable({
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

    Add =      function(a, b) return a + b end,
    Subtract = function(a, b) return a - b end,
    Multiply = function(a, b) return a * b end,
    Divide =   function(a, b) return a / b end,

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
