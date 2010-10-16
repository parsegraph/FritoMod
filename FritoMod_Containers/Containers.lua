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

local function ReadBagNames(iteratedBags, bag)
    if type(bag)=="table" then
        for i=1, #bag do
            ReadBagNames(iteratedBags, bag[i]);
        end;
    elseif IsCallable(bag) then
        ReadBagNames(iteratedBags, bag());
    elseif type(bag)=="string" then
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
    elseif bag~=nil then
        error("Unsupported type: "..type(bag));
    end;
    return iteratedBags;
end;

-- This metatable allows us to do things like this:
--
-- assert(Containers.backpack.Contains("Hearthstone"));
-- -- which is equivalent to:
-- assert(Containers.Contains("backpack", "Hearthstone"));
--
-- -- Does your first bag contain a hearthstone?
-- assert(Containers[1]Contains("Hearthstone"));
setmetatable(Containers, {
    __index=function(self, bag)
        assert(ReadBagNames(bag), "Unrecognized key: "..tostring(bag));
        if type(bag)=="string" then
            bag=bag:lower();
        end;
        if not rawget(self, bag) then
            self[bag]=setmetatable({}, {
                __newindex=Seal(error, "Containers."..bag.." is an immutable table"),
                __index=function(self, k)
                    local retrieved=Containers[k];
                    assert(IsCallable(retrieved), "Containers."..bag.."."..tostring(k).."is not callable");
                    return Curry(retrieved, bag);
                end
            });
        end;
        return rawget(self, bag);
    end
});

function Containers.Iterator(bag)
    local iteratedBags=ReadBagNames({}, bag);
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
                slot.slot=slotNum;
                slot[1]=bag;
                slot[2]=slotNum;
            end;
        end;
        if slot.slot==nil then
            -- We couldn't find a slot, so punt.
            return;
        end;
        -- XXX This should use a metatable, and these should possibly be 
        -- functions.
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

do
    oldEqualsTest=Containers.NewEqualsTest;
    local function DoComparision(slot, prim)
         if type(prim)=="string" then
            prim=prim:lower();
            local name=slot.name;
            if name then 
                name=name:lower()
            end;
            return name==prim;
        elseif type(prim)=="number" then
            return slot.id==prim;
        elseif type(prim)=="table" then
            return slot.bag==prim.bag and slot.slot==prim.slot;
        end;
    end;
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
                return DoComparision(a, b);
            elseif type(b)=="table" then
                return DoComparision(b, a);
            end;
            return a==b;
        end;
    end;
end;
