if nil ~= require then
    require "FritoMod_Events/Callbacks";

    require "FritoMod_Containers/Containers";
end;

function Callbacks.Quantity(bag, item, func, ...)
    func=Curry(func, ...);
    bag=Containers.InterpretBagName(bag);
    local lastQuantity=Containers.SumItem(bag, item);
    return Events.BAG_UPDATE(function(bagNum)
        if not Lists.Contains(bag, bagNum) then
            return;
        end;
        local newQuantity=Containers.SumItem(bag, item)
        if newQuantity~=lastQuantity then
            func(newQuantity);
        end;
    end);
end;
