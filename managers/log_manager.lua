function debug(...)
    return LoggingManager:Log(...);
end;

-------------------------------------------------------------------------------
--
--  LoggingManager
--
-------------------------------------------------------------------------------

LoggingManager = {
    outputs = {},
};
LoggingManager.log = Log:new(LoggingManager, "LoggingManager")
MixinLog(LoggingManager);
local LoggingManager = LoggingManager;

function LoggingManager:CaptureOutput(outputFunc, ...)
    local outputFunc = ObjFunc(outputFunc, ...);
    table.insert(self.outputs, outputFunc);
    return function()
        if self.outputs[#self.outputs] ~= outputFunc then
            error("LoggingManager:Attempting to release outputs out-of-order.");
        end;
        return table.remove(self.outputs);
    end;
end;

function LoggingManager:Log(...)
    self.log:Log(...);
    if self.outputs[1] then
        self.outputs[1](...);
    end;
end;

function LoggingManager:Print(...)
    print(...);
end;
