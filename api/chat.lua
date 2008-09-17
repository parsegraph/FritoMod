API.Chat = {};
local Chat = API.Chat;

Chat.mediums = {
    SAY = "say",
    EMOTE = "emote", 
    YELL = "yell",
    PARTY = "party", 
    GUILD = "guild",
    OFFICER = "officer",
    RAID = "raid",
    RAID_WARNING = "raid_warning",
    BATTLEGROUND = "battleground",
    DEBUG = "debug",
    NULL = "null",
}

Chat.fauxMediums = {
    CHANNEL = "channel",
    WHISPER = "whisper",
    AFK = "afk",
    DND = "dnd"
};

function Chat:Color(color, message)
    if color == nil then
        return message;
    end;
    if type(color) == "string" then
        local retrievedColor = MediaLibrary:GetExplicit("Color", color);
        if retrievedColor then
            color = retrievedColor;
        end;
    end;
    if type(color) == "table" then
        color = Chat:GetColorString(color);
    end;
    if #color ~= 8 or not string.find(color, "^[0-9a-fA-F]+$") then
        error(format("Color is invalid: '%s'", color));
    end;
    return "|c" .. color .. message .. "|r";
end;

function Chat:GetColorString(color, ...)
    if select("#", ...) > 0 then
        color = { color, ... };
    end;
    return string.join("", unpack(ListUtil:Map(color, {}, function(colorValue)
        local hexColor = ConvertToBase(16, math.floor(colorValue * 255));
        while #hexColor < 2 do
            hexColor = "0" .. hexColor;
        end;
        return hexColor;
    end)));
end;

function Chat:Print(message)
    return Chat:Say(Chat.mediums.DEBUG, message);
end;

function Chat:Say(medium, message, language, color, ...)
    if select("#", ...) > 0 then
        color = {color, ...};
    end;
    if not language then
        language = API.Unit:GetDefaultLanguage("player");
    end;
    if not medium or type(medium) ~= "string" then
        error("Invalid medium (Medium is falsy)");
    end;
    medium = string.upper(medium);
    local loweredMedium = string.lower(medium);
    if loweredMedium == Chat.mediums.NULL or loweredMedium == Chat.mediums.DEBUG then
        if color then
            message = API.Chat:Color(color, message);
        end;
        if loweredMedium == Chat.mediums.DEBUG then
            DEFAULT_CHAT_FRAME:AddMessage(message);
        end;
        return message;
    end;
    if Chat.mediums[medium] then
        SendChatMessage(message, medium, language);
    else
        local channel = medium;
        medium = Chat.fauxMediums.CHANNEL;
        if tonumber(channel) == nil then
            channel = API.Chat:GetChannelIndex(channel);
        end;
        SendChatMessage(message, Chat.fauxMediums.CHANNEL, language, channel);
    end;
    return message;
end;

function Chat:Whisper(playerName, message, language)
    if not language then
        language = API.Unit:GetDefaultLanguage("player");
    end;
    SendChatMessage(message, Chat.fauxMediums.WHISPER, language, playerName); 
end;

function Chat:GetChannelIndex(channelName)
    local index = GetChannelName(channelName);
    return index;
end;

function Chat:GetChannels()
    local channels = { GetChannelList() };
    error("NYI");
end;
