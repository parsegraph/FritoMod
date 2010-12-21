-- Containers provides collection over bags.
--
-- Containers.Each("all", function(k, v)
--     if v.name then print(v.name) end;
-- end);
-- assert(Containers.Contains("bags", "Hearthstone"), "You don't have a Hearthstone?!");
if nil ~= require then
    require "wow/Containers";
    require "currying";
    require "Metatables";
    require "Mixins-Iteration";
end;
Containers=Mixins.Iteration();

function Containers.InterpretBagName(bagName, iteratedBags)
    iteratedBags=iteratedBags or {};
    if type(bagName)=="table" then
        for i=1, #bagName do
            Containers.InterpretBagName(bagName[i], iteratedBags);
        end;
    elseif IsCallable(bagName) then
        Containers.InterpretBagName(bagName(), iteratedBags);
    elseif type(bagName)=="string" then
        bagName=bagName:lower();
        if bagName=="backpack" then
            table.insert(iteratedBags, 0);
        elseif bagName=="bags" or bagName=="all" then
            for i=0, NUM_BAG_SLOTS do
                table.insert(iteratedBags, i);
            end;
        else
            error("Unrecognized name: "..bagName);
        end;
    elseif type(bagName)=="number" then
        assert(bagName >= 0 and bagName <= NUM_BAG_SLOTS,
            "Bag number out of range: "..bagName);
        table.insert(iteratedBags, bagName);
    elseif bagName~=nil then
        error("Unsupported type: "..type(bagName));
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
        assert(Containers.InterpretBagName(bag), "Unrecognized key: "..tostring(bag));
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
    local iteratedBags=Containers.InterpretBagName(bag);
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

function Containers.SumItem(bags, target)
    return Containers.Sum(bags, function(slot)
        if slot.id==nil then
            return;
        end;
        if IsCallable(target) then
            return target(slot);
        elseif type(target)=="number" and slot.id==target then
            return slot.count;
        elseif type(target)=="string" and slot.name:lower()==target:lower() then
            return slot.count;
        end;
    end);
end;
