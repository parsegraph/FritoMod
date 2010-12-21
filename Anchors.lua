-- Anchors lets us set up Frame anchor points in a way that strikes me
-- as somewhat more readable. They're especially useful if you want to have
-- offsets between anchors.
--
-- -- myFrame's right anchor touches otherFrame's left anchor.
-- Anchors.Touch(myFrame, otherFrame, "left");
--
-- -- myFrame's bottomright anchor touches otherFrame's topleft anchor.
-- Anchors.Touch(myFrame, otherFrame, "topleft");
--
-- -- myFrame is aligned 2 pixels beneath otherFrame's top anchor.
-- Anchor.Share(myFrame, otherFrame, "top", -2); 
--
-- My advice is to use Anchors when it's convenient. Otherwise, there's no need
-- to religiously use it: Anchors is not intended to be a replacement or a substitute
-- for Frame:SetPoint. I typically use it only when I want to have gaps between frames
-- and don't want to remember which way is positive/negative.

if nil ~= require then
    require "wow/Frame-Layout";
end;

Anchors={};

do 
    local horizontalReverses={
        topleft    = "topright",
        bottomleft = "bottomright",
        left       = "right",
    };
    for k,v in pairs(horizontalReverses) do
        horizontalReverses[v]=k;
    end;

    local horizontalGaps={
        topright    =  1,
        right       =  1,
        bottomright =  1, 
        bottomleft  = -1,
        left        = -1,
        topleft     = -1,
    };

    function Anchors.HorizontalGap(anchor, gap)
        local sign=horizontalGaps[anchor];
        assert(sign, "Unrecognized anchor name: "..anchor);
        return gap * sign, 0;
    end;

    -- Anchors.HorizontalFlip(f, ref, "topright");
    -- +---+---+
    -- |   | f |
    -- |ref|---+
    -- |   |
    -- +---+
    -- 
    -- Anchors.HorizontalFlip(f, ref, "right");
    -- +---+
    -- |   |---+
    -- |ref| f |
    -- |   |---+
    -- +---+
    -- 
    -- Anchors.HorizontalFlip(f, ref, "bottomright");
    -- +---+
    -- |   |
    -- |ref|---+
    -- |   | f |
    -- +---+---+
    --
    -- Anchors.HorizontalFlip(f, ref, "topleft");
    -- +---+---+
    -- | f |   |
    -- +---|ref|
    --     |   |
    --     +---+
    --
    -- Anchors.HorizontalFlip(f, ref, "left");
    --     +---+
    -- +---|   |
    -- | f |ref|
    -- +---|   |
    --     +---+
    -- 
    -- Anchors.HorizontalFlip(f, ref, "bottomleft");
    --     +---+
    --     |   |
    -- +---|ref|
    -- | f |   |
    -- +---+---+
    function Anchors.HorizontalFlip(frame, ref, anchor, gap)
        gap=gap or 0;
        anchor=anchor:lower();
        frame:SetPoint(horizontalReverses[anchor], ref, anchor, Anchors.HorizontalGap(anchor, gap));
    end;
    Anchors.HorizontalFlipping = Anchors.HorizontalFlip;
    Anchors.HorizontalFlipped  = Anchors.HorizontalFlip;
    Anchors.HorizontalTouch    = Anchors.HorizontalFlip;
    Anchors.HorizontalTouching = Anchors.HorizontalFlip;
    Anchors.HorizontalTouches  = Anchors.HorizontalFlip;
    Anchors.HorizontalOver     = Anchors.HorizontalFlip;
end;

do 
    local verticalReverses={
        bottomright = "topright",
        bottomleft  = "topleft",
        bottom      = "top"
    };
    for k,v in pairs(verticalReverses) do
        verticalReverses[v]=k;
    end;

    local verticalGaps={
        topright    =  1,
        top         =  1,
        topleft     =  1,
        bottomright = -1, 
        bottom      = -1, 
        bottomleft  = -1,
    };

    function Anchors.VerticalGap(anchor, gap)
        local sign=verticalGaps[anchor];
        assert(sign, "Unrecognized anchor name: "..anchor);
        return 0, gap * sign;
    end;

    -- Anchors.VerticalFlip(f, ref, "bottomleft");
    -- +-------+
    -- |  ref  |
    -- +-------+
    -- | f |
    -- +---+
    -- 
    -- Anchors.VerticalFlip(f, ref, "bottom");
    -- +-------+
    -- |  ref  |
    -- +-------+
    --   | f |
    --   +---+
    --
    -- Anchors.VerticalFlip(f, ref, "bottomright");
    -- +-------+
    -- |  ref  |
    -- +-------+
    --     | f |
    --     +---+
    --
    -- Anchors.VerticalFlip(f, ref, "topleft");
    -- +---+
    -- | f |
    -- +-------+
    -- |  ref  |
    -- +-------+
    --
    -- Anchors.VerticalFlip(f, ref, "top");
    --   +---+
    --   | f |
    -- +-------+
    -- |  ref  |
    -- +-------+
    --
    -- Anchors.VerticalFlip(f, ref, "topright");
    --     +---+
    --     | f |
    -- +-------+
    -- |  ref  |
    -- +-------+
    function Anchors.VerticalFlip(frame, ref, anchor, gap)
        gap=gap or 0;
        anchor=anchor:lower();
        frame:SetPoint(verticalReverses[anchor], ref, anchor, Anchors.VerticalGap(anchor, gap));
    end;
    Anchors.VerticalFlipping = Anchors.VerticalFlip;
    Anchors.VerticalFlipped  = Anchors.VerticalFlip;
    Anchors.VerticalTouch    = Anchors.VerticalFlip;
    Anchors.VerticalTouching = Anchors.VerticalFlip;
    Anchors.VerticalTouches  = Anchors.VerticalFlip;
    Anchors.VerticalOver     = Anchors.VerticalFlip;
end;

do
    local reverses={
        top      = "bottom",
        right    = "left",
        topleft  = "bottomright",
        topright = "bottomleft",
    };
    for k,v in pairs(reverses) do
        reverses[v]=k;
    end;

    local touchGaps={
        top         = function(gap) return    0,  gap end;
        topright    = function(gap) return  gap,  gap end;
        right       = function(gap) return  gap,    0 end;
        bottomright = function(gap) return  gap, -gap end;
        bottom      = function(gap) return    0, -gap end;
        bottomleft  = function(gap) return -gap, -gap end;
        left        = function(gap) return -gap,    0 end;
        topleft     = function(gap) return -gap,  gap end;
    }

    -- Given a single number, convert it to the appropriate direction depending on
    -- what anchor is used.
    --
    -- Positive gap values will increase the distance between frames.
    -- Negative gap values will decrease the distance between frames.
    --
    -- The centers will form a line that passes through the anchor; diagonal anchor
    -- points will cause the frames to separate diagonally.
    function Anchors.DiagonalGap(anchor, gap)
        local gapFunc=touchGaps[anchor:lower()];
        assert(gapFunc, "Unrecognized anchor name: "..anchor);
        return gapFunc(gap);
    end;
    Anchors.RadialGap = Anchors.DiagonalGap;

    -- "frame touches ref's anchor."
    --
    -- frame will be "flipped" over the reference frame. The centers of the two frames
    -- will form a line that passes through the anchor.
    --
    -- Anchors.DiagonalFlip(f, ref, "topleft");
    -- +---+
    -- | f |
    -- +---+---+
    --     |ref|
    --     +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "top");
    -- +---+
    -- | f |
    -- +---+
    -- |ref|
    -- +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "topright");
    --     +---+
    --     | f |
    -- +---+---+
    -- |ref|
    -- +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "right");
    -- +---+---+
    -- |ref| f |
    -- +---+---+
    --
    --
    -- Anchors.DiagonalFlip(f, ref, "bottomright");
    -- +---+
    -- |ref|
    -- +---+---+
    --     | f |
    --     +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "bottom");
    -- +---+
    -- |ref|
    -- +---+
    -- | f |
    -- +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "bottomleft");
    --     +---+
    --     |ref|
    -- +---+---+
    -- | f |
    -- +---+
    --
    -- Anchors.DiagonalFlip(f, ref, "left");
    -- +---+---+
    -- | f |ref|
    -- +---+---+
    function Anchors.DiagonalFlip(frame, ref, anchor, gap)
        gap=gap or 0;
        anchor=anchor:lower();
        frame:SetPoint(reverses[anchor], ref, anchor, Anchors.RadialGap(anchor, gap));
    end;
    Anchors.DiagonalFlipping = Anchors.DiagonalFlip;
    Anchors.DiagonalFlipped  = Anchors.DiagonalFlip; 
    Anchors.DiagonalTouch    = Anchors.DiagonalFlip;
    Anchors.DiagonalTouching = Anchors.DiagonalFlip;
    Anchors.DiagonalTouches  = Anchors.DiagonalFlip;
    Anchors.DiagonalOver     = Anchors.DiagonalFlip;
    Anchors.RadialFlip       = Anchors.DiagonalFlip;
    Anchors.Flip             = Anchors.DiagonalFlip;
end;

-- frame shares ref's anchor
function Anchors.Share(frame, ref, anchor, gap)
    gap=gap or 0;
    anchor=anchor:lower();
    frame:SetPoint(anchor, ref, anchor, Anchors.DiagonalGap(anchor, -gap));
end;
Anchors.Shares=Anchors.Share;
Anchors.Sharing=Anchors.Share;
Anchors.On=Anchors.Share;

function Anchors.Center(frame, ref, anchor)
    anchor=anchor or "center";
    frame:SetPoint(anchor, ref, "center");
end;
