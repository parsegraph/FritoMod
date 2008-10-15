StringUtil = {};
local StringUtil = StringUtil;

StringUtil.DIGITS = "0123456789"
StringUtil.ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
StringUtil.ALPHANUMERICS = StringUtil.DIGITS .. StringUtil.ALPHABET;

-------------------------------------------------------------------------------
--
--  Naming Conversion Functions
--
-------------------------------------------------------------------------------
--
-- These functions allow intelligent conversion from ProperCase, snake_case, and
-- camelCase.
--
-- Observe that converting back and forth may sometimes be destructive. As a convention, 
-- don't convert from a previously converted string. If you have to, be sure that either 
-- the names don't contain potentially-harmful parts, or that yielding non-identical results
-- during multiple conversions will be harmless.
--
-- You'll avoid trouble for the most part by avoiding acronyms in your strings. For
-- example, 'aFooAPI' will be converted into 'a_foo_api', but converting 'a_foo_api'
-- back to camelCase yields 'aFooApi'. Be very aware of these differences when doing
-- your conversions.
--
-- Also be aware that these functions are _NOT_ idempotent. Converting 'a_foo_api' to
-- snake_case again will yield unpredictable results.

------------------------------------------
--  SplitByCase
------------------------------------------
-- 
-- Splits a camelCase'd or ProperCase'd string into lower-case words. Acronyms will be 
-- treated as single words.
--
-- Observe that camelCase's passed into this method will be parsed correctly; the list
-- returned will be {"camel", "Case"}
function StringUtil:SplitByCase(originalString)
    originalString = tostring(originalString);
    local words = {};
    string.gsub(originalString, "^(%l-)(%U*)$", function(initial, rest)
        table.insert(words, initial);
        originalString = rest;
    end)
    string.gsub(originalString , "(%U.*%l*)%U%l", function(word)
        table.insert(words, string.lower(word));
    end);
    table.insert(words, word);
    return words;
end;

------------------------------------------
--  SplitByDelimiter
------------------------------------------
-- 
-- Splits originalString by the given delimiter, with an underscore used as the default.
function StringUtil:SplitByDelimiter(originalString, delimiter)
    delimiter = delimiter or "_";
    return { string.split(delimiter, originalString) };
end;

------------------------------------------
--  String Joiners
------------------------------------------

function StringUtil:JoinProperCase(words)
    return ListUtil:Reduce(words, "", function(camelCase, word)
        return camelCase .. StringUtil:ProperNounize(word);
    end);
end;

function StringUtil:JoinCamelCase(words)
    local properString = StringUtil:JoinProperCase(words);
    return string.lower(string.sub(properString, 1, 1)) .. string.sub(properString, 2);
end;

function StringUtil:JoinSnakeCase(words)
    return string.join("_", words);
end;

------------------------------------------
--  ProperCase Converters
------------------------------------------

-- Converts AProperCase to aProperCase. 
function StringUtil:ProperToCamelCase(properString)
    return StringUtil:JoinCamelCase(StringUtil:SplitByCase(properString));
end;

-- Converts AProperCase to a_proper_case.
function StringUtil:ProperToSnakeCase(properString)
    return StringUtil:JoinSnakeCase(StringUtil:SplitByCase(properString));
end;

------------------------------------------
--  camelCase Converters
------------------------------------------

-- Converts aProperCase to AProperCase. 
function StringUtil:CamelToProperCase(camelString)
    return StringUtil:JoinProperCase(StringUtil:SplitByCase(camelString));
end;

-- Converts aProperCase to a_proper_case.
function StringUtil:CamelToSnakeCase(camelString)
    return StringUtil:JoinSnakeCase(StringUtil:SplitByCase(camelString));
end;

------------------------------------------
--  snake_case Converters
------------------------------------------

function StringUtil:SnakeToProperCase(snakeString)
    return StringUtil:JoinProperCase(StringUtil:SplitByDelimiter(snakeString));
end;

function StringUtil:SnakeToCamelString(snakeString)
    return StringUtil:JoinCamelCase(StringUtil:SplitByDelimiter(snakeString));
end;

function StringUtil:ProperNounize(word)
    word = tostring(word);
    return string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2));
end;

function StringUtil:ConvertToBase(base, number, digits)
    digits = digits or StringUtil.ALPHANUMERICS;
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

function StringUtil:Concat(...)
    return ListUtil:Reduce({...}, "", function(concatted, word)
        if #concatted > 0 then
            return concatted .. " " .. word;
        end;
        return word;
    end);
end;
