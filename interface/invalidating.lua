Invalidating = OOP.MixinLibrary();
local Invalidating = Invalidating;

-- Boolean of whether to fake validation on iterations that throw errors.
Invalidating.SUPPRESS_ERRORS = true;

-------------------------------------------------------------------------------
--
--  Overriddable Methods: Invalidating
--
-------------------------------------------------------------------------------

function Invalidating:Measure()
    -- OVERRIDE ME: Update your Invalidating's layout as necessary here. It is not necessary
    -- to set invalidatedLayout to false again.
    -- If you're subclassing, remember to call super's Measure() first.
end;

function Invalidating:UpdateLayout(width, height)
    -- OVERRIDE ME: Update your Invalidating's layout as necessary here. It is not necessary
    -- to set invalidatedLayout to false again.
    -- If you're subclassing, remember to call super's UpdateLayout() first.
end;

-------------------------------------------------------------------------------
--
--  Public Validation Interface
--
-------------------------------------------------------------------------------

function Invalidating:InvalidateLayout()
    --debug("Invalidation: Layout, on: " .. tostring(self));
    self.invalidatedLayout = true;
end;

function Invalidating:InvalidateSize()
    --debug("Invalidation: Size, on: " .. tostring(self));
    self.invalidatedSize = true;
end;

-- Force a validation immediately. This is used when you suspect things aren't quite in sync, and feel
-- that a validation cycle would work. This will validate the entire tree starting with this Invalidating.
function Invalidating:ValidateNow()
    -- First phase is measurement. This works from the bottom, up. 
    Invalidating.ValidateSize(self);
    -- The second phase is layout, working from the top, down.
    Invalidating.ValidateLayout(self);
end;

-------------------------------------------------------------------------------
--
--  Getters and Setters
--
-------------------------------------------------------------------------------

function Invalidating:GetMeasuredWidth()
    return self.measuredWidth;
end;

function Invalidating:GetMeasuredHeight()
    return self.measuredHeight;
end;

-------------------------------------------------------------------------------
--
--  Internal Validation Utilities
--
-------------------------------------------------------------------------------

-- Given a Invalidating, validate the size of it and all of its children who
-- need to be validated. This will validate the deepest-levels of children first,
-- working its way back up.
function Invalidating.ValidateSize(invalidating)
    -- If the object has children of some sort, we want to validate those first.
    if invalidating.Iter then
        for child in invalidating:Iter() do
            Invalidating.ValidateSize(child);
        end;
    end;
    if invalidating.invalidatedSize ~= false then
        -- This Invalidating's size needs to be validated, so do so.
        invalidating.invalidatedSize = false;
        debug("Invalidating: Validating size: " .. tostring(invalidating));
        local oldMeasuredHeight, oldMeasuredWidth = invalidating:GetMeasuredHeight(), invalidating:GetMeasuredWidth()
        invalidating:Measure();
        local measuredHeight, measuredWidth = invalidating:GetMeasuredHeight(), invalidating:GetMeasuredWidth()
        if oldMeasuredWidth ~= measuredWidth or oldMeasuredHeight ~= measuredHeight then
            if invalidating:GetParent() then
                invalidating:GetParent():InvalidateSize();
            end;
            invalidating:InvalidateLayout();
        end;
    end;
end;

-- Given an Invalidating, validate the layout of it and all its children. This will
-- operate on the given object first, then its children.
function Invalidating.ValidateLayout(invalidating)
    if invalidating.invalidatedLayout ~= false then
        -- This invalidating needs to be validated, so do so.
        invalidating.invalidatedLayout = false;
        debug("Invalidating: Validating layout: " .. tostring(invalidating));
        invalidating:UpdateLayout();
    end;
    -- If it has children of some sort, validate them now.
    if invalidating.Iter then
        for child in invalidating:Iter() do
            Invalidating.ValidateLayout(child);
        end;
    end;
end;
