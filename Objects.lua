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
    require "Metatables";
    require "Assert";
    require "Strings";
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
    local holder;
    holder = Metatables.ForceFunctions({
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

        Change = function(newValue)
            return Functions.OnlyOnce(holder.Set, holder.Set(newValue));
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
            return Assert.Equals(expectedValue, value, assertion);
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
        end,

        Clear = function()
            return holder.Set(nil);
        end
    });

    -- Aliases
    holder.CurrentValue = holder.Get;
    holder.SetCurrentValue = holder.Get;

    holder.SetValue = holder.Set;
    holder.SetCurrentValue = holder.Set;

    holder.AssertValue = holder.Assert;
    holder.AssertCurrentValue = holder.Assert;

    holder.Reset = holder.Clear;

    getmetatable(holder).__call=holder.Value;

    return holder;
end;

local toggleAliases={
    ["yes"]   ="on",
    ["on"]    ="on",
    ["true"]  ="on",
    ["1"]     ="on",
    ["start"] ="on",

    ["no"]   ="off",
    ["off"]  ="off",
    ["false"]="off",
    ["nil"]  ="off",
    ["0"]    ="off",
    ["stop"] ="off",

    [""]      ="toggle",
    ["toggle"]="toggle",
    ["switch"]="toggle",
    ["next"]  ="toggle"
}
local function InterpretState(state)
    if type(state)=="string" then
        state=Strings.Trim(state)
        local convertedState=toggleAliases[state:lower()];
        assert(convertedState, "Unrecognized state: "..state);
        return convertedState;
    elseif IsCallable(state) then
        return InterpretState(state());
    else
        if state then
            return "on";
        else
            return "off";
        end
    end;
end;

function Objects.Toggle(func, ...)
    local resetter;
    if not IsCallable(func) and select("#", ...)==0 then
        if InterpretState(func)=="on" then
            resetter=Noop;
        end;
        func=Noop;
    elseif func==nil and select("#",...)==0 then
        func=Noop;
    else
        func=Curry(func, ...);
    end;
    local toggle=Metatables.ForcedFunctions();

    function toggle.IsOn()
        -- If we have a resetter, we're on.
        if resetter then
            return true;
        else
            return false;
        end;
    end;
    toggle.IsSet=toggle.IsOn;
    toggle.GetStatus=toggle.IsOn;
    toggle.GetState=toggle.IsOn;
    toggle.Get=toggle.IsOn;

    function toggle.IsOff()
        return not toggle.IsOn();
    end;

    function toggle.On()
        if toggle.IsOn() then
            return toggle.Off;
        end;
        resetter=func();
        if not IsCallable(resetter) then
            resetter=Noop;
        end;
        return toggle.Off;
    end;
    toggle.TurnOn=toggle.On;

    function toggle.Off()
        if toggle.IsOff() then
            return toggle.On;
        end;
        resetter();
        resetter=nil;
        return toggle.On;
    end;

    function toggle.Toggle()
        if toggle.IsOn() then
            return toggle.Off();
        else
            return toggle.On();
        end;
    end;
    toggle.Switch=toggle.Toggle;
    toggle.Next=toggle.Toggle;
    toggle.Go=toggle.Toggle;
    toggle.Fire=toggle.Toggle;

    function toggle.State(state)
        if state == nil then
            return toggle.IsOn();
        else
            return toggle.Set(state);
        end;
    end;
    toggle.Status=toggle.State;
    toggle.Value=toggle.State;

    function toggle.Set(state)
        state=InterpretState(state);
        if     state=="on"     then return toggle.On();
        elseif state=="off"    then return toggle.Off();
        else                        return toggle.Toggle();
        end;
    end;
    toggle.To=toggle.Set;
    toggle.Turn=toggle.Set;
    toggle.SwitchTo=toggle.Set;

    function toggle.Assert(expectedState, assertion)
        if assertion then
            assertion=(" for assertion '%s'"):format(assertion);
        else
            assertion="";
        end;
        if expectedState==nil then
            expectedState=true;
        end;
        expectedState=InterpretState(expectedState);
        if expectedState=="on" then 
            expectedState=true;
        else
            expectedState=false;
        end;
        assert(expectedState==toggle.State(), 
            ("Toggle must be %s, but was %s%s"):format(tostring(expectedState), tostring(toggle.State()), assertion));
    end;

    function toggle.AssertTrue(assertion)
        return toggle.Assert(true, assertion);
    end;
    toggle.AssertOn=toggle.AssertTrue;

    function toggle.AssertFalse(assertion)
        return toggle.Assert(false, assertion);
    end;
    toggle.AssertOff=toggle.AssertFalse;
    
    getmetatable(toggle).__call=toggle.State;

    return toggle;
end;
Objects.Switch=Objects.Toggle;
