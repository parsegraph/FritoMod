-- ImmediateToggleDispatcher is a ToggleDispatcher that
-- ensures Fire and Reset only fire once. It also immediately
-- calls listeners when added, if the dispatcher is in a
-- "fired" state.

if nil ~= require then
	require "fritomod/ToggleDispatcher";
end;

ImmediateToggleDispatcher=OOP.Class("ImmediateToggleDispatcher", ToggleDispatcher);

function ImmediateToggleDispatcher:Fire(...)
	self.firedArguments={...};
	return ImmediateToggleDispatcher.super.Fire(self, ...);
end;

function ImmediateToggleDispatcher:Reset()
	self.firedArguments = nil;
	return ImmediateToggleDispatcher.super.Reset(self);
end;

function ImmediateToggleDispatcher:Add(listener, ...)
	listener=Curry(listener, ...);
	local r=ImmediateToggleDispatcher.super.Add(self, listener);
	if self.firedArguments then
		self:FireListener(listener, unpack(self.firedArguments));
	end;
	return r;
end;
