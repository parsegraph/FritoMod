if nil ~= require then
    require "FritoMod_Functional/Mixins";
end;

Invalidating = Mixins.Library();
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
function Invalidating.ValidateSize(target)
    -- If the object has children of some sort, we want to validate those first.
    if target.Iter then
        for child in target:Iter() do
            Invalidating.ValidateSize(child);
        end;
    end;
    if target.invalidatedSize == false then
		return;
	end;
	-- This Invalidating's size needs to be validated, so do so.
	target.invalidatedSize = false;
	print("Invalidating: Validating size: " .. tostring(target));
	local oldMeasuredHeight, oldMeasuredWidth = target:GetMeasuredHeight(), target:GetMeasuredWidth()
	target:Measure();
	local measuredHeight, measuredWidth = target:GetMeasuredHeight(), target:GetMeasuredWidth()
	if oldMeasuredWidth ~= measuredWidth or oldMeasuredHeight ~= measuredHeight then
		if target:GetParent() then
			target:GetParent():InvalidateSize();
		end;
		target:InvalidateLayout();
	end;
end;

-- Given an Invalidating, validate the layout of it and all its children. This will
-- operate on the given object first, then its children.
function Invalidating.ValidateLayout(target)
    if target.invalidatedLayout ~= false then
        -- This target needs to be validated, so do so.
        target.invalidatedLayout = false;
        print("Invalidating: Validating layout: " .. tostring(target));
        target:UpdateLayout();
    end;
    -- If it has children of some sort, validate them now.
    if target.Iter then
        for child in target:Iter() do
            Invalidating.ValidateLayout(child);
        end;
    end;
end;
