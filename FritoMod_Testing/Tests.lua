Tests = {};
local Tests = Tests;

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
        end
    };
    flag.Assert = ForcedMethod(flag, function(self, ...)
        assert(self:IsSet(), ...);
    end);
    return flag;
end

function Tests.Counter()
    local count = 0;
    local counter = {
        Hit = function()
            count = count + 1;
        end,
        Count = function()
            return count;
        end,
    };
    return counter;
end;
