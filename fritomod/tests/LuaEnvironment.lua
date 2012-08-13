local Suite = CreateTestSuite("fritomod.LuaEnvironment");

do
    local g1, g2, g3;
    Suite:AddListener(Metatables.Noop({
        TestStarted = function(self, suite)
            g1 = __g1;
            g2 = __g2;
            g3 = __g3;
        end,
        TestFinished = function(self, suite)
            __g1 = g1;
            __g2 = g2;
            __g3 = g3;
        end
    }));
end;

function Suite:TestGlobalEnvironmentIsClean()
    Assert.Nil(__g1);
    Assert.Nil(__g2);
    Assert.Nil(__g3);
end;

function Suite:TestSimpleEnvironment()
    local env = LuaEnvironment:New();
    env:Set("__g1", 42);
    Assert.Nil(__g1);
    Assert.Equals(42, env:Get("__g1"));
end;

function Suite:TestLuaEnvironmentShieldsGlobals()
    local env = LuaEnvironment:New();
    env:Run(function()
        __g1 = 43;
    end);
    Assert.Nil(__g1);
    Assert.Equals(43, env:Get("__g1"));
end;

function Suite:TestLuaEnvironmentAcceptsStrings()
    local env = LuaEnvironment:New();
    env:Run([[
        __g1 = 44;
    ]]);
    Assert.Nil(__g1);
    Assert.Equals(44, env:Get("__g1"));
end;
