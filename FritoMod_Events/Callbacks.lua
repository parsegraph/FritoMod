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

do
    local dispatcher=ToggleDispatcher:New();
    function dispatcher:Install()
        return Events.PLAYER_UPDATE_RESTING(function()
            if IsResting() then
                dispatcher:Fire();
            else
                dispatcher:Reset();
            end;
        end);
    end;
    Callbacks.Resting=Curry(dispatcher, "Add");
    Callbacks.Rest=Callbacks.Resting;
    Callbacks.RestState=Callbacks.Resting;
end;

do
    local dispatcher=ToggleDispatcher:New();
    function dispatcher:Install()
        local r1=Events.PLAYER_REGEN_DISABLED(Seal(dispatcher, "Fire"));
        local r2=Events.PLAYER_REGEN_ENABLED(Seal(dispatcher, "Reset"));
        return Functions.OnlyOnce(function()
            r1();
            r2();
        end);
    end;
    Callbacks.Combat=Curry(dispatcher, "Add");
    Callbacks.InCombat=Callbacks.Combat;
end;

do
    function Callbacks.Experience(func, ...)
        func=Curry(func, ...);
        Events.PLAYER_XP_UPDATE(function(who)
            if who:lower()=="player" then
                func(UnitXP("player"), UnitXPMax("player"), UnitLevel("player"));
            end;
        end);
    end;
    Callbacks.XP=Callbacks.Experience;
end;
