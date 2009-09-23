-- A very simple class that acts as a boolean object. Useful in testing since
-- it provides explicit methods that can be curried.
--
-- This class' methods operate through closure, so they may be invoked directly;
-- the 'self' reference is not used.
function Flag()
    local isSet = false;
    return {
        Raise = function()
            isSet = true;
        end,
        IsSet = function()
            return isSet;
        end,
        Assert = function(self, ...)
            assert(self:IsSet(), ...);
        end
    };
end;
