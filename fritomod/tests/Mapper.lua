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

function Suite:TestReuse()
    local values = {
        "yellow",
        "yellow",
    };
    local mapper = Mapper:New();
    mapper:SetMapper(function(color)
        return {
            name = color
        };
    end);
    mapper:AddSource(values);

    local frames = {};
    mapper:AddDest(frames);

    -- Don't use Assert.Equals and friends because neither
    -- value is really an "expected" value.
    assert(frames[1] ~= frames[2]);

    mapper:AllowReuse();
    assert(frames[1] == frames[2]);
end;

function Suite:TestSmartIteration()
    local mapper = Mapper:New();

    mapper:AddSource({"yellow", "yellow"});
    mapper:AddSource({"blue"});

    mapper:SetMapper("upper");

    local frames = {};
    mapper:AddDest(frames);

    Assert.Equals({
        "YELLOW",
        "YELLOW",
        "BLUE"
    }, frames);
end;
