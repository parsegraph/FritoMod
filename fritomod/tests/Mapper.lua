local Suite = CreateTestSuite("fritomod.Mapper");

function Suite:TestMapper()
    local m = Mapper:New();

    local source = {
        a = "Foo",
        b = "Bar",
        c = "Baz"
    };

    m:AddSource(source);

    local dest = {};
    m:AddDestination(dest);

    m:SetMapper("upper");

    Assert.Equals({
        a = "FOO",
        b = "BAR",
        c = "BAZ"
    }, dest);

    source.a = "Bat";

    m:Update();

    Assert.Equals({
        a = "BAT",
        b = "BAR",
        c = "BAZ"
    }, dest);

    local other = {};
    m:AddDestination(other);

    Assert.Equals({
        a = "BAT",
        b = "BAR",
        c = "BAZ"
    }, other);

    m:SetMapper("lower");

    Assert.Equals({
        a = "bat",
        b = "bar",
        c = "baz"
    }, dest);
end;
