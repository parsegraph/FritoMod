local Suite = CreateTestSuite("fritomod.basic");

function Suite:TestUnpackAll()
	local a, b, c = UnpackAll({1,2,3});
	Assert.Equals(1, a, "A value");
	Assert.Equals(2, b, "B value");
	Assert.Equals(3, c, "C value");
end;

-- This is a bit of a controversial test. PUC-Rio Lua unpacks the 3, which causes
-- an exception. However, LuaJIT only unpacks the first 1. Since UnpackAll explicitly
-- warns about nil values causing issues, I decided to keep this test and ensure one of
-- the two possibilities are handled. Specifically, I'm checking to make sure either the
-- nil is detected, or the table is unpacked only up to the first nil.
function Suite:TestUnpackAllRejectsNilValues()
    local success, result = pcall(UnpackAll, {1, nil, 3});
    if not success then
        -- Throwing an error is a valid response
        return;
    else
        -- ... or just returning up to the first nil value
        Assert.Equals({1}, result);
    end;
end;
