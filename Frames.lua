-- A namespace of functions for frames.

if nil ~= require then
    require "wow/Frame-Layout";

    require "Functions";
    require "Media-Color";
end;

Frames={};

function Frames.Inject(f, ...)
    if type(f)=="string" then
        f=CreateFrame(f, ...);
    end;
    local mt=getmetatable(f).__index;
    f._injected=mt;
    assert(type(mt)=="table", "Frame is not injectable");
    setmetatable(f, {
        __index=function(self, k)
            return Frames[k] or Anchors[k] or mt[k];
        end
    });
    return f;
end;

function Frames.IsInjected(frame)
    return Bool(f._injected);
end;

local function CallOriginal(f, k, ...)
    if Frames.IsInjected(f) then
        return f._injected[k](f, ...);
    else
        return f[k](f, ...);
    end;
end;

function Frames.Child(frame, t, name, ...)
    local child=CreateFrame(t, name, frame, ...);
    if Frames.IsInjected(frame) then
        Frames.Inject(child);
    end;
    return child;
end;

-- Sets the color for a frame. This handles Frames, FontStrings, and 
-- Textures. The color can be a name, which will be retrieved using
-- Media.color
--
-- -- Sets frame to red.
-- Frames.Color(f, "red");
--
-- -- Sets frame to a half-transparent red.
-- Frames.Color(f, "red", .5);
function Frames.Color(f,...)
    local r,g,b,a;
    if select("#", ...)<3 then
        local color, possibleAlpha=...;
        r,g,b,a=unpack(Media.color[color]);
        if possibleAlpha then
            a=possibleAlpha;
        end;
    else
        r,g,b,a=...;
        a=a or 1.0;
    end;
    if tonumber(r) == nil then
        local possibleAlpha=g;
        if possibleAlpha then
            a=possibleAlpha;
        end;
    end;
    if f.GetBackdrop and f:GetBackdrop() then
        f:SetBackdropColor(r,g,b,a);
    elseif f.SetTextColor then
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

function Frames.BorderColor(f, r, g, b, a)
    if tonumber(r) == nil then
        local possibleAlpha=g;
        r,g,b,a=unpack(Media.color[r]);
        if possibleAlpha then
            a=possibleAlpha;
        end;
    end;
    f:SetBackdropBorderColor(r,g,b,a);
    return f;
end;
Frames.BackdropBorderColor=Frames.BorderColor;

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

function Frames.Text(parent, font, size, ...)
    local text;
    if type(parent) ~= "table" then
        text=parent;
        parent=UIParent:CreateFontString();
    end;
    if parent.CreateFontString then
        f=parent:CreateFontString();
    else
        f=parent;
    end;
    if not font:match("\\") then
        font=Media.font[font];
    end;
    f:SetFont(font, size, ...);
    if text then
        f:SetText(text);
    end;
    return f;
end;

function Frames.ButtonTexture(f, textureName)
    local texture;
    if type(textureName)=="string" or not textureName then
        texture=Media.button[textureName];
    else
        texture=textureName;
    end;
    if f:GetObjectType():find("Button$") then
        f:SetNormalTexture(texture.normal);
        f:SetPushedTexture(texture.pushed);
        f:SetHighlightTexture(texture.highlight);
        if f:GetObjectType():find("CheckButton$") then
            f:SetCheckedTexture(texture.checked);
            f:SetDisabledCheckedTexture(texture.disabledChecked);
        end;
    elseif f:GetObjectType() == "Texture" then
        f:SetTexture(texture.normal);
    else
        local t=f:CreateTexture();
        t:SetAllPoints();
        t:SetTexture(texture.normal);
        f=t;
    end;
    if texture.Finish then
        texture.Finish(f);
    end;
    return f;
end;
Frames.Button=Frames.ButtonTexture;

function Frames.Backdrop(f, backdrop, bg)
    if type(backdrop)=="string" or not backdrop then
        backdrop=Media.backdrop[backdrop];
    else
        backdrop=backdrop;
    end;
    if bg then
        local usedBackdrop=Tables.Clone(backdrop);
        usedBackdrop.bgFile=bg;
        backdrop=usedBackdrop;
    end;
    f:SetBackdrop(backdrop);
    return f;
end;

function Frames.Destroy(f)
    f:Hide();
    f:ClearAllPoints();
    f:SetParent(nil);
end;
