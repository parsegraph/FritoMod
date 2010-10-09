if nil ~= require then
    require "FritoMod_OOP/OOP-Class";

    require "FritoMod_UI/Frames";
end;

PersistentAnchor=OOP.Class();

function PersistentAnchor:Constructor(parentFrame)
    local f=CreateFrame("Frame", nil, parentFrame)
    self.frame=f;
    Frames.Square(f, 10);
    f:SetMovable(true);
    Frames.Color(f, "black");
    f:Hide();

    local white=f:CreateTexture();
    Frames.Color(f, "white");
    white:SetPoint("center");
    Frames.Square(white, 7);
end;

function PersistentAnchor:Show()
    if self.frame:GetNumPoints()==0 then
        self.frame:SetPoint("center");
    end;
    self.frame:Show();
    Frames.Draggable(self.frame);
    return Functions.OnlyOnce(self, "Hide");
end;

function PersistentAnchor:Hide()
    self.frame:Hide();
    Frames.Draggable(self.frame, false);
end;

local function AssertLocationFormat(location)
    assert(location, "location must not be nil");
    assert(type(location) == "table", "location must be a table. Type: "..type(location));
    assert(type(location.anchor)=="string", 
        "location.anchor must be a string, but it was: "..tostring(location.anchor));
    assert(tonumber(location.x) or location.x==nil, 
        "location.x looks invalid (not a number or nil): "..tostring(location.x));
    assert(tonumber(location.y) or location.y==nil, 
        "location.y looks invalid (not a number or nil): "..tostring(location.y));
end

function PersistentAnchor:Load(location)
    AssertLocationFormat(location);
    self.frame:ClearAllPoints();
    self.frame:SetPoint(location.anchor, nil, location.anchor, location.x, location.y);
end;

function PersistentAnchor:Save()
    local location={};
    local anchor,_,_,x,y=self.frame:GetPoint(1);
    location.anchor=anchor;
    location.x=x;
    location.y=y;
    AssertLocationFormat(location);
    return location;
end;
