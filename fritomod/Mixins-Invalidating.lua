if nil ~= require then
    require "fritomod/OOP";
    require "fritomod/log";
    require "fritomod/Callbacks-Timing";
    require "fritomod/ToggleDispatcher";
end;

Mixins = Mixins or {};

-- A complex object may have state that is expensive to calculate (e.g. laying
-- out a complex view).  As a result, it's common to coalesce these
-- invalidating changes into a single update.
--
-- Invalidators are listeners that are fired when the object becomes invalid.
--
-- validators will be used to calculate the new state of the object. Once all
-- validators have been called, the object is once again considered valid.
function Mixins.Invalidating(self)
    if OOP.IsClass(self) then
        self:AddConstructor(Mixins.Invalidating);
        return;
    end;

    Log.Entercf(self,
        "Invalidating mixin constructions",
        "Constructing invalidating mixin"
    );

    local validateLater;
    function self:ValidateLater()
        if not validateLater then
            validateLater = Callbacks.Later(function()
                self:CancelValidateLater();
                self:Validate();
            end);
        end;
        return Seal(self, "CancelValidateLater");
    end;

    function self:CancelValidateLater()
        if validateLater then
            validateLater();
            validateLater = nil;
        end;
    end;

    self:AddDestructor(self, "CancelValidateLater");

    local validators = ToggleDispatcher:New();
    validators:SetID("Validators", self);
    self:AddDestructor(validators);

    local invalidated = true;
    function self:IsInvalidated()
        return not self:IsValidated();
    end;

    function self:IsValidated()
        return validators:HasFired();
    end;
    self.GetValidated = self.IsValidated;

    function self:Validate(...)
        return validators:Fire(...);
    end;

    function self:Invalidate(...)
        return validators:Reset(...);
    end;

    function self:OnInvalidate(func, ...)
        return validators:AddResetter(func, ...);
    end;

    function self:OnValidate(func, ...)
        return validators:Add(func, ...);
    end;

    Log.Leave();
end;
