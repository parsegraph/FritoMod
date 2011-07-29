local Suite=CreateTestSuite("fritomod.Timing");

function Suite:Tick(value)
    self.time=self.time+value;
    Timing._Tick(value);
end;

Suite:AddListener(Metatables.Noop({
	TestStarted = function(self, suite)
        self.oldGetTime=GetTime;
        suite.time=0;
        GetTime=function()
            return suite.time;
        end;
        self.updateListeners={};
        self.deadListeners={};
        self.remover=Timing._Mask(self.updateListeners, self.deadListeners);
	end,
	TestFinished = function(self, suite)
        GetTime=self.oldGetTime;
        self.updateListeners=nil;
        self.deadListeners=nil;
        self.remover();
	end
}));

function Suite:TestTiming()
    local v=Tests.Value();
    local r=Timing.OnUpdate(v.Set);
    self:Tick(1);
    v.Assert(1);
    r();
    self:Tick(2);
    v.Assert(1);
end;

function Suite:TestPeriodicTimer()
    local c=Tests.Counter();
    local r=Timing.Periodic(1, c);
    self:Tick(1);
    c.Assert(1);
    self:Tick(1.25);
    c.Assert(2);
    self:Tick(.75);
    -- Periodic timers start counting from their last iteration, not from
    -- their first iteration.
    c.Assert(2);
    self:Tick(.25);
    -- Once we give the periodic timer the rest of the time, it fires.
    c.Assert(3);
    -- Periodic timers don't burst, so they'll miss beats.
    self:Tick(4);
    c.Assert(4);
end;

function Suite:TestRhythmicTimer()
    local c=Tests.Counter();
    local r=Timing.Rhythmic(1, c);
    self:Tick(1);
    c.Assert(1);
    self:Tick(1.25);
    c.Assert(2);
    self:Tick(.75);
    -- Rhythmic timers keep count from their first iteration, so it will have a shorter
    -- period here to "catch" up.
    c.Assert(3);
    self:Tick(1);
    -- Now that our rhythmic timer has caught up, it's back on track.
    c.Assert(4);
    self:Tick(4);
    -- Rhythmic timers will still miss beats, though.
    c.Assert(5);
end;

function Suite:TestBurstTimer()
    local c=Tests.Counter();
    local r=Timing.Burst(2, c);
    self:Tick(1);
    c.Assert(0);
    self:Tick(1);
    c.Assert(1);
    c.Reset();
    self:Tick(4);
    c.Assert(2);
end;

function Suite:TestThrottledTime()
    local c=Tests.Value();
    local f=Timing.Throttle(2, c);
    f(1);
    f(2);
    f(3);
    c.Assert(nil);
    self:Tick(2);
    c.Assert(1);
    self:Tick(2);
    c.Assert(2);
    f(POISON);
    self:Tick(2);
    c.Assert(2);
end;

function Suite:TestDelayTimerDelaysAFunctionCall()
    local v=Tests.Value();
    local f=Timing.After(2, v.Set, true);
    self:Tick(1);
    v.Assert(nil);
    -- Reset it to wait 2 more seconds.
    f();
    self:Tick(1);
    v.Assert(nil);
    self:Tick(1);
    v.Assert(true);
    v.Reset();
    self:Tick(100);
    -- Once our timer has fired, it's irrecoverably dead.
    v.Assert(nil);
end;

function Suite:TestDelayTimerCanBeDelayedWithAValue()
    local v=Tests.Value();
    local f=Timing.After(2, v.Set, true);
    self:Tick(1);
    -- Wait 2 seconds beyond what we're currently waiting.
    f(2);
    self:Tick(2);
    -- It's nil here because we still have another second from
    -- our original delay.
    v.Assert(nil);
    self:Tick(1);
    -- Done!
    v.Assert(true);
end;

function Suite:TestDelayTimerCanBePoisoned()
    local v=Tests.Value();
    local f=Timing.After(2, v.Set, true);
    -- Timer is poisoned, so it dies irrecoverably.
    f(POISON);
    self:Tick(100);
    v.Assert(nil);
end;

function Suite:TestCooldown()
    local c=Tests.Counter(0);
    local f=Timing.Cooldown(3, c);
    f();
    -- The first call is not on cooldown.
    c.Assert(1);
    f();
    f();
    f();
    -- We're on cooldown, so our counter doesn't move.
    c.Assert(1);
    self:Tick(3);
    -- We coalesce calls, so now that our cooldown is complete, the implicit call will
    -- fire.
    c.Assert(2);
    f();
    -- Invocations due to cooldown put us on cooldown, just like user-initiated ones.
    c.Assert(2);
end;

function Suite:TestCycleValues()
    local t=Timing.CycleValues(1, "a", "b", "c");
    -- Nudge time a bit, since CycleValues prefers previous elements on border cases.
    self:Tick(.1);
    Assert.Equals("a", t());
    -- It's based on time, so instantaneous invocations return the same result.
    Assert.Equals("a", t());
    self:Tick(1);
    Assert.Equals("b", t());
    self:Tick(2);
    Assert.Equals("a", t());
end;
