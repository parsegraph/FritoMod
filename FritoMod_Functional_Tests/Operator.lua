local Suite=CreateTestSuite("FritoMod_Functional/Operator");

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
