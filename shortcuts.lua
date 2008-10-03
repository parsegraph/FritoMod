function print(...)
    return API.Chat:Say("debug", tostring(concat(...)));
end;

function debug(...)
    return Environment.GetInstance():LogDebug(...);
end;

function log(...)
    return Environment.GetInstance():LogMessage(...);
end;

function warning(...)
    return Environment.GetInstance():LogWarning(...);
end;

function rawdebug(...)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(concat(...)));
end;
