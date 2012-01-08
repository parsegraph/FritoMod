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
	require "fritomod/currying";
	require "fritomod/Callbacks";
	require "fritomod/Lists";
	require "fritomod/IdempotentToggleDispatcher";
	require "fritomod/ToggleDispatcher";
	require "fritomod/Events";
end;

Callbacks=Callbacks or {};

do
	local lastInstance;
	local listeners={};
	local removers;
	Callbacks.ChangedInstance=Functions.Spy(
		function(func, ...)
			func=Curry(func, ...);
			func(select(2, IsInInstance()));
			return Lists.Insert(listeners, func);
		end,
		Functions.Install(function()
			lastInstance=select(2, IsInInstance());
			return Events.PLAYER_ENTERING_WORLD(function()
				if removers then
					Lists.CallEach(removers);
				end;
				removers=Lists.MapCall(listeners, select(2, IsInInstance()));
			end);
		end)
	);
	Callbacks.InstanceChange=Callbacks.ChangedInstance;
	Callbacks.InstanceChanged=Callbacks.ChangedInstance;
	Callbacks.ChangeInstance=Callbacks.ChangedInstance;
end;

local function InstanceWatcher(watchedType, specialName)
	local dispatcher=IdempotentToggleDispatcher:New();
	dispatcher:AddInstaller(function()
		return Callbacks.ChangedInstance(function(instanceType)
			if instanceType:lower()==watchedType then
				dispatcher:Fire();
			else
				dispatcher:Reset();
			end;
		end);
	end);
	Callbacks[specialName]=Curry(dispatcher, "Add");
	Callbacks["Enter"..specialName]=Callbacks[specialName];
	Callbacks["Entering"..specialName]=Callbacks[specialName];
	Callbacks["Entered"..specialName]=Callbacks[specialName];

	Callbacks["Leave"..specialName]=Callbacks.ReversedCallback("Enter"..specialName);
	Callbacks["Leaving"..specialName]=Callbacks["Leave"..specialName];
	Callbacks["Left"..specialName]=Callbacks["Leave"..specialName];
end;

InstanceWatcher("arena", "Arena");
InstanceWatcher("pvp", "Battleground");
InstanceWatcher("raid", "RaidInstance");
Callbacks.EnterRaid=Callbacks.EnterRaidInstance;
Callbacks.EnteringRaid=Callbacks.EnterRaidInstance;
Callbacks.EnteredRaid=Callbacks.EnterRaidInstance;
InstanceWatcher("party", "Dungeon");
InstanceWatcher("none", "World");

-- Callbacks.Resting fires the specified callback whenever the player is resting.
do
	local dispatcher=ToggleDispatcher:New();
	dispatcher:AddInstaller(function()
		return Events.PLAYER_UPDATE_RESTING(function()
			if IsResting() then
				dispatcher:Fire();
			else
				dispatcher:Reset();
			end;
		end);
	end);
	Callbacks.Resting=Curry(dispatcher, "Add");
	Callbacks.Rest=Callbacks.Resting;
	Callbacks.RestState=Callbacks.Resting;
end;

-- Callbacks.Combat fires the specified callback whenever the player enters combat.
do
	local dispatcher=ToggleDispatcher:New();
	dispatcher:AddInstaller(
		Events.PLAYER_REGEN_DISABLED, Seal(dispatcher, "Fire"));
	dispatcher:AddInstaller(
		Events.PLAYER_REGEN_ENABLED, Seal(dispatcher, "Reset"));
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
