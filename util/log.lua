Log = FritoLib.OOP.Class(LogEntry);
local Log = Log;

function MixinLog(obj, logAttrName)
    if not logAttrName then
        logAttrName = "log";
    end;
    obj.Print = function(self, ...)
        return obj[logAttrName]:Print(...);
    end;
    obj.Head = function(self, ...)
        return obj[logAttrName]:Head(...);
    end;
    obj.Tail = function(self, ...)
        return obj[logAttrName]:Tail(...);
    end;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Log.prototype:init(prefix)
    Log.super.prototype.init(self, LogEntry.entryTypes.LIST);
    self.prefix = tostring(prefix);
    self.listeners = {};
end;

-------------------------------------------------------------------------------
--
--  Logging
--
-------------------------------------------------------------------------------

local function MixinLogEntryCreator(entryType)
    Log.prototype["Log" .. entryType] = function(self, ...)
        return self:InsertLogEntry(LogEntry:new(entryType, self:GetPrefix(), ...));
    end;
end;

MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.DATA));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.DEBUG));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.MESSAGE));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.WARNING));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.ERROR));

function Log.prototype:Log(...)
    return self:InsertLogEntry(LogEntry:new(LogEntry.entryTypes.MESSAGE, self:GetPrefix(), ...));
end;

function Log.prototype:InsertLogEntry(logEntry, doQuietly)
    table.insert(self, logEntry);
    if doQuietly then
        return logEntry;
    end;
    for _, listenerFunc in ipairs(self.listeners) do
        listenerFunc(logEntry);
    end;
    if MasterLog and self ~= MasterLog then
        MasterLog:InsertLogEntry(logEntry);
    end;
    return logEntry;
end;

function Log.prototype:InsertLogEntryQuietly(logEntry, doQuietly)
    return self:InsertLogEntry(logEntry, true);
end;

-------------------------------------------------------------------------------
--
--  Listeners and Pipers
--
-------------------------------------------------------------------------------

function Log.prototype:Listen(listenerFunc, ...)
    listenerFunc = ObjFunc(listenerFunc, ...);
    table.insert(self.listeners, listenerFunc);
    local this = self;
    return function()
        this.listeners = ListUtil:RemoveItem(this.listeners, listenerFunc);
    end;
end;

function Log.prototype:Pipe(medium)
    if not medium or type(medium) ~= "string" then
        error("Invalid medium");
    end;
    local prefixOwner = self;
    return self:Listen(function(logEntry)
        logEntry:Print(prefixOwner:GetPrefix(), medium);
    end);
end;

function Log.prototype:SyndicateTo(log)
    return self:Listen(log, "InsertLogEntryQuietly");
end;

-------------------------------------------------------------------------------
--
--  Some Querying Stuff
--
-------------------------------------------------------------------------------

function Log.prototype:Head(numShown)
    if not numShown then
        numShown = 10;
    end;
    numShown = min(numShown, #self);
    for i=1, numShown do
        self:Print(unpack(self[i]));
    end;
end;

function Log.prototype:Tail(numShown)
    if not numShown then
        numShown = 10;
    end;
    local start = max(1, #self - numShown);
    numShown = min(numShown, #self);
    for i=start,numShown do
        self:Print(unpack(self[i]));
    end;
end;

-------------------------------------------------------------------------------
--
--  Utility
--
-------------------------------------------------------------------------------

