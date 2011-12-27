-- Callbacks for your inventory
--[[

Callbacks.Quantity("all", "Embersilk Cloth", printf, "You now have %d cloth!");

--]]
--
-- See Also:
-- Containers.SumItem

if nil ~= require then
	require "fritomod/Lists";
	require "fritomod/Events";
	require "fritomod/Containers";
end;

Callbacks=Callbacks or {};

-- Fires on inventory changes.
--
-- This only fires for changes to your inventory, so it will not fire
-- on first-use. Use Callbacks.ImmediateQuantity.
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
			lastQuantity=newQuantity;
		end;
	end);
end;

function Callbacks.ImmediateQuantity(bag, item, func, ...)
	func=Curry(func, ...);
	func(Containers.SumItem(bag, item));
	return Callbacks.Quantity(bag, item, func);
end;
