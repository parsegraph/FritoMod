local MetatableTests = ReflectiveTestSuite:New("FritoMod_Utilities.Metatables");

function MetatableTests:TestDefensive()
    local defensive = Metatables.Defensive();

    Assert.Exception("DefensiveTable throws on missing method calls", function()
        defensive:MissingMethod();
    end);

    Assert.Exception("DefensiveTable throws on missing field accesses", function()
        local _ = defensive.MissingField;
    end);
end;

