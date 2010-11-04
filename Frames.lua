-- A namespace of functions for frames.

if nil ~= require then
    require "wow/Frame-Layout";

    require "Functions";
    require "Media-Color";
end;

Frames={};

-- Sets the color for a frame. This handles Frames, FontStrings, and 
-- Textures. The color can be a name, which will be retrieved using
-- Media.color
--
-- -- Sets frame to red.
-- Frames.Color(f, "red");
--
-- -- Sets frame to a half-transparent red.
-- Frames.Color(f, "red", .5);
function Frames.Color(f,r,g,b,a)
    if tonumber(r) == nil then
        local possibleAlpha=g;
        r,g,b,a=unpack(Media.color[r]);
        if possibleAlpha then
            a=possibleAlpha;
        end;
    end;
    if f.SetTextColor then
        f:SetTextColor(r,g,b,a);
    elseif f.SetTexture then
        f:SetTexture(r,g,b,a);
    elseif f.CreateTexture then
        local t=f:CreateTexture();
        t:SetAllPoints();
        t:SetTexture(r,g,b,a);
        f=t;
    end;
    return f;
end;
Frames.Colored=Frames.Color;
Frames.Solid=Frames.Color;
Frames.SolidColor=Frames.Color;

-- Sets the size of the specified frame.
function Frames.Square(f, size)
    return Frames.Rectangle(f, size, size);
end;
Frames.Squared=Frames.Square;

-- Sets the dimensions for the specified frame.
function Frames.Rectangle(f, w, h)
    if h==nil then
        return Frames.Square(f, w);
    end;
    f:SetWidth(w);
    f:SetHeight(h);
end;
Frames.Rect=Frames.Rectangle;
Frames.Rectangular=Frames.Rectangle;
Frames.Size=Frames.Rectangle;

-- Sets the alpha for a frame. 
--
-- You don't need to use this function: we have it here when we use
-- Frames as a headless table.
function Frames.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;
