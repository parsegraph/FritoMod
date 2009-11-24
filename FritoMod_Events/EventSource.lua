if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Metatables";

    require "FritoMod_OOP/OOP-Class";
    
    require "FritoMod_Collections/Tables";
end;

-- EventSource automatically manages the lifecycle of events and their registered listeners.
EventSource = OOP.Class();
local EventSource = EventSource;
