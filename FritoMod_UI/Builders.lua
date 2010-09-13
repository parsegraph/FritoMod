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
    f:SetTexture(r,g,b,a);
end;

function Builders.Square(f, size)
    f:SetHeight(size);
    f:SetWidth(size);
end;

function Builders.Centered(f, relative)
    f:SetPoint("CENTER", relative);
end;
