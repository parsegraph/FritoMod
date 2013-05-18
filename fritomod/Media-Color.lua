-- A bunch of colors for Media.color

if nil ~= require then
	require "fritomod/Metatables";
	require "fritomod/Strings";
	require "fritomod/Colors";
	require "fritomod/Media";

	require "wow/api/colors";
	require "wow/Texture";
end;

local colors=setmetatable({}, {
	__index = function(self, k)
		if type(k) == "string" then
			return rawget(self, k:lower());
		elseif IsCallable(k) then
			return self[k()];
		end;
	end,
	__newindex = function(self,k,v)
		if type(k) == "string" then
			k = k:lower();
		end;
		rawset(self,k,v);
	end
});

local function BreakColorTable(table)
	return {table.r, table.g, table.b, table.a or 1.0};
end;

local function ConvertToTable(alpha, ...)
	if select("#", ...) == 0 then
		return { Colors.UnpackHex(alpha) };
	end;
	local red, green, blue = 0, 0, 0;
	if select("#", ...) == 2 then
		red = alpha;
		green, blue = ...;
		alpha = 1.0;
	else
		red, green, blue = ...;
	end;
	return {red, green, blue, alpha};
end;

--            {r,   g,    b,   a  };
colors.white= {1.0, 1.0,  1.0, 1.0};
colors.black= {0.0, 0.0,  0.0, 1.0};
colors.blue=  {0.0, 0.0,  1.0, 1.0};
colors.orange={1.0, 0.5,  0.0, 1.0};
colors.yellow={1.0, 1.0,  0.0, 1.0};
colors.pink  ={1.0, 0.0,  1.0, 1.0};
colors.purple={0.5, 0.0,  1.0, 1.0};
colors.maroon={0.5, 0.0,  0.0, 1.0};
colors.marroon=colors.maroon;
colors.cyan = {0.0, 1.0,  1.0, 1.0};
colors.gold  ={1.0, 0.82, 0.0, 1.0}; -- This is the yellow/gold color Blizzard uses in text.
colors.violet=colors.purple;

colors.magenta = {1.0, 0.0, 1.0, 1.0};
colors.fuchsia = colors.magenta;
colors.fushia  = colors.magenta;

colors.alliance = {.3, .3, 1};
colors.horde = {1, .2, .2};

colors.warning=ConvertToTable(0xFFFF6347);
colors.error=  ConvertToTable(0xFFB22222)
colors.debug=  ConvertToTable(0xFFCD5C5C);
colors.message=ConvertToTable(0xFF6495ED);

if RED_FONT_COLOR then
	colors.red=BreakColorTable(RED_FONT_COLOR);
else
	colors.red = {1.0, 0.0, 0.0, 1.0};
end;
if GREEN_FONT_COLOR then
	colors.green=BreakColorTable(GREEN_FONT_COLOR);
else
	colors.green = {0.0, 1.0, 0.0, 1.0};
end;

if GRAY_FONT_COLOR then
	colors.gray=BreakColorTable(GRAY_FONT_COLOR);
else
	colors.gray = {0.5, 0.5, 0.5, 1.0};
end;
colors.grey=colors.gray;

if RAID_CLASS_COLORS then
	for className, classColor in pairs(RAID_CLASS_COLORS) do
		colors[className]=BreakColorTable(classColor);
	end;
end;
colors.pally  = colors.paladin;
colors.shammy = colors.shaman;
colors.lock   = colors.warlock;
colors.warr   = colors.warrior;

colors["death knight"] = colors.deathknight;
colors.dk              = colors.deathknight;

if PowerBarColor then
	for name, color in pairs(PowerBarColor) do
		if not tonumber(name) then
			colors[name:gsub("_", " ")]=BreakColorTable(color);
		end;
	end;
end;

colors.default=colors.white;
Media.color(colors);

do
	local schoolColors;
	Media.color(function(name)
		if type(name) ~= "string" then
			return;
		end;
		if not COMBATLOG_DEFAULT_COLORS then
			return;
		end;
		if not schoolColors then
			schoolColors = {};
			for school, schoolColor in pairs(COMBATLOG_DEFAULT_COLORS.schoolColoring) do
				schoolColors[CombatLog_String_SchoolString(school):lower()] =
					BreakColorTable(schoolColor);
			end;
		end;
		return schoolColors[name:lower()];
	end);
end;

Media.color(function(grayShade)
	if tonumber(grayShade) then
		grayShade=tonumber(grayShade);
		return {grayShade, grayShade, grayShade, 1.0};
	end;
end);

Media.color(function(color)
	if type(color)=="table" then
		return color;
	end;
end);

Media.SetAlias("color", "colors", "colour", "colours");

Frames=Frames or {};

local function GetColor(...)
	local r,g,b,a;
	if select("#", ...)<3 then
		local color, possibleAlpha=...;
		r,g,b,a=unpack(Media.color[color]);
		if possibleAlpha then
			a=possibleAlpha;
		end;
	else
		r,g,b,a=...;
		a=a or 1.0;
	end;
	if tonumber(r) == nil then
		local possibleAlpha=g;
		if possibleAlpha then
			a=possibleAlpha;
		end;
	end;
	return r,g,b,a;
end;

-- Sets the color for a frame. This handles Frames, FontStrings, and
-- Textures. The color can be a name, which will be retrieved using
-- Media.color
--
-- -- Sets frame to red.
-- Frames.Color(f, "red");
--
-- -- Sets frame to a half-transparent red.
-- Frames.Color(f, "red", .5);
function Frames.Color(f,...)
	f=Frames.AsRegion(f);
	local r,g,b,a = GetColor(...);
	if f.SetTextColor then
		f:SetTextColor(r,g,b,a);
	elseif f.SetTexture then
		f:SetTexture(r,g,b,a);
	elseif f.CreateTexture then
		local t = nil;
		local regions = {f:GetRegions()};
		for _, region in ipairs(regions) do
			if region.__colored then
				t=region;
				break;
			end;
		end;
		if not t then
			t=f:CreateTexture();
		end;
		Anchors.ShareAll(t);
		t:SetTexture(r,g,b,a);
		t.__colored = true;
		f=t;
	else
		error("Frame must support color setting");
	end;
	return f;
end;
Frames.Colored=Frames.Color;
Frames.Solid=Frames.Color;
Frames.SolidColor=Frames.Color;

function Frames.BorderColor(f, ...)
	f=Frames.AsRegion(f);
	local r,g,b,a = GetColor(...);
	assert(f.SetBackdropBorderColor,
		"Provided object does not support backdrop border colors");
	f:SetBackdropBorderColor(r,g,b,a);
	return f;
end;
Frames.BackdropBorderColor=Frames.BorderColor;

function Frames.BackdropColor(f, ...)
	f=Frames.AsRegion(f);
	local r,g,b,a = GetColor(...);
	assert(f.SetBackdropColor,
		"Provided object does not support backdrop colors");
	f:SetBackdropColor(r,g,b,a);
	return f;
end;

-- vim: set noet :
