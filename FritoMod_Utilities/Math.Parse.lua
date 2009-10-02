local states = {};

-- Numeric specials are the least flexible of any number, and can only
-- be used on their own.
states.specials = States.TableLookup({
    zero = 0
}, Noop);
states.specials.Transition = {};

states.numbers = {
    Check = function(self, value)
        value = tonumber(value);
        if not value then
            return false;
        end;
        if value > 1000 then
            return false;
        end;
        return true;
    end,
    Act = function(self, value)
        self:Stage(tonumber(value));
    end,
    Transition = "magnitudes";
};

-- Numeric singles are single digits. They can modify both magnitudes and regular 
-- numerics.
states.singles = States.TableLookup({
    one = 1,
    two = 2,
    three = 3,
    four = 4,
    five = 5,
    six = 6,
    seven = 7,
    eight = 8,
    nine = 9,
}, "Stage");
states.singles.Transition = {"magnitudes", "regulars", "flexibleMagnitudes"};

-- Numeric irregulars are irregular multi-digit numbers. They can modify magnitudes but
-- are not allowed singles.
states.irregulars = States.TableLookup({
    ten = 10,
    eleven = 11,
    twelve = 12,
    thirteen = 13,
    fourteen = 14,
    fifteen = 15,
    sixteen = 16,
    seventeen = 17,
    eighteen = 18,
    nineteen = 19
}, "Stage");
states.irregulars.Transition = "magnitudes";

-- Numeric regulars are the regular multi-digit numbers. They can modify magnitudes and are
-- allowed singles.
states.regulars = States.TableLookup({
    twenty = 20,
    thirty = 30,
    forty = 40,
    fifty = 50,
    sixty = 60,
    seventy = 70,
    eighty = 80,
    ninety = 90,
}, "Stage");
states.regulars.Transition = {"magnitudes", "singles"};

-- Numeric qualifiers modify numeric values. They are exclusive to one another, and must be
-- used before any other number.
states.qualifiers = States.TableLookup({
    minus = -1,
    negative = -1,
    positive = 1,
    half = .5,
    quarter = .25,
}, "SetQualifier");
states.qualifiers.Transition = function(stateContext)
    stateContext:DeactivateAllStates();
    stateContext:ActivateState("initial");
    stateContext:DeactivateState("qualifiers");
end;

-- Flexible magnitudes are related to magnitudes, but also can act like regulars.
states.flexibleMagnitudes = States.TableLookup({
    hundred = 100,
}, "Stage");
states.flexibleMagnitudes.Transition = {"regulars", "irregulars", "singles", "magnitudes"};

-- Numeric magnitudes can stand on their own, but are also allowed to modify other values. They
-- cannot, however, modify each other.
states.magnitudes = States.TableLookup({
    dozen = 12,
    thousand = 1000,
    million = 10 ^ 6,
    billion = 10 ^ 9,
    trillion = 10 ^ 12,
}, "Magnitude");
states.magnitudes.Transition = {"regulars", "irregulars", "singles"};

states.initial = {"numbers", "magnitudes", "flexibleMagnitudes", "regulars", "irregulars", "singles", "specials", "qualifiers"};

function Math.Parse(number)
    if type(number) == "number" then
        return number;
    end;
    if tonumber(number) then
        return tonumber(number);
    end;
    assert(type(number) == "string", "number is not a string or number. Type: " .. type(number));
    local builder = NumberBuilder:New();
    local stateMachine = StateMachine:New(states, builder);
    stateMachine:ActivateState("initial");
    for word in number:gmatch("[^- ,]+") do
        word = word:lower();
        if word ~= "and" then
            assert(stateMachine:Feed(word), "Value not handled: " .. word);
        end;
    end;
    return builder:GetValue();
end;

local timeMagnitudes = {
    millisecond = 1,
    second = 1000,
    minute = 1000 * 60,
    hour = 1000 * 60 * 60,
    day = 1000 * 60 * 60 * 24,
};

function Math.ParseTime(time)
    if type(number) == "number" then
        return number;
    end;
    if tonumber(number) then
        return tonumber(number);
    end;
    assert(type(number) == "string", "number is not a string or number. Type: " .. type(number));
    local builder = NumberBuilder:New();
    local stateMachine = StateMachine:New(states, builder);
    stateMachine:ActivateState("initial");
    local time = 0;
    local lastMagnitude = nil;
    for word in number:gmatch("[^- ,]+") do
        word = word:lower();
        local magnitude = timeMagnitudes[word] or timeMagnitudes[word:sub(1, #word - 1)];
        if magnitude then
            assert(not lastMagnitude or lastMagnitude > magnitude, "Magnitude is out of sequence: " .. word);
            local value = builder:GetValue();
            assert(value > 0, "Value is zero");
            time = time + value * magnitude;
            builder:Clear();
        elseif word ~= "and" then
            assert(stateMachine:Feed(word), "Value not handled: " .. word);
        end;
    end;
    local value = builder:GetValue();
    return time + value;
end;

