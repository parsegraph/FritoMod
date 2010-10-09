if nil ~= require then
    require "WoW_UI/Frame-Layout";

    require "FritoMod_Functional/Functions";
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
    return Frames.Rectangle(f, size, size);
end;
Frames.Squared=Frames.Square;

function Frames.Rectangle(f, w, h)
    f:SetWidth(w);
    f:SetHeight(h);
end;
Frames.Rect=Frames.Rectangle;
Frames.Rectangular=Frames.Rectangle;
Frames.Size=Frames.Rectangle;

function Frames.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;

do 
    local buttons={
        left="LeftButton",
        leftmouse="LeftButton",
        ["1"]="LeftButton",
        mouse1="LeftButton",

        right="RightButton",
        rightmouse="LeftButton",
        ["2"]="RightButton",
        mouse2="RightButton",

        middle="MiddleButton",
        middlemouse="MiddleButton",
        ["3"]="MiddleButton",
        mouse3="MiddleButton",

        ["4"]="Button4",
        mouse4="Button4",
        thumb="Button4",
        thumb1="Button4",
        side1="Button4",
        side="Button4",

        ["5"]="Button5",
        mouse5="Button5",
        side2="Button4",
        thumb2="Button4",
    };
    local function StartDrag(f, buttons)
        f:EnableMouse(true);
        f:RegisterForDrag(unpack(buttons));
        f:SetScript("OnDragStart", f.StartMoving);
        f:SetScript("OnDragStop", f.StopMovingOrSizing);
    end;
    local function StopDrag(f)
        f:EnableMouse(false);
        f:RegisterForDrag();
        f:StopMovingOrSizing();
        f:SetScript("OnDragStart", nil);
        f:SetScript("OnDragStop", nil);
    end;
    function Frames.Draggable(f, ...)
        local buttons={...};
        if #buttons==0 then
            buttons={"LeftButton"};
        elseif #buttons==1 and type(buttons[1])=="boolean" then
            if buttons[1] then
                StartDrag(f, {"LeftButton"});
            else
                StopDrag(f);
            end;
        else
            for i,btn in ipairs(buttons) do
                if type(btn)~="string" then
                    btn=tostring(btn);
                end;
                buttons[i]=buttons[btn:lower()] or btn:lower();
            end;
        end;
        StartDrag(f, buttons);
        return Functions.OnlyOnce(StopDrag, f);
    end;
end;
