if nil ~= require then
    require "fritomod/OOP";
    require "fritomod/Log";
    require "fritomod/ToggleDispatcher";
end;

Mixins = Mixins or {};

-- By default, this object is not visible.
function Mixins.Visible(self)
    if OOP.IsClass(self) then
        self:AddConstructor(Mixins.Visible);
        return;
    end;

    Log.Entercf(self,
        "Visibility mixin constructions",
        "Constructing visibility mixin"
    );

    local showers = ToggleDispatcher:New();
    showers:SetID("Showers", self);
    self:AddDestructor(showers);

    function self:SetVisible(visible, ...)
        visible = Bool(visible);
        if visible then
            return showers:Fire(...);
        else
            return showers:Reset(...);
        end;
    end;

    function self:GetVisible()
        return showers:HasFired();
    end;

    function self:IsVisible()
        return self:GetVisible();
    end;

    function self:ToggleVisible(...)
        return self:SetVisible(not self:IsVisible(), ...);
    end;

    function self:Show(...)
        return self:SetVisible(true, ...);
    end;

    function self:ForceShow(...)
        self:Hide();
        return self:Show(...);
    end;

    function self:OnShow(shower, ...)
        return showers:Add(shower, ...);
    end;

    function self:Hide(...)
        return self:SetVisible(false, ...);
    end;

    function self:ForceHide(...)
        self:Show();
        return self:Hide(...);
    end;

    function self:OnHide(hider, ...)
        return showers:AddResetter(hider, ...);
    end;

    Log.Leave();
end;
