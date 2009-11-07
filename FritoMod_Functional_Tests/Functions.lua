if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Functional/Functions";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Functional.Functions");

function AGlobalFunctionNoOneShouldEverUse(stuff)
    Assert.Equals(4, stuff, "Internal global receives externally received value");
    return stuff;
end;

function Suite:TestHookGlobal()
    local counter = Tests.Counter();
    local remover = Functions.HookGlobal("AGlobalFunctionNoOneShouldEverUse", function(stuff)
        counter.Hit();
        Assert.Equals(2, stuff, "Wrapped function receives externally received value");
        return stuff * 2;
    end);
    local result = AGlobalFunctionNoOneShouldEverUse(2);
    Assert.Equals(4, result, "Wrapped global returns internally returned value");
    remover();
    result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Wrapped global returns original value when hook is removed");
    counter.Assert(1, "Hook function only fires once");
end;

function Suite:TestHookGlobalFailsWhenIntermediatelyModified()
    local remover = Functions.HookGlobal("AGlobalFunctionNoOneShouldEverUse", Noop);
    local original = AGlobalFunctionNoOneShouldEverUse;
    AGlobalFunctionNoOneShouldEverUse = nil;
    Assert.Exception("HookGlobal fails when global is modified between calls", remover);
    AGlobalFunctionNoOneShouldEverUse = original;
    remover();
end;

function Suite:TestSpyGlobal()
    local counter = Tests.Counter();
    local remover = Functions.SpyGlobal("AGlobalFunctionNoOneShouldEverUse", function(stuff)
        counter.Hit();
        Assert.Equals(4, stuff, "Spied global receives original value");
        return stuff * 2;
    end);
    local result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Spied global returns original value");
    remover();
    result = AGlobalFunctionNoOneShouldEverUse(4);
    Assert.Equals(4, result, "Spied global returns original value after removal");
    counter.Assert(1, "Spy function only fires once");
end;

function Suite:TestSpyGlobalFailsWhenIntermediatelyModified()
    local remover = Functions.SpyGlobal("AGlobalFunctionNoOneShouldEverUse", Noop);
    local original = AGlobalFunctionNoOneShouldEverUse;
    AGlobalFunctionNoOneShouldEverUse = nil;
    Assert.Exception("SpyGlobal fails when global is modified between calls", remover);
    AGlobalFunctionNoOneShouldEverUse = original;
    remover();
end;

