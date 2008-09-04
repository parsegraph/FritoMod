function debug(...)
    return LogManager:Log(...);
end;

-------------------------------------------------------------------------------
--
--  LogManager
--
-------------------------------------------------------------------------------

LogManager = {
    outputs = {},
};
LogManager.log = Log:new(LogManager, "LogManager")
MixinLog(LogManager);
local LogManager = LogManager;

function LogManager:Capture(outputFunc, ...)
    local outputFunc = ObjFunc(outputFunc, ...);
    table.insert(self.outputs, outputFunc);
    return function()
        if self.outputs[#self.outputs] ~= outputFunc then
            error("LogManager:Attempting to release outputs out-of-order.");
        end;
        return table.remove(self.outputs);
    end;
end;

function LogManager:Release()
    table.remove(self.outputs);
end;

function LogManager:Pipe(chatType)
    if chatType == "DEBUG" then
        return self:Capture(function(...)
            ChatFrame1:AddMessage(tostring(concat(...)));
        end);
    end;
    return self:Capture(function(...)
        SendChatMessage(tostring(concat(...)), chatType);
    end);
end;

function LogManager:Log(...)
    self.log:Log(...);
    if self.outputs[1] then
        self.outputs[1](...);
    end;
end;

function LogManager:Print(...)
    print(...);
end;
