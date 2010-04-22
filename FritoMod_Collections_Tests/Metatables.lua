if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Metatables";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Metatables");

function Suite:TestMulticast()
    local comp = Metatables.Multicast();
	
    local x = Tests.Flag();
    local y = Tests.Flag();
	
    comp:Add(x);
    comp:Raise();
	
    x:Assert("X has been raised");
	
    comp:Add(y);
    comp:Raise();
	
    x:Assert("X and Y have been raised");
    y:Assert("X and Y have been raised");
end;

function Suite:TestOrderedMap()
    local map = Metatables.OrderedMap();
    -- Intentionally called twice to get the first value.
    local key, value = map:Iterator()();
    assert(key == nil, "OrderedMap finds values on an empty map. Value found: " .. tostring(key));
end;
