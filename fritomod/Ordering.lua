if nil ~= require then
    require "fritomod/OOP-Class";
    require "fritomod/Lists";
    require "fritomod/Strings";
end;


Ordering = OOP.Class("Ordering");

function Ordering:Constructor()
    self.order = {};
end;

function Ordering:Get()
    return self.order;
end;

function Ordering:Iterator()
    return Lists.Iterator(self:Get());
end;

function Ordering:Each(func, ...)
    Lists.Each(self:Get(), func, ...);
end;

function Ordering:Raise(name)
    Lists.Remove(self.order, name);
    Lists.Insert(self.order, name);
end;

function Ordering:Lower(name)
    Lists.Remove(self.order, name);
    Lists.Unshift(self.order, name);
end;

function Ordering:Order(order, ...)
    if type(order) ~= "table" or select("#", ...) > 0 or #order == 0 then
        return self:Order({order, ...});
    end;

    do
        -- Do a quick check for duplicates in their names.
        local names = {};
        for _, name in ipairs(order) do
            assert(not names[name], "Ordering names must be unique; "
            .. "duplicate ordering names are ambiguous and not allowed");
            names[name] = true;
        end;
    end;

    if DEBUG_TRACE then
        trace("Reordering with: " .. Strings.Join(" ", order));
    end;

    local ourIndex = 1;
    local theirIndex = 1;
    while theirIndex <= #order do
        if ourIndex > #self.order then
            -- No more elements in the original ordering, so just start
            -- pushing their elements to the end.
            while theirIndex <= #order do
                Lists.Push(self.order, order[theirIndex]);
                theirIndex = theirIndex + 1;
            end;
            break;
        end;
        -- Still elements in both lists
        assert(ourIndex <= #self.order);
        assert(theirIndex <= #order);

        -- Look to see if their ordering contains our current element
        local i = Lists.IndexOf(order, self.order[ourIndex]);

        if i ~= nil then
            -- We've found an element in both the original ordering
            -- and the partial ordering, so move any elements that
            -- come before this one in their order.
            --
            -- For example, imagine our ordering:
            -- A B D C E
            -- And their ordering:
            -- C D
            --
            -- Once we find D in our ordering, we'll also find it in
            -- theirs. We'll add every element to our ordering that
            -- comes before D in their ordering.
            local offset = 0;
            for j=theirIndex, i - 1 do
                -- Remove their element from our ordering, regardless
                -- of its location.
                Lists.Remove(self.order, order[j]);

                -- Replace that same element at the current location (which
                -- is offset to ensure multiple insertions don't end up
                -- backwards)
                Lists.InsertAt(self.order, ourIndex + offset, order[j]);

                offset = offset + 1;
            end;

            -- Advance both iterators past the area we just worked with
            local advancedOurIndex = ourIndex + offset + 1;
            assert(ourIndex < advancedOurIndex,
                "ourIndex failed to advance");
            ourIndex = advancedOurIndex;

            local advancedTheirIndex = i + 1;
            assert(theirIndex < advancedTheirIndex,
                "theirIndex failed to advance");
            theirIndex = advancedTheirIndex;
        else
            -- The partial ordering provides no information about
            -- this element, so just continue
            ourIndex = ourIndex + 1;
        end;
    end;

    -- Just to make sure iteration ended as expected
    assert(theirIndex > #order);
end;

function Ordering:Remove(name)
    Lists.Remove(self.order, name);
end;

function Ordering:Filter(filter, ...)
    self.order = Lists.Filter(self.order, filter, ...);
end;
