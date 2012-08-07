local Suite = CreateTestSuite("fritomod.Ordering");

function Suite:TestOrdering()
    local o = Ordering:New();
    o:Order("A", "B", "D", "C", "E", "F", "G");
    o:Order("C", "D", "G");
    Assert.Equals(
        {"A", "B", "C", "D", "E", "F", "G"},
        o:Get());
end;

function Suite:TestOrderingWithEqualHead()
    local o = Ordering:New();
    o:Order("A", "B", "C", "D", "E", "F", "G");
    o:Order("A", "B", "C");
    Assert.Equals(
        {"A", "B", "C", "D", "E", "F", "G"},
        o:Get());
end;

function Suite:TestOrderingWithEqualTail()
    local o = Ordering:New();
    o:Order("A", "B", "C", "D", "E", "F", "G");
    o:Order("E", "F", "G");
    Assert.Equals(
        {"A", "B", "C", "D", "E", "F", "G"},
        o:Get());
end;

function Suite:TestOrderingWithTail()
    local o = Ordering:New();
    o:Order("A", "B", "C", "D");
    o:Order("E", "F", "G");
    Assert.Equals(
        {"A", "B", "C", "D", "E", "F", "G"},
        o:Get());
end;

