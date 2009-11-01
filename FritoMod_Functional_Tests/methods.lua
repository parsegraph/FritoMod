local Suite = ReflectiveTestSuite:New("FritoMod_Functional.methods");

function AGlobalFunctionNoOneShouldEverUse(stuff)
    Assert.Equals(2, stuff, "Internal global receives externally received value");
    return stuff;
end;

function Suite:TestHookGlobal()
    local remover = HookGlobal("AGlobalFunctionNoOneShouldEverUse", function(stuff)
        Assert.Equals(2, stuff, "Wrapped function receives externally received value");
    end);
    local result = AGlobalFunctionNoOneShouldEverUse(2);
    Assert.Equals(2, result, "Wrapped global returns internally returned value");
end;

function Suite:TestUnpackAll()
    local a, b, c = UnpackAll({1,2,3});
    Assert.Equals(1, a, "A value");
    Assert.Equals(2, b, "B value");
    Assert.Equals(3, c, "C value");
end;

function Suite:TestUnpackAllWithNilValues()
    local a, b, c = UnpackAll({1,nil,3});
    Assert.Equals(1, a, "A value");
    Assert.Equals(nil, b, "B value");
    Assert.Equals(3, c, "C value");
end;
