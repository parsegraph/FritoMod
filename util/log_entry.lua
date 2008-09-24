LogEntry = OOP.Class();
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

function LogEntry:__init(entryType, prefix, ...)
    if entryType == nil then
        entryType = LogEntry.entryTypes.MESSAGE;
    end;
    self.entryType = string.lower(entryType);
    self:SetPrefix(prefix);
    self.data = { ... };
end;

-------------------------------------------------------------------------------
--
--  Getters
--
-------------------------------------------------------------------------------

function LogEntry:GetEntryType()
    return self.entryType;
end;

function LogEntry:GetPrefix()
    return self.prefix;
end;

function LogEntry:SetPrefix(prefix)
    self.prefix = prefix;
end;

-------------------------------------------------------------------------------
--
--  Output 
--
-------------------------------------------------------------------------------

function LogEntry:ToString()
    return self:Print(nil, API.Chat.mediums.NULL);
end;

LogEntry.PREFIX_SYNTAX = "%s: %s";

function LogEntry:Print(prefix, medium)
    --rawdebug("Print", prefix, medium, self:GetEntryType());
    medium = medium or API.Chat.mediums.DEBUG;
    prefix = prefix or "";
    local oldPrefix = prefix;
    local currentPrefix = self:GetPrefix();
    if currentPrefix ~= nil then
        if prefix ~= "" and prefix ~= currentPrefix then
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
