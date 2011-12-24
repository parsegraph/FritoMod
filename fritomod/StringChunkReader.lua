-- Converts messages generated from Serializers.StringChunks
--
-- See Also:
-- Serializers-StringChunks.lua

if nil ~= require then
    require "fritomod/currying";
    require "fritomod/Functions";
    require "fritomod/OOP-Class";
end;

StringChunkReader = OOP.Class();

local DELIMITER_BYTE=(":"):byte(1);

function StringChunkReader:Constructor()
    self.messages={};
    self.listeners={};
end;

function StringChunkReader:Add(listener, ...)
    return Lists.InsertFunction(self.listeners, listener, ...);
end;

function StringChunkReader:Dispatch(message, who, ...)
    trace("Dispatching %q from %q", message, who);
    Lists.CallEach(self.listeners, message, who, ...);
end;

function StringChunkReader:Read(chunk, who, ...)
    who = who or "";
    trace("Received %q from %q", chunk, who);
    if chunk:byte(1)==DELIMITER_BYTE then
        -- It's a headless chunk, so dispatch it directly.
        self:Dispatch(chunk:sub(2), who, ...);
    else
        local header, data=unpack(Strings.Split(":", chunk, 2));
        local id=who..header;
        if not self.messages[id] then
            -- A new message
            self.messages[id]={};
            self.messages[id].dataLength=#data;
        end;
        if data then
            table.insert(self.messages[id], data);
        end;
        if not data or #data < self.messages[id].dataLength then
            -- Any empty data or data that's less than previous
            -- submissions is interpreted as end-of-message.
            local message=table.concat(self.messages[id], "");
            self.messages[id]=nil;
            self:Dispatch(message, who, ...);
        end;
    end;
end;

Callbacks = Callbacks or {};
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
    local reader = StringChunkReader:New();
    reader:Add(callback, ...);
    return source(Curry(reader, "Read"));
end;
