local Suite = CreateTestSuite("fritomod.Mapper");

function Suite:TestMapper()
    local m = Mapper:New();

    local source = {
        a = "Foo",
        b = "Bar",
        c = "Baz"
    };

    m:SetSource(source);

    m:SetMapper(function(data)
        if data then
            return data:upper();
        end;
    end);

    Assert.Equals({
        a = "FOO",
        b = "BAR",
        c = "BAZ"
    }, m:Get());

    source.a = "Bat";
    m:Invalidate();

    Assert.Equals({
        a = "BAT",
        b = "BAR",
        c = "BAZ"
    }, m:Get());

    m:SetMapper(function(data)
        if data then
            return data:lower();
        end;
    end);

    Assert.Equals({
        a = "bat",
        b = "bar",
        c = "baz"
    }, m:Get());
end;

function Suite:TestReuse()
    if true then
        -- Mappers don't support reuse just yet.
        return;
    end;

    local mapper = Mapper:New();
    mapper:SetMapper(function(color)
        return {
            name = color
        };
    end);
    mapper:SetSource({
        "yellow",
        "yellow",
    });

    local frames = mapper:Get();
    assert(frames[1]);
    assert(frames[2]);

    -- Don't use Assert.Equals and friends because neither
    -- value is really an "expected" value.
    assert(frames[1] ~= frames[2]);
end;
