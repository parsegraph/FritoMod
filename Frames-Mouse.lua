if nil ~= require then
    require "wow/Frame-Events";
    require "Functions";
    require "Callbacks-UI";
end;

Frames=Frames or {};

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
