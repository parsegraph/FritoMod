if nil ~= require then
    require "FritoMod_Testing/ReflectiveTestSuite";
    require "FritoMod_Testing/Assert";
    require "FritoMod_Testing/Tests";

    require "FritoMod_Events/EventSource";
end;

local Suite = ReflectiveTestSuite:New("FritoMod_Events.EventSource");

function Suite:TestEventSource()
    local source = EventSource:New();
end;

