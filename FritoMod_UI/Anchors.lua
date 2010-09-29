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

do
    local anchors;
    local function CreateAnchor(name)
        local f=CreateFrame("Frame", nil, UIParent);
        anchors[name]=f;
        f:SetWidth(10);
        f:SetHeight(10);
        anchors[name]=f;
        return f;
    end;
    local savedKey="FritoMod.Anchors";
    Callbacks.Persistence(function()
        anchors={};
        if Persistent[savedKey] then
            for name,location in pairs(Persistent[savedKey]) do
                local f=CreateAnchor(name);
                f:SetPoint(unpack(location));
            end;
        end;
        return function()
            Persistent[savedKey]={};
            for name,f in pairs(anchors) do
                local location={f:GetPoint(1)};
                if location[2]==nil then
                    location[2]="UIParent";
                end;
                Persistent[savedKey][name]=location;
            end;
        end;
    end);
    function Anchors.Named(name)
        assert(anchors, "Anchors has not yet been loaded");
        if not anchors[name] then
            local f=CreateAnchor(name);
            f:SetPoint("center");
        end;
        return anchors[name];
    end;
end;
