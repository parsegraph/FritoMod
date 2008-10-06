StringUtil = {};
local StringUtil = StringUtil;

StringUtil.DIGITS = "0123456789"
StringUtil.ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
StringUtil.ALPHANUMERICS = DIGITS .. ALPHABET;

function StringUtil:ProperNounize(name)
    name = tostring(name);
    return strupper(strsub(name, 1, 1)) .. strlower(strsub(name, 2));
end;

function StringUtil:ConvertToBase(base, number, digits)
    digits = digits or StringUtil:ALPHANUMERICS;
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
	local message = "";
	for i=1, select("#", ...) do
        local part = tostring(select(i, ...));
        if #message then
            message = format("%s %s", message, part);
        else
            message = part;
        end;
	end
	return message;
end;

