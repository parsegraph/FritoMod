-- Be sure to keep these dependencies to an absolute minimum.
if nil ~= require then
    require "wow/api/Timing"; -- GetTime()
    require "fritomod/basic"; -- Reference
end;

if Log and type(Log) == "table" and Log.AddLogger then
    return;
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

    if sender == nil then
        category = category or "";
        local joined = "";
        for i=1, select("#", ...) do
            local part = tostring(select(i, ...));
            if joined == "" then
                joined = part;
            else
                joined = joined .. " " .. part;
            end;
        end;
        error("Sender must not be nil.\n\tMessage: " ..
            event .. " " .. category .. " " .. joined
        );
    end;

    local senderRef;
    if type(sender) == "table" then
        senderRef = Reference(sender);
    end;
    sender = tostring(sender);

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

function Log.Enter(sender, ...)
    LogMessage("ENTER", sender, ...)
end;
Log.Entercf = Log.Enter;

function Log.Enterf(sender, ...)
    Log.Enter(sender, nil, ...);
end;

function Log.Log(sender, ...)
    LogMessage("LOG", sender, ...)
end;
Log.Logcf = Log.Log;
Log.Message = Log.Log;
Log.Messagecf = Log.Log;

function Log.Logf(sender, ...)
    Log.Log(sender, nil, ...);
end;
Log.Messagef = Log.Logf;

function Log.Leave(sender, ...)
    if select("#", ...) > 0 then
        Log.Log(sender, ...);
    end;
    Fire("LEAVE");
end;
Log.Leavecf = Log.Leave;

function Log.Reset(sender, ...)
    if select("#", ...) > 0 then
        Log.Log(sender, ...);
    end;
    Fire("RESET");
end;
Log.Resetcf = Log.Reset;

function Log.Leavef(sender, ...)
    if select("#", ...) > 0 then
        Log.Logf(sender, ...);
    end;
    Log.Leave();
end;
