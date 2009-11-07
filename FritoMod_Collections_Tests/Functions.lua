if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Collections/Functions";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Collections.Functions");

function Suite:TestFunctionPopulator()
    local functions = {};
    local populator = Functions.FunctionPopulator(functions);
    local remover = populator(Noop);
    Assert.Equals(1, #functions, "Only one function was added to functions");
    remover();
    Assert.Equals(0, #functions, "Returned remover removes added function");
end;

