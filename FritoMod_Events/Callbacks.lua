if nil ~= require then
    require "FritoMod_Functional/currying";
    require "FritoMod_Functional/Callbacks";

    require "FritoMod_Collections/Lists";
    require "FritoMod_Events/ToggleDispatcher";
end;

do
    local dispatcher=ToggleDispatcher:New();
    function dispatcher:Install()
        return Events.PLAYER_ENTERING_WORLD(function()
            local _, instanceType = IsInInstance();
            if instanceType and instanceType:lower() == "arena" then
                dispatcher:Fire();
            else
                dispatcher:Reset();
            end;
        end);
    end;
    Callbacks.EnterArena=Curry(dispatcher, "Add");
    Callbacks.Arena=Callbacks.EnterArena;
    Callbacks.EnteredArena=Callbacks.EnterArena;
    Callbacks.EnteringArena=Callbacks.EnterArena;
end;
