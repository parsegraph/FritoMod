local s = Strings.PrettyPrint;

Assert = {};
local Assert = Assert;

local function FormatName(assertion)
    if not assertion then
        return "";
    end;
    return format(" for assertion '%s'", tostring(assertion));
end;

-- Asserts that the specified function fails. The return value or exception message
-- is ignored.
--
-- assertion:string
--     the reason why the function should raise an exception
-- func, ...
--     the function that is tested
function Assert.Exception(assertion, func, ...)
    assert(not pcall(func, ...), assertion);
end;

-- Asserts that the specified function runs successfully. Its return value
-- is ignored.
--
-- assertion:string
--     the reason why the function should run successfully
-- func, ...
--     the function that is tested
function Assert.Success(assertion, func, ...)
    assert(pcall(func, ...), assertion);
end;

-- Asserts that the specified value is truthy. Specifically, it asserts that the specified
-- value is neither nil nor false.
--
-- actual:*
--     the tested value
-- assertion
--     the reason why the specified value should be truthy
function Assert.Truthy(actual, assertion)
    assertion = FormatName(assertion);
    assert(actual, format("Value was not truthy%s, value was %s", assertion, s(actual)));
end;

-- Asserts that the specified value is falsy. Specifically, it asserts that the specified
-- value is either nil or false.
--
-- actual:*
--     the tested value
-- assertion
--     the reason why the specified value should be falsy
function Assert.Falsy(actual, assertion)
    assertion = FormatName(assertion);
    assert(not actual, format("Value was not falsy%s, value was %s", assertion, s(actual)));
end;

-- Asserts that the specified value is nil.
--
-- actual:*
--     the tested value
-- assertion:string
--     optional. the reason why the tested value must be nil
function Assert.Nil(actual, assertion)
    assertion = FormatName(assertion);
    assert(nil == actual, format("Value was not nil%s, value was %s", assertion, s(actual)));
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
        format("Type mismatch%s, expected %s, got %s", assertion, s(expectedType), s(value)));
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
        format("Identity mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
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
        format("Size mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
end;

-- Asserts that the two tables contain equal values for each key.
--
-- Equivalence is determined by Assert.Equals
--
-- expected:table
--     the control table
-- actual:table
--     the tested table
-- assertion:string
--     optional. describes why the two tables should be equal
function Assert.TablesEqual(expected, actual, assertion)
    if expected == actual then
        -- Short-circuit for the common case.
        return;
    end;
    Assert.SizesEqual(expected, actual, assertion);
    for k, v in pairs(expected) do
        Assert.Equals(expected[k], actual[k], assertion .. ": key " .. s(k));
    end;
end;

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
