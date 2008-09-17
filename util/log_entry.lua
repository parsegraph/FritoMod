LogEntry = FritoLib.OOP.Class();
local LogEntry = LogEntry;

LogEntry.entryTypes = {
    LIST = "list",
    DATA = "data",

    DEBUG = "debug",
    WARNING = "warning",
    ERROR = "error",
    MESSAGE = "message",
};

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function LogEntry.prototype:init(entryType, prefix, ...)
    LogEntry.super.prototype.init(self);
    if entryType == nil then
        entryType = LogEntry.entryTypes.MESSAGE;
    end;
    self.entryType = string.lower(entryType);
    self.prefix = prefix;
    self.data = { ... };
end;

-------------------------------------------------------------------------------
--
--  Getters
--
-------------------------------------------------------------------------------

function LogEntry.prototype:GetEntryType()
    return self.entryType;
end;

function LogEntry.prototype:GetPrefix()
    return self.prefix;
end;

-------------------------------------------------------------------------------
--
--  Output 
--
-------------------------------------------------------------------------------

function LogEntry.prototype:ToString()
    return self:Print(nil, API.Chat.mediums.NULL);
end;

LogEntry.PREFIX_SYNTAX = "%s: %s";

function LogEntry.prototype:Print(prefix, medium)
    --rawdebug("Print", prefix, medium, self:GetEntryType());
    medium = medium or API.Chat.mediums.DEBUG;
    prefix = prefix or "";
    local oldPrefix = prefix;
    local currentPrefix = self:GetPrefix();
    if currentPrefix ~= nil then
        if prefix ~= "" then
            prefix = format(LogEntry.PREFIX_SYNTAX, prefix, currentPrefix);
        else
            prefix = currentPrefix;
        end;
    end;
    if self:GetEntryType() == LogEntry.entryTypes.DATA then
        return;
    end;
    if self:GetEntryType() == LogEntry.entryTypes.LIST then
        local lines = {};
        local fullPrefix = prefix;
        for i, logEntry in ipairs(self) do
            if logEntry:GetPrefix() == self:GetPrefix() then
                prefix = oldPrefix;
            else
                prefix = fullPrefix;
            end;
            local output = logEntry:Print(prefix, medium);
            if output ~= nil then
                table.insert(lines, output);
            end;
        end;
        return lines;
    end;
    local message = tostring(concat(unpack(self.data)));
    if prefix ~= "" then
        message = format(LogEntry.PREFIX_SYNTAX, prefix, message);
    end;
    return API.Chat:Say(medium, message, nil, MediaLibrary:GetExplicit("Color", ProperNounize(self:GetEntryType())));
end;
