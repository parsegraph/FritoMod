local Suite = CreateTestSuite("Assert");

function Suite:TestAssertException()
    assert(not pcall(Assert.Exception, "Don't throw", Noop), "Assert.Exception throws on successful test");
    assert(pcall(Assert.Exception, "Throw!", error), "Assert.Exception succeeds on bad test");
end;

function Suite:TestAssertExceptionWithNoReason()
	assert(pcall(Assert.Exception, error), "Exception is not thrown when error is expected");
end;

function Suite:TestAssertExceptionDoesNotUseCurrying()
	local o={};
	function o:Call()
	end;
	assert(not pcall(Assert.Exception, o, "Call"), "Assert.Exception must accept curried methods");
end;

function Suite:TestAssertSucceeds()
    assert(pcall(Assert.Succeeds, "Don't Throw", Noop), "Assert.Succeeds succeeds on successful test");
    assert(not pcall(Assert.Succeeds, "Throw!", error), "Assert.Succeeds throws on bad test");
end;

function Suite:TestAssertSucceedsDoesNotUseCurrying()
	local f=Tests.Flag();
	local o={};
	function o:Call()
	end;
	assert(pcall(Assert.Succeeds, o, "Call"), "Assert.Succeeds must accept curried methods");
end;

function Suite:TestNotEquals()
	Assert.Unequal(true, false, "Unequal values are unequal");
	Assert.Unequal(nil, "Foo", "nil on lhs is unequal");
	Assert.Unequal("Foo", nil, "nil on rhs is still unequal");
    Assert.Unequal(Noop, nil, "Noop function is not nil");
    assert(not pcall(Assert.Unequal, nil, nil), "nil==nil");
    assert(not pcall(Assert.Unequal, "", ""), "empty strings are equal");
    assert(not pcall(Assert.Unequals, Noop, Noop), "Functions are equal");
end;

function Suite:TestEquals()
    Assert.Equals("Foo", "Foo", "Foo is foo");
    Assert.Equals("", "", "Empty string is empty string");
    Assert.Equals({}, {}, "Empty table is empty table");
    assert(not pcall(Assert.Equals, nil, "Foo"), "nil is not Foo");
    assert(not pcall(Assert.Equals, "", {}), "Empty string is not empty list");
    assert(not pcall(Assert.Equals, Noop, nil), "Noop function is not nil");
end;

function Suite:TestEquals()
    Assert.Equals("Foo", "Foo", "Foo is foo");
    Assert.Equals("", "", "Empty string is empty string");
    Assert.Equals({}, {}, "Empty table is empty table");
    assert(not pcall(Assert.Equals, nil, "Foo"), "nil is not Foo");
    assert(not pcall(Assert.Equals, "", {}), "Empty string is not empty list");
    assert(not pcall(Assert.Equals, Noop, nil), "Noop function is not nil");
end;

function Suite:TestEqualsWithNestedTables()
    local control = {
        nested = { superNested = "Foo" }
    }
    Assert.Success("Equals is successful for equal tables", Assert.Equals, control, {
        nested = { superNested = "Foo" }
    });
    Assert.Success("Equals is successful for equal tables", Assert.Equals, control, {
        nested = { superNested = "Foo" }
    });
    Assert.Fails("Equals fails for tables with unequal nested tables", Assert.Equals, control, {
        nested = { badlyNamed = "Foo" }
    });
    Assert.Fails("Equals fails for tables with unequal nested values", Assert.Equals, control, {
        nested = { superNested = "Not Foo" }
    });
end;

function Suite:TestTablesEqual()
    Assert.Succeeds("TablesEqual succeeds for two empty tables",
        Assert.TablesEqual, {}, {});
    Assert.Fails("TablesEqual fails for a empty table and a non-table value",
        Assert.TablesEqual, {}, "Foo");
    Assert.Fails("TablesEqual fails for a empty table and a non-empty table",
        Assert.TablesEqual, {}, {a=1});
    Assert.Succeeds("TablesEqual succeeds for equal non-empty tables",
        Assert.TablesEqual, {a=1}, {a=1});
    Assert.Succeeds("TablesEqual succeeds for two keys",
        Assert.TablesEqual, {a=1, b=2}, {a=1, b=2});
    Assert.Fails("TablesEqual fails for unmatched expected keys",
        Assert.TablesEqual, {a=1, b=2}, {a=1});
    Assert.Fails("TablesEqual fails for unmatched actual keys",
        Assert.TablesEqual, {a=1}, {a=1, b=2});
    Assert.Succeeds("TablesEqual succeeds for nested but equal tables",
        Assert.TablesEqual, {a={b=2}}, {a={b=2}});
end;

function Suite:TestTablesEqualWithBothNilValues()
    Assert.Fails("TablesEqual fails for two nil values", Assert.TablesEqual, nil, nil);
end;
