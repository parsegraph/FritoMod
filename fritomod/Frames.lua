-- A namespace of functions for frames.

if nil ~= require then
    require "wow/Frame-Layout";

    require "fritomod/Functions";
    require "fritomod/Media-Color";
end;

Frames=Frames or {};

function Frames.Inject(frame)
    if Frames.IsInjected(frame) then
        return;
    end;
    local mt=getmetatable(frame).__index;
    frame._injected=mt;
    assert(type(mt)=="table", "Frame is not injectable");
    setmetatable(frame, {
        __index=function(self, k)
            return Frames[k] or Anchors[k] or mt[k];
        end
    });
    return frame;
end;

function Frames.IsInjected(frame)
    return Bool(frame._injected);
end;

local function CallOriginal(frame, name, ...)
    if Frames.IsInjected(frame) then
        return frame._injected[name](frame, ...);
    else
        return frame[name](frame, ...);
    end;
end;

function Frames.Child(frame, t, name, ...)
    local child=CreateFrame(t, name, frame, ...);
    if Frames.IsInjected(frame) then
        Frames.Inject(child);
    end;
    return child;
end;

-- Sets the size of the specified frame.
function Frames.Square(f, size)
    return Frames.Rectangle(f, size, size);
end;
Frames.Squared=Frames.Square;

function Frames.DumpPoints(f)
    for i=1,f:GetNumPoints() do
        print(f:GetPoint(i));
    end;
end;

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

local INSETS_ZERO={
    left=0,
    top=0,
    bottom=0,
    right=0
};
function Frames.Insets(f)
    if f.GetBackdrop then
        local b=f:GetBackdrop();
        if b then
            return b.insets;
        end;
    end;
    return INSETS_ZERO;
end;

-- Sets the alpha for a frame. 
--
-- You don't need to use this function: we have it here when we use
-- Frames as a headless table.
function Frames.Alpha(f, alpha)
    f:SetAlpha(alpha);
end;
Frames.Opacity=Frames.Alpha;
Frames.Visibility=Frames.Alpha;

function Frames.Show(f)
    CallOriginal(f, "Show");
    return Functions.OnlyOnce(CallOriginal, f, "Hide");
end;

function Frames.Hide(f)
    CallOriginal(f, "Hide");
    return Functions.OnlyOnce(CallOriginal, f, "Show");
end;

function Frames.ToggleShowing(f)
    if f:IsVisible() then
        f:Hide();
    else
        f:Show();
    end;
end;
Frames.ToggleVisibility=Frames.ToggleShowing;
Frames.ToggleVisible=Frames.ToggleShowing;
Frames.ToggleShown=Frames.ToggleShowing;
Frames.ToggleShow=Frames.ToggleShowing;
Frames.ToggleHide=Frames.ToggleShowing;
Frames.ToggleHidden=Frames.ToggleShowing;

function Frames.Destroy(f)
    f:Hide();
    f:ClearAllPoints();
    f:SetParent(nil);
end;
