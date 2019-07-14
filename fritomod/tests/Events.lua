local Suite=CreateTestSuite("fritomod.Events");

function Suite:TestEvents()
	local f=Tests.Flag();
	local r=Events.ADDON_LOADED(function(a)
		Assert.Equals("MyAddon", a, "Events must pass arguments to listeners");
		f.AssertUnset("Events calls listeners only once per each event");
		f.Raise();
	end);
	Events.Dispatch("ADDON_LOADED", "MyAddon");
	f.Assert("Events calls listeners exactly once per event");
	r();
	-- Test to ensure the remover actually worked
	Events.Dispatch("ADDON_LOADED", "MyAddon");
end;
