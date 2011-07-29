local Suite=CreateTestSuite("fritomod.Events");

function Suite:TestEvents()
	local f=Tests.Flag();
	local r=Events.FOO(function(a)
		Assert.Equals(true, a, "Events must pass arguments to listeners");
		f.AssertUnset("Events calls listeners only once per each event");
		f.Raise();
	end);
	Events._call("FOO", true);
	f.Assert("Events calls listeners exactly once per event");
	r();
	-- Test to ensure the remover actually worked
	Events._call("FOO", true);
end;
