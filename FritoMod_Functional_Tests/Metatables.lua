local MetatableTests = ReflectiveTestSuite:New("FritoMod_Utilities.Metatables");

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

function MetatableTests:TestDefensive()
    local defensive = Metatables.Defensive();

    Assert.Exception("DefensiveTable throws on missing method calls", function()
        defensive:MissingMethod();
    end);

    Assert.Exception("DefensiveTable throws on missing field accesses", function()
        local _ = defensive.MissingField;
    end);
end;

