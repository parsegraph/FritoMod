Mediums = {};
local Mediums = Mediums;

local function SendMessage(medium, message)
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

local ALIASES = Expand({
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
            for _, childMedium in ipairs(medium) do
                return Mediums[childMedium];
            end;
            return;
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
