-- Chat is a registry of mediums to which to send messages. To use, simply do:
--
-- Chat.Say("Hello!");
-- Chat.RaidWarning("Sup raid :)");
--
-- You don't have to necessarily use proper capitalization:
--
-- Chat.YELL("I AM YELLING!");
-- Chat.RaidWARNING("Hello again, raid members!");
--
-- Matter of fact, there's a healthy amount of aliases for these standard channels:
--
-- Chat.g("Sup guild!");
-- Chat.RW("This is a raid warning");
--
-- Spaces and underscores are also ignored:
--
-- Chat.RAID_WARNING("Raid warning!");
--
-- If given a non-standard name, it will first check if it's a channel name...
--
-- Chat.Notime("This is sent to the NOTIME channel, if you're in it.");
--
-- As a last resort, it will whisper a player by that name:
--
-- Chat.Threep("This is a whisper to Threep");
--
-- You can be explicit and send directly to a channel:
--
-- Chat.Channel("Threep", "This is always sent to the 'threep' channel");
--
-- You can even batch-send a message to many mediums:
-- 
-- Chat[{"g", "p"}]("Hello to my party and my guild");
--
-- If necessary, you can even use functions as keys:
--
-- local r = Iterators.Repeat({"guild", "party"});
-- Chat[r]("This is sent to the guild");
-- Chat[r]("This is sent to the party");
-- Chat[r]("This is sent to the guild again");

if nil ~= require then
    -- This file uses WoW-specific functionality
 
    require "FritoMod_Functional/currying";

    require "FritoMod_Collections/Tables";

    require "FritoMod_Strings/Strings";
end;

Chat = {};
Chat = Chat;
local Chat = Chat;

local function SendMessage(medium, message, ...)
    message = Strings.JoinValues(" ", message, ...);
    SendChatMessage(message, medium);
end;

Chat.Say = CurryFunction(SendMessage, "SAY");
Chat.Emote = CurryFunction(SendMessage, "EMOTE");
Chat.Yell = CurryFunction(SendMessage, "YELL");
Chat.Raid = CurryFunction(SendMessage, "RAID");
Chat.Party = CurryFunction(SendMessage, "PARTY");
Chat.RaidWarning = CurryFunction(SendMessage, "RAID_WARNING");
Chat.Battleground = CurryFunction(SendMessage, "BATTLEGROUND");
Chat.Guild = CurryFunction(SendMessage, "GUILD");
Chat.Party = CurryFunction(SendMessage, "PARTY");
Chat.Officer = CurryFunction(SendMessage, "OFFICER");
Chat.Null = Noop;
Chat.Debug = print;

function Chat.Channel(target, message)
   if type(target) == "string" then
      target = GetChannelName(target);
   end;
	assert(message ~= nil, "message must be provided");
   SendChatMessage(message, "CHANNEL", GetDefaultLanguage("PLAYER"), target);
end;

function Chat.Whisper(target, message)
	assert(type(target) == "string", "target must be a string");
	assert(message ~= nil, "message must be provided");
	SendChatMessage(message, "WHISPER", GetDefaultLanguage("PLAYER"), target:lower());
end;

local ALIASES = Tables.Expand({
      c = Chat.Channel,
      w = Chat.Whisper,
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

setmetatable(Chat, {
    __index = function(self, medium)
        if type(medium) == "function" then
            return Chat[medium()];
        end;
        if type(medium) == "table" and #medium > 0 then
            return function(...)
                for i=1, #medium do 
                    childMedium = medium[i];
                    Chat[childMedium](...);
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
            local requestedMedium = rawget(Chat, medium);
            if requestedMedium then
                return requestedMedium;
            end;
            medium = medium:lower();
            if ALIASES[medium] then
				if IsCallable(ALIASES[medium]) then
					return ALIASES[medium];
				end;
                return Chat[ALIASES[medium]];
            end;
            local channelIndex = GetChannelName(medium);
            if channelIndex > 0 then
                return CurryFunction(Chat.Channel, channelIndex);
            end;
            return CurryFunction(Chat.Whisper, medium);
        end;
		error("medium must be a string, table, or function. Type: " .. type(medium));
    end
});
