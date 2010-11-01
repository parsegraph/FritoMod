-- A bunch of colors for Media.color

if nil ~= require then
    require "Metatables";
    require "Strings";
    require "Colors";
    require "Media";
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

colors.white= {1.0, 1.0, 1.0, 1.0};
colors.black= {0.0, 0.0, 0.0, 1.0};
colors.blue=  {0.0, 0.0, 1.0, 1.0};
colors.orange={1.0, 0.5, 0.0, 1.0};
colors.yellow={1.0, 1.0, 0.0, 1.0};
colors.purple={1.0, 0.0, 1.0, 1.0};
colors.violet=colors.purple;

colors.warning=ConvertToTable(0xFFFF6347);
colors.error=  ConvertToTable(0xFFB22222)
colors.debug=  ConvertToTable(0xFFCD5C5C);
colors.message=ConvertToTable(0xFF6495ED);

if RED_FONT_COLOR then
    colors.red=BreakColorTable(RED_FONT_COLOR);
end;
if GREEN_FONT_COLOR then
    colors.green=BreakColorTable(GREEN_FONT_COLOR);
end;
if GRAY_FONT_COLOR then
    colors.gray=BreakColorTable(GRAY_FONT_COLOR);
    colors.grey=colors.gray;
end;

if MATERIAL_TEXT_COLOR_TABLE then
    for k,v in pairs(MATERIAL_TEXT_COLOR_TABLE) do
        colors[k] = v;
    end;
end;

if RAID_CLASS_COLORS then
    for className, classColor in pairs(RAID_CLASS_COLORS) do 
        colors[className]=BreakColorTable(classColor);
    end;
end;

if PowerBarColor then
    for name, color in pairs(PowerBarColor) do
        if not tonumber(name) then
            colors[name:gsub("_", " ")]=BreakColorTable(color);
        end;
    end;
end;

Media.color(colors);
Media.SetAlias("color", "colors", "colour", "colours");
