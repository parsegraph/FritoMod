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
        mouse1=    "LeftButton",

        rightbutton="RightButton",
        right=      "RightButton",
        rightmouse= "RightButton",
        mouse2=     "RightButton",

        middlebutton="MiddleButton",
        middle=      "MiddleButton",
        middlemouse= "MiddleButton",
        mouse3=      "MiddleButton",

        button4="Button4",
        mouse4= "Button4",
        thumb=  "Button4",
        thumb1= "Button4",
        side1=  "Button4",
        side=   "Button4",

        button5="Button5",
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
    function Frames.BlizzardDraggable(f, ...)
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

local function AdjustPoint(f)
    local center={f:GetCenter()};
    -- Remove scale for our points so they can be accurately compared.
    center[1]=  center[1]          *f:GetEffectiveScale();
    center[2]=  center[2]          *f:GetEffectiveScale();
    local right=UIParent:GetRight()*UIParent:GetEffectiveScale();
    local top=  UIParent:GetTop()  *UIParent:GetEffectiveScale();
    local possibilities={
        { 0,       0,     "bottomleft" },
        { right/2, 0,     "bottom" },
        { right,   0,     "bottomright" },
        { right,   top/2, "right" },
        { right,   top,   "topright" },
        { right/2, top,   "top" },
        { 0,       top,   "topleft" },
        { 0,       top/2, "left" },
        { right/2, top/2, "center" },
    };
    local best, bestDistance;
    for _, candidate in ipairs(possibilities) do
        local candidateDistance=Math.Distance(candidate, center);
        if bestDistance==nil or candidateDistance < bestDistance then
            bestDistance=candidateDistance;
            best=candidate;
        end;
    end;
    f:ClearAllPoints();
    f:SetPoint("center", UIParent, best[3], 
        (center[1]-best[1])/f:GetEffectiveScale(), 
        (center[2]-best[2])/f:GetEffectiveScale()
    );
end;

function Frames.ThresholdDraggable(f, threshold, ...)
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
        local startX, startY=f:GetCenter();
        local moving=false;
        local r=Callbacks.CursorOffset(f, function(x, y)
            if not moving and math.abs(x) > threshold or math.abs(y) > threshold then
                moving=true;
                f:ClearAllPoints();
                if f:GetParent() ~= UIParent then
                    -- Remove the local scale and re-add it once we've reparented. If we 
                    -- don't do this, startX and startY will use an out-of-date scale and
                    -- will cause the frame to "jump" once it's first moved.
                    startX=startX*f:GetEffectiveScale();
                    startY=startY*f:GetEffectiveScale();
                    f:SetParent(UIParent);
                    startX=startX/f:GetEffectiveScale();
                    startY=startY/f:GetEffectiveScale();
                end;
            end;
            if moving then
                f:SetPoint("center", UIParent, "bottomleft", startX+x, startY+y);
            end;
        end);
        return Functions.OnlyOnce(function()
            if moving then
                AdjustPoint(f);
            end;
            r();
        end);
    end);
end;

function Frames.InstantDraggable(f, ...)
    return Frames.ThresholdDraggable(f, 0, ...);
end;

function Frames.Draggable(f, ...)
    -- Type is dumb, so we have to include "or nil"
    if type(select(1, ...) or nil)=="number" then
        return Frames.ThresholdDraggable(f, ...);
    else
        return Frames.InstantDraggable(f, ...);
    end;
end;
