InvalidatingForwarder = FritoLib.OOP.Mixin{
	"AddInvalidating", "RemoveInvalidating",
	"InvalidateSize", "InvalidateLayout"
};
local InvalidatingForwarder = InvalidatingForwarder;

function InvalidatingForwarder:AddInvalidating(invalidating)
	if not self.forwarding then
		self.forwarding = List:new();
	end;
	return self.forwarding:Add(invalidating);
end;

function InvalidatingForwarder:RemoveInvalidating(invalidating)
	if not self.forwarding then
		return;
	end;
	return self.forwarding:Remove(invalidating);
end;

function InvalidatingForwarder:InvalidateSize()
	if not self.forwarding then
		return;
	end;
	for invalidating in self.forwarding:Iter() do
		invalidating:InvalidateSize();
	end;
end;

function InvalidatingForwarder:InvalidateLayout()
	if not self.forwarding then
		return;
	end;
	for invalidating in self.forwarding:Iter() do
		invalidating:InvalidateLayout();
	end;
end;
