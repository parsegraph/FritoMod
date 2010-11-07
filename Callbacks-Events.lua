-- Callbacks is a namespace of functions that register callbacks. Most
-- callbacks involve registering listeners for events. You can also have
-- callbacks that fire after a given time.
--
-- Callbacks should follow this pattern:
--
-- Callbacks.Resting(listener, ...);
--
-- where listener, ... is a curried function that is called whenever the player is
-- resting. Listeners can be undoable where applicable.
--
-- Whenever I'm writing event listening code, I usually see if I can extract
-- the boilerplate into a function that lives here. A callback usually has a couple
-- possible names, so I typically add aliases until I've covered most of them.

-- Internally, many callbacks use ToggleDispatcher, which greatly simplifies writing
-- callbacks that have two possible states.

if nil ~= require then
    require "currying";
    require "Lists";
    require "ToggleDispatcher";
end;

Callbacks=Callbacks or {};

-- Callbacks.Arena fires the specified callback whenever you enter an arena.
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

-- Callbacks.Resting fires the specified callback whenever the player is resting.
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

-- Callbacks.Combat fires the specified callback whenever the player enters combat.
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

-- Callbacks.Experience fires the specified callback whenever the player gains experience.
--
-- The callback is called like so:
-- callback(currentXP, maxXP, currentLevel)
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
