if nil ~= require then
	require "wow/Frame-Layout";
end;

Serializers=Serializers or {};

function Serializers.VerifyPoint(location)
	assert(location, "location must not be nil");
	assert(type(location) == "table", "location must be a table. Type: "..type(location));
	assert(type(location.anchor)=="string",
		"location.anchor must be a string, but it was: "..tostring(location.anchor));
	if location.anchorTo then
		assert(type(location.anchorTo)=="string",
			"location.anchorTo must be a string, but it was: "..type(location.anchorTo));
	end;
	assert(tonumber(location.x) or location.x==nil,
		"location.x looks invalid (not a number or nil): "..tostring(location.x));
	assert(tonumber(location.y) or location.y==nil,
		"location.y looks invalid (not a number or nil): "..tostring(location.y));
end;

function Serializers.LoadPoint(location, frame)
	Serializers.VerifyPoint(location);
	frame:SetPoint(
		location.anchor,
		nil,
		location.anchorTo or location.anchor,
		location.x,
		location.y);
end;

function Serializers.SavePoint(frame, pointNum)
	local location={};
	local anchor,_,anchorTo,x,y=frame:GetPoint(pointNum);
	location.anchor=anchor;
	location.anchorTo=anchorTo or anchor;
	location.x=x;
	location.y=y;
	Serializers.VerifyPoint(location);
	return location;
end;

function Serializers.SaveAllPoints(frame)
    local points = {};
    for pointNum=1, frame:GetNumPoints() do
        table.insert(points, Serializers.SavePoint(frame, pointNum));
    end;
    return points;
end;

function Serializers.LoadAllPoints(points, frame)
    for _, location in ipairs(points) do
        Serializers.LoadPoint(location, frame);
    end;
end;
