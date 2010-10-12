-- Objects contains simple objects. These objects are simple in that they typically 
-- don't do a whole lot. They're also not metatable-based. The quintessential simple
-- object is a value object. It supports a few useful methods to talk to it, but the
-- object is ultimately humble in its pursuits.
--
-- While these are simple, there's some things I expect from objects here. First, they
-- should all be tables; if you're making a function or closure, put it somewhere else.
-- Second, both method and function invocations should work. In other words, I should be
-- able to do this:
--
-- local f=Objects.Foo();
-- f.Bar("call");
-- f:Bar("call");
--
-- Metatables.ForceFunctions and Metatables.ForceMethods will help you here.
if nil ~= require then
    require "FritoMod_Functional/Metatables";
end;
Objects=Objects or {};

-- Holds a value, allowing functional access to changing it and ways to assert its
-- value.
--
-- The holder's methods can be safely called like functions.
--
-- value:*
--     the initial value of the holder
-- returns:object
--     a holder for the specified value.
function Objects.Value(value)
    local holder = Metatables.ForceFunctions({
        -- Returns the current value.
        --
        -- returns:*
        --     the current value
        Get = function()
            return value;
        end,
        
        -- Sets the holder to contain the specified value.
        --
        -- newValue:*
        --     the new value to hold
        -- returns:*
        --     the old value 
        Set = function(newValue)
            local oldValue = value;
            value = newValue;
            return oldValue; 
        end,

        -- Asserts the current value is equal to the expectedValue, as determined by
        -- Assert.Equals.
        --
        -- expectedValue:*
        --     the expected value. For this function to succeed, it should be equivalent
        --     to the current value according to Assert.Equals
        -- assertion:string
        --     indicates why the current value should be equal to the expected value, or
        --     the significance of why these are equal
        -- returns:*
        --     if successful, returns the current value
        -- throws
        --     if Assert.Equals determines that the values are not equal
        Assert = function(expectedValue, assertion)
            if Assert then
                -- FritoMod_Testing contains a useful Assert function that we can use.
                return Assert.Equals(expectedValue, value, assertion);
            else
                assert(expectedValue==value, "Values are not equal");
            end;
        end,

        -- If newValue is provided, this calls Set with that value. Otherwise, Get is
        -- called.
        --
        -- newValue:*
        --     optional. If provided, the holder's value is set to this value.
        -- returns:*
        --     if newValue was provided, the old value is returned
        --     otherwise, the current value is returned
        Value = function(newValue)
            if newValue ~= nil then
                return holder.Set(newValue);
            end;
            return holder.Get();
        end
    });

    -- Aliases
    holder.CurrentValue = holder.Get;
    holder.SetCurrentValue = holder.Get;

    holder.SetValue = holder.Set;
    holder.SetCurrentValue = holder.Set;

    holder.AssertValue = holder.Assert;
    holder.AssertCurrentValue = holder.Assert;

    return holder;
end;

local toggleAliases={
    on="on",
    ["true"]="on",
    ["1"]="on",

    off="off",
    ["false"]="off",
    ["nil"]="off",
    ["0"]="off",
    [""]="off",

    toggle="toggle",
    switch="toggle",
    next="toggle"
}

function Objects.Toggle(func, ...)
    func=Curry(func, ...);
    local resetter;
    local toggle={};

    function toggle:IsOn()
        -- If we have a resetter, we're on.
        return not resetter;
    end;
    toggle.IsSet=toggle.IsOn;
    toggle.GetStatus=toggle.IsOn;
    toggle.GetState=toggle.IsOn;

    function toggle:IsOff()
        return not toggle:IsOn();
    end;

    function toggle:On()
        if toggle:IsOn() then
            return toggle.Off;
        end;
        resetter=func();
        return toggle.Off;
    end;
    toggle.TurnOn=toggle.On;

    function toggle:Off()
        if toggle:IsOff() then
            return toggle.On;
        end;
        resetter();
        resetter=nil;
        return toggle.On;
    end;

    function toggle:Toggle()
        if toggle:IsOn() then
            return toggle:Off();
        else
            return toggle:On();
        end;
    end;
    toggle.Switch=toggle.Toggle;
    toggle.Next=toggle.Toggle;

    function toggle:State(state)
        if state == nil then
            return toggle:IsOn();
        else
            return toggle:Set(state);
        end;
    end;
    toggle.Status=toggle.State;

    function toggle:Set(state)
        if type(state)=="string" then
            if Strings then
                -- FritoMod_Strings provides useful, but non-essential, trim functionality.
                state=Strings.Trim(state)
            end;
            state=toggleAliases[state:lower()] or state;
            if     state=="on"     then toggle:On();
            elseif state=="off"    then toggle:Off();
            elseif state=="toggle" then toggle:Toggle();
            else
                assert(state, "Unrecognized state: "..state);
            end;
        elseif IsCallable(state) then
            toggle:Set(state());
        else
            if state then
                return toggle:On();
            else
                return toggle:Off();
            end
        end;
    end;
    toggle.To=toggle.Set;
    toggle.Turn=toggle.Set;
    toggle.SwitchTo=toggle.Set;
    toggle.State=toggle.Set;

    return toggle;
end;
