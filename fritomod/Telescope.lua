if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/Mixins-Log";
    require "fritomod/Mixins-Invalidating";

    require "fritomod/Ordering";
end;

Telescope = OOP.Class("Telescope",
    Mixins.Log,
    Mixins.Invalidating
);

Telescope:AddConstructor(function(self)
    self.ordering = Ordering:New();
    self:AddDestructor(self.ordering);
    self.ordering:OnUpdate(self, "Invalidate");

    self.lenses = {};

    self:Validate();
end);

function Telescope:Add(name, lens, ...)
    assert(not self:Has(name),
        "I'm refusing to overwrite the existing lens named " .. tostring(name)
    );
    lens = Curry(lens, ...);

    self.lenses[name] = {
        builder = lens,
        enabled = false
    };
    self:Order():Push(name);
    self:Invalidate();

    return function()
        self.lenses[name] = nil;
        self:Order():Remove(name);
    end;
end;
Telescope.AddLens = Telescope.Add;

function Telescope:AddEnabled(name, lens, ...)
    local remover = self:Add(name, lens, ...);
    self:Enable(name);
    return remover;
end;

function Telescope:AddDisabled(name, lens, ...)
    local remover = self:Add(name, lens, ...);
    self:Disable(name);
    return remover;
end;

function Telescope:InvokeLens(name, ...)
    assert(self:Has(name), "I don't have a lens named " .. tostring(name));
    return self.lenses[name].builder(...);
end;

function Telescope:Get(...)
    local order = self:Order():Get();

    -- Use a recursive function to guarantee varargs are preserved
    local function Invoke(index, ...)
        if index > #order then
            return ...;
        end;
        local name = order[index];
        if self:IsEnabled(name) then
            return Invoke(index + 1, self:InvokeLens(name, ...));
        end;
        return Invoke(index + 1, ...);
    end;
    return Invoke(1, ...);
end;
Telescope.Build = Telescope.Get;

function Telescope:Has(name)
    return Bool(self.lenses[name]);
end;
Telescope.HasLens = Telescope.Has;

function Telescope:SetEnabled(name, enabled)
    local lens = self.lenses[name];
    if lens then
        lens.enabled = enabled;
        self:Invalidate();
    end;
    return Seal(self, "SetEnabled", name, not enabled);
end;

function Telescope:Enable(name)
    return self:SetEnabled(name, true);
end;

function Telescope:Disable(name)
    return self:SetEnabled(name, false);
end;

function Telescope:Toggle(name)
    return self:SetEnabled(name, not self:IsEnabled(name));
end;
Telescope.ToggleEnabled = Telescope.Toggle;

function Telescope:IsEnabled(name)
    local lens = self.lenses[name];
    return lens and Bool(lens.enabled);
end;
Telescope.Enabled = Telescope.IsEnabled;
Telescope.GetEnabled = Telescope.IsEnabled;

function Telescope:Order()
    return self.ordering;
end;
Telescope.GetOrder = Telescope.Order;
Telescope.Ordering = Telescope.Order;
Telescope.GetOrdering = Telescope.Order;
