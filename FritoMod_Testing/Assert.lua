Assert = {};
local Assert = Assert;

local function FormatName(assertion)
    if not assertion then
        return "";
    end;
    return format(" for assertion '%s'", tostring(assertion));
end;

local s = Strings.PrettyPrint;

function Assert.Exception(assertion, func, ...)
    assert(not pcall(func, ...), assertion);
end;

function Assert.Falsy(actual, assertion)
    assertion = FormatName(assertion);
    if not actual then
        return;
    end
    error(format("Value was not falsy%s, value was %s", assertion, s(actual)));
end;

function Assert.Nil(actual, assertion)
    assertion = FormatName(assertion);
    if actual == nil then
        return;
    end
    error(format("Value was not nil%s, value was %s", assertion, s(actual)));
end;

-- Returns whether the specified value is of the specified expected type.
--
-- expectedType
--     the string name of the expected type
-- value
--     the value that is tested. Its type will be compared against the expected type
-- assertion
--     the string that describes the reason why the types should be equal
function Assert.Type(expectedType, value, assertion)
    assertion = FormatName(assertion);
    assert(expectedType == type(value),
        format("Type mismatch%s, expected %s, got %s", assertion, s(expectedType), s(value)));
end;

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
--     describes the reason why these two tables should be equal
function Assert.SizesEqual(expectedSize, actual, assertion)
    assertion = FormatName(assertion);
    if type(expectedSize) == "table" then
        expectedSize = #expectedSize;
    end;
    assert(type(expectedSize) == "number", "expectedSize is not a number. Type: " .. type(expectedSize));
    assert(expectedSize >= 0, "expectedSize must be at least zero. expectedSize" .. s(expectedSize));
    Assert.Type("table", actual, assertion);
    if expectedSize ~= #actual then
        error(format("Size mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
    end;
end;

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
    local unformattedName = assertion;
    assertion = FormatName(assertion);
    if expected == actual then
        -- Short-circuit for the common case.
        return;
    end;
    if type(expected) ~= type(actual) then
        error(format("Type mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
    end;
    if type(expected) == "table" then
        if #expected ~= #actual then
            error(format("Size mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
        end;
        for k, v in pairs(expected) do
            Assert.Equals(expected[k], actual[k], unformattedName .. ": key " .. Strings.PrettyPrint(k));
        end;
        return;
    end;
    error(format("Equality mismatch%s, expected %s, got %s", assertion, s(expected), s(actual)));
end;
