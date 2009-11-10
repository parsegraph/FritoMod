if nil ~= require then
    require "FritoMod_Functional/basic";
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Functions";

    require "FritoMod_Collections/Lists";
    require "FritoMod_Collections/Functions";
end;

Tests = {};
local Tests = Tests;

do
    local listeners = {};
    Tests.AddErrorListener = Functions.Activator(Functions.FunctionPopulator(listeners), function()
        local oldHandler = geterrorhandler() or Noop;
        local function OurHandler(errorMessage, frame, stack, etype, ...)
            seterrorhandler(oldHandler);
            -- We unhook our handler in case one of *our* handlers fails.
            pcall(Lists.CallEach, listeners, errorMessage, etype, stack, ...);
            seterrorhandler(OurHandler);
            oldHandler();
        end;
        seterrorhandler(OurHandler);
        return Curry(seterrorhandler, oldHandler);
    end);
end;

-- Returns the full stack trace, or up to MAX_STACK_TRACE levels of stack trace information. Each
-- stack level is represented by a table containing information provided by debug.getinfo.
--
-- returns
--     a list of stack levels. Stack levels are in the format specified by debug.getinfo
-- throws
--     if debug.getinfo is not available
local MAX_STACK_TRACE = 999;
function Tests.FullStackTrace()
    assert(debug, "FullStackTrace is not available without debug");
    local stackTrace = {};
    -- We start at 2 instead of 1 since we don't wish to include the FullStackTrace call
    -- in the stack trace.
	for i=2, MAX_STACK_TRACE do
        local stackLevel = debug.getinfo(i);
        if not stackLevel then
            break;
        end;
        if nil == stackLevel.name then
            stackLevel.name = ("<%s:%d>"):format(stackLevel.short_src, stackLevel.linedefined);
            stackLevel.namewhat = "function";
        end;
        table.insert(stackTrace, stackLevel);
    end;
    return stackTrace;
end;

-- Returns a partial stack trace. It returns the head of the stack, and the tail
-- of the stack. The amount of stack levels contained by either element is determined
-- by numHead and numTail. You may also skip some of the head elements, since these
-- are typically associated with debugging output and not relevance to the stack trace.
--
-- The returned stacks will never overlap; if skip + numHead + numTail > the number of stacks, then
-- the head stack will contain the overlapping stacks. Otherwise, the middle stack levels are
-- lost.
--
-- debugstack is similar to this function though debugstack returns a formatted string and this
-- function returns two lists. See Tests.FormattedPartialStackTrace for a function that behaves
-- identically to that function.
--
-- skip:number
--     the number of stack levels to skip. These levels are ignored, but are not subtracted from
--     numHead. Defaults to 1, meaning the most-recent stack level returned is the one that was 
--     active when this function was called.
-- numHead:number
--     the number of stack levels to contain in the head stack trace. If this is greater than the
--     size of the stack, all stack levels are contained in that trace. The head stack trace is
--     offset by skip, but the skipped levels are not subtracted from numHead. Defaults to 10.
-- numTail:number
--     the number of stack levels to contain in the tail stack trace. The head stack has 
--     precedence over the tail stack; overlapping values will be added to the head stack and not
--     the tail stack. If they are not overlapping, then the tail stack will contain numTail stack
--     levels. Defaults to 10
-- returns
--     headStackTrace:table
--         a list of stack levels representing the head of the stack, as described above. Each
--         stack level is a table containing information. The level's information is provided by
--         debug.getinfo
--     tailStackTrace:table
--         a list of stack levels representing the tail of the stack, as described above. Each
--         stack level is a table containing information. The level's information is provided by
--         debug.getinfo
-- see
--     Tests.FullStackTrace, Tests.FormattedPartialStackTrace
function Tests.PartialStackTrace(skip, numHead, numTail)
    skip = skip or 1;
	numHead = numHead or 10;
	numTail = numTail or 10;
    local stackTrace = Tests.FullStackTrace();
    for i=1, math.max(1, skip) do
        table.remove(stackTrace, 1);
    end;
    local headStackTrace = {};
    for i=1, math.min(#stackTrace, numHead) do
        table.insert(headStackTrace, stackTrace[i]);
	end;
    local tailStackTrace = {};
    for i=math.max(#stackTrace - numTail, numHead) + 1, #stackTrace do
        table.insert(tailStackTrace, stackTrace[i]);
	end;
    return headStackTrace, tailStackTrace;
end;

-- Formats a stack level to be in the form returned by debugstack.
--
-- stackLevel:table
--     a stack level, as returned by debug.getinfo
-- returns
--     a string describing the stack level, in the same format as returned by
--     debugstack
function Tests.FormatStackLevel(stackLevel)
    if stackLevel.source:find("^[@=]") then
        stackLevel.source = stackLevel.source:sub(2);
    else
        stackLevel.source = stackLevel.source:gsub("\n.*", "");
        stackLevel.source = ("[string %s]"):format(stackLevel.source);
    end
    local name = stackLevel.name;
    if name == nil then
        name = "(unnamed)";
    elseif name:sub(1,1) ~= "<" then
        name = ("`%s'"):format(name);
    end;
    local stackLevelDescription = ("%s:%s: in %s %s"):format(
        stackLevel.source,
        stackLevel.currentline,
        stackLevel.namewhat,
        name
    );
    return stackLevelDescription:gsub("/", "\\");
end;

-- Formats a stack trace, emulating the way debugstack formats it. As a result,
-- this function is redundant if debugstack is available.
-- 
-- stackTrace:table
--     a list of stack levels. Each level should be in the form as returned by debug.getinfo
-- tailStackTrace:table
--     optional. A list of stack levels, same format as above
-- returns
--     a string describing the stack trace
function Tests.FormatStackTrace(stackTrace, tailStackTrace)
    local stackString = "";
    local function concat(stackLevel)
        stackString = stackString .. Tests.FormatStackLevel(stackLevel) .. "\n";
    end;
    Lists.EachValue(stackTrace, concat);
    if tailStackTrace then
        stackString = stackString .. "...\n";
        Lists.EachValue(tailStackTrace, concat);
    end;
    return stackString;
end;

-- Alias for formatting a full stack trace.
function Tests.FormattedStackTrace()
    local stackTrace = Tests.FullStackTrace();
    table.remove(stackTrace, 1);
    return Tests.FormatStackTrace(stackTrace);
end;

-- Alias for formatting a partial stack trace. The arguments 
--
-- This function is identical in functionality to debugstack. In fact, if debugstack is available
-- that function is directly called.
--
-- The arguments provided are immediately passed to Tests.PartialStackTrace.
function Tests.FormattedPartialStackTrace(skip, numHead, numTail)
    if nil == skip then
        skip = 0;
    end;
    skip = math.max(2, skip + 2);
    if debugstack then
        if numHead == nil then
            numHead = 10;
        end;
        if numTail == nil then
            numTail = 10;
        end;
        return debugstack(skip, numHead, numTail);
    end;
    return Tests.FormatStackTrace(Tests.PartialStackTrace(skip, numHead, numTail));
end;

function Tests.Choke(choke)
    local count = 0;
    return function()
        count = count + 1;
        if count > choke then
            error("Choked at count: " ..count);
        end;
    end;
end;

-- Holds a value, allowing functional access to changing it and ways to assert its
-- value.
--
-- The holder's methods can be safely called like functions.
--
-- value:*
--     the initial value of the holder
-- returns:object
--     a holder for the specified value.
function Tests.Value(value)
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

-- A very simple class that acts as a boolean object. Useful in testing since
-- it provides explicit methods that can be curried.
--
-- This class' methods operate through closure, so they may be invoked directly;
-- the 'self' reference is not used.
--
-- isSet:boolean
--     optional. the isSet state of the false. Defaults to false
function Tests.Flag(isSet)
    local isSet = Bool(isSet);
    local flag = {
        Raise = function()
            isSet = true;
        end,
        IsSet = function()
            return isSet;
        end,
        Clear = function()
            isSet = false;
        end
    };
    flag.Assert = ForcedFunction(flag, function(...)
        assert(flag.IsSet(), ...);
    end);
    return flag;
end

function Tests.Counter(count)
    if type(count) ~= "number" then
        if count == nil then
            count = 0;
        else
            count = assert(tonumber(count), "Initial is not a number. Initial value: " .. tostring(count));
        end;
    end;
    local counter = Metatables.ForceFunctions({
        Hit = function()
            count = count + 1;
        end,
        Count = function()
            return count;
        end,
        Clear = function()
            count = 0;
        end,
        AssertGreaterThan = function(num)
            assert(count > num, ("Count was %d, but assertion requires strictly more than %d"):format(count, num));
        end,
        AssertAtLeast = function(num)
            assert(count >= num, ("Count was %d, but assertion requires at least %d"):format(count, num));
        end,
        AssertEquals = function(num)
            assert(count == num, ("Count was %d, but assertion requires exactly %d"):format(count, num));
        end,
        AssertLessThan = function(num)
            assert(count < num, ("Count was %d, but assertion requires strictly less than %d"):format(count, num));
        end,
        AssertAtMost = function(num)
            assert(count <= num, ("Count was %d, but assertion requires at most %d"):format(count, num));
        end,
    });
    counter.Assert = counter.AssertEquals;
    return counter;
end;
