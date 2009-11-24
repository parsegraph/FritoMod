if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Events/EventSource";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Events.EventSource");

function Suite:TestEventSourceAddListener()
    local source = EventSource:New();
    local remover = source:AddListener("Foo", Noop);
    Assert.Type("function", remover, "AddListener returns a callable");
    Assert.Exception("AddListener accepts only string event names", source.AddListener, source, 1, Noop);
end;
