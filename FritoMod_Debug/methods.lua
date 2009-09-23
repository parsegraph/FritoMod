--[[ 
-- A collection of debug-level convenience methods. In production use, no 
-- methods named here would be used.
--]]

--[[function print(...)
    return API.Chat:Say("debug", tostring(Strings.Concat(...)));
end;]]

function debug(...)
    return Environment.GetCurrentEnvironment():LogDebug(...);
end;

function log(...)
    return Environment.GetCurrentEnvironment():LogMessage(...);
end;

function warning(...)
    return Environment.GetCurrentEnvironment():LogWarning(...);
end;

function rawdebug(...)
    DEFAULT_CHAT_FRAME:AddMessage(tostring(Strings.Concat(...)));
end;
