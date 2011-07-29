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
