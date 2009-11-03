if nil ~= require then
     require "FritoMod_Functional/Mixins";
end;

InvalidatingProxy = Mixins.Library();
local InvalidatingProxy = InvalidatingProxy;

function InvalidatingProxy:AddInvalidating(invalidating)
	if not self.forwarding then
		self.forwarding = List();
	end;
	return self.forwarding:Add(invalidating);
end;

function InvalidatingProxy:RemoveInvalidating(invalidating)
	if not self.forwarding then
		return;
	end;
	return self.forwarding:Remove(invalidating);
end;

function InvalidatingProxy:InvalidateSize()
	if not self.forwarding then
		return;
	end;
	for invalidating in self.forwarding:Iter() do
		invalidating:InvalidateSize();
	end;
end;

function InvalidatingProxy:InvalidateLayout()
	if not self.forwarding then
		return;
	end;
	for invalidating in self.forwarding:Iter() do
		invalidating:InvalidateLayout();
	end;
end;
