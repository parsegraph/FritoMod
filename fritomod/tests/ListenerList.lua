local Suite = CreateTestSuite("fritomod.ListenerList");

function Suite:TestAddingAListener()
	local list = ListenerList:New();
	local c = Tests.Counter(0);
	local v = Tests.Value();
	local r;
	list:Add(c.Hit);
	r=list:Add(function(...)
		c.Hit();
		v.Set(...);
		r();
	end);
	list:Add(c.Hit);
	list:Fire(42);
	c.Assert(3);
	v.Assert(42);
	r();
	v.Reset();
	c.Reset();
	list:Fire(42);
	c.Assert(2);
	v.Assert(nil);
end;

function Suite:TestListenersAreFiredInTheCorrectOrder()
	local list = ListenerList:New();
	local c = Tests.Counter(0);
	list:Add(function()
		c.Assert(0);
		c.Hit();
	end);
	list:Add(function()
		c.Assert(1);
		c.Hit();
	end);
	list:Add(function()
		c.Assert(2);
		c.Hit();
	end);
	list:Fire();
	c.Assert(3);
end;

-- This test ensures that the returned remover removes the function that
-- was added, even if duplicates are present in the listener list. This
-- ensures that the order of invoked functions will always be predictable;
-- your remover won't take away someone else's function just because they
-- got there first.
--
-- The test itself is pretty complicated to follow, since we have to ensure
-- two conditions:
--
-- * All currently added listeners are fired
-- * The order of listeners is predictable (we didn't remove the first or the
-- last instead of the intended middle listener)
function Suite:TestRemoverRemovesCorrectFunctionEvenWithDuplicates()
	local list = ListenerList:New();
	local c = Tests.Counter(0);
	local removed=false;
	list:Add(c.Hit);
	list:Add(function()
		c.Assert(1);
		c.Hit();
	end);
	local r=list:Add(c.Hit);
	list:Add(function()
		if removed then
			c.Assert(2);
		else
			c.Assert(3);
		end;
		c.Hit();
	end);
	list:Add(c.Hit);
	list:Fire();
	c.Assert(5);
	r();
	removed=true;
	c.Reset();
	list:Fire();
	c.Assert(4); -- One less than before since the remover has taken away one hit.
end;
