if nil ~= require then
    require "fritomod/OOP-Class";
end;

local Suite = CreateTestSuite("hack.Assets");

local Assets = Hack.Assets;

local function GetObjAndAsset(asset, ...)
    local obj = OOP.Class():New();
    asset = Assets.AsAsset(asset, ...);
    return obj, asset(obj, "AddDestructor");
end;

function Suite:TestFlagAsset()
    local obj, flag = GetObjAndAsset(Assets.Flag());
    flag.Raise();
    obj:Destroy();
    flag.AssertUnset();
end;

function Suite:TestSingletonAsset()
    local obj = OOP.Class():New();
    local asset = Assets.Singleton(Assets.Flag());

    local a = asset(obj, "AddDestructor");
    local b = asset(obj, "AddDestructor");

    assert(a == b, "Singleton returns identical assets");

    obj:Destroy();

    obj = OOP.Class():New();
    local c = asset(obj, "AddDestructor");
    assert(a ~= c, "Destruction will reset the singleton");
end;

function Suite:TestUndoerAsset()
    local obj = OOP.Class():New();

    local undoer = Assets.Undoer()(obj, "AddDestructor");

    local flag = Tests.Flag();
    undoer(flag.Raise);
    obj:Destroy();
    flag.Assert();
end;

function Suite:TestFactoryAsset()
    local obj, factory
        = GetObjAndAsset(Assets.Factory(Assets.Flag()));
    local f = factory();
    f.Raise();
    obj:Destroy();
    f.AssertUnset();
end;

-- vim: set et :
