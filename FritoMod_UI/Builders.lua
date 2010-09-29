if nil ~= require then
    require "WoW_UI/Frame-Layout";

    require "FritoMod_Media/color";
end;

-- Builders are simple methods for adding functionality to another object.
-- I chain them together as an array of headless methods and use Lists.Build
-- to construct my value. Here's an example:
--
-- local b=Builders;
-- local s={
--     Headless(b.Colored, "red"),
--     Headless(b.Square, 64),
--     Headless(b.Centered)
-- };
-- Lists.Build(s, UIParent:CreateTexture());
--
-- I feel like this is pretty useful. We don't get in the way of the
-- underlying API, since we never "own" the texture or wrap it in a
-- closed abstraction. 
--
-- The closure calling convention might throw people off, and it's redundant
-- information at any rate, so I made a HeadlessBuilders, which lets us do
-- the above in a much cleaner way:
--
-- local b=HeadlessBuilders;
-- local s={
--     b.Colored("red"),
--     b.Square(64),
--     b.Centered()
-- };
-- Lists.Build(s, UIParent:CreateTexture());
-- 
-- HeadlessBuilders is just a view over Builders, so we're not locking anyone
-- into one form or another.
--
-- I like that builders deal with very primitive objects. Builders can
-- be called directly, and they're very easy to understand. 
--
-- I like the "function-as-an-adjective" naming convention, since it's
-- easy to read. It also highlights that these methods are all related.
--
Builders=Builders or {};
HeadlessBuilders=setmetatable({}, {
    __newindex=function(self,k,v)
        Builders[k]=v;
    end,
    __index=function(self,k)
        return function(...)
            return Headless(Builders[k], ...);
        end
    end
});

function Builders.Colored(f,r,g,b,a)
    if type(r) == "string" and g == nil and b == nil and a == nil then
        r,g,b,a=unpack(Media.color[r]);
    end;
    if not f.SetTexture then
        local t=f:CreateTexture();
        t:SetAllPoints();
        f=t;
    end;
    f:SetTexture(r,g,b,a);
end;
Builders.Color=Builders.Colored;

function Builders.Square(f, size)
    f:SetHeight(size);
    f:SetWidth(size);
end;

function Builders.Centered(f, relative)
    if relative then
        f:SetPoint("CENTER", relative);
    else
        f:SetPoint("CENTER");
    end;
end;
Builders.Center=Builders.Centered;

function Builders.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Builders.Opacity=Builders.Alpha;
Builders.Visibility=Builders.Alpha;

do
    -- Right now, this only does a subset of the possible positions. I think I might change how I decompose here, since
    -- I don't like how ugly this ends up being.
    --
    -- Here's my thoughts on a better way:
    --
    -- * Flip anchors - two regions are arranged such that they are on opposite sides of some shared axis.
    -- * Stack, or Shared,  anchors - two regions are arranged such that they share a common anchor.
    -- * Center anchors - the working frame is arranged such that its center anchor is aligned to a reference point's anchor.
    --
    -- I think these are more descriptive, since they describe the common behavior, rather than being the currently
    -- very ambiguous names we use now (left, right, etc.)
    Builders.Left       =function(f,r,g) g=g or 0; if r then f:SetPoint("right",       r, "left",        -g,  0) end end;
    Builders.Right      =function(f,r,g) g=g or 0; if r then f:SetPoint("left",        r, "right",        g,  0) end end;
    Builders.Top        =function(f,r,g) g=g or 0; if r then f:SetPoint("bottom",      r, "top",          0,  g) end end;
    Builders.Bottom     =function(f,r,g) g=g or 0; if r then f:SetPoint("top",         r, "bottom",       0, -g) end end;
    Builders.TopLeft    =function(f,r,g) g=g or 0; if r then f:SetPoint("bottomright", r, "topleft",     -g,  g) end end;
    Builders.TopRight   =function(f,r,g) g=g or 0; if r then f:SetPoint("bottomleft",  r, "topright",     g,  g) end end;
    Builders.BottomLeft =function(f,r,g) g=g or 0; if r then f:SetPoint("topright",    r, "bottomleft",  -g, -g) end end;
    Builders.BottomRight=function(f,r,g) g=g or 0; if r then f:SetPoint("topleft",     r, "bottomright",  g, -g) end end;

    -- I really like aliases, but I dislike lots of repetition, so this code churns out a lot of aliases
    -- for our various directions.
    local cardinals={
        Left       = "West",
        Right      = "East",
        Top        = "North",
        Bottom     = "South",
        TopLeft    = "Northwest",
        TopRight   = "Northeast",
        BottomLeft = "Southwest",
        BottomRight= "Southeast"
    };

    for k,v in pairs(cardinals) do
        Builders[v]=Builders[k];
    end;
    for _, pat in ipairs({"To%s", "%sOf", "Align%s", "%sAligned"}) do
        for k,v in pairs(cardinals) do
            Builders[pat:format(k)]=Builders[k];
            Builders[pat:format(v)]=Builders[v];
        end;
    end;

    Builders.Above=Builders.Top;
    Builders.Beneath=Builders.Bottom;
    Builders.Below=Builders.Bottom;
end;
