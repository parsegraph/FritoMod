local Suite = CreateTestSuite("fritomod.Metatables-OrderedMap");

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

function Suite:TestMulticastHandlesMissingFunctions()
	local m = Metatables.Multicast();
	m:Add({});
	m:Missing();
end;

function Suite:TestOrderedMap()
    local map = Metatables.OrderedMap();
    -- Intentionally called twice to get the first value.
    local key, value = map:Iterator()();
    assert(key == nil, "OrderedMap finds values on an empty map. Value found: " .. tostring(key));
end;
