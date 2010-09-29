-- I think Anchors will be a collection of method dealing with points. Right now, these
-- live in Builders, but I'm going to move them here. I want to have the good decomposition
-- (i.e., Flip, Stack, Center, etc. anchors) along with persistent anchors (once I figure out
-- how these should work).

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
}

-- frame touches ref's anchor.
function Anchors.Touch(frame, ref, anchor, gap)
    gap=gap or 0;
    anchor=anchor:lower();
    frame:SetPoint(reverses[anchor], ref, anchor, touchGaps[anchor](gap));
end;

-- frame shares ref's anchor
function Anchors.Share(frame, ref, anchor, gap)
    gap=gap or 0;
    anchor=anchor:lower();
    frame:SetPoint(anchor, ref, anchor, touchGaps[anchor](gap));
end;
