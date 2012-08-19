-- Represents a view of a list of elements.
--
-- UI.List coordinates rendering with three components:
-- 1. A source list of UI elements
-- 2. A sorting strategy for that list
-- 3. A layout strategy
--
-- The source list may not necessarily be UI elements; specific
-- restrictions depend on the layout strategy used. However, it
-- is common for the source list to contain UI elements.
--
-- The sorting strategy allows runtime modification of the order
-- of elements. For example, it may be common to have a table of
-- buffs, keyed by their name. You can pass this table directly
-- to UI.List, and they will be rendered in alphabetical order.
-- If you want to change the order, you may pass a custom
-- comparator.
--
-- The layout strategy should expect a list of UI elements. The
-- layout strategy may choose to omit certain elements, transform
-- the content, or some other behavior. However, it is common
-- to have the layout strategy display all passed arguments
-- directly. Notably, the layout strategy does not have access
-- to the underlying keys.

if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/Tables";
    require "fritomod/Iterators";
    require "fritomod/ToggleDispatcher";
    require "fritomod/Anchors";
end;

UI = UI or {};

local List = OOP.Class();
UI.List = List;

-- Construct a new list.
--
-- You must pass a list of items and a layout strategy before
-- rendering occurs.
function List:Constructor()
    -- Listeners for the new reference frame.
    self.listeners = ToggleDispatcher:New();

    -- Some sensible defaults.
    self:UseKeySorting();
    self:SetCleaner(Anchors.Clear);

    -- Clean our frames when we are destroyed.
    self:AddDestructor(self, "Reset");
end;

-- Sets the items of this list to the specified table.
--
-- If items were already present in this list, then the
-- layout will be removed from them before the new items
-- are laid out.
function List:SetContent(items)
    if self.items then
        self:Reset();
    end;
    self.items = items;
    self:Update();
end;

local function UseSort(strategy)
    return function(self, comparator, ...)
        self.sortStrategy = strategy;
        if comparator or select("#", ...) > 0 then
            self.comparator = Curry(comparator, ...);
        else
            -- Use natural sorting
            self.comparator = nil;
        end;
        self:Update();
    end;
end;

-- Use the sorting strategy specified. Optionally, a
-- comparator may be passed to further specify the sorting
-- order. By default, natural key-sorting is used.
--
-- The comparator, if provided, should expect two arguments
-- (or four, if pair sorting is used), and return a numeric
-- value that will be used in comparison tests.
List.UseKeySorting   = UseSort(Tables.KeySortedIterator);
List.UseValueSorting = UseSort(Tables.ValueSortedIterator);
List.UsePairSorting  = UseSort(Tables.PairSortedIterator);

function List:UseNoopSorting()
    self.comparator = nil;
    self.sortStrategy = function(items)
        return Tables.PairIterator(items);
    end;
    self:Update();
end;

-- Use the specified layout strategy for this list.
--
-- The layout strategy should expect a list of UI elements.
-- It is obligated to lay them out in the specified order.
-- It must return the reference element, that will be passed
-- to listeners.
function List:SetLayout(layout, ...)
    self.layout = Curry(layout, ...);
    self:Update();
end;

-- Use the specified function to clean elements before use.
--
-- It's common to clear anchors from a UI element before
-- using it, so by default, the cleaner will be Anchors.Clear.
-- However, if you want to only clean some of the anchors,
-- or do nothing, you should use a custom cleaner here.
function List:SetCleaner(cleaner, ...)
    self.cleaner = Curry(cleaner, ...);
    self:Update();
end;

-- Returns a function that will iterate over the items in
-- this list, sorted using this list's sorting strategy.
--
-- If no items are currently present in this list, an empty
-- iterator will be returned.
function List:Iterator()
    if not self.items then
        return Noop;
    end;
    return self.sortStrategy(self.items, self.comparator);
end;

-- Layout this list's items with this list's layout strategy.
--
-- This function is the meat of this class. It should be called
-- whenever the content of the specified items changes. It will
-- be automatically called if the other properties are changed
-- (e.g., a new layout strategy is provided)
function List:Update()
    if not self.items or not self.layout then
        return;
    end;
    self:Reset();
    local values = Iterators.Values(self:Iterator());
    if #values > 0 then
        local ref = self.layout(values);
        -- We use a curried function here to ensure any action we take will affect
        -- the old values we had, rather than the new ones that we might have now.
        self.resetLayout = Functions.OnlyOnce(Lists.Each, values, self.cleaner);
        self.listeners:Fire(ref);
    else
        -- Don't use the layout if we don't have anything to lay out.
        self.resetLayout = Noop;
        self.listeners:Fire();
    end;
end;

-- Listen for updates to this list.
--
-- Every listener will be passed the new reference frame. This
-- frame will be the frame which other UI elements are anchored
-- around. In practice, it is typically the first or last
-- UI element.
--
-- You should register yourself as a listener if you are
-- incorporating this list's values into your UI.
function List:OnUpdate(listener, ...)
    return self.listeners:Add(listener, ...);
end;

-- Reset this list's layout, if any.
--
-- The layout will be removed from this list's items, as provided
-- by the layout strategy's returned function.
function List:Reset()
    self.listeners:Reset();
    if self.resetLayout then
        self.resetLayout();
        self.resetLayout = nil;
    end;
end;

-- vim: set et :
