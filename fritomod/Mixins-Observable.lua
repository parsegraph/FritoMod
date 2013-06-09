if nil ~= require then
    require "fritomod/ListenerList";
end;

Mixins = Mixins or {};

function Mixins.Observable(klass)
    return function(self)
        local listeners = ListenerList:New();
        listeners:SetID(self);

        function self:_GetListeners()
            return listeners;
        end;

        function self:OnUpdate(listener, ...)
            return listeners:Add(listener, ...);
        end;

        function self:Update(...)
            listeners:Fire(...);
        end;
    end;
end;
