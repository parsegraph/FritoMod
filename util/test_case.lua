TestCase = OOP.Class(Log);
local TestCase = TestCase;

TestCase.returnTypes = {
    CONSTANT = "constant",
    COMPLEX = "complex",
    EXCEPTION = "exception",
}

function TestCase:__Init(returnType, returnValue, testFunc, ...)
    TestCase.__super.__Init(self);
    self.returnType = returnType;
    self.returnValue = returnValue;
    self.testFunc = ObjFunc(testFunc, ...);
end;

function TestCase:ToString()
    return "TestCase";
end;

function TestCase:NakedExecute(catchExceptions)
    if catchExceptions then
        return { pcall(self.testFunc) };
    end;
    return testFunc();
end;

function TestCase:Execute(dontCatchExceptions)
    self:Log(format("Test started, expecting '%s'", self.returnType));
    self:LogData("Expected Results", self.returnType, self.returnValue);
    local releaser = MasterLog:SyndicateTo(self);
    local result = self:NakedExecute(true);
    releaser();
    self:LogData("Test Results", result);
    if self.returnType == TestCase.returnTypes.EXCEPTION then
        if result[1] ~= false then
            self:LogError("Test Failed - Wrong type");
            return false;
        end;
        if result[2] ~= self.returnValue then
            self:LogError("Test Failed - Incorrect value");
            return false;
        end;
    elseif self.returnType == TestCase.returnTypes.CONSTANT then
        if result[1] ~= true then
            self:LogError("Test Failed - Wrong type");
            return false;
        end;
        if result[2] ~= self.returnValue then
            self:LogError("Test Failed - Incorrect value");
            return false;
        end;
    elseif self.returnType == TestCase.returnTypes.COMPLEX then
        if result[1] ~= true then
            self:LogError("Test Failed - Wrong type");
            return false;
        end;
        if not self.returnValue(unpack(result)) then
            self:LogError("Test Failed - Incorrect complex result");
            return false;
        end;
    else
        self:LogError(format("Test Failed - Invalid returnType '%s'", self.returnType));
        error(format("Test Failed - Invalid returnType '%s'", self.returnType));
        return false;
    end;
    self:Log("Test Successful");
    return true;
end;
