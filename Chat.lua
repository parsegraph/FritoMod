-- Chat is a registry of mediums to which to send messages. To use, simply do:
--
-- Chat.Say("Hello!");
-- Chat.RaidWarning("Sup raid :)");
--
-- The most flexible one is "group" which will send messages to the proper group,
-- determining on the fly what that may be:
--
-- Chat.group("Hello, battleground!") -- If you're in WSG
-- Chat.group("Hello, raid!") -- If you're in a raid
-- Chat.group("Hello, party!") -- If you're in a party or dungeon group
--
-- Chat.group will die if you're not in a group.
--
-- You don't have to necessarily use proper capitalization:
--
-- Chat.YELL("I AM YELLING!");
-- Chat.RaidWARNING("Hello again, raid members!");
--
-- Matter of fact, there's a healthy amount of aliases for these standard channels:
--
-- Chat.g("Sup guild!");
-- Chat.gr("HELLO, FELLOW DUNGEONEERS.");
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
-- local r = Iterators.Repeat("guild", "party");
-- Chat[r]("This is sent to the guild");
-- Chat[r]("This is sent to the party");
-- Chat[r]("This is sent to the guild again");

if nil ~= require then
    require "wow/Chat";
    require "currying";
    require "Tables";
    require "Strings";
end;

Chat = {};
Chat = Chat;
local Chat = Chat;

Chat.__Send=function(...)
    if ChatThrottleLib then
        ChatThrottleLib:SendChatMessage("NORMAL", "FritoMod", ...);
    else
        SendChatMessage(...);
    end;
end;

Chat.__Language=function()
    return GetDefaultLanguage("PLAYER");
end;

Chat.__ChannelName=function(...)
    return GetChannelName(...);
end;

local function SendTargetedMessage(medium, target, ...)
    if type(target)=="string" then
        target=target:lower();
    end;
    if select("#", ...)==1 then
        -- We handle single arguments specially if they're tables. If so,
        -- we recurse for each value in the table. 
        local str=...;
        while IsCallable(str) do
            str=str();
        end;
        if type(str)=="table" then
            Lists.Each(str, SendTargetedMessage, medium, target);
        else
            Chat.__Send(tostring(str), medium, Chat.__Language(), target);
        end;
    else
        -- If we receive multiple arguments, there's not really a good way
        -- of cleaning them up, so we defer to Strings.JoinValues.
        Chat.__Send(Strings.JoinValues(" ", ...), medium, Chat.__Language(), target);
    end;
end;

local function SendMessage(medium, ...)
    SendTargetedMessage(medium, "", ...);
end;

Chat.say = CurryFunction(SendMessage, "SAY");
Chat.emote = CurryFunction(SendMessage, "EMOTE");
Chat.yell = CurryFunction(SendMessage, "YELL");
Chat.raid = CurryFunction(SendMessage, "RAID");
Chat.party = CurryFunction(SendMessage, "PARTY");
Chat.raidwarning = CurryFunction(SendMessage, "RAID_WARNING");
Chat.battleground = CurryFunction(SendMessage, "BATTLEGROUND");
Chat.guild = CurryFunction(SendMessage, "GUILD");
Chat.party = CurryFunction(SendMessage, "PARTY");
Chat.officer = CurryFunction(SendMessage, "OFFICER");
Chat.debug = print;

function Chat.channel(target, ...)
    if type(target) == "string" then
        target = Chat.__ChannelName(target);
    end;
    return SendTargetedMessage("CHANNEL", target, ...);
end;

function Chat.whisper(target, ...)
	assert(type(target) == "string", "target must be a string");
    return SendTargetedMessage("WHISPER", target, ...);
end;

-- Sends a message to the appropriate group. This uses IsInInstance
-- to send messages, so battlegrounds and arenas work as intended. 
-- Otherwise, it will send to raid or party. If you're not in a group,
-- this function will raise an error.
function Chat.group(...)
    local _, instanceType=IsInInstance();
    if not instanceType or instanceType=="none" then
        if GetNumRaidMembers() > 0 then
            return Chat.raid(...);
        else
            return Chat.party(...);
        end;
    else
        return Chat[instanceType](...);
    end;
end;

local ALIASES = Tables.Expand({
      c = Chat.channel,
      [{"w", "pst", "tell"}] = Chat.whisper,
      d = "debug",
      g = "guild",
      [{"p", "par", "party"}] = "party",
      [{"gr", "group"}] = "group",
      [{"s", "say"}] = "say",
      [{"y", "yell"}] = "yell",
      [{"r", "ra", "raid"}] = "raid",
      [{"rw", "warning", "warn"}] = "raidwarning",
      [{"o", "officer"}] = "officer",
      [{"bg", "battlegroup", "pvp", "arena"}] = "battleground",
      [{"null", "noop", "none"}] = Noop
});

setmetatable(Chat, {
    __index = function(self, medium)
        if type(medium) == "function" then
            return Chat[medium()];
        end;
        if type(medium) == "table" then
            if medium.GetAttribute then
                local editboxMedium=assert(medium:GetAttribute("chatType"));
                if editboxMedium:lower()=="whisper" then
                    medium=medium:GetAttribute("tellTarget");
                elseif editboxMedium:lower()=="channel" then
                    medium=medium:GetAttribute("channelTarget");
                else
                    return self[editboxMedium];
                end;
            elseif #medium > 0 then
                return function(...)
                    for i=1, #medium do 
                        childMedium = medium[i];
                        Chat[childMedium](...);
                    end;
                end;
            end;
        end;
        if type(medium) == "string" then
            medium=Strings.Trim(medium):lower();
            medium=medium:gsub("[ _]", "");
            local requestedMedium = rawget(Chat, medium);
            if requestedMedium then
                return requestedMedium;
            end;
            if ALIASES[medium] then
				if IsCallable(ALIASES[medium]) then
					return ALIASES[medium];
				end;
                return Chat[ALIASES[medium]];
            end;
            local channelIndex = Chat.__ChannelName(medium);
            if channelIndex > 0 then
                return CurryFunction(Chat.Channel, channelIndex);
            end;
            return CurryFunction(Chat.Whisper, medium);
        end;
		error("medium must be a string, table, or function. Type: " .. type(medium));
    end
});

Chatf=setmetatable({}, {
    __index = function(self, medium)
        self[medium]=function(s, ...)
            return Chat[medium](s:format(...));
        end
        return self[medium];
    end
});
