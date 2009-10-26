Tests = {};
local Tests = Tests;

do
    local listeners = {};
    Tests.AddErrorListener = Activator(FunctionPopulator(listeners), function()
        local oldHandler = geterrorhandler() or Noop;
        function OurHandler(errorMessage, frame, stack, etype, ...)
            print("Cpaturing?");
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

function Tests.Choke(choke)
    local count = 0;
    return function()
        count = count + 1;
        if count > choke then
            error("Choked at count: " ..count);
        end;
    end;
end;

-- A very simple class that acts as a boolean object. Useful in testing since
-- it provides explicit methods that can be curried.
--
-- This class' methods operate through closure, so they may be invoked directly;
-- the 'self' reference is not used.
function Tests.Flag()
    local isSet = false;
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

function Tests.Counter()
    local count = 0;
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
            assert(count > num, format("Count was %d, but assertion requires strictly more than %d", count, num));
        end,
        AssertAtLeast = function(num)
            assert(count >= num, format("Count was %d, but assertion requires at least %d", count, num));
        end,
        AssertEquals = function(num)
            assert(count == num, format("Count was %d, but assertion requires exactly %d", count, num));
        end,
        AssertLessThan = function(num)
            assert(count < num, format("Count was %d, but assertion requires strictly less than %d", count, num));
        end,
        AssertAtMost = function(num)
            assert(count <= num, format("Count was %d, but assertion requires at most %d", count, num));
        end,
    });
    counter.Assert = counter.AssertEquals;
    return counter;
end;
