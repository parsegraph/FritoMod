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

function Colors.RGBtoHSV(c)
	local computedH = 0;
	local computedS = 0;
	local computedV = 0;

	local r, g, b = unpack(c);
	local minRGB = math.min(r,math.min(g,b));
	local maxRGB = math.max(r,math.max(g,b));
	local diff = maxRGB - minRGB;
	computedV = diff;

	-- Black-gray-white
	if diff == 0 then
		return {0,0,minRGB};
	end;

	if maxRGB == r then
		computedH = math.fmod((g - b)/diff, 6.0);
	elseif maxRGB == g then
		computedH = (b - r)/diff + 2.0;
	else
		computedH = (r - g)/diff + 4.0;
	end;
	computedH = computedH * 60;
	if computedH < 0 then
		computedH = computedH + 360;
	end;
	computedS = diff / maxRGB;
	return {computedH,computedS,computedV};
end;

function Colors.HSVtoRGB(orig)
	local h, s, v = unpack(orig);
	local c = v * s;
	local x = c * (1 - math.abs(math.fmod(h / 60, 2) - 1.0));
	local m = v - c;
	if h >= 0 and h < 60 then
		return {c+m, x+m, m};
	elseif h >= 60 and h < 120 then
		return {x+m, c+m, m};
	elseif h >= 120 and h < 180 then
		return {m, c+m, x+m};
	elseif h >= 180 and h < 240 then
		return {m, x+m, c+m};
	elseif h >= 240 and h < 300 then
		return {x+m, m, c+m};
	elseif h >= 300 and h < 360 then
		return {c+m, m, x+m};
	else
		return {m, m, m};
	end;
end;

function Colors.Mix(bg, fg, lerp)
	local hbg = Colors.RGBtoHSV(bg);
	local hfg = Colors.RGBtoHSV(fg);

	if hfg[3] == 0 then
		return Colors.HSVtoRGB({
			hbg[1], hbg[2], Math.mix(hbg[3], 0, lerp)
		});
	end;
	if hbg[3] == 0 then
		return Colors.HSVtoRGB({
			hfg[1], hfg[2], Math.mix(hfg[3], 0, 1-lerp)
		});
	end;
	if hfg[2] == 0 then
		return Colors.HSVtoRGB({
			hbg[1], Math.mix(hbg[2], 0, lerp), Math.mix(hbg[3], hfg[3], lerp)
		});
	end;
	if hbg[2] == 0 then
		return Colors.HSVtoRGB({
			hfg[1], Math.mix(hfg[2], 0, 1-lerp), Math.mix(hbg[3], hfg[3], 1-lerp)
		});
	end;
	local bgx = math.cos(math.pi * hbg[1] / 180);
	local bgy = math.sin(math.pi * hbg[1] / 180);
	local fgx = math.cos(math.pi * hfg[1] / 180);
	local fgy = math.sin(math.pi * hfg[1] / 180);

	local rx = Math.mix(bgx, fgx, lerp);
	local ry = Math.mix(bgy, fgy, lerp);
	local h = 180 * math.atan2(ry, rx) / math.pi;
	if h < 0 then
		h = 360 + h;
	end;
	--local h = Math.mix(hbg[1], hfg[1], lerp);
	dump("Mixed h", h);
	return Colors.HSVtoRGB({
		h,
		Math.mix(hbg[2], hfg[2], lerp),
		Math.mix(hbg[3], hfg[3], lerp),
	});
end;

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
