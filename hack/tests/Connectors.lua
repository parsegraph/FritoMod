if nil ~= require then
    require "fritomod/CreateTestSuite";
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

    env:Run([[
        foo.Raise();
    ]]);
    local f = env:Get("foo");
    f:Assert();
    env:Destroy();
    f:AssertUnset();
end;

function Suite:TestMemberConnector()
    local env = LuaEnvironment:New();

    env:Run([[
        foo = {};
        foo.bar = {};
        foo.bar.baz = OOP.Class();
    ]]);

    local connector = Connectors.Member("foo.bar.baz", "xen",
        Assets.Flag());
    connector(env);

    env:Run([[
        a = foo.bar.baz:New();
        b = foo.bar.baz:New();
    ]]);
    local a = env:Get("a");
    assert(a);
    assert(a.xen);
    a.xen.Raise();
    local aflag = a.xen;

    local b = env:Get("b");
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

    env:Run([[
        foo.Raise();
    ]]);
    local f = env:Get("foo");
    f:Assert();
    env:Run([[
        foo.Assert();
    ]]);
    env:Destroy();
    f:AssertUnset();
    counter.Assert(1);
end;

function Suite:TestFactoryAsset()
    local env = LuaEnvironment:New();
    local connector = Connectors.Global("foo",
        Assets.Factory(Assets.Flag()));
    connector(env);
    env:Run([[
        f = foo()
    ]]);
    local f = env:Get("f");
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

    env:Set("runCounter", runCounter);

    env:Run([[
        a = foo;
        runCounter.Hit();
    ]]);
    local a = env:Get("a");
    proxyCounter.Assert(1);
    runCounter.Assert(1);

    env:Run([[
        b = foo;
        runCounter.Hit();
    ]]);
    local b = env:Get("b");
    proxyCounter.Assert(2);
    runCounter.Assert(2);

    a.Raise();
    b.Raise();
    assert(a ~= b);
end;

-- vim: set et :
