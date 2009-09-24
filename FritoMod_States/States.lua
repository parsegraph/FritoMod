-- States contains methods to perform state-based operations. It allows clients to clearly define separate
-- states while managing the transitions between them. 
--
-- A few terms are consistently used in this framework: understanding them will aid clients in understanding how
-- to use this framework. They are defined in readme.txt

States = {};
local States = States;

local function IsStateGroup(candidate)
    return candidate and type(candidate) == "table" and #candidate > 0;
end;

-- Checks whether the state at the specified name in the specified schema is valid. The rules behind
-- state validity are dependent on the type of state; all rules are defined in the readme included
-- with this addon.
--
-- schema
--     the schema that contains a state for the specified stateName
-- stateName
--     the name of the state
-- throws
--     if the state is not valid at the specified stateName
local function CheckState(schema, stateName)
    local state = schema[stateName];
    assert(state, "State is falsy");
    if IsStateGroup(state) then
        -- It's a State group
        for i=1, #state do
            CheckState(schema, state[i]);
        end;
        return;
    elseif type(state) == "table" then
        -- It's a State object
        assert(type(state.Check) == "function", "State.Check is not a function. Type: " .. type(state.Check));
        assert(type(state.Act) == "function", "State.Act is not a function. Type: " .. type(state.Act));
        local transitionType = type(state.Transition);
        assert(transitionType == "string" or transitionType == "function" or transitionType == "table", 
            "State.Transition is not a function, table, or string. Type: " .. transitionType);
    elseif type(state) == "string" then
        -- It's a state alias, so check its target.
        CheckState(schema, state);
    else
        -- It's a state function
        assert(type(state) == "function", "state is not a table or function. Type: " .. type(state));
    end;
end;

-- Asserts that the specified state schema is consistent. The rules behind schemas are defined in the
-- readme included with this addon.
--
-- schema
--     the schema to test
-- throws
--     if the schema is not consistent
--
function States.AssertSchema(schema)
    for stateName, state in pairs(schema) do
        CheckState(schema, stateName);
    end;
end;

-- A State that checks if a specified value is in the specifiedj
function States.TableLookup(map, func, ...)
    func = Curry(func, ...);
    local state = {};

    state.Check = Method(state, Tables.ContainsKey, map);
    state.Act = function(context, value)
        func(context, map[value]);
    end;
    state.Transition = Noop;
    return state;
end;

function Mixins.StateContext(schema)
    assert(schema, "schema is falsy");
    States.AssertSchema(schema);
    return function(class)
        class:AddConstructor(States.StateContext, schema);
    end;
end;

-- Creates a state context object by augmenting the specified target table. Specifically, this adds four methods 
-- that query and modify the active states on the specified target.
--
-- Clients are free to use any table for the target object, as long as there are no preexisting methods on the 
-- target table with the same names as the ones added by this operation.
--
-- schema 
--     a state schema
-- target
--     Optional. The target object that is populated with methods. This target must not already contain any methods
--     with the same names as the ones added by this operation.
--
--     If target is omitted, then a new table is created.
-- returns
--     target
-- throws
--     if the target already contains mappings for any of the function names added by this operation
--     if schema is not consistent, according to States.AssertSchema
function States.StateContext(schema, target)
    States.AssertSchema(schema);
    
    if not target then
        target = {};
    end;

    assert(not target.IterateActiveStates, "IterateActiveStates is already set");
    assert(not target.ActivateState, "ActivateState is already set");
    assert(not target.DectivateState, "DeactivateState is already set");
    assert(not target.DeactivateAllStates, "DeactivateAllStates is already set");

    local activeStates = {};

    -- Iterates over all active states.
    target.IterateActiveStates = Seal(ipairs, activeStates);

    -- Feeds this state context the specified values using the specified context. The active states
    -- will be iterated until a state successfully handles the specified values.
    --
    -- stateContext
    --     the state context object
    -- context
    --     the context object
    -- ...
    --     the values
    -- returns
    --     true if a state successfully handled the specified values, otheriwse false
    --
    function target:Feed(context, ...)
        for _, state in self:IterateActiveStates() do
            if type(state) == "function" then
                local success = state(stateContext, context, ...);
                if success then
                    return true;
                end;
            else
                assert(type(state) == "table", "state is not a table. Type: " .. type(state));
                if state:Check(context, ...) then
                    state:Act(context, ...);
                    if type(state.Transition) == "table" then
                        self:DeactivateAllStates();
                        self:ActivateState(unpack(state.Transition));
                    elseif type(state.Transition) == "string" then
                        self:DeactivateAllStates();
                        self:ActivateState(state.Transition);
                    else
                        state:Transition(self);
                    end;
                    return true;
                end;
            end;
        end;
        return false;
    end;

    -- Activates the specified states.
    --
    -- ...
    --     a list of strings referencing state groups, state aliases, state objects, or state functions.
    -- throws
    --     if a state is not present
    function target:ActivateState(...)
        for i=1, select("#", ...) do
            local stateName = select(i, ...);
            local state = schema[stateName];
            assert(state, "State is not present. Name: " .. stateName);
            if IsStateGroup(state) then
                self:ActivateState(unpack(state));
            elseif type(state) == "string" then
                self:ActivateState(state);
            else
                table.insert(activeStates, state);
            end;
        end;
    end;

    -- Deactivates the specified states.
    --
    -- ...
    --     a list of strings referencing state groups, state aliases, state objects, or state functions.
    -- throws
    --     if a state is not present
    function target:DeactivateState(...)
        for i=1, select("#", ...) do
            local stateName = select(i, ...);
            local state = self:GetState(stateName);
            assert(state, "State is not present. Name: " .. stateName);
            if IsStateGroup(state) then
                self:DeactivateState(unpack(state));
            elseif type(state) == "string" then
                self:DeactivateState(state);
            else
                local removed = 0;
                for i=#activeStates, 1, -1 do
                    if activeStates[i] == state then
                        table.remove(activeStates, i);
                    end;
                end;
            end;
        end;
    end;

    -- Deactivates all states.
    target.DeactivateAllStates = function()
        for i=1, #activeStates do
            table.remove(activeStates);
        end;
    end;

    return target;
end;
