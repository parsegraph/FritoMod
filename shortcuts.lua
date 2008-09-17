function print(...)
    return MasterLog:Print(...);
end;

function debug(...)
    return MasterLog:Log(...);
end;

function rawdebug(...)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(concat(...)));
end;
