if nil ~= require then
    require "WoW_UI/Frame-Layout";

    require "FritoMod_Media/color";
end;

Frames={};

function Frames.Color(f,r,g,b,a)
    if tonumber(r) == nil then
        local possibleAlpha=g;
        r,g,b,a=unpack(Media.color[r]);
        if possibleAlpha then
            a=possibleAlpha;
        end;
    end;
    if not f.SetTexture then
        local t=f:CreateTexture();
        t:SetAllPoints();
        f=t;
    end;
    f:SetTexture(r,g,b,a);
end;
Frames.Colored=Frames.Color;
Frames.Solid=Frames.Color;
Frames.SolidColor=Frames.Color;


function Frames.Square(f, size)
    f:SetHeight(size);
    f:SetWidth(size);
end;

function Frames.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;
