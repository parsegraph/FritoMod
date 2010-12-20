local Suite=CreateTestSuite("Mixins");

function Suite:TestOverridable()
    local t={};
    Mixins.Overridable(t, "Foo", 42);
    Assert.Equals(42, t.Foo);
    Mixins.Overridable(t, "Foo", 43);
    Assert.Equals(42, t.Foo);
end;

function Suite:TestDefaultAlias()
    local c=Tests.Counter();
    local t={
        Foo=c.Tick
    };
    Mixins.DefaultAlias(t, "Foo", "Bar", "Baz");
    t.Bar();
    t.Baz();
    c.Assert(2);
end;
