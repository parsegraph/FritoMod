LogEntry = FritoLib.OOP.Class();
local LogEntry = LogEntry;

function LogEntry.prototype:init(entryType, ...)
    LogEntry.super.prototype.init(self);
    self.entryType = string.lower(entryType);
    self.data = { ... };
end;
