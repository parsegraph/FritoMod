-- Containers provides collection over bags.
--
-- Containers.Each("all", function(k, v)
--     if v.name then print(v.name) end;
-- end);
-- assert(Containers.Contains("bags", "Hearthstone"), "You don't have a Hearthstone?!");
if nil ~= require then
    require "WoW_Containers/Containers";

    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_Collections/Mixins-Iteration";
end;
Containers=Mixins.Iteration();
Metatables.Defensive(Containers);

function Containers.Iterator(bag)
    local iteratedBags={};
    if type(bag)=="string" then
        bag=bag:lower();
        if bag=="backpack" then
            table.insert(iteratedBags, 0);
        elseif bag=="bags" or bag=="all" then
            for i=0, NUM_BAG_SLOTS do
                table.insert(iteratedBags, i);
            end;
        else
            error("Unrecognized name: "..bag);
        end;
    elseif type(bag)=="number" then
        assert(bag >= 0 and bag <= NUM_BAG_SLOTS,
        "Bag number out of range: "..bag);
        table.insert(iteratedBags, bag);
    elseif type(bag)=="table" then
        error("Not yet supported");
    end;
    local slotNum=0;
    local slot={};
    return function()
        slot.slot=nil;
        while #iteratedBags>0 and slot.slot==nil do
            bag=iteratedBags[1];
            slotNum=slotNum+1;
            if slotNum > GetContainerNumSlots(bag) then
                slotNum=0;
                bag=table.remove(iteratedBags, 1);
            else
                slot.bag=bag;
                slot[1]=bag;
                slot.slot=slotNum;
                slot[2]=slotNum;
            end;
        end;
        if slot.slot==nil then
            return;
        end;
        -- I don't like this at all. We should at least use a metatable 
        -- with __index.
        slot.id=GetContainerItemID(bag, slotNum);
        if slot.id then
            slot.name=GetItemInfo(slot.id);
            local texture, count, _, quality=GetContainerItemInfo(bag, slotNum);
            slot.texture=texture;
            slot.count=count;
            slot.quality=quality;
        else
            slot.name=nil;
            slot.texture=nil;
            slot.count=nil;
            slot.quality=nil;
        end;
        return slot, slot;
    end;
end;
Containers.Bag=Containers.Iterator;
Containers.Iterate=Containers.Iterator;
Containers.IterateBags=Containers.Iterator;
Containers.All=Curry(Containers.Iterator, "all");
Containers.Backpack=Curry(Containers.Iterator, 0);

do
    oldEqualsTest=Containers.NewEqualsTest;
    -- This equality test lets us do things like:
    -- assert(Containers.Contains("all", "Hearthstone"), 
    --     "You don't have a hearthstone?!");
    -- We support comparisons by item name and by item ID. You can also compare
    -- returned slots to one another. Beware, however, that an iterator will operate 
    -- on the same table throughout its iteration.
    function Containers.NewEqualsTest(testFunc, ...)
        if testFunc then
            return oldEqualsTest(testFunc, ...);
        end;
        return function(a, b)
            if type(a)=="table" then
                if type(b)=="string" then
                    local name=a.name;
                    if name then name=name:lower() end;
                    return name==b:lower();
                elseif type(b)=="number" then
                    return a.id==b;
                elseif type(b)=="table" then
                    return a.bag==b.bag and a.slot==b.slot;
                end;
            elseif type(b)=="table" then
                if type(a)=="string" then
                    local name=a.name;
                    if name then name=name:lower() end;
                    return name==a:lower();
                elseif type(a)=="number" then
                    return b.id==a;
                end;
            end;
            return a==b;
        end;
    end;
end;
