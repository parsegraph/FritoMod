if nil ~= require then
    require "wow/Frame-Layout";
end;

Anchors={};

local function GetAnchorArguments(frame, ...)
    local anchor, ref, x, y;
    if type(select(1, ...)) == "string" then
        if type(select(2, ...))=="number" then
            anchor, x, y=...;
        else
            anchor, ref, x, y=...;
        end;
    else
        ref, anchor, x, y=...;
    end;
    anchor=anchor:lower();
    if ref == nil then
        ref=frame:GetParent();
    end;
    return anchor, ref, x, y;
end;

local function FlipAnchor(name, reverses, signs, defaultSigns)
    for k,v in pairs(reverses) do
        reverses[v]=k;
    end;

    local function Gap(anchor, x, y)
        if not x then
            x=0;
        end;
        local sign=assert(signs[anchor], "Unrecognized anchor name: "..anchor);
        local sx, sy=unpack(sign);
        if not y then
            y=x;
            local defaults;
            if #defaultSigns > 0 then
                defaults=defaultSigns;
            else
                defaults=defaultSigns[anchor];
            end;
            sx, sy = defaults[1] * sx, defaults[2] * sy;
        end;
        return sx * x, sy * y;
    end;
    Anchors[name.."Gap"] = Gap;

    local function Flip(frame, ...)
        local anchor, ref, x, y=GetAnchorArguments(frame, ...);
        frame:SetPoint(reverses[anchor], ref, anchor, Gap(anchor, x, y));
    end

    Anchors[name.."Flip"]     = Flip;
    Anchors[name.."Flipping"] = Flip;
    Anchors[name.."Flipped"]  = Flip;
    Anchors[name.."Over"]     = Flip;
end;

-- Anchors.HorizontalFlip(f, "topright", ref);
-- +---+---+
-- |   | f |
-- |ref|---+
-- |   |
-- +---+
-- 
-- Anchors.HorizontalFlip(f, "right", ref);
-- +---+
-- |   |---+
-- |ref| f |
-- |   |---+
-- +---+
-- 
-- Anchors.HorizontalFlip(f, "bottomright", ref);
-- +---+
-- |   |
-- |ref|---+
-- |   | f |
-- +---+---+
--
-- Anchors.HorizontalFlip(f, "topleft", ref);
-- +---+---+
-- | f |   |
-- +---|ref|
--     |   |
--     +---+
--
-- Anchors.HorizontalFlip(f, "left", ref);
--     +---+
-- +---|   |
-- | f |ref|
-- +---|   |
--     +---+
-- 
-- Anchors.HorizontalFlip(f, "bottomleft", ref);
--     +---+
--     |   |
-- +---|ref|
-- | f |   |
-- +---+---+
FlipAnchor("Horizontal", {
        topleft    = "topright",
        bottomleft = "bottomright",
        left       = "right",
    }, { -- Signs
        topright    =  {  1,  1 },
        right       =  {  1,  1 },
        bottomright =  {  1, -1 },
        bottomleft  =  { -1, -1 },
        left        =  { -1,  1 },
        topleft     =  { -1,  1 }
    }, { 1, 0 } -- Default mask
);

-- Anchors.VerticalFlip(f, "bottomleft", ref);
-- +-------+
-- |  ref  |
-- +-------+
-- | f |
-- +---+
-- 
-- Anchors.VerticalFlip(f, "bottom", ref);
-- +-------+
-- |  ref  |
-- +-------+
--   | f |
--   +---+
--
-- Anchors.VerticalFlip(f, "bottomright", ref);
-- +-------+
-- |  ref  |
-- +-------+
--     | f |
--     +---+
--
-- Anchors.VerticalFlip(f, "topleft", ref);
-- +---+
-- | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "top", ref);
--   +---+
--   | f |
-- +-------+
-- |  ref  |
-- +-------+
--
-- Anchors.VerticalFlip(f, "topright", ref);
--     +---+
--     | f |
-- +-------+
-- |  ref  |
-- +-------+
FlipAnchor("Vertical",
    {
        bottomright = "topright",
        bottomleft  = "topleft",
        bottom      = "top"
    }, { -- Signs
        topright    =  {  1,  1 },
        top         =  {  1,  1 },
        topleft     =  { -1,  1 },
        bottomright =  {  1, -1 },
        bottom      =  {  1, -1 },
        bottomleft  =  { -1, -1 }
    }, { 0, 1 } -- Default mask
);

-- "frame touches ref's anchor."
--
-- frame will be "flipped" over the reference frame. The centers of the two frames
-- will form a line that passes through the anchor.
-- Given a single number, convert it to the appropriate direction depending on
-- what anchor is used.
--
-- Positive gap values will increase the distance between frames.
-- Negative gap values will decrease the distance between frames.
--
-- The centers will form a line that passes through the anchor; diagonal anchor
-- points will cause the frames to separate diagonally.
-- 
-- Anchors.DiagonalFlip(f, "topleft", ref);
-- +---+
-- | f |
-- +---+---+
--     |ref|
--     +---+
--
-- Anchors.DiagonalFlip(f, "top", ref);
-- +---+
-- | f |
-- +---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "topright", ref);
--     +---+
--     | f |
-- +---+---+
-- |ref|
-- +---+
--
-- Anchors.DiagonalFlip(f, "right", ref);
-- +---+---+
-- |ref| f |
-- +---+---+
--
--
-- Anchors.DiagonalFlip(f, "bottomright", ref);
-- +---+
-- |ref|
-- +---+---+
--     | f |
--     +---+
--
-- Anchors.DiagonalFlip(f, "bottom", ref);
-- +---+
-- |ref|
-- +---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "bottomleft", ref);
--     +---+
--     |ref|
-- +---+---+
-- | f |
-- +---+
--
-- Anchors.DiagonalFlip(f, "left", ref);
-- +---+---+
-- | f |ref|
-- +---+---+
FlipAnchor("Diagonal", 
    {
        top      = "bottom",
        right    = "left",
        topleft  = "bottomright",
        topright = "bottomleft",
    }, { -- Signs
        top         = {  1,  1 },
        topright    = {  1,  1 },
        right       = {  1,  1 },
        bottomright = {  1, -1 },
        bottom      = {  1, -1 },
        bottomleft  = { -1, -1 },
        left        = { -1, -1 },
        topleft     = { -1,  1 },
    }, { -- Defaults
        top         = {  0,  1 },
        topright    = {  1,  1 },
        right       = {  1,  0 },
        bottomright = {  1,  1 },
        bottom      = {  0,  1 },
        bottomleft  = {  1,  1 },
        left        = {  1,  0 },
        topleft     = {  1,  1 },
    }
);
Anchors.Flip=Anchors.DiagonalFlip;
Anchors.Flipping=Anchors.DiagonalFlip;
Anchors.Flipped=Anchors.DiagonalFlip;
Anchors.Over=Anchors.DiagonalOver;

-- frame shares ref's anchor
function Anchors.Share(frame, ...)
    local anchor, ref, x, y=GetAnchorArguments(frame, ...);
    if x ~= nil then
        x=-x;
    end;
    if y ~= nil then
        y=-y;
    end;
    frame:SetPoint(anchor, ref, anchor, Anchors.DiagonalGap(anchor, x, y));
end;
Anchors.Shares=Anchors.Share;
Anchors.Sharing=Anchors.Share;
Anchors.On=Anchors.Share;

function Anchors.Center(frame, ref)
    anchor=anchor or "center";
    frame:SetPoint(anchor, ref, "center");
end;

function Anchors.Inset(frame, ref, inset)
    Anchors.Share(frame, "topleft", ref, inset);
    Anchors.Share(frame, "bottomright", ref, inset);
end;
