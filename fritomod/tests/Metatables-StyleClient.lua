local Suite = CreateTestSuite("fritomod.Metatables-StyleClient");

sc = nil;

Suite:AddListener({
	TestStarted = function()
		sc = Metatables.StyleClient();
	end
});

function Suite:TestStyleClient()
	sc.color = "blue";
	Assert.Equals("blue", sc.color, "Client returns correct color");
end;

function Suite:TestStyleClientIgnoresCapitalization()
	sc.color = 1;
	Assert.Equals(1, sc.COLOR, "Client returns value for color in spite of capital letters");
end;

function Suite:TestStyleClientOnNil()
	Assert.Equals(nil, sc.color, "Client returns nil on missing value");
end;

function Suite:TestStyleClientThrowsOnNilKey()
	Assert.Exception("StyleClient doesn't accept setting nil keys", function()
		sc[nil] = true;
	end);
end;

function Suite:TestStyleClientHandlesRetrievingNilKeys()
	Assert.Equals(nil, sc[nil], "StyleClient returns nil for nil key");
end;

function Suite:TestProcessedValues()
	sc.ProcessedStyle("color", Functions.Return, 1);
	sc.color = true;
	Assert.Equals(1, sc.color);
end;

function Suite:TestSilentProcessorDoesntModifyStyle()
	sc.ProcessedStyle("color", function(v)
		Assert.Equals(1, v, "Processor receives style");
	end);
	sc.color = 1;
	Assert.Equals(1, sc.color);
end;

function Suite:TestStyleClientInheritors()
	sc.Inherits({
		color = 1
	});
	Assert.Equals(1, sc.color);
end;

function Suite:TestStyleClientInheritsStyleClient()
	local parent = Metatables.StyleClient();
	parent.color = 2;
	sc.Inherits(parent);
	Assert.Equals(2, sc.color);
end;

function Suite:TestStyleClientInheritsDeepStyleClient()
	local p = Metatables.StyleClient();
	local gp = Metatables.StyleClient();
	gp.color = 1;
	p.Inherits(gp);
	sc.Inherits(p);
	Assert.Equals(1, sc.color);
end;

function Suite:TestRemoveInherited()
	local r = sc.Inherits({
		color = 1
	});
	r();
	Assert.Equals(nil, sc.color);
end;

function Suite:TestListener()
	local f = Tests.Flag();
	local r = sc:AddListener(function(key, value)
		f.AssertFalse("Listener is only called once");
		f.Raise();
		Assert.Equals("color", key);
		Assert.Equals(2, value);
	end);
	sc.color = 2;
	f.Assert("Listener is invoked on new style");
end;

function Suite:TestListenerWithParent()
	local f = Tests.Flag();
	sc:AddListener(function(key, value)
		f.AssertFalse("Listener is only called once");
		f.Raise();
		Assert.Equals("color", key);
		Assert.Equals(2, value);
	end);
	local p = Metatables.StyleClient();
	sc.Inherits(p);
	p.color = 2;
	f.Assert("Listener is invoked on new style");
end;

function Suite:TestListenerDoesntFireOnShadowedChanges()
	sc.color = "green";
	sc:AddListener(function(key, value)
		error("Shadowed changes do not generate events");
	end);
	local p = Metatables.StyleClient();
	sc.Inherits(p);
	p.color = "blue";
end;

function Suite:TestShadowedChangesCanBeRevealed()
	local f = Tests.Flag();
	sc.color = "child";
	local p = Metatables.StyleClient();
	p.color = "parent";
	sc:AddListener(function(key, value)
		f.AssertUnset();
		f.Raise();
		Assert.Equals("color", key);
		Assert.Equals("parent", value);
	end);
	sc.Inherits(p);
	sc.color = nil;
	f.Assert();
end;

function Suite:TestNewParentsImmediatelyAffectStyles()
	local f = Tests.Flag();
	local p = Metatables.StyleClient();
	p.color = "parent";
	sc:AddListener(function(key, value)
		f.AssertUnset();
		f.Raise();
		Assert.Equals("color", key);
		Assert.Equals("parent", value);
	end);
	sc.Inherits(p);
	f.Assert("Parent causes listener to fire");
end

function Suite:TestRemovedParentsImmediatelyAffectStyles()
	local f = Tests.Flag();
	local p = Metatables.StyleClient();
	p.color = "parent";
	local r = sc.Inherits(p);
	sc:AddListener(function(key, value)
		f.AssertUnset();
		f.Raise();
		Assert.Equals("color", key);
		Assert.Equals(nil, value);
	end);
	r();
	f.Assert("Removing parent causes listener to fire");
end;

function Suite:TestRemovingDeeplyNestedParent()
	local f = Tests.Flag();
	local p = Metatables.StyleClient();
	local gp = Metatables.StyleClient();
	sc.color = 1;
	p.color = 2;
	gp.color = 3;
	sc.Inherits(p);
	p.Inherits(gp);
	Assert.Equals(1, sc.color);
	sc.AddListener(function(key, value)
		error("Listeners dont fire on shadowed removals");
	end);
	p.color=nil;
	Assert.Equals(3, p.color);
end;

function Suite:TestIndirectUpdate()
	local f = Tests.Flag();
	local p = Metatables.StyleClient();
	local gp = Metatables.StyleClient();
	sc.color = 1;
	gp.color = 3;
	sc.Inherits(p);
	p.Inherits(gp);
	sc.AddListener(function(key, value)
		error("Listeners dont fire on shadowed removals");
	end);
	p.color=nil;
	Assert.Equals(3, p.color);
end;

function Suite:TestPoorlyCapitalizedTable()
	sc.Inherits({
		Color=2
	});
	Assert.Equals(2,sc.color);
end;

function Suite:TestInitialStyleLoading()
	sc=Metatables.StyleClient({color=2});
	Assert.Equals(2, sc.color);
end;

function Suite:TestInheritingAChangedNakedTable()
	local a = {color=2};
	sc.Inherits(a);
	local f = Tests.Flag();
	sc.AddListener(function(k,v)
		f.AssertUnset();
		f.Raise();
		Assert.Equals(3, v);
	end);
	a.color=3;
	f.Assert();
	Assert.Equals(3,sc.color);
end;

function Suite:TestPleaseDontEraseMyMistakenlyGivenClass()
	Assert.Exception(sc.Inherits,OOP.Class():New());
	Assert.Exception(Metatables.StyleClient, OOP.Class():New());
end;
