if nil ~= require then
    require "wow/Frame-Events";
    require "Functions";
    require "Callbacks-UI";
end;

Frames=Frames or {};

do
    local buttons={
        leftbutton="LeftButton",
        left=      "LeftButton",
        leftmouse= "LeftButton",
        ["1"]=     "LeftButton",
        mouse1=    "LeftButton",

        rightbutton="RightButton",
        right=      "RightButton",
        rightmouse= "RightButton",
        ["2"]=      "RightButton",
        mouse2=     "RightButton",

        middlebutton="MiddleButton",
        middle=      "MiddleButton",
        middlemouse= "MiddleButton",
        ["3"]=       "MiddleButton",
        mouse3=      "MiddleButton",

        button4="Button4",
        ["4"]=  "Button4",
        mouse4= "Button4",
        thumb=  "Button4",
        thumb1= "Button4",
        side1=  "Button4",
        side=   "Button4",

        button5="Button5",
        ["5"]=  "Button5",
        mouse5= "Button5",
        side2=  "Button5",
        thumb2= "Button5",
    };
    -- Returns the "proper" button name for a given alias. This lets
    -- us use plenty of different names without needing to remember the 
    -- One True Way.
    function Frames.GetButtonName(button)
        button=tostring(button);
        return buttons[button:lower()] or button;
    end;
end;

-- Registers the frame to be draggable. This uses Frames.GetButtonName, so mouse buttons can
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
        f:SetMovable(true);
        f:RegisterForDrag(unpack(buttons));
        f.dragRemover=Callbacks.DragFrame(f, Functions.Undoable(
            Seal(f, "StartMoving"),
            Seal(f, "StopMovingOrSizing")
        ));
    end;
    local function StopDrag(f)
        f:StopMovingOrSizing();
        if f.dragRemover then
            f.dragRemover();
            f.dragRemover=nil;
        end;
        f:RegisterForDrag();
        f:SetMovable(false);
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
            return;
        else
            for i,btn in ipairs(buttons) do
                buttons[i]=Frames.GetButtonName(btn);
            end;
        end;
        StartDrag(f, buttons);
        return Functions.OnlyOnce(StopDrag, f);
    end;
end;

-- Allow dragging on a frame, similar to Frames.Draggable. The difference is that dragging
-- that occurs here is immediate - OnDragStart waits until a minimum threshold is exceeded,
-- meaning you need to "yank" a frame out of place to move it.
function Frames.InstantDraggable(f, ...)
    local buttons={...};
    local conditional;
    if type(buttons[1])=="function" or type(buttons[1])=="table" then
        conditional=Curry(...);
    else
        if #buttons==0 then
            buttons={"LeftButton", "RightButton"};
        else
            for i,btn in ipairs(buttons) do
                buttons[i]=Frames.GetButtonName(btn);
            end;
        end;
        conditional=function(button)
            return Lists.Contains(buttons, button, Strings.StartsWith);
        end;
    end;
    return Callbacks.MouseDown(f, function(button)
        if not conditional(button) then
            return;
        end;
        local startX, startY=select(4, f:GetPoint(1));
        return Callbacks.CursorOffset(function(x, y)
            f:SetPoint("center", UIParent, "center", startX+x, startY+y);
        end);
    end);
end;
