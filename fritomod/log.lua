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

function Log.Enter(sender, category, ...)
    if sender then
        sender = tostring(sender);
    end;
    local message = {
        sender = sender,
        category = category,
        -- FIXME This won't work outside of Rainback
        timestamp = math.floor(Rainback.GetTime()),
    };
    message.message = ProcessMessage(...);
    Fire("ENTER", message);
end;

function Log.Log(sender, category, ...)
    if sender then
        sender = tostring(sender);
    end;
    local message = {
        sender = sender,
        category = category,
        timestamp = Math.Round(Rainback.GetTime()),
    };
    message.message = ProcessMessage(...);
    Fire("LOG", message);
end;

function Log.Leave(sender, ...)
    if select("#", ...) > 0 then
        Log.Log(...);
    end;
    Fire("LEAVE");
end;

