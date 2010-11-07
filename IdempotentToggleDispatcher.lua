-- IdempotentToggleDispatcher is a ToggleDispatcher that
-- ensures Fire and Reset only fire once. It also immediately
-- calls listeners when added, if the dispatcher is in a 
-- "fired" state.

if nil ~= require then
    require "ToggleDispatcher";
end;

IdempotentToggleDispatcher=OOP.Class(ToggleDispatcher);

function IdempotentToggleDispatcher:Fire(...)
    if self.fired then
        return;
    end;
    self.fired={...};
    return self.super.Fire(self, ...);
end;

function IdempotentToggleDispatcher:Reset()
    if not self.fired then
        return;
    end;
    self.fired=nil;
    return self.super.Reset(self);
end;

function IdempotentToggleDispatcher:Add(listener, ...)
    listener=Curry(listener, ...);
    if self.fired then
        listener(unpack(self.fired));
    end;
    return self.super.Add(self, listener);
end;
