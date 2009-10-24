local MetatableTests = ReflectiveTestSuite:New("FritoMod_Collections.Metatables");

function MetatableTests:TestMulticast()
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
