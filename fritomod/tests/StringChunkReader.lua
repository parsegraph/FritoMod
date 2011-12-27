local Suite=CreateTestSuite("fritomod.StringChunkReader");

function Suite:TestStringChunkReader()
	local reader = StringChunkReader:New();
	local f = Tests.Flag();
	reader:Add(function(msg, who)
		Assert.Equals("Foo", msg);
		Assert.Equals("Frito", who);
		f.Raise();
	end);
	reader:Read(":Foo", "Frito");
	f.Assert();
end;

function Suite:TestStringChunkReaderWithChunkedString()
	local reader = StringChunkReader:New();
	local f = Tests.Flag();
	reader:Add(function(msg, who)
		f.AssertUnraised();
		Assert.Equals("Fooderbug", msg);
		Assert.Equals("Frito", who);
		f.Raise();
	end);
	reader:Read("1:Foo", "Frito");
	reader:Read("1:der", "Frito");
	reader:Read("1:bug", "Frito");
	reader:Read("1:", "Frito");
	f.Assert();
end;

function Suite:TestChunkStringCallback()
	local callback=Objects.Value();
	local flag=Tests.Flag();
	local remover=Callbacks.StringChunks(callback.Set, function(message, who, ...)
		flag.AssertUnraised();
		Assert.Equals("Foo", message);
		Assert.Equals("Frito", who);
		flag.Raise();
	end);
	callback.Get()(":Foo", "Frito");
	flag.Assert();
end;

function Suite:TestCallbackWithABrokenString()
	local callback=Objects.Value();
	local flag=Tests.Flag();
	local remover=Callbacks.StringChunks(callback.Set, function(message, who, ...)
		flag.AssertUnraised();
		Assert.Equals("Fooderbug", message);
		Assert.Equals("Frito", who);
		flag.Raise();
	end);
	callback.Get()("1:Foo", "Frito");
	callback.Get()("1:der", "Frito");
	callback.Get()("1:bug", "Frito");
	callback.Get()("1:", "Frito");
	flag.Assert();
end;
