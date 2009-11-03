-- Mediums is a registry of mediums to which to send messages. To use, simply do:
--
-- Mediums.Say("Hello!");
-- Mediums.RaidWarning("Sup raid :)");
--
-- You don't have to necessarily use proper capitalization:
--
-- Mediums.YELL("I AM YELLING!");
-- Mediums.RaidWARNING("Hello again, raid members!");
--
-- Matter of fact, there's a healthy amount of aliases for these standard channels:
--
-- Mediums.g("Sup guild!");
-- Mediums.RW("This is a raid warning");
--
-- Spaces and underscores are also ignored:
--
-- Mediums.RAID_WARNING("Raid warning!");
--
-- If given a non-standard name, it will first check if it's a channel name...
--
-- Mediums.Notime("This is sent to the NOTIME channel, if you're in it.");
--
-- As a last resort, it will whisper a player by that name:
--
-- Mediums.Threep("This is a whisper to Threep");
--
-- You can be explicit and send directly to a channel:
--
-- Mediums.Channel("Threep", "This is always sent to the 'threep' channel");
--
-- You can even batch-send a message to many mediums:
-- 
-- Mediums[{"g", "p"}]("Hello to my party and my guild");
--
-- If necessary, you can even use functions as keys:
--
-- local r = Iterators.Repeat({"guild", "party"});
-- Mediums[r]("This is sent to the guild");
-- Mediums[r]("This is sent to the party");
-- Mediums[r]("This is sent to the guild again");

if nil ~= require then
    -- This file uses WoW-specific functionality
 
    require "FritoMod_Functional/methods";
    require "FritoMod_Functional/currying";

    require "FritoMod_Collections/Tables";

    require "FritoMod_Strings/Strings";
end;

Mediums = {};
local Mediums = Mediums;

local function SendMessage(medium, message, ...)
    message = Strings.Concat(message, ...);
    SendChatMessage(message, medium);
end;

Mediums.Say = CurryFunction(SendMessage, "SAY");
Mediums.Emote = CurryFunction(SendMessage, "EMOTE");
Mediums.Yell = CurryFunction(SendMessage, "YELL");
Mediums.Raid = CurryFunction(SendMessage, "RAID");
Mediums.Party = CurryFunction(SendMessage, "PARTY");
Mediums.RaidWarning = CurryFunction(SendMessage, "RAID_WARNING");
Mediums.Battleground = CurryFunction(SendMessage, "BATTLEGROUND");
Mediums.Guild = CurryFunction(SendMessage, "GUILD");
Mediums.Party = CurryFunction(SendMessage, "PARTY");
Mediums.Officer = CurryFunction(SendMessage, "OFFICER");
Mediums.Null = Noop;
Mediums.Debug = print;

function Mediums.Channel(target, message)
   if type(target) == "string" then
      target = GetChannelName(target);
   end;
   SendChatMessage(message, "channel", nil, target);
end;

function Mediums.Whisper(target, message)
   SendChatMessage(message, "whisper", nil, target);
end;

local ALIASES = Tables.Expand({
      d = "Debug",
      g = "Guild",
      [{"p", "par", "party"}] = "Party",
      [{"gr", "group"}] = "Group",
      [{"s", "say"}] = "Say",
      [{"y", "yell"}] = "Yell",
      [{"r", "ra", "raid"}] = "Raid",
      [{"rw", "warning", "warn"}] = "RaidWarning",
      [{"o", "officer"}] = "Officer",
      [{"bg", "battlegroup"}] = "Battleground"
});

setmetatable(Mediums, {
    __index = function(self, key)
        if type(medium) == "function" then
            return Mediums[medium()];
        end;
        if type(medium) == "table" and #medium > 0 then
            return function(...)
                for i=1, #medium do 
                    childMedium = medium[i];
                    return Mediums[childMedium](...);
                end;
            end;
        end;
        if type(medium) == "string" then
            medium = strtrim(medium);
            if medium:find(" ") then
                medium:gsub(" ", "_");
            end;
            if medium:find("_") then
                medium = Strings.CamelToProperCase(medium);
            elseif medium:lower() == medium or medium:upper() == medium then
                medium = Strings.ProperNounize(medium);
            end;
            local requestedMedium = rawget(Mediums, medium);
            if requestedMedium then
                return requestedMedium;
            end;
            medium = medium:lower();
            if ALIASES[medium] then
                return Mediums[ALIASES[medium]];
            end;
            local channelIndex = GetChannelName(medium);
            if channelIndex then
                return CurryFunction(Mediums.Channel, channelIndex);
            end;
            return CurryFunction(Mediums.Whisper, medium);
        end;
    end
});
