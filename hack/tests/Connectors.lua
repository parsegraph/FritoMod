if nil ~= require then
    require "hack/Assets";
end;

local Suite = CreateTestSuite("hack.Connectors");

local Assets = Hack.Assets;
local Connectors = Hack.Connectors;

function Suite:TestGlobalConnector()
    local env = LuaEnvironment:New();

    local connector = Connectors.Global("foo",
        Assets.Flag());

    connector(env);

    env:Run(function()
        foo.Raise();
    end);
    local f = env:Get("foo");
    f:Assert();
    env:Destroy();
    f:AssertUnset();
end;

function Suite:TestMemberConnector()
    local env = LuaEnvironment:New();

    env:Run(function()
        foo = {};
        foo.bar = {};
        foo.bar.baz = OOP.Class();
    end);

    local connector = Connectors.Member("foo.bar.baz", "xen",
        Assets.Flag());
    connector(env);

    local a, b;
    env:Run(function()
        a = foo.bar.baz:New();
        b = foo.bar.baz:New();
    end);
    assert(a);
    assert(a.xen);
    a.xen.Raise();
    local aflag = a.xen;

    assert(b);
    assert(b.xen);
    b.xen.AssertUnset();
    b.xen.Raise();
    local bflag = b.xen;

    a:Destroy();
    aflag.AssertUnset();
    bflag.Assert();

    b:Destroy();
    bflag.AssertUnset();
end;

function Suite:TestLazyConnector()
    local env = LuaEnvironment:New();

    local counter = Tests.Counter(0);
    local flagAsset = Assets.Flag();
    local connector = Connectors.Lazy("foo", function(dtor, ...)
        counter.Hit();
        return flagAsset(dtor, ...);
    end);

    connector(env);

    env:Run(function()
        foo.Raise();
    end);
    local f = env:Get("foo");
    f:Assert();
    env:Run(function()
        foo.Assert();
    end);
    env:Destroy();
    f:AssertUnset();
    counter.Assert(1);
end;

function Suite:TestFactoryAsset()
    local env = LuaEnvironment:New();
    local connector = Connectors.Global("foo",
        Assets.Factory(Assets.Flag()));
    connector(env);
    local f;
    env:Run(function()
        f = foo()
    end);
    f.Raise();
    env:Destroy();
    f.AssertUnset();
end;

function Suite:TestProxyConnector()
    local env = LuaEnvironment:New();

    local proxyCounter = Tests.Counter(0);
    local runCounter = Tests.Counter(0);
    local flagAsset = Assets.Flag();
    local connector = Connectors.Proxy("foo", function(dtor, ...)
        proxyCounter.Hit();
        return flagAsset(dtor, ...);
    end);

    connector(env);

    local a;
    env:Run(function()
        a = foo;
        runCounter.Hit();
    end);
    proxyCounter.Assert(1);
    runCounter.Assert(1);

    local b;
    env:Run(function()
        b = foo;
        runCounter.Hit();
    end);
    proxyCounter.Assert(2);
    runCounter.Assert(2);

    a.Raise();
    b.Raise();
    assert(a ~= b);
end;

-- vim: set et :
