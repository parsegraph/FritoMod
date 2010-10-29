if nil ~= require then
    require "wow/Frame-Layout";

    require "Functions";
    require "color";
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


function Frames.Square(f, size)
    return Frames.Rectangle(f, size, size);
end;
Frames.Squared=Frames.Square;

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

function Frames.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;

do
    local buttons={
        leftbutton="LeftButton",
        left="LeftButton",
        leftmouse="LeftButton",
        ["1"]="LeftButton",
        mouse1="LeftButton",

        rightbutton="LeftButton",
        right="RightButton",
        rightmouse="LeftButton",
        ["2"]="RightButton",
        mouse2="RightButton",

        middlebutton="MiddleButton",
        middle="MiddleButton",
        middlemouse="MiddleButton",
        ["3"]="MiddleButton",
        mouse3="MiddleButton",

        button4="Button4",
        ["4"]="Button4",
        mouse4="Button4",
        thumb="Button4",
        thumb1="Button4",
        side1="Button4",
        side="Button4",

        button5="Button5",
        ["5"]="Button5",
        mouse5="Button5",
        side2="Button4",
        thumb2="Button4",
    };
    function Frames.GetButtonName(button)
        assert(type(button)=="string", "Button name is not a string. Type: "..type(button));
        return buttons[button:lower()] or button;
    end;
end;

do 
    local function StartDrag(f, buttons)
        f:RegisterForDrag(unpack(buttons));
        f.dragRemover=Callbacks.DragFrame(f, Functions.Undoable(
            Seal(f, "StartMoving"),
            Seal(f, "StopMovingOrSizing")
        ));
    end;
    local function StopDrag(f)
        f:StopMovingOrSizing();
        f.dragRemover();
        f.dragRemover=nil;
        f:RegisterForDrag();
    end;
    function Frames.Draggable(f, ...)
        local buttons={...};
        if #buttons==0 then
            buttons={"LeftButton", "RightButton"};
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
                buttons[i]=Frames.GetButtonName(btn);
            end;
        end;
        StartDrag(f, buttons);
        return Functions.OnlyOnce(StopDrag, f);
    end;
end;
