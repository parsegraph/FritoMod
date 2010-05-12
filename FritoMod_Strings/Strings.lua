if nil ~= require then
    require "FritoMod_Functional/basic";

    require "FritoMod_Collections/Lists";
    require "FritoMod_Collections/Tables";
    
    require "FritoMod_OOP/OOP";
end;

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

function Strings.StartsWith(match, str)
	assert(type(match) == "string", "match must be a string");
	assert(#match > 0, "match must contain at least one character");
	return match==str:sub(1, #match);
end;

function Strings.EndsWith(match, str)
	assert(type(match) == "string", "match must be a string");
	assert(#match > 0, "match must contain at least one character");
	return match==str:sub(#str-#match+1);
end;

function Strings.PrettyPrint(value)
    if value == nil then
        return "<nil>";
    end;
    local valueType = Strings.ProperNounize(type(value));
    if valueType == "Table" then
        if OOP.IsClass(value) then
            return ("Class@%s"):format(Reference(value));
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
    assert(type(value) == "function", "value is not a function. Type: " .. type(value));
    local name = Tables.KeyFor(_G, value);
    if not name then
        name = Reference(value);
    end
    return ("Function@%s"):format(name);
end;

function Strings.PrettyPrintNamedNumber(number, itemName, pluralName)
    if not pluralName then
        pluralName = itemName .. "s";
    elseif not Strings.StartsWith(pluralName, itemName) then
        pluralName = itemName + pluralName;
    end;
    local numberString = Strings.PrettyPrintNumber(number);
    if number == 1 then
        return ("%s %s"):format(numberString, itemName);
    end;
    return ("%s %s"):format(numberString, pluralName);
end;

function Strings.PrettyPrintList(value)
    assert(type(value) == "table", "value is not a table. Type: " .. type(value));
    local size = #value;
    if size == 0 then
        return "[<empty>]";
    end;
    local size = Strings.PrettyPrintNamedNumber(Strings.PrettyPrintNumber(size), "item");
    local contents = Lists.Map(value, Strings.PrettyPrint);
    return ("[<%s> %s]"):format(size, Strings.Join(", ", contents));
end;

function Strings.PrettyPrintMap(value)
    assert(type(value) == "table", "value is not a table. Type: " .. type(value));
    local size = Tables.Size(value);
    if size == 0 then
        return "{<empty>}";
    end;
    size = Strings.PrettyPrintNamedNumber(Strings.PrettyPrintNumber(size), "item");
    local contents = Tables.MapPairs(value, function(key, value)
        return ("%s = %s"):format(Strings.PrettyPrint(key), Strings.PrettyPrint(value));
    end);
    return ("[<%s> %s]"):format(size, Strings.Join(", ", contents));
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
    return ('"%s"'):format(value);
end;

function Strings.Join(delimiter, items)
    assert(delimiter ~= nil, "delimiter is nil");
    delimiter = tostring(delimiter);
    return Lists.Reduce(items, "", function(concatted, word)
        word = tostring(word);
        if #word == 0 then
            return concatted;
        end;
        if #concatted > 0 then
            return concatted .. delimiter  .. word;
        end;
        return word;
    end);
end

function Strings.JoinValues(delimiter, ...)
    return Strings.Join(delimiter, { ... });
end

-- Splits originalString by the given delimiter.
--
-- delimiter:regex
--     a pattern indicating what defines the "split" characters
-- limit:number
--     optional. the final number of strings that should be returned
-- returns:list
--     a list of strings, split by the specified delimiter
function Strings.SplitByDelimiter(delimiter, originalString, limit)
	assert(delimiter ~= nil, "delimiter must be provided");
	assert(delimiter ~= "", "delimiter must not be an empty string");
    delimiter = tostring(delimiter);
	assert(originalString ~= nil, "originalString must be provided");
    local remainder = tostring(originalString);
    local items = {};
    while limit == nil or #items + 1 < limit do
        local startMatch, endMatch = remainder:find(delimiter);
        if not startMatch then
            break;
        end;
        if startMatch > 1 then
            Lists.Insert(items, remainder:sub(1, startMatch - 1));
        end;
        remainder = remainder:sub(endMatch + 1);
    end;
    if #remainder > 0 then
        table.insert(items, remainder);
    end;
    if #items == 0 then
        Lists.Insert(items, "");
    end;
    return items;
end;


-- Removes leading and trailing whitespace from the specified string.
--
-- str:string
--     the string that is the target of this operation
-- returns:string
--     the specified string without leading or trailing whitespace
function Strings.Trim(str)
    str = str:sub(str:find("[^ ]") or #str);
    return str:sub(1, (str:find("[ ]*$" or 1)-1) or #str);
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

    -- These are forward declared to avoid bad references in our closures.
    local InitialState, Capturing, PotentialAcronym, Acronym;

    Capturing = function(letter)
        if not Strings.IsUpper(letter) then
            return;
        end;
        -- To hopefully explain the indices we use here, take a look at this picture:
        -- "MatchFoo...
        --   ..21^
        -- 
        -- We're at the 'F'. The end of the previous word is one index back, so we're at
        -- the start of the new word.
        Lists.Insert(words, target:sub(1, index - 1));
        target = target:sub(index);
        
        -- Set it to one since we've already iterated the first element. Otherwise, we'll
        -- mistakenly think we're in an acronym.
        index = 1;
        return PotentialAcronym;
    end;

    Acronym = function(letter)
        if not Strings.IsLower(letter) then
            return;
        end;
        -- To hopefully explain the indices we use here, take a look at this picture:
        -- "MATCHFoo...
        --   ...21^
        -- 
        -- We're at the 'o', but the end of the previous word is two indices back. The
        -- start of this word is one step back.
        Lists.Insert(words, target:sub(1, index - 2));
        target = target:sub(index - 1);
        
        -- Set it to one since we've already iterated the first element. 
        index = 1;
        return Capturing;
    end;

    PotentialAcronym = function(letter)
        if Strings.IsUpper(letter) then
            return Acronym;
        end;
        return Capturing;
    end;

    InitialState = function(letter)
        if Strings.IsUpper(letter) then
            return PotentialAcronym;
        end;
        return Capturing;
    end;

    local state = InitialState;
    while index <= #target do
        index = index + 1;
        local letter = Strings.CharAt(target, index);
		local newState = state(letter);
		state = newState or state;
    end;
    if #target > 0 then
        table.insert(words, target);
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
    return Strings.JoinProperCase(Strings.SplitByDelimiter("_", snakeString));
end;

-- Converts a_proper_case to aProperCase
function Strings.SnakeToCamelCase(snakeString)
    return Strings.JoinCamelCase(Strings.SplitByDelimiter("_", snakeString));
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
    local isNegative = number < 0;
    number = abs(number);
    local converted = "";
    while number > 0 do
        local place = (number % base) + 1;
        number = math.floor(number / base);
        converted = Strings.CharAt(digits, place) .. converted;
    end
    if #converted == 0 then
        converted = Strings.CharAt(digits, 1);
    end;
    if isNegative then
        converted = "-" .. converted;
    end;
    return converted;
end
