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
