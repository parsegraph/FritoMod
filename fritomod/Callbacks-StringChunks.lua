-- A callback that handles the receiving end of Serializers.StringChunks.

if nil ~= require then
    require "fritomod/currying";
end;

Callbacks=Callbacks or {};

local DELIMITER_BYTE=(":"):byte(1);

-- This is a callback that will piece together string chunks provided from
-- the specified source.
--
-- local r=Callbacks.StringChunks(Remote["FritoMod.Chat"], function(msg, who)
--     printf("%s said %q", who, msg);
-- end);
--
-- You'll pretty much always use this in tandem with Serializers.StringChunks,
-- who would send:
--
-- local prefix = "FritoMod.Chat";
-- Remote[prefix].g(Serializers.WriteStringChunks(aSuperLongString, prefix));
--
-- source
--     A function that provides data to registered callbacks. Remote is
--     by far the most common source.
-- callback, ...
--     A callback that expects messages from the source. The callback will
--     be invoked whenever a full message is received.
-- returns
--    a function that disables this callback.
-- see
--    Serializers.StringChunks for the other side of this function.
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
