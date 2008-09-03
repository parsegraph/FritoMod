TestCase = FritoLib.OOP.Class(Log);
local TestCase = TestCase;

TestCase.returnTypes = {
    CONSTANT = "constant",
    COMPLEX = "complex",
    EXCEPTION = "exception",
}

function TestCase.prototype:init(testName, returnType, returnValue, testFunc, ...)
    TestCase.super.prototype.init(self, "TestCase(" .. testName .. ")");
    self.testName = testName;
    self.returnType = returnType;
    self.returnValue = returnValue;
    self.testFunc = ObjFunc(testFunc, ...);
end;

function TestCase:ToString()
    return "TestCase";
end;

function TestCase.prototype:Execute()
    self:Log("Starting Test - " .. self.testName);
    self:Log("Expected Results", self.returnType, self.returnValue);
    self:Capture();
    local result = {pcall(testFunc)};
    self:Release();
    self:Log("Test Results", result);
    if self.returnType == TestCase.returnType.EXCEPTION then
        if result[1] ~= false then
            self:Log("Test Failed (Reason: Expected exception, but test didn't throw.)");
            return false;
        end;
        if result[2] ~= self.returnValue then
            self:Log("Test Failed (Reason: Expected and got exception, but values mismatch.)");
            return false;
        end;
    elseif self.returnType == TestCase.returnType.CONSTANT then
        if result[1] ~= true then
            self:Log("Test Failed (Reason: Expected constant, but test threw.");
            return false;
        end;
        if result[2] ~= self.returnValue then
            self:Log("Test Failed (Reason: Expected and got constant, but values mismatch.)");
            return false;
        end;
    elseif self.returnType == TestCase.returnType.COMPLEX then
        if result[1] ~= true then
            self:Log("Test Failed (Reason: Expected constant, but test threw.)");
            return false;
        end;
        if not self.returnValue(unpack(result)) then
            self:Log("Test Failed (Reason: Validator returned falsy.)");
            return false;
        end;
    else
        self:Log("Test Failed (Reason: ReturnType is unknown", self.returnType);
        return false;
    end;
    self.log:Log("Test Successful.");
    return true;
end;

