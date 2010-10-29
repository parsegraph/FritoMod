if nil ~= require then
    require "FritoMod_Functional/Metatables";

    require "FritoMod_Strings/Strings";
end;

local s = Strings.Pretty;

Assert = Metatables.Defensive();
local Assert = Assert;

local function FormatName(assertion)
    if not assertion then
        return "";
    end;
	if Strings.StartsWith(" for assertion '", assertion) then
		return assertion;
	end;
    return (" for assertion '%s'"):format(tostring(assertion));
end;

local function DoCall(objOrFunc, ...)
	if IsCallable(objOrFunc) then
		return pcall(objOrFunc, ...);
	else
		assert(type(objOrFunc)=="table", "Exception must be passed a callable, or a table");
		local f=objOrFunc[select(1,...)];
		assert(IsCallable(f), 
			"Exception's passed object must contain a callable value for key: " .. tostring(select(1, ...)));
		return pcall(f, objOrFunc, select(2, ...));
	end;
end;

-- Asserts that the specified function fails. The return value or exception message
-- is ignored.
--
-- assertion:string
--     the reason why the function should raise an exception
-- func, ...
--     the function that is tested
function Assert.Exception(assertion, ...)
	local r;
	if type(assertion) ~= "string" then
		r=DoCall(assertion, ...);
		assertion=nil;
	else
		r=DoCall(...);
	end;
	assert(not r, ("Function must raise an exception%s"):format(FormatName(assertion)));
end;

Assert.Failure = Assert.Exception;
Assert.Fails = Assert.Exception;
Assert.Throws = Assert.Exception;
Assert.Raises = Assert.Exception;
Assert.RaisesException = Assert.Exception;

-- Asserts that the specified function runs successfully. Its return value
-- is ignored.
--
-- assertion:string
--     the reason why the function should run successfully
-- func, ...
--     the function that is tested
function Assert.Success(assertion, ...)
	local r,m;
	if type(assertion) ~= "string" then
		r,m=DoCall(assertion, ...);
		assertion=nil;
	else
		r,m=DoCall(...);
	end;
    assert(r, ("Function must be successful%s, but failed with result %q"):format(
        FormatName(assertion), tostring(m)));
end;

Assert.Successful = Assert.Success;
Assert.Succeeds = Assert.Success;
Assert.Succeed = Assert.Success;

-- Asserts that the specified value is truthy. Specifically, it asserts that the specified
-- value is neither nil nor false.
--
-- actual:*
--     the tested value
-- assertion
--     the reason why the specified value should be truthy
function Assert.Truthy(actual, assertion)
    assertion = FormatName(assertion);
    assert(actual, ("Value was not truthy%s, value was %s"):format(assertion, s(actual)));
end;
Assert.True=Assert.Truthy;
Assert.Yes=Assert.Truthy;

-- Asserts that the specified value is falsy. Specifically, it asserts that the specified
-- value is either nil or false.
--
-- actual:*
--     the tested value
-- assertion
--     the reason why the specified value should be falsy
function Assert.Falsy(actual, assertion)
    assertion = FormatName(assertion);
    assert(not actual, ("Value was not falsy%s, value was %s"):format(assertion, s(actual)));
end;
Assert.False=Assert.Falsy;
Assert.No=Assert.Falsy;
Assert.Not=Assert.Falsy;

-- Asserts that the specified value is nil.
--
-- actual:*
--     the tested value
-- assertion:string
--     optional. the reason why the tested value must be nil
function Assert.Nil(actual, assertion)
    assertion = FormatName(assertion);
    assert(nil == actual, ("Value was not nil%s, value was %s"):format(assertion, s(actual)));
end;

function Assert.NotNil(actual, assertion)
    assertion = FormatName(assertion);
    assert(nil ~= actual, ("Value must be non-nil, but was nil anyway%s"):format(assertion, s(actual)));
end;

-- Asserts that the specified value is of the specified expected type.
--
-- expectedType
--     the string name of the expected type
-- value
--     the value that is tested. Its type will be compared against the expected type
-- assertion:string
--     optional. the string that describes the reason why the types should be equal
function Assert.Type(expectedType, value, assertion)
    assert(type(expectedType) == "string", "expectedType must be a string value");
    assertion = FormatName(assertion);
    assert(expectedType == type(value),
        ("Type mismatch%s, expected %s, got %s"):format(assertion, s(expectedType), s(value)));
end;

function Assert.Number(value, assertion)
    if type(value)=="number" then
        return;
    end;
    assertion = FormatName(assertion);
    assert(tonumber(value), ("%s value must be a number, but was not%s. Value was: "..tostring(value)):format(type(value), assertion));
end;

-- Asserts that the specified actual value is identical(==) to the specified expected value.
--
-- expected:*
--     the control value
-- actual:*
--     the tested value
-- assertion:string
--     optional. describes the reason why the specified values are identical
function Assert.Identical(expected, actual, assertion)
    Assert.Type(type(expected), actual, assertion);
    assertion = FormatName(assertion);
    assert(expected == actual,
        ("Identity mismatch%s, expected %s, got %s"):format(assertion, s(expected), s(actual)));
end;

-- Asserts that the size of the specified actual list is equal to the expected size.
--
-- expectedSize:number, table
--     indicates the expected size of the table, or could be a table whose size will be used
--     as the control
-- actual:table
--     the value that is tested
-- assertion:string
--     optional. describes the reason why these two tables should be equal
function Assert.SizesEqual(expectedSize, actual, assertion)
    assertion = FormatName(assertion);
    if type(expectedSize) == "table" then
        expectedSize = #expectedSize;
    end;
    assert(type(expectedSize) == "number", "expectedSize is not a number. Type: " .. type(expectedSize));
    assert(expectedSize >= 0, "expectedSize must be at least zero. expectedSize" .. s(expectedSize));
    Assert.Type("table", actual, assertion);
    assert(expectedSize == #actual,
        ("Size mismatch%s, expected %s, got %s"):format(assertion, s(expectedSize), s(actual)));
end;

Assert.SizeEqual = Assert.SizesEqual;
Assert.Size = Assert.SizesEqual;
Assert.Sizes = Assert.SizesEqual;
Assert.EqualSizes = Assert.SizesEqual;
Assert.EqualSize = Assert.SizesEqual;

function Assert.Empty(actual, assertion)
    assertion = FormatName(assertion);
    Assert.Type("table", actual, assertion);
    assert(0 == #actual, ("Table must be empty%s"):format(assertion));
end;

-- Asserts that the two tables contain equal values for each key.
--
-- Tables are equal if:
--  * they contain the same keys, determined by identity(==)
--  * they contain equal(Assert.Equals) values for identical keys
--  * they contain no keys not contained by the other
--
-- expected:table
--     the control table
-- actual:table
--     the tested table
-- assertion:string
--     optional. describes why the two tables should be equal
function Assert.TablesEqual(expected, actual, assertion)
    assert(type(expected) == "table", "expected is not a table. Type: " .. type(expected));
    if assertion ~= nil then
        assert(type(assertion) == "string", "Assertion string is not a string. Type: " .. type(assertion));
    else
        assertion = "Tables are equal";
    end;
    if expected == actual then
        -- Short-circuit for the common case.
        return;
    end;
    Assert.SizesEqual(expected, actual, assertion);
    local keysInExpected = {};
    for k, v in pairs(expected) do
        keysInExpected[k] = true;
        local actualValue = actual[k];
        assert(actualValue ~= nil, ("Missing key '%s' in table%s"):format(s(k), FormatName(assertion)));
        Assert.Equals(expected[k], actual[k], assertion .. ": key " .. s(k));
    end;
    for k, _ in pairs(actual) do
        assert(keysInExpected[k], ("Unexpected key '%s' in table%s"):format(s(k), FormatName(assertion)));
    end;
end;

-- Asserts that the two values are equal. 
--
-- The method of testing for equivalence depends on the expected value:
--  * If the expected value is a table and it has an __eq method, identity(==) is used
--  * If the expected value is a table, then Assert.TablesEqual is used
--  * All other values are compared using identity(==)
--
-- expected:*
--     the expected value
-- actual:*
--     the actual value
-- assertion:string
--     optional. describes why the two values should be equivalent
function Assert.Equals(expected, actual, assertion)
    if expected == actual then
        -- Short-circuit for the common case.
        return;
    end;
    if type(expected) == "table" then
        Assert.TablesEqual(expected, actual, assertion);
        return;
    end;
    Assert.Identical(expected, actual, assertion);
end;
Assert.Same=Assert.Equals
Assert.Equal=Assert.Equals

function Assert.NotEquals(control,variable,assertion)
	assert(not pcall(Assert.Equals, control, variable), 
		("Values must not be equal '%s'%s"):format(s(control), FormatName(assertion)));
end;
Assert.NotEqual=Assert.NotEquals
Assert.Unequal=Assert.NotEquals
Assert.Unequals=Assert.NotEquals
Assert.Different=Assert.NotEquals
