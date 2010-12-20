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

local reverses={
    top="bottom",
    right="left",
    topleft="bottomright",
    topright="bottomleft",
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
    center      = function(gap) return -gap,  gap end;
}

function Anchors.ExpandGapValues(anchor, gap)
    local gapFunc=touchGaps[anchor:lower()];
    assert(gapFunc, "Unrecognized anchor name: "..anchor);
    return gapFunc(gap);
end;

-- frame touches ref's anchor.
function Anchors.Touch(frame, ref, anchor, gap)
    gap=gap or 0;
    anchor=anchor:lower();
    frame:SetPoint(reverses[anchor], ref, anchor, Anchors.ExpandGapValues(anchor, gap));
end;
Anchors.Touching=Anchors.Touch;
Anchors.Touches=Anchors.Touch;
Anchors.Flip=Anchors.Touch;
Anchors.Flipped=Anchors.Touch;
Anchors.Flipping=Anchors.Touch;
Anchors.Over=Anchors.Touch;

-- frame shares ref's anchor
function Anchors.Share(frame, ref, anchor, gap)
    gap=gap or 0;
    anchor=anchor:lower();
    frame:SetPoint(anchor, ref, anchor, Anchors.ExpandGapValues(anchor, -gap));
end;
Anchors.On=Anchors.Share;

function Anchors.Center(frame, ref, anchor)
    anchor=anchor or "center";
    frame:SetPoint(anchor, ref, "center");
end;
