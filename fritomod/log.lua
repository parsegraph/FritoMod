if nil ~= require then
    require "fritomod/Math";
    require "wow/api/Timing";
    require "fritomod/basic";
    require "fritomod/OOP";
end;

Log = Log or {};

local loggers = {}

local function Add(logger, ...)
    logger = Curry(logger, ...);
    table.insert(loggers, logger);
    return function()
        for i=#loggers,1,-1 do
            if loggers[i] == logger then
                table.remove(loggers, i);
                i = i + 1;
            end;
        end;
    end;
end;

local function Fire(...)
    for i=1, #loggers do
        loggers[i](...);
    end;
end;

local function ProcessMessage(...)
    local values = {...};
    for i=1, select("#", ...) do
        if values[i] == nil then
            values[i] = "<nil>";
        end;
    end;
    local msg = "";
    for i, value in ipairs(values) do
        msg = msg .. tostring(value);
        if i < #values then
            msg = msg .. " ";
        end;
    end;
    return msg;
end;

function Log.AddLogger(logger, ...)
    return Add(logger, ...);
end;

local firstMessage;

local function LogMessage(event, sender, category, ...)
    if #loggers == 0 then
        -- No loggers, so no sense creating a message
        return;
    end;
    local senderRef;
    if sender and type(sender) == "table" then
        senderRef = Reference(sender);
    end;
    if sender then
        -- Sender might be nil, so we can't just call tostring when
        -- creating the message table.
        sender = tostring(sender);
    end;
    if not firstMessage then
        firstMessage = GetTime();
    end;
    local message = {
        senderRef = senderRef,
        sender = sender,
        category = category,
        timestamp = math.floor((GetTime() - firstMessage) * 1000),
    };
    message.value = ProcessMessage(...);
    Fire(event, message);
end;

function Log.Enter(...)
    LogMessage("ENTER", ...)
end;

function Log.Log(...)
    LogMessage("LOG", ...)
end;

function Log.Leave(sender, ...)
    if select("#", ...) > 0 then
        Log.Log(...);
    end;
    Fire("LEAVE");
end;

