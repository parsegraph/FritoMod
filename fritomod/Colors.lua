-- A namespace for functions that deal with colors.

if nil ~= require then
	if not bit then
		if bit32 then
			bit = bit32;
		else
			require "bit"
		end;
	end

	require "fritomod/Metatables";
	require "fritomod/Math";
	require "fritomod/Lists";
	require "fritomod/Strings";
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
		color = Colors.PackHex(color[1], color[2], color[3]);
		if color[4] then
			color = Colors.ConvertOneHex(color[4]);
		else
			color = "ff"..color;
		end;
	end;
	if not string.find(color, "^[0-9a-fA-F]+$") then
		error(("Color is invalid: '%s'"):format(color));
	end;
	if #color == 6 then
		color = "ff"..color;
	else
		assert(#color == 8, "Color length is invalid: "..#color);
	end;
	return "|c" .. color .. message .. "|r";
end;
Colors.Colorize=Colors.ColorMessage;

function Colors.PackHex(colorParts, ...)
	local hexstring = "";
	if select("#", ...) > 0 then
		hexstring=Colors.ConvertOneHex(colorParts);
		for i=1, select("#", ...) do
			hexstring=hexstring..Colors.ConvertOneHex(select(i, ...));
		end;
	else
		for i=1, #colorParts do
			hexstring=hexstring..Colors.ConvertOneHex(colorParts);
		end;
	end;
	return hexstring;
end;

function Colors.ConvertOneHex(colorPart)
	local hexColor = Strings.ConvertToBase(16, math.floor(colorPart * 255));
	while #hexColor < 2 do
		hexColor = "0" .. hexColor;
	end;
	return hexColor;
end;

-- Unpacks the specified colorValue into its color value parts.
--
-- colorValue
--	 The color value that is to be unpacked
-- returns
--	 Unpacked color values, in ARGB order
function Colors.UnpackHex(colorValue)
	local alpha, red, green, blue = 0, 0, 0, 0;
	alpha = bit.rshift(bit.band(colorValue, 0xFF000000), 24) / 255;
	red   = bit.rshift(bit.band(colorValue, 0x00FF0000), 16) / 255;
	green = bit.rshift(bit.band(colorValue, 0x0000FF00),  8) / 255;
	blue  = bit.rshift(bit.band(colorValue, 0x000000FF),  0) / 255;
	return alpha, red, green, blue;
end;
