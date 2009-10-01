Assert = {};
local Assert = Assert;

local function FormatName(name)
    if not name then
        return "";
    end;
    return format(" for assertion '%s'", tostring(name));
end;

local s = Strings.PrettyPrint;

function Assert.Exception(name, func, ...)
    assert(not pcall(func, ...), name);
end;

function Assert.Falsy(actual, name)
    name = FormatName(name);
    if not actual then
        return;
    end
    error(format("Value was not falsy%s, value was %s", name, s(actual)));
end;

function Assert.Nil(actual, name)
    name = FormatName(name);
    if actual == nil then
        return;
    end
    error(format("Value was not nil%s, value was %s", name, s(actual)));
end;

function Assert.Equals(expected, actual, name)
    local unformattedName = name;
    name = FormatName(name);
    if expected == actual then
        -- Short-circuit for the common case.
        return;
    end;
    if type(expected) ~= type(actual) then
        error(format("Type mismatch%s, expected %s, got %s", name, s(expected), s(actual)));
    end;
    if type(expected) == "table" then
        if #expected ~= #actual then
            error(format("Size mismatch%s, expected %s, got %s", name, s(expected), s(actual)));
        end;
        for k, v in pairs(expected) do
            Assert.Equals(expected[k], actual[k], unformattedName .. ": key " .. Strings.PrettyPrint(k));
        end;
        return;
    end;
    error(format("Equality mismatch%s, expected %s, got %s", name, s(expected), s(actual)));
end;
