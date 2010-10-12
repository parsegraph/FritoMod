if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Functional.Objects");

function Suite:TestValue()
    local value = Objects.Value();
    Assert.Nil(value.Get(), "Value is initially nil");
    value.Set(true);
    Assert.Equals(true, value.Get(), "Value can be set with Set, and retrieved with Get");
    Assert.Exception("Value fails when asserted for unexpected value", value.Assert, false);
    Assert.Success("Value succeeds when asserted for expected value", value.Assert, true);
end;

function Suite:TestValueAcceptsInitialValue()
    local value = Objects.Value(true);
    Assert.Equals(true, value.Get(), "Value accepts initial values");
end;

function Suite:TestValueAllowsMethodCalls()
    local value = Objects.Value();
    value:Set(true);
    Assert.Equals(true, value:Get(), "Value allows method-style calls");
end;

function Suite:TestToggleManagesAToggledFunctionOrValue()
    local t=Objects.Toggle();
    Assert.False(t:IsOn());
    t:On();        
    t:AssertTrue();
    t:Off();
    t:AssertFalse();
    t:Off();
    t:AssertFalse();
    local r=t:Set(1);
    t:AssertTrue();
    r();
    t:AssertFalse();
    r();
end;
