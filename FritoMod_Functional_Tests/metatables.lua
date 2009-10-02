local MetatableTests = ReflectiveTestSuite:New("FritoMod_Functional.metatables");

function MetatableTests:TestCompositeTable()
    local comp = CompositeTable();

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

function MetatableTests:TestDefensiveTable()
    local defensive = DefensiveTable();

    Assert.Exception("DefensiveTable throws on missing method calls", function()
        defensive:MissingMethod();
    end);

    Assert.Exception("DefensiveTable throws on missing field accesses", function()
        local _ = defensive.MissingField;
    end);
end;

