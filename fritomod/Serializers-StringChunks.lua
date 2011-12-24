-- This provides a serializer to get around Blizzard's absurd 255-character limit on messages.
-- It will break up a long message into chunks, identifying them with a header so they may
-- be reassembled.
--
-- I think this code will work well, but it might behoove us to embed the header in the prefix
-- itself, instead of having them separate. I like having them separate for now, though, since
-- that allows us to use this serializer in any addon channel that we want to use it in. On the
-- flipside, we waste a bit of bandwidth.
--
-- There's also work to be done on the header itself. Right now, it's a integer literally represented
-- as a string. It wouldn't be too difficult to compress it into the bytes of the characters.

if nil ~= require then
    require "fritomod/basic";
end;

Serializers=Serializers or {};

-- Chunks are strings sent over the wire. They are comprised of a header and data, delimited
-- by a colon ':' character.
--
-- header:data
--
-- The header identifies the chunk's group. All chunks with the same group comprise
-- the same logical message. Blizzard ensures that messages arrive in the same order
-- as they are sent.
--
-- The data is a slice of the logical message. There are no restrictions over the
-- content of the message, except those placed by Blizzard: no \0.

-- The maximum sendable message is 255 characters. We exclude two characters beyond this, to
-- account for Blizzard's delimiter between the prefix and the chunk. We subtract another
-- character for our delimiter between the header and the data.
--
-- The total string looks something like this:
--
-- "prefix\theader:data\0"
local MAX_CHUNK_SIZE=255-1-1;

-- If a message is of a sufficiently small size, we will send it without a header. This should
-- occur regardless of what header scheme we're using.

-- Our current header system is simple but inefficient. It consists of an integer, represented
-- plainly as a string, between 1 and MAX_CHUNK_GROUP.

-- One beneath a hundred thousand groups should be sufficient for now. Once we exceed this amount,
-- we loop back to 1, so it's pretty safe.
local MAX_CHUNK_GROUP=1e5-1;

local MAX_HEADER_SIZE=#tostring(MAX_CHUNK_GROUP);

local chunkGroup=-1;

-- message
--     the data we want to send.
-- padding
--     strings that reduce the chunk size of our message. Typically, this will be the string value
--     of the prefix.
function Serializers.WriteStringChunks(message, padding)
    if IsCallable(message) then
        return Serializers.WriteStringChunks(message(), padding);
    elseif type(message)=="table" then
        if #message==1 then
            return Serializers.WriteStringChunks(message[1], padding);
        end;
        local chunks={};
        for i=1, #message do
            local v=Serializers.WriteStringChunks(message[i], padding);
            if type(v)=="table" then
                Lists.InsertAll(chunks, v);
            else
                table.insert(chunks, v);
            end;
        end;
        return chunks
    elseif not IsPrimitive(message) then
        error("Unsupported "..type(message).." value: "..tostring(message));
    end;
    while type(padding)~="number" do
        if IsCallable(padding) then
            padding=padding();
        elseif IsPrimitive(padding) then
            padding=#tostring(padding);
        elseif padding==nil then
            padding=0;
        else
            error("Unsupported "..type(padding).." value: "..tostring(padding));
        end;
    end;
    assert(padding>=0, "Negative padding does not make sense. Padding was: "..padding);
    -- Check if we can actually make progress sending our message. If the padding is too big, then
    -- we can't send the message.
    --
    -- We're intentionally pessimistic here. I don't want messages being able to send at some points,
    -- then failing to send later because our header became too big. I'd rather they always fail.
    if MAX_CHUNK_SIZE-MAX_HEADER_SIZE-padding < 1 then
        error("Padding is too big. Padding size is "..padding.." but "..
            "MAX_CHUNK_SIZE is "..MAX_CHUNK_SIZE.." and "..
            "MAX_HEADER_SIZE is "..MAX_HEADER_SIZE);
    end;

    -- If our message with its padding is less than MAX_CHUNK_SIZE, we don't need a header whatsoever.
    if #message + padding <= MAX_CHUNK_SIZE then
        return ":"..message;
    end;
    chunkGroup=chunkGroup+1;
    if chunkGroup > MAX_CHUNK_GROUP then
        -- We overflowed, so reset to 0.
        chunkGroup=0;
    end;
    local header=chunkGroup..":";
    -- Observe that even though we're pessimistic in the above assertion, we still send the maximum
    -- possible data.
    local messageSize=MAX_CHUNK_SIZE-#header-padding;
    local chunks={};
    for i=1,#message,messageSize do
        table.insert(chunks, header..message:sub(i, i+messageSize-1));
    end;
    if #chunks[#chunks]==messageSize then
        -- Our last message was completely full, so we need to send another one to indicate we've finished.
        table.insert(chunks, header);
    end;
    return chunks;
end;
