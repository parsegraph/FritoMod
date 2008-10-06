Environment = OOP.Class(LogMixin, OOP.Singleton);

-------------------------------------------------------------------------------
--
--  Runlevels
--
-------------------------------------------------------------------------------
--
-- Runlevels formalize two concepts vital to the successful use of the framework: 
-- The level of functionality to expect, and the suggested order of component 
-- deployment.

-- WHY RUNLEVELS? 
--
-- With such a diverse framework as this is, problems can arise over when any given 
-- component can be considered "ready." To further complicate matters, discrepancies 
-- can appear when a component is "ready" but has not yet been "deployed." An example 
-- of a non-ready component is one who has not yet created its attributes yet, but
-- an attempt is made to access them. To combat this, the component must either 
-- initialize as immediately as possible, or do so just-in-time. Both strategies can 
-- run into race conditions, and can unnecessarily bloat the framework, either in 
-- consumption of resources or in seemingly random performance drops as the component
-- is initialized on-demand.
--
-- With a formal set of steps to initialize the framework, we provide components with 
-- another strategy to handle initialization, and to minimize race conditions and 
-- unexpected behavior due to haphazardly initalized components.
--
-- That said, components do not have to use this system solely to initialize themselves; 
-- runLevels augment, not replace, existing practices of initialization, such as lazy 
-- and overeager initialization. You may use whatever method seems most appropriate 
-- to create your components.
--
-- However, while initialization using this system isn't required, every component must 
-- comply with the guarantees made at any given runLevel. If any alternative method is 
-- used, it must be transparent to the end-user.

-------------------------------------------------------------------------------
--
-- INITIALIZATION AND DEPLOYMENT
--
-------------------------------------------------------------------------------
--
-- All components undergo a two-phase initialization process: Initialization and 
-- deployment. All components are initialized first, then all components deploy 
-- themselves. The distinction here is dependency, and is best shown by explaining 
-- the phases:
--
-- During the first phase, initialization, all components prepare themselves to be 
-- deployed and to receive dependencies from other components. There is, however, 
-- no dependencies actually made during this phase.
--
-- The second phase, deployment, is where interdependencies and connections are 
-- established. You may safely assume during this phase that the entire framework 
-- is available to be utilized.

-------------------------------------------------------------------------------
--
-- CORE AND AUXILLARY COMPONENTS
--
-------------------------------------------------------------------------------
--
-- The problem with just having two phases involves this conundrum: How do you 
-- guarantee a fully functional framework for any one component to initialize, 
-- when the framework relies on that component to provide some functionality? We 
-- avoid this problem partially by using a two-phase initialization process; 
-- components have no interdependency during the first phase, so the order of 
-- initialization is irrelevant.
--
-- The second phase, deployment, is where problems arise. If you don't know 
-- whether the core parts (or any part) of the framework are fully deployed, 
-- you can be surprised by the strange results that crop up (most often due to
-- uninitialized data and missing listener connections between components).
--
-- To fight this inconsistent and invalid behavior, we divide components into 
-- two groups: core and auxillary. The essentials of the framework are core 
-- components, whereas dependents are auxillaries. We guarantee that any auxillary 
-- deployment will occur with a fully deployed core framework underneath it. This 
-- means that everyday component designers don't have to worry about whether some 
-- critical part of the framework is or isn't ready.
--
-- A consequence is that designers must cateogrize their component as either core 
-- or auxillary. Do so with care since a bad choice will make the initialization 
-- process awkward for any dependents. There's no hard and fast rules on what makes a
-- component one or the other; generally, core components have more fan-out than 
-- fan-in with regard to dependencies, and auxillary components are the reverse. 
-- Core components never depend on auxillary components. An auxillary component is 
-- not 'essential' except to (a few) other auxillary components. 

-------------------------------------------------------------------------------
--
-- MAKING BOOTSTRAPPERS
--
-------------------------------------------------------------------------------
--
-- Follow the contracts guaranteed by each runlevel. You should assign a boostrapper 
-- to the level it's intended to accomplish. (i.e, bootstrappers that do initial 
-- work on a component are assigned to the INITIALIZE level, whereas a Addon channel 
-- connection is made in the deployment stage.) After all bootstrappers are executed,
-- the framework should be completely finished and require no additional work to lift 
-- itself to the next runlevel. Simply put, be atomic and consistent with the guidelines.

-------------------------------------------------------------------------------
--
--A FINAL WORD
--
-------------------------------------------------------------------------------
--
-- Judgment over what is and isn't done at any point is ultimately up to the developer. 
-- The guarantees made here must always be kept, but the manner used to achieve them 
-- is irrelevant to the contract. Therefore, initialization or deployment of some 
-- component may occur later than what's said here, but _only_ if the result is 
-- transparent to the contracts. These cases should be the exception.
--
-- Be aware also that these phases are cumulative. Each runlevel guarantees all that 
-- the previous runlevels guaranteed, and no runlevel can be rolled back without 
-- rolling back any dependent runlevels first.

Environment.runLevels = {
    PREINITIALIZE = 1, 
    -- Expect nothing at this stage. Any attempt to use the framework at this level 
    -- is considered "unexpected" and may Fail Miserably. Since this level cannot be 
    -- advanced to, no bootstrappers can be assigned at this point.

    INITIALIZE = 2, 
    -- Unless guaranteed separately to be at some prepared state, this is equivalent 
    -- to the PREINITIALIZE state in terms of what to expect at the start. Bootstrappers 
    -- assigned here initialize all components, but make no inter-component connections 
    -- of any kind. By the end of this stage, every component is usable, but its fully-
    -- functional behavior may not be established.

    DEPLOY_CORE = 3,
    -- This stage guarantees that all components are initialized, and connections may 
    -- be made amongst all of them. However, connections cannot be expected amongst any 
    -- of them. Core components should be fully operational at the end of this stage, 
    -- but auxillary components should do nothing here.

    DEPLOY_AUXILLARY = 4,
    -- This stage guarantees a sane and consistent core framework for all components. 
    -- Bootstrappers may safely access this side and expect consistently clean results. 
    -- As such, core components do nothing past this phase. Auxillary components must 
    -- be fully deployed at the end of this stage.

    SAFE = 5,
    -- Finalize any initialization of whatever has been done. Initialization at this 
    -- phase is 100% complete, and the framework is now completely event-driven. This, 
    -- like PREINITIALIZE, has no requirements or expectations, and therefore is more of
    -- a guarantee's guarantee, rather than a real runlevel.
};

Environment.runLevelOrder = {
    Environment.runLevels.PREINITIALIZE,
    Environment.runLevels.INITIALIZE,
    Environment.runLevels.DEPLOY_CORE,
    Environment.runLevels.DEPLOY_AUXILLARY,
    Environment.runLevels.SAFE,
};

-- Bootstrappers are class-wide.
Environment.bootstrappers = {};
for _, runLevelName in pairs(Environment.runLevels) do
    Environment.bootstrappers[runLevelName] = {};
end;

Environment.environments = {};

function ComponentSingleton(class)
    class.GetInstance = function()
        local environment = Environment:GetCurrentEnvironment();
        return environment:GetComponent(class) or environment:SetComponent(class());
    end;
    return function()
        local environment = Environment:GetCurrentEnvironment();
        if environment:GetComponent(class) then
            error("Component Singletons can only be instantitated once per Environment.");
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Public Static Interface: Bootstrappers
--
-------------------------------------------------------------------------------

local function RunBootstrapper(environment, runLevel, bootstrapperFunc)
    local sanitizer = bootstrapperFunc(runLevel, environment);
    if IsCallable(sanitizer) then
        table.insert(environment.sanitizers[runLevel], sanitizer);
    end;
end;

function Environment:AddBootstrapper(runLevel, bootstrapperFunc, ...)
    if not runLevel then
        error("Falsy runLevel!");
    end;
    if runLevel == Environment.runLevels.PREINITIALIZE then
        error("Cannot have any bootstrappers that run at the lowest level.");
    end;
    bootstrapperFunc = ObjFunc(bootstrapperFunc, ...);
    table.insert(Environment:GetBootstrappers(runLevel), bootstrapperFunc);
    local releaser = Environment.SetCurrentEnvironment(nil);
    for _, environment in ipairs(Environment.environments) do
        Environment.SetCurrentEnvironment(environment);
        if runLevel <= environment:GetRunLevel() then
            RunBootstrapper(environment, runLevel, bootstrapperFunc);
        end;
    end;
    releaser();
end;

function Environment:GetBootstrappers(runLevel)
    local bootstrappers = Environment.bootstrappers[runLevel];
    if not bootstrappers then
        error(format("Invalid runLevel '%s'", tostring(runLevel)));
    end;
    return bootstrappers;
end;

-------------------------------------------------------------------------------
--
--  Public Static Methods: Environment
--
-------------------------------------------------------------------------------

function Environment:GetCurrentEnvironment()
    return Environment.currentEnvironment;
end;

function Environment:SetCurrentEnvironment(environment)
    local oldEnvironment = environment;
    Environment.currentEnvironment = environment;
    return function()
        Environment:SetCurrentEnvironment(oldEnvironment);
    end;
end;

-------------------------------------------------------------------------------
--
--  Public Methods: Environment
--
-------------------------------------------------------------------------------

function Environment:GetComponent(componentKey)
    return self.components[componentKey];
end;

function Environment:SetComponent(component, componentKey)
    componentKey = componentKey or component.__class;
    self.components[componentKey] = component;
    return component;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Environment:__Init()
    for _, runLevelName in pairs(Environment.runLevels) do
        self.sanitizers[runLevelName] = {};
    end;
    self.delayedCalls = {};
    self.runLevel = Environment.runLevels.PREINITIALIZE;
    table.insert(Environment.environments, self);
end;

function Environment:RunTests()
    local testManager = TestManager.GetInstance();
    local releaser = testManager:SyndicateTo(self);
    testManager:Run();
    releaser();
end;

-------------------------------------------------------------------------------
--
--  Public Interface: Bootstrappers
--
-------------------------------------------------------------------------------

function Environment:Bootstrap()
    return self:ChangeRunLevel(Environment.runLevels.SAFE);
end;

function Environment:Shutdown()
    return self:ChangeRunLevel(Environment.runLevels.PREINITIALIZE);
end;

function Environment:ChangeRunLevel(runLevel)
    if not LookupValue(Environment.runLevels, runLevel) then
        error("Runlevel is not valid: " .. runLevel);
    end;
    while runLevel ~= self.runLevel do
        if self.runLevel < runLevel then
            local pendingRunLevel = self.runLevel + 1;
            local bootstrappers = self:GetBootstrappers(self:GetRunLevel());
            for _, bootstrapperFunc in bootstrappers[pendingRunLevel] do
                RunBootstrapper(self, pendingRunLevel, bootstrapperFunc);
            end;
            self.runLevel = pendingRunLevel;
        else
            local sanitizers = self.sanitizers[self.runLevel];
            self.runLevel = self.runLevel - 1;
            while #sanitizers do
                local sanitizer = table.remove(sanitizers);
                sanitizer(self.runLevel);
            end;
        end;
    end;
end;

function Environment:GetRunLevel()
    return self.runLevel;
end;

-------------------------------------------------------------------------------
--
--  Delayed Call Methods
--
-------------------------------------------------------------------------------

function Environment:CallLater(delayedFunc, ...)
    delayedFunc = ObjFunc(delayedFunc, ...);
    table.insert(self.delayedCalls);
end;

function Environment:FlushDelayed()
    while #self.delayedCalls do
        local delayedCall = table.remove(self.delayedCalls);
        delayedCall();
    end;
end;
