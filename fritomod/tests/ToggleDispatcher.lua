local Suite=CreateTestSuite("fritomod.ToggleDispatcher");

function Suite:TestAddingAndRemovingAListener()
	local v=Tests.Counter(0);
	local dispatcher=ToggleDispatcher:New();
	local r=dispatcher:Add(v.Hit);
	dispatcher:Fire();
	v.Assert(1);
	r();
	dispatcher:Fire();
	v.Assert(1);
end;

function Suite:TestListenerWithAResetter()
	local v=Tests.Counter(0);
	local dispatcher=ToggleDispatcher:New();
	local r=dispatcher:Add(Functions.Undoable(v.Hit, v.Hit));
	dispatcher:Fire();
	v.Assert(1);
	dispatcher:Reset();
	v.Assert(2);
	dispatcher:Fire();
	v.Assert(3);
	r();
	dispatcher:Reset();
	v.Assert(3);
end;

function Suite:TestInstallingDispatcher()
	local dispatcher=ToggleDispatcher:New();
	local v=Tests.Value(false);
	dispatcher:AddInstaller(v.Change, true);
	v.Assert(false);
	local r=dispatcher:Add(Noop);
	v.Assert(true);
	r();
	v.Assert(false);
end;

function Suite:TestDispatcherPassesArgumentsDirectly()
	local dispatcher=ToggleDispatcher:New();

    local flag = Tests.Flag();
	dispatcher:Add(function(first, second, ...)
        flag.Raise();
        assert(first == 42);
        assert(second == 24);
        assert(select("#", ...) == 0);
    end);

    dispatcher:Fire(42, 24);
	flag.Assert();
end;

function Suite:TestDispatcherDoesntAddAnyArgumentsToInstallers()
	local dispatcher=ToggleDispatcher:New();
	local installerFlag = Tests.Flag();
	local removerFlag = Tests.Flag();
	local installer = function(a, b, c)
		installerFlag.Raise();
		assert(a == nil);
		assert(b == nil);
		assert(c == nil);
		return function(d, e, f)
			removerFlag.Raise();
			assert(d == nil);
			assert(e == nil);
			assert(f == nil);
		end;
	end;
	dispatcher:AddInstaller(installer);
	local r = dispatcher:Add(Noop);
	r();
	installerFlag.AssertRaised();
	removerFlag.AssertRaised();
end;
