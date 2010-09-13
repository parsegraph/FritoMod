if nil ~= require then
    require "bit"

    require "FritoMod_Functional/Metatables";
    require "FritoMod_Math/Math";
    require "FritoMod_Collections/Lists";
    require "FritoMod_Strings/Strings";
end;

Colors = Metatables.Defensive();
local Colors = Colors;

function Colors.ColorMessage(color, message)
    if color == nil then
        return message;
    end;
    if type(color) == "string" and Media then
        local retrievedColor = Media.color[color];
        if retrievedColor then
            color = retrievedColor;
        end;
    end;
    if type(color) == "table" then
        color = Chat:GetColorString(color);
    end;
    if #color ~= 8 or not string.find(color, "^[0-9a-fA-F]+$") then
        error(("Color is invalid: '%s'"):format(color));
    end;
    return "|c" .. color .. message .. "|r";
end;

function Colors.PackHex(colorParts, ...)
    if select("#", ...) > 0 then
        colorParts = { colorParts, ... };
    end;
    return Strings.Join("", unpack(Lists.Map(colorParts, function(colorPart)
        local hexColor = ConvertToBase(16, math.floor(colorValue * 255));
        while #hexColor < 2 do
            hexColor = "0" .. hexColor;
        end;
        return hexColor;
    end)));
end;

-- Unpacks the specified colorValue into its color value parts.
--
-- colorValue
--     The color value that is to be unpacked
-- returns
--     Unpacked color values, in ARGB order
function Colors.UnpackHex(colorValue)
    local alpha, red, green, blue = 0, 0, 0, 0;
    alpha = bit.rshift(bit.band(colorValue, 0xFF000000), 24) / 255;
    red   = bit.rshift(bit.band(colorValue, 0x00FF0000), 16) / 255;
    green = bit.rshift(bit.band(colorValue, 0x0000FF00),  8) / 255;
    blue  = bit.rshift(bit.band(colorValue, 0x000000FF),  0) / 255;
    return alpha, red, green, blue;
end;
