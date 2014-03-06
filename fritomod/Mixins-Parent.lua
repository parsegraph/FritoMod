if nil ~= require then
    require "fritomod/OOP";
    require "fritomod/log";
    require "fritomod/ToggleDispatcher";
end;

Mixins = Mixins or {};

function Mixins.Parent(self)
    if OOP.IsClass(self) then
        self:AddConstructor(Mixins.Parent);
        return;
    end;

    Log.Entercf(self,
        "Parent mixin constructions",
        "Constructing parent mixin"
    );

    local parenters = ToggleDispatcher:New();
    parenters:SetID("Parenters", self);
    self:AddDestructor(parenters);

    Mixins.Property(self, "Parent", function(self, commit)
        commit();
        return parenters:Fire(self:GetParent());
    end);

    function self:OnParent(parenter, ...)
        return parenters:Add(parenter, ...);
    end;

    function self:HasParent()
        return Bool(self:GetParent());
    end;

    Log.Leave();
end;

