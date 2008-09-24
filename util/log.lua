Log = OOP.Class(LogEntry);
local Log = Log;

function LogMixin(class)
    logAttrName = logAttrName or "log";
    OOP.IntegrateLibrary({
        Print = function(self, ...)
            return obj[logAttrName]:Print(...);
        end,
        Head = function(self, ...)
            return obj[logAttrName]:Head(...);
        end,
        Tail = function(self, ...)
            return obj[logAttrName]:Tail(...);
        end
    }, class);
    return function(self, class)
        if not self[logAttrName] then
            self[logAttrName] = Log();
        end;
    end;
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Log:__init(prefix, suppressMasterLog)
    Log.__super.__init(self, LogEntry.entryTypes.LIST);
    self.prefix = tostring(prefix);
    self.listeners = {};

    if false and not suppressMasterLog then
        self.DetachMasterLog = self:Listen(self, function(self, logEntry)
            if MasterLog and self ~= MasterLog and not self.suppressMasterLog then
                MasterLog:InsertLogEntry(logEntry);
            end;
        end);
    end;
end;

-------------------------------------------------------------------------------
--
--  Logging
--
-------------------------------------------------------------------------------

local function MixinLogEntryCreator(entryType)
    Log["Log" .. entryType] = function(self, ...)
        return self:InsertLogEntry(LogEntry(entryType, self:GetPrefix(), ...));
    end;
end;

MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.DATA));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.DEBUG));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.MESSAGE));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.WARNING));
MixinLogEntryCreator(ProperNounize(LogEntry.entryTypes.ERROR));

function Log:Log(...)
    return self:InsertLogEntry(LogEntry(LogEntry.entryTypes.MESSAGE, self:GetPrefix(), ...));
end;

function Log:InsertLogEntry(logEntry, isQuiet)
    if isQuiet == nil then
        isQuiet = self:IsQuiet();
    end;
    table.insert(self, logEntry);
    if isQuiet then
        return logEntry;
    end;
    for _, listenerFunc in ipairs(self.listeners) do
        listenerFunc(logEntry);
    end;
    return logEntry;
end;

function Log:InsertLogEntryQuietly(logEntry)
    return self:InsertLogEntry(logEntry, true);
end;

function Log:InsertLogEntryLoudly(logEntry)
    return self:InsertLogEntry(logEntry, false);
end;

-------------------------------------------------------------------------------
--
--  Listeners and Pipers
--
-------------------------------------------------------------------------------

function Log:Listen(listenerFunc, ...)
    listenerFunc = ObjFunc(listenerFunc, ...);
    table.insert(self.listeners, listenerFunc);
    local this = self;
    return function()
        this.listeners = ListUtil:RemoveItem(this.listeners, listenerFunc);
    end;
end;

function Log:Pipe(medium)
    if not medium or type(medium) ~= "string" then
        error("Invalid medium");
    end;
    local prefixOwner = self;
    return self:Listen(function(logEntry)
        logEntry:Print(prefixOwner:GetPrefix(), medium);
    end);
end;

function Log:SyndicateTo(log)
    return self:Listen(log, "InsertLogEntryQuietly");
end;

-------------------------------------------------------------------------------
--
--  Quietness
--
-------------------------------------------------------------------------------

function Log:SetQuiet(isQuiet)
    self.isQuiet = isQuiet;
    return self.isQuiet;
end;

function Log:IsQuiet()
    return self.isQuiet;
end;

-------------------------------------------------------------------------------
--
--  Some Querying Stuff
--
-------------------------------------------------------------------------------

function Log:Head(numShown)
    if not numShown then
        numShown = 10;
    end;
    numShown = min(numShown, #self);
    for i=1, numShown do
        self:Print(unpack(self[i]));
    end;
end;

function Log:Tail(numShown)
    if not numShown then
        numShown = 10;
    end;
    local start = max(1, #self - numShown);
    numShown = min(numShown, #self);
    for i=start,numShown do
        self:Print(unpack(self[i]));
    end;
end;
