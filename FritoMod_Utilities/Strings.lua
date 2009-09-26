Strings = {};
local Strings = Strings;

Strings.DIGITS = "0123456789"
Strings.ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
Strings.ALPHANUMERICS = Strings.DIGITS .. Strings.ALPHABET;

function Strings.Matches(pattern, candidate)
    candidate = tostring(candidate);
    return Bool(candidate:find(pattern));
end;

function Strings.Join(delimiter, items)
   local length = getn(list);
   if length == 0 then 
      return "";
   end;
   local joined = list[1];
   for i = 2, len do 
      joined = joined .. delimiter .. list[i] ;
   end;
   return joined;
end

-- Splits a camelCase'd or ProperCase'd string into lower-case words. Acronyms will be 
-- treated as single words.
--
-- Observe that camelCase's passed into this method will be parsed correctly; the list
-- returned will be {"camel", "Case"}
function Strings.SplitByCase(originalString)
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

-- Splits originalString by the given delimiter, with an underscore used as the default.
function Strings.SplitByDelimiter(originalString, delimiter)
    delimiter = delimiter or "_";
    return { string.split(delimiter, originalString) };
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
    return string.join("_", words);
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
