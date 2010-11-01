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
    -- Returns the "proper" button name for a given alias. This lets
    -- us use plenty of different names without needing to remember the 
    -- One True Way.
    function Frames.GetButtonName(button)
        assert(type(button)=="string", "Button name is not a string. Type: "..type(button));
        return buttons[button:lower()] or button;
    end;
end;

-- Registers the frame to be draggable. This uses Frames.GetButtonName, so buttons can
-- be specified freely.
--
-- local r=Frames.Draggable(f); -- f is now draggable with the left and right mouse buttons.
-- r(); -- f is no longer draggable.
--
-- -- Same as the above. Note that we don't have to use the remover here.
-- Frames.Draggable(f, true);
-- Frames.Draggable(f, false);
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
