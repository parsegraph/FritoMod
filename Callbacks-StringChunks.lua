if nil ~= require then
    require "currying";
end;

Callbacks=Callbacks or {};

local DELIMITER_BYTE=(":"):byte(1);

function Callbacks.StringChunks(source, callback, ...)
    callback=Curry(callback, ...);
    local messages={};
    return source(function(chunk, who, ...)
        if chunk:byte(1)==DELIMITER_BYTE then
            -- It's a headless chunk, so dispatch it directly.
            callback(chunk:sub(2), who, ...);
        else    
            local header, data=unpack(Strings.Split(":", chunk, 2));
            local id=who..header;
            if not messages[id] then
                messages[id]={};
                messages[id].dataLength=#data;
            end;
            if data then
                table.insert(messages[id], data);
            end;
            if not data or #data < messages[id].dataLength then
                local message=table.concat(messages[id], "");
                messages[id]=nil;
                callback(message, who, ...);
            end;
        end;
    end);
end;
