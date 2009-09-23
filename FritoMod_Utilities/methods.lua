-- A collection of miscellaneous methods that haven't found a home elsewhere.

-- Unpacks the specified colorValue into its color value parts.
--
-- colorValue
--     The color value that is to be unpacked
-- returns
--     Unpacked color values, in ARGB order
function UnpackColor(colorValue)
    local alpha, red, green, blue = 0, 0, 0, 0;
    alpha = bit.rshift(bit.band(colorValue, 0xFF000000), 24) / 255;
    red   = bit.rshift(bit.band(colorValue, 0x00FF0000), 16) / 255;
    green = bit.rshift(bit.band(colorValue, 0x0000FF00),  8) / 255;
    blue  = bit.rshift(bit.band(colorValue, 0x000000FF),  0) / 255;
    return alpha, red, green, blue;
end;
