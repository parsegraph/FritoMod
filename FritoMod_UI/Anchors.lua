-- I think Anchors will be a collection of method dealing with points. Right now, these
-- live in Builders, but I'm going to move them here. I want to have the good decomposition
-- (i.e., Flip, Stack, Center, etc. anchors) along with persistent anchors (once I figure out
-- how these should work).

if nil ~= require then
    require "FritoMod_Functional/Callbacks";
    require "FritoMod_Persistence/Persistence";
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

function Anchors.Center(frame, ref, anchor)
    anchor=anchor or "center";
    frame:SetPoint(anchor, ref, "center");
end;

do
    local anchors;
    local function CreateAnchor(name)
        local f=CreateFrame("Frame", nil, UIParent);
        anchors[name]=f;
        f:SetWidth(10);
        f:SetHeight(10);
        f:SetMovable(true);
        local t=f:CreateTexture();
        t:SetTexture(1,1,1);
        t:SetAllPoints();
        anchors[name]=f;
        return f;
    end;

    local function CheckLocation(location)
        if not location or type(location) ~= "table" then
            return false;
        end;
        if type(location.x) ~= "number" or type(location.y) ~= "number" then
            return false;
        end;
        if type(location.point) ~= "string" then
            return false;
        end;
        return true;
    end;
    local savedKey="FritoMod.Anchors";

    function Anchors.Load()
        anchors={};
        if Persistence[savedKey] then
            for name,location in pairs(Persistence[savedKey]) do
                local f=CreateAnchor(name);
                if CheckLocation(location) then
                    f:SetPoint(location.anchor, UIParent, location.anchor, location.x, location.y);
                end;
            end;
        end;
        return Anchors.Save;
    end;

    function Anchors.Save()
        Persistence[savedKey]={};
        for name,f in pairs(anchors) do
            local location={};
            local anchor,_,_,x,y=f:GetPoint(1);
            location.anchor=anchor;
            location.x=x;
            location.y=y;
            Persistence[savedKey][name]=location;
            if CheckLocation(location) then
                Persistence[savedKey][name]=location;
            end;
        end;
        return Anchors.Load;
    end;

    Callbacks.Persistence(Anchors.Load);
    function Anchors.Named(name)
        assert(anchors, "Anchors has not yet been loaded");
        if not anchors[name] then
            local f=CreateAnchor(name);
            f:SetPoint("center");
        end;
        return anchors[name];
    end;

    function Anchors.Unlock()
        for k,anchor in pairs(anchors) do
            anchor:RegisterForDrag("LeftButton");
            anchor:SetScript("OnDragStart", anchor.StartMoving);
            anchor:SetScript("OnDragStop", anchor.StopMovingOrSizing);
        end;
        return Anchors.Lock;
    end;


    function Anchors.Lock()
        for k,anchor in pairs(anchors) do
            anchor:RegisterForDrag();
            anchor:StopMovingOrSizing();
            anchor:SetScript("OnDragStart", nil);
            anchor:SetScript("OnDragStop", nil);
            anchor:Hide();
        end;
        return Anchors.Unlock;
    end;
end;
