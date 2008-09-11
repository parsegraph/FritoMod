function debug(...)
    return LogManager:Log(...);
end;

-------------------------------------------------------------------------------
--
--  LogManager
--
-------------------------------------------------------------------------------

LogManager = Log:new(LogManager, "LogManager")
local LogManager = LogManager;

LogManager:Pipe(Chat.mediums.debug);
