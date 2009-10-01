Strings = {};
local Strings = Strings;

Strings.DIGITS = "0123456789"
Strings.ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
Strings.ALPHANUMERICS = Strings.DIGITS .. Strings.ALPHABET;

function Strings.Matches(pattern, candidate)
    candidate = tostring(candidate);
    return Bool(candidate:find(pattern));
end;

function Strings.IsLetter(letter)
    letter = tostring(letter);
    return Bool(letter:find("^%a*$"));
end;

function Strings.IsNumber(letter)
    letter = tostring(letter);
    return Bool(letter:find("^%d*$"));
end;

function Strings.IsUpper(word)
    if word:lower() == word:upper() then
        -- It contains no upper or lower-case values, so
        -- it's neither upper nor lower case.
        return false;
    end;
    return word:upper() == word;
end;

function Strings.IsLower(word)
    if word:lower() == word:upper() then
        -- It contains no upper or lower-case values, so
        -- it's neither upper nor lower case.
        return false;
    end;
    return word:lower() == word;
end;

function Strings.CharAt(str, index)
    return str:sub(index, index);
end;

function Strings.PrettyPrint(value)
    if value == nil then
        return "<nil>";
    end;
    local valueType = Strings.ProperNounize(type(value));
    if valueType == "Table" then
        if OOP.IsClass(value) then
            return format("Class@%s", Tables.Reference(value));
        end;
        if OOP.IsInstance(value) then
            return value:ToString();
        end;
        if #value > 0 then
            return Strings.PrettyPrintList(value);
        end
        return Strings.PrettyPrintMap(value);
    end;
    local prettyPrinter = Strings["PrettyPrint" .. valueType];
    assert(prettyPrinter, "prettyPrinter not available for type. Type: " .. valueType);
    return prettyPrinter(value);
end;

function Strings.PrettyPrintFunction(value)
    assert(type(value) == "table", "value is not a table. Type: " .. type(value));
    local name = Tables.LookupValue(value) or Tables.Reference(value);
    return format("Function@%s", name);
end;

function Strings.PrettyPrintNamedNumber(number, itemName, pluralName)
    if not pluralName then
        pluralName = itemName .. "s";
    elseif not Strings.StartsWith(pluralName, itemName) then
        pluralName = itemName + pluralName;
    end;
    local numberString = Strings.PrettyPrintNumber(number);
    if number == 1 then
        return format("%s %s", numberString, itemName);
    end;
    return format("%s %s", numberString, pluralName);
end;

function Strings.PrettyPrintList(value)
    assert(type(value) == "table", "value is not a table. Type: " .. type(value));
    local size = #value;
    if size == 0 then
        return "[<empty>]";
    end;
    local size = Strings.PrettyPrintNamedNumber(Strings.PrettyPrintNumber(size), "item");
    local contents = Lists.Map(value, Strings.PrettyPrint);
    return format("[<%s> %s]", size, Strings.Join(", ", contents));
end;

function Strings.PrettyPrintMap(value)
    assert(type(value) == "table", "value is not a table. Type: " .. type(value));
    local size = Tables.Size(value);
    if size == 0 then
        return "{<empty>}";
    end;
    size = Strings.PrettyPrintNamedNumber(Strings.PrettyPrintNumber(size), "item");
    local contents = Tables.MapPairs(value, function(key, value)
        return format("%s = %s", Strings.PrettyPrint(key), Strings.PrettyPrint(value));
    end);
    return format("[<%s> %s]", size, Strings.Join(", ", contents));
end;

function Strings.PrettyPrintNumber(value)
    local number = tonumber(value);
    if not number then
        return "<NaN>";
    end
    -- TODO Make this add commas
    return tostring(number);
end;

function Strings.PrettyPrintBoolean(value)
    return Strings.ProperNounize(Bool(value));
end;

function Strings.PrettyPrintString(value)
    value = tostring(value);
    return format('"%s"', value);
end;

function Strings.Join(delimiter, items)
    assert(delimiter ~= nil, "delimiter is nil");
    delimiter = tostring(delimiter);
    if #items == 0 then 
        return "";
    end;
    local joined = items[1];
    for i = 2, #items do 
        joined = joined .. delimiter .. items[i];
    end;
    return joined;
end

-- Splits originalString by the given delimiter, with an underscore used as the default.
function Strings.SplitByDelimiter(delimiter, originalString)
    if originalString == nil then
        delimiter, originalString = "_", delimiter;
    end;
    delimiter = delimiter or "_";
    return Lists.Filter({ strsplit(delimiter, originalString) }, function(value)
        return value ~= "";
    end);
end;

-- Splits a camelCase'd or ProperCase'd string into lower-case words. Acronyms will be 
-- treated as single words.
--
-- Observe that camelCase's passed into this method will be parsed correctly; the list
-- returned will be {"camel", "Case"}
function Strings.SplitByCase(target)
    assert(target ~= nil, "target is nil");
    target = tostring(target);
    local words = {};
    local index = 0;

    -- These are forward declared to avoid problems later on. This may not be necessary.
    local Capturing, PotentialAcronym, Acronym;

    function Capturing(letter, index)
        if not Strings.IsUpper(letter) then
            return;
        end;
        Lists.Insert(words, target:sub(1, index - 1));
        target = target:sub(index);
        index = 0;
        return PotentialAcronym;
    end;

    function PotentialAcronym(letter, index)
        if Strings.IsUpper(letter) then
            return Acronym;
        end;
        return Capturing;
    end;

    function InitialState(letter, index)
        if Strings.IsUpper(letter) then
            return PotentialAcronym;
        end;
        return Capturing;
    end;

    local state = InitialState;
    while index <= #target do
        index = index + 1;
        local letter = Strings.CharAt(target, index);
        state = state(letter, index) or state;
    end;
    if #target > 0 then
        Lists.Insert(words, target);
    end;

    return words;
end;

function Strings.JoinProperCase(words)
    return Lists.Reduce(words, "", function(camelCase, word)
        return camelCase .. Strings.ProperNounize(word);
    end);
end;

function Strings.JoinCamelCase(words)
    local properString = Strings.JoinProperCase(words);
    return string.lower(string.sub(properString, 1, 1)) .. string.sub(properString, 2);
end;

function Strings.JoinSnakeCase(words)
    return Strings.Join("_", words):lower();
end;

-- Converts AProperCase to aProperCase. 
function Strings.ProperToCamelCase(properString)
    return Strings.JoinCamelCase(Strings.SplitByCase(properString));
end;

-- Converts AProperCase to a_proper_case.
function Strings.ProperToSnakeCase(properString)
    return Strings.JoinSnakeCase(Strings.SplitByCase(properString));
end;

-- Converts aProperCase to AProperCase. 
function Strings.CamelToProperCase(camelString)
    return Strings.JoinProperCase(Strings.SplitByCase(camelString));
end;

-- Converts aProperCase to a_proper_case.
function Strings.CamelToSnakeCase(camelString)
    return Strings.JoinSnakeCase(Strings.SplitByCase(camelString));
end;

-- Converts a_proper_case to AProperCase
function Strings.SnakeToProperCase(snakeString)
    return Strings.JoinProperCase(Strings.SplitByDelimiter(snakeString));
end;

-- Converts a_proper_case to aProperCase
function Strings.SnakeToCamelCase(snakeString)
    return Strings.JoinCamelCase(Strings.SplitByDelimiter(snakeString));
end;

function Strings.ProperNounize(word)
    word = tostring(word);
    return string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2));
end;

function Strings.ConvertToBase(base, number, digits)
    digits = digits or Strings.ALPHANUMERICS;
    if base > #digits or base < 2 then
        error("Invalid base: " .. base);
    end;
    local converted = "";
    while number > 0 do
        local place = (number % base) + 1;
        number = math.floor(number / base);
        converted = string.sub(digits, place, place) .. converted;
    end
    return converted;
end

function Strings.Concat(...)
    return Lists.Reduce({...}, "", function(concatted, word)
        word = tostring(word);
        if #concatted > 0 then
            return concatted .. " " .. word;
        end;
        return word;
    end);
end;
