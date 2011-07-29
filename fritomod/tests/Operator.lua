local Suite=CreateTestSuite("fritomod.Operator");

function Suite:TestAdditionSumsAllPassedNumbers()
    Assert.Equals(nil, Operator.Add());
    Assert.Equals(nil, Operator.Add(nil));
    Assert.Equals(2, Operator.Add(2));
    Assert.Equals(1+2+3+4+5, Operator.Add(1,2,3,4,5));
    Assert.Equals(Operator.Add(1,2,3,4,5), Operators.plus(1,2,3,4,5));
    Assert.Equals(1+2+3+4+5, Operator.Add(nil,1,2,3,nil,4,5));
end;

function Suite:TestSubtractionSubtractsAllNumbers()
    Assert.Equals(nil, Operator.Minus());
    Assert.Equals(nil, Operator.Minus(nil));
    Assert.Equals(1, Operator.Minus(1));
    Assert.Equals(4-2-1, Operator.Subtract(4,2,1));
    Assert.Equals(Operator.Subtract(4,2,1), Operator.minus(4,2,1));
    Assert.Equals(4-2-1, Operator.Subtract(nil,4,2,nil,1));
end;

function Suite:TestMultiplyMultipliesNumbersFromOne()
    Assert.Equals(nil, Operator.Times());
    Assert.Equals(2, Operator.Times(2));
    Assert.Equals(4, Operator.Times(2,2));
    Assert.Equals(2*3*4, Operator.multiply(2,3,4));
    Assert.Equals(2*3*4, Operator.multiply(nil,2,3,4));
    Assert.Equals(2*3*4, Operator.multiply(nil,2,nil,3,4));
end;

function Suite:TestDivisionDividesNumbersFromOne()
    Assert.Equals(nil, Operator.Divide());
    Assert.Equals(2, Operator.Divide(2));
    Assert.Equals(2/2, Operator.Divide(2,2));
    Assert.Equals(2/3/4, Operator.division(2,3,4));
    Assert.Equals(2/3/4, Operator.division(nil,2,3,4));
    Assert.Equals(2/3/4, Operator.division(nil,2,3,nil,4));
end;

function Suite:TestComparingOperations()
    assert(Operator.GT(2, 4));
    assert(Operator.GTE(2, 2));
    assert(Operator.LT(2, 1));
    assert(Operator.LTE(1, 1));
    assert(Operator.E(1, 1));
    assert(Operator.NE(1, 0));
end;

function Suite:TestComparingOperationsWithMultipleCandidates()
    assert(not Operator.GT (2, 3, 1));
    assert(not Operator.GTE(2, 2, 1));
    assert(not Operator.LT (2, 1, 3));
    assert(not Operator.LTE(1, 1, 2));
    assert(not Operator.E  (2, 2, 1));
    assert(not Operator.NE (1, 0, 1));
end;

function Suite:TestEvenAndOdd()
    assert(Operator.Even(2));
    assert(not Operator.Odd(2));

    assert(Operator.Odd(1));
    assert(not Operator.Even(1));

    assert(Operator.Even(2,4,6));
    assert(not Operator.Even(2,4,5));

    assert(Operator.Odd(1,3,5));
    assert(not Operator.Odd(1,3,4));
end;

function Suite:TestMultiple()
    assert(Operator.Multiple(3, 3, 6, 9));
    assert(not Operator.Multiple(3, 3, 6, 7));
    assert(Operator.NotMultiple(3, 2, 5, 7));
    assert(not Operator.NotMultiple(3, 2, 5, 9));
end;

function Suite:TestInclusiveRange()
    assert(Operator.InclusiveRange(1, 5, 2, 3, 4, 5));
    assert(not Operator.InclusiveRange(1, 5, 2, 3, 6));
end;

function Suite:TestExclusiveRange()
    assert(Operator.ExclusiveRange(1, 5, 2, 3, 4));
    assert(not Operator.ExclusiveRange(1, 5, 2, 3, 5));
end;
