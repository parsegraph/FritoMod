if nil ~= require then
     require "FritoMod_OOP/Mixins";
end;

InvalidatingProxy = Mixins.Library();
local InvalidatingProxy = InvalidatingProxy;

function InvalidatingProxy:AddInvalidating(invalidating)
	if not self.forwarding then
		self.forwarding = {};
	end;
	return table.insert(self.forwarding, invalidating);
end;

function InvalidatingProxy:RemoveInvalidating(invalidating)
	if not self.forwarding then
		return;
	end;
	Lists.Remove(self.forwarding, invalidating);
end;

function InvalidatingProxy:InvalidateSize()
	if not self.forwarding then
		return;
	end;
	for _, invalidating in pairs(self.forwarding) do
		invalidating:InvalidateSize();
	end;
end;

function InvalidatingProxy:InvalidateLayout()
	if not self.forwarding then
		return;
	end;
	for _, invalidating in pairs(self.forwarding) do
		invalidating:InvalidateLayout();
	end;
end;
