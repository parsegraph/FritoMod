Log = FritoLib.OOP.Class();
local Log = Log;

function MixinLog(obj, logAttrName)
    if not logAttrName then
        logAttrName = "log";
    end;
    local objLog = obj[logAttrName];
    obj.Cat = ObjFunc(objLog, "Cat");
    obj.Head = ObjFunc(objLog, "Head");
    obj.Tail = ObjFunc(objLog, "Tail");
end;

-------------------------------------------------------------------------------
--
--  Constructor
--
-------------------------------------------------------------------------------

function Log.prototype:init(prefix)
    Log.super.prototype.init(self);
    self.prefix = tostring(prefix);
    self.listeners = {};
end;

-------------------------------------------------------------------------------
--
--  Prefix stuff
--
-------------------------------------------------------------------------------

function Log.prototype:SetPrefix(prefix)
    self.prefix = prefix;
end;

function Log.prototype:GetPrefix()
    return self.prefix;
end;

-------------------------------------------------------------------------------
--
--  Logging
--
-------------------------------------------------------------------------------

local function MixinLogEntryCreator(entryType)
    Log.prototype["Log" .. entryType] = function(self, ...)
        return self:InsertLogEntry(LogEntry:new(entryType, ...));
    end;
end;

local entryTypes = {"Message", "Error", "Debug", "Data", "Warning"};
for _, entryType in ipairs(entryTypes) do
    MixinLogEntryCreator(entryType);
end;

function Log.prototype:Log(...)
    return self:InsertLogEntry(LogEntry:new("Message", ...));
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

-------------------------------------------------------------------------------
--
--  Listeners and Pipers
--
-------------------------------------------------------------------------------

function Log.prototype:Listen(listenerFunc, ...)
    listenerFunc = ObjFunc(listenerFunc, ...);
    table.insert(self.listeners, listenerFunc);
    local listeners = self.listeners;
    return function()
        listeners = ListUtil:RemoveItem(listeners, listenerFunc);
    end;
end;

function Log.prototype:Pipe(medium)
    if not medium or type(medium) ~= "string" then
        error("Invalid medium");
    end;
    return self:Listen(function(...)
        API.Chat:Say(medium, tostring(concat(...)));
    end);
end;

function Log.prototype:Syndicate(log)
    return self:Listen(log, "LogQuietly");
end;

-------------------------------------------------------------------------------
--
--  Some Querying Stuff
--
-------------------------------------------------------------------------------

function Log.prototype:Cat()
    for _, message in ipairs(self) do
        self:Print(unpack(message));
    end;
end;

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

function Log.prototype:Print(...)
    local message = tostring(concat(...));
    if self:GetPrefix() then
        message = self:GetPrefix() .. " - " .. message;
    end;
    API.Chat:Print(message);
end;

MasterLog = Log:new("FritoMod");
--MasterLog:Pipe(API.Chat.mediums.DEBUG);
