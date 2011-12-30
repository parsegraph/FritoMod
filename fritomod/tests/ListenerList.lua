local Suite = CreateTestSuite("fritomod.ListenerList");

function Suite:TestAddingAListener()
	local list = ListenerList:New();
	local v = Tests.Value();
	local r;
	r=list:Add(function(...)
		v.Set(...);
		r();
		assert(list:DeadListenerCount() == 1, "Dead listener has been registered");
	end);
	list:Fire(42);
	v.Assert(42);
	r(); -- Should do nothing
end;
