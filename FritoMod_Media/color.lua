if nil ~= require then
    require "FritoMod_Functional/Metatables";
    require "FritoMod_Strings/Strings";
    require "FritoMod_Chat/Colors";

    require "FritoMod_Media/Media";
end;

Media.color = setmetatable({}, {
    __index = function(self, k)
        if type(k) == "string" then
            return rawget(self, k:lower());
        end;
        return rawget(self, "default");
    end,

    __newindex = function(self,k,v)
        if type(k) == "string" then
            k = k:lower();
        end;
        rawset(self,k,v);
    end
});

local function BreakColorTable(table)
    return {table.a or 1.0, table.r, table.g, table.b};
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
    return { alpha, red, green, blue };
end;

Media.color.white={1.0, 1.0, 1.0, 1.0};
Media.color.black={1.0, 0.0, 0.0, 0.0};
Media.color.blue={1.0, 0.0, 0.0, 1.0};
Media.color.yellow={1.0, 1.0, 1.0, 0.0};

Media.color.warning=ConvertToTable(0xFFFF6347);
Media.color.error=ConvertToTable(0xFFB22222)
Media.color.debug=ConvertToTable(0xFFCD5C5C);
Media.color.message=ConvertToTable(0xFF6495ED);

if RED_FONT_COLOR then
    Media.color.red=BreakColorTable(RED_FONT_COLOR);
end;
if GREEN_FONT_COLOR then
    Media.color.green=BreakColorTable(GREEN_FONT_COLOR);
end;
if GRAY_FONT_COLOR then
    Media.color.gray=BreakColorTable(GRAY_FONT_COLOR);
end;

if MATERIAL_TEXT_COLOR_TABLE then
    for k,v in pairs(MATERIAL_TEXT_COLOR_TABLE) do
        Media.color[k] = v;
    end;
end;

if RAID_CLASS_COLORS then
    for className, classColor in pairs(RAID_CLASS_COLORS) do 
        Media.color[className]=BreakColorTable(classColor);
    end;
end;
