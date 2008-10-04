Environment = OOP.Class(LogMixin, OOP.Singleton);

-- Runlevels formalize the level of functionality that you can expect from the framework at any given
-- time.
--
-- Initializers should be assigned to the level they qualify some component for. In other words, a
-- function added at the NASCENT level expects everything to be in the UNBORN level, and does something
-- to make some component qualify for the NASCENT level of functionality.
--
-- Therefore, no initializers are allowed at the UNBORN level, since the framework starts at that level
-- of functionality (which is none).
--
-- I describe run-levels here to two separate audiences: core and non-core component developers. The 
-- difference is mostly arbitrary, but there are some guidelines. If your compoonent has heavy reliance
-- on many parts of the framework, it's not a core component. If it's not essential for some other
-- feature that other components use, it's not a core component.
--
-- Not being a core component is not a bad thing, of course - in fact, non-core components are much less
-- restricted in the functionality they can expect when they're initialized, whereas core components'
-- failure, due to their coupling with other components, can cause serious problems.
--
-- Also, these levels define the minimum level of preparedness for any given component. If a component
-- has no initialization or interdependence, then it's at the SAFE stage even in the UNBORN stage. More
-- importantly, a component only has to provide functionality at the given levels when requested - lazy
-- initialization is allowed, even encouraged in many cases, as long as the design decision works and 
-- is subtle. If your component is heavy, it's best to get it done with in the initialization cycle, 
-- rather than lazily.
Environment.runLevels = {
    UNBORN = 1, -- Inhospitable
    -- This is the starting level of readiness for the framework, and as such, no component should 
    -- expect any guarantee of functionality beyond the builtins and included code in the framework. 
    -- Any attempt to use the framework at this level is allowed to Fail Miserably.
    --
    -- If you're writing core components, you should run any independent initialization at this
    -- point. Independent initialization means that you should initialize your component to be used,
    -- but should _not_ make connections with any other part of the framework.
    --
    -- If you're writing non-core components, do nothing.

    NASCENT = 2, -- Functional but Unsanitary
    -- NASCENT means core components are functioning, though interdependencies may not yet be 
    -- established. Interdependencies include logging syndication, UI creation, listener registration
    -- for events, etc. Simply put, the framework works, but may look like it doesn't if it's used at this
    -- stage.
    --
    -- Core components should make any connections they see fit, but keep general operations waiting
    -- until the COMPLETE stage.
    --
    -- If you're writing non-core components, you should do nothing at this stage. If you want, you may
    -- initialize here (or even earlier if you really want to), but the contract here is that non-core
    -- components are given a pristine working environment. Since NASCENT is nowhere near pristine relative
    -- to COMPLETE, it's best to wait until that time.

    COMPLETE = 3, -- General Operations
    -- COMPLETE means all core components have completed everything involving their initialization. The
    -- very worst case would be items that are initialized on the first iteration, but this initialization
    -- should be totally transparent to the rest of the framework. The core framework is completely 
    -- operational. 
    --
    -- Non-core components may initialize at this time, though interdependencies between non-core components
    -- are not guaranteed to be stable. This is an identical situation to what core components are limited to
    -- in the UNBORN stage.

    SAFE = 4,
    -- Safe means that, like COMPLETE, all core components are fully operational and working. It also means that
    -- all non-core components can be accessed freely and interdependencies can be established.
    --
    -- If you're writing non-core components, all connections can be made here. However, like with the NASCENT stage
    -- and core components, you should wait until after this stage is complete due to initializer unpredictablity.
};

Environment.runLevelOrder = {
    Environment.runLevels.UNBORN,
    Environment.runLevels.NASCENT,
    Environment.runLevels.COMPLETE,
    Environment.runLevels.SAFE
};

function Environment:__Init()
    self.bootstrappers = {};
    for _, runLevelName in pairs(Environment.runLevels) do
        self.bootstrappers[runLevelName] = {};
        self.sanitizers[runLevelName] = {};
    end;
    self.delayedCalls = {};
    self.runLevel = Environment.runLevels.UNBORN;
end;

local function RunBootstrapper(self, runLevel, bootstrapperFunc)
    local sanitizer = bootstrapperFunc(runLevel);
    if IsCallable(sanitizer) then
        table.insert(self.sanitizers[runLevel], sanitizer);
    end;
end;

-------------------------------------------------------------------------------
--
--  Public Interface: Bootstrappers
--
-------------------------------------------------------------------------------

function Environment:ChangeRunLevel(runLevel)
    if not LookupValue(Environment.runLevels, runLevel) then
        error("Runlevel is not valid: " .. runLevel);
    end;
    while runLevel ~= self.runLevel do
        if self.runLevel < runLevel then
            for _, bootstrapperFunc in self.bootstrapper[runLevel] do
                RunBootstrapper(self, runLevel, bootstrapperFunc);
            end;
            self.runLevel = self.runLevel + 1;
        else
            self.runLevel = self.runLevel - 1;
            local sanitizers = self.sanitizers[runLevel];
            while #sanitizers do
                local sanitizer = table.remove(sanitizers);
                sanitizer(runLevel);
            end;
        end;
    end;
end;

function Environment:AddBootstrapper(runLevel, bootstrapperFunc, ...)
    if runLevel == Environment.runLevels.UNBORN then
        error("Cannot have any bootstrappers that run at the lowest level.");
    end;
    bootstrapperFunc = ObjFunc(bootstrapperFunc, ...);
    if runLevel <= self.runLevel then
        RunBootstrapper(self, runLevel, bootstrapperFunc);
    end;
    table.insert(self.bootstrappers[runLevel], bootstrapperFunc);
end;

------------------------------------------
--  Miscellaneous
------------------------------------------

function Environment:RunTests()
    local testManager = TestManager.GetInstance();
    local releaser = testManager:SyndicateTo(self);
    testManager:Run();
    releaser();
end;

-------------------------------------------------------------------------------
--
--  Delayed Call Methods
--
-------------------------------------------------------------------------------

function Environment:CallLater(delayedFunc, ....)
    delayedFunc = ObjFunc(delayedFunc, ...);
    table.insert(self.delayedCalls);
end;

function Environment:FlushDelayed()
    while #self.delayedCalls do
        local delayedCall = table.remove(self.delayedCalls);
        delayedCall();
    end;
end;
