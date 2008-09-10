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
}

Chat.fauxMediums = {
    CHANNEL = "channel",
    WHISPER = "whisper",
    AFK = "afk",
    DND = "dnd"
};

Chat.languages = {
    COMMON = "common",
    DARNASSIAN = "darnassian",
    DWARVEN = "dwarven",
    DRAENEI = "draenei",
    TAURAHE = "taurahe",
    ORCISH = "orcish",
    GUTTERSPEAK = "gutterspeak",
    DEMONIC = "demonic",
    DRACONIC = "draconic",
    KALIMAG = "kalimag",
    TITAN = "titan",
    GNOMISH = "gnomish",
    TROLL = "troll"
};

function Chat:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(message);
end;

function Chat:Say(medium, message, language)
    if not language then
        language = API.Unit:DefaultLanguage();
    end;
    medium = string.upper(medium);
    if medium == Chat.mediums.DEBUG then
        return API.Chat:Print(message);
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
end;

function Chat:Whisper(playerName, message, language)
    if not language then
        language = API.Unit:GetDefaultLanguage();
    end;
    SendChatMessage(message, Chat.fauxMediums.WHISPER, language, playerName); 
end;

function Chat:GetChannelIndex(channelName)
    local index = GetChannelName(channelName);
    return index;
end;
