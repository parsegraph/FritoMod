Environment = OOP.Class(LogMixin, OOP.Singleton);

Environment.runLevels = {
    -- The descriptions here describe the level of functionality guaranteed at the _completion_ of the given
    -- stage
    UNBORN = 1, -- No initialization performed. No guarantees of any functionality.
    NASCENT = 2, -- All core functionality is operational, but nothing has been built on top it.
    COMPLETE = 3, -- All functionality should be provided at this point.
    SAFE = 4, -- Everything, absolutely everything, is up.
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
    function Increment()
        if self.runLevel == runLevel then
            return;
        elseif self.runLevel < runLevel then
            self.runLevel = self.runLevel + 1;
        else
            self.runLevel = self.runLevel - 1;
        end;
    end;
    while runLevel ~= self.runLevel do
        for _, bootstrapperFunc in self.bootstrapper[runLevel] do
            RunBootstrapper(self, runLevel, bootstrapperFunc);
        end;
        Increment();
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
        self.delayedCalls[1]();
        table.remove(self.delayedCalls, 1);
    end;
end;
