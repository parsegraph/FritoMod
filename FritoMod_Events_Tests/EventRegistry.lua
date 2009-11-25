if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Events/EventRegistry";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Events.EventRegistry");

function Suite:TestEventRegistryAddListener()
    local source = EventRegistry:New();
    local remover = source:AddListener("Foo", Noop);
    Assert.Type("function", remover, "AddListener returns a callable");
    Assert.Exception("AddListener accepts only string event names", source.AddListener, source, 1, Noop);
end;

function Suite:TestEventRegistryDispatch()
    local value = Tests.Value(false);
    local source = EventRegistry:New();
    local remover = source:AddListener("Foo", value.Set);
    source:Dispatch("Foo", true);
    value.Assert(true, "Event is dispatched to listeners");
    remover();
    value.Set(false);
    source:Dispatch("Foo", true);
    value.Assert(false, "Listener is removed once function is called");
    Assert.Nil(source:Dispatch("Foo"), "Dispatch returns nothing");
end;

function Suite:TestEventRegistryAddListenerHasIdempotentRemover()
    local value = Tests.Value(false);
    local source = EventRegistry:New();
    local remover = source:AddListener("Foo", value.Set);
    remover();
    source:AddListener("Foo", value.Set);
    remover();
    source:Dispatch("Foo", true);
    value.Assert(false, "Removing function is idempotent");
end;
