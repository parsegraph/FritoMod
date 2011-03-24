local Suite=CreateTestSuite("Callbacks-StringChunks");

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
