-- IdempotentToggleDispatcher is a ToggleDispatcher that
-- ensures Fire and Reset only fire once. It also immediately
-- calls listeners when added, if the dispatcher is in a
-- "fired" state.

if nil ~= require then
	require "fritomod/ToggleDispatcher";
end;

IdempotentToggleDispatcher=OOP.Class(ToggleDispatcher);

function IdempotentToggleDispatcher:Fire(...)
	self.firedArguments={...};
	return IdempotentToggleDispatcher.super.Fire(self, ...);
end;

function IdempotentToggleDispatcher:Reset()
	return IdempotentToggleDispatcher.super.Reset(self);
end;

function IdempotentToggleDispatcher:Add(listener, ...)
	listener=Curry(listener, ...);
	local r=IdempotentToggleDispatcher.super.Add(self, listener);
	if self.firedArguments then
		self:FireListener(listener, unpack(self.firedArguments));
	end;
	return r;
end;
