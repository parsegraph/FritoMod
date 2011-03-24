if nil ~= require then
    require "wow/Frame-Layout";
end;

Serializers=Serializers or {};

function Serializers.VerifyPoint(location)
    assert(location, "location must not be nil");
    assert(type(location) == "table", "location must be a table. Type: "..type(location));
    assert(type(location.anchor)=="string", 
        "location.anchor must be a string, but it was: "..tostring(location.anchor));
    assert(tonumber(location.x) or location.x==nil, 
        "location.x looks invalid (not a number or nil): "..tostring(location.x));
    assert(tonumber(location.y) or location.y==nil, 
        "location.y looks invalid (not a number or nil): "..tostring(location.y));
end;

function Serializers.LoadPoint(location, frame)
    Serializers.VerifyPoint(location);
    frame:SetPoint(location.anchor, nil, location.anchor, location.x, location.y);
end;

function Serializers.SavePoint(frame, pointNum)
    local location={};
    local anchor,_,_,x,y=frame:GetPoint(pointNum);
    location.anchor=anchor;
    location.x=x;
    location.y=y;
    Serializers.VerifyPoint(location);
    return location;
end;

