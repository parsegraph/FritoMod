function print(...)
    return API.Chat:Say("debug", tostring(concat(...)));
end;

function debug(...)
    return MasterLog:LogDebug(...);
end;

function log(...)
    return MasterLog:LogMessage(...);
end;

function warning(...)
    return MasterLog:LogWarning(...);
end;

function rawdebug(...)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(concat(...)));
end;
